import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ScaleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Abstract contract for digital scale integration.
abstract class BluetoothScaleService {
  Stream<double> get weightStream;
  Stream<ScaleConnectionStatus> get statusStream;
  ScaleConnectionStatus get currentStatus;
  String? get connectedDeviceName;

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)});
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> tare();
  void dispose();
}

/// Production BLE Scale Service integrating standard GATT UART profile:
/// - Service UUID: 0xFFE0
/// - Characteristic UUID: 0xFFE1
class BleScaleService implements BluetoothScaleService {
  BleScaleService() {
    _statusController.add(_status);
  }

  static final Guid uartServiceUuid = Guid("0000ffe0-0000-1000-8000-00805f9b34fb");
  static final Guid uartCharacteristicUuid = Guid("0000ffe1-0000-1000-8000-00805f9b34fb");

  final _weightController = StreamController<double>.broadcast();
  final _statusController = StreamController<ScaleConnectionStatus>.broadcast();

  ScaleConnectionStatus _status = ScaleConnectionStatus.disconnected;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _notifyCharacteristic;
  StreamSubscription<List<int>>? _charSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  ScaleConnectionStatus get currentStatus => _status;

  @override
  String? get connectedDeviceName => _connectedDevice?.platformName.isNotEmpty == true
      ? _connectedDevice!.platformName
      : _connectedDevice?.remoteId.str;

  @override
  Stream<double> get weightStream => _weightController.stream;

  @override
  Stream<ScaleConnectionStatus> get statusStream => _statusController.stream;

  void _updateStatus(ScaleConnectionStatus newStatus) {
    _status = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // 1. Check if Bluetooth hardware is supported
      if (!await FlutterBluePlus.isSupported) {
        debugPrint('[BleScaleService] Bluetooth is not supported on this device.');
        _updateStatus(ScaleConnectionStatus.error);
        return;
      }

      // 2. Ensure adapter is powered on
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        debugPrint('[BleScaleService] Bluetooth adapter is off. Waiting or prompting user...');
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (_) {}
        }
      }

      _updateStatus(ScaleConnectionStatus.scanning);

      // 3. Scan for nearby BLE devices
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [uartServiceUuid],
      );

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          final name = r.device.platformName.toUpperCase();
          final services = r.advertisementData.serviceUuids;
          // Auto-identify scale devices
          if (services.contains(uartServiceUuid) ||
              name.contains('SCALE') ||
              name.contains('WEIGHT') ||
              name.contains('BLE') ||
              name.contains('ELECTRONIC') ||
              name.contains('CAS')) {
            debugPrint('[BleScaleService] Found matching scale: ${r.device.platformName} (${r.device.remoteId})');
            await FlutterBluePlus.stopScan();
            await connect(r.device.remoteId.str);
            break;
          }
        }
      });
    } catch (e) {
      debugPrint('[BleScaleService] Scan failed: $e');
      _updateStatus(ScaleConnectionStatus.error);
    }
  }

  @override
  Future<void> connect(String deviceId) async {
    try {
      _updateStatus(ScaleConnectionStatus.connecting);
      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;

      // Connect with autoConnect false and timeout
      await device.connect(timeout: const Duration(seconds: 8), autoConnect: false);

      // Discover GATT services
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.serviceUuid == uartServiceUuid || s.serviceUuid.str.contains('ffe0')) {
          for (final c in s.characteristics) {
            if (c.characteristicUuid == uartCharacteristicUuid || c.characteristicUuid.str.contains('ffe1')) {
              _notifyCharacteristic = c;
              break;
            }
          }
        }
      }

      if (_notifyCharacteristic != null) {
        await _notifyCharacteristic!.setNotifyValue(true);
        _charSubscription?.cancel();
        _charSubscription = _notifyCharacteristic!.onValueReceived.listen((bytes) {
          final parsedWeight = parseWeightFromBytes(bytes);
          if (parsedWeight != null && !_weightController.isClosed) {
            _weightController.add(parsedWeight);
          }
        });

        _updateStatus(ScaleConnectionStatus.connected);
        debugPrint('[BleScaleService] Successfully connected and subscribed to scale UART stream.');
      } else {
        debugPrint('[BleScaleService] UART Service (0xFFE0 / 0xFFE1) characteristic not found on device.');
        _updateStatus(ScaleConnectionStatus.error);
      }
    } catch (e) {
      debugPrint('[BleScaleService] Connection exception: $e');
      _updateStatus(ScaleConnectionStatus.error);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _charSubscription?.cancel();
      _scanSubscription?.cancel();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
    } catch (e) {
      debugPrint('[BleScaleService] Disconnect error: $e');
    } finally {
      _connectedDevice = null;
      _notifyCharacteristic = null;
      _updateStatus(ScaleConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> tare() async {
    // Standard GATT scale Tare command ('T\r\n' in ASCII)
    if (_notifyCharacteristic != null && _status == ScaleConnectionStatus.connected) {
      try {
        await _notifyCharacteristic!.write(utf8.encode('T\r\n'), withoutResponse: true);
      } catch (_) {}
    }
    if (!_weightController.isClosed) {
      _weightController.add(0.0);
    }
  }

  /// Parses incoming BLE UART byte arrays into a double weight in kg.
  /// Handles standard ASCII string packets (e.g. "ST,GS,+  12.50kg\r\n" or "12.50\n")
  /// as well as raw 16-bit little-endian binary formats.
  static double? parseWeightFromBytes(List<int> bytes) {
    if (bytes.isEmpty) return null;

    try {
      // 1. Try ASCII string decoding
      final rawStr = utf8.decode(bytes, allowMalformed: true).trim();
      final hasDigits = RegExp(r'[0-9]').hasMatch(rawStr);
      if (hasDigits) {
        final regex = RegExp(r'[-+]?\s*([0-9]+\.?[0-9]*)');
        final match = regex.firstMatch(rawStr);
        if (match != null) {
          final val = double.tryParse(match.group(1) ?? '');
          if (val != null && val >= 0 && val < 5000) {
            return double.parse(val.toStringAsFixed(2));
          }
        }
      }

      // If it contains ASCII readable text without digits, it is an unrecognized text packet
      final isPureAsciiText = rawStr.isNotEmpty && rawStr.runes.every((r) => r >= 32 && r <= 126);
      if (isPureAsciiText && !hasDigits) {
        return null;
      }

      // 2. Fallback to raw binary 2-byte uint (scaled by 100)
      if (bytes.length >= 2) {
        final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
        final intVal = byteData.getUint16(0, Endian.little);
        if (intVal > 0 && intVal < 50000) {
          return double.parse((intVal / 100.0).toStringAsFixed(2));
        }
      }
    } catch (e) {
      debugPrint('[BleScaleService] Failed to parse scale byte packet: $e');
    }
    return null;
  }

  @override
  void dispose() {
    disconnect();
    _weightController.close();
    _statusController.close();
  }
}

/// Fallback / Stub implementation for testing and environments without BLE hardware.
class StubBluetoothScaleService implements BluetoothScaleService {
  StubBluetoothScaleService({this.simulatedWeight = 0.0});

  final double simulatedWeight;
  final _weightController = StreamController<double>.broadcast();
  final _statusController = StreamController<ScaleConnectionStatus>.broadcast();

  ScaleConnectionStatus _status = ScaleConnectionStatus.disconnected;

  @override
  ScaleConnectionStatus get currentStatus => _status;

  @override
  String? get connectedDeviceName => 'Demo Scale (Hardware Stub)';

  @override
  Stream<double> get weightStream => _weightController.stream;

  @override
  Stream<ScaleConnectionStatus> get statusStream => _statusController.stream;

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    _status = ScaleConnectionStatus.scanning;
    _statusController.add(_status);
  }

  @override
  Future<void> connect(String deviceId) async {
    _status = ScaleConnectionStatus.connecting;
    _statusController.add(_status);

    await Future.delayed(const Duration(milliseconds: 300));
    _status = ScaleConnectionStatus.connected;
    _statusController.add(_status);

    if (simulatedWeight > 0) {
      _weightController.add(simulatedWeight);
    }
  }

  @override
  Future<void> disconnect() async {
    _status = ScaleConnectionStatus.disconnected;
    _statusController.add(_status);
  }

  @override
  Future<void> tare() async {
    _weightController.add(0.0);
  }

  @override
  void dispose() {
    _weightController.close();
    _statusController.close();
  }
}

import 'dart:async';

enum ScaleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Abstract contract for Bluetooth digital scale integration.
/// Designed for dual weight verification (collector & recycler handovers).
abstract class BluetoothScaleService {
  Stream<double> get weightStream;
  Stream<ScaleConnectionStatus> get statusStream;
  ScaleConnectionStatus get currentStatus;

  Future<void> startScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> tare();
  void dispose();
}

/// Stub implementation of Bluetooth scale interface for hardware decoupling
/// and test environments.
class StubBluetoothScaleService implements BluetoothScaleService {
  StubBluetoothScaleService({this.simulatedWeight = 0.0});

  final double simulatedWeight;
  final _weightController = StreamController<double>.broadcast();
  final _statusController = StreamController<ScaleConnectionStatus>.broadcast();

  ScaleConnectionStatus _status = ScaleConnectionStatus.disconnected;

  @override
  ScaleConnectionStatus get currentStatus => _status;

  @override
  Stream<double> get weightStream => _weightController.stream;

  @override
  Stream<ScaleConnectionStatus> get statusStream => _statusController.stream;

  @override
  Future<void> startScan() async {
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

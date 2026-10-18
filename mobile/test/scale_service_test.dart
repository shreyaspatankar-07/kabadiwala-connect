import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/hardware/scale_service.dart';

void main() {
  group('BleScaleService Byte Parser Tests', () {
    test('1. Parses standard ASCII scale stream format: ST,GS,+  12.50kg', () {
      final bytes = utf8.encode('ST,GS,+  12.50kg\r\n');
      final weight = BleScaleService.parseWeightFromBytes(bytes);
      expect(weight, equals(12.5));
    });

    test('2. Parses clean numeric ASCII string: 8.75', () {
      final bytes = utf8.encode('8.75\n');
      final weight = BleScaleService.parseWeightFromBytes(bytes);
      expect(weight, equals(8.75));
    });

    test('3. Parses integer weight in ASCII format: 42', () {
      final bytes = utf8.encode('42\r\n');
      final weight = BleScaleService.parseWeightFromBytes(bytes);
      expect(weight, equals(42.0));
    });

    test('4. Parses 16-bit binary little-endian byte stream (scaled x100)', () {
      // 15.25 kg -> 1525 (0x05F5 in little-endian: [0xF5, 0x05])
      final data = Uint8List(2);
      final byteData = ByteData.sublistView(data);
      byteData.setUint16(0, 1525, Endian.little);

      final weight = BleScaleService.parseWeightFromBytes(data);
      expect(weight, equals(15.25));
    });

    test('5. Handles empty and malformed payloads gracefully without throwing', () {
      expect(BleScaleService.parseWeightFromBytes([]), isNull);
      expect(BleScaleService.parseWeightFromBytes(utf8.encode('INVALID_NO_NUMS')), isNull);
    });
  });

  group('StubBluetoothScaleService Flow Tests', () {
    test('Stream emits simulated weight upon connection', () async {
      final stub = StubBluetoothScaleService(simulatedWeight: 24.5);
      expect(stub.currentStatus, equals(ScaleConnectionStatus.disconnected));

      final weightFuture = stub.weightStream.first;
      await stub.connect('MOCK_DEV_1');

      expect(stub.currentStatus, equals(ScaleConnectionStatus.connected));
      final weight = await weightFuture;
      expect(weight, equals(24.5));

      stub.dispose();
    });
  });
}

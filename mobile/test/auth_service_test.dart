import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kabadiwala_mobile/core/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('AuthService Dynamic Zero-PII Identity Tests', () {
    test('1. First launch generates a cryptographically secure UUIDv4 prefixed with KC-C-', () async {
      final auth = AuthService();
      await auth.clearAll();

      final collectorId = await auth.getOrCreateCollectorId();
      expect(collectorId, startsWith('KC-C-'));
      // Format: KC-C-<UUID-36-chars> -> Length = 5 + 36 = 41
      expect(collectorId.length, equals(41));
    });

    test('2. Subsequent calls return the identical persisted collector ID', () async {
      final auth = AuthService();
      final firstId = await auth.getOrCreateCollectorId();
      final secondId = await auth.getOrCreateCollectorId();
      final storedId = await auth.getCollectorId();

      expect(secondId, equals(firstId));
      expect(storedId, equals(firstId));
    });

    test('3. PIN hash save and verification via secure storage', () async {
      final auth = AuthService();
      await auth.savePinHash('hash_secure_1234');

      expect(await auth.verifyPin('hash_secure_1234'), isTrue);
      expect(await auth.verifyPin('wrong_hash'), isFalse);
    });

    test('4. clearAll() wipes secure identity and credentials', () async {
      final auth = AuthService();
      await auth.getOrCreateCollectorId();
      await auth.savePinHash('pin_hash');

      await auth.clearAll();
      expect(await auth.getCollectorId(), isNull);
      expect(await auth.verifyPin('pin_hash'), isFalse);
    });
  });
}

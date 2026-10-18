import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/core/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService Real-Time GPS Unit Tests', () {
    tearDown(() {
      LocationService.mockLocationString = null;
    });

    test('1. Successful GPS: returns formatted string "Lat: {lat}, Lng: {lng}"', () async {
      LocationService.mockLocationString = 'Lat: 19.076000, Lng: 72.877700';

      final result = await LocationService.getCurrentLocationString();
      expect(result, 'Lat: 19.076000, Lng: 72.877700');

      final coords = LocationService.parseCoordinates(result);
      expect(coords, isNotNull);
      expect(coords!.latitude, 19.076000);
      expect(coords.longitude, 72.877700);
    });

    test('2. GPS Unavailable: returns exact failure string "GPS Unavailable"', () async {
      LocationService.mockLocationString = 'GPS Unavailable';

      final result = await LocationService.getCurrentLocationString();
      expect(result, 'GPS Unavailable');

      final coords = LocationService.parseCoordinates(result);
      expect(coords, isNull);
    });

    test('3. Permission Denied: returns exact failure string "Permission Denied"', () async {
      LocationService.mockLocationString = 'Permission Denied';

      final result = await LocationService.getCurrentLocationString();
      expect(result, 'Permission Denied');

      final coords = LocationService.parseCoordinates(result);
      expect(coords, isNull);
    });

    test('4. parseCoordinates helper: handles edge cases safely', () {
      expect(LocationService.parseCoordinates(''), isNull);
      expect(LocationService.parseCoordinates('Invalid string'), isNull);
      expect(LocationService.parseCoordinates('Lat: 28.613939, Lng: 77.209021'), isNotNull);
      final delhi = LocationService.parseCoordinates('Lat: 28.613939, Lng: 77.209021')!;
      expect(delhi.latitude, closeTo(28.613939, 0.0001));
      expect(delhi.longitude, closeTo(77.209021, 0.0001));
    });

    test('5. Instance method proxy works consistently', () async {
      LocationService.mockLocationString = 'Lat: 18.520400, Lng: 73.856700';
      const service = LocationService();

      final result = await service.getLocationString();
      expect(result, 'Lat: 18.520400, Lng: 73.856700');
    });
  });
}

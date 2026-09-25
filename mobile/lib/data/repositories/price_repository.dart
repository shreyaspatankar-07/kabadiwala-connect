import 'package:drift/drift.dart';
import '../local_database.dart';

class PriceRepository {
  PriceRepository(this._db);

  final AppDatabase _db;

  /// Watch cached prices for a given district
  Stream<List<CachedPrice>> watchPricesForDistrict(String district) {
    return (_db.select(_db.cachedPrices)
          ..where((p) => p.district.equals(district))
          ..orderBy([(p) => OrderingTerm.asc(p.category)]))
        .watch();
  }

  /// Watch all cached prices
  Stream<List<CachedPrice>> watchAllPrices() {
    return (_db.select(_db.cachedPrices)
          ..orderBy([(p) => OrderingTerm.asc(p.category)]))
        .watch();
  }

  /// Seed initial fallback prices if cache is empty
  Future<void> seedInitialPricesIfEmpty() async {
    final existing = await _db.select(_db.cachedPrices).get();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final initialRates = [
      ('PCB High-Grade', 'संगणक / मोबाईल सर्किट', 420.0, 390.0, 450.0),
      ('Copper Wire', 'तांब्याची वायर', 680.0, 650.0, 720.0),
      ('Batteries (Li-ion)', 'लिथियम बॅटरी', 140.0, 120.0, 160.0),
      ('CRT / Monitor', 'जुना टीव्ही / मॉनिटर', 18.0, 15.0, 22.0),
      ('LCD / LED', 'स्क्रीन पॅनेल', 45.0, 35.0, 55.0),
      ('Motors', 'मोटर / कॉपर कॉइल', 85.0, 75.0, 95.0),
      ('Mixed Plastics', 'ई-कचरा प्लास्टिक', 12.0, 10.0, 15.0),
    ];

    for (var i = 0; i < initialRates.length; i++) {
      final rate = initialRates[i];
      await _db.into(_db.cachedPrices).insert(
        CachedPricesCompanion.insert(
          id: 'SEED-PR-$i',
          category: rate.$1,
          subCategory: Value(rate.$2),
          district: 'Palghar',
          latitude: 19.6967,
          longitude: 72.7699,
          recordedAt: now,
          buyingPrice: rate.$3,
          sellingQuotedPrice: rate.$3,
          marketMin: rate.$4,
          marketMax: rate.$5,
          createdAt: now,
        ),
      );
    }
  }
}

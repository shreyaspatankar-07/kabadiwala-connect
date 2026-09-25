import 'dart:convert';
import 'dart:math' as math;
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

  /// Check whether price data is older than 3 days
  static bool isCacheStale(DateTime? recordedAt) {
    if (recordedAt == null) return true;
    final difference = DateTime.now().difference(recordedAt);
    return difference.inDays >= 3;
  }

  /// Generate continuous 30-day sparkline trend data around a benchmark rate
  static List<double> generateSparklinePoints(double baseRate) {
    final points = <double>[];
    for (var i = 29; i >= 0; i--) {
      final delta = math.sin(i / 3.0) * (baseRate * 0.05);
      points.add(double.parse((baseRate + delta).toStringAsFixed(1)));
    }
    return points;
  }

  /// Save a price report submitted by collector from field; enqueues to sync queue
  Future<String> savePriceReport({
    required String category,
    required double offeredPrice,
    required String district,
    String? subCategory,
    String? notes,
  }) async {
    final now = DateTime.now();
    final clientTxId = 'PR-REP-${now.millisecondsSinceEpoch}';

    final payload = jsonEncode({
      'clientTxId': clientTxId,
      'category': category,
      'sub_category': subCategory,
      'district': district,
      'offered_price': offeredPrice,
      'unit': 'kg',
      'source': 'collector_report',
      'notes': notes,
      'timestamp': now.toIso8601String(),
    });

    // 1. Enqueue into SyncQueueEntries for background sync
    await _db.into(_db.syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        clientTxId: clientTxId,
        collectorId: 'COLLECTOR-LOCAL',
        action: 'report_price',
        payloadJson: payload,
        clientTimestamp: now,
        createdAt: now,
      ),
    );

    // 2. Insert into local CachedPrices
    await _db.into(_db.cachedPrices).insertOnConflictUpdate(
      CachedPricesCompanion.insert(
        id: clientTxId,
        category: category,
        subCategory: Value(subCategory),
        district: district,
        latitude: 19.6967,
        longitude: 72.7699,
        recordedAt: now,
        buyingPrice: offeredPrice,
        sellingQuotedPrice: offeredPrice,
        marketMin: offeredPrice * 0.9,
        marketMax: offeredPrice * 1.1,
        source: const Value('collector_report'),
        createdAt: now,
      ),
    );

    return clientTxId;
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

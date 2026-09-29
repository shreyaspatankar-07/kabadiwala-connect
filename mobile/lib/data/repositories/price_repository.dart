import 'dart:convert';
import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../local_database.dart';

class PriceRepository {
  PriceRepository(this._db, {http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final AppDatabase _db;
  final http.Client _http;

  AppDatabase get db => _db;

  /// Canonical category normalizer across vernacular and raw strings
  static String normalizeCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('pcb') || lower.contains('circuit') || lower.contains('board')) return 'PCB';
    if (lower.contains('cable') || lower.contains('wire') || lower.contains('copper')) return 'Cables';
    if (lower.contains('batt')) return 'Batteries';
    if (lower.contains('lcd') || lower.contains('screen') || lower.contains('panel') || lower.contains('led')) return 'LCD';
    if (lower.contains('motor') || lower.contains('magnet') || lower.contains('coil')) return 'Motors_Magnets';
    if (lower.contains('crt') || lower.contains('tv') || lower.contains('monitor')) return 'CRT';
    if (lower.contains('plastic')) return 'Mixed_Plastics';
    return cat;
  }

  /// Watch cached prices for a given district, ordered by most recently recorded
  Stream<List<CachedPrice>> watchPricesForDistrict(String district) {
    return (_db.select(_db.cachedPrices)
          ..where((p) => p.district.equals(district))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  /// Watch all cached prices, ordered by most recently recorded
  Stream<List<CachedPrice>> watchAllPrices() {
    return (_db.select(_db.cachedPrices)
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
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

  /// Upsert a single price record for district and category
  Future<void> upsertPrice({
    required String category,
    required String district,
    required double buyingPrice,
    double? marketMin,
    double? marketMax,
    double? recyclerQuote,
    String? subCategory,
    DateTime? recordedAt,
  }) async {
    final now = DateTime.now();
    final canonicalCat = normalizeCategory(category);
    final id = 'PRICE-${district.toUpperCase()}-$canonicalCat';
    await _db.into(_db.cachedPrices).insertOnConflictUpdate(
      CachedPricesCompanion.insert(
        id: id,
        category: canonicalCat,
        subCategory: Value(subCategory),
        district: district,
        latitude: 19.6967,
        longitude: 72.7699,
        recordedAt: recordedAt ?? now,
        buyingPrice: buyingPrice,
        sellingQuotedPrice: recyclerQuote ?? buyingPrice,
        marketMin: marketMin ?? (buyingPrice * 0.9),
        marketMax: marketMax ?? (buyingPrice * 1.1),
        source: const Value('server_sync'),
        createdAt: now,
      ),
    );
  }

  /// Fetch latest prices directly from backend server and update cache
  Future<bool> fetchLatestPricesFromServer([String? serverBaseUrl]) async {
    final List<String> candidateUrls = [];
    if (serverBaseUrl != null) {
      candidateUrls.add(serverBaseUrl);
    } else {
      if (kIsWeb) {
        candidateUrls.add('http://localhost:8000/api/v1');
      } else {
        candidateUrls.addAll([
          'http://10.0.2.2:8000/api/v1',
          'http://localhost:8000/api/v1',
          'http://127.0.0.1:8000/api/v1',
        ]);
      }
    }

    for (final base in candidateUrls) {
      try {
        final uri = Uri.parse('$base/prices');
        final resp = await _http.get(uri).timeout(const Duration(seconds: 4));
        if (resp.statusCode == 200) {
          final List<dynamic> list = jsonDecode(resp.body);
          for (final item in list) {
            final rawCat = item['category']?.toString() ?? 'PCB';
            final canonical = normalizeCategory(rawCat);
            final district = item['district']?.toString() ?? 'Palghar';
            final buyingPrice = (item['buying_price'] as num?)?.toDouble() ?? 0.0;
            final marketMin = (item['market_min'] as num?)?.toDouble();
            final marketMax = (item['market_max'] as num?)?.toDouble();
            final quote = (item['selling_quoted_price'] as num?)?.toDouble();
            final recordedAt = DateTime.tryParse(item['recorded_at']?.toString() ?? '');

            if (buyingPrice > 0) {
              await upsertPrice(
                category: canonical,
                district: district,
                buyingPrice: buyingPrice,
                marketMin: marketMin,
                marketMax: marketMax,
                recyclerQuote: quote,
                recordedAt: recordedAt,
              );
            }
          }
          return true;
        }
      } catch (e) {
        debugPrint('[PriceRepository] fetchLatestPrices error from $base: $e');
      }
    }
    return false;
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
    final canonicalCat = normalizeCategory(category);

    final payload = jsonEncode({
      'clientTxId': clientTxId,
      'category': canonicalCat,
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
        category: canonicalCat,
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
      ('PCB High-Grade', 'संगणक / मोबाईल सर्किट', 420.0, 390.0, 450.0, 435.0),
      ('Copper Wire / Cables', 'तांब्याची वायर', 680.0, 650.0, 720.0, 700.0),
      ('Batteries', 'लिथियम बॅटरी', 140.0, 120.0, 160.0, 145.0),
      ('LCD', 'स्क्रीन पॅनेल', 45.0, 35.0, 55.0, 48.0),
      ('Motors_Magnets', 'मोटर / कॉपर कॉइल', 85.0, 75.0, 95.0, 88.0),
      ('CRT', 'जुना टीव्ही / मॉनिटर', 18.0, 15.0, 22.0, 19.0),
      ('Mixed_Plastics', 'ई-कचरा प्लास्टिक', 12.0, 10.0, 15.0, 13.0),
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
          sellingQuotedPrice: rate.$6,
          marketMin: rate.$4,
          marketMax: rate.$5,
          createdAt: now,
        ),
      );
    }
  }
}

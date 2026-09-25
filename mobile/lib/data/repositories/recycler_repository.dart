import 'dart:convert';
import 'package:drift/drift.dart';
import '../local_database.dart';
import '../matching/offline_matching_engine.dart';

class RecyclerRepository {
  RecyclerRepository(this._db);

  final AppDatabase _db;

  /// Retrieves top matching buyers for a given lot completely offline from Drift cache.
  Future<List<RankedRecyclerResult>> getBestBuyers(
    OfflineLotInput lot, {
    DateTime? currentDate,
    List<RecyclerCandidateData>? overrideCandidates,
  }) async {
    List<RecyclerCandidateData> candidates;

    if (overrideCandidates != null && overrideCandidates.isNotEmpty) {
      candidates = overrideCandidates;
    } else {
      final rows = await _db.select(_db.cachedRecyclers).get();
      candidates = rows.map((r) {
        List<String> mats = [];
        try {
          final decoded = jsonDecode(r.materialsAcceptedJson);
          if (decoded is List) {
            mats = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}

        Map<String, double> rates = {};
        try {
          final decoded = jsonDecode(r.offeredRatesJson);
          if (decoded is Map) {
            decoded.forEach((k, v) {
              if (v is num) rates[k.toString()] = v.toDouble();
            });
          }
        } catch (_) {}

        Map<String, dynamic> area = {};
        try {
          final decoded = jsonDecode(r.serviceAreaJson);
          if (decoded is Map) {
            area = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}

        return RecyclerCandidateData(
          id: r.id,
          name: r.name,
          latitude: r.latitude,
          longitude: r.longitude,
          materialsAccepted: mats,
          authorizationNumber: r.authorizationNumber,
          authorizationStatus: r.authorizationStatus,
          authorizationValidTill: r.authorizationValidTill,
          phone: r.phone,
          offeredRates: rates,
          pickupAvailable: r.pickupAvailable,
          pickupRadiusKm: r.pickupRadiusKm,
          serviceArea: area,
          rating: r.rating,
        );
      }).toList();
    }

    return OfflineMatchingEngine.rankCandidates(
      candidates,
      lot,
      currentDate: currentDate,
    );
  }

  /// Saves or refreshes recyclers into Drift cache.
  Future<void> cacheRecyclers(List<RecyclerCandidateData> candidates) async {
    await _db.batch((batch) {
      for (final c in candidates) {
        batch.insert(
          _db.cachedRecyclers,
          CachedRecyclersCompanion.insert(
            id: c.id,
            name: c.name,
            latitude: c.latitude,
            longitude: c.longitude,
            materialsAcceptedJson: jsonEncode(c.materialsAccepted),
            authorizationNumber: c.authorizationNumber,
            authorizationBody: 'CPCB',
            authorizationStatus: c.authorizationStatus,
            authorizationValidTill: c.authorizationValidTill,
            phone: c.phone,
            offeredRatesJson: jsonEncode(c.offeredRates),
            pickupAvailable: Value(c.pickupAvailable),
            pickupRadiusKm: Value(c.pickupRadiusKm),
            serviceAreaJson: jsonEncode(c.serviceArea),
            rating: Value(c.rating),
            cachedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../local_database.dart';
import '../models/lot_item_draft.dart';

class LotRepository {
  LotRepository(this._db, {this.apiBaseUrl = 'http://10.0.2.2:8000/api/v1'});

  final AppDatabase _db;
  AppDatabase get db => _db;
  final String apiBaseUrl;
  final Uuid _uuid = const Uuid();

  /// Create a new e-waste lot completely offline.
  /// Generates client UUID, stores in LocalTransactions, queues for sync,
  /// and attempts an immediate live push if server is reachable.
  Future<LocalTransaction> createLotOffline({
    required String collectorId,
    required String category,
    required double weightKg,
    required double quotedPrice,
    required double latitude,
    required double longitude,
    String? photoHash,
    List<String>? photoHashes,
    List<LotItemDraft>? items,
    String? subCategory,
    String? condition,
  }) async {
    final clientUuid = _uuid.v4();
    final now = DateTime.now();
    final dateSuffix = '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}';
    final randomSuffix = clientUuid.substring(0, 5).toUpperCase();
    final lotId = 'KC-MH-$dateSuffix-$randomSuffix';

    final entry = LocalTransactionsCompanion.insert(
      lotId: lotId,
      clientLotUuid: clientUuid,
      collectorId: collectorId,
      category: category,
      weightKg: weightKg,
      quotedPrice: quotedPrice,
      collectionLat: latitude,
      collectionLng: longitude,
      createdAt: now,
      paymentStatus: const Value('pending'),
      transactionStatus: const Value('draft'),
      isSynced: const Value(false),
    );

    await _db.into(_db.localTransactions).insert(entry);

    final resolvedPhotoHashes = photoHashes ?? (photoHash != null ? [photoHash] : <String>[]);
    final itemsPayload = items?.map((i) => i.toJson()).toList() ?? [
      {
        'category': category,
        'sub_category': subCategory,
        'condition': condition ?? 'broken',
        'weight_kg': weightKg,
        'quoted_price': quotedPrice,
        'photo_hashes': resolvedPhotoHashes,
      }
    ];

    // Queue operation in sync engine FIFO queue
    final queuePayloadMap = {
      'client_lot_id': clientUuid,
      'client_tx_id': clientUuid,
      'lot_id': lotId,
      'collector_id': collectorId,
      'category': category,
      'sub_category': subCategory,
      'condition': condition,
      'weight_kg': weightKg,
      'quoted_price': quotedPrice,
      'collection_lat': latitude,
      'collection_lng': longitude,
      'latitude': latitude,
      'longitude': longitude,
      'photo_hashes': resolvedPhotoHashes,
      'items': itemsPayload,
      'created_at': now.toIso8601String(),
    };

    final queuePayload = jsonEncode(queuePayloadMap);

    final queueEntry = SyncQueueEntriesCompanion.insert(
      clientTxId: clientUuid,
      collectorId: collectorId,
      action: 'create_lot',
      payloadJson: queuePayload,
      clientTimestamp: now,
      createdAt: now,
      status: const Value('pending'),
    );

    await _db.into(_db.syncQueueEntries).insert(queueEntry);

    // Fire non-blocking immediate live sync push
    unawaited(_tryLiveServerPush(clientUuid, queuePayloadMap));

    return (await (_db.select(_db.localTransactions)
          ..where((t) => t.lotId.equals(lotId)))
        .getSingle());
  }

  Future<void> _tryLiveServerPush(String clientUuid, Map<String, dynamic> payload) async {
    final urlsToTry = [
      apiBaseUrl,
      'http://10.149.199.230:8000/api/v1',   // PC LAN IP for physical phone on same WiFi
      'http://192.168.137.1:8000/api/v1',     // Mobile hotspot bridge IP
      'http://10.0.2.2:8000/api/v1',          // Android emulator → host loopback
      'http://localhost:8000/api/v1',
      'http://127.0.0.1:8000/api/v1',
    ];

    for (final base in urlsToTry.toSet()) {
      try {
        debugPrint('[LotRepository] Live push attempt → $base/lots (client_lot_id=$clientUuid)');
        // Send complete payload matching what the sync queue also sends.
        // The LotCreate schema accepts all these field names via AliasChoices.
        final lotBody = jsonEncode({
          'client_lot_id': payload['client_lot_id'],
          'category': payload['category'],
          'sub_category': payload['sub_category'],
          'condition': payload['condition'],
          'weight_kg': payload['weight_kg'],
          'quoted_price': payload['quoted_price'],
          'collection_lat': payload['collection_lat'],
          'collection_lng': payload['collection_lng'],
          'photo_hashes': payload['photo_hashes'] ?? [],
          'created_at': payload['created_at'],
        });

        final response = await http
            .post(
              Uri.parse('$base/lots'),
              headers: {'Content-Type': 'application/json'},
              body: lotBody,
            )
            .timeout(const Duration(seconds: 5));

        debugPrint('[LotRepository] Live push → $base status=${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('[LotRepository] Live sync succeeded → $base lot=$clientUuid');
          await (_db.update(_db.syncQueueEntries)
                ..where((e) => e.clientTxId.equals(clientUuid)))
              .write(const SyncQueueEntriesCompanion(status: Value('completed')));

          await (_db.update(_db.localTransactions)
                ..where((t) => t.clientLotUuid.equals(clientUuid)))
              .write(LocalTransactionsCompanion(
                isSynced: const Value(true),
                syncedAt: Value(DateTime.now()),
              ));
          return; // success — stop trying other URLs
        } else {
          debugPrint('[LotRepository] Live push non-2xx from $base: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        // Offline or server unreachable — fallback to background sync queue
        debugPrint('[LotRepository] Live push to $base failed (offline?): $e');
      }
    }
    debugPrint('[LotRepository] Live push exhausted all URLs; queued for background sync');
  }


  /// Watch local lots for collector
  Stream<List<LocalTransaction>> watchCollectorLots(String collectorId) {
    return (_db.select(_db.localTransactions)
          ..where((t) => t.collectorId.equals(collectorId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get all offline lots
  Future<List<LocalTransaction>> getOfflineLots([String? collectorId]) async {
    if (collectorId != null) {
      return (_db.select(_db.localTransactions)
            ..where((t) => t.collectorId.equals(collectorId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
    }
    return (_db.select(_db.localTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get pending unsynced lot count
  Future<int> getUnsyncedLotCount() async {
    final count = countAll();
    final query = _db.selectOnly(_db.localTransactions)
      ..addColumns([count])
      ..where(_db.localTransactions.isSynced.equals(false));
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }
}

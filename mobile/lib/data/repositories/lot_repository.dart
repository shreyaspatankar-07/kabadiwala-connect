import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local_database.dart';

class LotRepository {
  LotRepository(this._db);

  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  /// Create a new e-waste lot completely offline.
  /// Generates client UUID, stores in LocalTransactions, and queues for sync.
  Future<LocalTransaction> createLotOffline({
    required String collectorId,
    required String category,
    required double weightKg,
    required double quotedPrice,
    required double latitude,
    required double longitude,
    String? photoHash,
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

    // Queue operation in sync engine FIFO queue
    final queuePayload = jsonEncode({
      'client_tx_id': clientUuid,
      'lot_id': lotId,
      'collector_id': collectorId,
      'category': category,
      'weight_kg': weightKg,
      'quoted_price': quotedPrice,
      'latitude': latitude,
      'longitude': longitude,
      'photo_hash': photoHash,
      'created_at': now.toIso8601String(),
    });

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

    return (await (_db.select(_db.localTransactions)
          ..where((t) => t.lotId.equals(lotId)))
        .getSingle());
  }

  /// Watch local lots for collector
  Stream<List<LocalTransaction>> watchCollectorLots(String collectorId) {
    return (_db.select(_db.localTransactions)
          ..where((t) => t.collectorId.equals(collectorId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
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

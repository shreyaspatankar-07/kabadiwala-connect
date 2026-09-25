import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local_database.dart';

class LedgerRepository {
  LedgerRepository(this._db);

  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  /// Watch ledger entries for collector
  Stream<List<LocalLedgerData>> watchLedger(String collectorId) {
    return (_db.select(_db.localLedger)
          ..where((l) => l.collectorId.equals(collectorId))
          ..orderBy([(l) => OrderingTerm.desc(l.recordedAt)]))
        .watch();
  }

  /// Record cash payment received offline
  Future<void> recordCashPayment({
    required String collectorId,
    required double amount,
    required String description,
    String? lotId,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    // Calculate new balance
    final entries = await (_db.select(_db.localLedger)
          ..where((l) => l.collectorId.equals(collectorId))
          ..orderBy([(l) => OrderingTerm.desc(l.recordedAt)])
          ..limit(1))
        .get();

    final lastBalance = entries.isNotEmpty ? entries.first.balanceAfter : 0.0;
    final newBalance = lastBalance + amount;

    await _db.into(_db.localLedger).insert(
      LocalLedgerCompanion.insert(
        id: id,
        collectorId: collectorId,
        entryType: 'credit',
        amount: amount,
        paymentMode: const Value('cash_received'),
        description: description,
        balanceAfter: newBalance,
        recordedAt: now,
        isSynced: const Value(false),
      ),
    );
  }

  /// Get summary of total earned and pending balance
  Future<({double totalReceived, double pendingAmount})> getEarningsSummary(
    String collectorId,
  ) async {
    final entries = await (_db.select(_db.localLedger)
          ..where((l) => l.collectorId.equals(collectorId)))
        .get();

    double total = 0.0;
    for (final e in entries) {
      if (e.paymentMode == 'cash_received' || e.paymentMode == 'digital_paid') {
        total += e.amount;
      }
    }

    // Pending lots
    final pendingLots = await (_db.select(_db.localTransactions)
          ..where((t) =>
              t.collectorId.equals(collectorId) &
              t.paymentStatus.equals('pending')))
        .get();

    double pending = 0.0;
    for (final lot in pendingLots) {
      pending += (lot.finalPrice ?? lot.quotedPrice);
    }

    return (totalReceived: total, pendingAmount: pending);
  }
}

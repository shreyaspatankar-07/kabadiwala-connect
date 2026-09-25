import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local_database.dart';

class LedgerItemDetail {
  const LedgerItemDetail({
    required this.entryId,
    required this.lotId,
    required this.category,
    required this.weightKg,
    required this.amount,
    required this.paymentStatus, // 'cash_received' | 'pending' | 'digital_paid' | 'disputed'
    required this.recyclerName,
    required this.recordedAt,
    this.recyclerPhone,
  });

  final String entryId;
  final String? lotId;
  final String category;
  final double weightKg;
  final double amount;
  final String paymentStatus;
  final String recyclerName;
  final DateTime recordedAt;
  final String? recyclerPhone;
}

class EarningsOverviewData {
  const EarningsOverviewData({
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
    required this.allTimeTotal,
    required this.receivedAmount,
    required this.pendingAmount,
    required this.pendingDuesCount,
    required this.transactions,
  });

  final double todayTotal;
  final double weekTotal;
  final double monthTotal;
  final double allTimeTotal;
  final double receivedAmount;
  final double pendingAmount;
  final int pendingDuesCount;
  final List<LedgerItemDetail> transactions;
}

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

  /// Detailed collector overview with today, week, month, pending dues, and joined lot items
  Future<EarningsOverviewData> getDetailedOverview(String collectorId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));
    final monthStart = now.subtract(const Duration(days: 30));

    final ledgerEntries = await (_db.select(_db.localLedger)
          ..where((l) => l.collectorId.equals(collectorId))
          ..orderBy([(l) => OrderingTerm.desc(l.recordedAt)]))
        .get();

    double today = 0.0;
    double week = 0.0;
    double month = 0.0;
    double allTime = 0.0;
    double received = 0.0;

    for (final e in ledgerEntries) {
      if (e.entryType == 'credit') {
        allTime += e.amount;
        if (e.recordedAt.isAfter(todayStart)) today += e.amount;
        if (e.recordedAt.isAfter(weekStart)) week += e.amount;
        if (e.recordedAt.isAfter(monthStart)) month += e.amount;

        if (e.paymentMode == 'cash_received' || e.paymentMode == 'digital_paid') {
          received += e.amount;
        }
      }
    }

    // Transactions map for category, weight, recycler
    final txRows = await (_db.select(_db.localTransactions)
          ..where((t) => t.collectorId.equals(collectorId)))
        .get();
    final txMap = {for (var t in txRows) t.lotId: t};

    // Recyclers map for recycler details
    final recyclers = await _db.select(_db.cachedRecyclers).get();
    final recyclerMap = {for (var r in recyclers) r.id: r};

    // Calculate pending dues from unpaid transactions
    int pendingCount = 0;
    double pendingAmount = 0.0;

    for (final tx in txRows) {
      if (tx.paymentStatus == 'pending') {
        pendingCount++;
        pendingAmount += (tx.finalPrice ?? tx.quotedPrice);
      }
    }

    final List<LedgerItemDetail> items = [];
    for (final e in ledgerEntries) {
      final tx = e.lotId != null ? txMap[e.lotId!] : null;
      final rec = (tx != null && tx.recyclerId != null) ? recyclerMap[tx.recyclerId!] : null;

      final cat = tx?.category ?? 'E-Waste';
      final weight = tx?.weightKg ?? 0.0;
      final status = (tx != null && tx.anomalyFlag) ? 'disputed' : e.paymentMode;
      final rName = rec?.name ?? 'EcoRecycle Solutions';
      final rPhone = rec?.phone ?? '+91 98200 12345';

      items.add(
        LedgerItemDetail(
          entryId: e.id,
          lotId: e.lotId,
          category: cat,
          weightKg: weight,
          amount: e.amount,
          paymentStatus: status,
          recyclerName: rName,
          recordedAt: e.recordedAt,
          recyclerPhone: rPhone,
        ),
      );
    }

    return EarningsOverviewData(
      todayTotal: today,
      weekTotal: week,
      monthTotal: month,
      allTimeTotal: allTime,
      receivedAmount: received,
      pendingAmount: pendingAmount,
      pendingDuesCount: pendingCount,
      transactions: items,
    );
  }

  /// Mark cash received offline: updates LocalLedger, LocalTransactions, and enqueues to SyncQueueEntries
  Future<void> markCashReceivedOffline({
    required String entryId,
    required String collectorId,
    String? lotId,
  }) async {
    final now = DateTime.now();

    // 1. Update LocalLedger
    await (_db.update(_db.localLedger)..where((l) => l.id.equals(entryId))).write(
      const LocalLedgerCompanion(
        paymentMode: Value('cash_received'),
        isSynced: Value(false),
      ),
    );

    // 2. Update LocalTransactions if linked
    if (lotId != null && lotId.isNotEmpty) {
      await (_db.update(_db.localTransactions)..where((t) => t.lotId.equals(lotId))).write(
        const LocalTransactionsCompanion(
          paymentStatus: Value('cash_received'),
          isSynced: Value(false),
        ),
      );
    }

    // 3. Enqueue to SyncQueueEntries for background sync
    await _db.into(_db.syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        clientTxId: _uuid.v4(),
        collectorId: collectorId,
        action: 'record_cash_payment',
        payloadJson: jsonEncode({
          'entry_id': entryId,
          'lot_id': lotId,
          'payment_mode': 'cash_received',
          'marked_at': now.toIso8601String(),
        }),
        clientTimestamp: now,
        createdAt: now,
        status: const Value('pending'),
      ),
    );
  }
}

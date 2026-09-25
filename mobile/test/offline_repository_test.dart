import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_mobile/data/local_database.dart';
import 'package:kabadiwala_mobile/data/repositories/ledger_repository.dart';
import 'package:kabadiwala_mobile/data/repositories/lot_repository.dart';
import 'package:kabadiwala_mobile/data/repositories/price_repository.dart';

void main() {
  group('Drift Offline Repositories & Sync Queue Tests', () {
    late AppDatabase db;
    late LotRepository lotRepo;
    late PriceRepository priceRepo;
    late LedgerRepository ledgerRepo;

    setUp(() {
      db = AppDatabase.inMemory();
      lotRepo = LotRepository(db);
      priceRepo = PriceRepository(db);
      ledgerRepo = LedgerRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Lot creation works offline, creates human ID and queues sync entry', () async {
      final lot = await lotRepo.createLotOffline(
        collectorId: 'KC-C-1001',
        category: 'PCB High-Grade',
        weightKg: 12.5,
        quotedPrice: 5250.0,
        latitude: 19.6967,
        longitude: 72.7699,
        photoHash: 'sha256-mock-hash-1234',
      );

      // Verify human friendly lot ID format
      expect(lot.lotId, startsWith('KC-MH-'));
      expect(lot.collectorId, equals('KC-C-1001'));
      expect(lot.weightKg, equals(12.5));
      expect(lot.isSynced, isFalse);

      // Verify Sync Queue entry was queued
      final unsyncedCount = await lotRepo.getUnsyncedLotCount();
      expect(unsyncedCount, equals(1));

      final queueEntries = await db.select(db.syncQueueEntries).get();
      expect(queueEntries.length, equals(1));
      expect(queueEntries.first.action, equals('create_lot'));
      expect(queueEntries.first.status, equals('pending'));
    });

    test('Price repository seeds initial benchmark prices for offline operation', () async {
      await priceRepo.seedInitialPricesIfEmpty();

      final prices = await db.select(db.cachedPrices).get();
      expect(prices.isNotEmpty, isTrue);
      expect(prices.any((p) => p.category.contains('Copper')), isTrue);
      expect(prices.any((p) => p.category.contains('PCB')), isTrue);
    });

    test('Ledger repository records cash received and tracks balance', () async {
      await ledgerRepo.recordCashPayment(
        collectorId: 'KC-C-1001',
        amount: 2500.0,
        description: 'रोख रक्कम प्राप्त (PCB Lot)',
      );

      final summary = await ledgerRepo.getEarningsSummary('KC-C-1001');
      expect(summary.totalReceived, equals(2500.0));

      final entries = await db.select(db.localLedger).get();
      expect(entries.length, equals(1));
      expect(entries.first.paymentMode, equals('cash_received'));
      expect(entries.first.balanceAfter, equals(2500.0));
    });
  });
}

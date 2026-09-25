import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../data/local_database.dart';

/// Singleton service managing in-app Demo Mode and offline simulation for judges.
class DemoModeService extends ChangeNotifier {
  static final DemoModeService instance = DemoModeService._internal();

  DemoModeService._internal();

  bool _isDemoMode = false;
  bool _isSimulatedOffline = false;

  bool get isDemoMode => _isDemoMode;
  bool get isSimulatedOffline => _isSimulatedOffline;

  void toggleDemoMode([AppDatabase? db]) {
    _isDemoMode = !_isDemoMode;
    if (_isDemoMode && db != null) {
      seedDemoDriftData(db);
    }
    notifyListeners();
  }

  void setDemoMode(bool value, [AppDatabase? db]) {
    if (_isDemoMode != value) {
      _isDemoMode = value;
      if (_isDemoMode && db != null) {
        seedDemoDriftData(db);
      }
      notifyListeners();
    }
  }

  void toggleSimulatedOffline() {
    _isSimulatedOffline = !_isSimulatedOffline;
    notifyListeners();
  }

  void setSimulatedOffline(bool value) {
    if (_isSimulatedOffline != value) {
      _isSimulatedOffline = value;
      notifyListeners();
    }
  }

  /// Populate Drift SQLite database with rich demo data for collectors and judges
  Future<void> seedDemoDriftData(AppDatabase db) async {
    final now = DateTime.now();

    // 1. Seed Recyclers
    final sampleRecyclers = [
      CachedRecyclersCompanion(
        id: const Value('REC-SYNTH-001'),
        name: const Value('Maharashtra Green E-Solutions (Synthetic)'),
        latitude: const Value(19.0760),
        longitude: const Value(72.8777),
        materialsAcceptedJson: const Value('["CRT", "LCD panel", "PCB (low grade)", "PCB (mid grade)", "PCB (high grade)", "cables", "batteries"]'),
        authorizationNumber: const Value('CPCB/SYNTH/EPR/2026/001'),
        authorizationBody: const Value('CPCB'),
        authorizationStatus: const Value('verified'),
        authorizationValidTill: Value(DateTime(2028, 12, 31)),
        phone: const Value('+91-98200-11111'),
        offeredRatesJson: const Value('{"CRT":14.5,"LCD panel":48.0,"PCB (low grade)":52.0,"PCB (mid grade)":210.0,"PCB (high grade)":620.0,"cables":310.0,"batteries":95.0}'),
        pickupAvailable: const Value(true),
        pickupRadiusKm: const Value(35.0),
        serviceAreaJson: const Value('{"districts":["Mumbai","Thane"]}'),
        rating: const Value(4.8),
        cachedAt: Value(now),
      ),
      CachedRecyclersCompanion(
        id: const Value('REC-SYNTH-003'),
        name: const Value('Thane Industrial E-Waste Aggregators (Synthetic)'),
        latitude: const Value(19.2183),
        longitude: const Value(72.9781),
        materialsAcceptedJson: const Value('["CRT", "PCB (mid grade)", "cables", "batteries"]'),
        authorizationNumber: const Value('MPCB/SYNTH/EPR/2026/003'),
        authorizationBody: const Value('SPCB'),
        authorizationStatus: const Value('verified'),
        authorizationValidTill: Value(DateTime(2028, 12, 31)),
        phone: const Value('+91-98200-33333'),
        offeredRatesJson: const Value('{"CRT":13.5,"PCB (mid grade)":205.0,"cables":305.0,"batteries":92.0}'),
        pickupAvailable: const Value(true),
        pickupRadiusKm: const Value(25.0),
        serviceAreaJson: const Value('{"districts":["Thane"]}'),
        rating: const Value(4.7),
        cachedAt: Value(now),
      ),
      CachedRecyclersCompanion(
        id: const Value('REC-SYNTH-005'),
        name: const Value('Pune Circular Resources Pvt Ltd (Synthetic)'),
        latitude: const Value(18.5204),
        longitude: const Value(73.8567),
        materialsAcceptedJson: const Value('["CRT", "LCD panel", "PCB (high grade)", "batteries", "cables"]'),
        authorizationNumber: const Value('CPCB/SYNTH/EPR/2026/005'),
        authorizationBody: const Value('CPCB'),
        authorizationStatus: const Value('verified'),
        authorizationValidTill: Value(DateTime(2028, 12, 31)),
        phone: const Value('+91-98200-55555'),
        offeredRatesJson: const Value('{"CRT":14.0,"LCD panel":47.0,"PCB (high grade)":615.0,"cables":308.0,"batteries":94.0}'),
        pickupAvailable: const Value(true),
        pickupRadiusKm: const Value(30.0),
        serviceAreaJson: const Value('{"districts":["Pune"]}'),
        rating: const Value(4.9),
        cachedAt: Value(now),
      ),
    ];

    for (final r in sampleRecyclers) {
      await db.into(db.cachedRecyclers).insertOnConflictUpdate(r);
    }

    // 2. Seed Price Benchmarks
    final prices = [
      CachedPricesCompanion(
        id: const Value('PRC-PCB-01'),
        category: const Value('PCB (mid grade)'),
        district: const Value('Thane'),
        latitude: const Value(19.2183),
        longitude: const Value(72.9781),
        recordedAt: Value(now),
        buyingPrice: const Value(205.0),
        sellingQuotedPrice: const Value(225.0),
        marketMin: const Value(180.0),
        marketMax: const Value(240.0),
        createdAt: Value(now),
      ),
      CachedPricesCompanion(
        id: const Value('PRC-CABLE-01'),
        category: const Value('cables'),
        district: const Value('Thane'),
        latitude: const Value(19.2183),
        longitude: const Value(72.9781),
        recordedAt: Value(now),
        buyingPrice: const Value(305.0),
        sellingQuotedPrice: const Value(330.0),
        marketMin: const Value(280.0),
        marketMax: const Value(340.0),
        createdAt: Value(now),
      ),
      CachedPricesCompanion(
        id: const Value('PRC-BATT-01'),
        category: const Value('batteries'),
        district: const Value('Thane'),
        latitude: const Value(19.2183),
        longitude: const Value(72.9781),
        recordedAt: Value(now),
        buyingPrice: const Value(92.0),
        sellingQuotedPrice: const Value(105.0),
        marketMin: const Value(85.0),
        marketMax: const Value(110.0),
        createdAt: Value(now),
      ),
      CachedPricesCompanion(
        id: const Value('PRC-CRT-01'),
        category: const Value('CRT'),
        district: const Value('Thane'),
        latitude: const Value(19.2183),
        longitude: const Value(72.9781),
        recordedAt: Value(now),
        buyingPrice: const Value(13.5),
        sellingQuotedPrice: const Value(16.0),
        marketMin: const Value(10.0),
        marketMax: const Value(18.0),
        createdAt: Value(now),
      ),
    ];

    for (final p in prices) {
      await db.into(db.cachedPrices).insertOnConflictUpdate(p);
    }

    // 3. Seed Completed & Pending Transactions for Demo Collector KC-C-7821
    final demoTransactions = [
      LocalTransactionsCompanion(
        lotId: const Value('KC-MH-2609-00101'),
        clientLotUuid: const Value('uuid-lot-101'),
        collectorId: const Value('KC-C-7821'),
        category: const Value('PCB (mid grade)'),
        weightKg: const Value(14.5),
        quotedPrice: const Value(205.0),
        finalPrice: const Value(2972.5),
        recyclerId: const Value('REC-SYNTH-003'),
        collectionLat: const Value(19.2183),
        collectionLng: const Value(72.9781),
        createdAt: Value(now.subtract(const Duration(days: 18))),
        handoverAt: Value(now.subtract(const Duration(days: 18))),
        paymentStatus: const Value('cash_received'),
        transactionStatus: const Value('handed_over'),
        isSynced: const Value(true),
      ),
      LocalTransactionsCompanion(
        lotId: const Value('KC-MH-2609-00102'),
        clientLotUuid: const Value('uuid-lot-102'),
        collectorId: const Value('KC-C-7821'),
        category: const Value('cables'),
        weightKg: const Value(22.0),
        quotedPrice: const Value(305.0),
        finalPrice: const Value(6710.0),
        recyclerId: const Value('REC-SYNTH-003'),
        collectionLat: const Value(19.2183),
        collectionLng: const Value(72.9781),
        createdAt: Value(now.subtract(const Duration(days: 12))),
        handoverAt: Value(now.subtract(const Duration(days: 12))),
        paymentStatus: const Value('cash_received'),
        transactionStatus: const Value('handed_over'),
        isSynced: const Value(true),
      ),
      LocalTransactionsCompanion(
        lotId: const Value('KC-MH-2609-00103'),
        clientLotUuid: const Value('uuid-lot-103'),
        collectorId: const Value('KC-C-7821'),
        category: const Value('batteries'),
        weightKg: const Value(18.0),
        quotedPrice: const Value(92.0),
        finalPrice: const Value(1656.0),
        recyclerId: const Value('REC-SYNTH-003'),
        collectionLat: const Value(19.2183),
        collectionLng: const Value(72.9781),
        createdAt: Value(now.subtract(const Duration(days: 7))),
        handoverAt: Value(now.subtract(const Duration(days: 7))),
        paymentStatus: const Value('cash_received'),
        transactionStatus: const Value('handed_over'),
        isSynced: const Value(true),
      ),
      LocalTransactionsCompanion(
        lotId: const Value('KC-MH-2609-00105'),
        clientLotUuid: const Value('uuid-lot-105'),
        collectorId: const Value('KC-C-7821'),
        category: const Value('LCD panel'),
        weightKg: const Value(15.0),
        quotedPrice: const Value(46.0),
        finalPrice: const Value(690.0),
        recyclerId: const Value('REC-SYNTH-003'),
        collectionLat: const Value(19.2183),
        collectionLng: const Value(72.9781),
        createdAt: Value(now.subtract(const Duration(days: 1))),
        paymentStatus: const Value('pending'),
        transactionStatus: const Value('handover_pending'),
        isSynced: const Value(false),
      ),
    ];

    for (final tx in demoTransactions) {
      await db.into(db.localTransactions).insertOnConflictUpdate(tx);
    }

    // 4. Seed Ledger Entries
    final demoLedger = [
      LocalLedgerCompanion(
        id: const Value('LEDG-DEMO-001'),
        collectorId: const Value('KC-C-7821'),
        lotId: const Value('KC-MH-2609-00101'),
        entryType: const Value('credit'),
        amount: const Value(2972.5),
        paymentMode: const Value('cash_received'),
        description: const Value('PCB (mid grade) (14.5 kg @ ₹205/kg)'),
        balanceAfter: const Value(2972.5),
        recordedAt: Value(now.subtract(const Duration(days: 18))),
        isSynced: const Value(true),
      ),
      LocalLedgerCompanion(
        id: const Value('LEDG-DEMO-002'),
        collectorId: const Value('KC-C-7821'),
        lotId: const Value('KC-MH-2609-00102'),
        entryType: const Value('credit'),
        amount: const Value(6710.0),
        paymentMode: const Value('cash_received'),
        description: const Value('cables (22.0 kg @ ₹305/kg)'),
        balanceAfter: const Value(9682.5),
        recordedAt: Value(now.subtract(const Duration(days: 12))),
        isSynced: const Value(true),
      ),
      LocalLedgerCompanion(
        id: const Value('LEDG-DEMO-003'),
        collectorId: const Value('KC-C-7821'),
        lotId: const Value('KC-MH-2609-00103'),
        entryType: const Value('credit'),
        amount: const Value(1656.0),
        paymentMode: const Value('cash_received'),
        description: const Value('batteries (18.0 kg @ ₹92/kg)'),
        balanceAfter: const Value(11338.5),
        recordedAt: Value(now.subtract(const Duration(days: 7))),
        isSynced: const Value(true),
      ),
    ];

    for (final l in demoLedger) {
      await db.into(db.localLedger).insertOnConflictUpdate(l);
    }
  }
}

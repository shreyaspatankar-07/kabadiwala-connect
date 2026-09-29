import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_database.dart';
import '../repositories/ledger_repository.dart';
import '../repositories/lot_repository.dart';
import '../repositories/price_repository.dart';
import '../../main.dart';

/// Provider for LotRepository
final lotRepositoryProvider = Provider<LotRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LotRepository(db);
});

/// Provider for PriceRepository
final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PriceRepository(db);
});

/// Provider for LedgerRepository
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LedgerRepository(db);
});

/// StreamProvider listening reactively to all created lots for a collector from SQLite
final collectorLotsStreamProvider = StreamProvider.family<List<LocalTransaction>, String>((ref, collectorId) {
  final db = ref.watch(databaseProvider);
  return db.watchCollectorLots(collectorId);
});

/// StreamProvider listening reactively to all lots on the device from SQLite
final allLotsStreamProvider = StreamProvider<List<LocalTransaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllLots();
});

/// StreamProvider listening reactively to cached price boards from SQLite
final cachedPricesStreamProvider = StreamProvider<List<CachedPrice>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCachedPrices();
});

/// StreamProvider listening reactively to earnings overview from SQLite
final collectorEarningsStreamProvider = StreamProvider.family<EarningsOverviewData, String>((ref, collectorId) {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.watchDetailedOverview(collectorId);
});

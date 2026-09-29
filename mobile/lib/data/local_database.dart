import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'local_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kabadiwala.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  LocalMaterials,
  CachedPrices,
  CachedRecyclers,
  LocalTransactions,
  LocalTraceability,
  CollectorProfile,
  LocalLedger,
  CachedSafetyContent,
  SyncQueueEntries,
  LocalMLSamples,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future schema migrations for mobile local db
    },
  );

  /// Stream all local lots/transactions for a collector ordered by newest first
  Stream<List<LocalTransaction>> watchCollectorLots(String collectorId) {
    return (select(localTransactions)
          ..where((t) => t.collectorId.equals(collectorId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Stream all local lots across the device
  Stream<List<LocalTransaction>> watchAllLots() {
    return (select(localTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Stream all cached prices ordered by recorded time
  Stream<List<CachedPrice>> watchCachedPrices() {
    return (select(cachedPrices)
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  /// Stream local ledger entries for a collector
  Stream<List<LocalLedgerData>> watchLocalLedger(String collectorId) {
    return (select(localLedger)
          ..where((l) => l.collectorId.equals(collectorId))
          ..orderBy([(l) => OrderingTerm.desc(l.recordedAt)]))
        .watch();
  }
}

import 'package:drift/drift.dart';
import 'tables.dart';

part 'local_database.g.dart';

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
  AppDatabase(super.e);

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
}

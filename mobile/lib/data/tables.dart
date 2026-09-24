import 'package:drift/drift.dart';

// -----------------------------------------------------------------------------
// Offline Drift SQLite Tables for Kabadiwala Connect (Matching Server Schema)
// -----------------------------------------------------------------------------

/// 1. Materials Catalog (Offline cached reference)
class LocalMaterials extends Table {
  TextColumn get id => text()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  TextColumn get subCategory => text().withLength(min: 1, max: 50)();
  TextColumn get description => text()();
  TextColumn get imageRef => text().nullable()();
  RealColumn get approxWeightKg => real()();
  TextColumn get condition => text()(); // working | broken | damaged | burnt
  TextColumn get sourceType => text()(); // household | office | shop | repair_unit | other
  RealColumn get estimatedValue => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 2. Prices Board (Offline cached regional benchmark rates)
class CachedPrices extends Table {
  TextColumn get id => text()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  TextColumn get subCategory => text().nullable()();
  TextColumn get district => text().withLength(min: 1, max: 100)();
  TextColumn get city => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get buyingPrice => real()();
  RealColumn get sellingQuotedPrice => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))(); // kg | piece
  RealColumn get marketMin => real()();
  RealColumn get marketMax => real()();
  TextColumn get recyclerId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('synthetic'))(); // recycler_quote | field_survey | synthetic
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 3. Recyclers Directory (Offline cached nearby authorized recyclers)
class CachedRecyclers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get materialsAcceptedJson => text()(); // JSON array of category strings
  TextColumn get authorizationNumber => text().unique()();
  TextColumn get authorizationBody => text()(); // CPCB | SPCB | OTHER
  TextColumn get authorizationStatus => text()(); // verified | pending | expired | suspended
  DateTimeColumn get authorizationValidTill => dateTime()();
  TextColumn get phone => text()();
  TextColumn get offeredRatesJson => text()(); // JSON map of category to rate
  BoolColumn get pickupAvailable => boolean().withDefault(const Constant(false))();
  RealColumn get pickupRadiusKm => real().withDefault(const Constant(0.0))();
  TextColumn get serviceAreaJson => text()(); // District list or geo polygon JSON
  RealColumn get rating => real().withDefault(const Constant(0.0))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 4. Transactions / E-Waste Lots (Offline-first created and synced lots)
class LocalTransactions extends Table {
  TextColumn get lotId => text().withLength(min: 5, max: 40)(); // Human-friendly e.g. KC-MH-2609-00123
  TextColumn get clientLotUuid => text()(); // Local client UUID for deduplication
  TextColumn get collectorId => text()();
  TextColumn get category => text()();
  RealColumn get weightKg => real()();
  RealColumn get quotedPrice => real()();
  RealColumn get finalPrice => real().nullable()();
  TextColumn get recyclerId => text().nullable()();
  RealColumn get collectionLat => real()();
  RealColumn get collectionLng => real()();
  RealColumn get handoverLat => real().nullable()();
  RealColumn get handoverLng => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get handoverAt => dateTime().nullable()();
  TextColumn get paymentStatus => text().withDefault(const Constant('pending'))(); // cash_received | pending | digital_paid
  TextColumn get transactionStatus => text().withDefault(const Constant('draft'))(); // draft | listed | matched | handover_pending | handed_over | confirmed | disputed | cancelled
  BoolColumn get anomalyFlag => boolean().withDefault(const Constant(false))();
  TextColumn get anomalyReason => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {lotId};
}

/// 5. Traceability & Dual Handover Audit Records (Append-only & hash-chained)
class LocalTraceability extends Table {
  TextColumn get id => text()();
  TextColumn get lotId => text()();
  TextColumn get photoHashesJson => text()(); // JSON array of SHA-256 photo hashes
  RealColumn get weightKg => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get gpsLat => real()();
  RealColumn get gpsLng => real()();
  TextColumn get handoverRefNo => text().unique()();
  TextColumn get qrPayload => text()();
  BoolColumn get recyclerConfirmation => boolean().withDefault(const Constant(false))();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  TextColumn get confirmedBy => text().nullable()();
  TextColumn get downstreamStatus => text().withDefault(const Constant('received'))(); // received | dismantled | processed | certificate_issued
  TextColumn get recordHash => text()(); // SHA-256 of this record
  TextColumn get prevHash => text()(); // Previous block/handover record SHA-256
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 6. Collector Local Profile (Data-minimization: no Aadhaar / real name)
class CollectorProfile extends Table {
  TextColumn get collectorId => text()(); // e.g. KC-C-7821
  TextColumn get preferredLanguage => text().withDefault(const Constant('mr'))(); // mr | hi | en
  TextColumn get operatingArea => text()(); // District name only
  TextColumn get quickPinHash => text().nullable()(); // Offline unlock PIN hash
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {collectorId};
}

/// 7. Cash & Credit Ledger Entries (Collector's personal transaction history)
class LocalLedger extends Table {
  TextColumn get id => text()();
  TextColumn get collectorId => text()();
  TextColumn get lotId => text().nullable()();
  TextColumn get entryType => text()(); // credit | debit
  RealColumn get amount => real()();
  TextColumn get paymentMode => text().withDefault(const Constant('cash_received'))(); // cash_received | pending | digital_paid
  TextColumn get description => text()();
  RealColumn get balanceAfter => real()();
  DateTimeColumn get recordedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 8. Safety Content Cards (Vernacular dismantling & hazard instructions)
class CachedSafetyContent extends Table {
  TextColumn get id => text()(); // e.g. SAFE-BATT-01
  TextColumn get category => text()();
  TextColumn get hazardLevel => text().withDefault(const Constant('info'))(); // info | warning | danger
  TextColumn get pictogramAssetPath => text()();
  TextColumn get audioAssetPath => text()();
  TextColumn get titleVernacular => text()();
  TextColumn get instructionsVernacular => text()();
  TextColumn get dosJson => text()();
  TextColumn get dontsJson => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 9. Sync Queue (Local FIFO queue for outbound offline transactions)
class SyncQueueEntries extends Table {
  TextColumn get clientTxId => text()(); // Unique client transaction UUID
  TextColumn get collectorId => text()();
  TextColumn get action => text()(); // create_lot | record_handover | record_cash_payment
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | processing | completed | failed
  IntColumn get retryAttempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get clientTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientTxId};
}

/// 10. ML Training & Image Labeling Cache (Offline-gathered training samples)
class LocalMLSamples extends Table {
  TextColumn get id => text()();
  TextColumn get localImagePath => text()();
  TextColumn get label => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get price => real().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('field'))(); // synthetic | field | scraped_public
  RealColumn get qualityScore => real().withDefault(const Constant(1.0))();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

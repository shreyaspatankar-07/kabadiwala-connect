import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../local_database.dart';
import '../repositories/price_repository.dart';

enum SyncStatus { offline, onlineIdle, syncing, error }

class SyncEngineState {
  const SyncEngineState({
    required this.status,
    required this.pendingQueueCount,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncStatus status;
  final int pendingQueueCount;
  final DateTime? lastSyncedAt;
  final String? lastError;

  bool get isOnline => status != SyncStatus.offline;
  bool get isSyncing => status == SyncStatus.syncing;
}

/// Offline-first Sync Engine following /docs/OFFLINE_STRATEGY.md.
/// Listens to network connectivity changes, maintains exponential backoff,
/// and synchronizes outbound queue and inbound cached data.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    http.Client? httpClient,
    Connectivity? connectivity,
    String? serverBaseUrl,
  })  : _db = db,
        _http = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity(),
        serverBaseUrl = serverBaseUrl ?? AppConfig.apiBaseUrl {
    _initConnectivityListener();
  }

  final AppDatabase _db;
  final http.Client _http;
  final Connectivity _connectivity;
  final String serverBaseUrl;

  List<String> get _candidateUrls {
    final list = <String>[serverBaseUrl];
    for (final url in AppConfig.candidateUrls) {
      if (!list.contains(url)) {
        list.add(url);
      }
    }
    return list;
  }

  final _stateController = StreamController<SyncEngineState>.broadcast();
  Stream<SyncEngineState> get stateStream => _stateController.stream;

  SyncEngineState _currentState = const SyncEngineState(
    status: SyncStatus.onlineIdle,
    pendingQueueCount: 0,
  );
  SyncEngineState get currentState => _currentState;

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  Timer? _backoffTimer;
  int _consecutiveFailures = 0;
  bool _isDisposed = false;

  Future<bool> _checkNetworkAvailable() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        return true;
      }
    } catch (_) {}
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _initConnectivityListener() {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    } catch (_) {}
    _checkInitialConnectivity();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityResult(result);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final hasNet = await _checkNetworkAvailable();
    if (!hasNet) {
      _updateState(SyncStatus.offline);
    } else {
      _updateState(SyncStatus.onlineIdle);
      unawaited(triggerSync());
    }
  }

  void _handleConnectivityResult(ConnectivityResult result) async {
    final isConnected = result != ConnectivityResult.none || await _checkNetworkAvailable();
    if (!isConnected) {
      _updateState(SyncStatus.offline);
    } else {
      _updateState(SyncStatus.onlineIdle);
      triggerSync();
    }
  }

  void _updateState(
    SyncStatus status, {
    String? error,
    DateTime? lastSyncedAt,
  }) async {
    final pendingCount = await getPendingCount();
    _currentState = SyncEngineState(
      status: status,
      pendingQueueCount: pendingCount,
      lastSyncedAt: lastSyncedAt ?? _currentState.lastSyncedAt,
      lastError: error,
    );
    if (!_isDisposed) {
      _stateController.add(_currentState);
    }
  }

  Future<int> getPendingCount() async {
    final count = countAll();
    final query = _db.selectOnly(_db.syncQueueEntries)
      ..addColumns([count])
      ..where(_db.syncQueueEntries.status.equals('pending'));
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }

  /// Trigger sync with exponential backoff on failure
  Future<void> triggerSync() async {
    if (_currentState.status == SyncStatus.syncing) return;

    final hasNet = await _checkNetworkAvailable();
    if (!hasNet) {
      _updateState(SyncStatus.offline);
      return;
    }

    _updateState(SyncStatus.syncing);

    try {
      // 1. Push pending local operations
      await _pushPendingQueue();

      // 2. Pull server updates (rates, safety)
      await _pullServerUpdates();

      _consecutiveFailures = 0;
      _updateState(SyncStatus.onlineIdle, lastSyncedAt: DateTime.now());
    } catch (e) {
      _consecutiveFailures++;
      final errorMsg = e.toString();
      _updateState(SyncStatus.error, error: errorMsg);
      _scheduleBackoffRetry();
    }
  }

  Future<void> _pushPendingQueue() async {
    final pendingEntries = await (_db.select(_db.syncQueueEntries)
          ..where((e) => e.status.equals('pending'))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)])
          ..limit(50))
        .get();

    if (pendingEntries.isEmpty) return;

    final operations = pendingEntries.map((e) {
      return {
        'client_tx_id': e.clientTxId,
        'action': e.action,
        'payload': jsonDecode(e.payloadJson),
        'client_timestamp': e.clientTimestamp.toIso8601String(),
      };
    }).toList();

    bool pushSucceeded = false;
    Exception? lastException;

    for (final base in _candidateUrls) {
      try {
        final response = await _http
            .post(
              Uri.parse('$base/sync/push'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'operations': operations}),
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint(
              '[SyncEngine] Push succeeded: ${pendingEntries.length} ops sent to $base/sync/push');
          // Mark all pushed entries completed
          for (final entry in pendingEntries) {
            await (_db.update(_db.syncQueueEntries)
                  ..where((e) => e.clientTxId.equals(entry.clientTxId)))
                .write(const SyncQueueEntriesCompanion(
              status: Value('completed'),
            ));

            // FIX: localTransactions is keyed by clientLotUuid, not clientTxId.
            // These are the same UUID value for create_lot operations, but we must
            // match on the correct column or the update silently touches 0 rows.
            await (_db.update(_db.localTransactions)
                  ..where((t) => t.clientLotUuid.equals(entry.clientTxId)))
                .write(LocalTransactionsCompanion(
              isSynced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ));
            debugPrint('[SyncEngine] Marked synced: clientLotUuid=${entry.clientTxId}');
          }
          pushSucceeded = true;
          break;
        } else {
          debugPrint('[SyncEngine] Push non-200 from $base: status=${response.statusCode}');
        }
      } catch (e) {
        debugPrint('[SyncEngine] Push failed on $base: $e');
        lastException = e is Exception ? e : Exception(e.toString());
      }
    }

    if (!pushSucceeded && lastException != null) {
      throw lastException;
    }
  }

  Future<void> _pullServerUpdates() async {
    for (final base in _candidateUrls) {
      try {
        final response = await _http
            .get(
              Uri.parse('$base/sync/pull?since=2026-01-01T00:00:00Z'),
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final prices = data['prices'] as List<dynamic>? ?? [];

          for (final p in prices) {
            final id = p['id'].toString();
            final rawCat = p['category'] as String;
            final category = PriceRepository.normalizeCategory(rawCat);
            final buyingPrice = (p['buying_price'] as num).toDouble();
            final district = p['district'] as String? ?? 'Palghar';
            final recordedAt = DateTime.tryParse(p['recorded_at'] ?? '') ?? DateTime.now();
            final sellingQuoted = (p['selling_quoted_price'] as num? ?? buyingPrice).toDouble();
            final marketMin = (p['market_min'] as num? ?? buyingPrice * 0.9).toDouble();
            final marketMax = (p['market_max'] as num? ?? buyingPrice * 1.1).toDouble();

            final cacheKey = 'PRICE-${district.toUpperCase()}-$category';
            await _db.into(_db.cachedPrices).insertOnConflictUpdate(
                  CachedPricesCompanion.insert(
                    id: cacheKey,
                    category: category,
                    subCategory: Value(p['sub_category'] as String?),
                    district: district,
                    latitude: 19.6967,
                    longitude: 72.7699,
                    recordedAt: recordedAt,
                    buyingPrice: buyingPrice,
                    sellingQuotedPrice: sellingQuoted,
                    marketMin: marketMin,
                    marketMax: marketMax,
                    createdAt: DateTime.now(),
                  ),
                );

            if (id != cacheKey) {
              await _db.into(_db.cachedPrices).insertOnConflictUpdate(
                    CachedPricesCompanion.insert(
                      id: id,
                      category: category,
                      subCategory: Value(p['sub_category'] as String?),
                      district: district,
                      latitude: 19.6967,
                      longitude: 72.7699,
                      recordedAt: recordedAt,
                      buyingPrice: buyingPrice,
                      sellingQuotedPrice: sellingQuoted,
                      marketMin: marketMin,
                      marketMax: marketMax,
                      createdAt: DateTime.now(),
                    ),
                  );
            }
          }
          break; // Pull succeeded on this URL
        }
      } catch (e) {
        debugPrint('[SyncEngine] Pull failed on $base (using offline cache): $e');
      }
    }
  }

  void _scheduleBackoffRetry() {
    _backoffTimer?.cancel();
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    } catch (_) {}
    if (_currentState.status == SyncStatus.offline) return;

    // Exponential backoff: min(60s, 2^(attempts-1)) with small jitter
    final delaySeconds = min(60, pow(2, min(_consecutiveFailures, 6)).toInt());
    final jitter = Random().nextInt(3);
    final duration = Duration(seconds: delaySeconds + jitter);

    debugPrint(
        '[SyncEngine] Backoff retry scheduled in ${duration.inSeconds}s (attempt $_consecutiveFailures)');
    _backoffTimer = Timer(duration, () {
      triggerSync();
    });
  }

  void dispose() {
    _isDisposed = true;
    _connectivitySub?.cancel();
    _backoffTimer?.cancel();
    _stateController.close();
  }
}

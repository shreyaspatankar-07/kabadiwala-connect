import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../local_database.dart';

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
    this.serverBaseUrl = 'http://10.0.2.2:8000', // default Android emulator host to FastAPI backend
  })  : _db = db,
        _http = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity() {
    _initConnectivityListener();
  }

  final AppDatabase _db;
  final http.Client _http;
  final Connectivity _connectivity;
  final String serverBaseUrl;

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

  void _initConnectivityListener() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      final isConnected = result != ConnectivityResult.none;
      if (!isConnected) {
        _updateState(SyncStatus.offline);
      } else {
        _updateState(SyncStatus.onlineIdle);
        triggerSync();
      }
    });
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

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
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

    try {
      final response = await _http.post(
        Uri.parse('$serverBaseUrl/sync/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'operations': operations}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark all pushed entries completed
        for (final entry in pendingEntries) {
          await (_db.update(_db.syncQueueEntries)
                ..where((e) => e.clientTxId.equals(entry.clientTxId)))
              .write(const SyncQueueEntriesCompanion(
                status: Value('completed'),
              ));

          // Also mark matching transaction as synced
          await (_db.update(_db.localTransactions)
                ..where((t) => t.clientLotUuid.equals(entry.clientTxId)))
              .write(LocalTransactionsCompanion(
                isSynced: const Value(true),
                syncedAt: Value(DateTime.now()),
              ));
        }
      } else {
        throw HttpException('Push failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[SyncEngine] Push error: $e');
      rethrow;
    }
  }

  Future<void> _pullServerUpdates() async {
    try {
      final response = await _http.get(
        Uri.parse('$serverBaseUrl/sync/pull?since=2026-01-01T00:00:00Z'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] as List<dynamic>? ?? [];

        for (final p in prices) {
          final id = p['id'].toString();
          final category = p['category'] as String;
          final buyingPrice = (p['buying_price'] as num).toDouble();
          final district = p['district'] as String? ?? 'Palghar';

          await _db.into(_db.cachedPrices).insertOnConflictUpdate(
            CachedPricesCompanion.insert(
              id: id,
              category: category,
              subCategory: Value(p['sub_category'] as String?),
              district: district,
              latitude: 19.6967,
              longitude: 72.7699,
              recordedAt: DateTime.tryParse(p['recorded_at'] ?? '') ?? DateTime.now(),
              buyingPrice: buyingPrice,
              sellingQuotedPrice: buyingPrice,
              marketMin: (p['market_min'] as num? ?? buyingPrice * 0.9).toDouble(),
              marketMax: (p['market_max'] as num? ?? buyingPrice * 1.1).toDouble(),
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      // Pull failure shouldn't throw if push succeeded
      debugPrint('[SyncEngine] Pull failed (using offline cache): $e');
    }
  }

  void _scheduleBackoffRetry() {
    _backoffTimer?.cancel();
    if (_currentState.status == SyncStatus.offline) return;

    // Exponential backoff: min(60s, 2^(attempts-1)) with small jitter
    final delaySeconds = min(60, pow(2, min(_consecutiveFailures, 6)).toInt());
    final jitter = Random().nextInt(3);
    final duration = Duration(seconds: delaySeconds + jitter);

    debugPrint('[SyncEngine] Backoff retry scheduled in ${duration.inSeconds}s (attempt $_consecutiveFailures)');
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

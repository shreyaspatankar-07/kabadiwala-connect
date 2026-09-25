import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../data/local_database.dart';

class HandoverInitiateResult {
  const HandoverInitiateResult({
    required this.lotId,
    required this.handoverRefNo,
    required this.qrPayload,
    required this.signature,
    required this.timestamp,
    required this.weightKg,
  });

  final String lotId;
  final String handoverRefNo;
  final String qrPayload;
  final String signature;
  final DateTime timestamp;
  final double weightKg;
}

class HandoverConfirmResult {
  const HandoverConfirmResult({
    required this.lotId,
    required this.handoverRefNo,
    required this.transactionStatus,
    required this.isDisputed,
    required this.measuredWeightKg,
    required this.originalWeightKg,
    required this.finalPrice,
    required this.recordHash,
    this.disputeReason,
  });

  final String lotId;
  final String handoverRefNo;
  final String transactionStatus;
  final bool isDisputed;
  final double measuredWeightKg;
  final double originalWeightKg;
  final double finalPrice;
  final String recordHash;
  final String? disputeReason;
}

class OfflineHandoverService {
  OfflineHandoverService(this._db, {this.secretKey = defaultDevSecretKey});

  final AppDatabase _db;
  final String secretKey;
  final Uuid _uuid = const Uuid();

  static const String defaultDevSecretKey = 'dev_secret_key_change_in_production_e9f2a8c14b';
  static const String _refCharset = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const double defaultTolerancePercent = 10.0;

  /// Generates a unique 6-character uppercase reference code omitting ambiguous symbols.
  static String generateShortCode([Random? rng]) {
    final r = rng ?? Random();
    return List.generate(6, (_) => _refCharset[r.nextInt(_refCharset.length)]).join();
  }

  /// Deterministic HMAC-SHA256 signature over sorted JSON payload.
  static String signPayload(Map<String, dynamic> payload, String key) {
    final clean = Map<String, dynamic>.from(payload)..remove('signature');
    final sortedKeys = clean.keys.toList()..sort();
    final sortedMap = {for (var k in sortedKeys) k: clean[k]};
    final serialized = jsonEncode(sortedMap);

    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final digest = hmacSha256.convert(utf8.encode(serialized));
    return digest.toString();
  }

  /// Verifies HMAC signature on raw QR JSON payload.
  static bool verifyPayloadSignature(String qrPayloadJson, {String key = defaultDevSecretKey}) {
    try {
      final parsed = jsonDecode(qrPayloadJson) as Map<String, dynamic>;
      final signature = parsed['signature'] as String?;
      if (signature == null || signature.isEmpty) return false;

      final expected = signPayload(parsed, key);
      return expected.toLowerCase() == signature.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  /// Initiates handover offline: generates unique short code, creates HMAC-signed QR, and updates Drift.
  Future<HandoverInitiateResult> initiateHandover({
    required String lotId,
    required double weightKg,
    required List<String> photoHashes,
    required double gpsLat,
    required double gpsLng,
    String collectorId = 'KC-C-7821',
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now().toUtc();
    final refNo = generateShortCode();
    final collectorHash = sha256.convert(utf8.encode(collectorId)).toString().substring(0, 16);

    final payloadMap = {
      'collector_id_hash': collectorHash,
      'gps_lat': (gpsLat * 1000000).round() / 1000000,
      'gps_lng': (gpsLng * 1000000).round() / 1000000,
      'handover_ref_no': refNo,
      'lot_id': lotId,
      'photo_hashes': photoHashes,
      'timestamp': now.toIso8601String(),
      'weight_kg': (weightKg * 100).round() / 100,
    };

    final signature = signPayload(payloadMap, secretKey);
    payloadMap['signature'] = signature;
    final qrPayloadStr = jsonEncode(payloadMap);

    // Initial record hash
    final prevHash = '0' * 64;
    final recordHash = sha256.convert(utf8.encode('$qrPayloadStr:$prevHash')).toString();

    // 1. Insert into LocalTraceability
    await _db.into(_db.localTraceability).insert(
          LocalTraceabilityCompanion.insert(
            id: _uuid.v4(),
            lotId: lotId,
            photoHashesJson: jsonEncode(photoHashes),
            weightKg: weightKg,
            timestamp: now,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            handoverRefNo: refNo,
            qrPayload: qrPayloadStr,
            recyclerConfirmation: const Value(false),
            downstreamStatus: const Value('received'),
            recordHash: recordHash,
            prevHash: prevHash,
            isSynced: const Value(false),
            createdAt: now,
          ),
        );

    // 2. Update LocalTransactions status to 'handover_pending'
    await (_db.update(_db.localTransactions)..where((t) => t.lotId.equals(lotId))).write(
      const LocalTransactionsCompanion(
        transactionStatus: Value('handover_pending'),
      ),
    );

    // 3. Enqueue to SyncQueueEntries
    await _db.into(_db.syncQueueEntries).insert(
          SyncQueueEntriesCompanion.insert(
            clientTxId: _uuid.v4(),
            collectorId: collectorId,
            action: 'record_handover',
            payloadJson: qrPayloadStr,
            clientTimestamp: now,
            createdAt: now,
            status: const Value('pending'),
          ),
        );

    return HandoverInitiateResult(
      lotId: lotId,
      handoverRefNo: refNo,
      qrPayload: qrPayloadStr,
      signature: signature,
      timestamp: now,
      weightKg: weightKg,
    );
  }

  /// Confirms handover offline by scanning QR or typing 6-char ref code.
  Future<HandoverConfirmResult> confirmHandover({
    required double measuredWeightKg,
    required double finalPrice,
    String? handoverRefNo,
    String? qrPayload,
    String recyclerId = 'REC-TEST-AUTH-01',
    double tolerancePercent = defaultTolerancePercent,
  }) async {
    String? targetRef = handoverRefNo;

    if (qrPayload != null && qrPayload.isNotEmpty) {
      if (!verifyPayloadSignature(qrPayload, key: secretKey)) {
        throw StateError('Invalid or tampered QR signature.');
      }
      final parsed = jsonDecode(qrPayload) as Map<String, dynamic>;
      targetRef = parsed['handover_ref_no'] as String?;
    }

    if (targetRef == null || targetRef.isEmpty) {
      throw ArgumentError('Either handoverRefNo or valid qrPayload must be supplied.');
    }

    // Look up LocalTraceability
    final query = _db.select(_db.localTraceability)..where((t) => t.handoverRefNo.equals(targetRef!));
    final traceRow = await query.getSingleOrNull();

    if (traceRow == null) {
      throw StateError('Handover record $targetRef not found in local database.');
    }

    if (traceRow.recyclerConfirmation) {
      throw StateError('Replay attack detected: handover $targetRef is already confirmed.');
    }

    final origWeight = traceRow.weightKg;
    final delta = (measuredWeightKg - origWeight).abs() / (origWeight > 0 ? origWeight : 1.0);
    final isDisputed = delta > (tolerancePercent / 100.0);
    final disputeReason = isDisputed
        ? 'Weight mismatch of ${(delta * 100).toStringAsFixed(1)}% exceeds tolerance of ${tolerancePercent.toStringAsFixed(0)}% (collector: ${origWeight.toStringAsFixed(1)} kg, recycler: ${measuredWeightKg.toStringAsFixed(1)} kg)'
        : null;

    final txStatus = isDisputed ? 'disputed' : 'handed_over';
    final now = DateTime.now().toUtc();

    // Hash chain
    final newRecordHash = sha256
        .convert(utf8.encode(
            '${traceRow.qrPayload}:${traceRow.prevHash}:$measuredWeightKg:$finalPrice:$recyclerId:${now.toIso8601String()}'))
        .toString();

    // Update LocalTraceability
    await (_db.update(_db.localTraceability)..where((t) => t.handoverRefNo.equals(targetRef!))).write(
      LocalTraceabilityCompanion(
        recyclerConfirmation: const Value(true),
        confirmedAt: Value(now),
        confirmedBy: Value(recyclerId),
        downstreamStatus: const Value('received'),
        recordHash: Value(newRecordHash),
        isSynced: const Value(false),
      ),
    );

    // Update LocalTransactions
    await (_db.update(_db.localTransactions)..where((t) => t.lotId.equals(traceRow.lotId))).write(
      LocalTransactionsCompanion(
        transactionStatus: Value(txStatus),
        finalPrice: Value(finalPrice),
        handoverAt: Value(now),
        recyclerId: Value(recyclerId),
        anomalyFlag: Value(isDisputed),
        anomalyReason: Value(disputeReason),
      ),
    );

    // Enqueue confirm sync
    await _db.into(_db.syncQueueEntries).insert(
          SyncQueueEntriesCompanion.insert(
            clientTxId: _uuid.v4(),
            collectorId: traceRow.lotId,
            action: 'record_handover',
            payloadJson: jsonEncode({
              'handover_ref_no': targetRef,
              'measured_weight_kg': measuredWeightKg,
              'final_price': finalPrice,
              'recycler_id': recyclerId,
              'confirmed_at': now.toIso8601String(),
              'transaction_status': txStatus,
              'is_disputed': isDisputed,
              'dispute_reason': disputeReason,
              'record_hash': newRecordHash,
            }),
            clientTimestamp: now,
            createdAt: now,
            status: const Value('pending'),
          ),
        );

    return HandoverConfirmResult(
      lotId: traceRow.lotId,
      handoverRefNo: targetRef,
      transactionStatus: txStatus,
      isDisputed: isDisputed,
      disputeReason: disputeReason,
      measuredWeightKg: measuredWeightKg,
      originalWeightKg: origWeight,
      finalPrice: finalPrice,
      recordHash: newRecordHash,
    );
  }
}

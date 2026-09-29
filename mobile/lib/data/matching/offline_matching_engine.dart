import 'dart:math' as math;

class OfflineLotInput {
  const OfflineLotInput({
    required this.category,
    required this.collectionLat,
    required this.collectionLng,
    this.weightKg = 1.0,
    this.district,
    this.lotId,
  });

  final String category;
  final double collectionLat;
  final double collectionLng;
  final double weightKg;
  final String? district;
  final String? lotId;
}

class RecyclerCandidateData {
  const RecyclerCandidateData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.materialsAccepted,
    required this.authorizationStatus,
    required this.authorizationValidTill,
    required this.phone,
    required this.offeredRates,
    this.authorizationNumber = 'REG-MINT-DEFAULT',
    this.pickupAvailable = false,
    this.pickupRadiusKm = 0.0,
    this.serviceArea = const {},
    this.rating = 0.0,
    this.completionRate,
    this.confirmationSpeedHours,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> materialsAccepted;
  final String authorizationNumber;
  final String authorizationStatus;
  final DateTime authorizationValidTill;
  final String phone;
  final Map<String, double> offeredRates;
  final bool pickupAvailable;
  final double pickupRadiusKm;
  final Map<String, dynamic> serviceArea;
  final double rating;
  final double? completionRate;
  final double? confirmationSpeedHours;

  factory RecyclerCandidateData.fromJson(Map<String, dynamic> json) {
    DateTime validTill;
    try {
      validTill = DateTime.parse(json['authorization_valid_till'] as String);
    } catch (_) {
      validTill = DateTime(2030, 1, 1);
    }

    final rawRates = json['offered_rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};
    rawRates.forEach((k, v) {
      if (v is num) {
        parsedRates[k] = v.toDouble();
      }
    });

    final rawMats = json['materials_accepted'] as List<dynamic>? ?? [];

    return RecyclerCandidateData(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      materialsAccepted: rawMats.map((e) => e.toString()).toList(),
      authorizationStatus: json['authorization_status'] as String,
      authorizationValidTill: validTill,
      authorizationNumber: json['authorization_number'] as String? ?? 'REG-MINT-DEFAULT',
      phone: json['phone'] as String? ?? '+910000000000',
      offeredRates: parsedRates,
      pickupAvailable: json['pickup_available'] as bool? ?? false,
      pickupRadiusKm: (json['pickup_radius_km'] as num?)?.toDouble() ?? 0.0,
      serviceArea: json['service_area'] as Map<String, dynamic>? ?? {},
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      confirmationSpeedHours: (json['confirmation_speed_hours'] as num?)?.toDouble(),
    );
  }
}

class ScoreBreakdownData {
  const ScoreBreakdownData({
    required this.offeredRate,
    required this.distance,
    required this.pickupAvailable,
    required this.completionRate,
    required this.confirmationSpeed,
    required this.rating,
  });

  final double offeredRate;
  final double distance;
  final double pickupAvailable;
  final double completionRate;
  final double confirmationSpeed;
  final double rating;

  Map<String, double> toMap() => {
        'offered_rate': offeredRate,
        'distance': distance,
        'pickup_available': pickupAvailable,
        'completion_rate': completionRate,
        'confirmation_speed': confirmationSpeed,
        'rating': rating,
      };
}

class RankedRecyclerResult {
  const RankedRecyclerResult({
    required this.recyclerId,
    required this.name,
    required this.phone,
    required this.rank,
    required this.score,
    required this.scoreBreakdown,
    required this.distanceKm,
    required this.offeredRate,
    required this.pickupAvailable,
    required this.estimatedPickupTime,
    required this.rating,
    this.authorizationNumber,
  });

  final String recyclerId;
  final String name;
  final String phone;
  final int rank;
  final double score;
  final ScoreBreakdownData scoreBreakdown;
  final double distanceKm;
  final double offeredRate;
  final bool pickupAvailable;
  final String estimatedPickupTime;
  final double rating;
  final String? authorizationNumber;
}

class OfflineMatchingEngine {
  static const double wRate = 0.30;
  static const double wDist = 0.25;
  static const double wPickup = 0.15;
  static const double wComp = 0.15;
  static const double wSpeed = 0.10;
  static const double wRating = 0.05;

  static const double distanceDecayKm = 10.0;
  static const double speedMaxHours = 48.0;
  static const double defaultCompletionRate = 0.85;
  static const double defaultConfirmationHours = 4.0;

  /// Haversine great-circle distance in kilometers rounded to 2 decimal places.
  static double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const radiusEarthKm = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return ((radiusEarthKm * c) * 100).round() / 100;
  }

  /// Checks if candidate passes all 3 non-negotiable hard constraints.
  static bool passesHardFilters(
    RecyclerCandidateData candidate,
    OfflineLotInput lot,
    double distanceKm, [
    DateTime? currentDate,
  ]) {
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Authorization verified and not expired
    if (candidate.authorizationStatus.trim().toLowerCase() != 'verified') {
      return false;
    }
    final expDate = DateTime(
      candidate.authorizationValidTill.year,
      candidate.authorizationValidTill.month,
      candidate.authorizationValidTill.day,
    );
    if (!expDate.isAfter(today)) {
      return false;
    }

    // 2. Category accepted
    final lotCat = lot.category.trim().toLowerCase();
    final accepts = candidate.materialsAccepted.isEmpty ||
        candidate.materialsAccepted.any((m) {
          final mat = m.trim().toLowerCase();
          return mat == lotCat ||
              mat.contains(lotCat) ||
              lotCat.contains(mat) ||
              mat == 'all' ||
              mat == 'e-waste';
        });
    if (!accepts) {
      return false;
    }

    // 3. Location check
    if (candidate.pickupRadiusKm > 0 && distanceKm <= candidate.pickupRadiusKm) {
      return true;
    }

    final sa = candidate.serviceArea;
    if (sa['all'] == true || sa['state'] == 'Maharashtra') {
      return true;
    }

    final lotDist = (lot.district ?? '').trim().toLowerCase();
    if (lotDist.isNotEmpty) {
      final districts = (sa['districts'] as List<dynamic>? ?? [])
          .map((d) => d.toString().trim().toLowerCase())
          .toList();
      final singleDistrict = (sa['district'] ?? '').toString().trim().toLowerCase();
      if (districts.contains(lotDist) || (singleDistrict.isNotEmpty && singleDistrict == lotDist)) {
        return true;
      }
    }

    final maxDist = sa['max_distance_km'];
    if (maxDist is num && distanceKm <= maxDist.toDouble()) {
      return true;
    }

    return false;
  }

  static String estimatePickupTime(bool pickupAvailable, double distanceKm) {
    if (!pickupAvailable) {
      return 'Drop-off only (No pickup)';
    }
    if (distanceKm <= 15.0) {
      return 'Within 2-4 hours';
    }
    if (distanceKm <= 50.0) {
      return 'Same-day pickup (by 6 PM)';
    }
    return 'Next business day pickup';
  }

  static double _round4(double val) => (val * 10000).round() / 10000;

  static double _extractOfferedRate(Map<String, double> rates, String category) {
    if (rates.containsKey(category)) return rates[category]!;
    final catLower = category.toLowerCase();
    for (final entry in rates.entries) {
      final keyLower = entry.key.toLowerCase();
      if (keyLower.contains(catLower) || catLower.contains(keyLower)) {
        return entry.value;
      }
    }
    return rates.values.isNotEmpty ? rates.values.first : 120.0;
  }

  /// Ranks candidates deterministically using multi-criteria weighted sum.
  static List<RankedRecyclerResult> rankCandidates(
    List<RecyclerCandidateData> candidates,
    OfflineLotInput lot, {
    DateTime? currentDate,
  }) {
    final passing = <_PassingCandidate>[];

    for (final c in candidates) {
      final distKm = haversineDistanceKm(
        lot.collectionLat,
        lot.collectionLng,
        c.latitude,
        c.longitude,
      );

      if (passesHardFilters(c, lot, distKm, currentDate)) {
        final rate = _extractOfferedRate(c.offeredRates, lot.category);
        passing.add(_PassingCandidate(c, distKm, rate));
      }
    }

    if (passing.isEmpty) {
      return [];
    }

    final allRates = passing.map((p) => p.rate).toList();
    final minRate = allRates.reduce(math.min);
    final maxRate = allRates.reduce(math.max);

    final scored = <_ScoredItem>[];

    for (final p in passing) {
      final c = p.candidate;
      final distKm = p.distanceKm;
      final rate = p.rate;

      // 1. Offered Rate (0.0 to 1.0)
      final normRate = maxRate > minRate
          ? (rate - minRate) / (maxRate - minRate)
          : (rate > 0 ? 1.0 : 0.0);

      // 2. Inverse Distance
      final normDist = 1.0 / (1.0 + (distKm / distanceDecayKm));

      // 3. Pickup Available
      final normPickup = c.pickupAvailable ? 1.0 : 0.0;

      // 4. Completion Rate
      final comp = c.completionRate ?? defaultCompletionRate;
      final normComp = math.max(0.0, math.min(1.0, comp));

      // 5. Confirmation Speed
      final speed = c.confirmationSpeedHours ?? defaultConfirmationHours;
      final normSpeed = math.max(0.0, 1.0 - (speed / speedMaxHours));

      // 6. Rating
      final normRating = math.max(0.0, math.min(1.0, c.rating / 5.0));

      final score = wRate * normRate +
          wDist * normDist +
          wPickup * normPickup +
          wComp * normComp +
          wSpeed * normSpeed +
          wRating * normRating;

      final breakdown = ScoreBreakdownData(
        offeredRate: _round4(wRate * normRate),
        distance: _round4(wDist * normDist),
        pickupAvailable: _round4(wPickup * normPickup),
        completionRate: _round4(wComp * normComp),
        confirmationSpeed: _round4(wSpeed * normSpeed),
        rating: _round4(wRating * normRating),
      );

      scored.add(_ScoredItem(
        score: _round4(score),
        offeredRate: rate,
        distanceKm: distKm,
        rating: c.rating,
        candidate: c,
        breakdown: breakdown,
      ));
    }

    // Deterministic tie-breaking:
    // 1. score descending
    // 2. offeredRate descending
    // 3. distanceKm ascending
    // 4. rating descending
    // 5. candidate.id ascending
    scored.sort((a, b) {
      final cmpScore = b.score.compareTo(a.score);
      if (cmpScore != 0) return cmpScore;

      final cmpRate = b.offeredRate.compareTo(a.offeredRate);
      if (cmpRate != 0) return cmpRate;

      final cmpDist = a.distanceKm.compareTo(b.distanceKm);
      if (cmpDist != 0) return cmpDist;

      final cmpRating = b.rating.compareTo(a.rating);
      if (cmpRating != 0) return cmpRating;

      return a.candidate.id.compareTo(b.candidate.id);
    });

    final top3 = scored.take(3).toList();
    final results = <RankedRecyclerResult>[];

    for (var i = 0; i < top3.length; i++) {
      final item = top3[i];
      final c = item.candidate;
      results.add(RankedRecyclerResult(
        recyclerId: c.id,
        name: c.name,
        phone: c.phone,
        rank: i + 1,
        score: item.score,
        scoreBreakdown: item.breakdown,
        distanceKm: item.distanceKm,
        offeredRate: item.offeredRate,
        pickupAvailable: c.pickupAvailable,
        estimatedPickupTime: estimatePickupTime(c.pickupAvailable, item.distanceKm),
        authorizationNumber: c.authorizationNumber,
        rating: c.rating,
      ));
    }

    return results;
  }
}

class _PassingCandidate {
  _PassingCandidate(this.candidate, this.distanceKm, this.rate);
  final RecyclerCandidateData candidate;
  final double distanceKm;
  final double rate;
}

class _ScoredItem {
  _ScoredItem({
    required this.score,
    required this.offeredRate,
    required this.distanceKm,
    required this.rating,
    required this.candidate,
    required this.breakdown,
  });

  final double score;
  final double offeredRate;
  final double distanceKm;
  final double rating;
  final RecyclerCandidateData candidate;
  final ScoreBreakdownData breakdown;
}

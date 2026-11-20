/// Model representing a citizen doorstep pickup request on mobile.
class PickupRequestDto {
  final String id;
  final String publicCode;
  final String status;
  final List<String> categories;
  final List<String> photoUrls;
  final String? addressText;
  final double latitude;
  final double longitude;
  final double? estimatedDistanceKm;
  final String? assignedCollectorId;
  final String? citizenPhone;
  final String? preferredTimeSlot;
  final DateTime createdAt;

  const PickupRequestDto({
    required this.id,
    required this.publicCode,
    required this.status,
    required this.categories,
    required this.photoUrls,
    this.addressText,
    required this.latitude,
    required this.longitude,
    this.estimatedDistanceKm,
    this.assignedCollectorId,
    this.citizenPhone,
    this.preferredTimeSlot,
    required this.createdAt,
  });

  factory PickupRequestDto.fromJson(Map<String, dynamic> json) {
    return PickupRequestDto(
      id: json['id']?.toString() ?? '',
      publicCode: json['public_code']?.toString() ?? json['publicCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'CREATED',
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      addressText: json['address_text']?.toString() ?? json['addressText']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude:
          (json['longitude'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble() ?? 0.0,
      estimatedDistanceKm: (json['estimated_distance_km'] as num?)?.toDouble(),
      assignedCollectorId: json['assigned_collector_id']?.toString(),
      citizenPhone: json['citizen_phone']?.toString() ?? json['phone']?.toString(),
      preferredTimeSlot: json['preferred_time_slot']?.toString() ?? json['timeSlot']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'public_code': publicCode,
      'status': status,
      'categories': categories,
      'photo_urls': photoUrls,
      'address_text': addressText,
      'latitude': latitude,
      'longitude': longitude,
      'estimated_distance_km': estimatedDistanceKm,
      'assigned_collector_id': assignedCollectorId,
      'citizen_phone': citizenPhone,
      'preferred_time_slot': preferredTimeSlot,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

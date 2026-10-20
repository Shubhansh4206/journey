import 'package:latlong2/latlong.dart';

/// Model representing a record from `public.quotations` table in Supabase.
class SupabaseQuotation {
  final String id;
  final String tripRequestId;
  final String operatorId;
  final String title;
  final String status;
  final double totalBaseCost;
  final double totalFinalPrice;
  final DateTime? validUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int paxCount;
  final double perPersonPrice;

  SupabaseQuotation({
    required this.id,
    required this.tripRequestId,
    required this.operatorId,
    required this.title,
    required this.status,
    required this.totalBaseCost,
    required this.totalFinalPrice,
    this.validUntil,
    this.createdAt,
    this.updatedAt,
    this.paxCount = 1,
    double? perPersonPrice,
  }) : perPersonPrice = perPersonPrice ??
            (paxCount > 0 ? (totalFinalPrice / paxCount) : totalFinalPrice);

  bool get isFinalized {
    final s = status.toLowerCase();
    return s == 'finalized' || s == 'finalised';
  }

  factory SupabaseQuotation.fromJson(Map<String, dynamic> json) {
    final double totalFinal = (json['total_final_price'] as num?)?.toDouble() ?? 0.0;
    final int pax = (json['pax_count'] as num?)?.toInt() ?? 1;
    final double? ppp = (json['per_person_price'] as num?)?.toDouble();

    return SupabaseQuotation(
      id: json['id']?.toString() ?? '',
      tripRequestId: json['trip_request_id']?.toString() ?? '',
      operatorId: json['operator_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Customized Itinerary',
      status: json['status']?.toString().toLowerCase() ?? 'draft',
      totalBaseCost: (json['total_base_cost'] as num?)?.toDouble() ?? 0.0,
      totalFinalPrice: totalFinal,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      paxCount: pax > 0 ? pax : 1,
      perPersonPrice: ppp ?? (pax > 0 ? (totalFinal / pax) : totalFinal),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_request_id': tripRequestId,
      'operator_id': operatorId,
      'title': title,
      'status': status,
      'total_base_cost': totalBaseCost,
      'total_final_price': totalFinalPrice,
      'valid_until': validUntil?.toIso8601String(),
      'pax_count': paxCount,
      // per_person_price is a GENERATED ALWAYS STORED column in PostgreSQL, so omitted on writes
    };
  }
}

/// Represents an itinerary item with coordinates for OpenStreetMap visualization.
class ItineraryLocationItem {
  final String id;
  final String title;
  final String category; // 'Hotel', 'Place', 'Activity', 'Transport'
  final double latitude;
  final double longitude;
  final String subtitle;
  final double price;
  final int dayNumber;
  final String duration;
  final String notes;

  ItineraryLocationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.subtitle = '',
    this.price = 0.0,
    this.dayNumber = 1,
    this.duration = '',
    this.notes = '',
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lngDir';
  }
}

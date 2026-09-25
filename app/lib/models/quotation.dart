class QuotationItem {
  final String icon;
  final String text;

  QuotationItem({required this.icon, required this.text});

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      icon: json['icon'] as String? ?? '•',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'icon': icon, 'text': text};
}

class Quotation {
  final String id;
  final String tripRequestId;
  final String operatorId;
  final double basePricePerPax;
  final Map<String, dynamic> dynamicTiers; // e.g. {"+1_solo": 5500, "+2_solos": 5000}
  final int negotiationRound;
  final String? userFeedback;
  final List<QuotationItem> inclusions;
  final List<QuotationItem> exclusions;
  final String status; // 'submitted', 'user_counter', 'operator_revised', 'accepted', 'rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quotation({
    required this.id,
    required this.tripRequestId,
    required this.operatorId,
    required this.basePricePerPax,
    this.dynamicTiers = const {},
    this.negotiationRound = 0,
    this.userFeedback,
    this.inclusions = const [],
    this.exclusions = const [],
    this.status = 'submitted',
    this.createdAt,
    this.updatedAt,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as String,
      tripRequestId: json['trip_request_id'] as String,
      operatorId: json['operator_id'] as String,
      basePricePerPax: (json['base_price_per_pax'] as num).toDouble(),
      dynamicTiers: Map<String, dynamic>.from(json['dynamic_tiers'] ?? {}),
      negotiationRound: json['negotiation_round'] as int? ?? 0,
      userFeedback: json['user_feedback'] as String?,
      inclusions: (json['inclusions'] as List<dynamic>? ?? [])
          .map((item) => QuotationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      exclusions: (json['exclusions'] as List<dynamic>? ?? [])
          .map((item) => QuotationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'submitted',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_request_id': tripRequestId,
      'operator_id': operatorId,
      'base_price_per_pax': basePricePerPax,
      'dynamic_tiers': dynamicTiers,
      'negotiation_round': negotiationRound,
      'user_feedback': userFeedback,
      'inclusions': inclusions.map((e) => e.toJson()).toList(),
      'exclusions': exclusions.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }
}
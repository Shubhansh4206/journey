class QuotationModel {
  final String id;
  final String tripRequestId;
  final String? operatorId;
  final String title;
  final String status; // 'pending_operator', 'operator_proposed', 'user_countered', 'accepted', 'declined', 'draft'
  final String currency;
  final double totalBaseCost;
  final double totalMarginAmount;
  final double totalFinalPrice;
  final int paxCount;
  final double perPersonPrice;
  final String? customerNotes;
  final String? operatorNotes;
  final DateTime? validUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuotationModel({
    required this.id,
    required this.tripRequestId,
    this.operatorId,
    this.title = 'Your Customized Itinerary',
    this.status = 'pending_operator',
    this.currency = 'INR',
    this.totalBaseCost = 0.0,
    this.totalMarginAmount = 0.0,
    required this.totalFinalPrice,
    this.paxCount = 4,
    double? perPersonPrice,
    this.customerNotes,
    this.operatorNotes,
    this.validUntil,
    this.createdAt,
    this.updatedAt,
  }) : perPersonPrice = perPersonPrice ??
            (paxCount > 0 ? (totalFinalPrice / paxCount) : totalFinalPrice);

  /// Status Checkers
  bool get isLocked =>
      status == 'pending_operator' ||
      status == 'user_countered' ||
      status == 'draft' ||
      status == 'sent';

  bool get isOperatorProposed =>
      status == 'operator_proposed' || status == 'user_modified';

  bool get isAccepted => status == 'accepted' || status == 'confirmed';

  bool get isDeclined => status == 'declined' || status == 'cancelled';

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    final total = (json['total_final_price'] as num?)?.toDouble() ??
        (json['base_price_per_pax'] as num?)?.toDouble() ??
        0.0;
    final pax = (json['pax_count'] as num?)?.toInt() ?? 4;
    final ppp = (json['per_person_price'] as num?)?.toDouble() ??
        (pax > 0 ? (total / pax) : total);

    return QuotationModel(
      id: json['id']?.toString() ?? '',
      tripRequestId: json['trip_request_id']?.toString() ?? '',
      operatorId: json['operator_id']?.toString(),
      title: json['title']?.toString() ?? 'Customized Itinerary',
      status: json['status']?.toString().toLowerCase() ?? 'pending_operator',
      currency: json['currency']?.toString() ?? 'INR',
      totalBaseCost: (json['total_base_cost'] as num?)?.toDouble() ?? 0.0,
      totalMarginAmount: (json['total_margin_amount'] as num?)?.toDouble() ?? 0.0,
      totalFinalPrice: total,
      paxCount: pax,
      perPersonPrice: ppp,
      customerNotes: json['customer_notes']?.toString(),
      operatorNotes: json['operator_notes']?.toString(),
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'].toString())
          : null,
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
      'title': title,
      'status': status,
      'currency': currency,
      'total_base_cost': totalBaseCost,
      'total_final_price': totalFinalPrice,
      'pax_count': paxCount,
      'per_person_price': perPersonPrice,
      'customer_notes': customerNotes,
      'operator_notes': operatorNotes,
      'valid_until': validUntil?.toIso8601String(),
    };
  }

  QuotationModel copyWith({
    String? id,
    String? tripRequestId,
    String? operatorId,
    String? title,
    String? status,
    String? currency,
    double? totalBaseCost,
    double? totalMarginAmount,
    double? totalFinalPrice,
    int? paxCount,
    double? perPersonPrice,
    String? customerNotes,
    String? operatorNotes,
    DateTime? validUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuotationModel(
      id: id ?? this.id,
      tripRequestId: tripRequestId ?? this.tripRequestId,
      operatorId: operatorId ?? this.operatorId,
      title: title ?? this.title,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      totalBaseCost: totalBaseCost ?? this.totalBaseCost,
      totalMarginAmount: totalMarginAmount ?? this.totalMarginAmount,
      totalFinalPrice: totalFinalPrice ?? this.totalFinalPrice,
      paxCount: paxCount ?? this.paxCount,
      perPersonPrice: perPersonPrice ?? this.perPersonPrice,
      customerNotes: customerNotes ?? this.customerNotes,
      operatorNotes: operatorNotes ?? this.operatorNotes,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

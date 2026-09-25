class TripRequest {
  final String id;
  final String groupId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? travelPace;
  final double maxBudgetPerPax;
  final List<Map<String, dynamic>> requestedCartItems;
  final String status; // 'broadcasting', 'reviewing_bids', 'closed'
  final DateTime? createdAt;

  TripRequest({
    required this.id,
    required this.groupId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.travelPace,
    required this.maxBudgetPerPax,
    this.requestedCartItems = const [],
    this.status = 'broadcasting',
    this.createdAt,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      travelPace: json['travel_pace'] as String?,
      maxBudgetPerPax: (json['max_budget_per_pax'] as num).toDouble(),
      requestedCartItems: List<Map<String, dynamic>>.from(
        json['requested_cart_items'] ?? [],
      ),
      status: json['status'] as String? ?? 'broadcasting',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'travel_pace': travelPace,
      'max_budget_per_pax': maxBudgetPerPax,
      'requested_cart_items': requestedCartItems,
      'status': status,
    };
  }
}
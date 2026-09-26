class TripRequest {
  final String id;
  final String? customerId;
  final String? groupId;

  // 1. Header Details from UI
  final String destination;
  final String tripMode; // 'Group Squad' or 'Solo Journey'
  final String? assignedGroupName;

  // 2. Dates & Financials
  final DateTime startDate;
  final DateTime endDate;
  final double perPersonBudget;
  final double estimatedMockTotal;

  // 3. Itemized Itinerary Selections (UUID arrays)
  final List<String> selectedHotels;
  final List<String> selectedPlaces;
  final List<String> selectedActivities;
  final List<String> selectedTransport;

  // 4. Tracking
  final String status; // 'pending'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility getters
  double get maxBudgetPerPax => perPersonBudget;
  List<Map<String, dynamic>> get requestedCartItems => [];

  TripRequest({
    required this.id,
    this.customerId,
    this.groupId,
    required this.destination,
    this.tripMode = 'Group Squad',
    this.assignedGroupName,
    required this.startDate,
    required this.endDate,
    required this.perPersonBudget,
    this.estimatedMockTotal = 0.0,
    this.selectedHotels = const [],
    this.selectedPlaces = const [],
    this.selectedActivities = const [],
    this.selectedTransport = const [],
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    List<String> parseUuidList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return TripRequest(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      groupId: json['group_id'] as String?,
      destination: json['destination'] as String? ?? '',
      tripMode: json['trip_mode'] as String? ?? 'Group Squad',
      assignedGroupName: json['assigned_group_name'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      perPersonBudget: (json['per_person_budget'] as num?)?.toDouble() ??
          (json['max_budget_per_pax'] as num?)?.toDouble() ??
          0.0,
      estimatedMockTotal:
          (json['estimated_mock_total'] as num?)?.toDouble() ?? 0.0,
      selectedHotels: parseUuidList(json['selected_hotels']),
      selectedPlaces: parseUuidList(json['selected_places']),
      selectedActivities: parseUuidList(json['selected_activities']),
      selectedTransport: parseUuidList(json['selected_transport']),
      status: json['status'] as String? ?? 'pending',
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
      'customer_id': ?customerId,
      'group_id': ?groupId,
      'destination': destination,
      'trip_mode': tripMode,
      'assigned_group_name': ?assignedGroupName,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'per_person_budget': perPersonBudget,
      'estimated_mock_total': estimatedMockTotal,
      'selected_hotels': selectedHotels,
      'selected_places': selectedPlaces,
      'selected_activities': selectedActivities,
      'selected_transport': selectedTransport,
      'status': status,
      'created_at': ?createdAt?.toIso8601String(),
      'updated_at': ?updatedAt?.toIso8601String(),
    };
  }
}
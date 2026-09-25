class ItineraryActivity {
  final String? time;
  final String activity;

  ItineraryActivity({this.time, required this.activity});

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      time: json['time'] as String?,
      activity: json['activity'] as String? ?? json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'time': time, 'activity': activity};
}

class ItineraryDay {
  final String id;
  final String quotationId;
  final int dayNumber;
  final String dateDisplay;
  final String dayTitle;
  final List<ItineraryActivity> activities;
  final List<String> inventoryItems;
  final DateTime? createdAt;

  ItineraryDay({
    required this.id,
    required this.quotationId,
    required this.dayNumber,
    required this.dateDisplay,
    required this.dayTitle,
    this.activities = const [],
    this.inventoryItems = const [],
    this.createdAt,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      id: json['id'] as String,
      quotationId: json['quotation_id'] as String,
      dayNumber: json['day_number'] as int,
      dateDisplay: json['date_display'] as String,
      dayTitle: json['day_title'] as String,
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((item) => ItineraryActivity.fromJson(item as Map<String, dynamic>))
          .toList(),
      inventoryItems: List<String>.from(json['inventory_items'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'day_number': dayNumber,
      'date_display': dateDisplay,
      'day_title': dayTitle,
      'activities': activities.map((e) => e.toJson()).toList(),
      'inventory_items': inventoryItems,
    };
  }
}
class LiveCheckin {
  final String id;
  final String groupId;
  final String itineraryDayId;
  final String userId;
  final String status; // 'arrived', 'completed', 'no_show'
  final DateTime? timestamp;

  LiveCheckin({
    required this.id,
    required this.groupId,
    required this.itineraryDayId,
    required this.userId,
    this.status = 'arrived',
    this.timestamp,
  });

  factory LiveCheckin.fromJson(Map<String, dynamic> json) {
    return LiveCheckin(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      itineraryDayId: json['itinerary_day_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'arrived',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'itinerary_day_id': itineraryDayId,
      'user_id': userId,
      'status': status,
    };
  }
}
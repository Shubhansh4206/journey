class TripGroup {
  final String id;
  final String leaderId;
  final String name;
  final bool openToSolos;
  final int maxSoloSeats;
  final DateTime? createdAt;

  TripGroup({
    required this.id,
    required this.leaderId,
    required this.name,
    this.openToSolos = false,
    this.maxSoloSeats = 0,
    this.createdAt,
  });

  factory TripGroup.fromJson(Map<String, dynamic> json) {
    return TripGroup(
      id: json['id'] as String,
      leaderId: json['leader_id'] as String,
      name: json['name'] as String,
      openToSolos: json['open_to_solos'] as bool? ?? false,
      maxSoloSeats: json['max_solo_seats'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leader_id': leaderId,
      'name': name,
      'open_to_solos': openToSolos,
      'max_solo_seats': maxSoloSeats,
    };
  }
}

class GroupMember {
  final String groupId;
  final String userId;
  final String role; // 'leader', 'member', 'solo_join'
  final DateTime? joinedAt;

  GroupMember({
    required this.groupId,
    required this.userId,
    this.role = 'member',
    this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'role': role,
    };
  }
}
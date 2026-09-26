class UserProfileBasic {
  final String id;
  final String fullName;
  final String email;

  UserProfileBasic({
    required this.id,
    required this.fullName,
    required this.email,
  });

  String get name => fullName;

  factory UserProfileBasic.fromJson(Map<String, dynamic> json) {
    return UserProfileBasic(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ??
          json['name'] as String? ??
          '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'name': fullName,
      'email': email,
    };
  }
}

class GroupData {
  final String id;
  final String leaderId;
  final String name;
  final bool openToSolos;
  final int maxSoloSeats;
  final DateTime? createdAt;

  GroupData({
    required this.id,
    required this.leaderId,
    required this.name,
    this.openToSolos = false,
    this.maxSoloSeats = 0,
    this.createdAt,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      id: json['id'] as String? ?? '',
      leaderId: json['leader_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
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
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  GroupData copyWith({
    String? id,
    String? leaderId,
    String? name,
    bool? openToSolos,
    int? maxSoloSeats,
    DateTime? createdAt,
  }) {
    return GroupData(
      id: id ?? this.id,
      leaderId: leaderId ?? this.leaderId,
      name: name ?? this.name,
      openToSolos: openToSolos ?? this.openToSolos,
      maxSoloSeats: maxSoloSeats ?? this.maxSoloSeats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Alias for compatibility
typedef TripGroup = GroupData;
typedef Group = GroupData;

class GroupMemberItem {
  final String groupId;
  final String userId;
  final String role; // 'leader' | 'member' | 'solo_join'
  final String fullName;
  final String email;
  final DateTime? joinedAt;

  GroupMemberItem({
    required this.groupId,
    required this.userId,
    required this.role,
    this.fullName = '',
    this.email = '',
    this.joinedAt,
  });

  bool get isLeader => role.toLowerCase() == 'leader';

  factory GroupMemberItem.fromJson(Map<String, dynamic> json) {
    final profile = json['user_profiles'] as Map<String, dynamic>? ??
        json['profiles'] as Map<String, dynamic>? ??
        {};

    return GroupMemberItem(
      groupId: json['group_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      fullName: profile['full_name'] as String? ??
          json['full_name'] as String? ??
          'Unknown Member',
      email: profile['email'] as String? ??
          json['email'] as String? ??
          '',
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
      'full_name': fullName,
      'email': email,
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    };
  }
}

class GroupInvitationItem {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime? createdAt;

  GroupInvitationItem({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.status,
    this.createdAt,
  });

  factory GroupInvitationItem.fromJson(Map<String, dynamic> json) {
    final group = json['groups'] as Map<String, dynamic>? ?? {};
    final inviter = json['inviter'] as Map<String, dynamic>? ??
        json['user_profiles'] as Map<String, dynamic>? ??
        json['profiles'] as Map<String, dynamic>? ??
        {};

    final resolvedGroupName = json['group_name'] as String? ??
        group['name'] as String? ??
        'Unknown Group';

    final resolvedInviterName = json['inviter_name'] as String? ??
        inviter['full_name'] as String? ??
        inviter['name'] as String? ??
        'Group Leader';

    return GroupInvitationItem(
      id: json['id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      groupName: resolvedGroupName,
      inviterId: json['inviter_id'] as String? ?? '',
      inviterName: resolvedInviterName,
      inviteeId: json['invitee_id'] as String? ??
          json['solo_user_id'] as String? ??
          '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'group_name': groupName,
      'inviter_id': inviterId,
      'inviter_name': inviterName,
      'invitee_id': inviteeId,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class Community {
  final String id;
  final String destination;
  final String travelMonth;
  final List<String> tags;
  final DateTime? createdAt;

  Community({
    required this.id,
    required this.destination,
    required this.travelMonth,
    this.tags = const [],
    this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      destination: json['destination'] as String,
      travelMonth: json['travel_month'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'travel_month': travelMonth,
      'tags': tags,
    };
  }
}

class CommunityMember {
  final String communityId;
  final String userId;
  final bool lookingForGroup;
  final DateTime? joinedAt;

  CommunityMember({
    required this.communityId,
    required this.userId,
    this.lookingForGroup = true,
    this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      lookingForGroup: json['looking_for_group'] as bool? ?? true,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'user_id': userId,
      'looking_for_group': lookingForGroup,
    };
  }
}
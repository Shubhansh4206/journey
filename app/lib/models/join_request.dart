class JoinRequest {
  final String id;
  final String groupId;
  final String soloUserId;
  final String? pitchMessage;
  final int? aiMatchScore;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime? createdAt;

  JoinRequest({
    required this.id,
    required this.groupId,
    required this.soloUserId,
    this.pitchMessage,
    this.aiMatchScore,
    this.status = 'pending',
    this.createdAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      soloUserId: json['solo_user_id'] as String,
      pitchMessage: json['pitch_message'] as String?,
      aiMatchScore: json['ai_match_score'] as int?,
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
      'solo_user_id': soloUserId,
      'pitch_message': pitchMessage,
      'ai_match_score': aiMatchScore,
      'status': status,
    };
  }
}
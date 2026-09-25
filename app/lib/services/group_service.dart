import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_group.dart';

class GroupService {
  final _supabase = Supabase.instance.client;

  /// Look up a user by email using an RPC function that reads from auth.users.
  /// Requires the `get_user_id_by_email` Postgres function to exist in Supabase.
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final result = await _supabase.rpc(
        'get_user_id_by_email',
        params: {'lookup_email': email.toLowerCase()},
      );

      // RPC returns a list of rows
      if (result is List && result.isNotEmpty) {
        return Map<String, dynamic>.from(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('findUserByEmail RPC error: $e');
      return null;
    }
  }

  /// Create a new group and add the leader as a group_member
  Future<TripGroup?> createGroup({
    required String name,
    required String leaderId,
  }) async {
    try {
      final groupData = await _supabase.from('groups').insert({
        'leader_id': leaderId,
        'name': name,
        'open_to_solos': false,
        'max_solo_seats': 0,
      }).select().single();

      final group = TripGroup.fromJson(groupData);

      // Add leader as group_member with role 'leader'
      await _supabase.from('group_members').insert({
        'group_id': group.id,
        'user_id': leaderId,
        'role': 'leader',
      });

      return group;
    } catch (e) {
      debugPrint('createGroup error: $e');
      return null;
    }
  }

  /// Send an invite to a user via join_requests
  Future<bool> sendInvite({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _supabase.from('join_requests').insert({
        'group_id': groupId,
        'solo_user_id': userId,
        'status': 'pending',
        'pitch_message': 'You have been invited to join this group!',
      });
      return true;
    } catch (e) {
      debugPrint('sendInvite error: $e');
      return false;
    }
  }

  /// Accept an invite: update join_request status + add to group_members
  Future<bool> acceptInvite(String requestId, String groupId, String userId) async {
    try {
      await _supabase.from('join_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      await _supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'member',
      });
      return true;
    } catch (e) {
      debugPrint('acceptInvite error: $e');
      return false;
    }
  }

  /// Decline an invite
  Future<bool> declineInvite(String requestId) async {
    try {
      await _supabase.from('join_requests')
          .update({'status': 'declined'})
          .eq('id', requestId);
      return true;
    } catch (e) {
      debugPrint('declineInvite error: $e');
      return false;
    }
  }

  /// Remove a member from a group (leader action)
  Future<bool> removeMember(String groupId, String userId) async {
    try {
      await _supabase.from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('removeMember error: $e');
      return false;
    }
  }

  /// Get all groups the current user belongs to
  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    try {
      final memberships = await _supabase
          .from('group_members')
          .select('group_id, role, groups(id, name, leader_id, open_to_solos, max_solo_seats, created_at)')
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(memberships);
    } catch (e) {
      debugPrint('getUserGroups error: $e');
      return [];
    }
  }

  /// Get members of a group with their profile info + email via RPC
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final members = await _supabase
          .from('group_members')
          .select('user_id, role, joined_at, profiles(id, full_name)')
          .eq('group_id', groupId);

      final memberList = List<Map<String, dynamic>>.from(members);
      // Fetch emails via RPC for each member
      for (var i = 0; i < memberList.length; i++) {
        try {
          final result = await _supabase.rpc(
            'get_email_by_user_id',
            params: {'lookup_id': memberList[i]['user_id']},
          );
          if (result is List && result.isNotEmpty) {
            memberList[i]['email'] = result.first['email'] ?? '';
          } else {
            memberList[i]['email'] = '';
          }
        } catch (_) {
          memberList[i]['email'] = '';
        }
      }
      return memberList;
    } catch (e) {
      debugPrint('getGroupMembers error: $e');
      return [];
    }
  }

  /// Get pending invites for the current user
  Future<List<Map<String, dynamic>>> getPendingInvites(String userId) async {
    try {
      final invites = await _supabase
          .from('join_requests')
          .select('id, group_id, status, pitch_message, created_at, groups(id, name, leader_id)')
          .eq('solo_user_id', userId)
          .eq('status', 'pending');

      return List<Map<String, dynamic>>.from(invites);
    } catch (e) {
      debugPrint('getPendingInvites error: $e');
      return [];
    }
  }

  /// Get pending invites sent from a group (for leader view)
  Future<List<Map<String, dynamic>>> getGroupPendingInvites(String groupId) async {
    try {
      final invites = await _supabase
          .from('join_requests')
          .select('id, solo_user_id, status, created_at')
          .eq('group_id', groupId)
          .eq('status', 'pending');

      final inviteList = List<Map<String, dynamic>>.from(invites);
      for (var i = 0; i < inviteList.length; i++) {
        try {
          final result = await _supabase.rpc(
            'get_email_by_user_id',
            params: {'lookup_id': inviteList[i]['solo_user_id']},
          );
          if (result is List && result.isNotEmpty) {
            inviteList[i]['email'] = result.first['email'] ?? '';
            inviteList[i]['name'] = result.first['email']?.split('@').first ?? '';
          }
        } catch (_) {}
      }
      return inviteList;
    } catch (e) {
      debugPrint('getGroupPendingInvites error: $e');
      return [];
    }
  }

  Future<bool> updateGroupName(String groupId, String name) async {
    try {
      await _supabase.from('groups').update({'name': name}).eq('id', groupId);
      return true;
    } catch (e) {
      debugPrint('updateGroupName error: $e');
      return false;
    }
  }

  /// Members can leave. Leaders cannot leave (rename/delete instead).
  Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final membership = await _supabase
          .from('group_members')
          .select('role')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (membership == null) return false;
      if (membership['role'] == 'leader') {
        return false;
      }

      await _supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('leaveGroup error: $e');
      return false;
    }
  }

  /// Solo traveler asks to join an open squad.
  Future<bool> requestToJoinGroup({
    required String groupId,
    required String userId,
    String? pitch,
  }) async {
    try {
      await _supabase.from('join_requests').insert({
        'group_id': groupId,
        'solo_user_id': userId,
        'status': 'pending',
        'pitch_message': pitch ?? 'I would like to join this squad.',
      });
      return true;
    } catch (e) {
      debugPrint('requestToJoinGroup error: $e');
      return false;
    }
  }

  Future<bool> joinCommunity({
    required String communityId,
    required String userId,
  }) async {
    try {
      await _supabase.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
        'looking_for_group': true,
      });
      return true;
    } catch (e) {
      debugPrint('joinCommunity error: $e');
      return false;
    }
  }
}

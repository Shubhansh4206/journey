import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_models.dart';

class GroupService {
  final SupabaseClient _supabase;

  GroupService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 1. Create a new group and add the creator as 'leader' in `group_members`
  Future<GroupData?> createGroup({
    required String name,
    String? leaderId,
  }) async {
    final effectiveLeaderId = leaderId ?? currentUserId;
    debugPrint('🚀 [GroupService.createGroup] Starting: name="$name", leaderId=$effectiveLeaderId');

    if (name.trim().isEmpty) {
      debugPrint('❌ [GroupService.createGroup] Empty group name');
      throw Exception('Group name cannot be empty.');
    }
    if (effectiveLeaderId == null) {
      debugPrint('❌ [GroupService.createGroup] No authenticated user');
      throw Exception('User must be logged in to create a group.');
    }

    try {
      // 1. Insert into groups and retrieve created record
      debugPrint('⏳ [GroupService.createGroup] Inserting into `groups` table...');
      final groupRow = await _supabase.from('groups').insert({
        'name': name.trim(),
        'leader_id': effectiveLeaderId,
        'open_to_solos': false,
        'max_solo_seats': 0,
      }).select().single();

      debugPrint('✅ [GroupService.createGroup] Group inserted: $groupRow');
      final createdGroup = GroupData.fromJson(groupRow);

      // 2. Insert the creator as 'leader' in group_members
      debugPrint('⏳ [GroupService.createGroup] Inserting leader into `group_members`...');
      final memberRow = await _supabase.from('group_members').insert({
        'group_id': createdGroup.id,
        'user_id': effectiveLeaderId,
        'role': 'leader',
      }).select();

      debugPrint('✅ [GroupService.createGroup] Leader added to group_members: $memberRow');
      return createdGroup;
    } catch (e, stack) {
      debugPrint('❌ [GroupService.createGroup] Error: $e\nStack: $stack');
      return null;
    }
  }

  /// 2. Search for a registered user by email in `user_profiles` (typed)
  Future<UserProfileBasic?> searchUserByEmail(String email) async {
    final raw = await findUserByEmail(email);
    if (raw == null) return null;
    return UserProfileBasic.fromJson(raw);
  }

  /// Look up user by email (returns Map for backward compatibility)
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    debugPrint('🔍 [GroupService.findUserByEmail] Searching for email: "$cleanEmail"');
    if (cleanEmail.isEmpty) return null;

    try {
      debugPrint('⏳ [GroupService.findUserByEmail] Querying `user_profiles` table...');
      final data = await _supabase
          .from('user_profiles')
          .select('id, full_name, email')
          .ilike('email', cleanEmail)
          .maybeSingle();

      if (data != null) {
        debugPrint('✅ [GroupService.findUserByEmail] Found in `user_profiles`: $data');
        return Map<String, dynamic>.from(data);
      }
      debugPrint('⚠️ [GroupService.findUserByEmail] Not found in `user_profiles` for "$cleanEmail"');

      // Try RPC if defined
      try {
        final rpcResult = await _supabase.rpc(
          'get_user_id_by_email',
          params: {'lookup_email': cleanEmail},
        );
        if (rpcResult is List && rpcResult.isNotEmpty) {
          debugPrint('✅ [GroupService.findUserByEmail] Found via RPC: ${rpcResult.first}');
          return Map<String, dynamic>.from(rpcResult.first);
        }
      } catch (rpcErr) {
        debugPrint('⚠️ [GroupService.findUserByEmail] RPC lookup notice: $rpcErr');
      }

      debugPrint('❌ [GroupService.findUserByEmail] No user found with email "$cleanEmail"');
      return null;
    } catch (e) {
      debugPrint('❌ [GroupService.findUserByEmail] Error: $e');
      return null;
    }
  }

  /// 3. Send invite to invitee
  Future<bool> sendInvite({
    required String groupId,
    required String userId,
    String? groupName,
    String? inviterName,
  }) async {
    final inviterId = currentUserId;
    debugPrint('💌 [GroupService.sendInvite] Starting: groupId=$groupId, inviterId=$inviterId, inviteeId=$userId');

    if (inviterId == null) {
      debugPrint('❌ [GroupService.sendInvite] User must be logged in to send invitations.');
      return false;
    }

    try {
      // 1. Resolve group name
      String resolvedGroupName = groupName ?? '';
      if (resolvedGroupName.isEmpty) {
        try {
          final g = await _supabase.from('groups').select('name').eq('id', groupId).maybeSingle();
          if (g != null && g['name'] != null) resolvedGroupName = g['name'];
        } catch (_) {}
      }

      // 2. Resolve inviter name
      String resolvedInviterName = inviterName ?? '';
      if (resolvedInviterName.isEmpty) {
        try {
          final p = await _supabase.from('user_profiles').select('full_name').eq('id', inviterId).maybeSingle();
          if (p != null && p['full_name'] != null) resolvedInviterName = p['full_name'];
        } catch (_) {}
      }

      // 3. Check if user is already in the group
      debugPrint('⏳ [GroupService.sendInvite] Checking existing membership in group_members...');
      final existingMember = await _supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        debugPrint('⚠️ [GroupService.sendInvite] Invitee is already a member of this group.');
        throw Exception('User is already a member of this group.');
      }

      // 4. Check if there is already a pending invite in group_invitations
      debugPrint('⏳ [GroupService.sendInvite] Checking existing pending invites in group_invitations...');
      final existingInvite = await _supabase
          .from('group_invitations')
          .select('id, status')
          .eq('group_id', groupId)
          .eq('invitee_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingInvite != null) {
        debugPrint('⚠️ [GroupService.sendInvite] An active pending invite already exists: $existingInvite');
        throw Exception('An active invitation has already been sent to this user.');
      }

      // 5. Insert into group_invitations with group_name and inviter_name
      debugPrint('⏳ [GroupService.sendInvite] Inserting into `group_invitations` table...');
      try {
        final insertResult = await _supabase.from('group_invitations').insert({
          'group_id': groupId,
          'inviter_id': inviterId,
          'invitee_id': userId,
          'status': 'pending',
          'group_name': resolvedGroupName.isNotEmpty ? resolvedGroupName : 'Travel Squad',
          'inviter_name': resolvedInviterName.isNotEmpty ? resolvedInviterName : 'Group Leader',
        }).select();
        debugPrint('✅ [GroupService.sendInvite] Invitation inserted successfully with group_name: $insertResult');
      } catch (insertErr) {
        debugPrint('Notice: group_name column might not exist yet, trying standard insert: $insertErr');
        final insertResult = await _supabase.from('group_invitations').insert({
          'group_id': groupId,
          'inviter_id': inviterId,
          'invitee_id': userId,
          'status': 'pending',
        }).select();
        debugPrint('✅ [GroupService.sendInvite] Standard invitation inserted: $insertResult');
      }

      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ [GroupService.sendInvite] PostgrestException: code=${e.code}, msg=${e.message}, details=${e.details}, hint=${e.hint}');
      if (e.code == '23505') {
        throw Exception('Invitation already exists for this user.');
      }
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [GroupService.sendInvite] General error: $e\nStack: $stack');
      rethrow;
    }
  }

  /// 4. Respond to invite ('accepted' or 'rejected')
  Future<bool> respondToInvite({
    required String inviteId,
    required String groupId,
    required String status,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User must be logged in to respond to invites.');
    }

    try {
      // Update group_invitations status
      await _supabase
          .from('group_invitations')
          .update({'status': status})
          .eq('id', inviteId);

      // If accepted, add member to group_members
      if (status.toLowerCase() == 'accepted') {
        await _supabase.from('group_members').upsert({
          'group_id': groupId,
          'user_id': userId,
          'role': 'member',
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error in respondToInvite: $e');
      rethrow;
    }
  }

  /// Accept invite (join_requests or group_invitations)
  Future<bool> acceptInvite(String requestId, String groupId, String userId) async {
    try {
      try {
        await _supabase.from('group_invitations')
            .update({'status': 'accepted'})
            .eq('id', requestId);
      } catch (_) {
        await _supabase.from('join_requests')
            .update({'status': 'accepted'})
            .eq('id', requestId);
      }

      await _supabase.from('group_members').upsert({
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
      try {
        await _supabase.from('group_invitations')
            .update({'status': 'rejected'})
            .eq('id', requestId);
      } catch (_) {
        await _supabase.from('join_requests')
            .update({'status': 'declined'})
            .eq('id', requestId);
      }
      return true;
    } catch (e) {
      debugPrint('declineInvite error: $e');
      return false;
    }
  }

  /// 5. Update group name
  Future<bool> updateGroupName(String groupId, String newName) async {
    try {
      await _supabase
          .from('groups')
          .update({'name': newName.trim()})
          .eq('id', groupId);
      return true;
    } catch (e) {
      debugPrint('Error in updateGroupName: $e');
      return false;
    }
  }

  /// 6. Remove member from group (leader action or member leaving)
  Future<bool> removeMember(String groupId, String userId) async {
    try {
      await _supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('Error in removeMember: $e');
      return false;
    }
  }

  /// Member leaves group (leaders cannot leave)
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

      return await removeMember(groupId, userId);
    } catch (e) {
      debugPrint('leaveGroup error: $e');
      return false;
    }
  }

  /// Solo traveler asks to join an open squad
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

  /// Join a community
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

  /// Get all groups the user belongs to (for group_picker_sheet.dart)
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

  /// Get pending invites for user (returns List<Map<String, dynamic>> for pending_invites_screen.dart)
  Future<List<Map<String, dynamic>>> getPendingInvites(String userId) async {
    try {
      final invites = await _supabase
          .from('group_invitations')
          .select('id, group_id, inviter_id, status, created_at, groups(id, name, leader_id)')
          .eq('invitee_id', userId)
          .eq('status', 'pending');

      return List<Map<String, dynamic>>.from(invites);
    } catch (e) {
      try {
        final legacyInvites = await _supabase
            .from('join_requests')
            .select('id, group_id, status, pitch_message, created_at, groups(id, name, leader_id)')
            .eq('solo_user_id', userId)
            .eq('status', 'pending');
        return List<Map<String, dynamic>>.from(legacyInvites);
      } catch (_) {
        return [];
      }
    }
  }

  /// Get pending invites sent from a group (for leader view in group_detail_screen.dart)
  Future<List<Map<String, dynamic>>> getGroupPendingInvites(String groupId) async {
    try {
      final invites = await _supabase
          .from('group_invitations')
          .select('id, invitee_id, status, created_at')
          .eq('group_id', groupId)
          .eq('status', 'pending');

      final inviteList = List<Map<String, dynamic>>.from(invites);
      for (var i = 0; i < inviteList.length; i++) {
        try {
          final uId = inviteList[i]['invitee_id'];
          final p = await _supabase.from('user_profiles').select('full_name, email').eq('id', uId).maybeSingle();
          if (p != null) {
            inviteList[i]['email'] = p['email'] ?? '';
            inviteList[i]['name'] = p['full_name'] ?? '';
          }
        } catch (_) {}
      }
      return inviteList;
    } catch (e) {
      return [];
    }
  }

  /// Helper: Cancel or delete an invitation (inviter action)
  Future<bool> cancelInvite(String inviteId) async {
    try {
      debugPrint('🗑️ [GroupService.cancelInvite] Deleting inviteId: $inviteId');
      await _supabase.from('group_invitations').delete().eq('id', inviteId);
      return true;
    } catch (e) {
      debugPrint('❌ [GroupService.cancelInvite] Error: $e');
      return false;
    }
  }

  /// Helper: Get all pending invites for current user (both received and sent)
  Future<List<GroupInvitationItem>> getPendingInvitesForCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) {
      debugPrint('⚠️ [GroupService.getPendingInvites] currentUserId is null (not logged in)');
      return [];
    }

    try {
      debugPrint('📩 [GroupService.getPendingInvites] Querying group_invitations for user: $userId (as invitee or inviter)');
      final invitesData = await _supabase
          .from('group_invitations')
          .select('*')
          .or('invitee_id.eq.$userId,inviter_id.eq.$userId')
          .ilike('status', 'pending')
          .order('created_at', ascending: false);

      debugPrint('📩 [GroupService.getPendingInvites] Raw response rows (${(invitesData as List).length}): $invitesData');

      final List<GroupInvitationItem> result = [];
      for (final raw in (invitesData as List)) {
        final inv = Map<String, dynamic>.from(raw as Map);
        final gId = inv['group_id']?.toString() ?? '';
        final inviterId = inv['inviter_id']?.toString() ?? '';
        final inviteeId = inv['invitee_id']?.toString() ?? '';

        String groupName = inv['group_name']?.toString() ?? '';
        String inviterName = inv['inviter_name']?.toString() ?? '';
        String inviteeName = inv['invitee_name']?.toString() ?? '';
        String inviteeEmail = inv['invitee_email']?.toString() ?? '';

        // Resolve group name if missing
        if (groupName.isEmpty && gId.isNotEmpty) {
          try {
            final g = await _supabase.from('groups').select('name').eq('id', gId).maybeSingle();
            if (g != null && g['name'] != null) groupName = g['name'].toString();
          } catch (_) {}
        }

        // Resolve inviter name if missing
        if (inviterName.isEmpty && inviterId.isNotEmpty) {
          try {
            final p = await _supabase.from('user_profiles').select('full_name, email').eq('id', inviterId).maybeSingle();
            if (p != null) {
              inviterName = p['full_name']?.toString() ?? p['email']?.toString() ?? '';
            }
          } catch (_) {}
        }

        // Resolve invitee name / email if missing
        if ((inviteeName.isEmpty || inviteeEmail.isEmpty) && inviteeId.isNotEmpty) {
          try {
            final p = await _supabase.from('user_profiles').select('full_name, email').eq('id', inviteeId).maybeSingle();
            if (p != null) {
              if (inviteeName.isEmpty) inviteeName = p['full_name']?.toString() ?? '';
              if (inviteeEmail.isEmpty) inviteeEmail = p['email']?.toString() ?? '';
            }
          } catch (_) {}
        }

        result.add(GroupInvitationItem(
          id: inv['id']?.toString() ?? '',
          groupId: gId,
          groupName: groupName.isNotEmpty ? groupName : 'Travel Squad',
          inviterId: inviterId,
          inviterName: inviterName.isNotEmpty ? inviterName : 'Travel Leader',
          inviteeId: inviteeId,
          inviteeName: inviteeName.isNotEmpty ? inviteeName : (inviteeEmail.isNotEmpty ? inviteeEmail : 'Invited Member'),
          inviteeEmail: inviteeEmail,
          status: inv['status']?.toString() ?? 'pending',
          createdAt: inv['created_at'] != null ? DateTime.tryParse(inv['created_at'].toString()) : null,
        ));
      }

      debugPrint('✅ [GroupService.getPendingInvites] Successfully returned ${result.length} pending invites for user: $userId');
      return result;
    } catch (e, stack) {
      debugPrint('❌ [GroupService.getPendingInvites] Error: $e\n$stack');
      return [];
    }
  }

  /// Helper: Fetch group details by ID
  Future<GroupData?> getGroupDetails(String groupId) async {
    try {
      final data = await _supabase
          .from('groups')
          .select()
          .eq('id', groupId)
          .maybeSingle();

      if (data == null) return null;
      return GroupData.fromJson(data);
    } catch (e) {
      debugPrint('Error in getGroupDetails: $e');
      return null;
    }
  }

  /// Get members of a group as raw Maps (for group_detail_screen.dart)
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final members = await _supabase
          .from('group_members')
          .select('user_id, role, joined_at')
          .eq('group_id', groupId);

      final memberList = List<Map<String, dynamic>>.from(members);
      for (var i = 0; i < memberList.length; i++) {
        try {
          final uId = memberList[i]['user_id'];
          final p = await _supabase.from('user_profiles').select('full_name, email').eq('id', uId).maybeSingle();
          if (p != null) {
            memberList[i]['full_name'] = p['full_name'] ?? '';
            memberList[i]['email'] = p['email'] ?? '';
            memberList[i]['profiles'] = p;
          }
        } catch (_) {}
      }
      return memberList;
    } catch (e) {
      debugPrint('getGroupMembers error: $e');
      return [];
    }
  }

  /// Helper: Fetch all members of a group as typed `GroupMemberItem`s
  Future<List<GroupMemberItem>> getGroupMemberItems(String groupId) async {
    final rawMembers = await getGroupMembers(groupId);
    return rawMembers.map((m) => GroupMemberItem.fromJson(m)).toList();
  }
}

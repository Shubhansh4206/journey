import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_models.dart';
import '../services/group_service.dart';

class GroupController extends GetxController {
  static GroupController get to => Get.find<GroupController>();

  final GroupService _groupService = GroupService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Reactive state
  final RxList<GroupCardData> myGroups = <GroupCardData>[].obs;
  final Rxn<GroupData> activeGroup = Rxn<GroupData>();
  final RxBool isLoading = false.obs;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    fetchUserGroups();
  }

  Future<void> fetchUserGroups() async {
    final userId = currentUserId;
    if (userId == null) {
      myGroups.clear();
      activeGroup.value = null;
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('👥 [GroupController.fetchUserGroups] Fetching groups for user: $userId');

      // Fetch group memberships with nested group data
      final memberships = await _supabase
          .from('group_members')
          .select('''
            group_id,
            role,
            groups (
              id,
              name,
              leader_id,
              created_at
            )
          ''')
          .eq('user_id', userId);

      final List<GroupCardData> fetched = [];

      for (final m in (memberships as List)) {
        final gMap = m['groups'] as Map<String, dynamic>?;
        if (gMap == null) continue;

        final group = GroupData.fromJson(gMap);
        final role = m['role'] as String? ?? 'member';

        // Fetch members for this group to show avatars & count
        final memberItems = await _groupService.getGroupMemberItems(group.id);

        fetched.add(GroupCardData(
          group: group,
          role: role,
          members: memberItems,
        ));
      }

      myGroups.assignAll(fetched);
      debugPrint('✅ [GroupController.fetchUserGroups] Loaded ${myGroups.length} groups');

      // If no active group is selected, select the first group or keep current
      if (activeGroup.value == null && myGroups.isNotEmpty) {
        activeGroup.value = myGroups.first.group;
      } else if (activeGroup.value != null) {
        // Refresh active group data if it exists in list
        final match = myGroups.firstWhereOrNull((g) => g.group.id == activeGroup.value!.id);
        if (match != null) {
          activeGroup.value = match.group;
        } else if (myGroups.isNotEmpty) {
          activeGroup.value = myGroups.first.group;
        } else {
          activeGroup.value = null;
        }
      }
    } catch (e) {
      debugPrint('❌ [GroupController.fetchUserGroups] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectActiveGroup(GroupData group) {
    activeGroup.value = group;
  }

  void clearActiveGroup() {
    activeGroup.value = null;
  }
}

class GroupCardData {
  final GroupData group;
  final String role;
  final List<GroupMemberItem> members;

  GroupCardData({
    required this.group,
    required this.role,
    required this.members,
  });

  bool get isLeader => role.toLowerCase() == 'leader';
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_models.dart';
import '../screens/group_picker_sheet.dart';
import '../services/group_service.dart';

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();

  // Reactive state
  final RxList<Map<String, dynamic>> userGroups = <Map<String, dynamic>>[].obs;
  final Rxn<SelectedGroup> selectedGroup = Rxn<SelectedGroup>();
  final RxInt pendingInvitesCount = 0.obs;
  final RxBool isLoading = false.obs;

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchUserGroups(),
      fetchPendingInvitesCount(),
    ]);
  }

  Future<void> fetchUserGroups() async {
    final userId = currentUserId;
    if (userId == null) {
      userGroups.clear();
      return;
    }

    try {
      isLoading.value = true;
      final groups = await _groupService.getUserGroupsWithMembers(userId);
      userGroups.assignAll(groups);

      // Auto-select first group if none selected and groups exist
      if (selectedGroup.value == null && groups.isNotEmpty) {
        final first = groups.first;
        final nested = first['groups'] as Map<String, dynamic>?;
        final gId = first['group_id'] as String? ?? nested?['id'] as String? ?? '';
        final gName = nested?['name'] as String? ?? 'Squad';
        final role = first['role'] as String? ?? 'member';

        if (gId.isNotEmpty) {
          selectedGroup.value = SelectedGroup(id: gId, name: gName, role: role);
        }
      } else if (selectedGroup.value != null) {
        // Keep selected group updated if name changed
        final match = groups.firstWhereOrNull((g) {
          final nested = g['groups'] as Map<String, dynamic>?;
          final id = g['group_id'] ?? nested?['id'];
          return id == selectedGroup.value!.id;
        });

        if (match != null) {
          final nested = match['groups'] as Map<String, dynamic>?;
          final gName = nested?['name'] as String? ?? selectedGroup.value!.name;
          selectedGroup.value = SelectedGroup(
            id: selectedGroup.value!.id,
            name: gName,
            role: selectedGroup.value!.role,
          );
        }
      }
    } catch (e) {
      debugPrint('GroupController.fetchUserGroups error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingInvitesCount() async {
    try {
      final invites = await _groupService.getPendingInvitesForCurrentUser();
      pendingInvitesCount.value = invites.length;
    } catch (e) {
      debugPrint('GroupController.fetchPendingInvitesCount error: $e');
    }
  }

  void selectGroup(SelectedGroup? group) {
    selectedGroup.value = group;
  }

  List<GroupMemberItem> getMembersForGroup(String groupId) {
    final match = userGroups.firstWhereOrNull((g) {
      final nested = g['groups'] as Map<String, dynamic>?;
      final id = g['group_id'] ?? nested?['id'];
      return id == groupId;
    });

    if (match != null && match['members'] is List<GroupMemberItem>) {
      return match['members'] as List<GroupMemberItem>;
    }
    return [];
  }
}

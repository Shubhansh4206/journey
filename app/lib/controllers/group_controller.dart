import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_models.dart';
import '../models/trip_request.dart';
import '../screens/group_picker_sheet.dart';
import '../services/group_service.dart';
import '../services/trip_request_service.dart';

class GroupController extends GetxController {
  final GroupService _groupService = GroupService();
  final TripRequestService _tripRequestService = TripRequestService();

  // Reactive state
  final RxList<Map<String, dynamic>> userGroups = <Map<String, dynamic>>[].obs;
  final Rxn<SelectedGroup> selectedGroup = Rxn<SelectedGroup>();
  final RxInt pendingInvitesCount = 0.obs;
  final RxBool isLoading = false.obs;

  // Sent trip requests state
  final RxList<TripRequest> sentTripRequests = <TripRequest>[].obs;
  final RxBool isLoadingTripRequests = false.obs;

  RealtimeChannel? _realtimeChannel;
  StreamSubscription<AuthState>? _authSubscription;

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
    _setupRealtimeSubscription();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        refreshAll();
        _setupRealtimeSubscription();
      } else {
        _teardownRealtimeSubscription();
        userGroups.clear();
        selectedGroup.value = null;
        pendingInvitesCount.value = 0;
        sentTripRequests.clear();
      }
    });
  }

  void _setupRealtimeSubscription() {
    _teardownRealtimeSubscription();

    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client
          .channel('public:groups_and_invites_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group_invitations',
            callback: (payload) {
              debugPrint('⚡ [GroupController Realtime] group_invitations change: ${payload.eventType}');
              fetchPendingInvitesCount();
              fetchUserGroups();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group_members',
            callback: (payload) {
              debugPrint('⚡ [GroupController Realtime] group_members change: ${payload.eventType}');
              fetchUserGroups();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'groups',
            callback: (payload) {
              debugPrint('⚡ [GroupController Realtime] groups change: ${payload.eventType}');
              fetchUserGroups();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'trip_requests',
            callback: (payload) {
              debugPrint('⚡ [GroupController Realtime] trip_requests change: ${payload.eventType}');
              fetchSentTripRequests();
            },
          )
          .subscribe();
      debugPrint('🛰️ [GroupController] Subscribed to Supabase Realtime channel');
    } catch (e) {
      debugPrint('⚠️ [GroupController] Failed to setup realtime subscription: $e');
    }
  }

  void _teardownRealtimeSubscription() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _teardownRealtimeSubscription();
    super.onClose();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchUserGroups(),
      fetchPendingInvitesCount(),
      fetchSentTripRequests(),
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

  Future<void> fetchSentTripRequests() async {
    try {
      isLoadingTripRequests.value = true;
      final requests = await _tripRequestService.getUserTripRequests();
      sentTripRequests.assignAll(requests);
      debugPrint('📦 [GroupController] Fetched ${requests.length} sent trip requests');
    } catch (e) {
      debugPrint('GroupController.fetchSentTripRequests error: $e');
    } finally {
      isLoadingTripRequests.value = false;
    }
  }

  Future<bool> cancelTripRequest(String requestId) async {
    final success = await _tripRequestService.cancelTripRequest(requestId);
    if (success) {
      await fetchSentTripRequests();
    }
    return success;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/group_controller.dart';
import '../models/group_models.dart';
import '../screens/group_picker_sheet.dart';
import '../utils/colors.dart';

class SwiggyGroupRosterSheet extends StatelessWidget {
  const SwiggyGroupRosterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SwiggyGroupRosterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Travel Squads',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      'Select a squad to coordinate your itinerary',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/create-group').then((_) {
                      groupController.fetchUserGroups();
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFFFC8019)),
                  label: Text(
                    'New Squad',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFFFC8019),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Squad List
          Flexible(
            child: Obx(() {
              if (groupController.isLoading.value && groupController.userGroups.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (groupController.userGroups.isEmpty) {
                return _buildEmptyState(context, groupController);
              }

              return RefreshIndicator(
                onRefresh: () async => groupController.fetchUserGroups(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: groupController.userGroups.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final membership = groupController.userGroups[index];
                    final nested = membership['groups'] as Map<String, dynamic>?;
                    final groupId = membership['group_id'] as String? ?? nested?['id'] as String? ?? '';
                    final groupName = nested?['name'] as String? ?? 'Travel Squad';
                    final role = membership['role'] as String? ?? 'member';
                    final isLeader = role.toLowerCase() == 'leader';
                    final members = (membership['members'] as List<GroupMemberItem>?) ?? [];
                    final isSelected = groupController.selectedGroup.value?.id == groupId;

                    return _buildSquadCard(
                      context,
                      groupId: groupId,
                      groupName: groupName,
                      role: role,
                      isLeader: isLeader,
                      members: members,
                      isSelected: isSelected,
                      onSelect: () {
                        groupController.selectGroup(
                          SelectedGroup(id: groupId, name: groupName, role: role),
                        );
                        Navigator.pop(context);
                      },
                      onManage: () {
                        Navigator.pop(context);
                        context.push('/group/$groupId').then((_) {
                          groupController.fetchUserGroups();
                        });
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GroupController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFC8019).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_3_rounded,
              color: Color(0xFFFC8019),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Squads Formed Yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a group to invite friends and plan your trip together!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/create-group').then((_) {
                controller.fetchUserGroups();
              });
            },
            icon: const Icon(Icons.group_add_rounded, size: 18),
            label: const Text('Create a Squad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8019),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadCard(
    BuildContext context, {
    required String groupId,
    required String groupName,
    required String role,
    required bool isLeader,
    required List<GroupMemberItem> members,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onManage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFFC8019) : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Squad name & active badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        groupName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLeader ? Colors.amber.shade100 : Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isLeader ? 'Leader' : 'Member',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLeader ? Colors.amber.shade900 : Colors.indigo.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC8019),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          'Active',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Joined Members Row (Who has joined)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${members.length} Member${members.length == 1 ? '' : 's'} joined:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Member Avatars & Names preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: members.isEmpty
                ? Text(
                    'No other members joined yet',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: members.map((m) {
                      final initial = m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : 'M';
                      return Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        avatar: CircleAvatar(
                          radius: 10,
                          backgroundColor: m.isLeader ? Colors.amber.shade200 : Colors.indigo.shade100,
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: m.isLeader ? Colors.amber.shade900 : Colors.indigo.shade800,
                            ),
                          ),
                        ),
                        label: Text(
                          m.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),

          // Card Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFEEDD6) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Manage & Invite',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.grey.shade800 : const Color(0xFFFC8019),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Select Squad',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

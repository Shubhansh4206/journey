import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/group_controller.dart';
import '../models/group_models.dart';
import '../utils/colors.dart';

/// Swiggy-style bottom sheet for switching active group or managing squads
class SwiggyGroupSheet extends StatelessWidget {
  const SwiggyGroupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SwiggyGroupSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupController = Get.isRegistered<GroupController>()
        ? Get.find<GroupController>()
        : Get.put(GroupController());

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      'Select squad for custom itinerary planning',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.indigo),
                  label: const Text(
                    'New Squad',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // List of Squads
          Expanded(
            child: Obx(() {
              if (groupController.isLoading.value && groupController.myGroups.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (groupController.myGroups.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.groups_rounded, size: 40, color: Colors.indigo),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Groups Joined Yet',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a squad to plan trips with friends and split costs!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/create-group').then((_) {
                              groupController.fetchUserGroups();
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Create Your First Squad'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => groupController.fetchUserGroups(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupController.myGroups.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = groupController.myGroups[index];
                    final isActive = groupController.activeGroup.value?.id == item.group.id;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        groupController.selectActiveGroup(item.group);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.indigo.shade50.withValues(alpha: 0.6) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? Colors.indigo : Colors.grey.shade200,
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isActive ? Colors.indigo : Colors.indigo.shade100,
                                  child: Icon(
                                    Icons.groups_rounded,
                                    color: isActive ? Colors.white : Colors.indigo.shade800,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.group.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkCharcoal,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (item.isLeader)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade100,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Leader',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.members.length} member${item.members.length == 1 ? '' : 's'} joined',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isActive)
                                  const Icon(Icons.check_circle_rounded, color: Colors.indigo, size: 22)
                                else
                                  const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 22),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Member Avatars & Manage Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMemberAvatars(item.members),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.push('/group/${item.group.id}').then((_) {
                                      groupController.fetchUserGroups();
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: Colors.indigo,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Manage Roster',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 11),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMemberAvatars(List<GroupMemberItem> members) {
    const maxVisible = 4;
    final visibleCount = members.length > maxVisible ? maxVisible : members.length;
    final extraCount = members.length - maxVisible;

    return Row(
      children: [
        SizedBox(
          height: 28,
          width: visibleCount * 20.0 + (extraCount > 0 ? 28 : 8),
          child: Stack(
            children: [
              for (int i = 0; i < visibleCount; i++)
                Positioned(
                  left: i * 18.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.indigo.shade200,
                      child: Text(
                        members[i].fullName.isNotEmpty ? members[i].fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
              if (extraCount > 0)
                Positioned(
                  left: visibleCount * 18.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        '+$extraCount',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

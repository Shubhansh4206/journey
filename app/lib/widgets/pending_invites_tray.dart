import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/group_controller.dart';
import '../models/group_models.dart';
import '../services/group_service.dart';

enum InviteTabFilter { all, received, sent }

/// A self-contained, drop-in tray widget for displaying and responding to pending group invitations.
class PendingInvitesTray extends StatefulWidget {
  final VoidCallback? onInvitesChanged;
  final Function(GroupInvitationItem invite)? onInviteAccepted;
  final Function(GroupInvitationItem invite)? onInviteRejected;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PendingInvitesTray({
    super.key,
    this.onInvitesChanged,
    this.onInviteAccepted,
    this.onInviteRejected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PendingInvitesTray> createState() => _PendingInvitesTrayState();
}

class _PendingInvitesTrayState extends State<PendingInvitesTray> {
  final GroupService _groupService = GroupService();
  late Future<List<GroupInvitationItem>> _invitesFuture;
  final Set<String> _processingIds = {};
  InviteTabFilter _currentFilter = InviteTabFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  void _fetchInvites() {
    setState(() {
      _invitesFuture = _groupService.getPendingInvitesForCurrentUser();
    });
  }

  Future<void> _handleResponse({
    required GroupInvitationItem invite,
    required bool accept,
  }) async {
    setState(() {
      _processingIds.add(invite.id);
    });

    final status = accept ? 'accepted' : 'rejected';
    try {
      await _groupService.respondToInvite(
        inviteId: invite.id,
        groupId: invite.groupId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? 'Joined ${invite.groupName} successfully!'
                  : 'Declined invitation to ${invite.groupName}.',
            ),
            backgroundColor: accept ? Colors.green.shade700 : Colors.blueGrey.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (accept) {
          try {
            if (Get.isRegistered<GroupController>()) {
              Get.find<GroupController>().fetchUserGroups();
            }
          } catch (_) {}
          widget.onInviteAccepted?.call(invite);
        } else {
          widget.onInviteRejected?.call(invite);
        }
        widget.onInvitesChanged?.call();
      }

      _fetchInvites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update invite: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(invite.id);
        });
      }
    }
  }

  Future<void> _handleCancelInvite(GroupInvitationItem invite) async {
    setState(() {
      _processingIds.add(invite.id);
    });

    try {
      final success = await _groupService.cancelInvite(invite.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cancelled invitation to ${invite.inviteeName.isNotEmpty ? invite.inviteeName : "user"}.'),
              backgroundColor: Colors.blueGrey.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onInvitesChanged?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel invitation.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      _fetchInvites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(invite.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _groupService.currentUserId ?? Supabase.instance.client.auth.currentUser?.id;

    return FutureBuilder<List<GroupInvitationItem>>(
      future: _invitesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load invitations',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _fetchInvites,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final allInvites = snapshot.data ?? [];
        final receivedInvites = allInvites.where((i) => !i.isOutgoing(currentUserId)).toList();
        final sentInvites = allInvites.where((i) => i.isOutgoing(currentUserId)).toList();

        List<GroupInvitationItem> displayedInvites;
        if (_currentFilter == InviteTabFilter.received) {
          displayedInvites = receivedInvites;
        } else if (_currentFilter == InviteTabFilter.sent) {
          displayedInvites = sentInvites;
        } else {
          displayedInvites = allInvites;
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchInvites(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter tabs if there are both received and sent
              if (allInvites.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All (${allInvites.length})',
                        filter: InviteTabFilter.all,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Received (${receivedInvites.length})',
                        filter: InviteTabFilter.received,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Sent (${sentInvites.length})',
                        filter: InviteTabFilter.sent,
                      ),
                    ],
                  ),
                ),

              if (displayedInvites.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mail_outline_rounded, size: 36, color: Colors.indigo),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentFilter == InviteTabFilter.received
                                ? 'No Received Invitations'
                                : _currentFilter == InviteTabFilter.sent
                                    ? 'No Sent Invitations'
                                    : 'No Pending Invitations',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When a leader invites you or you invite someone, requests appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _fetchInvites,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: widget.padding,
                    shrinkWrap: widget.shrinkWrap,
                    physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
                    itemCount: displayedInvites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final invite = displayedInvites[index];
                      final isProcessing = _processingIds.contains(invite.id);
                      final isOutgoing = invite.isOutgoing(currentUserId);
                      final isIncoming = !isOutgoing;

                      debugPrint('📨 [PendingInvitesTray] item: "${invite.groupName}" | inviter: "${invite.inviterName}" (${invite.inviterId}) | invitee: "${invite.inviteeName}" (${invite.inviteeId}) | currentUserId: "$currentUserId" | isIncoming: $isIncoming, isOutgoing: $isOutgoing');

                      return _buildInviteCard(
                        invite: invite,
                        isIncoming: isIncoming,
                        isProcessing: isProcessing,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required InviteTabFilter filter,
  }) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _currentFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCard({
    required GroupInvitationItem invite,
    required bool isIncoming,
    required bool isProcessing,
  }) {
    final avatarName = isIncoming ? invite.inviterName : invite.inviteeName;
    final initial = avatarName.isNotEmpty ? avatarName[0].toUpperCase() : 'U';

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isIncoming ? Colors.indigo.shade100 : Colors.amber.shade100,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isIncoming ? Colors.indigo.shade800 : Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isIncoming)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sent by you · Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            height: 1.35,
                          ),
                          children: isIncoming
                              ? [
                                  TextSpan(
                                    text: invite.inviterName.isNotEmpty ? invite.inviterName : 'A leader',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: ' invited you to join '),
                                  TextSpan(
                                    text: invite.groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ]
                              : [
                                  const TextSpan(text: 'You invited '),
                                  TextSpan(
                                    text: invite.inviteeName.isNotEmpty ? invite.inviteeName : (invite.inviteeEmail.isNotEmpty ? invite.inviteeEmail : 'a member'),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: ' to join '),
                                  TextSpan(
                                    text: invite.groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                      if (invite.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(invite.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isProcessing)
              const Center(
                child: SizedBox(
                  height: 36,
                  width: 36,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              )
            else if (isIncoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleResponse(invite: invite, accept: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(invite: invite, accept: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _handleCancelInvite(invite),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel Invite'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

import 'package:flutter/material.dart';
import '../models/group_models.dart';
import '../services/group_service.dart';

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
          widget.onInviteAccepted?.call(invite);
        } else {
          widget.onInviteRejected?.call(invite);
        }
        widget.onInvitesChanged?.call();
      }

      // Refresh list after processing
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

  @override
  Widget build(BuildContext context) {
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

        final invites = snapshot.data ?? [];

        if (invites.isEmpty) {
          return Center(
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
                  const Text(
                    'No Pending Invitations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'When a group leader invites you to travel, it will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchInvites(),
          child: ListView.separated(
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
            itemCount: invites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final invite = invites[index];
              final isProcessing = _processingIds.contains(invite.id);

              return _buildInviteCard(invite, isProcessing);
            },
          ),
        );
      },
    );
  }

  Widget _buildInviteCard(GroupInvitationItem invite, bool isProcessing) {
    final inviterInitial = invite.inviterName.isNotEmpty
        ? invite.inviterName[0].toUpperCase()
        : 'G';

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
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    inviterInitial,
                    style: TextStyle(
                      color: Colors.indigo.shade800,
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
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: invite.inviterName,
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
            else
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

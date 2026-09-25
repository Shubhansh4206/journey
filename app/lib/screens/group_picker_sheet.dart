import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/group_service.dart';
import '../utils/colors.dart';

class SelectedGroup {
  final String id;
  final String name;
  final String role;

  const SelectedGroup({
    required this.id,
    required this.name,
    required this.role,
  });
}

class GroupPickerSheet extends StatefulWidget {
  const GroupPickerSheet({super.key});

  @override
  State<GroupPickerSheet> createState() => _GroupPickerSheetState();
}

class _GroupPickerSheetState extends State<GroupPickerSheet> {
  final GroupService _groupService = GroupService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();

  List<Map<String, dynamic>> _groups = [];
  bool _loading = true;
  bool _showCreate = false;
  bool _creating = false;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) {
      setState(() {
        _groups = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final groups = await _groupService.getUserGroups(userId);
    if (mounted) {
      setState(() {
        _groups = groups;
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _groupMap(Map<String, dynamic> membership) {
    final nested = membership['groups'];
    if (nested is Map<String, dynamic>) return nested;
    return null;
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    final userId = _userId;
    if (name.isEmpty || userId == null) return;

    setState(() => _creating = true);
    final group = await _groupService.createGroup(name: name, leaderId: userId);

    final email = _emailController.text.trim().toLowerCase();
    if (group != null && email.contains('@')) {
      final user = await _groupService.findUserByEmail(email);
      if (user != null) {
        await _groupService.sendInvite(groupId: group.id, userId: user['id']);
      }
    }

    setState(() => _creating = false);
    if (group == null) {
      _snack('Could not create group');
      return;
    }

    _nameController.clear();
    _emailController.clear();
    setState(() => _showCreate = false);
    if (mounted) {
      Navigator.pop(
        context,
        SelectedGroup(id: group.id, name: group.name, role: 'leader'),
      );
    }
  }

  Future<void> _rename(String groupId, String currentName) async {
    _renameController.text = currentName;
    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename group', style: GoogleFonts.poppins()),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _renameController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (next == null || next.isEmpty) return;
    final ok = await _groupService.updateGroupName(groupId, next);
    if (ok) {
      _snack('Group renamed', success: true);
      _load();
    } else {
      _snack('Could not rename group');
    }
  }

  Future<void> _leave(String groupId) async {
    final userId = _userId;
    if (userId == null) return;
    final ok = await _groupService.leaveGroup(groupId: groupId, userId: userId);
    if (ok) {
      _snack('Left group', success: true);
      _load();
    } else {
      _snack('Leaders cannot leave. Rename the group instead.');
    }
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.success : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.darkCharcoal),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Your groups',
            style: GoogleFonts.poppins(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      'Pick a group like an address. You must belong to one before submitting the trip.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _groups.isEmpty && !_showCreate
                        ? Center(
                            child: Text(
                              'No groups yet. Create one below.',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _groups.length,
                            itemBuilder: (context, index) {
                              final membership = _groups[index];
                              final group = _groupMap(membership);
                              final name = group?['name'] ?? 'Untitled group';
                              final id = (group?['id'] ??
                                      membership['group_id'])
                                  .toString();
                              final role = membership['role'] ?? 'member';
                              final isLeader = role == 'leader';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      SelectedGroup(
                                        id: id,
                                        name: name,
                                        role: role,
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.vibrantPurple
                                        .withValues(alpha: 0.15),
                                    child: const Icon(
                                      Icons.groups,
                                      color: AppColors.vibrantPurple,
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    isLeader
                                        ? 'You are the leader'
                                        : 'Member',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _rename(id, name);
                                      } else if (value == 'leave') {
                                        _leave(id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      if (isLeader)
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Rename'),
                                        ),
                                      if (!isLeader)
                                        const PopupMenuItem(
                                          value: 'leave',
                                          child: Text('Leave group'),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      16,
                      24,
                      16 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: _showCreate ? _createForm() : _createButton(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _createButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _showCreate = true),
        icon: const Icon(Icons.add),
        label: Text(
          'Make a group',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkCharcoal,
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _createForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New group',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Group name',
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Invite email (optional)',
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _showCreate = false),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _creating ? null : _createGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantPurple,
                foregroundColor: Colors.white,
              ),
              child: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Create & select',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

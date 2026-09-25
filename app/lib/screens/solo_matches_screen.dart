import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';
import '../models/solo_community.dart';
import '../services/group_service.dart';
import '../services/home_service.dart';
import '../utils/colors.dart';

class SoloMatchesScreen extends StatefulWidget {
  final TripCartDraft draft;

  const SoloMatchesScreen({super.key, required this.draft});

  @override
  State<SoloMatchesScreen> createState() => _SoloMatchesScreenState();
}

class _SoloMatchesScreenState extends State<SoloMatchesScreen> {
  final HomeService _homeService = HomeService();
  final GroupService _groupService = GroupService();

  late Future<_SoloMatchData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SoloMatchData> _load() async {
    final squads = await _homeService.getOpenSquads(
      destination: widget.draft.city.name,
      startDate: widget.draft.startDate,
      endDate: widget.draft.endDate,
    );
    final communities = await _homeService.getCommunities(
      destination: widget.draft.city.name,
      around: widget.draft.startDate,
    );
    return _SoloMatchData(squads: squads, communities: communities);
  }

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> _joinSquad(String groupId) async {
    final userId = _userId;
    if (userId == null) return;
    final ok = await _groupService.requestToJoinGroup(
      groupId: groupId,
      userId: userId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Join request sent' : 'Could not send request'),
        backgroundColor: ok ? AppColors.success : null,
      ),
    );
  }

  Future<void> _joinCommunity(String communityId) async {
    final userId = _userId;
    if (userId == null) return;
    final ok = await _groupService.joinCommunity(
      communityId: communityId,
      userId: userId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Joined community' : 'Could not join community'),
        backgroundColor: ok ? AppColors.success : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          'Matches in ${draft.city.name}',
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<_SoloMatchData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ??
              _SoloMatchData(squads: const [], communities: const []);

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text(
                'Open squads travelling around your dates. Join one or keep exploring.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Budget ₹${draft.budget.toStringAsFixed(0)} · ${draft.items.length} cart items',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Open squads',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (data.squads.isEmpty)
                _empty('No open squads for ${draft.city.name} yet.')
              else
                ...data.squads.map(_squadTile),
              const SizedBox(height: 24),
              Text(
                'Communities',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (data.communities.isEmpty)
                _empty('No communities for this destination / month.')
              else
                ...data.communities.map(_communityTile),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkCharcoal,
                    side: const BorderSide(color: AppColors.border, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Keep exploring',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _squadTile(Map<String, dynamic> squad) {
    final id = squad['id']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(
          squad['name'] ?? squad['destination'] ?? 'Squad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${squad['matchScore'] ?? ''} · ₹${(squad['maxBudget'] as num?)?.toStringAsFixed(0) ?? '-'} / pax',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: TextButton(
          onPressed: id.isEmpty ? null : () => _joinSquad(id),
          child: const Text('Join'),
        ),
      ),
    );
  }

  Widget _communityTile(Community community) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(
          community.destination,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Travel month: ${community.travelMonth}',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: TextButton(
          onPressed: () => _joinCommunity(community.id),
          child: const Text('Join'),
        ),
      ),
    );
  }
}

class _SoloMatchData {
  final List<Map<String, dynamic>> squads;
  final List<Community> communities;

  _SoloMatchData({required this.squads, required this.communities});
}

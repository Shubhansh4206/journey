import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_city_catalog.dart';
import '../models/ai_community_models.dart';
import '../services/ai_community_service.dart';
import '../utils/colors.dart';
import 'community/community_detail_screen.dart';
import 'community/community_chat_screen.dart';

class SoloMatchesScreen extends StatefulWidget {
  final TripCartDraft draft;

  const SoloMatchesScreen({super.key, required this.draft});

  @override
  State<SoloMatchesScreen> createState() => _SoloMatchesScreenState();
}

class _SoloMatchesScreenState extends State<SoloMatchesScreen> {
  final AiCommunityService _communityService = AiCommunityService();
  bool _isPosting = false;
  bool _hasPosted = false;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _postTripDraft() async {
    setState(() => _isPosting = true);
    await _communityService.saveTripPostIt(widget.draft);
    setState(() {
      _isPosting = false;
      _hasPosted = true;
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF7C3AED), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Trip Post-It Pinned!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ${widget.draft.city.name} trip draft is now recorded in the community pool.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.darkCharcoal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: Color(0xFF7C3AED), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Our AI Agent will aggregate solo travelers matching your dates and budget, form a master community, and send you an invitation.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: const Color(0xFF6D28D9),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Browsing',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // back to home
              context.go('/solo_comm'); // go to community tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View My Post-Its',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final cityName = draft.city.name.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          'Open Communities in ${draft.city.name}',
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<AiCommunity>>(
        valueListenable: _communityService.communitiesNotifier,
        builder: (context, allCommunities, _) {
          // Filter matching open communities for this destination
          final matchingCommunities = allCommunities.where((c) {
            return c.destination.toLowerCase() == cityName;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header Summary ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    color: Color(0xFF7C3AED), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'AI MATCH ENGINE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF7C3AED),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Budget: ₹${draft.budget.toStringAsFixed(0)} / pax',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFC8019),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join an active solo squad, bookmark to watch, or post your trip for AI clustering.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Case A: Open Communities Found ──────────────────────────────
              if (matchingCommunities.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comm = matchingCommunities[index];
                        return _buildCommunityMatchCard(comm);
                      },
                      childCount: matchingCommunities.length,
                    ),
                  ),
                ),

                // Post custom trip secondary banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: _buildPostTripSecondaryBanner(),
                  ),
                ),
              ]

              // ── Case B: No Communities Found -> Post Your Trip Prompt ──────
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildNoCommunitiesPostItPrompt(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Open Community Match Card ─────────────────────────────────────────────
  Widget _buildCommunityMatchCard(AiCommunity comm) {
    final isBookmarked = comm.myMembershipStatus == 'bookmarked';
    final isAccepted = comm.myMembershipStatus == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isAccepted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & AI Badge
          Stack(
            children: [
              SizedBox(
                height: 135,
                width: double.infinity,
                child: Image.network(
                  comm.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.electricBlue,
                    child: const Icon(Icons.landscape, size: 48, color: Colors.white),
                  ),
                ),
              ),
              Container(
                height: 135,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // AI Compatibility Score Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.amberAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${comm.myCompatibilityScore}% MATCH',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bookmark Button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked ? Colors.amber : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _communityService.toggleBookmark(comm.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'Removed from Bookmarks'
                                : '🔖 Bookmarked! Watching this community in Community tab.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Title & Dates
              Positioned(
                bottom: 10,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comm.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${_fmt(comm.startDate)} → ${_fmt(comm.endDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Itinerary Core Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 12, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Fixed Stay: ${comm.fixedHotel.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      '${comm.activityRoster.length} Activities (Opt-out capable)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Members & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ...comm.memberAvatars.take(3).map((url) {
                          return Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 9.5,
                                backgroundImage: NetworkImage(url),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${comm.memberCount} members · ${comm.maxMembers - comm.memberCount} spots left',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${comm.masterEstimatedBudget.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFC8019),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: View / Customise Itinerary & Join
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityDetailScreen(community: comm),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkCharcoal,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Itinerary',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isAccepted) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityChatScreen(community: comm),
                            ),
                          );
                        },
                        icon: const Icon(Icons.forum_rounded,
                            size: 14, color: Colors.white),
                        label: Text(
                          'CHAT',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () {
                          _communityService.respondToInvitation(comm.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Joined ${comm.title}! Chat & voting unlocked.',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFF60B246),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60B246),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'JOIN COMMUNITY',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── No Communities Found: Post Your Trip Prompt ───────────────────────────
  Widget _buildNoCommunitiesPostItPrompt() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.push_pin_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Communities for ${widget.draft.city.name} Yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first! Post your trip draft as a Post-It. Our backend AI Agent will cluster incoming solo travelers with compatible dates and budgets, form your community, and notify you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Post-It details preview card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dates: ${_fmt(widget.draft.startDate)} → ${_fmt(widget.draft.endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      'Cap: ₹${widget.draft.budget.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.draft.items.length} items in your desired itinerary',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Post Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isPosting || _hasPosted ? null : _postTripDraft,
              icon: _isPosting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              label: Text(
                _hasPosted
                    ? 'TRIP POST-IT RECORDED ✓'
                    : 'POST TRIP (LET AI AGENT BUILD COMMUNITY)',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasPosted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Secondary Post Trip Banner (When communities exist) ───────────────────
  Widget _buildPostTripSecondaryBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.push_pin_rounded,
                color: Color(0xFF7C3AED), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want a custom community?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  'Post your unique itinerary draft as a Post-It for AI clustering.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isPosting ? null : _postTripDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _hasPosted ? 'POSTED' : 'POST TRIP',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

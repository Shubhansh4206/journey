import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ai_community_models.dart';
import '../../services/ai_community_service.dart';
import '../../utils/colors.dart';
import 'community_detail_screen.dart';
import 'community_chat_screen.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  final AiCommunityService _communityService = AiCommunityService();
  String _activeTab = 'invitations'; // 'invitations', 'squads', 'bookmarked', 'post_its'

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Solo Communities',
              style: GoogleFonts.poppins(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Filter Segment Tabs ───────────────────────────────────────────
          _buildFilterTabs(),

          // ── Content Area ──────────────────────────────────────────────────
          Expanded(
            child: ValueListenableBuilder<List<AiCommunity>>(
              valueListenable: _communityService.communitiesNotifier,
              builder: (context, communities, _) {
                return ValueListenableBuilder<List<TripPostIt>>(
                  valueListenable: _communityService.postItsNotifier,
                  builder: (context, postIts, _) {
                    return _buildActiveContent(communities, postIts);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Segment Tabs Bar ──────────────────────────────────────────────────────
  Widget _buildFilterTabs() {
    final tabs = [
      {'id': 'invitations', 'label': 'Invitations', 'icon': Icons.mail_outline_rounded},
      {'id': 'squads', 'label': 'My Squads', 'icon': Icons.groups_rounded},
      {'id': 'bookmarked', 'label': 'Bookmarked', 'icon': Icons.bookmark_border_rounded},
      {'id': 'post_its', 'label': 'My Post-Its', 'icon': Icons.push_pin_outlined},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.map((t) {
            final isSelected = _activeTab == t['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _activeTab = t['id'] as String),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E2430)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        t['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t['label'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Main Content Switcher ─────────────────────────────────────────────────
  Widget _buildActiveContent(
    List<AiCommunity> communities,
    List<TripPostIt> postIts,
  ) {
    if (_activeTab == 'post_its') {
      return _buildPostItsList(postIts);
    }

    final filtered = communities.where((c) {
      if (_activeTab == 'invitations') {
        return c.myMembershipStatus == 'invited';
      } else if (_activeTab == 'squads') {
        return c.myMembershipStatus == 'accepted';
      } else if (_activeTab == 'bookmarked') {
        return c.myMembershipStatus == 'bookmarked';
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final comm = filtered[index];
        return _buildCommunityCard(comm);
      },
    );
  }

  // ── Community Invitation / Squad Card ─────────────────────────────────────
  Widget _buildCommunityCard(AiCommunity comm) {
    final isInvited = comm.myMembershipStatus == 'invited';
    final isAccepted = comm.myMembershipStatus == 'accepted';
    final isBookmarked = comm.myMembershipStatus == 'bookmarked';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInvited
              ? const Color(0xFFDDD6FE)
              : const Color(0xFFE2E8F0),
          width: isInvited ? 1.5 : 1,
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
                height: 140,
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
                height: 140,
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
                          letterSpacing: 0.5,
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
                    onPressed: () => _communityService.toggleBookmark(comm.id),
                  ),
                ),
              ),

              // Destination & Title
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
                        fontSize: 16,
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

          // Fixed Base Summary
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.lock_rounded, size: 13, color: Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Fixed Core: ${comm.fixedHotel.name} · ${comm.fixedTransport.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 13, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${comm.activityRoster.length} Activities with Opt-Out Support',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Members Avatar Stack & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ...comm.memberAvatars.take(4).map((url) {
                          return Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(url),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${comm.memberCount} solo travelers',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Est. Total',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '₹${comm.masterEstimatedBudget.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFC8019),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Row
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
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Review',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isInvited) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _communityService.respondToInvitation(comm.id, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 Accepted invitation to ${comm.title}!',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color(0xFF0F172A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'ACCEPT',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else if (isAccepted) ...[
                      Expanded(
                        child: ElevatedButton.icon(
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
                            'CHAT & VOTE',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
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

  // ── Post-Its Tab View ─────────────────────────────────────────────────────
  Widget _buildPostItsList(List<TripPostIt> postIts) {
    if (postIts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.push_pin_rounded,
                  size: 48, color: Color(0xFF8B5CF6)),
              const SizedBox(height: 12),
              Text(
                'No Solo Post-Its Yet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Build a solo itinerary draft and pin it as a Post-It. Our AI will automatically find matching solo travelers.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: postIts.length,
      itemBuilder: (context, index) {
        final post = postIts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Post-it yellow tint
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.push_pin_rounded,
                          color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${post.destination} Post-It Draft',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded,
                            size: 12, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 4),
                        Text(
                          'AI CLUSTERING...',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Dates: ${_fmt(post.startDate)} → ${_fmt(post.endDate)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Text(
                'Budget Cap: ₹${post.budgetPerPax.toStringAsFixed(0)} / person',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Desired items: ${post.desiredActivities.length} activities, ${post.desiredHotels.length} stays',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _activeTab == 'bookmarked'
                ? Icons.bookmark_border_rounded
                : Icons.auto_awesome_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            _activeTab == 'bookmarked'
                ? 'No Bookmarked Communities'
                : 'No Active Communities Here',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check other tabs or create a new Solo Post-It to get matched!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';
import 'package:guide_app/screens/package_details_screen.dart';
import 'package:guide_app/screens/tourist_chat_screen.dart';

class GuideDashboardScreen extends StatefulWidget {
  final GuideState guideState;
  final VoidCallback onLogout;

  const GuideDashboardScreen({
    super.key,
    required this.guideState,
    required this.onLogout,
  });

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  int _currentTabIndex = 0;

  void _showRejectDialog(TourPackage pkg) {
    String selectedReason = 'Schedule conflict with existing booking';
    final customReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppTheme.danger),
              SizedBox(width: 8),
              Text('Decline Package', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Decline "${pkg.title}"?',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please specify reason to assist our automated dispatch algorithm:',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildReasonOption(
                title: 'Schedule conflict on dates',
                value: 'Schedule conflict with existing booking',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonOption(
                title: 'Location outside my active zone',
                value: 'Route outside primary jurisdiction',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonOption(
                title: 'Group size exceeds capacity',
                value: 'Group size exceeds guide preference',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonOption(
                title: 'Other reason',
                value: 'Other',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              if (selectedReason == 'Other') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: customReasonController,
                  decoration: const InputDecoration(hintText: 'Enter reason...', isDense: true),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () {
                final reason = selectedReason == 'Other' && customReasonController.text.trim().isNotEmpty
                    ? customReasonController.text.trim()
                    : selectedReason;

                widget.guideState.rejectPackage(pkg.id, reason);
                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Package declined. Reallocated to network.'),
                    backgroundColor: AppTheme.textPrimary,
                  ),
                );
              },
              child: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      value: value,
      groupValue: groupValue,
      activeColor: AppTheme.danger,
      onChanged: onChanged,
    );
  }

  void _acceptPackage(TourPackage pkg) {
    widget.guideState.acceptPackage(pkg.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Accepted "${pkg.title}"!')),
          ],
        ),
        backgroundColor: AppTheme.success,
        action: SnackBarAction(
          label: 'Connect',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TouristChatScreen(
                  package: pkg,
                  guideState: widget.guideState,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guide = widget.guideState.currentGuide;

    return ListenableBuilder(
      listenable: widget.guideState,
      builder: (context, _) {
        final pending = widget.guideState.pendingPackages;
        final accepted = widget.guideState.acceptedPackages;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(guide.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.warning, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${guide.rating} (${guide.totalTours} Tours)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Online Toggle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: guide.isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: guide.isAvailable ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: guide.isAvailable ? AppTheme.success : AppTheme.danger,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      guide.isAvailable ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: guide.isAvailable ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: guide.isAvailable,
                      activeColor: AppTheme.success,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => widget.guideState.toggleAvailability(),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
                tooltip: 'Sign Out',
                onPressed: widget.onLogout,
              ),
            ],
          ),
          body: Column(
            children: [
              // Stats Overview Header
              _buildStatsBanner(),

              // Body Content by Tab
              Expanded(
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    _buildPendingPackagesTab(pending),
                    _buildAcceptedToursTab(accepted),
                    _buildTouristHubTab(accepted),
                    _buildGuideProfileTab(guide),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
            backgroundColor: Colors.white,
            elevation: 3,
            indicatorColor: AppTheme.primaryLight,
            destinations: [
              NavigationDestination(
                icon: Badge(
                  label: Text('${pending.length}'),
                  isLabelVisible: pending.isNotEmpty,
                  child: const Icon(Icons.notifications_active_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('${pending.length}'),
                  isLabelVisible: pending.isNotEmpty,
                  child: const Icon(Icons.notifications_active, color: AppTheme.primary),
                ),
                label: 'Requests',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text('${accepted.length}'),
                  isLabelVisible: accepted.isNotEmpty,
                  child: const Icon(Icons.explore_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('${accepted.length}'),
                  isLabelVisible: accepted.isNotEmpty,
                  child: const Icon(Icons.explore, color: AppTheme.primary),
                ),
                label: 'My Tours',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt, color: AppTheme.primary),
                label: 'Tourist Hub',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_pin_outlined),
                selectedIcon: Icon(Icons.person_pin, color: AppTheme.primary),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C5C), Color(0xFF1B6B7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBannerStat(
            label: 'New Offers',
            value: '${widget.guideState.pendingPackages.length}',
            icon: Icons.inbox_rounded,
          ),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
          _buildBannerStat(
            label: 'Active Tours',
            value: '${widget.guideState.acceptedPackages.length}',
            icon: Icons.tour_rounded,
          ),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
          _buildBannerStat(
            label: 'Total Tourists',
            value: '${widget.guideState.totalRegisteredTourists}',
            icon: Icons.groups_rounded,
          ),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
          _buildBannerStat(
            label: 'Projected Payout',
            value: '\$${widget.guideState.totalPotentialEarnings.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  // TAB 1: Pending Packages for Guide to Accept or Reject
  Widget _buildPendingPackagesTab(List<TourPackage> pending) {
    if (pending.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.done_all_rounded, size: 48, color: AppTheme.success),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Caught Up!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'No pending package assignments right now. New matched tours will appear here automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.explore_rounded),
                label: const Text('View Active Tours'),
                onPressed: () => setState(() => _currentTabIndex = 1),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final pkg = pending[index];
        return _buildPendingPackageCard(pkg);
      },
    );
  }

  Widget _buildPendingPackageCard(TourPackage pkg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PackageDetailsScreen(
                package: pkg,
                guideState: widget.guideState,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner with Badges
            Stack(
              children: [
                Image.network(
                  pkg.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 160,
                    color: AppTheme.primaryDark,
                    child: const Icon(Icons.landscape, size: 48, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'NEW REQUEST',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Payout: \$${pkg.payoutAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

            // Content info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pkg.destination,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, color: AppTheme.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        pkg.dates,
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pkg.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 12),

                  // Tourists summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${pkg.tourists.length} registered parties (${pkg.currentBookings}/${pkg.maxCapacity} spots booked)',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons: Reject & Accept
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Decline'),
                          onPressed: () => _showRejectDialog(pkg),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Accept Tour Assignment'),
                          onPressed: () => _acceptPackage(pkg),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: Accepted Tours with Direct Connect
  Widget _buildAcceptedToursTab(List<TourPackage> accepted) {
    if (accepted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hiking_rounded, size: 54, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              const Text(
                'No Active Tours Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Check your "Requests" tab to accept upcoming tours and start guiding!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _currentTabIndex = 0),
                child: const Text('Review Package Requests'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: accepted.length,
      itemBuilder: (context, index) {
        final pkg = accepted[index];
        return _buildAcceptedTourCard(pkg);
      },
    );
  }

  Widget _buildAcceptedTourCard(TourPackage pkg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                pkg.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'CONFIRMED ACTIVE TOUR',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pkg.destination} • ${pkg.dates}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.pin_drop, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pkg.meetingPoint,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Tourist Rosters Preview
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: Row(
                        children: pkg.tourists
                            .take(4)
                            .map((t) => Align(
                                  widthFactor: 0.7,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundImage: NetworkImage(t.avatarUrl),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '${pkg.tourists.length} registered parties (${pkg.currentBookings} travelers)',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Direct Connection Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.forum_rounded, size: 18),
                        label: const Text('Connect with Tourists'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TouristChatScreen(
                                package: pkg,
                                guideState: widget.guideState,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                      child: const Text('Details'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PackageDetailsScreen(
                              package: pkg,
                              guideState: widget.guideState,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: Tourist Hub (Browse all tourists across accepted tours)
  Widget _buildTouristHubTab(List<TourPackage> accepted) {
    if (accepted.isEmpty) {
      return const Center(
        child: Text(
          'Accept packages to connect with booked tourists.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text(
          'Active Group Chats & Travelers',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Coordinate gear requirements, meeting coordinates, and answer tourist questions.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),

        ...accepted.map((pkg) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pkg.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TouristChatScreen(
                                package: pkg,
                                guideState: widget.guideState,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pkg.tourists.length} Travelers Enrolled:',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  ...pkg.tourists.map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 12, backgroundImage: NetworkImage(t.avatarUrl)),
                            const SizedBox(width: 8),
                            Text(
                              t.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${t.country} • Party of ${t.partySize})',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            )),
      ],
    );
  }

  // TAB 4: Guide Profile
  Widget _buildGuideProfileTab(GuideUser guide) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Profile Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(guide.avatarUrl),
              ),
              const SizedBox(height: 12),
              Text(
                guide.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              Text(
                guide.badge,
                style: const TextStyle(fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: guide.languages
                    .map((lang) => Chip(
                          label: Text(lang, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          backgroundColor: AppTheme.surfaceVariant,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Specialties
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Certified Guide Specialties',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ...guide.specialties.map((spec) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.success, size: 16),
                        const SizedBox(width: 8),
                        Text(spec, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sign out button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out of Guide Portal'),
            onPressed: widget.onLogout,
          ),
        ),
      ],
    );
  }
}

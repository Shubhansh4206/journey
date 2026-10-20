import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../models/quotation_item_model.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';
import 'package:guide_app/screens/package_details_screen.dart';
import 'package:guide_app/screens/tourist_chat_screen.dart';
import 'package:guide_app/screens/tour_guide_profile_screen.dart';
import 'package:guide_app/screens/itinerary_map_screen.dart';
import 'package:guide_app/screens/sos_emergency_dialog.dart';

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

  String _formatINR(num amount) {
    final int val = amount.round();
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showEditGoalDialog() {
    final currentGoal = widget.guideState.weeklyGoal.round().toString();
    final controller = TextEditingController(text: currentGoal);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.track_changes_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Set Weekly Target', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your weekly earnings target in INR (₹):',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '40000',
                labelText: 'Weekly Goal (₹)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.replaceAll(',', '').trim());
              if (val != null && val > 0) {
                widget.guideState.setWeeklyGoal(val);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Weekly target updated to ₹${_formatINR(val)}!'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save Goal'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(TourPackage pkg) {
    String selectedReason = 'Schedule conflict on dates';
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
                value: 'Schedule conflict on dates',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonOption(
                title: 'Location outside my active zone',
                value: 'Location outside my active zone',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonOption(
                title: 'Group size exceeds capacity',
                value: 'Group size exceeds capacity',
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
                  const SnackBar(
                    content: Text('Package declined. Reallocated to network.'),
                    backgroundColor: AppTheme.textPrimary,
                    behavior: SnackBarBehavior.floating,
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
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppTheme.danger : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
          ],
        ),
      ),
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
            Expanded(
              child: Text(
                'Accepted "${pkg.title}"! (+₹${_formatINR(pkg.payoutAmount)} added to Escrow)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'My Tours',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentTabIndex = 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.guideState,
      builder: (context, _) {
        final guide = widget.guideState.currentGuide;
        final pending = widget.guideState.pendingPackages;
        final accepted = widget.guideState.acceptedPackages;
        final totalRequestsCount = pending.length + widget.guideState.finalizedQuotations.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                // Header Section (shown on Requests, My Tours, and Tourist Hub; hidden on Profile to avoid double header)
                if (_currentTabIndex != 3) _buildHeaderSection(guide),

                // Persistent High-Priority SOS Emergency Alert Banner
                if (widget.guideState.activeSosAlert != null)
                  _buildActiveSosWarningBanner(widget.guideState.activeSosAlert!),

                // Tab Body
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
          ),
          // 4. Complete Navigation Bar with Dynamic Badges
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
            backgroundColor: Colors.white,
            elevation: 3,
            indicatorColor: AppTheme.primaryLight,
            destinations: [
              NavigationDestination(
                icon: Badge(
                  label: Text('$totalRequestsCount'),
                  isLabelVisible: totalRequestsCount > 0,
                  child: const Icon(Icons.notifications_active_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('$totalRequestsCount'),
                  isLabelVisible: totalRequestsCount > 0,
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

  // ==========================================
  // 1. HEADER SECTION (Clean Two-Row Layout)
  // ==========================================
  Widget _buildHeaderSection(GuideUser guide) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: CircleAvatar + Expanded Column (Name & Rating) - No Logout Button
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryLight,
                  backgroundImage: NetworkImage(guide.avatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      guide.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.warning, size: 17),
                        const SizedBox(width: 3),
                        Text(
                          '${guide.rating}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• ${guide.totalTours} Verified Tours',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Available / Busy Status Pill Toggle Switch
          Row(
            children: [
              InkWell(
                onTap: () => widget.guideState.toggleAvailability(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: guide.isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: guide.isAvailable ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: guide.isAvailable ? AppTheme.success : AppTheme.danger,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        guide.isAvailable ? 'Status: Ready for Tours (Available)' : 'Status: Off-Duty (Busy)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: guide.isAvailable ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 20,
                        width: 32,
                        child: Switch(
                          value: guide.isAvailable,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeThumbColor: AppTheme.success,
                          inactiveThumbColor: AppTheme.danger,
                          activeTrackColor: const Color(0xFFA7F3D0),
                          inactiveTrackColor: const Color(0xFFFECACA),
                          onChanged: (val) => widget.guideState.toggleAvailability(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. METRICS DASHBOARD (INR, Escrow, Editable Goal - Compact & Requests Only)
  // ==========================================
  Widget _buildStatsBanner({bool isInsidePaddedList = false}) {
    final double totalPayout = widget.guideState.totalPotentialEarnings;
    final double inEscrow = widget.guideState.inEscrowEarnings;
    final double readyToWithdraw = widget.guideState.readyToWithdraw;
    final double weeklyGoal = widget.guideState.weeklyGoal;
    final double progress = (totalPayout / weeklyGoal).clamp(0.0, 1.0);

    return Container(
      margin: isInsidePaddedList
          ? const EdgeInsets.fromLTRB(0, 8, 0, 8)
          : const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C5C), Color(0xFF1B6B7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Stat Columns: "New Offers" & "Active Tours" (Total Tourists removed as requested)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBannerStat(
                label: 'New Offers',
                value: '${widget.guideState.pendingPackages.length}',
                icon: Icons.inbox_rounded,
              ),
              Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.2)),
              _buildBannerStat(
                label: 'Active Tours',
                value: '${widget.guideState.acceptedPackages.length}',
                icon: Icons.tour_rounded,
              ),
            ],
          ),

          const SizedBox(height: 9),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 9),

          // Projected Payout in INR & Escrow Breakdown Split (Sleeker & More Compact)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROJECTED PAYOUT',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '₹${_formatINR(totalPayout)}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatINR(inEscrow)} In Escrow',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6EE7B7),
                      ),
                    ),
                    Text(
                      '₹${_formatINR(readyToWithdraw)} Ready to Withdraw',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          // Editable Weekly Goal Progress Bar
          InkWell(
            onTap: _showEditGoalDialog,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Weekly Target',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_rounded, color: Colors.white70, size: 11),
                        ],
                      ),
                      Text(
                        '₹${_formatINR(totalPayout)} / ₹${_formatINR(weeklyGoal)} Weekly Goal',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A9D8F)),
                    ),
                  ),
                ],
              ),
            ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: REQUESTS TAB (Supabase Finalized Tours + Offers)
  // ==========================================
  Widget _buildPendingPackagesTab(List<TourPackage> pending) {
    final finalizedQuotes = widget.guideState.finalizedQuotations;
    final totalRequests = pending.length + finalizedQuotes.length;

    if (totalRequests == 0) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          _buildStatsBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.done_all_rounded, size: 44, color: AppTheme.success),
                ),
                const SizedBox(height: 14),
                const Text(
                  'All Caught Up!',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 5),
                const Text(
                  'No pending package assignments right now. New matched tours will appear here automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh Supabase'),
                      onPressed: () => widget.guideState.loadFinalizedQuotations(),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.explore_rounded, size: 18),
                      label: const Text('View Active Tours'),
                      onPressed: () => setState(() => _currentTabIndex = 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildStatsBanner(isInsidePaddedList: true),
        ),

        // Section 1: Finalized Quotations from Supabase (Ready to Claim)
        if (finalizedQuotes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FINALIZED ITINERARIES (${finalizedQuotes.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => widget.guideState.loadFinalizedQuotations(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, size: 13, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text(
                          'Live Supabase',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...finalizedQuotes.map((q) => _buildFinalizedQuotationCard(q)),
        ],

        // Section 2: Other Pending Offers
        if (pending.isNotEmpty) ...[
          if (finalizedQuotes.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 10),
              child: Text(
                'OTHER ASSIGNMENT OFFERS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ...pending.map((pkg) => _buildPendingPackageCard(pkg)),
        ],
      ],
    );
  }

  Future<void> _acceptFinalizedQuotationAndOpenMap(SupabaseQuotation quote) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  'Accepting Tour & Loading OpenStreetMap...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Fetch items with coordinates from Supabase via trip_request_id
    final items = await widget.guideState.fetchItemsForQuotation(quote);

    // Accept into guide state (updates escrow, adds to active tours)
    final acceptedPkg = await widget.guideState.acceptFinalizedQuotation(quote);

    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading

      // Push OpenStreetMap Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItineraryMapScreen(
            title: acceptedPkg.title,
            quotationId: quote.id,
            tripRequestId: quote.tripRequestId,
            destination: acceptedPkg.destination,
            payoutAmount: acceptedPkg.payoutAmount,
            items: items,
            isJustAccepted: true,
          ),
        ),
      );
    }
  }

  /// Open OpenStreetMap for any TourPackage (curated or Supabase)
  Future<void> _openTourMap(TourPackage pkg) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  'Loading OpenStreetMap Route & Stops...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final items = await widget.guideState.getItineraryLocationsForPackage(pkg);

    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItineraryMapScreen(
            title: pkg.title,
            destination: pkg.destination,
            payoutAmount: pkg.payoutAmount,
            items: items,
            package: pkg,
            guideState: widget.guideState,
          ),
        ),
      );
    }
  }

  /// Persistent high-priority SOS alert bar when an emergency is active
  Widget _buildActiveSosWarningBanner(SosEmergencyAlert alert) {
    final pkg = widget.guideState.allPackages.firstWhere(
      (p) => p.id == alert.packageId,
      orElse: () => widget.guideState.allPackages.first,
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFFDC2626),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () => SosEmergencyDialog.show(context, package: pkg, guideState: widget.guideState),
        child: Row(
          children: [
            const Icon(Icons.crisis_alert_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🚨 SOS ACTIVE • OPERATOR ALERTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${alert.emergencyType})',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    'Trip: "${alert.tourTitle}" • Tap to contact operator or resolve',
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Open Console',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openQuotationMapPreview(SupabaseQuotation quote) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  'Loading Itinerary Stops from Supabase...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final items = await widget.guideState.fetchItemsForQuotation(quote);

    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ItineraryMapScreen(
            title: quote.title,
            quotationId: quote.id,
            tripRequestId: quote.tripRequestId,
            destination: quote.title.toLowerCase().contains('goa') ? 'Goa' : 'Mumbai',
            payoutAmount: quote.totalFinalPrice,
            items: items,
            isJustAccepted: false,
          ),
        ),
      );
    }
  }

  Widget _buildFinalizedQuotationCard(SupabaseQuotation quote) {
    final lowerTitle = quote.title.toLowerCase();
    String destination = 'MUMBAI, MAHARASHTRA';
    if (lowerTitle.contains('goa')) destination = 'PANJIM, GOA';
    if (lowerTitle.contains('udaipur')) destination = 'UDAIPUR, RAJASTHAN';
    if (lowerTitle.contains('jaipur')) destination = 'JAIPUR, RAJASTHAN';
    if (lowerTitle.contains('tokyo')) destination = 'TOKYO, JAPAN';

    final imageUrl = _getImageForQuotation(quote);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6EE7B7), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Half: Image Container with Overlay
          Container(
            height: 165,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'FINALIZED IN SUPABASE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF6EE7B7)),
                        ),
                        child: Text(
                          'Payout: ₹${_formatINR(quote.totalFinalPrice)}',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, color: Color(0xFF2A9D8F), size: 15),
                          const SizedBox(width: 4),
                          Text(
                            destination,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quote.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Half: Details & Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, color: AppTheme.primary, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Trip Req #${quote.tripRequestId.length > 8 ? quote.tripRequestId.substring(0, 8) : quote.tripRequestId}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.people_alt_outlined, color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${quote.paxCount} Pax (₹${_formatINR(quote.perPersonPrice)}/ea)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // OpenStreetMap Route Preview Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.map_rounded, size: 15, color: Color(0xFF065F46)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Route & selected item GPS pins ready on OpenStreetMap',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Actions: Preview OSM Map & One-Tap Accept
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _openQuotationMapPreview(quote),
                        icon: const Icon(Icons.map_outlined, size: 15),
                        label: const Text('View OSM Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptFinalizedQuotationAndOpenMap(quote),
                        icon: const Icon(Icons.check_circle_rounded, size: 17),
                        label: const Text('Accept Tour Assignment', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C5C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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

  String _getImageForQuotation(SupabaseQuotation quote) {
    final t = quote.title.toLowerCase();
    if (t.contains('goa')) {
      return 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=900&q=80';
    } else if (t.contains('udaipur')) {
      return 'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=900&q=80';
    }
    return 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=900&q=80';
  }

  Widget _buildPendingPackageCard(TourPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD8BF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Half: Image Container with Dark Gradient Overlay
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(pkg.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'NEW REQUEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF6EE7B7).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'Payout: ₹${_formatINR(pkg.payoutAmount)}',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, color: Color(0xFF2A9D8F), size: 15),
                          const SizedBox(width: 4),
                          Text(
                            pkg.destination.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pkg.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Half: Logistics, Meeting Point & Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      pkg.dates,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.people_outline_rounded, color: AppTheme.textSecondary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '${pkg.currentBookings}/${pkg.maxCapacity} Booked',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Meeting Point & Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.secondary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pkg.meetingPointEta.isNotEmpty ? pkg.meetingPointEta : 'Starts at ${pkg.meetingPoint}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Logistics Check Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        pkg.logisticsBadge,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Actions: Decline & Accept Tour Assignment
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(pkg),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Decline', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptPackage(pkg),
                        icon: const Icon(Icons.check_circle_rounded, size: 17),
                        label: const Text('Accept Tour Assignment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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

  // ==========================================
  // TAB 2: MY TOURS (Confirmed Active Tours)
  // ==========================================
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

    final ongoing = widget.guideState.ongoingTour;
    final otherAccepted = accepted.where((p) => p.id != ongoing?.id).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        // Pinned Live Ongoing Tour Hero Card (if a tour is in progress)
        if (ongoing != null) ...[
          _buildOngoingTourHeroCard(ongoing),
          if (otherAccepted.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: Text(
                'UPCOMING CONFIRMED TOURS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],

        ...otherAccepted.map((pkg) => _buildAcceptedTourCard(pkg)),
      ],
    );
  }

  /// Pinned Hero Card for Live Ongoing Tour
  Widget _buildOngoingTourHeroCard(TourPackage pkg) {
    final isSos = widget.guideState.isSosActive(pkg.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSos
              ? [const Color(0xFF7F1D1D), const Color(0xFFDC2626)]
              : [const Color(0xFF064E3B), const Color(0xFF0F4C5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isSos ? const Color(0xFFDC2626) : const Color(0xFF0F4C5C)).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSos ? Colors.white : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSos ? Icons.crisis_alert_rounded : Icons.radio_button_checked_rounded,
                      size: 13,
                      color: isSos ? const Color(0xFFDC2626) : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSos ? '🚨 SOS ACTIVE — OPERATOR ALERTED' : 'LIVE ONGOING TRIP',
                      style: TextStyle(
                        color: isSos ? const Color(0xFFDC2626) : Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Payout: ₹${_formatINR(pkg.payoutAmount)}',
                style: const TextStyle(
                  color: Color(0xFF6EE7B7),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pkg.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${pkg.destination} • ${pkg.meetingPoint}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Actions: OSM Route Map & Tourist Chat
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F4C5C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 17, color: Color(0xFF0F4C5C)),
                  label: const Text(
                    'OpenStreetMap Route',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => _openTourMap(pkg),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.forum_rounded, size: 17, color: Colors.white),
                  label: const Text(
                    'Tourists Chat',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TouristChatScreen(
                          package: pkg,
                          guideState: widget.guideState,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Secondary Actions: SOS EMERGENCY (High Visibility) & Complete Tour
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.crisis_alert_rounded, size: 18),
                  label: Text(
                    isSos ? 'OPERATOR ALERT ACTIVE' : '🚨 SOS EMERGENCY (OPERATOR)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  onPressed: () => SosEmergencyDialog.show(
                    context,
                    package: pkg,
                    guideState: widget.guideState,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF6EE7B7)),
                  label: const Text('Finish Tour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () => _confirmCompleteTour(pkg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCompleteTour(TourPackage pkg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Complete Tour?'),
          ],
        ),
        content: Text(
          'Mark "${pkg.title}" as completed? Escrow payout of ₹${_formatINR(pkg.payoutAmount)} will be credited and guests will receive completion confirmation.',
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            onPressed: () {
              widget.guideState.completeTour(pkg.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Tour "${pkg.title}" completed! Payout credited to Escrow.'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Completion'),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedTourCard(TourPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(pkg.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.guideState.isSosActive(pkg.id)
                              ? const Color(0xFFDC2626)
                              : (pkg.isOngoing ? const Color(0xFF10B981) : AppTheme.success),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.guideState.isSosActive(pkg.id)
                                  ? Icons.crisis_alert_rounded
                                  : (pkg.isOngoing ? Icons.radio_button_checked_rounded : Icons.check_circle_rounded),
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.guideState.isSosActive(pkg.id)
                                  ? '🚨 SOS ACTIVE - OPERATOR ALERTED'
                                  : (pkg.isOngoing ? 'LIVE ONGOING TRIP' : 'CONFIRMED ACTIVE TOUR'),
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '₹${_formatINR(pkg.payoutAmount)}',
                          style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    pkg.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 15, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pkg.meetingPointEta.isNotEmpty ? pkg.meetingPointEta : pkg.meetingPoint,
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(pkg.dates, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const Divider(height: 22),

                // Tourist Rosters Preview
                Row(
                  children: [
                    if (pkg.tourists.isNotEmpty)
                      SizedBox(
                        height: 30,
                        child: Row(
                          children: pkg.tourists
                              .take(4)
                              .map((t) => Align(
                                    widthFactor: 0.7,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundImage: NetworkImage(t.avatarUrl),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${pkg.tourists.length} registered parties (${pkg.currentBookings} travelers)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 1 Actions: View OSM Map, Connect with Tourists, Details
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text('View Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        onPressed: () => _openTourMap(pkg),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.forum_rounded, size: 16),
                        label: const Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Details', style: TextStyle(fontSize: 12)),
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
                const SizedBox(height: 10),

                // Row 2 Actions: Ongoing Trip Transition & SOS Emergency Button
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: pkg.isOngoing
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF047857),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.check_circle_rounded, size: 16),
                              label: const Text('Finish Tour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              onPressed: () => _confirmCompleteTour(pkg),
                            )
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F4C5C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.play_circle_filled_rounded, size: 16),
                              label: const Text('Start Tour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              onPressed: () {
                                widget.guideState.startTour(pkg.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tour "${pkg.title}" is now Ongoing! Live route active.'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.guideState.isSosActive(pkg.id)
                              ? const Color(0xFF991B1B)
                              : const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.crisis_alert_rounded, size: 16),
                        label: Text(
                          widget.guideState.isSosActive(pkg.id) ? 'SOS ACTIVE' : '🚨 SOS Alert',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        onPressed: () => SosEmergencyDialog.show(
                          context,
                          package: pkg,
                          guideState: widget.guideState,
                        ),
                      ),
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

  // ==========================================
  // TAB 3: TOURIST HUB TAB
  // ==========================================
  Widget _buildTouristHubTab(List<TourPackage> accepted) {
    if (accepted.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Accept packages to connect with booked tourists.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
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

  // ==========================================
  // TAB 4: PROFILE TAB (Rich Profile Dashboard)
  // ==========================================
  Widget _buildGuideProfileTab(GuideUser guide) {
    return TourGuideProfileScreen(
      onLogout: widget.onLogout,
    );
  }
}

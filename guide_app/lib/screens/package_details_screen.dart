import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';
import 'tourist_chat_screen.dart';

class PackageDetailsScreen extends StatefulWidget {
  final TourPackage package;
  final GuideState guideState;

  const PackageDetailsScreen({
    super.key,
    required this.package,
    required this.guideState,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  void _showRejectDialog() {
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
              const Text(
                'Please select a reason for declining this tour package assignment:',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              _buildReasonRadio(
                title: 'Schedule conflict / Unavailable on dates',
                value: 'Schedule conflict with existing booking',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonRadio(
                title: 'Route outside primary jurisdiction',
                value: 'Route outside primary jurisdiction',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonRadio(
                title: 'Group size exceeds guide preference',
                value: 'Group size exceeds guide preference',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonRadio(
                title: 'Personal medical or recovery leave',
                value: 'Personal medical or recovery leave',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              _buildReasonRadio(
                title: 'Other specific reason',
                value: 'Other',
                groupValue: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              ),
              if (selectedReason == 'Other') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: customReasonController,
                  decoration: const InputDecoration(
                    hintText: 'Enter reason...',
                    isDense: true,
                  ),
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

                widget.guideState.rejectPackage(widget.package.id, reason);
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to dashboard

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Declined "${widget.package.title}". Reallocated to next available guide.'),
                    backgroundColor: AppTheme.textPrimary,
                  ),
                );
              },
              child: const Text('Confirm Decline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonRadio({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      value: value,
      groupValue: groupValue,
      activeColor: AppTheme.danger,
      onChanged: onChanged,
    );
  }

  void _acceptTour() {
    widget.guideState.acceptPackage(widget.package.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('Package accepted! "${widget.package.title}" is now in your active tours.')),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Chat Now',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TouristChatScreen(
                  package: widget.package,
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
    return ListenableBuilder(
      listenable: widget.guideState,
      builder: (context, _) {
        final currentPkg = widget.guideState.allPackages.firstWhere(
          (p) => p.id == widget.package.id,
          orElse: () => widget.package,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        currentPkg.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppTheme.primaryDark,
                          child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 64),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: currentPkg.status == PackageStatus.accepted
                                    ? AppTheme.success
                                    : currentPkg.status == PackageStatus.rejected
                                        ? AppTheme.danger
                                        : AppTheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currentPkg.status == PackageStatus.accepted
                                    ? 'ASSIGNED & ACCEPTED'
                                    : currentPkg.status == PackageStatus.rejected
                                        ? 'DECLINED'
                                        : 'NEW PACKAGE REQUEST',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentPkg.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  currentPkg.destination,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Metrics Row
                      _buildMetricsRow(currentPkg),
                      const SizedBox(height: 24),

                      // Rejection banner if rejected
                      if (currentPkg.status == PackageStatus.rejected) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppTheme.danger),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Declined Reason: ${currentPkg.rejectionReason ?? "Unavailable"}',
                                  style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.guideState.restorePackage(currentPkg.id);
                                },
                                child: const Text('Re-evaluate'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description
                      const Text(
                        'Tour Overview',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentPkg.description,
                        style: const TextStyle(fontSize: 14.5, color: AppTheme.textSecondary, height: 1.45),
                      ),
                      const SizedBox(height: 24),

                      // Meeting Point Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Designated Meeting Point',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentPkg.meetingPoint,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Highlights
                      const Text(
                        'Itinerary Highlights',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      ...currentPkg.highlights.map((h) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    h,
                                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24),

                      // Inclusions for Guide
                      const Text(
                        'Guide Inclusions & Support',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      ...currentPkg.inclusions.map((inc) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    inc,
                                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 28),

                      // Registered Tourists Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booked Tourists',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              ),
                              Text(
                                '${currentPkg.tourists.length} Parties (${currentPkg.currentBookings} total guests)',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          if (currentPkg.status == PackageStatus.accepted)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: const Icon(Icons.forum_rounded, size: 16),
                              label: const Text('Group Chat', style: TextStyle(fontSize: 13)),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TouristChatScreen(
                                      package: currentPkg,
                                      guideState: widget.guideState,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Tourist Cards
                      ...currentPkg.tourists.map((t) => _buildTouristCard(t, currentPkg)),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomActionBar(currentPkg),
        );
      },
    );
  }

  Widget _buildMetricsRow(TourPackage pkg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.payments_rounded,
            color: AppTheme.success,
            label: 'Guide Payout',
            value: '\$${pkg.payoutAmount.toStringAsFixed(0)}',
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildMetricItem(
            icon: Icons.calendar_month_rounded,
            color: AppTheme.primary,
            label: 'Tour Dates',
            value: pkg.dates.split(' - ').first,
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildMetricItem(
            icon: Icons.groups_rounded,
            color: AppTheme.secondary,
            label: 'Capacity',
            value: '${pkg.currentBookings}/${pkg.maxCapacity}',
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildMetricItem(
            icon: Icons.terrain_rounded,
            color: AppTheme.accent,
            label: 'Difficulty',
            value: pkg.difficulty,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTouristCard(TouristUser tourist, TourPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(tourist.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tourist.name,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (tourist.isLeadBooker) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Lead Booker',
                              style: TextStyle(fontSize: 10, color: AppTheme.primaryDark, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${tourist.country} • Party of ${tourist.partySize}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (pkg.status == PackageStatus.accepted) ...[
                IconButton.filledTonal(
                  icon: const Icon(Icons.phone, size: 16),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${tourist.name} (${tourist.phone})...')),
                    );
                  },
                ),
              ],
            ],
          ),
          if (tourist.dietaryOrSpecialNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Note: ${tourist.dietaryOrSpecialNotes}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(TourPackage pkg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: pkg.status == PackageStatus.pending
            ? Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Decline'),
                      onPressed: _showRejectDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: Text('Accept Package (\$${pkg.payoutAmount.toStringAsFixed(0)})'),
                      onPressed: _acceptTour,
                    ),
                  ),
                ],
              )
            : pkg.status == PackageStatus.accepted
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.forum_rounded),
                      label: Text('Connect with Tourists (${pkg.tourists.length} Travelers)'),
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
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Restore / Re-evaluate Package'),
                      onPressed: () => widget.guideState.restorePackage(pkg.id),
                    ),
                  ),
      ),
    );
  }
}

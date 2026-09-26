import 'package:flutter/material.dart';

/// Model representing a Tour item for TourGuideHomeScreen
class GuideTourItem {
  final String id;
  final String title;
  final String destination;
  final String imageUrl;
  final String duration;
  final String dates;
  final int payoutAmount;
  final int touristsCount;
  final String meetingPointEta;
  final String logisticsBadge;
  final IconData logisticsIcon;
  bool isActive;

  GuideTourItem({
    required this.id,
    required this.title,
    required this.destination,
    required this.imageUrl,
    required this.duration,
    required this.dates,
    required this.payoutAmount,
    required this.touristsCount,
    required this.meetingPointEta,
    required this.logisticsBadge,
    required this.logisticsIcon,
    required this.isActive,
  });
}

class TourGuideHomeScreen extends StatefulWidget {
  const TourGuideHomeScreen({super.key});

  @override
  State<TourGuideHomeScreen> createState() => _TourGuideHomeScreenState();
}

class _TourGuideHomeScreenState extends State<TourGuideHomeScreen> {
  // Guide Status
  bool _isAvailable = true;
  final String _guideName = 'Capt. Ryan Vance';
  final double _guideRating = 4.96;
  final int _totalToursCompleted = 142;
  final String _guideAvatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80';

  // Base financial metrics (INR)
  final int _weeklyGoal = 40000;
  final int _readyToWithdraw = 4500;
  int _inEscrow = 28000;

  // Localized 4 tour cards
  late List<GuideTourItem> _tours;

  @override
  void initState() {
    super.initState();
    _tours = [
      // 1. Active Tour 1 (Mumbai)
      GuideTourItem(
        id: 'tour_mum_01',
        title: 'South Bombay Art Deco & Heritage Trail',
        destination: 'Mumbai, Maharashtra',
        imageUrl:
            'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=900&q=80',
        duration: 'Half Day • 4 Hours',
        dates: 'Today, 4:30 PM - 8:30 PM',
        payoutAmount: 4800,
        touristsCount: 6,
        meetingPointEta: "Starts at McDonald's entrance opposite CST • 10 mins away",
        logisticsBadge: 'Walking Tour Only',
        logisticsIcon: Icons.directions_walk_rounded,
        isActive: true,
      ),
      // 2. Active Tour 2 (Udaipur)
      GuideTourItem(
        id: 'tour_uda_01',
        title: 'Lake Pichola Royal Ghats & Haveli Sunset Walk',
        destination: 'Udaipur, Rajasthan',
        imageUrl:
            'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=900&q=80',
        duration: 'Sunset Special • 3.5 Hours',
        dates: 'Tomorrow, 3:00 PM - 6:30 PM',
        payoutAmount: 6500,
        touristsCount: 4,
        meetingPointEta: 'Starts at City Palace Gate • 15 mins away',
        logisticsBadge: 'Walking & Boat Ride',
        logisticsIcon: Icons.sailing_rounded,
        isActive: true,
      ),
      // 3. Tour Request 1 (Goa)
      GuideTourItem(
        id: 'tour_goa_01',
        title: 'Fontainhas Latin Quarter Architecture Walk',
        destination: 'Panjim, Goa',
        imageUrl:
            'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=900&q=80',
        duration: 'Morning Trail • 3 Hours',
        dates: 'Oct 12, 8:00 AM - 11:00 AM',
        payoutAmount: 3200,
        touristsCount: 5,
        meetingPointEta: 'Starts at General Post Office Panjim • 8 mins away',
        logisticsBadge: 'Walking Tour Only',
        logisticsIcon: Icons.directions_walk_rounded,
        isActive: false,
      ),
      // 4. Tour Request 2 (Mumbai)
      GuideTourItem(
        id: 'tour_mum_02',
        title: 'Elephanta Caves Guided Expedition',
        destination: 'Mumbai, Maharashtra',
        imageUrl:
            'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=900&q=80',
        duration: 'Full Day • 6 Hours',
        dates: 'Oct 15, 9:00 AM - 3:00 PM',
        payoutAmount: 4500,
        touristsCount: 8,
        meetingPointEta: 'Starts at Gateway of India • 20 mins away',
        logisticsBadge: 'Ferry & Transport Included',
        logisticsIcon: Icons.directions_boat_filled_rounded,
        isActive: false,
      ),
    ];
  }

  // Getters for dynamic state metrics
  List<GuideTourItem> get _activeTours =>
      _tours.where((t) => t.isActive).toList();

  List<GuideTourItem> get _pendingRequests =>
      _tours.where((t) => !t.isActive).toList();

  int get _totalProjectedPayout => _inEscrow + _readyToWithdraw;

  int get _totalActiveTourists =>
      _activeTours.fold(0, (sum, t) => sum + t.touristsCount);

  // Accept Tour Interaction
  void _acceptTour(GuideTourItem tour) {
    setState(() {
      tour.isActive = true;
      _inEscrow += tour.payoutAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Accepted "${tour.title}"! (+₹${_formatCurrency(tour.payoutAmount)} added to Escrow)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Decline Tour Request
  void _declineTour(GuideTourItem tour) {
    setState(() {
      _tours.removeWhere((t) => t.id == tour.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined "${tour.title}". Offer reallocated.'),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header Section (2-Row Hierarchy)
            SliverToBoxAdapter(
              child: _buildHeaderSection(),
            ),

            // 2. Metrics Dashboard (Dark Teal Payout Bar)
            SliverToBoxAdapter(
              child: _buildMetricsDashboard(),
            ),

            // 3. Tour Feed - Section Header: Tour Requests (if any)
            if (_pendingRequests.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'New Tour Requests',
                  count: _pendingRequests.length,
                  badgeColor: const Color(0xFFE36414),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tour = _pendingRequests[index];
                      return _buildTourCard(tour);
                    },
                    childCount: _pendingRequests.length,
                  ),
                ),
              ),
            ],

            // 4. Tour Feed - Section Header: Active Tours
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Active Tour Schedule',
                count: _activeTours.length,
                badgeColor: const Color(0xFF0F4C5C),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tour = _activeTours[index];
                    return _buildTourCard(tour);
                  },
                  childCount: _activeTours.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. HEADER SECTION (Two-Row Clean Layout)
  // ==========================================
  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Expanded Column with Name & Rating (No Logout Button)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F4C5C), width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE6F4F6),
                  backgroundImage: NetworkImage(_guideAvatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _guideName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 17,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$_guideRating',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• $_totalToursCompleted Verified Tours',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
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

          // Bottom Row: "Available / Busy" Toggle Pill Switch
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _isAvailable = !_isAvailable),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isAvailable
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFECACA),
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
                          color: _isAvailable
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAvailable
                            ? 'Status: Ready for Tours (Available)'
                            : 'Status: Off-Duty (Busy)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _isAvailable
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 20,
                        width: 32,
                        child: Switch(
                          value: _isAvailable,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeThumbColor: const Color(0xFF10B981),
                          inactiveThumbColor: const Color(0xFFEF4444),
                          activeTrackColor: const Color(0xFFA7F3D0),
                          inactiveTrackColor: const Color(0xFFFECACA),
                          onChanged: (val) =>
                              setState(() => _isAvailable = val),
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
  // 2. METRICS DASHBOARD (Dark Teal Payout Bar)
  // ==========================================
  Widget _buildMetricsDashboard() {
    final double progress = (_totalProjectedPayout / _weeklyGoal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C5C), Color(0xFF1B6B7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating Surge Badge (Top-Right Corner)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE36414),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔥 Peak Season (+15%)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Core Stat Columns Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(
                      label: 'New Offers',
                      value: '${_pendingRequests.length}',
                      icon: Icons.inbox_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildStatColumn(
                      label: 'Active Tours',
                      value: '${_activeTours.length}',
                      icon: Icons.tour_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildStatColumn(
                      label: 'Total Tourists',
                      value: '$_totalActiveTourists',
                      icon: Icons.groups_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 14),

                // Projected Payout in INR & Escrow Breakdown
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
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_formatCurrency(_totalProjectedPayout)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Currency & Escrow Breakdown Split
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${_formatCurrency(_inEscrow)} In Escrow',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6EE7B7),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '₹${_formatCurrency(_readyToWithdraw)} Ready to Withdraw',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Weekly Goal Progress Bar & Tiny Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Target',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${_formatCurrency(_totalProjectedPayout)} / ₹${_formatCurrency(_weeklyGoal)} Weekly Goal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2A9D8F),
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

  Widget _buildStatColumn({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 15),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3 & 4. TOUR CARD BUILDER (Active & Requests)
  // ==========================================
  Widget _buildTourCard(GuideTourItem tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tour.isActive
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFFFD8BF),
          width: tour.isActive ? 1 : 1.5,
        ),
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
                image: NetworkImage(tour.imageUrl),
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
                  // Top Tags Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: tour.isActive
                              ? const Color(0xFF0F4C5C).withValues(alpha: 0.9)
                              : const Color(0xFFE36414).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tour.isActive
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.bolt_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.isActive
                                  ? 'CONFIRMED ACTIVE'
                                  : 'NEW ASSIGNMENT REQUEST',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Payout Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6EE7B7).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Payout: ₹${_formatCurrency(tour.payoutAmount)}',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Image Location Overlay Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            color: Color(0xFF2A9D8F),
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.destination.toUpperCase(),
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
                        tour.title,
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

          // Bottom Half: Logistics, Meeting Point & Interactive Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Party Size Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF0F4C5C),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tour.dates,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.people_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tour.touristsCount} Tourists',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Meeting Point Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFE36414),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tour.meetingPointEta,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Logistics Check Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tour.logisticsIcon,
                        size: 14,
                        color: const Color(0xFF0F4C5C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tour.logisticsBadge,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F4C5C),
                        ),
                      ),
                    ],
                  ),
                ),

                // Request Action Buttons (For Tour Requests Only)
                if (!tour.isActive) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => _declineTour(tour),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptTour(tour),
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 17,
                          ),
                          label: const Text(
                            'Accept Tour Assignment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C5C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

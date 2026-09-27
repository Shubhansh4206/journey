import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/group_controller.dart';
import '../models/group_models.dart';
import '../models/trip_request.dart';
import '../screens/confirmed_trip_dashboard_screen.dart';
import '../screens/group_picker_sheet.dart';
import '../utils/colors.dart';
import '../widgets/swiggy_group_roster_sheet.dart';

class GroupsNavScreen extends StatefulWidget {
  const GroupsNavScreen({super.key});

  @override
  State<GroupsNavScreen> createState() => _GroupsNavScreenState();
}

class _GroupsNavScreenState extends State<GroupsNavScreen> {
  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  @override
  void initState() {
    super.initState();
    _groupController.refreshAll();
  }

  String _formatDateShort(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

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
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Color(0xFFFC8019),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Groups',
                style: GoogleFonts.poppins(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
            tooltip: 'Manage Roster',
            onPressed: () => SwiggyGroupRosterSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFC8019),
        onRefresh: () async {
          await _groupController.refreshAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Confirmed Groups Summary Card (Phase 2) ───────────────────
              _buildConfirmedGroupsSummaryCard(),

              // ── Sent Trip Requests Section (Realtime Live Tracking) ────────
              _buildSentTripRequestsSection(),

              const SizedBox(height: 6),

              // ── My Travel Squads Section ──────────────────────────────────
              _buildMySquadsSection(),

              const SizedBox(height: 16),

              // ── Group Planning Feature Highlights / Banner ───────────────
              _buildGroupPlanningBanner(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirmed Groups Summary Card (Phase 2) ──────────────────────────────
  Widget _buildConfirmedGroupsSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Color(0xFF059669), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Confirmed Trips',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConfirmedTripDashboardScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 175,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1000&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.2, 0.5, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            'All payments cleared',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom info: Destination, Squad & Dates
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goa Beach Villa & Scuba Squad',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.groups_rounded,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Goa Sunshine Squad (6 Travelers)',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• 15-18 Oct',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFD400),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📍 Stay: Casa Baga Beachfront Resort',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ── Sent Trip Requests Section (Realtime Live Tracking) ───────────────────
  Widget _buildSentTripRequestsSection() {
    return Obx(() {
      final requests = _groupController.sentTripRequests;
      if (requests.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Color(0xFF2563EB), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Requests Sent',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${requests.length} Live',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _groupController.fetchSentTripRequests(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Sync',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 175,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _buildTripRequestCard(req);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTripRequestCard(TripRequest req) {
    Color statusBg;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (req.status.toLowerCase()) {
      case 'reviewing_bids':
      case 'bids_ready':
        statusBg = const Color(0xFFEEF2FF);
        statusColor = const Color(0xFF4F46E5);
        statusLabel = 'Bids Ready';
        statusIcon = Icons.local_offer_rounded;
        break;
      case 'accepted':
      case 'confirmed':
        statusBg = const Color(0xFFECFDF5);
        statusColor = const Color(0xFF059669);
        statusLabel = 'Accepted';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusBg = const Color(0xFFF1F5F9);
        statusColor = const Color(0xFF64748B);
        statusLabel = 'Cancelled';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        statusBg = const Color(0xFFFFF7ED);
        statusColor = const Color(0xFFFC8019);
        statusLabel = 'Awaiting Operators';
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    final totalItems = req.selectedHotels.length +
        req.selectedPlaces.length +
        req.selectedActivities.length +
        req.selectedTransport.length;

    return GestureDetector(
      onTap: () => _showTripRequestDetailsSheet(context, req),
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row 1: Destination + Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    req.destination,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Row 2: Squad / Mode Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    req.tripMode.contains('Solo')
                        ? Icons.person_rounded
                        : Icons.groups_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      req.assignedGroupName ?? req.tripMode,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Row 3: Travel Dates & Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDateShort(req.startDate)} - ${_formatDateShort(req.endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${req.perPersonBudget.toStringAsFixed(0)}/pax',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFC8019),
                  ),
                ),
              ],
            ),

            // Row 4: Items pill & Track link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalItems items chosen',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Track Details',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 10, color: Color(0xFF2563EB)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTripRequestDetailsSheet(BuildContext context, TripRequest req) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${req.destination} Trip Request',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        Text(
                          'ID: #${req.id.length > 8 ? req.id.substring(0, 8) : req.id}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: req.status == 'cancelled'
                            ? Colors.grey.shade100
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: req.status == 'cancelled'
                              ? Colors.grey
                              : const Color(0xFFFC8019),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Status Progression Tracker
                Text(
                  'Live Operator Tracker',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusTimeline(req.status),

                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Request Breakdown
                Text(
                  'Trip Specifications',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 10),
                _specRow('Trip Mode', req.tripMode),
                _specRow('Assigned Squad',
                    req.assignedGroupName ?? 'Solo Explorer'),
                _specRow('Travel Dates',
                    '${_formatDateShort(req.startDate)} → ${_formatDateShort(req.endDate)}'),
                _specRow('Per Person Budget',
                    '₹${req.perPersonBudget.toStringAsFixed(2)}'),
                if (req.estimatedMockTotal > 0)
                  _specRow('Mock Estimated Total',
                      '₹${req.estimatedMockTotal.toStringAsFixed(2)}'),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Category Items Count
                Text(
                  'Selections Sent to Operators',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _categoryChip('🏨 Stays', req.selectedHotels.length),
                    _categoryChip('📍 Sightseeing', req.selectedPlaces.length),
                    _categoryChip('🏄 Thrills', req.selectedActivities.length),
                    _categoryChip('🚗 Transfers', req.selectedTransport.length),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions
                if (req.status != 'cancelled')
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () async {
                        final scaffoldMessenger =
                            ScaffoldMessenger.of(context);
                        final bottomSheetNav = Navigator.of(ctx);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: Text('Cancel Trip Request',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold)),
                            content: Text(
                                'Are you sure you want to cancel this trip request?',
                                style: GoogleFonts.poppins()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dCtx, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                child: const Text('Cancel Request',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          bottomSheetNav.pop();
                          await _groupController.cancelTripRequest(req.id);
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Trip request cancelled.',
                                    style: GoogleFonts.poppins()),
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel This Request',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final steps = [
      {'title': 'Dispatched', 'desc': 'Sent to verified tour operators'},
      {'title': 'Operators Reviewing', 'desc': 'Custom packages being prepared'},
      {'title': 'Bids Available', 'desc': 'Compare quotes & accept proposals'},
      {'title': 'Trip Confirmed', 'desc': 'Booking & itinerary finalized'},
    ];

    int currentStep = 1;
    if (currentStatus == 'reviewing_bids' || currentStatus == 'bids_ready') {
      currentStep = 2;
    } else if (currentStatus == 'accepted' || currentStatus == 'confirmed') {
      currentStep = 3;
    } else if (currentStatus == 'cancelled') {
      currentStep = -1;
    }

    if (currentStep == -1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(
              'This trip request has been cancelled.',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: i <= currentStep
                          ? const Color(0xFFFC8019)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: i < currentStep
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : (i == currentStep
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 26,
                      color: i < currentStep
                          ? const Color(0xFFFC8019)
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i]['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: i <= currentStep
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: i <= currentStep
                            ? AppColors.darkCharcoal
                            : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      steps[i]['desc']!,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal)),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: count > 0 ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: count > 0
              ? const Color(0xFFFC8019).withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Text(
        '$label: $count',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: count > 0 ? const Color(0xFFFC8019) : AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── My Travel Squads Section ──────────────────────────────────────────────
  Widget _buildMySquadsSection() {
    return Obx(() {
      final groups = _groupController.userGroups;
      final selectedId = _groupController.selectedGroup.value?.id;

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.groups_rounded,
                            color: Color(0xFFFC8019), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Squads',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (groups.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFC8019).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${groups.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFC8019),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 20, color: Color(0xFFFC8019)),
                      onPressed: () {
                        context.push('/create-group').then((_) {
                          _groupController.refreshAll();
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'New Squad',
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          size: 16, color: AppColors.textSecondary),
                      onPressed: () => SwiggyGroupRosterSheet.show(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Manage Roster',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (groups.isEmpty)
              _buildEmptySquadsCard()
            else
              SizedBox(
                height: 145,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: groups.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == groups.length) {
                      return _buildAddSquadCard();
                    }
                    final g = groups[index];
                    return _buildSquadCard(g, selectedId);
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSquadCard(Map<String, dynamic> g, String? selectedId) {
    final nested = g['groups'] as Map<String, dynamic>?;
    final gId = g['group_id'] as String? ?? nested?['id'] as String? ?? '';
    final gName = nested?['name'] as String? ?? 'Travel Squad';
    final role = g['role'] as String? ?? 'member';
    final isLeader = role.toLowerCase() == 'leader';
    final openToSolos = nested?['open_to_solos'] as bool? ?? false;
    final maxSoloSeats = nested?['max_solo_seats'] as int? ?? 0;
    final members = g['members'] is List<GroupMemberItem>
        ? (g['members'] as List<GroupMemberItem>)
        : <GroupMemberItem>[];

    final isSelected = selectedId == gId;

    return GestureDetector(
      onTap: () {
        _groupController.selectGroup(SelectedGroup(
          id: gId,
          name: gName,
          role: role,
        ));
        SwiggyGroupRosterSheet.show(context);
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFC8019) : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFC8019).withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Group name + Role badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          gName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle,
                            size: 14, color: Color(0xFFFC8019)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLeader
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLeader ? 'Leader' : 'Member',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLeader
                          ? const Color(0xFFFC8019)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Member avatars stack & count
            Row(
              children: [
                SizedBox(
                  width: (members.length.clamp(1, 3) * 20.0) + 12,
                  height: 28,
                  child: Stack(
                    children: [
                      for (int i = 0; i < members.length.clamp(0, 3); i++)
                        Positioned(
                          left: i * 18.0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: [
                                const Color(0xFFFC8019),
                                const Color(0xFF2563EB),
                                const Color(0xFF10B981),
                              ][i % 3],
                              child: Text(
                                members[i].fullName.isNotEmpty
                                    ? members[i].fullName[0].toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${members.length} Joined',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Bottom row: Open to Solos badge or Active CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (openToSolos)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.handshake_outlined,
                            size: 11, color: Color(0xFF059669)),
                        const SizedBox(width: 3),
                        Text(
                          'Open to Solos ($maxSoloSeats)',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Private Squad',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                Text(
                  isSelected ? 'Active' : 'Tap to select',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFFFC8019)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSquadCard() {
    return GestureDetector(
      onTap: () {
        context.push('/create-group').then((_) {
          _groupController.refreshAll();
        });
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFC8019).withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_add_rounded,
                  color: Color(0xFFFC8019), size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '+ New Squad',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFC8019),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Invite friends',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySquadsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded,
                color: Color(0xFFFC8019), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan trips together with friends',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create a Squad to build itineraries, vote on stays, and split costs.',
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
            onPressed: () {
              context.push('/create-group').then((_) {
                _groupController.refreshAll();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8019),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              '+ Create',
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPlanningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC8019).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFFFC8019), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Collaboration Features',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Seamless squad coordination & voting',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _featurePill(
                  icon: Icons.how_to_vote_outlined,
                  title: 'Live Voting',
                  desc: 'Vote on stays & thrills',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _featurePill(
                  icon: Icons.splitscreen_rounded,
                  title: 'Cost Splitting',
                  desc: 'Equal budget tracking',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _featurePill(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Invites',
                  desc: 'Join squad requests',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featurePill({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFC8019), size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

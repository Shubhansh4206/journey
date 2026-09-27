import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';

class ConfirmedTripDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? tripData;

  const ConfirmedTripDashboardScreen({super.key, this.tripData});

  @override
  State<ConfirmedTripDashboardScreen> createState() =>
      _ConfirmedTripDashboardScreenState();
}

class _ConfirmedTripDashboardScreenState
    extends State<ConfirmedTripDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayFilter = 0; // 0: All, 1: Day 1, 2: Day 2, 3: Day 3, 4: Day 4

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // Guide assignment state (Operator / Squad lead can assign)
  Map<String, dynamic> _assignedGuide = {
    'name': 'Rajesh Kumar',
    'role': 'Certified Local Lead Guide',
    'rating': '4.9 ★ (120+ Trips)',
    'phone': '+91 98234 11092',
    'avatar':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    'specialization': 'Goan Coastal & Water Expeditions',
  };

  final List<Map<String, dynamic>> _availableGuides = [
    {
      'name': 'Rajesh Kumar',
      'role': 'Certified Local Lead Guide',
      'rating': '4.9 ★ (120+ Trips)',
      'phone': '+91 98234 11092',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      'specialization': 'Goan Coastal & Water Expeditions',
    },
    {
      'name': 'Anita Sharma',
      'role': 'Adventure & Scuba Specialist',
      'rating': '4.8 ★ (95 Trips)',
      'phone': '+91 98192 44320',
      'avatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80',
      'specialization': 'PADI Certified Dive Master & Trek Lead',
    },
    {
      'name': 'Vikram Deshmukh',
      'role': 'Heritage & Cultural Storyteller',
      'rating': '5.0 ★ (150+ Trips)',
      'phone': '+91 97654 88123',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'specialization': 'Old Goa Architecture & Cuisine Explorer',
    },
  ];

  // Chat messages with Guide presence clearly indicated
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Rajesh Kumar',
      'role': 'Local Guide',
      'isGuide': true,
      'time': '10:15 AM',
      'message':
          'Namaste squad! 🙏 I am Rajesh, your verified guide for Goa. I will be at Dabolim Airport Gate 3 with the AC Innova Crysta tomorrow at 10:30 AM.',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    },
    {
      'sender': 'Aarav (Leader)',
      'role': 'Squad Leader',
      'isGuide': false,
      'time': '10:18 AM',
      'message': 'Awesome Rajesh! All 6 of us have landed on the same flight.',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'sender': 'Priya',
      'role': 'Member',
      'isGuide': false,
      'time': '10:20 AM',
      'message': 'Can’t wait for the Scuba Dive at Grand Island on Day 2! 🤿',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
    {
      'sender': 'Rajesh Kumar',
      'role': 'Local Guide',
      'isGuide': true,
      'time': '10:22 AM',
      'message':
          'The waters are crystal clear this week! Scuba gear and certified PADI instructors are all confirmed for the squad.',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    },
  ];

  // Timeline Events
  final List<Map<String, dynamic>> _timelineItems = [
    {
      'day': 1,
      'date': '15 Oct 2026',
      'time': '11:00 AM',
      'title': 'Airport Pickup & Luxury AC Transfer',
      'category': 'Transport',
      'location': 'Dabolim Airport → Casa Baga Resort',
      'operator': 'Goan Coastal Transits',
      'isActivity': false,
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'day': 1,
      'date': '15 Oct 2026',
      'time': '01:00 PM',
      'title': 'Check-in: Casa Baga Beachfront Resort',
      'category': 'Hotel Stay',
      'location': 'Near Baga Beach, North Goa',
      'operator': 'Casa Baga Hospitality',
      'isActivity': false,
      'voucherRef': '#HTL-CB-40912',
      'icon': Icons.hotel_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'day': 1,
      'date': '15 Oct 2026',
      'time': '05:30 PM',
      'title': 'Sunset Cruise & Welcome Drinks',
      'category': 'Activity',
      'location': 'Mandovi River Boardwalk',
      'operator': 'Mandovi Cruises (4.9 ★)',
      'isActivity': true,
      'voucherRef': '#ACT-CRZ-9912',
      'ticketCode': 'JY-MND-8821',
      'icon': Icons.directions_boat_rounded,
      'color': Color(0xFFFC8019),
    },
    {
      'day': 2,
      'date': '16 Oct 2026',
      'time': '08:00 AM',
      'title': 'Grand Island PADI Guided Scuba Dive',
      'category': 'Activity',
      'location': 'Grand Island Reef, South Coast',
      'operator': 'Goa Dive Center (PADI Certified)',
      'isActivity': true,
      'voucherRef': '#ACT-SCUBA-5510',
      'ticketCode': 'JY-SCU-7734',
      'icon': Icons.scuba_diving_rounded,
      'color': Color(0xFF059669),
    },
    {
      'day': 2,
      'date': '16 Oct 2026',
      'time': '04:00 PM',
      'title': 'Baga Beach Parasailing & Jet Ski Speed Ride',
      'category': 'Activity',
      'location': 'Baga Watersports Deck',
      'operator': 'Coastal Sports Co.',
      'isActivity': true,
      'voucherRef': '#ACT-WTR-3391',
      'ticketCode': 'JY-WTR-6621',
      'icon': Icons.surfing_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'day': 3,
      'date': '17 Oct 2026',
      'time': '09:00 AM',
      'title': 'Dudhsagar Waterfall 4x4 Off-Road Safari',
      'category': 'Activity',
      'location': 'Bhagwan Mahaveer Sanctuary',
      'operator': 'Goa Jungle Expeditions',
      'isActivity': true,
      'voucherRef': '#ACT-DUDH-1290',
      'ticketCode': 'JY-SAF-4419',
      'icon': Icons.landscape_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'day': 3,
      'date': '17 Oct 2026',
      'time': '08:00 PM',
      'title': 'Beach Shack Seafood Feast & Bonfire',
      'category': 'Activity',
      'location': 'Anjuna Beach Shoreline',
      'operator': 'Curlies Beach Club',
      'isActivity': true,
      'voucherRef': '#ACT-FEAST-7721',
      'ticketCode': 'JY-FST-9901',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFE11D48),
    },
    {
      'day': 4,
      'date': '18 Oct 2026',
      'time': '11:00 AM',
      'title': 'Resort Checkout & Return Airport Drop',
      'category': 'Transport',
      'location': 'Casa Baga Resort → Dabolim Airport',
      'operator': 'Goan Coastal Transits',
      'isActivity': false,
      'icon': Icons.flight_takeoff_rounded,
      'color': Color(0xFF64748B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _openHotelInMaps() async {
    // Hotel location: Casa Baga, North Goa
    const lat = 15.5553;
    const lng = 73.7517;
    const hotelName = 'Casa Baga Beachfront Resort';

    final googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$hotelName');

    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening coordinates: $lat, $lng ($hotelName)'),
            backgroundColor: const Color(0xFF1E2430),
          ),
        );
      }
    }
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'sender': 'You',
        'role': 'Member',
        'isGuide': false,
        'time': 'Just now',
        'message': text,
        'avatar': 'https://i.pravatar.cc/150?img=60',
      });
    });

    _chatController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showActivityVoucherModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          'CONFIRMED VOUCHER',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['voucherRef'] ?? '#JY-VOUCH-8821',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                item['title'] ?? 'Activity Booking',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${item['date']} • ${item['time']} • ${item['location']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // QR Code Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Mock Visual Scannable QR Code
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grid pattern simulating QR
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                            ),
                            itemCount: 36,
                            itemBuilder: (context, i) {
                              final isCorner = i == 0 ||
                                  i == 1 ||
                                  i == 6 ||
                                  i == 7 ||
                                  i == 4 ||
                                  i == 5 ||
                                  i == 10 ||
                                  i == 11 ||
                                  i == 24 ||
                                  i == 25 ||
                                  i == 30 ||
                                  i == 31;
                              final isFill = isCorner || (i % 3 == 0) || (i % 5 == 1);
                              return Container(
                                decoration: BoxDecoration(
                                  color: isFill ? Colors.black87 : Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified,
                                color: Color(0xFFFC8019), size: 22),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ticket Code: ${item['ticketCode'] ?? 'JY-88219-EXP'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Present this QR Code to ${item['operator']} on arrival',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.tripData?['destination'] ??
              widget.tripData?['city'] ??
              widget.tripData?['name'] ??
              'Goa',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin_circle_rounded,
                color: Color(0xFF2563EB)),
            tooltip: 'Assign / Change Guide (Operator)',
            onPressed: _showAssignGuideModal,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          labelColor: const Color(0xFF0F172A),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF0F172A),
          indicatorWeight: 3,
          labelPadding: EdgeInsets.zero,
          labelStyle:
              GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.timeline_rounded, size: 18), text: 'Timeline'),
            Tab(icon: Icon(Icons.map_rounded, size: 18), text: 'Hotel Map'),
            Tab(icon: Icon(Icons.folder_shared_rounded, size: 18), text: 'Vault'),
            Tab(icon: Icon(Icons.forum_rounded, size: 18), text: 'Squad Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Chronological Feed (Timeline) & Activity Vouchers
          _buildTimelineTab(),

          // Tab 2: Embedded Mini-Map
          _buildMapTab(),

          // Tab 3: Shared Document Vault
          _buildDocumentVaultTab(),

          // Tab 4: Integrated Group Chatbox
          _buildSquadChatTab(),
        ],
      ),
    );
  }

  // ── Component 1 & Tab 2: Embedded Mini-Map ────────────────────────────────
  Widget _buildMapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hotel Location & Live Navigation',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          Text(
            'Tap the map snippet below to open live directions in Google Maps or Apple Maps.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Embedded Mini-Map Widget
          InkWell(
            onTap: _openHotelInMaps,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Stylized Map Background
                  Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),

                  // Map Roads / Pin overlay graphic
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC8019),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFC8019).withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '📍 Casa Baga Beachfront Resort',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom action pill
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded,
                              size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            'Open in Maps ↗',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Hotel Details Card
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Casa Baga Beachfront Resort',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '4.8 ★',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFC8019),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Near Baga Beach Shoreline, North Goa, 403516',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Booking Ref: HTL-CB-40912 (3 Luxury Deluxe Cabanas)',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // ── Operator Guide Assignment Modal ──────────────────────────────────────
  void _showAssignGuideModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                        child: const Icon(Icons.badge_rounded,
                            color: Color(0xFF2563EB), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Assign Tour Guide',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Operator Console',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Assign a certified local expert to manage transfers, activities & live assistance.',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ..._availableGuides.map((guide) {
                final isAssigned = _assignedGuide['name'] == guide['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAssigned
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: isAssigned ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(guide['avatar'] as String),
                    ),
                    title: Row(
                      children: [
                        Text(
                          guide['name'] as String,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${guide['role']} • ${guide['rating']}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          guide['specialization'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: isAssigned
                          ? null
                          : () {
                              setState(() {
                                _assignedGuide = guide;
                                _chatMessages.add({
                                  'sender': guide['name'],
                                  'role': 'Local Guide',
                                  'isGuide': true,
                                  'time': 'Just now',
                                  'message':
                                      'Namaste squad! I am ${guide['name']}, your assigned local guide. Let me know if you need anything!',
                                  'avatar': guide['avatar'],
                                });
                              });
                              Navigator.pop(modalCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎉 Assigned ${guide['name']} as trip guide for squad & operator!',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFF2563EB),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAssigned
                            ? const Color(0xFF059669)
                            : AppColors.primaryDarkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isAssigned ? 'Assigned ✓' : 'Assign',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Component 2 & 3: Chronological Feed (Timeline) & Activity Vouchers ─────
  Widget _buildTimelineTab() {
    final filtered = _selectedDayFilter == 0
        ? _timelineItems
        : _timelineItems
            .where((item) => item['day'] == _selectedDayFilter)
            .toList();

    return Column(
      children: [
        // Assigned Tour Guide Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(_assignedGuide['avatar'] as String),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _assignedGuide['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 13, color: Color(0xFF2563EB)),
                      ],
                    ),
                    Text(
                      '${_assignedGuide['role']} • ${_assignedGuide['phone']}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _showAssignGuideModal,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Day filter chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDayFilterChip(0, 'All Days (4)'),
                _buildDayFilterChip(1, 'Day 1 • Oct 15'),
                _buildDayFilterChip(2, 'Day 2 • Oct 16'),
                _buildDayFilterChip(3, 'Day 3 • Oct 17'),
                _buildDayFilterChip(4, 'Day 4 • Oct 18'),
              ],
            ),
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Vertical Timeline List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final isLast = index == filtered.length - 1;
              final color = item['color'] as Color;
              final isActivity = item['isActivity'] as bool;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Node Column
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Icon(item['icon'] as IconData,
                              size: 15, color: color),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Timeline Content Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item['date']} • ${item['time']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['category'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📍 ${item['location']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Operator: ${item['operator']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),

                            // Component 3: Activity Vouchers (QR / View Ticket button)
                            if (isActivity) ...[
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Voucher Code: ${item['ticketCode']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _showActivityVoucherModal(item),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFFEDD5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.qr_code_2_rounded,
                                              size: 14,
                                              color: Color(0xFFFC8019)),
                                          const SizedBox(width: 5),
                                          Text(
                                            'View Ticket / QR',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFC8019),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayFilterChip(int dayIndex, String label) {
    final isSelected = _selectedDayFilter == dayIndex;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedDayFilter = dayIndex),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  // ── Component 4: Shared Document Vault ────────────────────────────────────
  Widget _buildDocumentVaultTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared Document Vault',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          Text(
            'Single repository for all squad travel vouchers, PDF itineraries & emergency contacts.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Official Itinerary PDF
          _buildVaultItem(
            icon: Icons.picture_as_pdf_rounded,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            title: 'Official Goa Squad Itinerary (PDF)',
            subtitle: 'Complete 4-day verified schedule • 2.4 MB',
            badge: 'PDF READY',
            badgeColor: const Color(0xFFDC2626),
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading Itinerary PDF (2.4 MB)...'),
                  backgroundColor: Color(0xFF1E2430),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 2. Hotel Confirmation Numbers
          _buildVaultItem(
            icon: Icons.hotel_rounded,
            iconBg: const Color(0xFFEDE9FE),
            iconColor: const Color(0xFF7C3AED),
            title: 'Hotel Confirmation: Casa Baga Resort',
            subtitle: 'Booking ID: #HTL-CB-40912 • 3 Deluxe Cabanas',
            badge: 'CHECK-IN READY',
            badgeColor: const Color(0xFF7C3AED),
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hotel Confirmation #HTL-CB-40912 verified with front desk.'),
                  backgroundColor: Color(0xFF7C3AED),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. Emergency Contacts Repository
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emergency_rounded,
                          color: Color(0xFF059669), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Emergency & Support Contacts',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEmergencyContactRow(
                    '🧑‍💼 Rajesh Kumar (Lead Tour Guide)', '+91 98231 44510'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _buildEmergencyContactRow(
                    '📞 24x7 Trip Concierge Helpline', '1800 120 4090'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _buildEmergencyContactRow(
                    '🚑 Goa Coastal & Medical SOS', '112 / 1093'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textSecondary),
            onPressed: onAction,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactRow(String name, String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkCharcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: () async {
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.call, size: 12, color: Color(0xFF2563EB)),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Component 5: Integrated Group Chatbox ─────────────────────────────────
  Widget _buildSquadChatTab() {
    return Column(
      children: [
        // Guide Presence Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFFFF7ED),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFC8019),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Local Guide Rajesh Kumar is active in this squad chat.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9A3412),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ONLINE',
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Chat Message List
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              final isMe = msg['sender'] == 'You';
              final isGuide = msg['isGuide'] as bool;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(msg['avatar']),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFFC8019)
                              : (isGuide
                                  ? const Color(0xFFFFFBEB)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMe
                                ? Colors.transparent
                                : (isGuide
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFE2E8F0)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg['sender'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: isGuide
                                          ? const Color(0xFFB45309)
                                          : AppColors.darkCharcoal,
                                    ),
                                  ),
                                  if (isGuide) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'LOCAL GUIDE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              msg['message'],
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: isMe ? Colors.white : AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg['time'],
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: isMe ? Colors.white70 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?img=60'),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Chat Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Message squad & guide...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFC8019),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

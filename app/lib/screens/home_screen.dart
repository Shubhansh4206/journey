import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/cart_controller.dart';
import '../controllers/group_controller.dart';
import '../data/mock_city_catalog.dart';
import '../models/group_models.dart';
import '../models/trip_request.dart';
import '../screens/group_picker_sheet.dart';
import '../screens/itinerary_cart_screen.dart';
import '../services/profile_service.dart';
import '../utils/colors.dart';
import '../widgets/swiggy_group_roster_sheet.dart';
import '../widgets/travel_mode_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());
  final CartController _cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  bool _isSolo = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _vibeCategories = [
    {'name': 'All', 'icon': Icons.explore_outlined},
    {'name': 'Mountains', 'icon': Icons.landscape_outlined},
    {'name': 'Beaches', 'icon': Icons.beach_access_outlined},
    {'name': 'Heritage', 'icon': Icons.castle_outlined},
    {'name': 'Wellness', 'icon': Icons.spa_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _groupController.refreshAll();
  }

  Future<void> _loadUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // 1. Initial metadata fallback
    final metaName = user.userMetadata?['display_name'] ??
        user.userMetadata?['full_name'] ??
        user.email?.split('@').first;
    if (metaName != null &&
        metaName.toString().isNotEmpty &&
        ProfileService.currentUserNameNotifier.value == null) {
      ProfileService.currentUserNameNotifier.value = metaName.toString();
    }

    // 2. Query user profile from database to get fresh full_name
    try {
      final profile = await ProfileService().getProfile(user.id);
      if (profile != null && profile.fullName.trim().isNotEmpty) {
        ProfileService.currentUserNameNotifier.value = profile.fullName.trim();
      }
    } catch (e) {
      debugPrint('Error loading user profile in HomeScreen: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CityCatalog> get _filteredCities {
    return mockCities.where((city) {
      final matchesSearch = _searchQuery.isEmpty ||
          city.name.toLowerCase().contains(_searchQuery) ||
          city.tagline.toLowerCase().contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Coastal') {
        return city.id == 'mumbai' || city.id == 'goa';
      }
      if (_selectedCategory == 'Beaches') {
        return city.id == 'goa';
      }
      if (_selectedCategory == 'Heritage') {
        return city.id == 'jaipur' || city.id == 'udaipur';
      }
      if (_selectedCategory == 'Lakes') {
        return city.id == 'udaipur';
      }
      return true;
    }).toList();
  }

  void _openCart(CityCatalog city) {
    _cartController.setCity(city);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryCartScreen(
          city: city,
          isSolo: _isSolo,
        ),
      ),
    ).then((_) {
      _groupController.refreshAll();
      if (mounted) setState(() {});
    });
  }

  void _showCartSheet() {
    final count = _cartController.itemCount;
    final activeCity = _cartController.activeCity.value;

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFC8019), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Itinerary Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        Text(
                          count > 0 ? '$count item(s) selected for ${activeCity?.name ?? "trip"}' : 'No items added yet',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (count > 0)
                    TextButton(
                      onPressed: () {
                        _cartController.clearCart();
                        Navigator.pop(ctx);
                        setState(() {});
                      },
                      child: Text('Clear', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (count > 0 && activeCity != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Destination', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    Text(activeCity.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    Text(_cartController.progressStatusText, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFFC8019))),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openCart(activeCity);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFC8019),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Resume & Edit Itinerary', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ] else ...[
                Text(
                  'Select a destination below to start picking stays, thrills, and sightseeing spots:',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mockCities.map((city) {
                    return ActionChip(
                      avatar: const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFFC8019)),
                      label: Text(city.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openCart(city);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDateShort(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildItineraryProgressCard() {
    return Obx(() {
      final hasCart = _cartController.hasActiveCart;
      final city = _cartController.activeCity.value;
      final count = _cartController.itemCount;
      final progress = _cartController.progressPercentage;

      if (!hasCart) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFC8019), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Itinerary Cart is Ready',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      'Pick a destination below to add stays, sights & thrill activities.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _showCartSheet,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFC8019)),
                  foregroundColor: const Color(0xFFFC8019),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text('View Cart', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFC8019).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFC8019).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.route_rounded, color: Color(0xFFFC8019), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        city != null ? '${city.name} Itinerary Cart' : 'Draft Itinerary',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      Text(
                        '$count Item${count == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFC8019),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : 0.25,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFC8019)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (city != null) {
                  _openCart(city);
                } else if (mockCities.isNotEmpty) {
                  _openCart(mockCities.first);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC8019),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Resume', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
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
                      child: const Icon(Icons.send_rounded, color: Color(0xFF2563EB), size: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                      const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Sync',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
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
                separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    req.tripMode.contains('Solo') ? Icons.person_rounded : Icons.groups_rounded,
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
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
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
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF2563EB)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                _specRow('Assigned Squad', req.assignedGroupName ?? 'Solo Explorer'),
                _specRow('Travel Dates', '${_formatDateShort(req.startDate)} → ${_formatDateShort(req.endDate)}'),
                _specRow('Per Person Budget', '₹${req.perPersonBudget.toStringAsFixed(2)}'),
                if (req.estimatedMockTotal > 0)
                  _specRow('Mock Estimated Total', '₹${req.estimatedMockTotal.toStringAsFixed(2)}'),

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
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final bottomSheetNav = Navigator.of(ctx);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: Text('Cancel Trip Request', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            content: Text('Are you sure you want to cancel this trip request?', style: GoogleFonts.poppins()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dCtx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                child: const Text('Cancel Request', style: TextStyle(color: Colors.white)),
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
                                content: Text('Trip request cancelled.', style: GoogleFonts.poppins()),
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel This Request', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
              style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 12),
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
                      color: i <= currentStep ? const Color(0xFFFC8019) : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: i < currentStep
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                      color: i < currentStep ? const Color(0xFFFC8019) : Colors.grey.shade200,
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
                        fontWeight: i <= currentStep ? FontWeight.bold : FontWeight.w500,
                        color: i <= currentStep ? AppColors.darkCharcoal : AppColors.textMuted,
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
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
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
          color: count > 0 ? const Color(0xFFFC8019).withValues(alpha: 0.3) : Colors.transparent,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.groups_rounded, color: Color(0xFFFC8019), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Travel Squads',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    if (groups.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC8019).withValues(alpha: 0.12),
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
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        context.push('/create-group').then((_) {
                          _groupController.refreshAll();
                        });
                      },
                      icon: const Icon(Icons.add, size: 14, color: Color(0xFFFC8019)),
                      label: Text(
                        'New Squad',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFC8019),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
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
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFFFC8019)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLeader ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLeader ? 'Leader' : 'Member',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLeader ? const Color(0xFFFC8019) : const Color(0xFF2563EB),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.handshake_outlined, size: 11, color: Color(0xFF059669)),
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
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                  ),
                Text(
                  isSelected ? 'Active' : 'Tap to select',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFFFC8019) : AppColors.textMuted,
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
              child: const Icon(Icons.group_add_rounded, color: Color(0xFFFC8019), size: 20),
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
            child: const Icon(Icons.groups_rounded, color: Color(0xFFFC8019), size: 24),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              '+ Create',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final defaultUserName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first ??
        'Explorer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Upgraded App Bar with reactive dynamic user name
            SliverToBoxAdapter(
              child: ValueListenableBuilder<String?>(
                valueListenable: ProfileService.currentUserNameNotifier,
                builder: (context, dynamicName, _) {
                  final activeName = (dynamicName != null && dynamicName.trim().isNotEmpty)
                      ? dynamicName
                      : defaultUserName;
                  return _buildUpgradedHeader(activeName);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Swiggy-Style Active Itinerary Tracking Banner
            SliverToBoxAdapter(
              child: _buildItineraryProgressCard(),
            ),

            // Live Sent Trip Requests to Tour Operators
            SliverToBoxAdapter(
              child: _buildSentTripRequestsSection(),
            ),

            // My Travel Squads Feed
            SliverToBoxAdapter(
              child: _buildMySquadsSection(),
            ),

            // Core Travel Mode Toggle
            SliverToBoxAdapter(
              child: TravelModeToggle(
                isSolo: _isSolo,
                onChanged: (solo) => setState(() => _isSolo = solo),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Mode Explanation Card
            SliverToBoxAdapter(child: _buildModeBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Destination Search Bar
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Vibe Category Filters
            SliverToBoxAdapter(child: _buildVibeCategories()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Destinations Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Featured Destinations',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC8019).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_filteredCities.length} Cities',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFC8019),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Destinations List / Grid
            _filteredCities.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final city = _filteredCities[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildDestinationExploreCard(city),
                          );
                        },
                        childCount: _filteredCities.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Explore Section 1: Top Trending Experiences Carousel
            SliverToBoxAdapter(child: _buildTrendingExperiences()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Explore Section 2: Curated Trip Packages Showcase
            SliverToBoxAdapter(child: _buildCuratedPackagesSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Explore Section 3: Trust & Guarantee Banner
            SliverToBoxAdapter(child: _buildTrustFooterBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Upgraded Header ───────────────────────────────────────────────────────
  Widget _buildUpgradedHeader(String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Swiggy-Style Action Row: Squad Pill on left, Cart & Notifications on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Swiggy-Style Squad Selector Pill (Location Style)
              Expanded(
                child: GestureDetector(
                  onTap: () => SwiggyGroupRosterSheet.show(context),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Obx(() {
                      final selected = _groupController.selectedGroup.value;
                      final memberCount = selected != null
                          ? _groupController.getMembersForGroup(selected.id).length
                          : 0;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: Color(0xFFFC8019), // Swiggy Orange
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              selected != null
                                  ? '${selected.name} (${memberCount > 0 ? '$memberCount joined' : 'Squad'})'
                                  : 'Select Travel Squad',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              // 2. Right Side Actions: Cart Progress Pill + Notifications Bell
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Swiggy-Style Cart Itinerary Pill
                  Obx(() {
                    final count = _cartController.itemCount;
                    final activeCity = _cartController.activeCity.value;

                    return GestureDetector(
                      onTap: () {
                        if (count > 0 && activeCity != null) {
                          _openCart(activeCity);
                        } else {
                          _showCartSheet();
                        }
                      },
                      onLongPress: _showCartSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: count > 0
                                ? const Color(0xFFFC8019)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 15,
                              color: count > 0
                                  ? const Color(0xFFFC8019)
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              count > 0 ? '$count in Cart' : 'Cart',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: count > 0
                                    ? const Color(0xFFFC8019)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),

                  // Notifications Bell with Live Badge
                  Obx(() {
                    final inviteCount = _groupController.pendingInvitesCount.value;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.darkCharcoal,
                            size: 22,
                          ),
                          tooltip: 'Group Invitations',
                          onPressed: () async {
                            await context.push('/invites');
                            _groupController.fetchPendingInvitesCount();
                          },
                        ),
                        if (inviteCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF0052),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                inviteCount > 9 ? '9+' : '$inviteCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // User Greeting & Avatar
          Row(
            children: [
              GestureDetector(
                onLongPress: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) context.go('/login');
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFC8019),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF60B246),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hey, $userName',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('👋', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  Text(
                    'Where are we traveling next?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mode Explanation Card ─────────────────────────────────────────────────
  Widget _buildModeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _isSolo ? const Color(0xFFFFF0F5) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isSolo ? const Color(0xFFFFCCE1) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSolo ? Icons.person_pin_circle : Icons.groups_rounded,
            color: _isSolo ? AppColors.punchPink : AppColors.electricBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isSolo
                  ? 'Solo Mode: Build your itinerary cart and match with open travel squads!'
                  : 'Squad Mode: Custom-build trip details and get quotes from verified local operators.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Destination Search Bar ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) =>
              setState(() => _searchQuery = val.trim().toLowerCase()),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkCharcoal,
          ),
          decoration: InputDecoration(
            hintText: 'Search destinations (e.g. Manali, Goa, Jaipur)...',
            hintStyle:
                GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
            prefixIcon:
                const Icon(Icons.search, color: Color(0xFFFC8019), size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC8019).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFFFC8019),
                      size: 16,
                    ),
                  ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Vibe Category Filters ─────────────────────────────────────────────────
  Widget _buildVibeCategories() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _vibeCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _vibeCategories[index];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = _selectedCategory == name;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = name),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E2430) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E2430)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? const Color(0xFFFC8019)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Destination Full Explore Card ─────────────────────────────────────────
  Widget _buildDestinationExploreCard(CityCatalog city) {
    return InkWell(
      onTap: () => _openCart(city),
      borderRadius: BorderRadius.circular(20),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Badges
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  city.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: city.accent.withValues(alpha: 0.2),
                    child: Icon(Icons.landscape, size: 48, color: city.accent),
                  ),
                ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60B246),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '4.9 (1.2k+)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${city.hotels.length + city.activities.length + city.places.length} Experiences',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      city.tagline,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action & Info Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED AVG BUDGET',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'From ₹15,000 / person',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _openCart(city),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC8019),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Build Itinerary',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── Explore Section 1: Trending Experiences ───────────────────────────────
  Widget _buildTrendingExperiences() {
    final experiences = [
      {
        'title': 'Marine Drive Sunset Cruise',
        'city': 'Mumbai',
        'price': '₹2,200',
        'icon': Icons.directions_boat,
        'color': const Color(0xFF2373F4),
        'cityObj': mockCities.firstWhere((c) => c.id == 'mumbai'),
      },
      {
        'title': 'Sunset Mandovi Cruise',
        'city': 'Goa',
        'price': '₹1,800',
        'icon': Icons.directions_boat,
        'color': const Color(0xFFFF0052),
        'cityObj': mockCities.firstWhere((c) => c.id == 'goa'),
      },
      {
        'title': 'Sunrise Hot Air Balloon',
        'city': 'Jaipur',
        'price': '₹8,500',
        'icon': Icons.air,
        'color': const Color(0xFF9564DD),
        'cityObj': mockCities.firstWhere((c) => c.id == 'jaipur'),
      },
      {
        'title': 'Lake Pichola Sunset Boat',
        'city': 'Udaipur',
        'price': '₹1,200',
        'icon': Icons.sailing,
        'color': const Color(0xFF10B981),
        'cityObj': mockCities.firstWhere((c) => c.id == 'udaipur'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔥 Top Must-Do Experiences',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Text(
                'Swipe right →',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: experiences.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final exp = experiences[index];
              final title = exp['title'] as String;
              final cityName = exp['city'] as String;
              final price = exp['price'] as String;
              final icon = exp['icon'] as IconData;
              final color = exp['color'] as Color;
              final cityObj = exp['cityObj'] as CityCatalog;

              return InkWell(
                onTap: () => _openCart(cityObj),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 190,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cityName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF60B246),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Explore Section 2: Curated Trip Packages ──────────────────────────────
  Widget _buildCuratedPackagesSection() {
    final packages = [
      {
        'title': 'Mumbai Coastal & Bollywood Vibes',
        'days': '3 Days / 2 Nights',
        'vibe': '🌆 Urban & Coastal',
        'badge': 'BESTSELLER',
        'cityObj': mockCities.firstWhere((c) => c.id == 'mumbai'),
      },
      {
        'title': 'Goa Sunsets, Beaches & Shacks',
        'days': '5 Days / 4 Nights',
        'vibe': '🏖️ Beach Party',
        'badge': 'POPULAR',
        'cityObj': mockCities.firstWhere((c) => c.id == 'goa'),
      },
      {
        'title': 'Jaipur Royal Palaces & Bazaars',
        'days': '3 Days / 2 Nights',
        'vibe': '🏰 Royal Heritage',
        'badge': 'FEATURED',
        'cityObj': mockCities.firstWhere((c) => c.id == 'jaipur'),
      },
      {
        'title': 'Udaipur Royal Lakes & Sunsets',
        'days': '4 Days / 3 Nights',
        'vibe': '⛵ Romantic Lakes',
        'badge': 'EXCLUSIVE',
        'cityObj': mockCities.firstWhere((c) => c.id == 'udaipur'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎒 Curated Squad & Solo Packages',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          ...packages.map((pkg) {
            final cityObj = pkg['cityObj'] as CityCatalog;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  pkg['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                subtitle: Text(
                  '${pkg['days']} • ${pkg['vibe']}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _openCart(cityObj),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Explore',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFC8019),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Explore Section 3: Trust Footer Banner ────────────────────────────────
  Widget _buildTrustFooterBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: Color(0xFFFC8019), size: 20),
              const SizedBox(width: 8),
              Text(
                'WHY PLAN WITH JOURNEY?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _trustFeatureTile(
                    Icons.bolt, 'Fast Quotes', 'Within 24h'),
              ),
              Expanded(
                child: _trustFeatureTile(
                    Icons.group_work, 'Squad Match', 'Per person budget'),
              ),
              Expanded(
                child: _trustFeatureTile(
                    Icons.shield, '100% Verified', 'Local operators'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trustFeatureTile(IconData icon, String title, String sub) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFC8019), size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  // ── Empty Search State ────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No matching destinations',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching for "Manali", "Goa", "Jaipur", "Rishikesh", or "Udaipur"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

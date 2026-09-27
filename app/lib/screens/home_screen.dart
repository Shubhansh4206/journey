import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/cart_controller.dart';
import '../controllers/group_controller.dart';
import '../data/mock_city_catalog.dart';
import '../screens/itinerary_cart_screen.dart';
import '../services/profile_service.dart';
import '../services/travel_mode_service.dart';
import '../utils/colors.dart';
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
    _isSolo = TravelModeService.isSolo;
    TravelModeService.isSoloNotifier.addListener(_onTravelModeChanged);
    _loadUserName();
    _groupController.refreshAll();
  }

  void _onTravelModeChanged() {
    if (mounted && _isSolo != TravelModeService.isSolo) {
      setState(() {
        _isSolo = TravelModeService.isSolo;
      });
    }
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
    TravelModeService.isSoloNotifier.removeListener(_onTravelModeChanged);
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
    _cartController.setCity(city, isSolo: _isSolo);
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
        child: Stack(
          children: [
            CustomScrollView(
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

                // Core Travel Mode Toggle
                SliverToBoxAdapter(
                  child: TravelModeToggle(
                    isSolo: _isSolo,
                    onChanged: (solo) {
                      setState(() => _isSolo = solo);
                      TravelModeService.setSolo(solo);
                    },
                  ),
                ),
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
                                color: AppColors.nearBlack,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.softGrey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '${_filteredCities.length} Cities',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDarkBlue,
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
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
              ],
            ),

            // Sleek Floating Cart Bar (Home screen only, non-intrusive)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _buildFloatingCartBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Floating Cart Bar ──────────────────────────────────────────────────────
  Widget _buildFloatingCartBar() {
    return Obx(() {
      final isSolo = _isSolo;
      final count = _cartController.itemCountFor(isSolo);
      final city = _cartController.activeCityFor(isSolo).value;

      if (count == 0 || city == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          city.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count item${count > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _cartController.progressStatusTextFor(isSolo),
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _openCart(city),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Resume',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Upgraded Header ───────────────────────────────────────────────────────
  Widget _buildUpgradedHeader(String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Greeting & Avatar
          Expanded(
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Hey, $userName',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 18)),
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
                ),
              ],
            ),
          ),

          // Notifications Bell with Live Badge
          Obx(() {
            final inviteCount = _groupController.pendingInvitesCount.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 38, minHeight: 38),
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkCharcoal,
                    size: 24,
                  ),
                  tooltip: 'Group Invitations',
                  onPressed: () async {
                    await context.push('/invites');
                    _groupController.fetchPendingInvitesCount();
                  },
                ),
                if (inviteCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
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
    );
  }



  // ── Destination Search Bar ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) =>
              setState(() => _searchQuery = val.trim().toLowerCase()),
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Search destinations',
            hintStyle:
                GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF94A3B8)),
            prefixIcon:
                const Icon(Icons.search, color: Color(0xFF0F172A), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF0F172A),
                      size: 15,
                    ),
                  ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  // ── Vibe Category Filters ─────────────────────────────────────────────────
  Widget _buildVibeCategories() {
    return SizedBox(
      height: 40,
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
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
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
                  height: 195,
                  width: double.infinity,
                  child: Image.network(
                    city.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.landscape, size: 48, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                Container(
                  height: 195,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.35, 0.65, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '4.9 (1.2k+)',
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
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xFF0F172A),
                      size: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        city.tagline,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action & Info Section
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Row with clean layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ESTIMATED AVG BUDGET',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'From ₹15,000 / person',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Verified Stays',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Dedicated Action Button (Pill shaped, rich Dark Blue)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _openCart(city),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Build Itinerary',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 16, color: Colors.white),
                        ],
                      ),
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
        'icon': Icons.directions_boat_rounded,
        'color': const Color(0xFF0F172A),
        'cityObj': mockCities.firstWhere((c) => c.id == 'mumbai'),
      },
      {
        'title': 'Sunset Mandovi Cruise',
        'city': 'Goa',
        'price': '₹1,800',
        'icon': Icons.directions_boat_rounded,
        'color': const Color(0xFF0F172A),
        'cityObj': mockCities.firstWhere((c) => c.id == 'goa'),
      },
      {
        'title': 'Sunrise Hot Air Balloon',
        'city': 'Jaipur',
        'price': '₹8,500',
        'icon': Icons.air_rounded,
        'color': const Color(0xFF0F172A),
        'cityObj': mockCities.firstWhere((c) => c.id == 'jaipur'),
      },
      {
        'title': 'Lake Pichola Sunset Boat',
        'city': 'Udaipur',
        'price': '₹1,200',
        'icon': Icons.sailing_rounded,
        'color': const Color(0xFF0F172A),
        'cityObj': mockCities.firstWhere((c) => c.id == 'udaipur'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Top Must-Do Experiences',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: experiences.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final exp = experiences[index];
              final title = exp['title'] as String;
              final cityName = exp['city'] as String;
              final price = exp['price'] as String;
              final icon = exp['icon'] as IconData;
              final cityObj = exp['cityObj'] as CityCatalog;

              return InkWell(
                onTap: () => _openCart(cityObj),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              cityName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
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
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
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
    final groupPackages = [
      {
        'title': 'Goa Beach Villa & Yacht Party',
        'days': '4 Days / 3 Nights',
        'vibe': 'Squad Beach & Nightlife',
        'badge': 'BESTSELLER',
        'price': '₹4,999/pax',
        'highlights': 'Private Villa • Scuba Diving • Sunset Yacht',
        'cityObj': mockCities.firstWhere((c) => c.id == 'goa'),
      },
      {
        'title': 'Udaipur Royal Haveli & Heritage Feast',
        'days': '3 Days / 2 Nights',
        'vibe': 'Heritage Forts & Group Dining',
        'badge': 'POPULAR',
        'price': '₹6,500/pax',
        'highlights': 'Heritage Suite • Lake Cruise • Candlelight Dinner',
        'cityObj': mockCities.firstWhere((c) => c.id == 'udaipur'),
      },
      {
        'title': 'Jaipur Fort Treks & Grand Bazaar',
        'days': '3 Days / 2 Nights',
        'vibe': 'Palaces & Cultural Squad Tours',
        'badge': 'FEATURED',
        'price': '₹5,200/pax',
        'highlights': 'Nahargarh Sunset • Jeep Safari • Chokhi Dhani',
        'cityObj': mockCities.firstWhere((c) => c.id == 'jaipur'),
      },
      {
        'title': 'Mumbai Coastal Cruise & Street Eats',
        'days': '2 Days / 1 Night',
        'vibe': 'Urban Night Squad Trails',
        'badge': 'EXCLUSIVE',
        'price': '₹3,800/pax',
        'highlights': 'Marine Drive Cruise • Street Food Trail • Midnight Cycling',
        'cityObj': mockCities.firstWhere((c) => c.id == 'mumbai'),
      },
    ];

    final soloPackages = [
      {
        'title': 'Goa Hostels, Scuba & Co-Working',
        'days': '5 Days / 4 Nights',
        'vibe': 'Surfing, Cafes & Co-Working',
        'badge': 'BESTSELLER',
        'price': '₹4,499/pax',
        'highlights': 'Beach Hostel Dorm • Scuba Intro • Co-working Pass',
        'cityObj': mockCities.firstWhere((c) => c.id == 'goa'),
      },
      {
        'title': 'Udaipur Photography & Old City Walks',
        'days': '3 Days / 2 Nights',
        'vibe': 'Heritage Strolls & Lake Sunsets',
        'badge': 'POPULAR',
        'price': '₹5,800/pax',
        'highlights': 'Boutique Stay • Photo Walk • Ghat Sunsets',
        'cityObj': mockCities.firstWhere((c) => c.id == 'udaipur'),
      },
      {
        'title': 'Jaipur Cultural Immersion & Pottery',
        'days': '3 Days / 2 Nights',
        'vibe': 'Art, Crafts & Local Cafes',
        'badge': 'FEATURED',
        'price': '₹4,900/pax',
        'highlights': 'Heritage Homestay • Blue Pottery Workshop • Cafe Hopping',
        'cityObj': mockCities.firstWhere((c) => c.id == 'jaipur'),
      },
      {
        'title': 'Mumbai Art Deco & Heritage Trail',
        'days': '2 Days / 1 Night',
        'vibe': 'Solo City Explorations',
        'badge': 'EXCLUSIVE',
        'price': '₹3,200/pax',
        'highlights': 'Colaba Art Walk • Seaside Cafes • Sunset at Marine Drive',
        'cityObj': mockCities.firstWhere((c) => c.id == 'mumbai'),
      },
    ];

    final activePackages = _isSolo ? soloPackages : groupPackages;
    final sectionTitle = _isSolo ? 'Curated Solo Packages' : 'Curated Group Packages';
    final sectionSubtitle = _isSolo
        ? 'Handpicked solo getaways with verified stays & community vibes'
        : 'Pre-configured squad getaways with verified group discounts';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sectionTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isSolo ? 'Solo Mode' : 'Group Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sectionSubtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 14),
          ...activePackages.map((pkg) {
            final cityObj = pkg['cityObj'] as CityCatalog;
            final badge = pkg['badge'] as String;
            final price = pkg['price'] as String;
            final highlights = pkg['highlights'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pkg['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pkg['days']} • ${pkg['vibe']}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    highlights,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Package Starting',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _openCart(cityObj),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'View',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 12, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: Colors.white, size: 20),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _trustFeatureTile(
                    Icons.bolt_rounded, 'Fast Quotes', 'Within 24h'),
              ),
              Expanded(
                child: _trustFeatureTile(
                    Icons.group_work_rounded, 'Squad Match', 'Per person budget'),
              ),
              Expanded(
                child: _trustFeatureTile(
                    Icons.shield_rounded, '100% Verified', 'Local operators'),
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
        Icon(icon, color: Colors.white, size: 22),
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
          sub,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            color: const Color(0xFF94A3B8),
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

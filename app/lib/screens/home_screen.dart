import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';
import '../screens/itinerary_cart_screen.dart';
import '../utils/colors.dart';
import '../widgets/travel_mode_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryCartScreen(
          city: city,
          isSolo: _isSolo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first ??
        'Explorer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Upgraded App Bar
            SliverToBoxAdapter(child: _buildUpgradedHeader(userName)),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

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
          // Location Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFFFC8019), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'New Delhi, IN',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textMuted, size: 14),
                  ],
                ),
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.darkCharcoal,
                          size: 24,
                        ),
                        onPressed: () => context.push('/invites'),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF0052),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    return Container(
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

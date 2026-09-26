import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_city_catalog.dart';
import '../utils/colors.dart';
import 'itinerary_cart_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // ── 1. Mock Data: Inspiration Packages ───────────────────────────────────────
  static const List<Map<String, dynamic>> _packages = [
    {
      'title': 'The Ultimate Udaipur Weekend',
      'price': 'From ₹6,500/pax',
      'duration': '3 Days • 2 Nights',
      'activities': ['City Palace Tour', 'Lake Pichola Boat', 'Rooftop Dining'],
      'imageUrl':
          'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'title': 'Goa Scuba & Sun',
      'price': 'From ₹4,999/pax',
      'duration': '4 Days • 3 Nights',
      'activities': ['Grand Island Scuba', 'Parasailing at Baga', 'Beach BBQ'],
      'imageUrl':
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'title': 'Manali Peak Expedition',
      'price': 'From ₹7,800/pax',
      'duration': '5 Days • 4 Nights',
      'activities': ['Solang Paragliding', 'Rohtang Pass Trek', 'Old Manali Cafes'],
      'imageUrl':
          'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1200&q=80',
    },
  ];

  // ── 2. Mock Data: Upcoming Long Weekends ─────────────────────────────────────
  static const List<Map<String, dynamic>> _longWeekends = [
    {
      'name': 'Gandhi Jayanti Escape',
      'dates': 'Oct 2 - Oct 4',
      'squadsCount': 14,
      'imageUrl':
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Dussehra Mega-Break',
      'dates': 'Oct 18 - Oct 20',
      'squadsCount': 28,
      'imageUrl':
          'https://images.unsplash.com/photo-1605335198032-475271cf5a88?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Diwali Advance Booking',
      'dates': 'Nov 8 - Nov 12',
      'squadsCount': 45,
      'imageUrl':
          'https://images.unsplash.com/photo-1605649487212-47bdab064df8?auto=format&fit=crop&w=800&q=80',
    },
  ];

  // ── 3. Mock Data: Wall of Fame Reviews ──────────────────────────────────────
  static const List<Map<String, dynamic>> _reviews = [
    {
      'userName': 'Aarav Sharma',
      'trip': 'Goa Squad Trip',
      'quote':
          'The scuba operator we matched with in Goa was incredible! Seamless booking, great gear, and awesome squad vibe.',
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
      'rating': 5,
    },
    {
      'userName': 'Priya Nair',
      'trip': 'Udaipur Royal Getaway',
      'quote':
          'Booking the Udaipur palace package saved us 40% on luxury heritage stays. Group discounts were real!',
      'avatarUrl': 'https://i.pravatar.cc/150?img=47',
      'rating': 5,
    },
    {
      'userName': 'Rohan Verma',
      'trip': 'Manali Mountain Trek',
      'quote':
          'Conquering snowy trails in Manali with a verified local guide was an unforgettable memory. Top tier support.',
      'avatarUrl': 'https://i.pravatar.cc/150?img=33',
      'rating': 5,
    },
  ];

  // ── 4. Mock Data: Top Operators ─────────────────────────────────────────────
  static const List<Map<String, dynamic>> _operators = [
    {
      'name': 'Royal Rajputana Expeditions',
      'rating': '4.9',
      'trips': '120+ trips completed',
      'tag': 'Heritage & Luxury',
      'logoUrl':
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=200&q=80',
    },
    {
      'name': 'Goan Coastal Tours',
      'rating': '4.8',
      'trips': '95+ trips completed',
      'tag': 'Water Sports & Beach',
      'logoUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=200&q=80',
    },
    {
      'name': 'Himalayan Heights',
      'rating': '5.0',
      'trips': '150+ trips completed',
      'tag': 'Trekking & Adventure',
      'logoUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=200&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      'Curated escapes, long weekends & verified operators',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Section 1: Static Packages (Inspiration Feed) ───────────────
              _buildSectionTitle('Featured Packages', 'Handpicked group getaways'),
              const SizedBox(height: 12),
              _buildPackagesCarousel(context),
              const SizedBox(height: 28),

              // ── Section 2: Upcoming Long Weekends ────────────────────────────
              _buildSectionTitle('Upcoming Long Weekends', 'Pre-built squads filling fast'),
              const SizedBox(height: 12),
              _buildLongWeekendsCarousel(),
              const SizedBox(height: 28),

              // ── Section 3: Wall of Fame ─────────────────────────────────────
              _buildSectionTitle('Wall of Fame', 'Real stories from verified travelers'),
              const SizedBox(height: 12),
              _buildWallOfFameCarousel(),
              const SizedBox(height: 28),

              // ── Section 4: Top Operators This Month ─────────────────────────
              _buildSectionTitle('Top Operators This Month', 'Highest rated local partners'),
              const SizedBox(height: 12),
              _buildTopOperatorsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 1 Widget: Inspiration Packages Carousel ─────────────────────────
  Widget _buildPackagesCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;

    return SizedBox(
      height: 400,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final item = _packages[index];
          final activities = item['activities'] as List<String>;

          return Container(
            width: cardWidth,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.35, 0.6, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge: Duration
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['duration'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Bottom content: Title, Activities, Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Activities Wrap
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: activities.map((act) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              act,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      // Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['price'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final title = (item['title'] as String).toLowerCase();
                              CityCatalog city = mockCities.first;
                              if (title.contains('goa')) {
                                city = mockCities.firstWhere((c) => c.id == 'goa', orElse: () => mockCities.first);
                              } else if (title.contains('manali')) {
                                city = mockCities.firstWhere((c) => c.id == 'manali', orElse: () => mockCities.first);
                              } else if (title.contains('udaipur')) {
                                city = mockCities.firstWhere((c) => c.id == 'udaipur', orElse: () => mockCities.first);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItineraryCartScreen(city: city, isSolo: false),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Explore',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section 2 Widget: Upcoming Long Weekends ────────────────────────────────
  Widget _buildLongWeekendsCarousel() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _longWeekends.length,
        itemBuilder: (context, index) {
          final item = _longWeekends[index];

          return Container(
            width: 260,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.2, 0.5, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top date tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.electricYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['dates'],
                      style: GoogleFonts.poppins(
                        color: AppColors.darkCharcoal,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Bottom Holiday Name & Squads Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${item['squadsCount']} pre-built squads open',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section 3 Widget: Wall of Fame Reviews ──────────────────────────────────
  Widget _buildWallOfFameCarousel() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];

          return Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
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
                // Top Row: Avatar, User Name, and 5 Gold Stars
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: NetworkImage(review['avatarUrl']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review['userName'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (starIdx) => const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Italicized Quote
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '"${review['quote']}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.darkCharcoal.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ),

                // Bottom: Electric Blue Action
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View this itinerary',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.electricBlue,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section 4 Widget: Top Operators This Month ───────────────────────────────
  Widget _buildTopOperatorsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _operators.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final op = _operators[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: NetworkImage(op['logoUrl']),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFFFFD400),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              op['name'],
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  op['rating'],
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• ${op['trips']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

// Type alias so existing router references to PackagesScreen continue to work seamlessly
typedef PackagesScreen = ExploreScreen;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // ── 1. Mock Data: Inspiration Packages ───────────────────────────────────────
  static const List<Map<String, dynamic>> _packages = [
    {
      'id': 'udaipur-pkg',
      'title': 'The Ultimate Udaipur Weekend',
      'subtitle': 'Royal Haveli Stay & Lake Pichola Cruise',
      'price': 'From ₹6,500 / person',
      'duration': '3 Days • 2 Nights',
      'dates': '15 Oct - 17 Oct 2026',
      'location': 'Udaipur, Rajasthan',
      'groupSize': 'Squad of 4-8',
      'operator': 'Royal Rajputana Expeditions (4.9 ★)',
      'imageUrl':
          'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=1200&q=80',
      'stay': {
        'name': 'Fateh Garh Heritage Palace',
        'type': 'Lake-View Heritage Deluxe Suite',
        'rating': '4.9 ★',
        'geoTag': 'Near Lake Pichola Shore, Old City',
        'amenities': [
          'Lake View',
          'Infinity Pool',
          'Royal Breakfast',
          'Free Wi-Fi',
        ],
      },
      'activities': [
        'City Palace & Crystal Gallery Guided Tour',
        'Sunset Private Boat Cruise on Lake Pichola',
        'Ambrai Rooftop Candlelight Heritage Dinner',
        'Bagore Ki Haveli Folk Dance & Puppet Show',
      ],
      'transport': {
        'mode': 'Dedicated AC Innova Crysta',
        'details':
            'Airport/Railway Station Pick & Drop + 3-day private sightseeing included.',
      },
      'inclusions': [
        '2 Nights Heritage Palace Stay',
        'Daily Royal Buffet Breakfast',
        'All Monument Passes & Boat Tickets',
        'Dedicated AC Innova Cab for Full Trip',
      ],
    },
    {
      'id': 'goa-pkg',
      'title': 'Goa Scuba & Sun',
      'subtitle': 'Island Diving & Beachfront Resort',
      'price': 'From ₹4,999 / person',
      'duration': '4 Days • 3 Nights',
      'dates': '22 Oct - 25 Oct 2026',
      'location': 'North & South Goa',
      'groupSize': 'Squad of 4-10',
      'operator': 'Goan Coastal Tours (4.8 ★)',
      'imageUrl':
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1200&q=80',
      'stay': {
        'name': 'Casa Baga Beachfront Resort',
        'type': 'Poolside Cabana & Luxury Suite',
        'rating': '4.8 ★',
        'geoTag': 'Near Baga Beach Road & Tito’s Lane',
        'amenities': [
          'Beach Access',
          'Swimming Pool',
          'Breakfast Included',
          'Cocktail Bar',
        ],
      },
      'activities': [
        'Grand Island Scuba Dive with PADI Instructors',
        'Parasailing & Jet Skiing at Baga Beach',
        'Sunset Beach BBQ & Live Acoustic Squad Jam',
        'Dudhsagar Waterfalls Off-Road Jeep Safari',
      ],
      'transport': {
        'mode': 'Self-Drive Mahindra Thar / AC Cab',
        'details':
            'Goa Airport Pick & Drop + 4-day vehicle for coastal hopping.',
      },
      'inclusions': [
        '3 Nights Luxury Beachfront Resort Stay',
        'Scuba Gear & HD Underwater Video',
        'All Water Sports Permits & Equipment',
        'Airport Transfers & Local Vehicle',
      ],
    },
    {
      'id': 'manali-pkg',
      'title': 'Manali Peak Expedition',
      'subtitle': 'Snowy Passes & Luxury Cedar Chalet',
      'price': 'From ₹7,800 / person',
      'duration': '5 Days • 4 Nights',
      'dates': '05 Nov - 09 Nov 2026',
      'location': 'Manali & Solang, Himachal',
      'groupSize': 'Squad of 6-12',
      'operator': 'Himalayan Heights (5.0 ★)',
      'imageUrl':
          'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1200&q=80',
      'stay': {
        'name': 'Himalayan Woodside Cedar Chalet',
        'type': 'Pine-Wood Mountain-View Cottage',
        'rating': '5.0 ★',
        'geoTag': 'Old Manali Riverside, Solang View',
        'amenities': [
          'Fireplace Lounge',
          'Heated Blankets',
          'Mountain Balcony',
          'Bonfire Area',
        ],
      },
      'activities': [
        'Solang Valley High-Altitude Tandem Paragliding',
        'Rohtang Pass Snow Trek & Skiing Session',
        'Old Manali Cafe Crawl & Live Acoustic Jam',
        'Jogini Waterfall Pine Forest Hike',
      ],
      'transport': {
        'mode': '4x4 Mountain Scorpio + AC Volvo Sleeper',
        'details':
            'Delhi-Manali Luxury AC Volvo Transfer + 4x4 Mountain SUV for snow passes.',
      },
      'inclusions': [
        '4 Nights Luxury Cedar Chalet Stay',
        'Daily Buffet Breakfast & Mountain Dinner',
        'Paragliding Permits & Snow Gear Rentals',
        'Delhi-Manali AC Volvo Sleeper Tickets',
      ],
    },
  ];

  // ── 2. Mock Data: Upcoming Long Weekends ─────────────────────────────────────
  static const List<Map<String, dynamic>> _longWeekends = [
    {
      'name': 'Gandhi Jayanti Serene Escape',
      'dates': 'Oct 2 - Oct 4',
      'squadsCount': 14,
      'imageUrl':
          'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Dussehra Royal Palace Break',
      'dates': 'Oct 18 - Oct 20',
      'squadsCount': 28,
      'imageUrl':
          'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Diwali Festive Lights Getaway',
      'dates': 'Nov 8 - Nov 12',
      'squadsCount': 45,
      'imageUrl':
          'https://images.unsplash.com/photo-1603555501671-8f96b3fce8b5?auto=format&fit=crop&w=800&q=80',
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Curated escapes, long weekends & verified operators',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Section 1: Static Packages (Inspiration Feed) ───────────────
              _buildSectionTitle('Featured Packages', 'Handpicked escapes (Tap to view details)'),
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
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
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
      height: 460,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final item = _packages[index];
          final activities = (item['activities'] as List<dynamic>).cast<String>();

          return InkWell(
            onTap: () => _showPackageDetailsModal(context, item),
            borderRadius: BorderRadius.circular(28),
            child: Container(
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
                    color: Colors.black.withValues(alpha: 0.12),
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
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(20),
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
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item['duration'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Bottom content: Title, Activities, Price & Action
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Activities Minimal Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: activities.take(2).map((act) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                act,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        // Price & Action Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ALL-INCLUSIVE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    item['price'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF0F172A),
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Package Detail Modal Bottom Sheet ──────────────────────────────────────
  void _showPackageDetailsModal(BuildContext context, Map<String, dynamic> item) {
    final title = (item['title'] as String?) ?? '';
    final subtitle = (item['subtitle'] as String?) ?? '';
    final price = (item['price'] as String?) ?? '';
    final duration = (item['duration'] as String?) ?? '';
    final dates = (item['dates'] as String?) ?? '';
    final location = (item['location'] as String?) ?? '';
    final groupSize = (item['groupSize'] as String?) ?? '';
    final imageUrl = (item['imageUrl'] as String?) ?? '';
    final stay = item['stay'] as Map<String, dynamic>? ?? {};
    final transport = item['transport'] as Map<String, dynamic>? ?? {};
    final activities = (item['activities'] as List<dynamic>?)?.cast<String>() ?? [];
    final inclusions = (item['inclusions'] as List<dynamic>?)?.cast<String>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Color(0xFFFC8019), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            location,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF60B246),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'FIXED ALL-INCLUSIVE PACKAGE',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      title,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quick info strip (Dates, Duration, Squad size)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildModalInfoPill(
                                  Icons.calendar_today_rounded,
                                  'Dates',
                                  dates,
                                  const Color(0xFFFC8019),
                                ),
                              ),
                              Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: _buildModalInfoPill(
                                  Icons.timer_outlined,
                                  'Duration',
                                  duration,
                                  const Color(0xFF3B82F6),
                                ),
                              ),
                              Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: _buildModalInfoPill(
                                  Icons.groups_rounded,
                                  'Squad Size',
                                  groupSize,
                                  const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section 1: Stay Details with Geo Tag
                      _buildModalSection(
                        title: 'Stay & Geo Tag',
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                      stay['name'] ?? 'Premium Resort Stay',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF60B246).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      stay['rating'] ?? '4.8 ★',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                stay['type'] ?? 'Deluxe Room',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Hotel Geo Tag
                              if (stay['geoTag'] != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_pin,
                                          color: Color(0xFF3B82F6), size: 14),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Geo Tag: ${stay['geoTag']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2563EB),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              if (stay['amenities'] != null)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (stay['amenities'] as List<dynamic>).map((amenity) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '✓ $amenity',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.darkCharcoal,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section 2: Simplified Activities List
                      _buildModalSection(
                        title: 'Fixed Activities (${activities.length})',
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: activities.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final act = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: idx == activities.length - 1 ? 0 : 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppColors.softGrey,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${idx + 1}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDarkBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          act,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkCharcoal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF10B981), size: 15),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section 3: Transport & Transfers
                      _buildModalSection(
                        title: 'Transport & Transfers',
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.directions_car_rounded,
                                        color: Color(0xFF3B82F6), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      transport['mode'] ?? 'Dedicated AC Vehicle Included',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                transport['details'] ??
                                    'All internal and airport transfers included.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section 4: Inclusions Checklist
                      if (inclusions.isNotEmpty)
                        _buildModalSection(
                          title: 'Inclusions Breakdown',
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Column(
                              children: inclusions.map((inc) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          color: Color(0xFF16A34A), size: 15),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          inc,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF14532D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Static Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Fixed Package Cost',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      // Static Page Behavior: Absolutely nothing happens when pressed
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Select Package',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalInfoPill(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildModalSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
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
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['dates'],
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F172A),
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
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: NetworkImage(review['avatarUrl']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review['userName'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
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
                      color: const Color(0xFF334155),
                      height: 1.3,
                    ),
                  ),
                ),

                // Bottom: Action
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
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF0F172A),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  backgroundColor: const Color(0xFFF1F5F9),
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
                      color: Color(0xFFFFB800),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              op['name'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 15,
                ),
                const SizedBox(width: 3),
                Text(
                  op['rating'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '• ${op['trips']}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
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

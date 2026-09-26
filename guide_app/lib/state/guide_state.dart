import 'package:flutter/material.dart';
import '../models/guide_models.dart';

class GuideState extends ChangeNotifier {
  GuideUser _currentGuide = GuideUser(
    id: 'guide_101',
    name: 'Captain Ryan Vance',
    email: 'ryan.vance@journeyguide.com',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
    phone: '+1 (555) 234-8900',
    badge: 'Master Wilderness & Heritage Guide',
    rating: 4.96,
    totalTours: 142,
    languages: ['English (Native)', 'Spanish (Fluent)', 'French (Conversational)'],
    specialties: ['High Altitude Trekking', 'Cultural History', 'Photography Expedition', 'Wilderness First Aid'],
    isAvailable: true,
  );

  GuideUser get currentGuide => _currentGuide;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  final List<TourPackage> _packages = [
    TourPackage(
      id: 'pkg_01',
      title: 'Kyoto Hidden Temples & Bamboo Forest Dawn Trek',
      destination: 'Kyoto, Japan',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
      duration: '3 Days • 2 Nights',
      dates: 'Oct 14 - Oct 17, 2026',
      payoutAmount: 1450.00,
      currentBookings: 6,
      maxCapacity: 8,
      difficulty: 'Moderate',
      meetingPoint: 'Kyoto Central Station - North Plaza Clock Tower',
      description:
          'Guide a boutique group of travelers through early-morning secluded shrine pathways in Arashiyama, tea ceremonies in Uji, and twilight culinary walks along Pontocho Alley.',
      highlights: [
        'Private dawn access to Fushimi Inari backtrails',
        'Traditional Matcha ceremony with 4th-gen tea master',
        'Monastery meditation session at Kennin-ji',
        'Multi-course Kaiseki dinner arrangement',
      ],
      inclusions: [
        'Guide daily stipend & luxury private transport',
        'Accommodations included at Machiya heritage inn',
        'All temple admissions & permits paid in advance',
        'Emergency satellite beacon & medical kit provided',
      ],
      status: PackageStatus.pending,
      tourists: [
        TouristUser(
          id: 't_01',
          name: 'Elena Rostova',
          email: 'elena.rostova@gmail.com',
          phone: '+1 (415) 890-1122',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
          country: 'United States',
          emergencyContact: '+1 (415) 890-9988 (Brother - Alex)',
          dietaryOrSpecialNotes: 'Strictly Vegetarian, allergic to shellfish',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_02',
          name: 'Kenji Takahashi',
          email: 'k.takahashi@tokyo-design.jp',
          phone: '+81 90-1234-5678',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          country: 'Japan',
          emergencyContact: '+81 90-9876-5432 (Spouse - Yuko)',
          dietaryOrSpecialNotes: 'None. Professional landscape photographer bringing gear.',
          partySize: 1,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_03',
          name: 'Sophie & Liam Becker',
          email: 'sophie.becker@berlin-travel.de',
          phone: '+49 170 9823411',
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          country: 'Germany',
          emergencyContact: '+49 170 1122334 (Sister)',
          dietaryOrSpecialNotes: 'Gluten-free diet required for Sophie',
          partySize: 2,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_04',
          name: 'Dr. Marcus Holloway',
          email: 'm.holloway@stanford.edu',
          phone: '+1 (650) 445-9801',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
          country: 'United States',
          emergencyContact: '+1 (650) 445-0012 (Clinic Admin)',
          dietaryOrSpecialNotes: 'History enthusiast, interested in Edo architectural notes',
          partySize: 1,
          isLeadBooker: false,
        ),
      ],
    ),
    TourPackage(
      id: 'pkg_02',
      title: 'Swiss Alps Zermatt Glacier & Matterhorn Ascent',
      destination: 'Zermatt, Switzerland',
      imageUrl: 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?w=800&q=80',
      duration: '4 Days • 3 Nights',
      dates: 'Nov 02 - Nov 06, 2026',
      payoutAmount: 2200.00,
      currentBookings: 4,
      maxCapacity: 6,
      difficulty: 'Challenging',
      meetingPoint: 'Zermatt Alpine Basecamp Lodge - Main Lounge',
      description:
          'Lead an exhilarating mountaineering circuit across Gornergrat ridge, high-altitude alpine hut overnight stays, and glacier navigation with panoramic Matterhorn sunrise vistas.',
      highlights: [
        'Gorner Glacier crevasse observation trek',
        'Overnight at 3,100m Kulmhotel Gornergrat',
        'Alpine wildlife spotting: Ibex & Golden Eagles',
        'Fondue & Swiss wine tasting in historic chalet',
      ],
      inclusions: [
        'All cable cars & Gornergrat Bahn passes provided',
        'Crampons, safety harness & helmet equipment supplied',
        'Full mountain rescue insurance package covered',
        'Private Alpine guide quarters included',
      ],
      status: PackageStatus.accepted,
      acceptedAt: DateTime.now().subtract(const Duration(days: 2)),
      tourists: [
        TouristUser(
          id: 't_05',
          name: 'Matteo Rossini',
          email: 'matteo.rossini@milano-trek.it',
          phone: '+39 340 551982',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&q=80',
          country: 'Italy',
          emergencyContact: '+39 340 998877 (Father)',
          dietaryOrSpecialNotes: 'Experienced alpine hiker. Has own crampons.',
          partySize: 1,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_06',
          name: 'Claire & Julien Moreau',
          email: 'claire.moreau@lyon-adventure.fr',
          phone: '+33 6 12 34 56 78',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          country: 'France',
          emergencyContact: '+33 6 98 76 54 32 (Julien Brother)',
          dietaryOrSpecialNotes: 'No dietary restrictions. Requesting trekking pole rentals.',
          partySize: 2,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_07',
          name: 'David Zhao',
          email: 'david.zhao@sydney-tech.au',
          phone: '+61 412 345 678',
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
          country: 'Australia',
          emergencyContact: '+61 412 888 999 (Sister)',
          dietaryOrSpecialNotes: 'Mild asthma (carries rescue inhaler in daypack)',
          partySize: 1,
          isLeadBooker: false,
        ),
      ],
    ),
    TourPackage(
      id: 'pkg_03',
      title: 'Amalfi Coast Path of the Gods & Cliffside Villages',
      destination: 'Positano, Italy',
      imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800&q=80',
      duration: '2 Days • 1 Night',
      dates: 'Nov 12 - Nov 14, 2026',
      payoutAmount: 1100.00,
      currentBookings: 5,
      maxCapacity: 10,
      difficulty: 'Easy - Moderate',
      meetingPoint: 'Bomerano Village Square (Piazza Paolo Capasso)',
      description:
          'Guide scenic coastal traverses above the Tyrrhenian Sea from Bomerano to Nocelle, followed by lemon orchard artisan tastings in Ravello and cliffside sunset cocktails.',
      highlights: [
        'Panoramic views 600m above the Mediterranean coastline',
        'Fresh Limoncello making workshop with local organic farmer',
        'Private sunset catamaran cruise returning to Positano pier',
      ],
      inclusions: [
        'Catamaran charter crew handled',
        'Artisan lunch & wine pairing included',
        'Baggage transfer between cliffside hotels',
      ],
      status: PackageStatus.pending,
      tourists: [
        TouristUser(
          id: 't_08',
          name: 'Grace Hopper-Smith',
          email: 'grace.h@london-creative.co.uk',
          phone: '+44 7700 900123',
          avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&q=80',
          country: 'United Kingdom',
          emergencyContact: '+44 7700 900999 (Husband)',
          dietaryOrSpecialNotes: 'Pescatarian',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_09',
          name: 'Lucas Silva',
          email: 'lucas.silva@saopaulo.br',
          phone: '+55 11 98765-4321',
          avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=300&q=80',
          country: 'Brazil',
          emergencyContact: '+55 11 91234-5678 (Mother)',
          dietaryOrSpecialNotes: 'None',
          partySize: 3,
          isLeadBooker: false,
        ),
      ],
    ),
    TourPackage(
      id: 'pkg_04',
      title: 'Moroccan Sahara Erg Chebbi Stargazing & Berber Camp',
      destination: 'Merzouga, Morocco',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800&q=80',
      duration: '3 Days • 2 Nights',
      dates: 'Nov 20 - Nov 23, 2026',
      payoutAmount: 1850.00,
      currentBookings: 6,
      maxCapacity: 8,
      difficulty: 'Moderate',
      meetingPoint: 'Merzouga Desert Gate Ksar Bicha Hotel',
      description:
          'Deep dunes expedition into Erg Chebbi golden sand dunes with 4x4 sand dune navigation, camel caravan sunset ridge ascent, live Gnawa music, and telescopic astronomy.',
      highlights: [
        'Luxury glamping with private Berber tent en-suites',
        'Telescope deep-sky astrophotography session',
        'Fossil bed discovery in Kem Kem geological basin',
      ],
      inclusions: [
        'Dedicated 4WD support fleet & driver assist',
        'All gourmet desert meals prepared by private camp chef',
        'Camel handlers and safety crew provided',
      ],
      status: PackageStatus.accepted,
      acceptedAt: DateTime.now().subtract(const Duration(days: 4)),
      tourists: [
        TouristUser(
          id: 't_10',
          name: 'Amina & Tariq Al-Mansoor',
          email: 'tariq.almansoor@dubai-ventures.ae',
          phone: '+971 50 123 4567',
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
          country: 'United Arab Emirates',
          emergencyContact: '+971 50 999 8888 (Brother)',
          dietaryOrSpecialNotes: 'Halal meals required',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_11',
          name: 'Hannah Lindqvist',
          email: 'hannah.lind@stockholm.se',
          phone: '+46 70 123 45 67',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
          country: 'Sweden',
          emergencyContact: '+46 70 987 65 43 (Partner)',
          dietaryOrSpecialNotes: 'Lactose intolerant',
          partySize: 2,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_12',
          name: 'Carlos Mendez',
          email: 'carlos.m@madrid-trek.es',
          phone: '+34 600 112 233',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
          country: 'Spain',
          emergencyContact: '+34 600 998 877 (Father)',
          dietaryOrSpecialNotes: 'None',
          partySize: 2,
          isLeadBooker: false,
        ),
      ],
    ),
  ];

  final Map<String, List<ChatMessage>> _chatsByPackageId = {
    'pkg_02': [
      ChatMessage(
        id: 'm_1',
        packageId: 'pkg_02',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Hello Alpine explorers! I am Captain Ryan, your certified lead guide for our Zermatt Matterhorn circuit. Super excited to welcome you all!',
        timestamp: DateTime.now().subtract(const Duration(hours: 26)),
        isAnnouncement: true,
      ),
      ChatMessage(
        id: 'm_2',
        packageId: 'pkg_02',
        senderId: 't_05',
        senderName: 'Matteo Rossini',
        senderAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&q=80',
        isGuide: false,
        message: 'Ciao Ryan! Looking forward to it. Will we need B2 mountain boots or will standard B1s with strap-on crampons suffice for day 2?',
        timestamp: DateTime.now().subtract(const Duration(hours: 24)),
      ),
      ChatMessage(
        id: 'm_3',
        packageId: 'pkg_02',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Great question Matteo! B1 boots are completely fine for our planned route across the lower glacier. I have backup microspikes as well.',
        timestamp: DateTime.now().subtract(const Duration(hours: 22)),
      ),
      ChatMessage(
        id: 'm_4',
        packageId: 'pkg_02',
        senderId: 't_06',
        senderName: 'Claire Moreau',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
        isGuide: false,
        message: 'Bonjour Ryan! Julien and I arrive in Zermatt via train at 2:30 PM. Can we leave luggage at the basecamp lodge before the gear check?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'pkg_04': [
      ChatMessage(
        id: 'm_5',
        packageId: 'pkg_04',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Welcome to the Sahara Expedition group! Please make sure to pack high-SPF sunscreen, a windproof scarf for sand ridges, and a light fleece for cold desert nights.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isAnnouncement: true,
      ),
      ChatMessage(
        id: 'm_6',
        packageId: 'pkg_04',
        senderId: 't_10',
        senderName: 'Tariq Al-Mansoor',
        senderAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
        isGuide: false,
        message: 'Salam Ryan! We have a private 4x4 transfer booked from Ouarzazate. We should reach Merzouga right at 1 PM.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };

  List<TourPackage> get allPackages => List.unmodifiable(_packages);
  List<TourPackage> get pendingPackages => _packages.where((p) => p.status == PackageStatus.pending).toList();
  List<TourPackage> get acceptedPackages => _packages.where((p) => p.status == PackageStatus.accepted || p.status == PackageStatus.inProgress).toList();
  List<TourPackage> get rejectedPackages => _packages.where((p) => p.status == PackageStatus.rejected).toList();
  List<TourPackage> get completedPackages => _packages.where((p) => p.status == PackageStatus.completed).toList();

  double get totalPotentialEarnings => _packages
      .where((p) => p.status == PackageStatus.accepted || p.status == PackageStatus.completed)
      .fold(0.0, (sum, p) => sum + p.payoutAmount);

  int get totalRegisteredTourists => acceptedPackages.fold(0, (sum, p) => sum + p.currentBookings);

  // Authentication
  bool login(String email, String password) {
    if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
      _isLoggedIn = true;
      _currentGuide = GuideUser(
        id: 'guide_101',
        name: email.contains('@') ? email.split('@').first.toUpperCase().replaceAll('.', ' ') : 'Captain Ryan Vance',
        email: email.trim(),
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        phone: '+1 (555) 234-8900',
        badge: 'Certified Master Guide',
        rating: 4.96,
        totalTours: 142,
        languages: ['English (Native)', 'Spanish (Fluent)', 'French (Conversational)'],
        specialties: ['High Altitude Trekking', 'Cultural History', 'Photography Expedition'],
        isAvailable: true,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void toggleAvailability() {
    _currentGuide.isAvailable = !_currentGuide.isAvailable;
    notifyListeners();
  }

  void acceptPackage(String packageId) {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index].status = PackageStatus.accepted;
      _packages[index].acceptedAt = DateTime.now();
      _packages[index].rejectionReason = null;

      // Initialize group chat welcome if not present
      if (!_chatsByPackageId.containsKey(packageId)) {
        _chatsByPackageId[packageId] = [
          ChatMessage(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
            packageId: packageId,
            senderId: _currentGuide.id,
            senderName: '${_currentGuide.name} (Guide)',
            senderAvatar: _currentGuide.avatarUrl,
            isGuide: true,
            message: 'Hello everyone! I have accepted this tour and will be your lead guide for ${_packages[index].title}. Feel free to ask any preparation questions!',
            timestamp: DateTime.now(),
            isAnnouncement: true,
          ),
        ];
      }
      notifyListeners();
    }
  }

  void rejectPackage(String packageId, String reason) {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index].status = PackageStatus.rejected;
      _packages[index].rejectionReason = reason;
      notifyListeners();
    }
  }

  void restorePackage(String packageId) {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index].status = PackageStatus.pending;
      _packages[index].rejectionReason = null;
      notifyListeners();
    }
  }

  List<ChatMessage> getMessagesForPackage(String packageId) {
    return _chatsByPackageId[packageId] ?? [];
  }

  void sendMessage(String packageId, String text, {bool isAnnouncement = false}) {
    if (text.trim().isEmpty) return;
    if (!_chatsByPackageId.containsKey(packageId)) {
      _chatsByPackageId[packageId] = [];
    }

    final newMsg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      packageId: packageId,
      senderId: _currentGuide.id,
      senderName: '${_currentGuide.name} (Guide)',
      senderAvatar: _currentGuide.avatarUrl,
      isGuide: true,
      message: text.trim(),
      timestamp: DateTime.now(),
      isAnnouncement: isAnnouncement,
    );

    _chatsByPackageId[packageId]!.add(newMsg);
    notifyListeners();

    // Trigger simulated quick tourist reply after 1.5 seconds for interactive demo feel
    Future.delayed(const Duration(milliseconds: 1500), () {
      final pkg = _packages.firstWhere((p) => p.id == packageId, orElse: () => _packages.first);
      if (pkg.tourists.isNotEmpty) {
        final randomTourist = pkg.tourists.first;
        final replyMsg = ChatMessage(
          id: 'm_reply_${DateTime.now().millisecondsSinceEpoch}',
          packageId: packageId,
          senderId: randomTourist.id,
          senderName: randomTourist.name,
          senderAvatar: randomTourist.avatarUrl,
          isGuide: false,
          message: 'Got it, thank you Captain! We will be ready at the scheduled spot.',
          timestamp: DateTime.now(),
        );
        _chatsByPackageId[packageId]?.add(replyMsg);
        notifyListeners();
      }
    });
  }
}

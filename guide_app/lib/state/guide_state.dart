import 'package:flutter/material.dart';
import '../models/guide_models.dart';

class GuideState extends ChangeNotifier {
  GuideUser _currentGuide = GuideUser(
    id: 'guide_101',
    name: 'Captain Ryan Vance',
    email: 'ryan.vance@journeyguide.com',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
    phone: '+91 98200 12345',
    badge: 'Master Wilderness & Heritage Guide',
    rating: 4.96,
    totalTours: 142,
    languages: ['English (Native)', 'Hindi (Fluent)', 'Marathi (Conversational)'],
    specialties: ['Heritage Architecture Walks', 'Coastal Expeditions', 'Royal Forts & Palaces', 'Wilderness First Aid'],
    isAvailable: true,
  );

  GuideUser get currentGuide => _currentGuide;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Editable Financial Metrics (INR)
  double _weeklyGoal = 40000.0;
  double get weeklyGoal => _weeklyGoal;

  final double _readyToWithdraw = 4500.0;
  double get readyToWithdraw => _readyToWithdraw;

  void setWeeklyGoal(double newGoal) {
    if (newGoal > 0) {
      _weeklyGoal = newGoal;
      notifyListeners();
    }
  }

  final List<TourPackage> _packages = [
    // Request 1 (Goa)
    TourPackage(
      id: 'pkg_goa_01',
      title: 'Fontainhas Latin Quarter Architecture Walk',
      destination: 'Panjim, Goa',
      imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=900&q=80',
      duration: 'Morning Trail • 3 Hours',
      dates: 'Oct 12, 8:00 AM - 11:00 AM',
      payoutAmount: 3200.00,
      currentBookings: 5,
      maxCapacity: 8,
      difficulty: 'Easy',
      meetingPoint: 'General Post Office Panjim',
      meetingPointEta: 'Starts at General Post Office Panjim • 8 mins away',
      logisticsBadge: 'Walking Tour Only',
      description:
          'Guide art and architecture enthusiasts through narrow colorful lanes of Fontainhas, heritage Portuguese mansions, and traditional bakeries.',
      highlights: [
        'Explore 18th-century Portuguese style villas & azulejo tiles',
        'Traditional Goan bakery snack and artisan coffee stop',
        'Stories of old Panjim history and maritime trade routes',
      ],
      inclusions: [
        'Guide compensation & entrance permissions',
        'Audio whisper headsets for groups',
        'Emergency hydration kit',
      ],
      status: PackageStatus.pending,
      tourists: [
        TouristUser(
          id: 't_g01',
          name: 'Aarav & Meera Kapoor',
          email: 'aarav.kapoor@gmail.com',
          phone: '+91 98201 55667',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          country: 'India (Mumbai)',
          emergencyContact: '+91 98201 00000 (Father)',
          dietaryOrSpecialNotes: 'Vegetarian snacks',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_g02',
          name: 'Lucas Dupont',
          email: 'lucas.dupont@paris-arch.fr',
          phone: '+33 6 12 34 89 00',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
          country: 'France',
          emergencyContact: '+33 6 99 88 77 66 (Brother)',
          dietaryOrSpecialNotes: 'Interested in colonial architecture documentation',
          partySize: 3,
          isLeadBooker: false,
        ),
      ],
    ),

    // Request 2 (Mumbai)
    TourPackage(
      id: 'pkg_mum_02',
      title: 'Elephanta Caves Guided Expedition',
      destination: 'Mumbai, Maharashtra',
      imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=900&q=80',
      duration: 'Full Day • 6 Hours',
      dates: 'Oct 15, 9:00 AM - 3:00 PM',
      payoutAmount: 4500.00,
      currentBookings: 8,
      maxCapacity: 10,
      difficulty: 'Moderate',
      meetingPoint: 'Gateway of India',
      meetingPointEta: 'Starts at Gateway of India • 20 mins away',
      logisticsBadge: 'Ferry & Transport Included',
      description:
          'Lead a high-profile tour across Mumbai Harbor by luxury ferry to explore the 6th-century UNESCO World Heritage rock-cut temples of Lord Shiva.',
      highlights: [
        'Private harbor boat crossing with skyline vistas',
        'Detailed iconographic storytelling of Sadashiva Trimurti',
        'Guided hill ascent and Cannon Point vantage view',
      ],
      inclusions: [
        'All ferry tickets & island monument entrance passes',
        'Miniature toy train transfer included',
        'Guide lunch stipend & transport cover',
      ],
      status: PackageStatus.pending,
      tourists: [
        TouristUser(
          id: 't_m01',
          name: 'Sarah & David Miller',
          email: 'sarah.miller@london-travel.co.uk',
          phone: '+44 7700 900345',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
          country: 'United Kingdom',
          emergencyContact: '+44 7700 900888 (Sister)',
          dietaryOrSpecialNotes: 'Carries own water bottle & sunscreen',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_m02',
          name: 'Rajesh & Sunita Iyer',
          email: 'r.iyer@chennai-tech.in',
          phone: '+91 98400 11223',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&q=80',
          country: 'India (Chennai)',
          emergencyContact: '+91 98400 99887 (Son)',
          dietaryOrSpecialNotes: 'Senior travelers - moderate pace preferred',
          partySize: 3,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_m03',
          name: 'Kenji Sato',
          email: 'kenji.sato@tokyo.jp',
          phone: '+81 90-8877-6655',
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
          country: 'Japan',
          emergencyContact: '+81 90-1122-3344 (Office)',
          dietaryOrSpecialNotes: 'None',
          partySize: 3,
          isLeadBooker: false,
        ),
      ],
    ),

    // Active Tour 1 (Mumbai)
    TourPackage(
      id: 'pkg_mum_01',
      title: 'South Bombay Art Deco & Heritage Trail',
      destination: 'Mumbai, Maharashtra',
      imageUrl: 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=900&q=80',
      duration: 'Half Day • 4 Hours',
      dates: 'Today, 4:30 PM - 8:30 PM',
      payoutAmount: 4800.00,
      currentBookings: 6,
      maxCapacity: 8,
      difficulty: 'Easy',
      meetingPoint: "McDonald's entrance opposite CST",
      meetingPointEta: "Starts at McDonald's entrance opposite CST • 10 mins away",
      logisticsBadge: 'Walking Tour Only',
      description:
          'Immersive architectural walking tour showcasing Victorian Gothic marvels and the world’s second largest concentration of Art Deco buildings along Oval Maidan and Marine Drive.',
      highlights: [
        'Chhatrapati Shivaji Maharaj Terminus (CST) architecture insight',
        'UNESCO Oval Maidan Victorian Gothic & Art Deco ensemble',
        'Irani Chai & Bun Maska heritage cafe experience',
        'Sunset views along Queen’s Necklace (Marine Drive)',
      ],
      inclusions: [
        'Guide stipend & emergency umbrella/kit',
        'Heritage cafe tasting arrangement',
        'Tour headsets and historical photo portfolio',
      ],
      status: PackageStatus.accepted,
      acceptedAt: DateTime.now().subtract(const Duration(days: 1)),
      tourists: [
        TouristUser(
          id: 't_m04',
          name: 'Elena Rostova',
          email: 'elena.rostova@gmail.com',
          phone: '+1 (415) 890-1122',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
          country: 'United States',
          emergencyContact: '+1 (415) 890-9988 (Brother)',
          dietaryOrSpecialNotes: 'Strictly Vegetarian',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_m05',
          name: 'Vikramaditya Rao',
          email: 'vikram.rao@bengaluru.in',
          phone: '+91 99000 88776',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          country: 'India (Bengaluru)',
          emergencyContact: '+91 99000 11223 (Spouse)',
          dietaryOrSpecialNotes: 'None',
          partySize: 2,
          isLeadBooker: false,
        ),
        TouristUser(
          id: 't_m06',
          name: 'Sophie Becker',
          email: 'sophie.becker@berlin.de',
          phone: '+49 170 9823411',
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          country: 'Germany',
          emergencyContact: '+49 170 1122334 (Sister)',
          dietaryOrSpecialNotes: 'Gluten-free preference',
          partySize: 2,
          isLeadBooker: false,
        ),
      ],
    ),

    // Active Tour 2 (Udaipur)
    TourPackage(
      id: 'pkg_uda_01',
      title: 'Lake Pichola Royal Ghats & Haveli Sunset Walk',
      destination: 'Udaipur, Rajasthan',
      imageUrl: 'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=900&q=80',
      duration: 'Sunset Special • 3.5 Hours',
      dates: 'Tomorrow, 3:00 PM - 6:30 PM',
      payoutAmount: 6500.00,
      currentBookings: 4,
      maxCapacity: 6,
      difficulty: 'Easy - Moderate',
      meetingPoint: 'City Palace Gate',
      meetingPointEta: 'Starts at City Palace Gate • 15 mins away',
      logisticsBadge: 'Walking & Boat Ride',
      description:
          'Scenic royal circuit across Ambrai Ghat, Bagore Ki Haveli courtyards, and a private solar boat cruise around Jag Mandir island with royal historians.',
      highlights: [
        'Exclusive royal courtyard access in old Mewar havelis',
        'Sunset boat ride on Lake Pichola facing City Palace',
        'Artisanal miniature painting studio demonstration',
      ],
      inclusions: [
        'Private solar boat cruise reservations covered',
        'Haveli heritage museum entry tickets',
        'Guide travel stipend and refreshment package',
      ],
      status: PackageStatus.accepted,
      acceptedAt: DateTime.now().subtract(const Duration(days: 2)),
      tourists: [
        TouristUser(
          id: 't_u01',
          name: 'Matteo Rossini',
          email: 'matteo.rossini@milano.it',
          phone: '+39 340 551982',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&q=80',
          country: 'Italy',
          emergencyContact: '+39 340 998877 (Father)',
          dietaryOrSpecialNotes: 'Photographer',
          partySize: 2,
          isLeadBooker: true,
        ),
        TouristUser(
          id: 't_u02',
          name: 'Claire Moreau',
          email: 'claire.moreau@lyon.fr',
          phone: '+33 6 12 34 56 78',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          country: 'France',
          emergencyContact: '+33 6 98 76 54 32 (Brother)',
          dietaryOrSpecialNotes: 'None',
          partySize: 2,
          isLeadBooker: false,
        ),
      ],
    ),
  ];

  final Map<String, List<ChatMessage>> _chatsByPackageId = {
    'pkg_mum_01': [
      ChatMessage(
        id: 'm_1',
        packageId: 'pkg_mum_01',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Namaste everyone! I am Captain Ryan, your certified heritage guide for our South Bombay Art Deco walk today. Looking forward to meeting you at McDonald\'s opposite CST at 4:30 PM!',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isAnnouncement: true,
      ),
      ChatMessage(
        id: 'm_2',
        packageId: 'pkg_mum_01',
        senderId: 't_m04',
        senderName: 'Elena Rostova',
        senderAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
        isGuide: false,
        message: 'Hi Ryan! Excited for the trail. Is comfortable walking footwear recommended?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ChatMessage(
        id: 'm_3',
        packageId: 'pkg_mum_01',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Yes Elena! Sneakers or comfortable walking shoes are ideal for our 4 km leisurely heritage walk.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    'pkg_uda_01': [
      ChatMessage(
        id: 'm_4',
        packageId: 'pkg_uda_01',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Greetings explorers! Tomorrow’s Lake Pichola royal haveli sunset walk will kick off from City Palace Gate at 3 PM sharp.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isAnnouncement: true,
      ),
      ChatMessage(
        id: 'm_5',
        packageId: 'pkg_uda_01',
        senderId: 't_u01',
        senderName: 'Matteo Rossini',
        senderAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&q=80',
        isGuide: false,
        message: 'Ciao Ryan! Can I bring my DSLR with a zoom lens on the boat?',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      ChatMessage(
        id: 'm_6',
        packageId: 'pkg_uda_01',
        senderId: 'guide_101',
        senderName: 'Capt. Ryan Vance (Guide)',
        senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
        isGuide: true,
        message: 'Absolutely Matteo, the sunset light over Jag Mandir offers breathtaking composition opportunities!',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ],
  };

  List<TourPackage> get allPackages => List.unmodifiable(_packages);
  List<TourPackage> get pendingPackages => _packages.where((p) => p.status == PackageStatus.pending).toList();
  List<TourPackage> get acceptedPackages => _packages.where((p) => p.status == PackageStatus.accepted || p.status == PackageStatus.inProgress).toList();
  List<TourPackage> get rejectedPackages => _packages.where((p) => p.status == PackageStatus.rejected).toList();
  List<TourPackage> get completedPackages => _packages.where((p) => p.status == PackageStatus.completed).toList();

  // Financial Escrow & Real-Time Calculations (INR)
  // Base fixed escrow buffer is 16,700, so initially with active tours (4800 + 6500 = 11,300), escrow is exactly ₹28,000!
  double get inEscrowEarnings =>
      acceptedPackages.fold(0.0, (sum, p) => sum + p.payoutAmount) + 16700.0;

  double get totalPotentialEarnings => inEscrowEarnings + _readyToWithdraw;

  int get totalRegisteredTourists => acceptedPackages.fold(0, (sum, p) => sum + p.currentBookings);

  // Operator-provisioned guide directory (Profiles created by operators)
  final Map<String, GuideUser> _registeredGuides = {
    'ryan.vance@journeyguide.com': GuideUser(
      id: 'guide_101',
      name: 'Captain Ryan Vance',
      email: 'ryan.vance@journeyguide.com',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
      phone: '+91 98200 12345',
      badge: 'Master Wilderness & Heritage Guide',
      rating: 4.96,
      totalTours: 142,
      languages: ['English (Native)', 'Hindi (Fluent)', 'Marathi (Conversational)'],
      specialties: ['Heritage Architecture Walks', 'Coastal Expeditions', 'Royal Forts & Palaces', 'Wilderness First Aid'],
      isAvailable: true,
    ),
    'yuki.tanaka@journeyguide.com': GuideUser(
      id: 'guide_102',
      name: 'Yuki Tanaka',
      email: 'yuki.tanaka@journeyguide.com',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      phone: '+81 90-4455-8899',
      badge: 'Senior Cultural & Historic Trail Guide',
      rating: 4.98,
      totalTours: 189,
      languages: ['Japanese (Native)', 'English (Fluent)', 'Mandarin (Conversational)'],
      specialties: ['Temple Trails', 'Tea Ceremonies', 'Historic Walk'],
      isAvailable: true,
    ),
    'sarah.jenkins@journeyguide.com': GuideUser(
      id: 'guide_103',
      name: 'Sarah Jenkins',
      email: 'sarah.jenkins@journeyguide.com',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&q=80',
      phone: '+44 7700 900555',
      badge: 'Wilderness Survival & Mountaineering Guide',
      rating: 4.92,
      totalTours: 98,
      languages: ['English (Native)', 'German (Fluent)'],
      specialties: ['Trekking Trails', 'Safety Coordination', 'Rock Climbing'],
      isAvailable: true,
    ),
    'guide@journey.com': GuideUser(
      id: 'guide_100',
      name: 'Alex Rivera',
      email: 'guide@journey.com',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
      phone: '+91 98111 22334',
      badge: 'Certified Tour Director',
      rating: 4.95,
      totalTours: 115,
      languages: ['English', 'Hindi', 'Spanish'],
      specialties: ['City Treks', 'Historical Expeditions'],
      isAvailable: true,
    ),
  };

  List<String> get authorizedGuideEmails => _registeredGuides.keys.toList();

  // Authentication - Operator Registered Emails
  bool login(String email) {
    final clean = email.trim().toLowerCase();
    if (_registeredGuides.containsKey(clean)) {
      _currentGuide = _registeredGuides[clean]!;
      _isLoggedIn = true;
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

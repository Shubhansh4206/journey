import 'dart:async';
import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../models/quotation_item_model.dart';
import '../services/guide_quotation_service.dart';

class GuideState extends ChangeNotifier {
  final GuideQuotationService _quotationService = GuideQuotationService();
  GuideQuotationService get quotationService => _quotationService;

  List<SupabaseQuotation> _finalizedQuotations = [];
  List<SupabaseQuotation> get finalizedQuotations => List.unmodifiable(_finalizedQuotations);

  bool _isLoadingQuotations = false;
  bool get isLoadingQuotations => _isLoadingQuotations;

  String? _quotationsError;
  String? get quotationsError => _quotationsError;

  StreamSubscription<List<SupabaseQuotation>>? _quotesSubscription;

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

  TourPackage? get ongoingTour {
    for (final p in _packages) {
      if (p.status == PackageStatus.inProgress) return p;
    }
    return null;
  }

  SosEmergencyAlert? _activeSosAlert;
  SosEmergencyAlert? get activeSosAlert => _activeSosAlert;
  bool isSosActive(String packageId) =>
      _activeSosAlert != null && _activeSosAlert!.packageId == packageId && !_activeSosAlert!.isResolved;

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

  /// Start tour: Transitions tour to inProgress (Ongoing Trip)
  void startTour(String packageId) {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index].status = PackageStatus.inProgress;
      sendMessage(
        packageId,
        '🚀 TOUR IS NOW IN PROGRESS! Lead Guide ${_currentGuide.name} has started the tour route. Please stay with the group and reach out for assistance at any time.',
        isAnnouncement: true,
      );
      notifyListeners();
    }
  }

  /// Complete tour: Finishes the ongoing tour
  void completeTour(String packageId) {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index].status = PackageStatus.completed;
      if (_activeSosAlert != null && _activeSosAlert!.packageId == packageId) {
        resolveSosAlert(_activeSosAlert!.id, notes: 'Tour successfully completed.');
      }
      sendMessage(
        packageId,
        '🎉 TOUR COMPLETED! Thank you for traveling with us today. It was an honor guiding your expedition.',
        isAnnouncement: true,
      );
      notifyListeners();
    }
  }

  /// Trigger high-urgency SOS Emergency Beacon
  Future<SosEmergencyAlert> triggerSosAlert({
    required TourPackage package,
    String emergencyType = 'General Urgent Emergency',
    String notes = '',
    double? latitude,
    double? longitude,
  }) async {
    final locCoords = GuideQuotationService.resolveCoordinatesStatic(
      name: package.meetingPoint,
      city: package.destination,
      lat: latitude,
      lng: longitude,
    );

    final alert = SosEmergencyAlert(
      id: 'sos_${DateTime.now().millisecondsSinceEpoch}',
      packageId: package.id,
      tourTitle: package.title,
      destination: package.destination,
      guideId: _currentGuide.id,
      guideName: _currentGuide.name,
      guidePhone: _currentGuide.phone,
      timestamp: DateTime.now(),
      latitude: locCoords['lat']!,
      longitude: locCoords['lng']!,
      locationName: package.meetingPoint,
      emergencyType: emergencyType,
      notes: notes,
    );

    _activeSosAlert = alert;

    // Send urgent broadcast message to group chat
    if (!_chatsByPackageId.containsKey(package.id)) {
      _chatsByPackageId[package.id] = [];
    }
    _chatsByPackageId[package.id]!.add(ChatMessage(
      id: 'm_sos_${DateTime.now().millisecondsSinceEpoch}',
      packageId: package.id,
      senderId: _currentGuide.id,
      senderName: '${_currentGuide.name} [EMERGENCY DISPATCH]',
      senderAvatar: _currentGuide.avatarUrl,
      isGuide: true,
      message: '🚨 [EMERGENCY PROTOCOL ACTIVATED] $emergencyType reported. The Tour Operator Operations Desk and emergency services have been alerted. All guests should remain calm and stay together at ${package.meetingPoint}. Stand by for direct updates.',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isSosAlert: true,
    ));

    debugPrint('🚨 [GuideState] SOS Alert Triggered for package "${package.title}" at (${alert.latitude}, ${alert.longitude})');
    notifyListeners();
    return alert;
  }

  /// Resolve / Stand Down SOS Alert
  void resolveSosAlert(String alertId, {String notes = ''}) {
    if (_activeSosAlert != null && _activeSosAlert!.id == alertId) {
      _activeSosAlert!.isResolved = true;
      _activeSosAlert!.resolvedAt = DateTime.now();
      _activeSosAlert!.resolutionNotes = notes;

      final pkgId = _activeSosAlert!.packageId;
      _activeSosAlert = null;

      if (_chatsByPackageId.containsKey(pkgId)) {
        _chatsByPackageId[pkgId]!.add(ChatMessage(
          id: 'm_sos_resolved_${DateTime.now().millisecondsSinceEpoch}',
          packageId: pkgId,
          senderId: _currentGuide.id,
          senderName: '${_currentGuide.name} (Guide)',
          senderAvatar: _currentGuide.avatarUrl,
          isGuide: true,
          message: '✅ [ALL CLEAR - SOS RESOLVED] The emergency situation has been de-escalated and verified by Tour Operator Operations. Normal tour schedule and activities have resumed.',
          timestamp: DateTime.now(),
          isAnnouncement: true,
        ));
      }

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

  // ==========================================
  // SUPABASE QUOTATIONS & OPENSTREETMAP LOGIC
  // ==========================================

  /// Initialize Supabase and stream finalized quotations in realtime
  Future<void> initSupabaseSync() async {
    await _quotationService.initialize();
    await loadFinalizedQuotations();

    // Start realtime stream
    try {
      _quotesSubscription?.cancel();
      _quotesSubscription = _quotationService.streamFinalizedQuotations().listen((quotes) {
        // Filter out any already accepted into _packages
        final acceptedIds = _packages.map((p) => p.id).toSet();
        _finalizedQuotations = quotes.where((q) => !acceptedIds.contains(q.id)).toList();
        notifyListeners();
      }, onError: (err) {
        debugPrint('⚠️ [GuideState] Realtime quotes stream error: $err');
      });
    } catch (e) {
      debugPrint('ℹ️ [GuideState] Realtime subscription note: $e');
    }
  }

  /// Manually fetch / refresh finalized quotations from Supabase
  Future<void> loadFinalizedQuotations() async {
    _isLoadingQuotations = true;
    _quotationsError = null;
    notifyListeners();

    try {
      final quotes = await _quotationService.fetchFinalizedQuotations();
      final acceptedIds = _packages.map((p) => p.id).toSet();
      _finalizedQuotations = quotes.where((q) => !acceptedIds.contains(q.id)).toList();
      _isLoadingQuotations = false;
      notifyListeners();
    } catch (e) {
      _isLoadingQuotations = false;
      _quotationsError = e.toString();
      notifyListeners();
    }
  }

  /// Accept a finalized quotation card directly
  /// Immediately transitions it into confirmed active tours and updates escrow earnings
  Future<TourPackage> acceptFinalizedQuotation(SupabaseQuotation quote) async {
    final lowerTitle = quote.title.toLowerCase();
    String destination = 'Mumbai, Maharashtra';
    String imgUrl = 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=900&q=80';
    String meetingPoint = 'Gateway of India';

    if (lowerTitle.contains('goa')) {
      destination = 'Panjim, Goa';
      imgUrl = 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=900&q=80';
      meetingPoint = 'Fontainhas Post Office';
    } else if (lowerTitle.contains('udaipur')) {
      destination = 'Udaipur, Rajasthan';
      imgUrl = 'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=900&q=80';
      meetingPoint = 'City Palace Gate';
    }

    final newPkg = TourPackage(
      id: quote.id,
      title: quote.title,
      destination: destination,
      imageUrl: imgUrl,
      duration: 'Custom Itinerary • Finalized',
      dates: 'Valid until ${quote.validUntil?.day ?? 15} ${_monthName(quote.validUntil?.month ?? 10)}',
      payoutAmount: quote.totalFinalPrice,
      currentBookings: quote.paxCount > 0 ? quote.paxCount : 1,
      maxCapacity: (quote.paxCount > 0 ? quote.paxCount : 1) + 2,
      difficulty: 'Custom Curated',
      meetingPoint: meetingPoint,
      meetingPointEta: 'Starts at $meetingPoint • Verified in Supabase',
      logisticsBadge: 'Supabase Finalized Booking',
      description: 'Custom operator itinerary booked and finalized for travelers. Validated and confirmed via Supabase.',
      highlights: [
        'Confirmed itinerary with ${quote.paxCount} travelers',
        'Direct payout of ₹${quote.totalFinalPrice.round()} allocated to guide escrow',
        'All locations mapped with live GPS coordinates on OpenStreetMap',
      ],
      inclusions: [
        'All monument entries and experience tickets',
        'Guide stipend & travel compensation covered',
      ],
      status: PackageStatus.accepted,
      acceptedAt: DateTime.now(),
      tourists: [
        TouristUser(
          id: 't_${quote.id.substring(0, 6)}',
          name: 'Confirmed Traveler Squad',
          email: 'traveler@journey.com',
          phone: '+91 98200 88990',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          country: 'India',
          emergencyContact: '+91 98200 00000',
          partySize: quote.paxCount,
          isLeadBooker: true,
        ),
      ],
    );

    // Remove from pending finalized quotations list
    _finalizedQuotations.removeWhere((q) => q.id == quote.id);

    // Add or update in packages list
    _packages.removeWhere((p) => p.id == quote.id);
    _packages.insert(0, newPkg);

    // Initialize chat
    _chatsByPackageId[quote.id] = [
      ChatMessage(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        packageId: quote.id,
        senderId: _currentGuide.id,
        senderName: '${_currentGuide.name} (Guide)',
        senderAvatar: _currentGuide.avatarUrl,
        isGuide: true,
        message: 'Namaste! I have accepted your customized itinerary for "${quote.title}". Excited to lead your tour!',
        timestamp: DateTime.now(),
        isAnnouncement: true,
      ),
    ];

    notifyListeners();
    return newPkg;
  }

  /// Helper to fetch OpenStreetMap coordinates using trip_request_id
  Future<List<ItineraryLocationItem>> fetchItemsForQuotation(SupabaseQuotation quote) async {
    final lowerTitle = quote.title.toLowerCase();
    String city = 'Mumbai';
    if (lowerTitle.contains('goa')) city = 'Goa';
    if (lowerTitle.contains('udaipur')) city = 'Udaipur';
    if (lowerTitle.contains('jaipur')) city = 'Jaipur';
    if (lowerTitle.contains('tokyo')) city = 'Tokyo';

    return await _quotationService.fetchSelectedItemsWithCoordinates(
      tripRequestId: quote.tripRequestId,
      quotationId: quote.id,
      destination: city,
    );
  }

  /// Universal OpenStreetMap stops resolver for ANY tour package.
  /// Works reliably for live Supabase quotations and local curated packages.
  Future<List<ItineraryLocationItem>> getItineraryLocationsForPackage(TourPackage package) async {
    // 1. If package matches a finalized quotation
    final matchingQuote = _finalizedQuotations.where((q) => q.id == package.id).firstOrNull;
    if (matchingQuote != null) {
      return await fetchItemsForQuotation(matchingQuote);
    }

    final lowerTitle = package.title.toLowerCase();
    final lowerDest = package.destination.toLowerCase();

    // 2. Curated South Bombay Art Deco Walk
    if (lowerTitle.contains('south bombay') || lowerTitle.contains('art deco') || (lowerDest.contains('mumbai') && lowerTitle.contains('heritage'))) {
      return [
        ItineraryLocationItem(
          id: 'mum_stop_1',
          title: "CST Terminus & McDonald's Meeting Spot",
          category: 'Place',
          latitude: 18.9401,
          longitude: 72.8354,
          subtitle: 'Starting Point • Fort, Mumbai',
          duration: '30 mins',
          notes: 'Assembly & historical overview of Victorian Gothic terminus',
        ),
        ItineraryLocationItem(
          id: 'mum_stop_2',
          title: 'Oval Maidan & Rajabai Clock Tower',
          category: 'Place',
          latitude: 18.9298,
          longitude: 72.8290,
          subtitle: 'UNESCO Heritage Ensemble',
          duration: '45 mins',
          notes: 'Gothic revival and Art Deco architectural confrontation',
        ),
        ItineraryLocationItem(
          id: 'mum_stop_3',
          title: 'Heritage Irani Cafe Tasting',
          category: 'Activity',
          latitude: 18.9380,
          longitude: 72.8310,
          subtitle: 'Churchgate Heritage Lane',
          duration: '40 mins',
          notes: 'Fresh Bun Maska and Irani Chai experience for tourists',
        ),
        ItineraryLocationItem(
          id: 'mum_stop_4',
          title: "Marine Drive Promenade (Queen's Necklace)",
          category: 'Place',
          latitude: 18.9440,
          longitude: 72.8230,
          subtitle: 'Sunset Viewpoint',
          duration: '60 mins',
          notes: 'Sunset panoramic stroll along the Arabian Sea curve',
        ),
      ];
    }

    // 3. Curated Elephanta Caves Expedition
    if (lowerTitle.contains('elephanta')) {
      return [
        ItineraryLocationItem(
          id: 'mum_ele_1',
          title: 'Gateway of India Jetty',
          category: 'Place',
          latitude: 18.9220,
          longitude: 72.8347,
          subtitle: 'Colaba, Mumbai',
          duration: '30 mins',
          notes: 'Boarding luxury catamaran ferry to Gharapuri Island',
        ),
        ItineraryLocationItem(
          id: 'mum_ele_2',
          title: 'Mumbai Harbor Boat Crossing',
          category: 'Transport',
          latitude: 18.9400,
          longitude: 72.8800,
          subtitle: 'Arabian Sea Cruise',
          duration: '50 mins',
          notes: 'Harbor skyline view and migratory bird watching',
        ),
        ItineraryLocationItem(
          id: 'mum_ele_3',
          title: 'Elephanta Caves UNESCO Monument',
          category: 'Place',
          latitude: 18.9633,
          longitude: 72.9315,
          subtitle: 'Gharapuri Island',
          duration: '2.5 Hours',
          notes: 'Guided storytelling of 6th-century rock-cut Shiva Trimurti',
        ),
        ItineraryLocationItem(
          id: 'mum_ele_4',
          title: 'Cannon Hill Viewpoint',
          category: 'Activity',
          latitude: 18.9650,
          longitude: 72.9340,
          subtitle: 'Island Peak',
          duration: '45 mins',
          notes: 'Vintage Portuguese cannons and panoramic harbor vistas',
        ),
      ];
    }

    // 4. Curated Goa Fontainhas Walk
    if (lowerTitle.contains('fontainhas') || lowerDest.contains('goa')) {
      return [
        ItineraryLocationItem(
          id: 'goa_stop_1',
          title: 'General Post Office Panjim',
          category: 'Place',
          latitude: 15.4989,
          longitude: 73.8278,
          subtitle: 'Designated Meeting Point',
          duration: '20 mins',
          notes: 'Gathering spot by the historic post office plaza',
        ),
        ItineraryLocationItem(
          id: 'goa_stop_2',
          title: 'Fontainhas Latin Quarter',
          category: 'Place',
          latitude: 15.4950,
          longitude: 73.8310,
          subtitle: 'Heritage Portuguese Villas',
          duration: '1 Hour',
          notes: 'Vibrant pastel mansions, azulejo tiles, and wooden balconies',
        ),
        ItineraryLocationItem(
          id: 'goa_stop_3',
          title: 'Confeitaria 31 de Janeiro',
          category: 'Activity',
          latitude: 15.4965,
          longitude: 73.8302,
          subtitle: 'Historic Bakery Stop',
          duration: '35 mins',
          notes: 'Sampling traditional Bebinca and artisanal Goan coffee',
        ),
        ItineraryLocationItem(
          id: 'goa_stop_4',
          title: 'Our Lady of the Immaculate Conception Church',
          category: 'Place',
          latitude: 15.4990,
          longitude: 73.8290,
          subtitle: 'Panjim Church Square',
          duration: '40 mins',
          notes: 'Zig-zag baroque staircases and old city lookout point',
        ),
      ];
    }

    // 5. Curated Udaipur Lake Pichola Walk
    if (lowerTitle.contains('lake pichola') || lowerTitle.contains('udaipur') || lowerDest.contains('udaipur')) {
      return [
        ItineraryLocationItem(
          id: 'uda_stop_1',
          title: 'City Palace Main Gate',
          category: 'Place',
          latitude: 24.5764,
          longitude: 73.6835,
          subtitle: 'Designated Meeting Point',
          duration: '30 mins',
          notes: 'Tour orientation facing the royal Mewar entrance',
        ),
        ItineraryLocationItem(
          id: 'uda_stop_2',
          title: 'Bagore Ki Haveli Courtyard',
          category: 'Place',
          latitude: 24.5790,
          longitude: 73.6820,
          subtitle: 'Gangaur Ghat',
          duration: '45 mins',
          notes: '18th-century royal haveli courtyards and miniature fresco art',
        ),
        ItineraryLocationItem(
          id: 'uda_stop_3',
          title: 'Lake Pichola Solar Boat Cruise',
          category: 'Activity',
          latitude: 24.5753,
          longitude: 73.6800,
          subtitle: 'Lake Pichola Waters',
          duration: '60 mins',
          notes: 'Exclusive boat cruise circling Jag Mandir Island',
        ),
        ItineraryLocationItem(
          id: 'uda_stop_4',
          title: 'Ambrai Ghat Sunset View',
          category: 'Place',
          latitude: 24.5802,
          longitude: 73.6808,
          subtitle: 'Opposite City Palace',
          duration: '45 mins',
          notes: 'Spectacular sunset illumination view of the Palace and Lake',
        ),
      ];
    }

    // 6. Generic Fallback
    String city = 'Mumbai';
    if (lowerDest.contains('goa')) city = 'Goa';
    if (lowerDest.contains('udaipur')) city = 'Udaipur';
    if (lowerDest.contains('jaipur')) city = 'Jaipur';
    if (lowerDest.contains('tokyo')) city = 'Tokyo';

    return await _quotationService.fetchSelectedItemsWithCoordinates(
      tripRequestId: package.id,
      quotationId: package.id,
      destination: city,
    );
  }

  String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return m[month - 1];
    return 'Oct';
  }

  @override
  void dispose() {
    _quotesSubscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_community_models.dart';
import '../data/mock_city_catalog.dart';

class AiCommunityService {
  static final AiCommunityService _instance = AiCommunityService._internal();
  factory AiCommunityService() => _instance;
  AiCommunityService._internal() {
    _initMockData();
  }

  final SupabaseClient _client = Supabase.instance.client;

  // ── Reactive Notifiers for live UI updates ─────────────────────────────────
  final ValueNotifier<List<AiCommunity>> communitiesNotifier =
      ValueNotifier<List<AiCommunity>>([]);
  final ValueNotifier<List<TripPostIt>> postItsNotifier =
      ValueNotifier<List<TripPostIt>>([]);
  final Map<String, ValueNotifier<List<CommunityMessage>>> _messagesByCommunity =
      {};

  ValueNotifier<List<CommunityMessage>> getMessagesNotifier(String communityId) {
    if (!_messagesByCommunity.containsKey(communityId)) {
      _messagesByCommunity[communityId] =
          ValueNotifier<List<CommunityMessage>>(_generateInitialMessages(communityId));
    }
    return _messagesByCommunity[communityId]!;
  }

  // ── Seed / Mock Initial State ──────────────────────────────────────────────
  void _initMockData() {
    final defaultPostIts = [
      TripPostIt(
        id: 'post-it-1',
        userId: 'user-me',
        destination: 'Goa',
        startDate: DateTime.now().add(const Duration(days: 18)),
        endDate: DateTime.now().add(const Duration(days: 22)),
        budgetPerPax: 16500,
        desiredActivities: [
          {'name': 'Scuba Diving at Grande Island', 'price': 3500},
          {'name': 'Mandovi Sunset Catamaran Cruise', 'price': 1800},
          {'name': 'Anjuna Flea Market & Live Music', 'price': 500},
        ],
        desiredHotels: [
          {'name': 'Zostel Plus Morjim Beach', 'price': 3800}
        ],
        status: 'active',
      ),
      TripPostIt(
        id: 'post-it-2',
        userId: 'user-me',
        destination: 'Jaipur',
        startDate: DateTime.now().add(const Duration(days: 35)),
        endDate: DateTime.now().add(const Duration(days: 39)),
        budgetPerPax: 14000,
        desiredActivities: [
          {'name': 'Sunrise Hot Air Balloon Safari', 'price': 7500},
          {'name': 'Amer Fort Heritage Light Show', 'price': 600},
        ],
        status: 'active',
      ),
    ];
    postItsNotifier.value = defaultPostIts;

    final defaultCommunities = [
      AiCommunity(
        id: 'ai-comm-goa-1',
        title: '🌴 Goa Sunset & Chill Co-Living Squad',
        destination: 'Goa',
        tagline: 'AI Clustered from 6 solo travelers with 92% budget & date overlap',
        coverImageUrl:
            'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
        startDate: DateTime.now().add(const Duration(days: 18)),
        endDate: DateTime.now().add(const Duration(days: 22)),
        fixedHotel: const FixedHotel(
          id: 'h-goa-1',
          name: 'The Postcard Hideaway Boutique Resort',
          pricePerNight: 3600,
          rating: 4.9,
          roomType: 'Twin Shared Luxury Garden Villa',
          imageUrl:
              'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
          location: 'Vagator Beachfront, North Goa',
        ),
        fixedTransport: const FixedTransport(
          id: 't-goa-1',
          name: 'Airport Pickup + Dedicated Air-Conditioned Van',
          vehicleType: 'Force Urbania Luxury Van (10-Seater)',
          price: 2200,
          coverage: 'Full-trip intercity transport & airport shuttle',
        ),
        activityRoster: const [
          CommunityActivity(
            id: 'act-1',
            name: 'Scuba Diving & Snorkeling at Grande Island',
            timeSlot: '08:30 AM - 01:30 PM',
            dayNumber: 'Day 2',
            price: 3500,
            category: 'Adventure',
            description:
                'Certified PADI dive master session with underwater video + boat BBQ lunch.',
            icon: Icons.scuba_diving_rounded,
          ),
          CommunityActivity(
            id: 'act-2',
            name: 'Mandovi River Sunset Catamaran Cruise',
            timeSlot: '05:00 PM - 07:30 PM',
            dayNumber: 'Day 2',
            price: 1800,
            category: 'Scenic & Music',
            description:
                'Sunset sail with live Goan acoustic music, unlimited appetizers and mocktails.',
            icon: Icons.sailing_rounded,
          ),
          CommunityActivity(
            id: 'act-3',
            name: 'Fontainhas Heritage Latin Quarter Walking Tour',
            timeSlot: '10:00 AM - 12:30 PM',
            dayNumber: 'Day 3',
            price: 900,
            category: 'Culture',
            description:
                'Guided photo walk through colorful Portuguese villas with local bakery tasting.',
            icon: Icons.camera_alt_rounded,
          ),
          CommunityActivity(
            id: 'act-4',
            name: 'Curated Beach Shack Dinner & Bonfire',
            timeSlot: '08:00 PM - 11:30 PM',
            dayNumber: 'Day 3',
            price: 1500,
            category: 'Nightlife & Food',
            description:
                'Reserved VIP beachside dining table with grilled seafood / vegan mezze and stargazing.',
            icon: Icons.nightlife_rounded,
          ),
        ],
        placesToVisit: const [
          'Vagator Hilltop Viewpoint',
          'Chapora Fort (Dil Chahta Hai point)',
          'Anjuna Flea Market',
          'Ashvem Beach Serenity Zone',
        ],
        masterEstimatedBudget: 19500,
        memberCount: 5,
        maxMembers: 8,
        status: 'forming',
        myCompatibilityScore: 89,
        myMembershipStatus: 'invited',
        myOptedOutActivityIds: [],
        memberAvatars: [
          'https://i.pravatar.cc/150?img=12',
          'https://i.pravatar.cc/150?img=33',
          'https://i.pravatar.cc/150?img=47',
          'https://i.pravatar.cc/150?img=60',
          'https://i.pravatar.cc/150?img=68',
        ],
      ),
      AiCommunity(
        id: 'ai-comm-jaipur-2',
        title: '👑 Royal Forts & Cafe Hopping Jaipur Circle',
        destination: 'Jaipur',
        tagline: 'Formed from 4 solo history buffs with compatible cultural interests',
        coverImageUrl:
            'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=800&q=80',
        startDate: DateTime.now().add(const Duration(days: 35)),
        endDate: DateTime.now().add(const Duration(days: 39)),
        fixedHotel: const FixedHotel(
          id: 'h-jai-1',
          name: 'Shahpura Haveli Heritage Stay',
          pricePerNight: 3200,
          rating: 4.8,
          roomType: 'Heritage Deluxe Room',
          imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
          location: 'Old City Center, Jaipur',
        ),
        fixedTransport: const FixedTransport(
          id: 't-jai-1',
          name: 'Dedicated Royal Chauffeur SUV',
          vehicleType: 'Toyota Innova Crysta',
          price: 2400,
          coverage: 'Full sightseeing + Fort climbs & Station drop',
        ),
        activityRoster: const [
          CommunityActivity(
            id: 'act-jai-1',
            name: 'Sunrise Hot Air Balloon over Amer Valley',
            timeSlot: '05:30 AM - 08:30 AM',
            dayNumber: 'Day 2',
            price: 7500,
            category: 'Adventure',
            description:
                'Magical 60-min aerial flight watching the sunrise over ancient Aravali forts.',
            icon: Icons.air_rounded,
          ),
          CommunityActivity(
            id: 'act-jai-2',
            name: 'Nahargarh Fort Sunset & Padao Cafe Dinner',
            timeSlot: '05:00 PM - 09:00 PM',
            dayNumber: 'Day 2',
            price: 1200,
            category: 'Scenic & Dining',
            description:
                'Panoramic bird’s eye view of the illuminated Pink City with traditional thali.',
            icon: Icons.castle_rounded,
          ),
          CommunityActivity(
            id: 'act-jai-3',
            name: 'Hawa Mahal Rooftop Photography & Chai Trail',
            timeSlot: '09:00 AM - 11:30 AM',
            dayNumber: 'Day 3',
            price: 600,
            category: 'Culture',
            description:
                'Exclusive access to heritage balconies with local storytellers and specialty chai.',
            icon: Icons.local_cafe_rounded,
          ),
        ],
        placesToVisit: const [
          'Amer Fort & Sheesh Mahal',
          'City Palace & Jantar Mantar',
          'Patrika Gate',
          'Hawa Mahal',
        ],
        masterEstimatedBudget: 17500,
        memberCount: 4,
        maxMembers: 6,
        status: 'forming',
        myCompatibilityScore: 94,
        myMembershipStatus: 'bookmarked',
        myOptedOutActivityIds: [],
        memberAvatars: [
          'https://i.pravatar.cc/150?img=11',
          'https://i.pravatar.cc/150?img=25',
          'https://i.pravatar.cc/150?img=53',
          'https://i.pravatar.cc/150?img=65',
        ],
      ),
      AiCommunity(
        id: 'ai-comm-udaipur-3',
        title: '🛶 Udaipur Lakefront Poets & Kayakers',
        destination: 'Udaipur',
        tagline: 'Active squad of 5 solo travelers exploring lakes & palace cafes',
        coverImageUrl:
            'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?auto=format&fit=crop&w=800&q=80',
        startDate: DateTime.now().add(const Duration(days: 48)),
        endDate: DateTime.now().add(const Duration(days: 52)),
        fixedHotel: const FixedHotel(
          id: 'h-udr-1',
          name: 'Zostel Waterfront Lake Pichola',
          pricePerNight: 2800,
          rating: 4.7,
          roomType: 'Lake View Shared Suite',
          imageUrl:
              'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
          location: 'Hanuman Ghat, Udaipur',
        ),
        fixedTransport: const FixedTransport(
          id: 't-udr-1',
          name: 'Lake Shuttle & City Cruiser',
          vehicleType: 'Tempo Luxury Cruiser',
          price: 1800,
          coverage: 'All lake transfers + Monsoon palace hill ride',
        ),
        activityRoster: const [
          CommunityActivity(
            id: 'act-udr-1',
            name: 'Lake Pichola Sunset Private Boat Charter',
            timeSlot: '05:00 PM - 07:00 PM',
            dayNumber: 'Day 1',
            price: 1200,
            category: 'Scenic',
            description:
                'Private golden hour cruise circling Jag Mandir Island with live santoor player.',
            icon: Icons.directions_boat_rounded,
          ),
          CommunityActivity(
            id: 'act-udr-2',
            name: 'Sunrise Kayaking on Fateh Sagar Lake',
            timeSlot: '06:00 AM - 08:30 AM',
            dayNumber: 'Day 2',
            price: 1500,
            category: 'Adventure',
            description:
                'Calm morning paddle with certified instructors and fresh breakfast on the dock.',
            icon: Icons.kayaking_rounded,
          ),
        ],
        placesToVisit: const [
          'City Palace Udaipur',
          'Sajjangarh (Monsoon Palace)',
          'Saheliyon Ki Bari',
          'Ambrai Ghat',
        ],
        masterEstimatedBudget: 13500,
        memberCount: 5,
        maxMembers: 8,
        status: 'locked',
        myCompatibilityScore: 82,
        myMembershipStatus: 'accepted',
        myOptedOutActivityIds: [],
        memberAvatars: [
          'https://i.pravatar.cc/150?img=17',
          'https://i.pravatar.cc/150?img=28',
          'https://i.pravatar.cc/150?img=39',
          'https://i.pravatar.cc/150?img=49',
          'https://i.pravatar.cc/150?img=61',
        ],
      ),
    ];
    communitiesNotifier.value = defaultCommunities;
  }

  // ── Initial Mock Messages & Polls ──────────────────────────────────────────
  List<CommunityMessage> _generateInitialMessages(String communityId) {
    final defaultPoll = CommunityPoll(
      id: 'poll-1',
      communityId: communityId,
      creatorName: 'Priya Sharma',
      question: '💡 Swap Day 2 evening walk for a Sunset Boat Party & Live DJ?',
      options: [
        PollOption(
          id: 'opt-1',
          text: '🎉 Yes! Let’s do the Boat Party (+₹900)',
          votes: 3,
          voterIds: ['u1', 'u2', 'u3'],
        ),
        PollOption(
          id: 'opt-2',
          text: '🧘 No, keep original chill walking tour',
          votes: 1,
          voterIds: ['u4'],
        ),
      ],
    );

    return [
      CommunityMessage(
        id: 'msg-1',
        communityId: communityId,
        senderId: 'user-1',
        senderName: 'Rohan Mehta',
        senderAvatar: 'https://i.pravatar.cc/150?img=12',
        message:
            'Hey everyone! 👋 Super excited the AI matched us for this Goa trip. Dates look perfect for me!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CommunityMessage(
        id: 'msg-2',
        communityId: communityId,
        senderId: 'user-2',
        senderName: 'Ananya Verma',
        senderAvatar: 'https://i.pravatar.cc/150?img=47',
        message:
            'Same here! The hotel at Vagator looks stunning. I opted out of scuba diving to do a chill beach cafe morning instead.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CommunityMessage(
        id: 'msg-3',
        communityId: communityId,
        senderId: 'user-3',
        senderName: 'Priya Sharma',
        senderAvatar: 'https://i.pravatar.cc/150?img=33',
        message:
            'I put together a quick poll for Day 2 evening. Please cast your votes below!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        poll: defaultPoll,
      ),
    ];
  }

  // ── Actions: Post-It Itinerary Creation ─────────────────────────────────────
  Future<bool> saveTripPostIt(TripCartDraft draft) async {
    final user = _client.auth.currentUser;
    final newPostIt = TripPostIt(
      id: 'post-it-${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'user-me',
      destination: draft.city.name,
      startDate: draft.startDate,
      endDate: draft.endDate,
      budgetPerPax: draft.budget,
      desiredActivities: draft.items
          .where((i) => i.type == 'activity')
          .map((i) => i.toCartJson())
          .toList(),
      desiredHotels: draft.items
          .where((i) => i.type == 'hotel')
          .map((i) => i.toCartJson())
          .toList(),
      desiredPlaces: draft.items
          .where((i) => i.type == 'place')
          .map((i) => i.toCartJson())
          .toList(),
      desiredTransport: draft.items
          .where((i) => i.type == 'transport')
          .map((i) => i.toCartJson())
          .toList(),
      status: 'active',
    );

    // 1. Update local reactive state
    postItsNotifier.value = [newPostIt, ...postItsNotifier.value];

    // 2. Persist to Supabase if connected
    try {
      if (user != null) {
        await _client.from('trip_post_its').insert(newPostIt.toJson());
      }
    } catch (e) {
      debugPrint('Notice on trip_post_its table (local fallback used): $e');
    }

    return true;
  }

  // ── Actions: Accept / Decline / Bookmark Community ──────────────────────────
  Future<void> respondToInvitation(String communityId, bool accept) async {
    final list = [...communitiesNotifier.value];
    final index = list.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final current = list[index];
      list[index] = current.copyWith(
        myMembershipStatus: accept ? 'accepted' : 'declined',
        memberCount: accept ? current.memberCount + 1 : current.memberCount,
      );
      communitiesNotifier.value = list;
    }

    // Persist to Supabase
    final user = _client.auth.currentUser;
    if (user != null) {
      try {
        await _client.from('community_members').upsert({
          'community_id': communityId,
          'user_id': user.id,
          'status': accept ? 'accepted' : 'declined',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Notice updating community_members: $e');
      }
    }
  }

  Future<void> toggleBookmark(String communityId) async {
    final list = [...communitiesNotifier.value];
    final index = list.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final current = list[index];
      final newStatus = current.myMembershipStatus == 'bookmarked'
          ? 'invited'
          : 'bookmarked';
      list[index] = current.copyWith(myMembershipStatus: newStatus);
      communitiesNotifier.value = list;
    }
  }

  // ── Actions: Activity Opt-Out (Flexible Roster) ─────────────────────────────
  Future<void> toggleActivityOptOut(String communityId, String activityId) async {
    final list = [...communitiesNotifier.value];
    final index = list.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final current = list[index];
      final optedOut = [...current.myOptedOutActivityIds];
      if (optedOut.contains(activityId)) {
        optedOut.remove(activityId);
      } else {
        optedOut.add(activityId);
      }

      list[index] = current.copyWith(myOptedOutActivityIds: optedOut);
      communitiesNotifier.value = list;
    }
  }

  // ── Actions: Chat & Polling ─────────────────────────────────────────────────
  Future<void> sendMessage(String communityId, String text) async {
    if (text.trim().isEmpty) return;
    final user = _client.auth.currentUser;
    final myName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'] ??
        'You';

    final newMessage = CommunityMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      senderId: user?.id ?? 'user-me',
      senderName: myName,
      senderAvatar: 'https://i.pravatar.cc/150?img=11',
      message: text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
    );

    final notifier = getMessagesNotifier(communityId);
    notifier.value = [...notifier.value, newMessage];
  }

  Future<void> castVote(String communityId, String pollId, String optionId) async {
    final notifier = getMessagesNotifier(communityId);
    final messages = [...notifier.value];
    for (int i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.poll != null && m.poll!.id == pollId) {
        final currentPoll = m.poll!;
        final updatedOptions = currentPoll.options.map((opt) {
          final isTarget = opt.id == optionId;
          final wasSelected = opt.voterIds.contains('user-me');

          if (isTarget && !wasSelected) {
            return opt.copyWith(
              votes: opt.votes + 1,
              voterIds: [...opt.voterIds, 'user-me'],
            );
          } else if (!isTarget && wasSelected) {
            return opt.copyWith(
              votes: opt.votes - 1,
              voterIds: opt.voterIds.where((id) => id != 'user-me').toList(),
            );
          }
          return opt;
        }).toList();

        final updatedPoll = CommunityPoll(
          id: currentPoll.id,
          communityId: currentPoll.communityId,
          creatorName: currentPoll.creatorName,
          question: currentPoll.question,
          options: updatedOptions,
          myVotedOptionId: optionId,
          createdAt: currentPoll.createdAt,
        );

        messages[i] = CommunityMessage(
          id: m.id,
          communityId: m.communityId,
          senderId: m.senderId,
          senderName: m.senderName,
          senderAvatar: m.senderAvatar,
          message: m.message,
          isMe: m.isMe,
          timestamp: m.timestamp,
          poll: updatedPoll,
        );
        break;
      }
    }
    notifier.value = messages;
  }

  Future<void> createPoll(
    String communityId,
    String question,
    List<String> optionTexts,
  ) async {
    if (question.trim().isEmpty || optionTexts.length < 2) return;
    final user = _client.auth.currentUser;
    final myName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'] ??
        'You';

    final poll = CommunityPoll(
      id: 'poll-${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      creatorName: myName,
      question: question.trim(),
      options: optionTexts
          .asMap()
          .entries
          .map(
            (e) => PollOption(
              id: 'opt-${e.key}',
              text: e.value.trim(),
              votes: 0,
            ),
          )
          .toList(),
    );

    final newMessage = CommunityMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      senderId: user?.id ?? 'user-me',
      senderName: myName,
      senderAvatar: 'https://i.pravatar.cc/150?img=11',
      message: '📊 New Poll: ${question.trim()}',
      isMe: true,
      timestamp: DateTime.now(),
      poll: poll,
    );

    final notifier = getMessagesNotifier(communityId);
    notifier.value = [...notifier.value, newMessage];
  }
}

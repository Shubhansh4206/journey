import 'package:flutter/material.dart';

/// ── 1. Trip Post-It Draft Model ─────────────────────────────────────────────
class TripPostIt {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budgetPerPax;
  final List<Map<String, dynamic>> desiredHotels;
  final List<Map<String, dynamic>> desiredActivities;
  final List<Map<String, dynamic>> desiredPlaces;
  final List<Map<String, dynamic>> desiredTransport;
  final String status; // 'active', 'clustered', 'archived'
  final DateTime createdAt;

  TripPostIt({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budgetPerPax,
    this.desiredHotels = const [],
    this.desiredActivities = const [],
    this.desiredPlaces = const [],
    this.desiredTransport = const [],
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TripPostIt.fromJson(Map<String, dynamic> json) {
    return TripPostIt(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      destination: json['destination'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ??
          DateTime.now().add(const Duration(days: 4)),
      budgetPerPax: (json['budget_per_pax'] as num?)?.toDouble() ?? 15000,
      desiredHotels: List<Map<String, dynamic>>.from(json['desired_hotels'] ?? []),
      desiredActivities:
          List<Map<String, dynamic>>.from(json['desired_activities'] ?? []),
      desiredPlaces: List<Map<String, dynamic>>.from(json['desired_places'] ?? []),
      desiredTransport:
          List<Map<String, dynamic>>.from(json['desired_transport'] ?? []),
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'destination': destination,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'budget_per_pax': budgetPerPax,
        'desired_hotels': desiredHotels,
        'desired_activities': desiredActivities,
        'desired_places': desiredPlaces,
        'desired_transport': desiredTransport,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}

/// ── 2. Fixed Hotel & Transport (The Core Base) ──────────────────────────────
class FixedHotel {
  final String id;
  final String name;
  final double pricePerNight;
  final double rating;
  final String roomType;
  final String imageUrl;
  final String location;

  const FixedHotel({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.rating,
    required this.roomType,
    required this.imageUrl,
    required this.location,
  });

  factory FixedHotel.fromJson(Map<String, dynamic> json) {
    return FixedHotel(
      id: json['id']?.toString() ?? 'hotel-1',
      name: json['name'] ?? 'Premium Boutique Resort',
      pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 4200,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      roomType: json['room_type'] ?? 'Co-Living Deluxe Suite',
      imageUrl: json['image_url'] ??
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
      location: json['location'] ?? 'North Goa, Beachfront',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_per_night': pricePerNight,
        'rating': rating,
        'room_type': roomType,
        'image_url': imageUrl,
        'location': location,
      };
}

class FixedTransport {
  final String id;
  final String name;
  final String vehicleType;
  final double price;
  final String coverage;

  const FixedTransport({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.price,
    required this.coverage,
  });

  factory FixedTransport.fromJson(Map<String, dynamic> json) {
    return FixedTransport(
      id: json['id']?.toString() ?? 'trans-1',
      name: json['name'] ?? 'Shared Private Tempo Traveler / SUV',
      vehicleType: json['vehicle_type'] ?? 'AC Luxury Cruiser',
      price: (json['price'] as num?)?.toDouble() ?? 2500,
      coverage: json['coverage'] ?? 'Airport Pickup + All-Trip Transit',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vehicle_type': vehicleType,
        'price': price,
        'coverage': coverage,
      };
}

/// ── 3. Flexible Community Activity ──────────────────────────────────────────
class CommunityActivity {
  final String id;
  final String name;
  final String timeSlot;
  final String dayNumber; // e.g. "Day 1 - Evening"
  final double price;
  final String category; // 'Adventure', 'Culture', 'Nightlife', 'Food & Dining'
  final String description;
  final IconData icon;
  final bool isFixed; // false by default for open roster items

  const CommunityActivity({
    required this.id,
    required this.name,
    required this.timeSlot,
    required this.dayNumber,
    required this.price,
    required this.category,
    required this.description,
    this.icon = Icons.local_activity_rounded,
    this.isFixed = false,
  });

  factory CommunityActivity.fromJson(Map<String, dynamic> json) {
    return CommunityActivity(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      timeSlot: json['time_slot'] ?? '10:00 AM',
      dayNumber: json['day_number'] ?? 'Day 1',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Experience',
      description: json['description'] ?? '',
      isFixed: json['is_fixed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time_slot': timeSlot,
        'day_number': dayNumber,
        'price': price,
        'category': category,
        'description': description,
        'is_fixed': isFixed,
      };
}

/// ── 4. AI Community Master Model ────────────────────────────────────────────
class AiCommunity {
  final String id;
  final String title;
  final String destination;
  final String tagline;
  final String coverImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final FixedHotel fixedHotel;
  final FixedTransport fixedTransport;
  final List<CommunityActivity> activityRoster;
  final List<String> placesToVisit;
  final double masterEstimatedBudget;
  final int memberCount;
  final int maxMembers;
  final String status; // 'forming', 'locked', 'in_progress'
  final int myCompatibilityScore; // e.g. 88%
  final String myMembershipStatus; // 'invited', 'accepted', 'declined', 'bookmarked'
  final List<String> myOptedOutActivityIds;
  final List<String> memberAvatars;

  AiCommunity({
    required this.id,
    required this.title,
    required this.destination,
    required this.tagline,
    required this.coverImageUrl,
    required this.startDate,
    required this.endDate,
    required this.fixedHotel,
    required this.fixedTransport,
    required this.activityRoster,
    this.placesToVisit = const [],
    required this.masterEstimatedBudget,
    this.memberCount = 4,
    this.maxMembers = 8,
    this.status = 'forming',
    this.myCompatibilityScore = 85,
    this.myMembershipStatus = 'invited',
    this.myOptedOutActivityIds = const [],
    this.memberAvatars = const [],
  });

  /// Calculate personal cost based on opted-out flexible activities
  double get personalCost {
    double total = (fixedHotel.pricePerNight * 3) + fixedTransport.price;
    for (final act in activityRoster) {
      if (!myOptedOutActivityIds.contains(act.id)) {
        total += act.price;
      }
    }
    return total;
  }

  /// Total money saved by opting out
  double get totalSavedAmount {
    double saved = 0;
    for (final act in activityRoster) {
      if (myOptedOutActivityIds.contains(act.id)) {
        saved += act.price;
      }
    }
    return saved;
  }

  AiCommunity copyWith({
    String? title,
    String? myMembershipStatus,
    List<String>? myOptedOutActivityIds,
    int? memberCount,
  }) {
    return AiCommunity(
      id: id,
      title: title ?? this.title,
      destination: destination,
      tagline: tagline,
      coverImageUrl: coverImageUrl,
      startDate: startDate,
      endDate: endDate,
      fixedHotel: fixedHotel,
      fixedTransport: fixedTransport,
      activityRoster: activityRoster,
      placesToVisit: placesToVisit,
      masterEstimatedBudget: masterEstimatedBudget,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers,
      status: status,
      myCompatibilityScore: myCompatibilityScore,
      myMembershipStatus: myMembershipStatus ?? this.myMembershipStatus,
      myOptedOutActivityIds: myOptedOutActivityIds ?? this.myOptedOutActivityIds,
      memberAvatars: memberAvatars,
    );
  }
}

/// ── 5. Poll & Negotiation Models ────────────────────────────────────────────
class PollOption {
  final String id;
  final String text;
  final int votes;
  final List<String> voterIds;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
    this.voterIds = const [],
  });

  PollOption copyWith({int? votes, List<String>? voterIds}) {
    return PollOption(
      id: id,
      text: text,
      votes: votes ?? this.votes,
      voterIds: voterIds ?? this.voterIds,
    );
  }
}

class CommunityPoll {
  final String id;
  final String communityId;
  final String creatorName;
  final String question;
  final List<PollOption> options;
  final String status; // 'open', 'resolved'
  final DateTime createdAt;
  final String? myVotedOptionId;

  CommunityPoll({
    required this.id,
    required this.communityId,
    required this.creatorName,
    required this.question,
    required this.options,
    this.status = 'open',
    DateTime? createdAt,
    this.myVotedOptionId,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);
}

/// ── 6. Community Chat Message Model ─────────────────────────────────────────
class CommunityMessage {
  final String id;
  final String communityId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final CommunityPoll? poll; // If the message is an embedded poll

  CommunityMessage({
    required this.id,
    required this.communityId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    this.isMe = false,
    DateTime? timestamp,
    this.poll,
  }) : timestamp = timestamp ?? DateTime.now();
}

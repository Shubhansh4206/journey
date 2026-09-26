import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CatalogItem {
  final String id;
  final String name;
  final String type; // hotel | activity | place | transport
  final double price;
  final String subtitle;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.subtitle = '',
  });

  /// Factory constructor for mapping Supabase operator_hotels table
  factory CatalogItem.fromHotelJson(Map<String, dynamic> json) {
    final star = json['star_rating'];
    final starPrefix = (star != null && star > 0) ? '$star★ • ' : '';
    final address = json['address']?.toString() ?? json['city']?.toString() ?? '';
    
    List<String> amenitiesList = [];
    if (json['amenities'] is List) {
      amenitiesList = (json['amenities'] as List).map((e) => e.toString()).toList();
    }
    final amenitiesSuffix = amenitiesList.isNotEmpty ? ' (${amenitiesList.take(2).join(', ')})' : '';

    return CatalogItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['name']?.toString() ?? 'Hotel Stay',
      type: 'hotel',
      price: (json['contracted_rate_per_night'] as num?)?.toDouble() ?? 0.0,
      subtitle: '$starPrefix$address$amenitiesSuffix'.trim(),
    );
  }

  /// Factory constructor for mapping Supabase operator_places table
  factory CatalogItem.fromPlaceJson(Map<String, dynamic> json) {
    final desc = json['description']?.toString() ?? '';
    List<String> tagsList = [];
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List).map((e) => e.toString()).toList();
    }
    final tagsSuffix = tagsList.isNotEmpty ? ' • ${tagsList.join(', ')}' : '';

    return CatalogItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['name']?.toString() ?? 'Attraction',
      type: 'place',
      price: (json['entry_fee_per_person'] as num?)?.toDouble() ?? 0.0,
      subtitle: desc.isNotEmpty ? '$desc$tagsSuffix' : 'Scenic landmark',
    );
  }

  /// Factory constructor for mapping Supabase operator_activities table
  factory CatalogItem.fromActivityJson(Map<String, dynamic> json) {
    final duration = json['duration_minutes'];
    final durStr = duration != null ? '$duration mins • ' : '';
    final activityType = json['activity_type']?.toString() ?? 'Experience';
    final location = json['location']?.toString() ?? '';

    return CatalogItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['title']?.toString() ?? 'Activity',
      type: 'activity',
      price: (json['cost_per_person'] as num?)?.toDouble() ?? 0.0,
      subtitle: '$durStr$activityType in $location'.trim(),
    );
  }

  /// Factory constructor for mapping Supabase operator_transport table
  factory CatalogItem.fromTransportJson(Map<String, dynamic> json) {
    final capacity = json['capacity_passengers'] ?? 4;
    List<String> features = [];
    if (json['features'] is List) {
      features = (json['features'] as List).map((e) => e.toString()).toList();
    }
    final featStr = features.isNotEmpty ? ' • ${features.join(', ')}' : '';

    return CatalogItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['vehicle_type']?.toString() ?? 'Private Vehicle',
      type: 'transport',
      price: (json['cost_per_day'] as num?)?.toDouble() ?? 0.0,
      subtitle: '$capacity Passengers$featStr',
    );
  }

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'subtitle': subtitle,
    };
  }
}

class CityCatalog {
  final String id;
  final String name;
  final String tagline;
  final String imageUrl;
  final Color accent;
  final List<CatalogItem> hotels;
  final List<CatalogItem> activities;
  final List<CatalogItem> places;
  final List<CatalogItem> transport;

  const CityCatalog({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.accent,
    required this.hotels,
    required this.activities,
    required this.places,
    this.transport = const [],
  });

  CityCatalog copyWith({
    String? id,
    String? name,
    String? tagline,
    String? imageUrl,
    Color? accent,
    List<CatalogItem>? hotels,
    List<CatalogItem>? activities,
    List<CatalogItem>? places,
    List<CatalogItem>? transport,
  }) {
    return CityCatalog(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      imageUrl: imageUrl ?? this.imageUrl,
      accent: accent ?? this.accent,
      hotels: hotels ?? this.hotels,
      activities: activities ?? this.activities,
      places: places ?? this.places,
      transport: transport ?? this.transport,
    );
  }
}

class TripCartDraft {
  final CityCatalog city;
  final List<CatalogItem> items;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final bool isSolo;

  const TripCartDraft({
    required this.city,
    required this.items,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.isSolo,
  });

  double get estimatedTotal =>
      items.fold(0, (sum, item) => sum + item.price);
}

const List<CityCatalog> mockCities = [
  CityCatalog(
    id: 'mumbai',
    name: 'Mumbai',
    tagline: 'Marine Drive, Bollywood & Cafes',
    imageUrl:
        'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=800',
    accent: AppColors.electricBlue,
    hotels: [],
    activities: [],
    places: [],
    transport: [],
  ),
  CityCatalog(
    id: 'goa',
    name: 'Goa',
    tagline: 'Beaches, shacks & nightlife',
    imageUrl:
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
    accent: AppColors.punchPink,
    hotels: [],
    activities: [],
    places: [],
    transport: [],
  ),
  CityCatalog(
    id: 'jaipur',
    name: 'Jaipur',
    tagline: 'Palaces, bazaars & pink walls',
    imageUrl:
        'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800',
    accent: AppColors.vibrantPurple,
    hotels: [],
    activities: [],
    places: [],
    transport: [],
  ),
  CityCatalog(
    id: 'udaipur',
    name: 'Udaipur',
    tagline: 'Lakes, royal palaces & sunsets',
    imageUrl:
        'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
    accent: AppColors.electricYellow,
    hotels: [],
    activities: [],
    places: [],
    transport: [],
  ),
];






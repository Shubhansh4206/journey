import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CatalogItem {
  final String id;
  final String name;
  final String type; // hotel | activity | place
  final double price;
  final String subtitle;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.subtitle = '',
  });

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

  const CityCatalog({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.accent,
    required this.hotels,
    required this.activities,
    required this.places,
  });
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
    id: 'manali',
    name: 'Manali',
    tagline: 'Snow, cafes & mountains',
    imageUrl:
        'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800',
    accent: AppColors.electricBlue,
    hotels: [
      CatalogItem(
        id: 'manali-h1',
        name: 'Cedar Valley Stay',
        type: 'hotel',
        price: 4200,
        subtitle: 'River-facing, breakfast included',
      ),
      CatalogItem(
        id: 'manali-h2',
        name: 'Old Manali Hostel',
        type: 'hotel',
        price: 1800,
        subtitle: 'Social dorms, rooftop bonfire',
      ),
      CatalogItem(
        id: 'manali-h3',
        name: 'Solang Heights Resort',
        type: 'hotel',
        price: 7800,
        subtitle: 'Ski-access, spa',
      ),
    ],
    activities: [
      CatalogItem(
        id: 'manali-a1',
        name: 'Solang paragliding',
        type: 'activity',
        price: 2500,
        subtitle: '15 min tandem flight',
      ),
      CatalogItem(
        id: 'manali-a2',
        name: 'Beas river rafting',
        type: 'activity',
        price: 1600,
        subtitle: 'Half day, grade II',
      ),
      CatalogItem(
        id: 'manali-a3',
        name: 'Hampta Pass day hike',
        type: 'activity',
        price: 2200,
        subtitle: 'Guided, packed lunch',
      ),
    ],
    places: [
      CatalogItem(
        id: 'manali-p1',
        name: 'Hadimba Temple',
        type: 'place',
        price: 0,
        subtitle: 'Cedar forest shrine',
      ),
      CatalogItem(
        id: 'manali-p2',
        name: 'Mall Road',
        type: 'place',
        price: 0,
        subtitle: 'Cafes & evening walk',
      ),
      CatalogItem(
        id: 'manali-p3',
        name: 'Jogini Falls',
        type: 'place',
        price: 300,
        subtitle: 'Local jeep + short trek',
      ),
    ],
  ),
  CityCatalog(
    id: 'goa',
    name: 'Goa',
    tagline: 'Beaches, shacks & nightlife',
    imageUrl:
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
    accent: AppColors.punchPink,
    hotels: [
      CatalogItem(
        id: 'goa-h1',
        name: 'Anjuna Palm Inn',
        type: 'hotel',
        price: 5500,
        subtitle: '2 min to the beach',
      ),
      CatalogItem(
        id: 'goa-h2',
        name: 'Panjim Heritage Stay',
        type: 'hotel',
        price: 3900,
        subtitle: 'Latin Quarter boutique',
      ),
      CatalogItem(
        id: 'goa-h3',
        name: 'South Goa Villa',
        type: 'hotel',
        price: 9200,
        subtitle: 'Private pool, Palolem',
      ),
    ],
    activities: [
      CatalogItem(
        id: 'goa-a1',
        name: 'Sunset cruise',
        type: 'activity',
        price: 1800,
        subtitle: 'Mandovi river',
      ),
      CatalogItem(
        id: 'goa-a2',
        name: 'Water sports combo',
        type: 'activity',
        price: 2400,
        subtitle: 'Banana + jet ski',
      ),
      CatalogItem(
        id: 'goa-a3',
        name: 'Spice plantation lunch',
        type: 'activity',
        price: 1500,
        subtitle: 'Ponda, guided walk',
      ),
    ],
    places: [
      CatalogItem(
        id: 'goa-p1',
        name: 'Baga Beach',
        type: 'place',
        price: 0,
        subtitle: 'Shacks & water sports',
      ),
      CatalogItem(
        id: 'goa-p2',
        name: 'Fort Aguada',
        type: 'place',
        price: 150,
        subtitle: 'Lighthouse views',
      ),
      CatalogItem(
        id: 'goa-p3',
        name: 'Fontainhas',
        type: 'place',
        price: 0,
        subtitle: 'Portuguese lanes',
      ),
    ],
  ),
  CityCatalog(
    id: 'jaipur',
    name: 'Jaipur',
    tagline: 'Palaces, bazaars & pink walls',
    imageUrl:
        'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800',
    accent: AppColors.vibrantPurple,
    hotels: [
      CatalogItem(
        id: 'jaipur-h1',
        name: 'Haveli on MI Road',
        type: 'hotel',
        price: 3600,
        subtitle: 'Courtyard breakfast',
      ),
      CatalogItem(
        id: 'jaipur-h2',
        name: 'Amer Fort View Hotel',
        type: 'hotel',
        price: 6400,
        subtitle: 'Hill-facing rooms',
      ),
    ],
    activities: [
      CatalogItem(
        id: 'jaipur-a1',
        name: 'Hot air balloon',
        type: 'activity',
        price: 8500,
        subtitle: 'Sunrise over Amer',
      ),
      CatalogItem(
        id: 'jaipur-a2',
        name: 'Cooking class',
        type: 'activity',
        price: 2100,
        subtitle: 'Rajasthani thali',
      ),
    ],
    places: [
      CatalogItem(
        id: 'jaipur-p1',
        name: 'Hawa Mahal',
        type: 'place',
        price: 200,
        subtitle: 'Palace of winds',
      ),
      CatalogItem(
        id: 'jaipur-p2',
        name: 'Amber Fort',
        type: 'place',
        price: 550,
        subtitle: 'Elephant village nearby',
      ),
      CatalogItem(
        id: 'jaipur-p3',
        name: 'Johari Bazaar',
        type: 'place',
        price: 0,
        subtitle: 'Jewelry & textiles',
      ),
    ],
  ),
  CityCatalog(
    id: 'rishikesh',
    name: 'Rishikesh',
    tagline: 'Ganga, yoga & adventure',
    imageUrl:
        'https://images.unsplash.com/photo-1582510003544-4d00b8af1fe0?w=800',
    accent: AppColors.electricYellow,
    hotels: [
      CatalogItem(
        id: 'rishi-h1',
        name: 'Laxman Jhula Lodge',
        type: 'hotel',
        price: 2800,
        subtitle: 'River-facing balcony',
      ),
      CatalogItem(
        id: 'rishi-h2',
        name: 'Tapovan Yoga Retreat',
        type: 'hotel',
        price: 5100,
        subtitle: 'Morning asana included',
      ),
    ],
    activities: [
      CatalogItem(
        id: 'rishi-a1',
        name: 'White water rafting',
        type: 'activity',
        price: 1900,
        subtitle: '16 km stretch',
      ),
      CatalogItem(
        id: 'rishi-a2',
        name: 'Bungee jump',
        type: 'activity',
        price: 3500,
        subtitle: 'Jumpin Heights',
      ),
      CatalogItem(
        id: 'rishi-a3',
        name: 'Ganga aarti boat',
        type: 'activity',
        price: 800,
        subtitle: 'Triveni ghat evening',
      ),
    ],
    places: [
      CatalogItem(
        id: 'rishi-p1',
        name: 'Beatles Ashram',
        type: 'place',
        price: 150,
        subtitle: 'Street art & history',
      ),
      CatalogItem(
        id: 'rishi-p2',
        name: 'Triveni Ghat',
        type: 'place',
        price: 0,
        subtitle: 'Evening aarti',
      ),
    ],
  ),
  CityCatalog(
    id: 'udaipur',
    name: 'Udaipur',
    tagline: 'Lakes, royal palaces & sunsets',
    imageUrl:
        'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800',
    accent: AppColors.vibrantPurple,
    hotels: [
      CatalogItem(
        id: 'udr-h1',
        name: 'Pichola Lake Resort',
        type: 'hotel',
        price: 6800,
        subtitle: 'Palace view balcony',
      ),
      CatalogItem(
        id: 'udr-h2',
        name: 'Fateh Sagar Hostel',
        type: 'hotel',
        price: 2200,
        subtitle: 'Rooftop cafe & dorms',
      ),
    ],
    activities: [
      CatalogItem(
        id: 'udr-a1',
        name: 'Lake Pichola sunset boat',
        type: 'activity',
        price: 1200,
        subtitle: '1 hour scenic boat ride',
      ),
      CatalogItem(
        id: 'udr-a2',
        name: 'Bagore Ki Haveli dance show',
        type: 'activity',
        price: 400,
        subtitle: 'Folk performance at dusk',
      ),
    ],
    places: [
      CatalogItem(
        id: 'udr-p1',
        name: 'City Palace Udaipur',
        type: 'place',
        price: 300,
        subtitle: 'Royal museum & courtyards',
      ),
      CatalogItem(
        id: 'udr-p2',
        name: 'Saheliyon Ki Bari',
        type: 'place',
        price: 100,
        subtitle: 'Fountain gardens',
      ),
    ],
  ),
];


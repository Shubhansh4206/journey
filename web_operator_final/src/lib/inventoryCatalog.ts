import { CartCatalogItem } from './types';

export const INVENTORY_CATALOG: CartCatalogItem[] = [
  // HOTELS
  {
    id: 'inv-hotel-1',
    node_type: 'hotel',
    title: 'Aman Tokyo - Premier Suite',
    category: 'Hotels & Ryokans',
    base_cost: 950,
    margin_percentage: 18,
    location: 'Otemachi, Tokyo',
    description: 'Panoramic skyline views, traditional furo soaking tubs, minimalist Japanese aesthetic.',
    image_url: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&q=80',
    rating: 4.9,
    badge: 'Luxury 5★',
    details: {
      room_type: 'Premier King Suite',
      nights: 3,
      provider: 'Aman Group',
      amenities: ['Skyline Spa', 'Breakfast Included', 'Private Butler']
    }
  },
  {
    id: 'inv-hotel-2',
    node_type: 'hotel',
    title: 'Hoshinoya Kyoto - Riverside Ryokan',
    category: 'Hotels & Ryokans',
    base_cost: 720,
    margin_percentage: 20,
    location: 'Arashiyama, Kyoto',
    description: 'Historic riverside retreat accessible only by traditional wooden boat.',
    image_url: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600&q=80',
    rating: 4.9,
    badge: 'Heritage Ryokan',
    details: {
      room_type: 'Pavilion River View',
      nights: 2,
      provider: 'Hoshino Resorts',
      amenities: ['Kaiseki Dinner', 'Private Boat Transfer', 'Zen Meditation']
    }
  },
  {
    id: 'inv-hotel-3',
    node_type: 'hotel',
    title: 'Park Hyatt Niseko Hanazono',
    category: 'Hotels & Ryokans',
    base_cost: 620,
    margin_percentage: 15,
    location: 'Niseko, Hokkaido',
    description: 'Ski-in ski-out luxury resort overlooking Mount Yotei with Michelin-starred dining.',
    image_url: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=80',
    rating: 4.8,
    badge: 'Alpine Ski Resort',
    details: {
      room_type: 'Mountain View Onsen Suite',
      nights: 2,
      provider: 'Hyatt International',
      amenities: ['Private Onsen', 'Ski Valet', 'Spa Access']
    }
  },

  // FLIGHTS
  {
    id: 'inv-flight-1',
    node_type: 'flight',
    title: 'ANA First Class: SFO -> HND (NH107)',
    category: 'Flights & Aviation',
    base_cost: 1400,
    margin_percentage: 12,
    location: 'San Francisco to Tokyo Haneda',
    description: 'The Room Suite with sliding privacy doors, 4K 24-inch screens, seasonal Japanese gastronomy.',
    image_url: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=600&q=80',
    rating: 5.0,
    badge: 'Business/First',
    details: {
      provider: 'All Nippon Airways',
      pnr_or_confirmation: 'NH-98442',
      departure_time: '11:30 AM',
      arrival_time: '03:40 PM (+1d)',
      duration: '11h 10m'
    }
  },
  {
    id: 'inv-flight-2',
    node_type: 'flight',
    title: 'JAL Domestic Executive: HND -> CTS (JL519)',
    category: 'Flights & Aviation',
    base_cost: 210,
    margin_percentage: 15,
    location: 'Tokyo to Sapporo',
    description: 'Fast domestic hop to Hokkaido in JAL Class J leather recliners.',
    image_url: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&q=80',
    rating: 4.7,
    badge: 'Domestic Express',
    details: {
      provider: 'Japan Airlines',
      pnr_or_confirmation: 'JL-5190',
      duration: '1h 35m'
    }
  },

  // TRANSFERS
  {
    id: 'inv-transfer-1',
    node_type: 'transfer',
    title: 'Shinkansen Gran Class (Tokyo -> Kyoto)',
    category: 'Ground Transfers',
    base_cost: 240,
    margin_percentage: 15,
    location: 'Tokaido Shinkansen',
    description: 'Gran Class bullet train luxury carriage with dedicated attendant and bento service.',
    image_url: 'https://images.unsplash.com/photo-1490806843957-31f4c9a91c65?w=600&q=80',
    rating: 4.9,
    badge: 'High-Speed Rail',
    details: {
      transport_mode: 'Bullet Train (Gran Class)',
      duration: '2h 15m',
      distance_km: 450,
      provider: 'JR Central'
    }
  },
  {
    id: 'inv-transfer-2',
    node_type: 'transfer',
    title: 'VIP Chauffeur: Lexus LM Private Fleet',
    category: 'Ground Transfers',
    base_cost: 320,
    margin_percentage: 22,
    location: 'Tokyo Metropolitan / Airport',
    description: 'Executive ultra-luxury MPV with reclining captain seats, privacy partition, Wi-Fi.',
    image_url: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=600&q=80',
    rating: 4.9,
    badge: 'Private Chauffeur',
    details: {
      transport_mode: 'Private Luxury Van',
      duration: 'Full Day Standby',
      distance_km: 120,
      provider: 'Tokyo Executive Chauffeurs'
    }
  },

  // ACTIVITIES
  {
    id: 'inv-activity-1',
    node_type: 'activity',
    title: 'Private Geisha Dinner & Tea Ceremony',
    category: 'Curated Activities',
    base_cost: 450,
    margin_percentage: 25,
    location: 'Gion District, Kyoto',
    description: 'Exclusive evening in an authentic ochaya teahouse with traditional dance and games.',
    image_url: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&q=80',
    rating: 5.0,
    badge: 'VIP Exclusive',
    details: {
      duration: '3.5 hours',
      provider: 'Kyoto Cultural Heritage Guild',
      tags: ['Culture', 'Culinary', 'Private Access']
    }
  },
  {
    id: 'inv-activity-2',
    node_type: 'activity',
    title: 'Mount Fuji Scenic Helicopter Expedition',
    category: 'Curated Activities',
    base_cost: 580,
    margin_percentage: 20,
    location: 'Hakone & Mt. Fuji Basin',
    description: 'Private 45-minute aerial flight around the snowy crater of Mount Fuji and Lake Ashi.',
    image_url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&q=80',
    rating: 4.9,
    badge: 'Aerial Adventure',
    details: {
      duration: '45 mins flight + champagne reception',
      provider: 'Aero Fuji Charters',
      tags: ['Scenic Flight', 'Photography', 'VIP']
    }
  },
  {
    id: 'inv-activity-3',
    node_type: 'activity',
    title: 'Tsukiji Outer Market Master Chef Tour',
    category: 'Curated Activities',
    base_cost: 190,
    margin_percentage: 25,
    location: 'Tsukiji, Tokyo',
    description: 'Early morning tasting tour of tuna, sea urchin, and wagyu led by a licensed sushi chef.',
    image_url: 'https://images.unsplash.com/photo-1553621042-f6e147245754?w=600&q=80',
    rating: 4.8,
    badge: 'Gastronomy',
    details: {
      duration: '3 hours',
      provider: 'Edo Culinary Guild',
      tags: ['Foodie', 'Local Market', 'Chef Guide']
    }
  }
];

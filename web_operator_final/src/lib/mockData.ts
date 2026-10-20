import { TourGuide, TripRequest, ItineraryNode, ItineraryEdge } from './types';

export const SEED_TOUR_GUIDES: TourGuide[] = [
  {
    id: 'tg-rahul-mumbai',
    name: 'Rahul Sharma',
    first_name: 'Rahul',
    last_name: 'Sharma',
    city: 'Mumbai',
    contact_number: '+91 98201-45678',
    languages: ['English', 'Hindi', 'Marathi'],
    daily_rate: 150,
    is_active: true,
  },
  {
    id: 'tg-vikram-udaipur',
    name: 'Vikram Singh Mewar',
    first_name: 'Vikram',
    last_name: 'Singh',
    city: 'Udaipur',
    contact_number: '+91 94141-89012',
    languages: ['English', 'Hindi', 'French'],
    daily_rate: 180,
    is_active: true,
  },
  {
    id: 'tg-ananya-jaipur',
    name: 'Ananya Rathore',
    first_name: 'Ananya',
    last_name: 'Rathore',
    city: 'Jaipur',
    contact_number: '+91 98290-12345',
    languages: ['English', 'Hindi', 'German'],
    daily_rate: 160,
    is_active: true,
  },
  {
    id: 'tg-rohan-goa',
    name: 'Rohan D Souza',
    first_name: 'Rohan',
    last_name: 'D Souza',
    city: 'Goa',
    contact_number: '+91 98221-67890',
    languages: ['English', 'Hindi', 'Portuguese'],
    daily_rate: 140,
    is_active: true,
  }
];

export const SAMPLE_TRIP_REQUESTS: TripRequest[] = [
  {
    id: 'req-tokyo-kyoto-01',
    customer_id: 'cust-sarah-jenkins',
    customer_name: 'Sarah Jenkins & Partner',
    customer_email: 'sarah.j@journey-traveler.io',
    destination: 'Tokyo & Kyoto Cultural Highlights',
    travel_dates: '2026-10-15 to 2026-10-22',
    budget_range: [4000, 6000],
    status: 'pending',
    user_preferences: 'Couple celebrating 10th anniversary. Looking for a mix of high-end ryokan with private onsen, first-class bullet train transfer, authentic tea ceremony in Kyoto, and Michelin-star dining in Tokyo. Prefer private transportation over crowded buses.',
    created_at: new Date(Date.now() - 3600000 * 4).toISOString()
  },
  {
    id: 'req-hokkaido-winter-02',
    customer_id: 'cust-marcus-vance',
    customer_name: 'Marcus Vance & Family (4 Pax)',
    customer_email: 'm.vance@venturecapital.com',
    destination: 'Hokkaido Ski & Onsen Winter Retreat',
    travel_dates: '2026-12-10 to 2026-12-18',
    budget_range: [8000, 12000],
    status: 'pending',
    user_preferences: 'Family of four wanting ski-in ski-out resort in Niseko, English-speaking private ski instructor for 2 days, private van transfer from New Chitose airport, and authentic seafood dinners in Otaru.',
    created_at: new Date(Date.now() - 3600000 * 18).toISOString()
  },
  {
    id: 'req-fuji-hakone-03',
    customer_id: 'cust-elena-rostova',
    customer_name: 'Elena Rostova',
    customer_email: 'elena.rostova@designstudio.ch',
    destination: 'Hakone & Mount Fuji Art & Wellness',
    travel_dates: '2026-11-01 to 2026-11-06',
    budget_range: [3000, 4500],
    status: 'reviewing',
    user_preferences: 'Solo creative director retreat. Interested in open-air sculpture museums, panoramic Fuji views, luxury onsen spa, helicopter scenic flight, and peaceful meditation spots.',
    created_at: new Date(Date.now() - 3600000 * 32).toISOString()
  }
];

export const INITIAL_DEMO_NODES: ItineraryNode[] = [
  {
    id: 'node-fl-1',
    itinerary_id: 'itin-demo-1',
    node_type: 'flight',
    title: 'ANA First Class: SFO -> HND',
    base_cost: 1400,
    margin_percentage: 12,
    final_price: 1568,
    ui_coordinates: { x: 80, y: 140 },
    ai_metadata: {
      generated_by: 'agent',
      confidence_score: 0.98,
      reasoning: 'Arrival at Tokyo Haneda allows quickest VIP transfer to Aman Tokyo.'
    },
    details: {
      provider: 'All Nippon Airways (NH107)',
      pnr_or_confirmation: 'NH-98442',
      departure_time: '11:30 AM PST',
      arrival_time: '03:40 PM JST (+1d)',
      duration: '11h 10m'
    }
  },
  {
    id: 'node-ht-1',
    itinerary_id: 'itin-demo-1',
    node_type: 'hotel',
    title: 'Aman Tokyo - Premier Suite (3 Nights)',
    base_cost: 950,
    margin_percentage: 18,
    final_price: 1121,
    ui_coordinates: { x: 420, y: 80 },
    ai_metadata: {
      generated_by: 'agent',
      confidence_score: 0.96,
      reasoning: 'Matches couple anniversary preference for top-tier urban luxury.'
    },
    details: {
      room_type: 'Premier King Suite',
      nights: 3,
      provider: 'Aman Group',
      city: 'Tokyo'
    }
  },
  {
    id: 'node-act-1',
    itinerary_id: 'itin-demo-1',
    node_type: 'activity',
    title: 'Tsukiji Master Chef Tasting & Private Tour',
    base_cost: 190,
    margin_percentage: 25,
    final_price: 237.5,
    ui_coordinates: { x: 420, y: 340 },
    ai_metadata: {
      generated_by: 'operator',
      confidence_score: 0.92
    },
    details: {
      duration: '3 hours',
      provider: 'Edo Culinary Guild',
      city: 'Tokyo'
    }
  },
  {
    id: 'node-tr-1',
    itinerary_id: 'itin-demo-1',
    node_type: 'transfer',
    title: 'Shinkansen Gran Class (Tokyo -> Kyoto)',
    base_cost: 240,
    margin_percentage: 15,
    final_price: 276,
    ui_coordinates: { x: 760, y: 140 },
    ai_metadata: {
      generated_by: 'agent',
      confidence_score: 0.99,
      reasoning: 'Gran Class offers VIP luxury rail experience through Mount Fuji corridor.'
    },
    details: {
      transport_mode: 'Shinkansen Bullet Train',
      duration: '2h 15m',
      distance_km: 450
    }
  },
  {
    id: 'node-ht-2',
    itinerary_id: 'itin-demo-1',
    node_type: 'hotel',
    title: 'Hoshinoya Kyoto - Riverside Ryokan (2 Nights)',
    base_cost: 720,
    margin_percentage: 20,
    final_price: 864,
    ui_coordinates: { x: 1100, y: 80 },
    ai_metadata: {
      generated_by: 'agent',
      confidence_score: 0.97,
      reasoning: 'Private boat access and riverfront onsen fulfills anniversary retreat wish.'
    },
    details: {
      room_type: 'Pavilion River View',
      nights: 2,
      provider: 'Hoshino Resorts',
      city: 'Kyoto'
    }
  },
  {
    id: 'node-act-2',
    itinerary_id: 'itin-demo-1',
    node_type: 'activity',
    title: 'Private Geisha Dinner & Tea Ceremony in Gion',
    base_cost: 450,
    margin_percentage: 25,
    final_price: 562.5,
    ui_coordinates: { x: 1100, y: 340 },
    ai_metadata: {
      generated_by: 'agent',
      confidence_score: 0.95
    },
    details: {
      duration: '3.5 hours',
      provider: 'Kyoto Cultural Heritage Guild',
      city: 'Kyoto'
    }
  }
];

export const INITIAL_DEMO_EDGES: ItineraryEdge[] = [
  {
    id: 'edge-1',
    itinerary_id: 'itin-demo-1',
    source_node_id: 'node-fl-1',
    target_node_id: 'node-ht-1',
    edge_type: 'next_step',
    travel_time_minutes: 45,
    distance_km: 22
  },
  {
    id: 'edge-2',
    itinerary_id: 'itin-demo-1',
    source_node_id: 'node-ht-1',
    target_node_id: 'node-act-1',
    edge_type: 'next_step',
    travel_time_minutes: 20,
    distance_km: 4
  },
  {
    id: 'edge-3',
    itinerary_id: 'itin-demo-1',
    source_node_id: 'node-ht-1',
    target_node_id: 'node-tr-1',
    edge_type: 'next_step',
    travel_time_minutes: 15,
    distance_km: 2
  },
  {
    id: 'edge-4',
    itinerary_id: 'itin-demo-1',
    source_node_id: 'node-tr-1',
    target_node_id: 'node-ht-2',
    edge_type: 'next_step',
    travel_time_minutes: 135,
    distance_km: 450
  },
  {
    id: 'edge-5',
    itinerary_id: 'itin-demo-1',
    source_node_id: 'node-ht-2',
    target_node_id: 'node-act-2',
    edge_type: 'next_step',
    travel_time_minutes: 30,
    distance_km: 8
  }
];

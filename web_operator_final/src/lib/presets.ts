export interface PresetHotel {
  name: string;
  city: string;
  address: string;
  star_rating: number;
  contracted_rate_per_night: number;
  amenities: string[];
  contact_person: string;
  contact_phone: string;
  latitude: number;
  longitude: number;
}

export interface PresetPlace {
  name: string;
  city: string;
  description: string;
  entry_fee_per_person: number;
  recommended_duration_minutes: number;
  tags: string[];
  latitude: number;
  longitude: number;
}

export interface PresetActivity {
  title: string;
  location: string;
  cost_per_person: number;
  duration_minutes: number;
  activity_type: string;
  inclusions: string[];
  latitude: number;
  longitude: number;
}

export interface PresetTransport {
  vehicle_type: string;
  capacity_passengers: number;
  cost_per_day: number;
  cost_per_km: number;
  vendor_company_name: string;
  contact_phone: string;
  features: string[];
  latitude: number;
  longitude: number;
}

export const PRESET_HOTELS: PresetHotel[] = [
  {
    name: 'The Taj Mahal Palace',
    city: 'Mumbai',
    address: 'Apollo Bunder, Colaba, Mumbai',
    star_rating: 5,
    contracted_rate_per_night: 320,
    amenities: ['wifi', 'breakfast_included', 'pool', 'spa', 'sea_view'],
    contact_person: 'Reservations Desk',
    contact_phone: '+91 22 6665 3366',
    latitude: 18.921700,
    longitude: 72.833300
  },
  {
    name: 'The Oberoi',
    city: 'Mumbai',
    address: 'Nariman Point, Mumbai',
    star_rating: 5,
    contracted_rate_per_night: 280,
    amenities: ['wifi', 'breakfast_included', 'ocean_view', 'fine_dining'],
    contact_person: 'Front Office Manager',
    contact_phone: '+91 22 6632 5757',
    latitude: 18.927200,
    longitude: 72.820600
  },
  {
    name: 'W Goa',
    city: 'Goa',
    address: 'Vagator Beach, Bardez, Goa',
    star_rating: 5,
    contracted_rate_per_night: 240,
    amenities: ['wifi', 'breakfast_included', 'beach_access', 'infinity_pool'],
    contact_person: 'Resort Reservations',
    contact_phone: '+91 832 671 0000',
    latitude: 15.602200,
    longitude: 73.734600
  },
  {
    name: 'Taj Lake Palace',
    city: 'Udaipur',
    address: 'Pichola, Udaipur, Rajasthan',
    star_rating: 5,
    contracted_rate_per_night: 450,
    amenities: ['wifi', 'heritage_boat_transfer', 'royal_dining', 'lake_view'],
    contact_person: 'Palace Concierge',
    contact_phone: '+91 294 242 8800',
    latitude: 24.575300,
    longitude: 73.680000
  }
];

export const PRESET_PLACES: PresetPlace[] = [
  {
    name: 'Gateway of India',
    city: 'Mumbai',
    description: 'Iconic 26m waterfront basalt arch overlooking the Arabian Sea built in 1924.',
    entry_fee_per_person: 0,
    recommended_duration_minutes: 60,
    tags: ['monument', 'sea_view', 'photography', 'heritage'],
    latitude: 18.922000,
    longitude: 72.834700
  },
  {
    name: 'Marine Drive Promenade',
    city: 'Mumbai',
    description: 'Scenic 3.6km C-shaped boulevard along the coast known as Queen’s Necklace.',
    entry_fee_per_person: 0,
    recommended_duration_minutes: 45,
    tags: ['sunset', 'walk', 'ocean', 'cityscape'],
    latitude: 18.944000,
    longitude: 72.823000
  },
  {
    name: 'City Palace Complex',
    city: 'Udaipur',
    description: 'Grand lakeside palace complex featuring museum, courtyards, and panoramic lake views.',
    entry_fee_per_person: 15,
    recommended_duration_minutes: 120,
    tags: ['palace', 'history', 'architecture', 'lake'],
    latitude: 24.576400,
    longitude: 73.683500
  }
];

export const PRESET_ACTIVITIES: PresetActivity[] = [
  {
    title: 'Bollywood Studio & Film City Guided Tour',
    location: 'Mumbai',
    cost_per_person: 150,
    duration_minutes: 180,
    activity_type: 'cultural',
    inclusions: ['Studio Access Pass', 'AC Coach Transfer', 'Live Shoot Viewing'],
    latitude: 19.166800,
    longitude: 72.852600
  },
  {
    title: 'Elephanta Caves Ferry & Ancient Rock-Cut Sculptures',
    location: 'Mumbai',
    cost_per_person: 95,
    duration_minutes: 240,
    activity_type: 'cultural',
    inclusions: ['Round-trip Boat Ferry', 'UNESCO Entry Tickets', 'Certified Guide'],
    latitude: 18.963300,
    longitude: 72.931500
  },
  {
    title: 'Scuba Diving & Watersports at Grand Island',
    location: 'Goa',
    cost_per_person: 120,
    duration_minutes: 300,
    activity_type: 'adventure',
    inclusions: ['PADI Instructor', 'Scuba Gear', 'Boat Cruise', 'Underwater Photos'],
    latitude: 15.353300,
    longitude: 73.784400
  }
];

export const PRESET_TRANSPORT: PresetTransport[] = [
  {
    vehicle_type: 'Toyota Innova Crysta Chauffeur SUV',
    capacity_passengers: 6,
    cost_per_day: 140,
    cost_per_km: 1.5,
    vendor_company_name: 'Royal Chauffeur Fleet Mumbai',
    contact_phone: '+91 22 4000 1234',
    features: ['AC', 'WiFi', 'Uniformed Chauffeur', 'Luggage Carrier'],
    latitude: 19.089600,
    longitude: 72.865600
  }
];

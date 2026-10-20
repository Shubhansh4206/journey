export type NodeType = 'flight' | 'hotel' | 'transfer' | 'activity';

export type RequestStatus = 'pending' | 'reviewing' | 'quoted' | 'negotiating' | 'finalized' | 'closed';

export type ItineraryStatus = 'draft' | 'sent_to_user' | 'user_edited' | 'finalized';

export type NegotiationStatus = 'pending_review' | 'accepted' | 'rejected';

export type GuideAssignmentStatus = 'unconfirmed' | 'confirmed' | 'completed';

export interface TourOperator {
  id: string;
  company_name: string;
  contact_email: string;
  created_at?: string;
}

export interface TripRequest {
  id: string;
  customer_id?: string | null;
  operator_id?: string | null;
  group_id?: string | null;
  status: RequestStatus | string;
  destination: string;
  trip_mode?: string | null;
  assigned_group_name?: string | null;
  start_date?: string;
  end_date?: string;
  travel_dates: string;
  per_person_budget?: number;
  budget_range: number[];
  user_preferences?: string | null;
  selected_hotels?: string[];
  selected_places?: string[];
  selected_activities?: string[];
  selected_transport?: string[];
  estimated_mock_total?: number | null;
  created_at?: string;
  updated_at?: string;
  customer_name?: string;
  customer_email?: string;
}

export interface Itinerary {
  id: string;
  request_id: string;
  operator_id?: string | null;
  version: number;
  status: ItineraryStatus;
  total_base_cost: number;
  total_margin: number;
  final_quotation_price: number;
  ai_context?: {
    last_prompt?: string;
    agent_reasoning?: string[];
    suggested_actions?: string[];
    target_margin_pct?: number;
  } | null;
  created_at?: string;
  updated_at?: string;
}

export interface ItineraryNode {
  id: string;
  itinerary_id: string;
  node_type: NodeType;
  title: string;
  start_time?: string | null;
  end_time?: string | null;
  base_cost: number;
  margin_percentage: number;
  final_price?: number;
  ui_coordinates: { x: number; y: number };
  ai_metadata?: {
    generated_by?: 'agent' | 'operator';
    confidence_score?: number;
    alternatives?: Array<{ title: string; cost: number; description?: string }>;
    reasoning?: string;
  } | null;
  details?: {
    city?: string;
    rating?: number;
    provider?: string;
    pnr_or_confirmation?: string;
    description?: string;
    image_url?: string;
    tags?: string[];
    duration?: string;
    room_type?: string;
    transport_mode?: string;
    nights?: number;
    amenities?: string[];
    [key: string]: any;
  } | null;
  created_at?: string;
}

export interface ItineraryEdge {
  id: string;
  itinerary_id: string;
  source_node_id: string;
  target_node_id: string;
  edge_type: 'next_step' | 'alternative_option';
  distance_km?: number | null;
  travel_time_minutes?: number | null;
}

export interface Negotiation {
  id: string;
  itinerary_id: string;
  sender_type: 'operator' | 'customer';
  sender_id: string;
  message: string;
  requested_price?: number | null;
  requested_changes?: {
    notes?: string;
    preferred_hotel_tier?: string;
    remove_node_ids?: string[];
    budget_target?: number;
  } | null;
  status: NegotiationStatus;
  created_at?: string;
}

export const SUPPORTED_CITIES = ['Mumbai', 'Udaipur', 'Jaipur', 'Goa'] as const;
export type SupportedCity = typeof SUPPORTED_CITIES[number];

export interface TourGuide {
  id: string;
  operator_id?: string | null;
  name?: string;
  first_name?: string;
  last_name?: string;
  city?: string;
  contact_number?: string | null;
  languages?: string[];
  daily_rate: number;
  is_active?: boolean;
  avatar_url?: string;
  specialties?: string[];
  created_at?: string;
}

export interface GuideAssignment {
  id: string;
  guide_id: string;
  itinerary_id: string;
  operator_id?: string | null;
  assignment_status: GuideAssignmentStatus;
  instructions_for_guide?: string | null;
  assigned_at?: string;
  guide?: TourGuide;
}

// --- TIED-UP OPERATOR INVENTORY TABLES ---

export interface OperatorHotel {
  id: string;
  operator_id?: string;
  name: string;
  city: string;
  address?: string;
  star_rating?: number;
  contracted_rate_per_night: number;
  amenities: string[];
  contact_person?: string;
  contact_phone?: string;
  is_active: boolean;
  latitude?: number | null;
  longitude?: number | null;
  created_at?: string;
  updated_at?: string;
}

export interface OperatorPlace {
  id: string;
  operator_id?: string;
  name: string;
  city: string;
  description?: string;
  entry_fee_per_person: number;
  recommended_duration_minutes?: number;
  tags: string[];
  is_active: boolean;
  latitude?: number | null;
  longitude?: number | null;
  created_at?: string;
}

export interface OperatorActivity {
  id: string;
  operator_id?: string;
  title: string;
  location?: string;
  cost_per_person: number;
  duration_minutes: number;
  activity_type?: string;
  inclusions: string[];
  restrictions?: Record<string, any>;
  is_active: boolean;
  latitude?: number | null;
  longitude?: number | null;
  created_at?: string;
  updated_at?: string;
}

export interface OperatorTransport {
  id: string;
  operator_id?: string;
  vehicle_type: string;
  capacity_passengers: number;
  cost_per_day?: number;
  cost_per_km?: number;
  vendor_company_name?: string;
  contact_phone?: string;
  features: string[];
  is_active: boolean;
  latitude?: number | null;
  longitude?: number | null;
  created_at?: string;
  updated_at?: string;
}

export interface CartCatalogItem {
  id: string;
  node_type: NodeType;
  title: string;
  category: string;
  base_cost: number;
  margin_percentage: number;
  location: string;
  description: string;
  image_url: string;
  badge?: string;
  rating?: number;
  details: Record<string, any>;
}



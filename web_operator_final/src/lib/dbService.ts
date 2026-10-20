import { supabase } from './supabase';
import {
  TripRequest,
  Itinerary,
  ItineraryNode,
  ItineraryEdge,
  Negotiation,
  TourGuide,
  GuideAssignment,
  TourOperator,
  OperatorHotel,
  OperatorPlace,
  OperatorActivity,
  OperatorTransport
} from './types';

const STORAGE_KEYS = {
  REQUESTS: 'journey_operator_requests',
  ITINERARIES: 'journey_operator_itineraries',
  NODES: 'journey_operator_nodes',
  EDGES: 'journey_operator_edges',
  NEGOTIATIONS: 'journey_operator_negotiations',
  GUIDES: 'journey_operator_guides',
  ASSIGNMENTS: 'journey_operator_assignments',
  ACTIVE_OPERATOR: 'journey_active_operator',
  HOTELS: 'journey_operator_hotels',
  PLACES: 'journey_operator_places',
  ACTIVITIES: 'journey_operator_activities',
  TRANSPORT: 'journey_operator_transport',
};

export function isValidUUID(str?: string | null): boolean {
  if (!str) return false;
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(str);
}

function getLocal<T>(key: string, fallback: T): T {
  if (typeof window === 'undefined') return fallback;
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch (e) {
    return fallback;
  }
}

function setLocal<T>(key: string, value: T): void {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (e) {
    console.error('Storage error', e);
  }
}

export const dbService = {
  // --- AUTH & OPERATOR REGISTRATION ---
  async getActiveOperator(): Promise<TourOperator | null> {
    const FLAMINGO_FALLBACK: TourOperator = {
      id: 'dc3d36fb-0502-432a-920d-c3daa95c981a',
      company_name: 'FLAMINGO',
      contact_email: 'flamingo1010@gmail.com'
    };

    const local = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
    if (
      local && 
      isValidUUID(local.id) && 
      local.id !== 'b5f1a8aa-b6bc-4698-9705-451120626bdd' && 
      local.id !== '11111111-1111-1111-1111-111111111111' && 
      local.id !== '00000000-0000-0000-0000-000000000000'
    ) {
      return local;
    }

    try {
      const sessionPromise = supabase.auth.getSession();
      const timeoutPromise = new Promise<{ data: { session: null } }>((resolve) =>
        setTimeout(() => resolve({ data: { session: null } }), 1000)
      );
      const { data: { session } } = await Promise.race([sessionPromise, timeoutPromise]);
      if (session?.user) {
        const { data } = await supabase
          .from('tour_operators')
          .select('*')
          .eq('id', session.user.id)
          .maybeSingle();

        if (data) {
          const op: TourOperator = {
            id: data.id,
            company_name: data.company_name,
            contact_email: data.contact_email,
            created_at: data.created_at
          };
          setLocal(STORAGE_KEYS.ACTIVE_OPERATOR, op);
          return op;
        }

        const fallbackOp: TourOperator = {
          id: session.user.id,
          company_name: session.user.user_metadata?.company_name || 'Tour Operator Agency',
          contact_email: session.user.email || 'operator@agency.com'
        };

        setLocal(STORAGE_KEYS.ACTIVE_OPERATOR, fallbackOp);
        return fallbackOp;
      }
    } catch (e) {
      console.warn('Supabase auth session check failed', e);
    }

    setLocal(STORAGE_KEYS.ACTIVE_OPERATOR, FLAMINGO_FALLBACK);
    return FLAMINGO_FALLBACK;
  },

  async ensureOperatorRecord(operatorId?: string | null): Promise<string | null> {
    try {
      let targetId = operatorId && isValidUUID(operatorId) ? operatorId : null;
      let targetCompany = 'Tour Operator Agency';
      let targetEmail = 'operator@agency.com';

      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user && isValidUUID(session.user.id)) {
        if (!targetId) targetId = session.user.id;
        targetCompany = session.user.user_metadata?.company_name || targetCompany;
        targetEmail = session.user.email || targetEmail;
      }

      if (!targetId) {
        const localOp = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        if (localOp && isValidUUID(localOp.id)) {
          targetId = localOp.id;
          targetCompany = localOp.company_name || targetCompany;
          targetEmail = localOp.contact_email || targetEmail;
        }
      }

      if (targetId && isValidUUID(targetId)) {
        await supabase.from('tour_operators').upsert({
          id: targetId,
          company_name: targetCompany,
          contact_email: targetEmail,
          created_at: new Date().toISOString()
        });
        return targetId;
      }
    } catch (e) {
      console.warn('ensureOperatorRecord warning:', e);
    }
    return operatorId && isValidUUID(operatorId) ? operatorId : null;
  },

  async signUpOperator(company_name: string, email: string, password: string): Promise<{ operator: TourOperator | null; error: string | null }> {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            company_name,
          }
        }
      });

      if (error) {
        return { operator: null, error: error.message };
      }

      if (data.user) {
        const op: TourOperator = {
          id: data.user.id,
          company_name: company_name.trim() || 'Tour Operator Agency',
          contact_email: email.trim(),
          created_at: new Date().toISOString()
        };

        // 1. Explicitly create/upsert the tour_operators record in Supabase
        const { error: insertError } = await supabase
          .from('tour_operators')
          .upsert({
            id: op.id,
            company_name: op.company_name,
            contact_email: op.contact_email,
            created_at: op.created_at
          });

        if (insertError) {
          console.warn('Could not upsert into tour_operators:', insertError.message);
        }

        // 2. If session wasn't auto-established, attempt immediate sign-in
        if (!data.session) {
          try {
            await supabase.auth.signInWithPassword({
              email: email.trim(),
              password
            });
          } catch (e) {
            // ignore
          }
        }

        this.setActiveOperator(op);
        return { operator: op, error: null };
      }
    } catch (err: any) {
      return { operator: null, error: err.message || 'Signup failed' };
    }

    return { operator: null, error: 'User creation failed' };
  },

  async signInOperator(email: string, password: string): Promise<{ operator: TourOperator | null; error: string | null }> {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        return { operator: null, error: error.message };
      }

      if (data.user) {
        const { data: opData } = await supabase
          .from('tour_operators')
          .select('*')
          .eq('id', data.user.id)
          .maybeSingle();

        const op: TourOperator = {
          id: data.user.id,
          company_name: opData?.company_name || data.user.user_metadata?.company_name || 'Tour Operator Agency',
          contact_email: opData?.contact_email || data.user.email || email,
          created_at: opData?.created_at || new Date().toISOString()
        };

        // Automatically ensure tour_operators has this row
        await supabase
          .from('tour_operators')
          .upsert({
            id: op.id,
            company_name: op.company_name,
            contact_email: op.contact_email,
            created_at: op.created_at
          });

        this.setActiveOperator(op);
        return { operator: op, error: null };
      }
    } catch (err: any) {
      return { operator: null, error: err.message || 'Login failed' };
    }

    return { operator: null, error: 'Authentication failed' };
  },

  setActiveOperator(operator: TourOperator | null): void {
    setLocal(STORAGE_KEYS.ACTIVE_OPERATOR, operator);
  },

  // --- TRIP REQUESTS ---
  async getTripRequests(operatorId?: string): Promise<TripRequest[]> {
    // 1. Try our Next.js API server route first (guaranteed data access)
    try {
      if (typeof window !== 'undefined') {
        const res = await fetch('/api/trip-requests');
        if (res.ok) {
          const list: TripRequest[] = await res.json();
          if (Array.isArray(list) && list.length > 0) {
            setLocal(STORAGE_KEYS.REQUESTS, list);
            return list;
          }
        }
      }
    } catch (e) {
      console.warn('API /api/trip-requests fetch warning, trying direct Supabase', e);
    }

    // 2. Direct Supabase fallback
    try {
      const { data, error } = await supabase
        .from('trip_requests')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && data && data.length > 0) {
        const formatted: TripRequest[] = data.map((d: any) => {
          const perPersonBudget = d.per_person_budget || 0;
          const budgetRange = Array.isArray(d.budget_range) && d.budget_range.length >= 2
            ? d.budget_range
            : [perPersonBudget || 3000, perPersonBudget ? perPersonBudget * 1.5 : 6000];

          const travelDates = d.start_date && d.end_date
            ? `${d.start_date} → ${d.end_date}`
            : (typeof d.travel_dates === 'string' ? d.travel_dates : 'Flexible 2026');

          return {
            id: d.id,
            customer_id: d.customer_id,
            operator_id: d.operator_id,
            group_id: d.group_id,
            status: d.status || 'pending',
            destination: d.destination || 'Unspecified Destination',
            trip_mode: d.trip_mode,
            assigned_group_name: d.assigned_group_name,
            start_date: d.start_date,
            end_date: d.end_date,
            travel_dates: travelDates,
            per_person_budget: perPersonBudget,
            budget_range: budgetRange,
            user_preferences: d.user_preferences,
            selected_hotels: d.selected_hotels || [],
            selected_places: d.selected_places || [],
            selected_activities: d.selected_activities || [],
            selected_transport: d.selected_transport || [],
            estimated_mock_total: d.estimated_mock_total,
            created_at: d.created_at,
            customer_name: d.assigned_group_name ? `${d.trip_mode || 'Group'}: ${d.assigned_group_name}` : (d.customer_name || 'Verified Traveler'),
            customer_email: d.customer_email || 'traveler@journey.io'
          };
        });

        setLocal(STORAGE_KEYS.REQUESTS, formatted);
        return formatted;
      }
    } catch (e) {
      console.warn('Error fetching trip_requests directly from Supabase', e);
    }

    return getLocal<TripRequest[]>(STORAGE_KEYS.REQUESTS, []);
  },

  async getTripRequestById(id: string): Promise<{ trip: TripRequest | null; hydrated_items: any } | null> {
    try {
      if (typeof window !== 'undefined') {
        const res = await fetch(`/api/trip-requests?id=${encodeURIComponent(id)}`);
        if (res.ok) {
          const json = await res.json();
          if (json.trip_request) {
            return {
              trip: json.trip_request as TripRequest,
              hydrated_items: json.hydrated_items || { hotels: [], places: [], activities: [], transport: [] }
            };
          }
        }
      }
    } catch (e) {
      console.warn('Could not fetch trip request via API:', e);
    }

    // Direct Supabase lookup fallback
    try {
      const { data: trip } = await supabase.from('trip_requests').select('*').eq('id', id).maybeSingle();
      if (trip) {
        const perPersonBudget = trip.per_person_budget || 0;
        const formattedTrip: TripRequest = {
          ...trip,
          travel_dates: trip.start_date && trip.end_date ? `${trip.start_date} → ${trip.end_date}` : (trip.travel_dates || 'Flexible 2026'),
          budget_range: Array.isArray(trip.budget_range) ? trip.budget_range : [perPersonBudget || 3000, perPersonBudget ? perPersonBudget * 1.5 : 6000],
          selected_hotels: trip.selected_hotels || [],
          selected_places: trip.selected_places || [],
          selected_activities: trip.selected_activities || [],
          selected_transport: trip.selected_transport || [],
        };
        return {
          trip: formattedTrip,
          hydrated_items: { hotels: [], places: [], activities: [], transport: [] }
        };
      }
    } catch (e) {
      console.warn('Supabase getTripRequestById error:', e);
    }

    const localList = getLocal<TripRequest[]>(STORAGE_KEYS.REQUESTS, []);
    const found = localList.find(r => r.id === id);
    return found ? { trip: found, hydrated_items: { hotels: [], places: [], activities: [], transport: [] } } : null;
  },

  async createTripRequest(req: Partial<TripRequest>): Promise<TripRequest | null> {
    const newReq: TripRequest = {
      id: req.id || `req-${Date.now()}`,
      customer_id: req.customer_id || null,
      operator_id: req.operator_id || null,
      status: req.status || 'pending',
      destination: req.destination || 'Tokyo & Kyoto Exploration',
      travel_dates: req.travel_dates || '[2026-10-10, 2026-10-18]',
      budget_range: req.budget_range || [3500, 5500],
      user_preferences: req.user_preferences || 'Looking for personalized boutique stay and guided experiences.',
      created_at: new Date().toISOString()
    };

    try {
      await supabase.from('trip_requests').insert({
        id: newReq.id,
        status: newReq.status,
        destination: newReq.destination,
        travel_dates: newReq.travel_dates,
        budget_range: newReq.budget_range,
        user_preferences: newReq.user_preferences
      });
    } catch (e) {
      console.warn('Supabase trip request insert error', e);
    }

    const current = getLocal<TripRequest[]>(STORAGE_KEYS.REQUESTS, []);
    setLocal(STORAGE_KEYS.REQUESTS, [newReq, ...current]);
    return newReq;
  },

  async clearRequests(): Promise<void> {
    try {
      await supabase.from('trip_requests').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      // ignore
    }
    setLocal(STORAGE_KEYS.REQUESTS, []);
  },

  async updateRequestStatus(id: string, status: TripRequest['status']): Promise<void> {
    try {
      await supabase.from('trip_requests').update({ status }).eq('id', id);
    } catch (e) {
      console.warn('Could not update request in Supabase', e);
    }

    const current = getLocal<TripRequest[]>(STORAGE_KEYS.REQUESTS, []);
    const updated = current.map(r => r.id === id ? { ...r, status } : r);
    setLocal(STORAGE_KEYS.REQUESTS, updated);
  },

  // --- ITINERARIES ---
  async getItineraryForRequest(requestId: string): Promise<Itinerary | null> {
    const local = getLocal<Record<string, Itinerary>>(STORAGE_KEYS.ITINERARIES, {});
    if (local[requestId]) return local[requestId];

    try {
      const { data } = await supabase
        .from('itineraries')
        .select('*')
        .eq('request_id', requestId)
        .order('version', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (data) {
        const itin: Itinerary = {
          id: data.id,
          request_id: data.request_id,
          operator_id: data.operator_id,
          version: data.version || 1,
          status: data.status || 'draft',
          total_base_cost: Number(data.total_base_cost || 0),
          total_margin: Number(data.total_margin || 0),
          final_quotation_price: Number(data.final_quotation_price || 0),
          ai_context: data.ai_context,
          created_at: data.created_at,
          updated_at: data.updated_at
        };
        local[requestId] = itin;
        setLocal(STORAGE_KEYS.ITINERARIES, local);
        return itin;
      }
    } catch (e) {
      console.warn('Supabase itinerary query error', e);
    }

    return null;
  },

  async saveItinerary(itinerary: Itinerary): Promise<void> {
    try {
      await supabase.from('itineraries').upsert({
        id: itinerary.id,
        request_id: itinerary.request_id,
        operator_id: itinerary.operator_id,
        version: itinerary.version,
        status: itinerary.status,
        total_base_cost: itinerary.total_base_cost,
        total_margin: itinerary.total_margin,
        final_quotation_price: itinerary.final_quotation_price,
        ai_context: itinerary.ai_context,
        updated_at: new Date().toISOString()
      });
    } catch (e) {
      console.warn('Supabase itinerary upsert error', e);
    }

    const local = getLocal<Record<string, Itinerary>>(STORAGE_KEYS.ITINERARIES, {});
    local[itinerary.request_id] = itinerary;
    setLocal(STORAGE_KEYS.ITINERARIES, local);
  },

  // --- NODES & EDGES ---
  async getNodesAndEdges(itineraryId: string): Promise<{ nodes: ItineraryNode[]; edges: ItineraryEdge[] }> {
    const allNodes = getLocal<Record<string, ItineraryNode[]>>(STORAGE_KEYS.NODES, {});
    const allEdges = getLocal<Record<string, ItineraryEdge[]>>(STORAGE_KEYS.EDGES, {});

    if (allNodes[itineraryId]) {
      return {
        nodes: allNodes[itineraryId],
        edges: allEdges[itineraryId] || []
      };
    }

    try {
      const { data: dbNodes } = await supabase
        .from('itinerary_nodes')
        .select('*')
        .eq('itinerary_id', itineraryId);

      const { data: dbEdges } = await supabase
        .from('itinerary_edges')
        .select('*')
        .eq('itinerary_id', itineraryId);

      if (dbNodes && dbNodes.length > 0) {
        const nodes: ItineraryNode[] = dbNodes.map(n => ({
          id: n.id,
          itinerary_id: n.itinerary_id,
          node_type: n.node_type,
          title: n.title,
          start_time: n.start_time,
          end_time: n.end_time,
          base_cost: Number(n.base_cost),
          margin_percentage: Number(n.margin_percentage),
          final_price: Number(n.final_price || n.base_cost * (1 + n.margin_percentage / 100)),
          ui_coordinates: n.ui_coordinates || { x: 100, y: 100 },
          ai_metadata: n.ai_metadata,
          details: n.details
        }));

        const edges: ItineraryEdge[] = (dbEdges || []).map(e => ({
          id: e.id,
          itinerary_id: e.itinerary_id,
          source_node_id: e.source_node_id,
          target_node_id: e.target_node_id,
          edge_type: e.edge_type || 'next_step',
          distance_km: e.distance_km,
          travel_time_minutes: e.travel_time_minutes
        }));

        allNodes[itineraryId] = nodes;
        allEdges[itineraryId] = edges;
        setLocal(STORAGE_KEYS.NODES, allNodes);
        setLocal(STORAGE_KEYS.EDGES, allEdges);

        return { nodes, edges };
      }
    } catch (e) {
      console.warn('Supabase nodes fetch error', e);
    }

    return { nodes: [], edges: [] };
  },

  async saveNodesAndEdges(
    itineraryId: string,
    nodes: ItineraryNode[],
    edges: ItineraryEdge[]
  ): Promise<void> {
    const allNodes = getLocal<Record<string, ItineraryNode[]>>(STORAGE_KEYS.NODES, {});
    const allEdges = getLocal<Record<string, ItineraryEdge[]>>(STORAGE_KEYS.EDGES, {});

    allNodes[itineraryId] = nodes;
    allEdges[itineraryId] = edges;
    setLocal(STORAGE_KEYS.NODES, allNodes);
    setLocal(STORAGE_KEYS.EDGES, allEdges);

    try {
      if (nodes.length > 0) {
        await supabase.from('itinerary_nodes').upsert(
          nodes.map(n => ({
            id: n.id,
            itinerary_id: itineraryId,
            node_type: n.node_type,
            title: n.title,
            start_time: n.start_time,
            end_time: n.end_time,
            base_cost: n.base_cost,
            margin_percentage: n.margin_percentage,
            ui_coordinates: n.ui_coordinates,
            ai_metadata: n.ai_metadata,
            details: n.details
          }))
        );
      }

      if (edges.length > 0) {
        await supabase.from('itinerary_edges').upsert(
          edges.map(e => ({
            id: e.id,
            itinerary_id: itineraryId,
            source_node_id: e.source_node_id,
            target_node_id: e.target_node_id,
            edge_type: e.edge_type,
            distance_km: e.distance_km,
            travel_time_minutes: e.travel_time_minutes
          }))
        );
      }
    } catch (e) {
      console.warn('Supabase nodes save error', e);
    }
  },

  // --- NEGOTIATIONS ---
  async getNegotiations(itineraryId: string): Promise<Negotiation[]> {
    const all = getLocal<Record<string, Negotiation[]>>(STORAGE_KEYS.NEGOTIATIONS, {});
    if (all[itineraryId]) return all[itineraryId];

    try {
      const { data } = await supabase
        .from('negotiations')
        .select('*')
        .eq('itinerary_id', itineraryId)
        .order('created_at', { ascending: true });

      if (data && data.length > 0) {
        all[itineraryId] = data as Negotiation[];
        setLocal(STORAGE_KEYS.NEGOTIATIONS, all);
        return data as Negotiation[];
      }
    } catch (e) {
      console.warn('Supabase negotiations fetch error', e);
    }

    return [];
  },

  async addNegotiation(negotiation: Negotiation): Promise<void> {
    const all = getLocal<Record<string, Negotiation[]>>(STORAGE_KEYS.NEGOTIATIONS, {});
    const list = all[negotiation.itinerary_id] || [];
    list.push(negotiation);
    all[negotiation.itinerary_id] = list;
    setLocal(STORAGE_KEYS.NEGOTIATIONS, all);

    try {
      await supabase.from('negotiations').insert({
        id: negotiation.id,
        itinerary_id: negotiation.itinerary_id,
        sender_type: negotiation.sender_type,
        sender_id: negotiation.sender_id,
        message: negotiation.message,
        requested_price: negotiation.requested_price,
        requested_changes: negotiation.requested_changes,
        status: negotiation.status
      });
    } catch (e) {
      console.warn('Supabase add negotiation error', e);
    }
  },

  async updateNegotiationStatus(id: string, itineraryId: string, status: Negotiation['status']): Promise<void> {
    const all = getLocal<Record<string, Negotiation[]>>(STORAGE_KEYS.NEGOTIATIONS, {});
    const list = all[itineraryId] || [];
    const updated = list.map(n => n.id === id ? { ...n, status } : n);
    all[itineraryId] = updated;
    setLocal(STORAGE_KEYS.NEGOTIATIONS, all);

    try {
      await supabase.from('negotiations').update({ status }).eq('id', id);
    } catch (e) {
      console.warn('Supabase negotiation status update error', e);
    }
  },

  // --- TOUR GUIDES & ASSIGNMENTS ---
  async getTourGuides(operatorId?: string, city?: string): Promise<TourGuide[]> {
    try {
      let resolvedOpId = operatorId;
      if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
        const active = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        resolvedOpId = active?.id;
      }

      let query = supabase.from('tour_guides').select('*').eq('is_active', true);
      if (resolvedOpId && isValidUUID(resolvedOpId)) {
        query = query.eq('operator_id', resolvedOpId);
      }
      if (city) {
        query = query.eq('city', city);
      }
      const { data, error } = await query.order('created_at', { ascending: false });
      if (!error && data) {
        const formatted: TourGuide[] = data.map((d: any) => ({
          id: d.id,
          operator_id: d.operator_id,
          name: d.name || `${d.first_name || ''} ${d.last_name || ''}`.trim() || 'Guide',
          first_name: d.first_name || (d.name ? d.name.split(' ')[0] : ''),
          last_name: d.last_name || (d.name ? d.name.split(' ').slice(1).join(' ') : ''),
          city: d.city || 'Mumbai',
          contact_number: d.contact_number,
          languages: Array.isArray(d.languages) ? d.languages : ['English', 'Hindi'],
          daily_rate: Number(d.daily_rate) || 150,
          is_active: d.is_active !== undefined ? d.is_active : true,
          created_at: d.created_at
        }));
        setLocal(STORAGE_KEYS.GUIDES, formatted);
        return formatted;
      }
      if (error) {
        console.warn('Supabase tour_guides fetch error:', error.message);
      }
    } catch (e) {
      console.warn('Supabase tour_guides exception:', e);
    }

    const local = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
    let filtered = local;
    if (operatorId && isValidUUID(operatorId)) {
      filtered = filtered.filter(g => g.operator_id === operatorId);
    }
    if (city && filtered.length > 0) {
      filtered = filtered.filter(g => !g.city || g.city.toLowerCase() === city.toLowerCase());
    }
    return filtered;
  },

  async createTourGuide(guide: Partial<TourGuide>): Promise<{ data: TourGuide; error: string | null }> {
    let resolvedOpId = guide.operator_id;
    if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
      resolvedOpId = await this.ensureOperatorRecord() || undefined;
    } else {
      await this.ensureOperatorRecord(resolvedOpId);
    }

    const guideName = guide.name || `${guide.first_name || ''} ${guide.last_name || ''}`.trim() || 'Guide Name';
    const insertPayload: any = {
      name: guideName,
      city: guide.city || 'Mumbai',
      contact_number: guide.contact_number || null,
      languages: guide.languages || ['English', 'Hindi'],
      daily_rate: Number(guide.daily_rate) || 150,
      is_active: true
    };

    if (isValidUUID(resolvedOpId)) {
      insertPayload.operator_id = resolvedOpId;
    }

    let created: TourGuide = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `tg-${Date.now()}`,
      operator_id: insertPayload.operator_id || null,
      name: guideName,
      first_name: guideName.split(' ')[0],
      last_name: guideName.split(' ').slice(1).join(' '),
      city: insertPayload.city,
      contact_number: insertPayload.contact_number,
      languages: insertPayload.languages,
      daily_rate: insertPayload.daily_rate,
      is_active: true,
      created_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabase.from('tour_guides').insert(insertPayload).select().single();
      if (!error && data) {
        created = {
          ...created,
          ...data,
          name: data.name || `${data.first_name || ''} ${data.last_name || ''}`.trim() || guideName
        };
        const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
        const updated = [created, ...current.filter(g => g.id !== created.id)];
        setLocal(STORAGE_KEYS.GUIDES, updated);
        return { data: created, error: null };
      }

      if (error) {
        console.warn('Supabase create guide error:', error.message);
        const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
        const updated = [created, ...current.filter(g => g.id !== created.id)];
        setLocal(STORAGE_KEYS.GUIDES, updated);
        return { data: created, error: error.message };
      }
    } catch (e: any) {
      console.warn('Supabase create guide exception:', e);
      const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
      const updated = [created, ...current.filter(g => g.id !== created.id)];
      setLocal(STORAGE_KEYS.GUIDES, updated);
      return { data: created, error: e.message || 'Network error' };
    }

    const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
    const updated = [created, ...current.filter(g => g.id !== created.id)];
    setLocal(STORAGE_KEYS.GUIDES, updated);
    return { data: created, error: null };
  },

  async updateTourGuide(guide: TourGuide): Promise<{ success: boolean; error: string | null }> {
    const guideName = guide.name || `${guide.first_name || ''} ${guide.last_name || ''}`.trim();
    const updatePayload: any = {
      name: guideName,
      city: guide.city || 'Mumbai',
      contact_number: guide.contact_number || null,
      languages: guide.languages || ['English', 'Hindi'],
      daily_rate: Number(guide.daily_rate) || 150,
      is_active: guide.is_active !== undefined ? guide.is_active : true,
      updated_at: new Date().toISOString()
    };

    const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
    setLocal(STORAGE_KEYS.GUIDES, current.map(g => g.id === guide.id ? { ...g, ...updatePayload } : g));

    if (isValidUUID(guide.id)) {
      try {
        const { error } = await supabase
          .from('tour_guides')
          .update(updatePayload)
          .eq('id', guide.id);
        if (error) {
          console.warn('Supabase update guide error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase update guide exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async deleteTourGuide(id: string): Promise<{ success: boolean; error: string | null }> {
    const current = getLocal<TourGuide[]>(STORAGE_KEYS.GUIDES, []);
    setLocal(STORAGE_KEYS.GUIDES, current.filter(g => g.id !== id));

    if (isValidUUID(id)) {
      try {
        const { error } = await supabase.from('tour_guides').delete().eq('id', id);
        if (error) {
          console.warn('Supabase delete guide error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase delete guide exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async getGuideAssignment(itineraryId: string): Promise<GuideAssignment | null> {
    const local = getLocal<Record<string, GuideAssignment>>(STORAGE_KEYS.ASSIGNMENTS, {});
    if (local[itineraryId]) return local[itineraryId];

    try {
      const { data } = await supabase
        .from('guide_assignments')
        .select('*')
        .eq('itinerary_id', itineraryId)
        .maybeSingle();

      if (data) {
        const guides = await this.getTourGuides();
        const guide = guides.find(g => g.id === data.guide_id);
        const res: GuideAssignment = {
          ...data,
          guide
        };
        local[itineraryId] = res;
        setLocal(STORAGE_KEYS.ASSIGNMENTS, local);
        return res;
      }
    } catch (e) {
      console.warn('Supabase guide_assignments fetch error', e);
    }

    return null;
  },

  async assignGuide(assignment: GuideAssignment): Promise<void> {
    const local = getLocal<Record<string, GuideAssignment>>(STORAGE_KEYS.ASSIGNMENTS, {});
    local[assignment.itinerary_id] = assignment;
    setLocal(STORAGE_KEYS.ASSIGNMENTS, local);

    try {
      await supabase.from('guide_assignments').upsert({
        id: assignment.id,
        guide_id: assignment.guide_id,
        itinerary_id: assignment.itinerary_id,
        operator_id: assignment.operator_id,
        assignment_status: assignment.assignment_status,
        instructions_for_guide: assignment.instructions_for_guide
      });
    } catch (e) {
      console.warn('Supabase guide assignment upsert error', e);
    }
  },

  // --- TIED-UP OPERATOR INVENTORY CRUD ---
  // 1. Operator Hotels
  async getOperatorHotels(operatorId?: string): Promise<OperatorHotel[]> {
    try {
      let resolvedOpId = operatorId;
      if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
        const active = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        resolvedOpId = active?.id;
      }

      let query = supabase.from('operator_hotels').select('*').eq('is_active', true);
      if (resolvedOpId && isValidUUID(resolvedOpId)) {
        query = query.eq('operator_id', resolvedOpId);
      }
      const { data, error } = await query.order('created_at', { ascending: false });
      if (!error && data) {
        setLocal(STORAGE_KEYS.HOTELS, data);
        return data as OperatorHotel[];
      }
      if (error) {
        console.warn('Supabase operator_hotels fetch error:', error.message);
      }
    } catch (e) {
      console.warn('Supabase operator_hotels exception:', e);
    }
    const local = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
    return operatorId && isValidUUID(operatorId) ? local.filter(h => h.operator_id === operatorId) : local;
  },

  async addOperatorHotel(hotel: Partial<OperatorHotel>): Promise<{ data: OperatorHotel; error: string | null }> {
    let resolvedOpId = hotel.operator_id;
    if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
      resolvedOpId = await this.ensureOperatorRecord() || undefined;
    } else {
      await this.ensureOperatorRecord(resolvedOpId);
    }

    const insertPayload: any = {
      name: hotel.name || 'Hotel Name',
      city: hotel.city || 'Mumbai',
      address: hotel.address || null,
      star_rating: Number(hotel.star_rating) || 5,
      contracted_rate_per_night: Number(hotel.contracted_rate_per_night) || 200,
      amenities: hotel.amenities || ['wifi', 'breakfast_included'],
      contact_person: hotel.contact_person || null,
      contact_phone: hotel.contact_phone || null,
      latitude: hotel.latitude !== undefined ? hotel.latitude : null,
      longitude: hotel.longitude !== undefined ? hotel.longitude : null,
      is_active: true
    };

    if (isValidUUID(resolvedOpId)) {
      insertPayload.operator_id = resolvedOpId;
    }

    let created: OperatorHotel = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `ht-${Date.now()}`,
      operator_id: insertPayload.operator_id || null,
      ...insertPayload,
      created_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabase.from('operator_hotels').insert(insertPayload).select().single();
      if (!error && data) {
        created = data as OperatorHotel;
        const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
        const updated = [created, ...current.filter(h => h.id !== created.id)];
        setLocal(STORAGE_KEYS.HOTELS, updated);
        return { data: created, error: null };
      }

      if (error) {
        console.warn('Supabase add hotel error:', error.message);
        const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
        const updated = [created, ...current.filter(h => h.id !== created.id)];
        setLocal(STORAGE_KEYS.HOTELS, updated);
        return { data: created, error: error.message };
      }
    } catch (e: any) {
      console.warn('Supabase add hotel exception:', e);
      const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
      const updated = [created, ...current.filter(h => h.id !== created.id)];
      setLocal(STORAGE_KEYS.HOTELS, updated);
      return { data: created, error: e.message || 'Network error' };
    }

    const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
    const updated = [created, ...current.filter(h => h.id !== created.id)];
    setLocal(STORAGE_KEYS.HOTELS, updated);
    return { data: created, error: null };
  },

  async updateOperatorHotel(hotel: OperatorHotel): Promise<{ success: boolean; error: string | null }> {
    const updatePayload = {
      name: hotel.name,
      city: hotel.city,
      address: hotel.address,
      star_rating: Number(hotel.star_rating) || 5,
      contracted_rate_per_night: Number(hotel.contracted_rate_per_night) || 200,
      amenities: hotel.amenities,
      contact_person: hotel.contact_person,
      contact_phone: hotel.contact_phone,
      latitude: hotel.latitude !== undefined ? hotel.latitude : null,
      longitude: hotel.longitude !== undefined ? hotel.longitude : null,
      updated_at: new Date().toISOString()
    };

    const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
    setLocal(STORAGE_KEYS.HOTELS, current.map(h => h.id === hotel.id ? { ...h, ...updatePayload } : h));

    if (isValidUUID(hotel.id)) {
      try {
        const { error } = await supabase
          .from('operator_hotels')
          .update(updatePayload)
          .eq('id', hotel.id);
        if (error) {
          console.warn('Supabase update hotel error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase update hotel exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async deleteOperatorHotel(id: string): Promise<{ success: boolean; error: string | null }> {
    const current = getLocal<OperatorHotel[]>(STORAGE_KEYS.HOTELS, []);
    setLocal(STORAGE_KEYS.HOTELS, current.filter(h => h.id !== id));

    if (isValidUUID(id)) {
      try {
        const { error } = await supabase.from('operator_hotels').delete().eq('id', id);
        if (error) {
          console.warn('Supabase delete hotel error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase delete hotel exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  // 2. Operator Places / Sightseeing
  async getOperatorPlaces(operatorId?: string): Promise<OperatorPlace[]> {
    try {
      let resolvedOpId = operatorId;
      if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
        const active = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        resolvedOpId = active?.id;
      }

      let query = supabase.from('operator_places').select('*').eq('is_active', true);
      if (resolvedOpId && isValidUUID(resolvedOpId)) {
        query = query.eq('operator_id', resolvedOpId);
      }
      const { data, error } = await query.order('created_at', { ascending: false });
      if (!error && data) {
        setLocal(STORAGE_KEYS.PLACES, data);
        return data as OperatorPlace[];
      }
      if (error) {
        console.warn('Supabase operator_places fetch error:', error.message);
      }
    } catch (e) {
      console.warn('Supabase operator_places exception:', e);
    }
    const local = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
    return operatorId && isValidUUID(operatorId) ? local.filter(p => p.operator_id === operatorId) : local;
  },

  async addOperatorPlace(place: Partial<OperatorPlace>): Promise<{ data: OperatorPlace; error: string | null }> {
    let resolvedOpId = place.operator_id;
    if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
      resolvedOpId = await this.ensureOperatorRecord() || undefined;
    } else {
      await this.ensureOperatorRecord(resolvedOpId);
    }

    const insertPayload: any = {
      name: place.name || 'Place of Interest',
      city: place.city || 'Mumbai',
      description: place.description || '',
      entry_fee_per_person: Number(place.entry_fee_per_person) || 0,
      recommended_duration_minutes: Number(place.recommended_duration_minutes) || 60,
      tags: place.tags || ['heritage', 'sightseeing'],
      latitude: place.latitude !== undefined ? place.latitude : null,
      longitude: place.longitude !== undefined ? place.longitude : null,
      is_active: true
    };

    if (isValidUUID(resolvedOpId)) {
      insertPayload.operator_id = resolvedOpId;
    }

    let created: OperatorPlace = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `pl-${Date.now()}`,
      operator_id: insertPayload.operator_id || null,
      ...insertPayload,
      created_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabase.from('operator_places').insert(insertPayload).select().single();
      if (!error && data) {
        created = data as OperatorPlace;
        const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
        const updated = [created, ...current.filter(p => p.id !== created.id)];
        setLocal(STORAGE_KEYS.PLACES, updated);
        return { data: created, error: null };
      }

      if (error) {
        console.warn('Supabase add place error:', error.message);
        const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
        const updated = [created, ...current.filter(p => p.id !== created.id)];
        setLocal(STORAGE_KEYS.PLACES, updated);
        return { data: created, error: error.message };
      }
    } catch (e: any) {
      console.warn('Supabase add place exception:', e);
      const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
      const updated = [created, ...current.filter(p => p.id !== created.id)];
      setLocal(STORAGE_KEYS.PLACES, updated);
      return { data: created, error: e.message || 'Network error' };
    }

    const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
    const updated = [created, ...current.filter(p => p.id !== created.id)];
    setLocal(STORAGE_KEYS.PLACES, updated);
    return { data: created, error: null };
  },

  async updateOperatorPlace(place: OperatorPlace): Promise<{ success: boolean; error: string | null }> {
    const updatePayload = {
      name: place.name,
      city: place.city,
      description: place.description,
      entry_fee_per_person: Number(place.entry_fee_per_person) || 0,
      recommended_duration_minutes: Number(place.recommended_duration_minutes) || 60,
      tags: place.tags,
      latitude: place.latitude !== undefined ? place.latitude : null,
      longitude: place.longitude !== undefined ? place.longitude : null,
    };

    const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
    setLocal(STORAGE_KEYS.PLACES, current.map(p => p.id === place.id ? { ...p, ...updatePayload } : p));

    if (isValidUUID(place.id)) {
      try {
        const { error } = await supabase
          .from('operator_places')
          .update(updatePayload)
          .eq('id', place.id);
        if (error) {
          console.warn('Supabase update place error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase update place exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async deleteOperatorPlace(id: string): Promise<{ success: boolean; error: string | null }> {
    const current = getLocal<OperatorPlace[]>(STORAGE_KEYS.PLACES, []);
    setLocal(STORAGE_KEYS.PLACES, current.filter(p => p.id !== id));

    if (isValidUUID(id)) {
      try {
        const { error } = await supabase.from('operator_places').delete().eq('id', id);
        if (error) {
          console.warn('Supabase delete place error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase delete place exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  // 3. Operator Activities
  async getOperatorActivities(operatorId?: string): Promise<OperatorActivity[]> {
    try {
      let resolvedOpId = operatorId;
      if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
        const active = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        resolvedOpId = active?.id;
      }

      let query = supabase.from('operator_activities').select('*').eq('is_active', true);
      if (resolvedOpId && isValidUUID(resolvedOpId)) {
        query = query.eq('operator_id', resolvedOpId);
      }
      const { data, error } = await query.order('created_at', { ascending: false });
      if (!error && data) {
        setLocal(STORAGE_KEYS.ACTIVITIES, data);
        return data as OperatorActivity[];
      }
      if (error) {
        console.warn('Supabase operator_activities fetch error:', error.message);
      }
    } catch (e) {
      console.warn('Supabase operator_activities exception:', e);
    }
    const local = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
    return operatorId && isValidUUID(operatorId) ? local.filter(a => a.operator_id === operatorId) : local;
  },

  async addOperatorActivity(activity: Partial<OperatorActivity>): Promise<{ data: OperatorActivity; error: string | null }> {
    let resolvedOpId = activity.operator_id;
    if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
      resolvedOpId = await this.ensureOperatorRecord() || undefined;
    } else {
      await this.ensureOperatorRecord(resolvedOpId);
    }

    const insertPayload: any = {
      title: activity.title || 'Curated Activity',
      location: activity.location || 'Mumbai',
      cost_per_person: Number(activity.cost_per_person) || 100,
      duration_minutes: Number(activity.duration_minutes) || 120,
      activity_type: activity.activity_type || 'cultural',
      inclusions: activity.inclusions || ['Guide', 'Entry Tickets'],
      restrictions: activity.restrictions || {},
      latitude: activity.latitude !== undefined ? activity.latitude : null,
      longitude: activity.longitude !== undefined ? activity.longitude : null,
      is_active: true
    };

    if (isValidUUID(resolvedOpId)) {
      insertPayload.operator_id = resolvedOpId;
    }

    let created: OperatorActivity = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `act-${Date.now()}`,
      operator_id: insertPayload.operator_id || null,
      ...insertPayload,
      created_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabase.from('operator_activities').insert(insertPayload).select().single();
      if (!error && data) {
        created = data as OperatorActivity;
        const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
        const updated = [created, ...current.filter(a => a.id !== created.id)];
        setLocal(STORAGE_KEYS.ACTIVITIES, updated);
        return { data: created, error: null };
      }

      if (error) {
        console.warn('Supabase add activity error:', error.message);
        const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
        const updated = [created, ...current.filter(a => a.id !== created.id)];
        setLocal(STORAGE_KEYS.ACTIVITIES, updated);
        return { data: created, error: error.message };
      }
    } catch (e: any) {
      console.warn('Supabase add activity exception:', e);
      const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
      const updated = [created, ...current.filter(a => a.id !== created.id)];
      setLocal(STORAGE_KEYS.ACTIVITIES, updated);
      return { data: created, error: e.message || 'Network error' };
    }

    const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
    const updated = [created, ...current.filter(a => a.id !== created.id)];
    setLocal(STORAGE_KEYS.ACTIVITIES, updated);
    return { data: created, error: null };
  },

  async updateOperatorActivity(activity: OperatorActivity): Promise<{ success: boolean; error: string | null }> {
    const updatePayload = {
      title: activity.title,
      location: activity.location,
      cost_per_person: Number(activity.cost_per_person) || 100,
      duration_minutes: Number(activity.duration_minutes) || 120,
      activity_type: activity.activity_type,
      inclusions: activity.inclusions,
      restrictions: activity.restrictions,
      latitude: activity.latitude !== undefined ? activity.latitude : null,
      longitude: activity.longitude !== undefined ? activity.longitude : null,
      updated_at: new Date().toISOString()
    };

    const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
    setLocal(STORAGE_KEYS.ACTIVITIES, current.map(a => a.id === activity.id ? { ...a, ...updatePayload } : a));

    if (isValidUUID(activity.id)) {
      try {
        const { error } = await supabase
          .from('operator_activities')
          .update(updatePayload)
          .eq('id', activity.id);
        if (error) {
          console.warn('Supabase update activity error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase update activity exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async deleteOperatorActivity(id: string): Promise<{ success: boolean; error: string | null }> {
    const current = getLocal<OperatorActivity[]>(STORAGE_KEYS.ACTIVITIES, []);
    setLocal(STORAGE_KEYS.ACTIVITIES, current.filter(a => a.id !== id));

    if (isValidUUID(id)) {
      try {
        const { error } = await supabase.from('operator_activities').delete().eq('id', id);
        if (error) {
          console.warn('Supabase delete activity error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase delete activity exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  // 4. Operator Transport Fleet
  async getOperatorTransport(operatorId?: string): Promise<OperatorTransport[]> {
    try {
      let resolvedOpId = operatorId;
      if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
        const active = getLocal<TourOperator | null>(STORAGE_KEYS.ACTIVE_OPERATOR, null);
        resolvedOpId = active?.id;
      }

      let query = supabase.from('operator_transport').select('*').eq('is_active', true);
      if (resolvedOpId && isValidUUID(resolvedOpId)) {
        query = query.eq('operator_id', resolvedOpId);
      }
      const { data, error } = await query.order('created_at', { ascending: false });
      if (!error && data) {
        setLocal(STORAGE_KEYS.TRANSPORT, data);
        return data as OperatorTransport[];
      }
      if (error) {
        console.warn('Supabase operator_transport fetch error:', error.message);
      }
    } catch (e) {
      console.warn('Supabase operator_transport exception:', e);
    }
    const local = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
    return operatorId && isValidUUID(operatorId) ? local.filter(t => t.operator_id === operatorId) : local;
  },

  async addOperatorTransport(transport: Partial<OperatorTransport>): Promise<{ data: OperatorTransport; error: string | null }> {
    let resolvedOpId = transport.operator_id;
    if (!resolvedOpId || !isValidUUID(resolvedOpId)) {
      resolvedOpId = await this.ensureOperatorRecord() || undefined;
    } else {
      await this.ensureOperatorRecord(resolvedOpId);
    }

    const insertPayload: any = {
      vehicle_type: transport.vehicle_type || 'Private Luxury Van',
      capacity_passengers: Number(transport.capacity_passengers) || 6,
      cost_per_day: Number(transport.cost_per_day) || 250,
      cost_per_km: Number(transport.cost_per_km) || 2,
      vendor_company_name: transport.vendor_company_name || 'Fleet Partner',
      contact_phone: transport.contact_phone || '',
      features: transport.features || ['AC', 'WiFi', 'Luggage Carrier'],
      latitude: transport.latitude !== undefined ? transport.latitude : null,
      longitude: transport.longitude !== undefined ? transport.longitude : null,
      is_active: true
    };

    if (isValidUUID(resolvedOpId)) {
      insertPayload.operator_id = resolvedOpId;
    }

    let created: OperatorTransport = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `tr-${Date.now()}`,
      operator_id: insertPayload.operator_id || null,
      ...insertPayload,
      created_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabase.from('operator_transport').insert(insertPayload).select().single();
      if (!error && data) {
        created = data as OperatorTransport;
        const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
        const updated = [created, ...current.filter(t => t.id !== created.id)];
        setLocal(STORAGE_KEYS.TRANSPORT, updated);
        return { data: created, error: null };
      }

      if (error && insertPayload.operator_id) {
        const fallbackPayload = { ...insertPayload };
        delete fallbackPayload.operator_id;
        const retry = await supabase.from('operator_transport').insert(fallbackPayload).select().single();
        if (!retry.error && retry.data) {
          created = retry.data as OperatorTransport;
          const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
          const updated = [created, ...current.filter(t => t.id !== created.id)];
          setLocal(STORAGE_KEYS.TRANSPORT, updated);
          return { data: created, error: null };
        }
      }

      if (error) {
        console.warn('Supabase add transport error:', error.message);
        const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
        const updated = [created, ...current.filter(t => t.id !== created.id)];
        setLocal(STORAGE_KEYS.TRANSPORT, updated);
        return { data: created, error: error.message };
      }
    } catch (e: any) {
      console.warn('Supabase add transport exception:', e);
      const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
      const updated = [created, ...current.filter(t => t.id !== created.id)];
      setLocal(STORAGE_KEYS.TRANSPORT, updated);
      return { data: created, error: e.message || 'Network error' };
    }

    const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
    const updated = [created, ...current.filter(t => t.id !== created.id)];
    setLocal(STORAGE_KEYS.TRANSPORT, updated);
    return { data: created, error: null };
  },

  async updateOperatorTransport(transport: OperatorTransport): Promise<{ success: boolean; error: string | null }> {
    const updatePayload = {
      vehicle_type: transport.vehicle_type,
      capacity_passengers: Number(transport.capacity_passengers) || 4,
      cost_per_day: Number(transport.cost_per_day) || 250,
      cost_per_km: Number(transport.cost_per_km) || 2,
      vendor_company_name: transport.vendor_company_name,
      contact_phone: transport.contact_phone,
      features: transport.features,
      latitude: transport.latitude !== undefined ? transport.latitude : null,
      longitude: transport.longitude !== undefined ? transport.longitude : null,
      updated_at: new Date().toISOString()
    };

    const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
    setLocal(STORAGE_KEYS.TRANSPORT, current.map(t => t.id === transport.id ? { ...t, ...updatePayload } : t));

    if (isValidUUID(transport.id)) {
      try {
        const { error } = await supabase
          .from('operator_transport')
          .update(updatePayload)
          .eq('id', transport.id);
        if (error) {
          console.warn('Supabase update transport error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase update transport exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  },

  async deleteOperatorTransport(id: string): Promise<{ success: boolean; error: string | null }> {
    const current = getLocal<OperatorTransport[]>(STORAGE_KEYS.TRANSPORT, []);
    setLocal(STORAGE_KEYS.TRANSPORT, current.filter(t => t.id !== id));

    if (isValidUUID(id)) {
      try {
        const { error } = await supabase.from('operator_transport').delete().eq('id', id);
        if (error) {
          console.warn('Supabase delete transport error:', error.message);
          return { success: false, error: error.message };
        }
        return { success: true, error: null };
      } catch (e: any) {
        console.warn('Supabase delete transport exception:', e);
        return { success: false, error: e.message };
      }
    }

    return { success: true, error: null };
  }
};

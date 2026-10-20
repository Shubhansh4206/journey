import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gwisnrgiuunhfcjernar.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

const supabase = createClient(supabaseUrl, supabaseKey);

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (id) {
      // 1. Fetch single trip request
      const { data: trip, error: tripErr } = await supabase
        .from('trip_requests')
        .select('*')
        .eq('id', id)
        .single();

      if (tripErr || !trip) {
        return NextResponse.json({ error: tripErr?.message || 'Trip request not found' }, { status: 404 });
      }

      // 2. Hydrate selected items
      const hydrated: {
        hotels: any[];
        places: any[];
        activities: any[];
        transport: any[];
      } = {
        hotels: [],
        places: [],
        activities: [],
        transport: []
      };

      if (trip.selected_hotels && trip.selected_hotels.length > 0) {
        const { data: hotels } = await supabase
          .from('operator_hotels')
          .select('*')
          .in('id', trip.selected_hotels);
        hydrated.hotels = hotels || [];
      }

      if (trip.selected_places && trip.selected_places.length > 0) {
        const { data: places } = await supabase
          .from('operator_places')
          .select('*')
          .in('id', trip.selected_places);
        hydrated.places = places || [];
      }

      if (trip.selected_activities && trip.selected_activities.length > 0) {
        const { data: activities } = await supabase
          .from('operator_activities')
          .select('*')
          .in('id', trip.selected_activities);
        hydrated.activities = activities || [];
      }

      if (trip.selected_transport && trip.selected_transport.length > 0) {
        const { data: transport } = await supabase
          .from('operator_transport')
          .select('*')
          .in('id', trip.selected_transport);
        hydrated.transport = transport || [];
      }

      // Map budget & dates
      const perPersonBudget = trip.per_person_budget || 0;
      const budgetRange = Array.isArray(trip.budget_range) && trip.budget_range.length >= 2
        ? trip.budget_range
        : [perPersonBudget || 3000, (perPersonBudget ? perPersonBudget * 1.5 : 6000)];

      const travelDates = trip.start_date && trip.end_date
        ? `${trip.start_date} → ${trip.end_date}`
        : trip.travel_dates || 'Flexible 2026';

      const formattedTrip = {
        ...trip,
        travel_dates: travelDates,
        budget_range: budgetRange,
        per_person_budget: perPersonBudget,
      };

      return NextResponse.json({
        success: true,
        trip_request: formattedTrip,
        hydrated_items: hydrated
      });
    }

    // List all trip requests
    const { data, error } = await supabase
      .from('trip_requests')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    const formattedList = (data || []).map((trip: any) => {
      const perPersonBudget = trip.per_person_budget || 0;
      const budgetRange = Array.isArray(trip.budget_range) && trip.budget_range.length >= 2
        ? trip.budget_range
        : [perPersonBudget || 3000, (perPersonBudget ? perPersonBudget * 1.5 : 6000)];

      const travelDates = trip.start_date && trip.end_date
        ? `${trip.start_date} → ${trip.end_date}`
        : trip.travel_dates || 'Flexible 2026';

      return {
        ...trip,
        travel_dates: travelDates,
        budget_range: budgetRange,
        per_person_budget: perPersonBudget,
        selected_hotels: trip.selected_hotels || [],
        selected_places: trip.selected_places || [],
        selected_activities: trip.selected_activities || [],
        selected_transport: trip.selected_transport || [],
        customer_name: trip.assigned_group_name 
          ? `${trip.trip_mode || 'Group'}: ${trip.assigned_group_name}` 
          : 'Verified Traveler'
      };
    });

    return NextResponse.json(formattedList);
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Internal server error' }, { status: 500 });
  }
}

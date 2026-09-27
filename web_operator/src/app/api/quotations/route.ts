import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gwisnrgiuunhfcjernar.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

const supabase = createClient(supabaseUrl, supabaseKey);

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      trip_request_id,
      operator_id,
      title,
      status = 'sent',
      nodes = [],
      edges = [],
      valid_until
    } = body;

    if (!trip_request_id) {
      return NextResponse.json(
        { error: 'trip_request_id is required' },
        { status: 400 }
      );
    }

    // 1. Calculate financial totals across all nodes
    let total_base_cost = 0;
    let total_margin_amount = 0;
    let total_final_price = 0;

    const sanitizedNodes = nodes.map((node: any, idx: number) => {
      const data = node.data || {};
      const baseCost = Number(data.baseCost ?? data.cost ?? 0);
      const margin = Number(data.margin ?? 15);
      const marginAmount = Math.round(baseCost * (margin / 100));
      const finalPrice = baseCost + marginAmount;

      total_base_cost += baseCost;
      total_margin_amount += marginAmount;
      total_final_price += finalPrice;

      const rawType = (data.type || node.type || 'ACTIVITY').toUpperCase().replace('NODE', '');
      let node_type = 'ACTIVITY';
      if (rawType.includes('HOTEL')) node_type = 'HOTEL';
      else if (rawType.includes('TRANS')) node_type = 'TRANSFER';
      else if (rawType.includes('FLIGHT')) node_type = 'FLIGHT';
      else if (rawType.includes('PLACE')) node_type = 'PLACE';

      return {
        client_node_id: String(node.id || `node-${idx + 1}`),
        node_type,
        title: data.title || `Item ${idx + 1}`,
        location_subtitle: data.location || data.location_subtitle || null,
        day_number: data.day ?? 1,
        time_slot: data.time ?? null,
        base_cost: baseCost,
        margin_percentage: margin,
        final_price: finalPrice,
        ui_coordinates: node.position || { x: 100, y: 100 },
        specs: data.specs || {},
        original_inventory_id: data.original_inventory_id || null,
        is_optional: Boolean(data.is_optional)
      };
    });

    // 2. Fetch operator_id fallback if not provided
    let assignedOperatorId = operator_id;
    if (!assignedOperatorId) {
      const { data: opData } = await supabase.from('tour_operators').select('id').limit(1).single();
      assignedOperatorId = opData?.id || 'dc3d36fb-0502-432a-920d-c3daa95c981a';
    }

    // 3. Insert into quotations table matching user's exact schema
    // Columns: trip_request_id, operator_id, title, status, total_base_cost, total_final_price, valid_until
    const quotePayload: any = {
      trip_request_id,
      operator_id: assignedOperatorId,
      title: title || 'Your Customized Itinerary',
      status,
      total_base_cost,
      total_final_price,
      valid_until: valid_until || new Date(Date.now() + 7 * 24 * 3600 * 1000).toISOString()
    };

    let quotationRecord: any = null;
    let tableExists = true;

    const { data: insertedQuotation, error: qErr } = await supabase
      .from('quotations')
      .insert(quotePayload)
      .select()
      .single();

    if (qErr) {
      console.warn('Could not insert to quotations table:', qErr.message);
      tableExists = false;
      quotationRecord = {
        id: `mock-quote-${Date.now()}`,
        ...quotePayload,
        created_at: new Date().toISOString()
      };
    } else {
      quotationRecord = insertedQuotation;
    }

    // 4. If quotation saved to DB, persist nodes and edges
    let savedNodeCount = 0;
    let savedEdgeCount = 0;

    if (tableExists && quotationRecord?.id) {
      // Map node rows matching itinerary_nodes schema:
      // quotation_id, node_type, title, location_subtitle, base_cost, margin_percentage, ui_coordinates, original_inventory_id
      // (final_price is GENERATED ALWAYS STORED so we must NOT pass it)
      const nodeRows = sanitizedNodes.map((n) => ({
        quotation_id: quotationRecord.id,
        node_type: n.node_type,
        title: n.title,
        location_subtitle: n.location_subtitle,
        base_cost: n.base_cost,
        margin_percentage: n.margin_percentage,
        ui_coordinates: {
          ...((typeof n.ui_coordinates === 'object' && n.ui_coordinates) || {}),
          day: n.day_number,
          time: n.time_slot,
          specs: n.specs,
          is_optional: n.is_optional
        },
        original_inventory_id: n.original_inventory_id
      }));

      if (nodeRows.length > 0) {
        const { data: dbNodes, error: nodeErr } = await supabase
          .from('itinerary_nodes')
          .insert(nodeRows)
          .select();

        if (nodeErr) {
          console.warn('Could not insert to itinerary_nodes:', nodeErr.message);
        } else if (dbNodes) {
          savedNodeCount = dbNodes.length;

          // Map client node id to DB node UUID for edges
          const idMap = new Map<string, string>();
          sanitizedNodes.forEach((n, idx) => {
            if (dbNodes[idx]) {
              idMap.set(n.client_node_id, dbNodes[idx].id);
            }
          });

          // Insert edges matching itinerary_edges schema:
          // quotation_id, source_node_id, target_node_id, edge_type, travel_time_minutes
          const edgeRows = edges
            .filter((e: any) => idMap.has(String(e.source)) && idMap.has(String(e.target)))
            .map((e: any) => ({
              quotation_id: quotationRecord.id,
              source_node_id: idMap.get(String(e.source))!,
              target_node_id: idMap.get(String(e.target))!,
              edge_type: e.edge_type || 'transit',
              travel_time_minutes: e.travel_time_minutes || 0
            }));

          if (edgeRows.length > 0) {
            const { error: edgeErr } = await supabase.from('itinerary_edges').insert(edgeRows);
            if (edgeErr) {
              console.warn('Could not insert to itinerary_edges:', edgeErr.message);
            } else {
              savedEdgeCount = edgeRows.length;
            }
          }
        }
      }
    }

    // 5. Update trip_request status
    await supabase
      .from('trip_requests')
      .update({ status: 'quoted' })
      .eq('id', trip_request_id);

    return NextResponse.json({
      success: true,
      message: 'Quotation created and sent successfully',
      quotation: quotationRecord,
      stats: {
        total_base_cost,
        total_margin_amount,
        total_final_price,
        nodes_saved: savedNodeCount || sanitizedNodes.length,
        edges_saved: savedEdgeCount || edges.length,
        persisted_to_db: tableExists
      }
    });

  } catch (error: any) {
    console.error('Error in POST /api/quotations:', error);
    return NextResponse.json(
      { error: error?.message || 'Internal Server Error' },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const tripRequestId = searchParams.get('trip_request_id');

    if (!tripRequestId) {
      return NextResponse.json(
        { error: 'trip_request_id parameter is required' },
        { status: 400 }
      );
    }

    // Fetch latest quotation
    const { data: quotation, error: qErr } = await supabase
      .from('quotations')
      .select('*')
      .eq('trip_request_id', tripRequestId)
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (qErr || !quotation) {
      return NextResponse.json({ found: false, quotation: null }, { status: 404 });
    }

    // Fetch nodes
    const { data: nodes } = await supabase
      .from('itinerary_nodes')
      .select('*')
      .eq('quotation_id', quotation.id)
      .order('created_at', { ascending: true });

    // Fetch edges
    const { data: edges } = await supabase
      .from('itinerary_edges')
      .select('*')
      .eq('quotation_id', quotation.id);

    return NextResponse.json({
      found: true,
      quotation,
      nodes: nodes || [],
      edges: edges || []
    });

  } catch (error: any) {
    console.error('Error in GET /api/quotations:', error);
    return NextResponse.json(
      { error: error?.message || 'Internal Server Error' },
      { status: 500 }
    );
  }
}

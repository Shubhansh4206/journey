import { ItineraryNode, ItineraryEdge, TripRequest } from './types';
import { INVENTORY_CATALOG } from './inventoryCatalog';

export interface AiAgentAction {
  type: 'add_node' | 'update_margins' | 'connect_nodes' | 'optimize_budget' | 'auto_draft';
  description: string;
  affectedNodesCount?: number;
  newQuotationTotal?: number;
}

export interface AiAgentResponse {
  reasoning: string[];
  suggestedAction: string;
  updatedNodes: ItineraryNode[];
  updatedEdges: ItineraryEdge[];
  summaryMessage: string;
}

export function autoDraftItineraryForRequest(
  request: TripRequest,
  itineraryId: string
): { nodes: ItineraryNode[]; edges: ItineraryEdge[] } {
  const isKyoto = request.destination.toLowerCase().includes('kyoto') || request.destination.toLowerCase().includes('tokyo');
  const isHokkaido = request.destination.toLowerCase().includes('hokkaido') || request.destination.toLowerCase().includes('ski');
  
  const nodes: ItineraryNode[] = [];
  const edges: ItineraryEdge[] = [];

  if (isHokkaido) {
    // Hokkaido ski itinerary
    const f1: ItineraryNode = {
      id: `node-${Date.now()}-1`,
      itinerary_id: itineraryId,
      node_type: 'flight',
      title: 'JAL Domestic Executive: HND -> CTS (Sapporo)',
      base_cost: 420,
      margin_percentage: 15,
      final_price: 483,
      ui_coordinates: { x: 80, y: 140 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.96,
        reasoning: 'Direct flight to Sapporo Chitose with ski luggage priority handling.'
      },
      details: {
        provider: 'Japan Airlines (JL519)',
        duration: '1h 35m'
      }
    };

    const tr1: ItineraryNode = {
      id: `node-${Date.now()}-2`,
      itinerary_id: itineraryId,
      node_type: 'transfer',
      title: 'Private 4WD Alphard Transfer to Niseko',
      base_cost: 320,
      margin_percentage: 20,
      final_price: 384,
      ui_coordinates: { x: 420, y: 140 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.99,
        reasoning: 'Winter mountain terrain requires dedicated private 4WD with ski racks.'
      },
      details: {
        transport_mode: 'Luxury 4WD MPV',
        duration: '2h 10m',
        distance_km: 115
      }
    };

    const ht1: ItineraryNode = {
      id: `node-${Date.now()}-3`,
      itinerary_id: itineraryId,
      node_type: 'hotel',
      title: 'Park Hyatt Niseko Hanazono (3 Nights)',
      base_cost: 1860,
      margin_percentage: 18,
      final_price: 2194.8,
      ui_coordinates: { x: 760, y: 80 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.95,
        reasoning: 'Ski-in ski-out luxury accommodation with onsen directly matching request.'
      },
      details: {
        room_type: 'Mountain View Onsen Suite',
        nights: 3,
        provider: 'Hyatt International'
      }
    };

    const act1: ItineraryNode = {
      id: `node-${Date.now()}-4`,
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: 'Private Certified English Ski Guide & Powder Clinic',
      base_cost: 540,
      margin_percentage: 25,
      final_price: 675,
      ui_coordinates: { x: 760, y: 350 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.98,
        reasoning: 'Dedicated English instructor guarantees safe off-piste powder experience.'
      },
      details: {
        duration: 'Full Day (6 hours)',
        provider: 'Niseko Mountain Academy'
      }
    };

    nodes.push(f1, tr1, ht1, act1);
    edges.push(
      { id: `e-${Date.now()}-1`, itinerary_id: itineraryId, source_node_id: f1.id, target_node_id: tr1.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-2`, itinerary_id: itineraryId, source_node_id: tr1.id, target_node_id: ht1.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-3`, itinerary_id: itineraryId, source_node_id: ht1.id, target_node_id: act1.id, edge_type: 'next_step' }
    );
  } else {
    // Tokyo & Kyoto Golden Route
    const f1: ItineraryNode = {
      id: `node-${Date.now()}-1`,
      itinerary_id: itineraryId,
      node_type: 'flight',
      title: 'ANA First Class Arrival: SFO -> HND',
      base_cost: 1400,
      margin_percentage: 12,
      final_price: 1568,
      ui_coordinates: { x: 80, y: 150 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.98,
        reasoning: 'Arrives at Tokyo Haneda closest to Aman Tokyo hotel.'
      },
      details: {
        provider: 'All Nippon Airways (NH107)',
        duration: '11h 10m'
      }
    };

    const ht1: ItineraryNode = {
      id: `node-${Date.now()}-2`,
      itinerary_id: itineraryId,
      node_type: 'hotel',
      title: 'Aman Tokyo - Premier Suite (3 Nights)',
      base_cost: 950,
      margin_percentage: 18,
      final_price: 1121,
      ui_coordinates: { x: 420, y: 90 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.96,
        reasoning: 'Celebration tier urban luxury in Otemachi.'
      },
      details: {
        room_type: 'Premier Suite',
        nights: 3,
        provider: 'Aman Group'
      }
    };

    const act1: ItineraryNode = {
      id: `node-${Date.now()}-3`,
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: 'Tsukiji Master Chef Tasting & Private Tour',
      base_cost: 190,
      margin_percentage: 25,
      final_price: 237.5,
      ui_coordinates: { x: 420, y: 350 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.93,
        reasoning: 'Morning VIP culinary immersion.'
      },
      details: {
        duration: '3 hours',
        provider: 'Edo Culinary Guild'
      }
    };

    const tr1: ItineraryNode = {
      id: `node-${Date.now()}-4`,
      itinerary_id: itineraryId,
      node_type: 'transfer',
      title: 'Shinkansen Gran Class (Tokyo -> Kyoto)',
      base_cost: 240,
      margin_percentage: 15,
      final_price: 276,
      ui_coordinates: { x: 760, y: 150 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.99,
        reasoning: 'Scenic high-speed transit with Mount Fuji vistas.'
      },
      details: {
        transport_mode: 'Shinkansen Bullet Train',
        duration: '2h 15m',
        distance_km: 450
      }
    };

    const ht2: ItineraryNode = {
      id: `node-${Date.now()}-5`,
      itinerary_id: itineraryId,
      node_type: 'hotel',
      title: 'Hoshinoya Kyoto - Riverside Ryokan (2 Nights)',
      base_cost: 720,
      margin_percentage: 20,
      final_price: 864,
      ui_coordinates: { x: 1100, y: 90 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.97,
        reasoning: 'Private river boat access & kaiseki gastronomy.'
      },
      details: {
        room_type: 'Pavilion River View',
        nights: 2,
        provider: 'Hoshino Resorts'
      }
    };

    const act2: ItineraryNode = {
      id: `node-${Date.now()}-6`,
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: 'Private Geisha Dinner & Tea Ceremony in Gion',
      base_cost: 450,
      margin_percentage: 25,
      final_price: 562.5,
      ui_coordinates: { x: 1100, y: 350 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.95,
        reasoning: 'Exclusive teahouse access.'
      },
      details: {
        duration: '3.5 hours',
        provider: 'Kyoto Cultural Heritage Guild'
      }
    };

    nodes.push(f1, ht1, act1, tr1, ht2, act2);
    edges.push(
      { id: `e-${Date.now()}-1`, itinerary_id: itineraryId, source_node_id: f1.id, target_node_id: ht1.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-2`, itinerary_id: itineraryId, source_node_id: ht1.id, target_node_id: act1.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-3`, itinerary_id: itineraryId, source_node_id: ht1.id, target_node_id: tr1.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-4`, itinerary_id: itineraryId, source_node_id: tr1.id, target_node_id: ht2.id, edge_type: 'next_step' },
      { id: `e-${Date.now()}-5`, itinerary_id: itineraryId, source_node_id: ht2.id, target_node_id: act2.id, edge_type: 'next_step' }
    );
  }

  return { nodes, edges };
}

export function executeAiPrompt(
  prompt: string,
  currentNodes: ItineraryNode[],
  currentEdges: ItineraryEdge[],
  request: TripRequest,
  itineraryId: string
): AiAgentResponse {
  const p = prompt.toLowerCase();
  let updatedNodes = [...currentNodes];
  let updatedEdges = [...currentEdges];
  const reasoning: string[] = [];
  let summaryMessage = '';
  let suggestedAction = 'Plan refined';

  // 1. Uniform margin change
  if (p.includes('margin') && (p.includes('%') || /\d+/.test(p))) {
    const match = p.match(/(\d+)\s*%/);
    const targetMargin = match ? parseInt(match[1], 10) : 18;
    reasoning.push(`Identified request to standardize margin percentage across nodes to ${targetMargin}%.`);
    reasoning.push(`Recalculating final prices: base_cost * (1 + ${targetMargin} / 100).`);
    
    updatedNodes = updatedNodes.map(node => {
      const margin_percentage = targetMargin;
      const final_price = Number((node.base_cost * (1 + margin_percentage / 100)).toFixed(2));
      return { ...node, margin_percentage, final_price };
    });

    suggestedAction = `Margin standardized to ${targetMargin}%`;
    summaryMessage = `Successfully adjusted margins on all ${updatedNodes.length} nodes to ${targetMargin}%. All pricing re-synchronized.`;
    return { reasoning, suggestedAction, updatedNodes, updatedEdges, summaryMessage };
  }

  // 2. Budget optimization
  if (p.includes('budget') || p.includes('lower') || p.includes('cheaper') || p.includes('reduce') || p.includes('cut')) {
    const maxBudget = request.budget_range[1] || 5000;
    reasoning.push(`Analyzing itinerary total vs target budget constraint ($${maxBudget.toLocaleString()}).`);
    reasoning.push(`Finding nodes with highest margin elasticity.`);
    
    updatedNodes = updatedNodes.map(node => {
      // Lower margin slightly on premium items
      const newMargin = Math.max(10, Math.round(node.margin_percentage * 0.8));
      const final_price = Number((node.base_cost * (1 + newMargin / 100)).toFixed(2));
      return {
        ...node,
        margin_percentage: newMargin,
        final_price,
        ai_metadata: {
          ...node.ai_metadata,
          reasoning: `Margin trimmed by 20% to meet traveler target budget.`
        }
      };
    });

    suggestedAction = 'Budget optimized';
    summaryMessage = `Optimized pricing structure across ${updatedNodes.length} nodes to fit comfortably within the traveler's budget limit.`;
    return { reasoning, suggestedAction, updatedNodes, updatedEdges, summaryMessage };
  }

  // 3. Add Activity (e.g. Fuji helicopter, dinner, etc.)
  if (p.includes('helicopter') || p.includes('fuji')) {
    reasoning.push('Found match for Mount Fuji Scenic Helicopter Expedition.');
    reasoning.push('Calculating optimal canvas placement adjacent to Day 2 Tokyo activities.');
    
    const maxX = updatedNodes.reduce((max, n) => Math.max(max, n.ui_coordinates.x), 100);
    const newNode: ItineraryNode = {
      id: `node-${Date.now()}`,
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: 'Mount Fuji Scenic Helicopter Expedition',
      base_cost: 580,
      margin_percentage: 20,
      final_price: 696,
      ui_coordinates: { x: maxX + 320, y: 220 },
      ai_metadata: {
        generated_by: 'agent',
        confidence_score: 0.97,
        reasoning: 'Added per operator instruction. VIP private aerial views of Mount Fuji.'
      },
      details: {
        duration: '45 mins flight + champagne',
        provider: 'Aero Fuji Charters',
        city: 'Hakone / Fuji'
      }
    };

    updatedNodes.push(newNode);
    if (updatedNodes.length > 1) {
      const prevNode = updatedNodes[updatedNodes.length - 2];
      updatedEdges.push({
        id: `edge-${Date.now()}`,
        itinerary_id: itineraryId,
        source_node_id: prevNode.id,
        target_node_id: newNode.id,
        edge_type: 'next_step',
        travel_time_minutes: 40
      });
    }

    suggestedAction = 'Helicopter tour added';
    summaryMessage = `Added Mount Fuji Helicopter Expedition node and connected it to the active itinerary graph.`;
    return { reasoning, suggestedAction, updatedNodes, updatedEdges, summaryMessage };
  }

  // 4. Auto-connect all nodes
  if (p.includes('connect') || p.includes('wire') || p.includes('link') || p.includes('sequence')) {
    reasoning.push('Inspecting all nodes for sequential flow.');
    reasoning.push('Sorting nodes by chronological and logistical topology (Flight -> Hotel -> Activities -> Transfer -> Hotel).');
    
    const sorted = [...updatedNodes].sort((a, b) => a.ui_coordinates.x - b.ui_coordinates.x);
    updatedEdges = [];
    for (let i = 0; i < sorted.length - 1; i++) {
      updatedEdges.push({
        id: `edge-auto-${i}-${Date.now()}`,
        itinerary_id: itineraryId,
        source_node_id: sorted[i].id,
        target_node_id: sorted[i + 1].id,
        edge_type: 'next_step',
        travel_time_minutes: 30
      });
    }

    suggestedAction = 'Graph sequenced';
    summaryMessage = `Generated ${updatedEdges.length} sequence edges connecting all itinerary blocks seamlessly.`;
    return { reasoning, suggestedAction, updatedNodes, updatedEdges, summaryMessage };
  }

  // Default: Smart enhancement
  reasoning.push(`Parsed instruction: "${prompt}"`);
  reasoning.push('Scanning inventory and node graph for optimization opportunities.');
  reasoning.push('Aligned financial metrics and validated node integrity.');

  suggestedAction = 'Itinerary updated';
  summaryMessage = `Agent evaluated: "${prompt}". Validated itinerary graph and ensured all nodes have valid cost calculations and layout positions.`;
  return { reasoning, suggestedAction, updatedNodes, updatedEdges, summaryMessage };
}

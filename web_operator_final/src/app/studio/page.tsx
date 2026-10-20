'use client';

import React, { useState, useCallback, useMemo, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import {
  ReactFlow,
  Controls,
  Background,
  applyNodeChanges,
  applyEdgeChanges,
  addEdge,
  Connection,
  EdgeChange,
  NodeChange,
  useReactFlow,
  ReactFlowProvider,
  Node,
  Edge,
  BackgroundVariant
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import { 
  Terminal, 
  Sparkles, 
  Send, 
  Clock, 
  ArrowLeft,
  CheckCircle2,
  RefreshCw,
  TrendingUp,
  DollarSign,
  FileCheck2,
  Save
} from 'lucide-react';
import Link from 'next/link';
import { TripRequest, TourOperator } from '../../lib/types';
import { dbService } from '../../lib/dbService';
import { DarkItineraryNode } from '../../components/canvas/DarkItineraryNode';

// --- 1. MAIN CANVAS COMPONENT ---
function CanvasInner() {
  const searchParams = useSearchParams();
  const paramTripId = searchParams?.get('trip_id');
  const paramOperatorId = searchParams?.get('operator_id');

  const [operator, setOperator] = useState<TourOperator | null>(null);
  const [nodes, setNodes] = useState<Node[]>([]);
  const [edges, setEdges] = useState<Edge[]>([]);
  const [isGenerating, setIsGenerating] = useState(false);
  const [isSavingQuotation, setIsSavingQuotation] = useState(false);
  const [agentThoughts, setAgentThoughts] = useState<string>('');
  
  // Trip request state
  const [tripId, setTripId] = useState<string>(paramTripId || '0ec1aea6-9bb9-45a4-963a-e2c994ff7997');
  const [currentTrip, setCurrentTrip] = useState<TripRequest | null>(null);
  const [saveStatus, setSaveStatus] = useState<string | null>(null);

  useEffect(() => {
    dbService.getActiveOperator().then((op) => {
      if (op) setOperator(op);
    }).catch(console.warn);
  }, []);

  const { fitView } = useReactFlow();

  // Callbacks for live node updates
  const handleBaseCostChange = useCallback((id: string, newCost: number) => {
    setNodes((prevNodes) =>
      prevNodes.map((n) => {
        if (n.id === id) {
          const margin = n.data?.margin !== undefined ? Number(n.data.margin) : 15;
          const quotationPrice = newCost + Math.round(newCost * (margin / 100));
          return {
            ...n,
            data: {
              ...n.data,
              baseCost: newCost,
              quotationPrice
            }
          };
        }
        return n;
      })
    );
  }, []);

  const handleMarginChange = useCallback((id: string, newMargin: number) => {
    setNodes((prevNodes) =>
      prevNodes.map((n) => {
        if (n.id === id) {
          const baseCost = n.data?.baseCost !== undefined ? Number(n.data.baseCost) : 0;
          const quotationPrice = baseCost + Math.round(baseCost * (newMargin / 100));
          return {
            ...n,
            data: {
              ...n.data,
              margin: newMargin,
              quotationPrice
            }
          };
        }
        return n;
      })
    );
  }, []);

  const handleDeleteNode = useCallback((id: string) => {
    setNodes((prev) => prev.filter((n) => n.id !== id));
    setEdges((prev) => prev.filter((e) => e.source !== id && e.target !== id));
  }, []);

  // Register DarkItineraryNode across all node types
  const nodeTypes = useMemo(() => ({
    darkNode: DarkItineraryNode,
    hotelNode: DarkItineraryNode,
    placeNode: DarkItineraryNode,
    activityNode: DarkItineraryNode,
    flightNode: DarkItineraryNode,
    transferNode: DarkItineraryNode,
    hotel: DarkItineraryNode,
    place: DarkItineraryNode,
    activity: DarkItineraryNode,
    flight: DarkItineraryNode,
    transfer: DarkItineraryNode
  }), []);

  // Sync with searchParams
  useEffect(() => {
    if (paramTripId && paramTripId !== tripId) {
      setTripId(paramTripId);
    }
  }, [paramTripId]);

  // Load trip request and initial nodes for selected items
  useEffect(() => {
    if (!tripId) return;
    loadTripAndInitialNodes(tripId);
  }, [tripId]);

  const loadTripAndInitialNodes = async (id: string) => {
    try {
      const res = await fetch(`/api/trip-requests?id=${encodeURIComponent(id.trim())}`);
      if (!res.ok) {
        setAgentThoughts(`Trip Request #${id.slice(0, 8)}... not found.\nClick "Dashboard" to pick an active request.`);
        return;
      }

      const json = await res.json();
      const trip: TripRequest = json.trip_request;
      const hydrated = json.hydrated_items || { hotels: [], places: [], activities: [], transport: [] };
      setCurrentTrip(trip);

      // Hydrate customer-selected items into sleek horizontal luxury cards
      const initialNodes: Node[] = [];
      let colIdx = 0;

      // 1. Hotels
      (hydrated.hotels || []).forEach((h: any) => {
        const baseCost = Number(h.contracted_rate_per_night || 250);
        const margin = 15;
        const quotationPrice = baseCost + Math.round(baseCost * (margin / 100));

        initialNodes.push({
          id: `init-hotel-${h.id}`,
          type: 'darkNode',
          position: { x: 80 + colIdx * 360, y: 140 },
          data: {
            id: `init-hotel-${h.id}`,
            type: 'HOTEL',
            title: h.name,
            location: `${h.city || ''} · ${h.address || 'Contracted Accommodation'}`,
            baseCost,
            margin,
            quotationPrice,
            currency: '₹',
            day: 1,
            time: 'Overnight Stay',
            badge: 'Traveler Selected',
            specs: {
              star_rating: h.star_rating,
              inclusions: h.amenities || ['Breakfast Included', 'Free Wi-Fi'],
              address: h.address
            },
            original_inventory_id: h.id,
            onBaseCostChange: handleBaseCostChange,
            onMarginChange: handleMarginChange,
            onDeleteNode: handleDeleteNode
          }
        });
        colIdx++;
      });

      // 2. Places
      (hydrated.places || []).forEach((p: any) => {
        const baseCost = Number(p.entry_fee_per_person || 0);
        const margin = 15;
        const quotationPrice = baseCost + Math.round(baseCost * (margin / 100));

        initialNodes.push({
          id: `init-place-${p.id}`,
          type: 'darkNode',
          position: { x: 80 + colIdx * 360, y: 140 },
          data: {
            id: `init-place-${p.id}`,
            type: 'PLACE',
            title: p.name,
            location: p.city || 'Sightseeing Attraction',
            baseCost,
            margin,
            quotationPrice,
            currency: '₹',
            day: 1,
            time: `${p.recommended_duration_minutes || 60}m Visit`,
            badge: 'Traveler Selected',
            specs: {
              duration: `${p.recommended_duration_minutes || 60} mins`,
              notes: p.description
            },
            original_inventory_id: p.id,
            onBaseCostChange: handleBaseCostChange,
            onMarginChange: handleMarginChange,
            onDeleteNode: handleDeleteNode
          }
        });
        colIdx++;
      });

      // 3. Activities
      (hydrated.activities || []).forEach((a: any) => {
        const baseCost = Number(a.cost_per_person || 95);
        const margin = 15;
        const quotationPrice = baseCost + Math.round(baseCost * (margin / 100));

        initialNodes.push({
          id: `init-activity-${a.id}`,
          type: 'darkNode',
          position: { x: 80 + colIdx * 360, y: 140 },
          data: {
            id: `init-activity-${a.id}`,
            type: 'ACTIVITY',
            title: a.title,
            location: a.location || 'Curated Experience',
            baseCost,
            margin,
            quotationPrice,
            currency: '₹',
            day: 1,
            time: `${a.duration_minutes || 120}m Activity`,
            badge: 'Traveler Selected',
            specs: {
              duration: `${a.duration_minutes || 120} mins`,
              inclusions: a.inclusions || ['Certified Guide', 'Entry Pass']
            },
            original_inventory_id: a.id,
            onBaseCostChange: handleBaseCostChange,
            onMarginChange: handleMarginChange,
            onDeleteNode: handleDeleteNode
          }
        });
        colIdx++;
      });

      // 4. Transport
      (hydrated.transport || []).forEach((t: any) => {
        const baseCost = Number(t.cost_per_day || 120);
        const margin = 15;
        const quotationPrice = baseCost + Math.round(baseCost * (margin / 100));

        initialNodes.push({
          id: `init-trans-${t.id}`,
          type: 'darkNode',
          position: { x: 80 + colIdx * 360, y: 140 },
          data: {
            id: `init-trans-${t.id}`,
            type: 'TRANSFER',
            title: t.vehicle_type || 'Private Transfer',
            location: t.vendor_company_name || 'Fleet Partner',
            baseCost,
            margin,
            quotationPrice,
            currency: '₹',
            day: 1,
            time: 'Chauffeur Service',
            badge: 'Traveler Selected',
            specs: {
              vehicle_type: t.vehicle_type,
              inclusions: t.features || ['AC', 'Luggage Assistance']
            },
            original_inventory_id: t.id,
            onBaseCostChange: handleBaseCostChange,
            onMarginChange: handleMarginChange,
            onDeleteNode: handleDeleteNode
          }
        });
        colIdx++;
      });

      setNodes(initialNodes);
      setEdges([]);

      const dest = trip.destination || 'Destination';
      const budget = trip.per_person_budget || trip.budget_range?.[0] || 0;
      const dates = trip.travel_dates || 'Flexible';
      const groupInfo = trip.assigned_group_name ? ` (${trip.trip_mode || 'Group'}: ${trip.assigned_group_name})` : '';

      setAgentThoughts(
        `✓ TRIP REQUEST INGESTED: #${id.slice(0, 8)}...\n` +
        `Destination: ${dest}${groupInfo}\n` +
        `Dates: ${dates}\n` +
        `Target Budget: ₹${Number(budget).toLocaleString()}\n\n` +
        `→ Rendered ${initialNodes.length} traveler selections on canvas as cards with live margin controls.\n` +
        `→ Click 'Auto-Draft with AI' to let the ReAct Agent synthesize the sequential route and transit connections.`
      );

      setTimeout(() => {
        fitView({ padding: 0.25, duration: 600 });
      }, 200);

    } catch (e: any) {
      console.warn('Failed to load trip request context', e);
    }
  };

  // Standard React Flow dragging & connecting logic
  const onNodesChange = useCallback((changes: NodeChange[]) => setNodes((nds) => applyNodeChanges(changes, nds)), []);
  const onEdgesChange = useCallback((changes: EdgeChange[]) => setEdges((eds) => applyEdgeChanges(changes, eds)), []);
  const onConnect = useCallback((connection: Connection) => setEdges((eds) => addEdge({
    ...connection,
    animated: true,
    type: 'smoothstep',
    style: { stroke: '#0F172A', strokeWidth: 2 }
  }, eds)), []);

  // --- TRIGGER THE AGENTIC AI ---
  const handleAutoDraft = async () => {
    if (!tripId.trim()) {
      alert('Please enter a valid trip_request_id');
      return;
    }

    setIsGenerating(true);
    setSaveStatus(null);
    setAgentThoughts(
      `Agent initialized for Trip Request #${tripId.slice(0, 8)}...\n` +
      `Connecting to ReAct tools (calculate_transit_time, check_budget)...\n` +
      `Synthesizing optimal sequential itinerary graph...\n`
    );
    
    try {
      const response = await fetch('http://localhost:8000/api/v1/agents/generate-draft', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ trip_request_id: tripId.trim() }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Agent failed to generate draft (${response.status}): ${errorText}`);
      }

      const result = await response.json();
      
      const rawNodes = result.data?.nodes || result.nodes || [];
      const rawEdges = result.data?.edges || result.edges || [];
      
      // Horizontal sequential grid layout for nodes
      const formattedNodes: Node[] = rawNodes.map((node: any, idx: number) => {
        const rawType = (node.type || node.data?.type || 'ACTIVITY').toUpperCase().replace('NODE', '');
        let type = 'ACTIVITY';
        if (rawType.includes('HOTEL')) type = 'HOTEL';
        else if (rawType.includes('TRANS')) type = 'TRANSFER';
        else if (rawType.includes('FLIGHT')) type = 'FLIGHT';
        else if (rawType.includes('PLACE')) type = 'PLACE';

        const baseCost = Number(node.data?.baseCost ?? node.cost ?? node.price ?? 120);
        const margin = Number(node.data?.margin ?? 15);
        const quotationPrice = baseCost + Math.round(baseCost * (margin / 100));

        // Horizontal layout with day/slot rows
        const day = node.day || node.data?.day || 1;
        const posX = node.position?.x ?? (80 + (idx % 4) * 360);
        const posY = node.position?.y ?? (120 + Math.floor(idx / 4) * 290);

        return {
          id: String(node.id || `node-${idx + 1}`),
          type: 'darkNode',
          position: { x: posX, y: posY },
          data: {
            id: String(node.id || `node-${idx + 1}`),
            type,
            title: node.title || node.data?.title || 'Itinerary Item',
            location: node.location || node.data?.location || currentTrip?.destination || 'Scheduled Stop',
            baseCost,
            margin,
            quotationPrice,
            currency: '₹',
            day,
            time: node.time || node.data?.time || 'Scheduled',
            specs: node.specs || node.data?.specs || {
              duration: node.duration || '60 mins',
              notes: node.notes || 'Automated draft item'
            },
            onBaseCostChange: handleBaseCostChange,
            onMarginChange: handleMarginChange,
            onDeleteNode: handleDeleteNode
          }
        };
      });

      // Format deep navy smoothstep edges
      const formattedEdges: Edge[] = rawEdges.map((edge: any, idx: number) => ({
        id: String(edge.id || `edge-${idx + 1}`),
        source: String(edge.source || edge.source_node_id),
        target: String(edge.target || edge.target_node_id),
        animated: edge.animated ?? true,
        type: 'smoothstep',
        style: { stroke: '#0F172A', strokeWidth: 2 },
        ...edge
      }));

      setNodes(formattedNodes);
      setEdges(formattedEdges);
      
      let parsedThoughts = '';
      if (typeof result.agent_thoughts === 'string') {
        parsedThoughts = result.agent_thoughts;
      } else if (Array.isArray(result.agent_thoughts)) {
        parsedThoughts = result.agent_thoughts
          .map((item: any) => (typeof item === 'string' ? item : item.text || JSON.stringify(item)))
          .join('\n');
      } else if (result.agent_thoughts) {
        parsedThoughts = JSON.stringify(result.agent_thoughts, null, 2);
      } else {
        parsedThoughts = `✓ Generated draft successfully with ${formattedNodes.length} itinerary nodes.`;
      }

      setAgentThoughts(parsedThoughts);

      setTimeout(() => { 
        fitView({ padding: 0.2, duration: 800 }); 
      }, 200);
      
    } catch (err: any) {
      console.error(err);
      setAgentThoughts((prev) => `${prev}\n\n❌ ERROR: ${err?.message || 'Could not connect to Agent backend.'}`);
    } finally {
      setIsGenerating(false);
    }
  };

  // --- LIVE FINANCIAL TOTALS ---
  const financials = useMemo(() => {
    let totalBaseCost = 0;
    let totalQuotationPrice = 0;

    nodes.forEach((n) => {
      const baseCost = Number(n.data?.baseCost ?? n.data?.cost ?? 0);
      const margin = Number(n.data?.margin ?? 15);
      const marginAmount = Math.round(baseCost * (margin / 100));
      totalBaseCost += baseCost;
      totalQuotationPrice += (baseCost + marginAmount);
    });

    const totalMargin = totalQuotationPrice - totalBaseCost;
    const avgMarginPercent = totalBaseCost > 0 ? Math.round((totalMargin / totalBaseCost) * 100) : 15;

    return { totalBaseCost, totalMargin, totalQuotationPrice, avgMarginPercent };
  }, [nodes]);

  // --- SAVE / SEND QUOTATION ---
  const handleSaveQuotation = async (status: 'draft' | 'sent' = 'sent') => {
    if (nodes.length === 0) {
      alert('Cannot send an empty quotation. Add nodes or Auto-Draft first.');
      return;
    }

    setIsSavingQuotation(true);
    setSaveStatus(null);

    try {
      const activeOp = operator || (await dbService.getActiveOperator());
      const resolvedOperatorId = 
        (paramOperatorId && paramOperatorId !== '00000000-0000-0000-0000-000000000000' && paramOperatorId !== '11111111-1111-1111-1111-111111111111' ? paramOperatorId : null) || 
        activeOp?.id || 
        'dc3d36fb-0502-432a-920d-c3daa95c981a';

      const res = await fetch('/api/quotations', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          ...(resolvedOperatorId ? { 'x-operator-id': resolvedOperatorId } : {})
        },
        body: JSON.stringify({
          trip_request_id: tripId.trim(),
          operator_id: resolvedOperatorId,
          title: currentTrip ? `${currentTrip.destination} Customized Itinerary` : 'Customized Itinerary Quotation',
          status,
          currency: 'INR',
          nodes,
          edges
        })
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to save quotation');
      }

      const opName = activeOp?.company_name || 'Operator';
      const msg = status === 'sent' 
        ? `Quotation sent by ${opName} to traveler! Total: ₹${financials.totalQuotationPrice.toLocaleString()} (${nodes.length} items)`
        : `Draft saved successfully! (${nodes.length} items)`;

      setSaveStatus(msg);
      setAgentThoughts((prev) => `${prev}\n\n✓ ${msg}\nStatus: Quotation ID: ${data.quotation?.id || 'Saved'}\nOperator ID: ${data.quotation?.operator_id || resolvedOperatorId}`);

    } catch (err: any) {
      console.error(err);
      alert(`Error saving quotation: ${err.message}`);
    } finally {
      setIsSavingQuotation(false);
    }
  };

  return (
    <div className="flex h-screen w-full bg-[#FAF9F6] text-[#0F172A] overflow-hidden font-sans">
      
      {/* LEFT SIDEBAR: Quotation Engine & Agent Brain */}
      <div className="w-[430px] border-r border-slate-200 bg-white p-5 flex flex-col justify-between shadow-lg z-10 overflow-y-auto">
        <div>
          {/* Header navigation & title */}
          <div className="flex items-center justify-between mb-4">
            <div>
              <div className="flex items-center gap-2">
                <span className="h-2 w-2 rounded-full bg-[#0F172A] animate-ping" />
                <h2 className="text-base font-bold text-[#0F172A] tracking-tight">Operator Studio</h2>
              </div>
              <p className="text-[11px] text-[#64748B] mt-0.5">Interactive Itinerary & Quotation Engine</p>
            </div>

            <Link
              href="/"
              className="flex items-center gap-1.5 text-xs text-[#64748B] hover:text-[#0F172A] px-3 py-1.5 rounded-full border border-slate-200 bg-[#FAF9F6] transition-colors font-medium shadow-xs"
            >
              <ArrowLeft className="w-3.5 h-3.5" />
              <span>Dashboard</span>
            </Link>
          </div>

          {/* Active Trip Request Badge */}
          {currentTrip && (
            <div className="mb-3.5 bg-[#FAF9F6] p-3.5 rounded-2xl border border-slate-200/80 space-y-1.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-[#0F172A] flex items-center gap-1.5">
                  <span>{currentTrip.destination}</span>
                  {currentTrip.trip_mode && (
                    <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-white text-[#0F172A] border border-slate-200">
                      {currentTrip.trip_mode}
                    </span>
                  )}
                </span>
                <span className="text-xs font-semibold text-[#0F172A]">
                  Target: ₹{Number(currentTrip.per_person_budget || currentTrip.budget_range?.[0] || 0).toLocaleString()}
                </span>
              </div>
              <div className="text-[11px] text-[#64748B] flex items-center justify-between pt-0.5">
                <span>{currentTrip.travel_dates}</span>
                <span className="text-[11px] text-[#0F172A] font-semibold">
                  {nodes.length} items on canvas
                </span>
              </div>
            </div>
          )}

          {/* REAL-TIME FINANCIAL QUOTATION SUMMARY */}
          <div className="mb-4 rounded-2xl border border-slate-200/80 bg-white p-4 shadow-[0_4px_20px_rgba(0,0,0,0.03)]">
            <div className="flex items-center justify-between mb-2.5">
              <span className="text-xs font-semibold text-[#0F172A] flex items-center gap-1">
                <DollarSign className="w-3.5 h-3.5 text-[#0F172A]" />
                Quotation Breakdown
              </span>
              <span className="text-xs text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/60 font-semibold">
                +{financials.avgMarginPercent}% Margin
              </span>
            </div>

            <div className="grid grid-cols-2 gap-2 text-xs mb-2.5">
              <div className="bg-[#FAF9F6] p-2.5 rounded-xl border border-slate-200/60">
                <span className="block text-[11px] text-[#64748B] font-medium">Total Base Cost</span>
                <span className="font-semibold text-[#0F172A] text-sm">
                  ₹{financials.totalBaseCost.toLocaleString()}
                </span>
              </div>
              <div className="bg-[#FAF9F6] p-2.5 rounded-xl border border-slate-200/60">
                <span className="block text-[11px] text-[#64748B] font-medium">Operator Margin</span>
                <span className="font-bold text-[#0F172A] text-sm">
                  +₹{financials.totalMargin.toLocaleString()}
                </span>
              </div>
            </div>

            <div className="border-t border-slate-100 pt-2.5 flex items-center justify-between">
              <span className="text-xs font-semibold text-[#64748B]">Client Total Quote:</span>
              <span className="text-lg font-bold font-heading text-[#0F172A]">
                ₹{financials.totalQuotationPrice.toLocaleString()}
              </span>
            </div>
          </div>

          {/* Trip Request ID input */}
          <div className="mb-3.5 bg-[#FAF9F6] p-3 rounded-2xl border border-slate-200/80">
            <label className="block text-xs font-semibold text-[#0F172A] mb-1">
              Trip Request Reference
            </label>
            <input
              type="text"
              value={tripId}
              onChange={(e) => setTripId(e.target.value)}
              placeholder="e.g. 0ec1aea6-9bb9-45a4-963a-e2c994ff7997"
              className="w-full text-xs bg-white border border-slate-200 rounded-lg px-2.5 py-1.5 text-[#0F172A] focus:outline-none focus:border-[#0F172A] font-medium"
            />
          </div>

          {/* Action buttons */}
          <div className="flex flex-col gap-2 mb-4">
            <button
              onClick={handleAutoDraft}
              disabled={isGenerating}
              className="flex items-center justify-center rounded-full bg-[#0F172A] hover:bg-[#081f3a] px-4 py-2.5 font-semibold text-xs text-white shadow-md shadow-[#0F172A]/15 transition-all active:scale-[0.99] disabled:opacity-50 disabled:pointer-events-none"
            >
              {isGenerating ? (
                <span className="flex items-center gap-2">
                  <RefreshCw className="w-4 h-4 animate-spin text-white" />
                  <span>Agent Generating Route...</span>
                </span>
              ) : (
                <span className="flex items-center">
                  <Sparkles className="mr-2 h-4 w-4 text-white" />
                  <span>Auto-Draft with AI</span>
                </span>
              )}
            </button>
            
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => handleSaveQuotation('sent')}
                disabled={isSavingQuotation || nodes.length === 0}
                className="flex items-center justify-center rounded-full bg-[#0F172A] hover:bg-[#081f3a] px-3 py-2 font-semibold text-xs text-white shadow-sm transition-all active:scale-[0.99] disabled:opacity-40 disabled:pointer-events-none"
              >
                <Send className="mr-1.5 h-3.5 w-3.5 text-white" />
                <span>Send to Traveler</span>
              </button>

              <button
                onClick={() => handleSaveQuotation('draft')}
                disabled={isSavingQuotation || nodes.length === 0}
                className="flex items-center justify-center rounded-full border border-slate-200 bg-white hover:bg-[#FAF9F6] px-3 py-2 font-semibold text-xs text-[#0F172A] transition-all active:scale-[0.99] disabled:opacity-40 disabled:pointer-events-none"
              >
                <Save className="mr-1.5 h-3.5 w-3.5 text-[#64748B]" />
                <span>Save Draft</span>
              </button>
            </div>

            {saveStatus && (
              <div className="flex items-center gap-1.5 text-xs text-emerald-800 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-full animate-in fade-in">
                <CheckCircle2 className="w-3.5 h-3.5 shrink-0 text-emerald-600" />
                <span className="text-[11px] truncate font-medium">{saveStatus}</span>
              </div>
            )}
          </div>
        </div>

        {/* The Agent "Brain" Display */}
        <div className="flex-1 flex flex-col rounded-2xl border border-slate-800 bg-[#12233F] overflow-hidden shadow-lg min-h-[190px]">
          <div className="flex items-center justify-between border-b border-slate-700/80 bg-[#0F172A] px-3.5 py-2">
            <div className="flex items-center">
              <Terminal className="mr-1.5 h-3.5 w-3.5 text-white" />
              <span className="text-[11px] font-mono font-bold text-white tracking-wider">TERMINAL LOG</span>
            </div>
            {isGenerating && (
              <span className="inline-flex items-center gap-1 text-[10px] font-mono text-cyan-300">
                <span className="w-1.5 h-1.5 rounded-full bg-cyan-300 animate-pulse" />
                RUNNING
              </span>
            )}
          </div>
          <div className="flex-1 overflow-y-auto p-3.5 font-mono text-[11px] text-slate-200 leading-relaxed scrollbar-thin scrollbar-thumb-slate-700">
            <pre className="whitespace-pre-wrap font-mono">
              {agentThoughts || '// Ready for operation.\n// Click "Auto-Draft with AI" to generate connected schedule.'}
            </pre>
          </div>
        </div>
      </div>

      {/* RIGHT SIDE: React Flow Canvas with Luxury Itinerary Nodes */}
      <div className="flex-1 relative h-full bg-[#FAF9F6]">
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onConnect={onConnect}
          nodeTypes={nodeTypes}
          fitView
        >
          <Background variant={BackgroundVariant.Dots} gap={24} size={1.5} color="#CBD5E1" />
          <Controls className="!bg-white !border-slate-200 !fill-[#0F172A] shadow-md rounded-2xl [&>button]:!bg-white [&>button]:!border-slate-200 hover:[&>button]:!bg-[#FAF9F6]" />
        </ReactFlow>

        {nodes.length === 0 && !isGenerating && (
          <div className="absolute inset-0 pointer-events-none flex flex-col items-center justify-center text-[#64748B] p-6">
            <div className="w-14 h-14 rounded-full bg-white border border-slate-200 flex items-center justify-center mb-3 text-[#0F172A] shadow-sm">
              <Sparkles className="w-6 h-6" />
            </div>
            <p className="text-sm font-bold text-[#0F172A]">Canvas Ready</p>
            <p className="text-xs text-[#64748B] max-w-sm text-center mt-1">
              Trip Request #{tripId.slice(0, 8)}... loaded. Use &quot;Auto-Draft with AI&quot; or connect nodes to draft the itinerary quotation.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

// React Flow requires the provider to wrap the hooks, and useSearchParams requires Suspense in Next.js
export default function ItineraryStudio() {
  return (
    <ReactFlowProvider>
      <Suspense fallback={
        <div className="flex h-screen w-full items-center justify-center bg-[#FAF9F6] text-[#64748B] font-mono text-xs">
          Loading Operator Studio...
        </div>
      }>
        <CanvasInner />
      </Suspense>
    </ReactFlowProvider>
  );
}

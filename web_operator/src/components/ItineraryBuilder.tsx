'use client';

import React, { useState, useEffect, useRef } from 'react';
import { 
  TripRequest, 
  Itinerary, 
  ItineraryNode, 
  ItineraryEdge, 
  GuideAssignment
} from '../lib/types';
import { dbService } from '../lib/dbService';
import { CanvasNodeCard } from './CanvasNodeCard';
import { CartDrawer } from './CartDrawer';
import { AgenticAiDrawer } from './AgenticAiDrawer';
import { NegotiationModal } from './NegotiationModal';
import { GuideAssignmentModal } from './GuideAssignmentModal';
import { 
  ArrowLeft, 
  Sparkles, 
  ShoppingCart, 
  Send, 
  SlidersHorizontal, 
  UserCheck, 
  Calendar, 
  ZoomIn, 
  ZoomOut, 
  Maximize2, 
  Plus
} from 'lucide-react';

interface ItineraryBuilderProps {
  request: TripRequest;
  onBackToDashboard: () => void;
}

export const ItineraryBuilder: React.FC<ItineraryBuilderProps> = ({
  request,
  onBackToDashboard,
}) => {
  const [itinerary, setItinerary] = useState<Itinerary | null>(null);
  const [nodes, setNodes] = useState<ItineraryNode[]>([]);
  const [edges, setEdges] = useState<ItineraryEdge[]>([]);
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null);

  // Drawers & Modals
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isAiOpen, setIsAiOpen] = useState(false);
  const [isNegotiationOpen, setIsNegotiationOpen] = useState(false);
  const [isGuideModalOpen, setIsGuideModalOpen] = useState(false);
  const [guideAssignment, setGuideAssignment] = useState<GuideAssignment | null>(null);

  // Canvas zoom & pan
  const [zoomLevel, setZoomLevel] = useState(1);
  const canvasRef = useRef<HTMLDivElement>(null);

  // Dragging state
  const [draggingNodeId, setDraggingNodeId] = useState<string | null>(null);
  const [dragOffset, setDragOffset] = useState<{ x: number; y: number }>({ x: 0, y: 0 });

  useEffect(() => {
    loadData();
  }, [request.id]);

  const loadData = async () => {
    let itin = await dbService.getItineraryForRequest(request.id);
    if (!itin) {
      const activeOp = await dbService.getActiveOperator();
      itin = {
        id: `itin-${request.id}`,
        request_id: request.id,
        operator_id: activeOp?.id || request.operator_id || null,
        version: 1,
        status: request.status === 'quoted' ? 'sent_to_user' : request.status === 'finalized' ? 'finalized' : 'draft',
        total_base_cost: 0,
        total_margin: 0,
        final_quotation_price: 0,
        created_at: new Date().toISOString()
      };
      await dbService.saveItinerary(itin);
    }

    const { nodes: loadedNodes, edges: loadedEdges } = await dbService.getNodesAndEdges(itin.id);
    setNodes(loadedNodes);
    setEdges(loadedEdges);
    recalculateTotals(loadedNodes, itin);
    setItinerary(itin);

    // Check guide assignment
    const assign = await dbService.getGuideAssignment(itin.id);
    if (assign) setGuideAssignment(assign);
  };

  const recalculateTotals = async (currentNodes: ItineraryNode[], currentItin?: Itinerary | null) => {
    const total_base_cost = currentNodes.reduce((sum, n) => sum + (n.base_cost || 0), 0);
    const total_margin = currentNodes.reduce((sum, n) => {
      const margin = (n.base_cost || 0) * ((n.margin_percentage || 0) / 100);
      return sum + margin;
    }, 0);
    const final_quotation_price = Number((total_base_cost + total_margin).toFixed(2));

    const updatedItin: Itinerary = {
      ...(currentItin || itinerary!),
      total_base_cost,
      total_margin: Number(total_margin.toFixed(2)),
      final_quotation_price,
    };

    setItinerary(updatedItin);
    await dbService.saveItinerary(updatedItin);
  };

  const handleUpdateNode = async (updated: ItineraryNode) => {
    const newNodes = nodes.map(n => n.id === updated.id ? updated : n);
    setNodes(newNodes);
    await dbService.saveNodesAndEdges(itinerary!.id, newNodes, edges);
    recalculateTotals(newNodes);
  };

  const handleDeleteNode = async (nodeId: string) => {
    const newNodes = nodes.filter(n => n.id !== nodeId);
    const newEdges = edges.filter(e => e.source_node_id !== nodeId && e.target_node_id !== nodeId);
    setNodes(newNodes);
    setEdges(newEdges);
    await dbService.saveNodesAndEdges(itinerary!.id, newNodes, newEdges);
    recalculateTotals(newNodes);
  };

  const handleAddNodeFromCart = async (nodePartial: Partial<ItineraryNode>) => {
    if (!itinerary) return;
    
    const maxX = nodes.reduce((max, n) => Math.max(max, n.ui_coordinates.x), 50);
    const newNode: ItineraryNode = {
      id: `node-${Date.now()}`,
      itinerary_id: itinerary.id,
      node_type: nodePartial.node_type || 'hotel',
      title: nodePartial.title || 'New Service Block',
      base_cost: nodePartial.base_cost || 300,
      margin_percentage: nodePartial.margin_percentage || 18,
      final_price: nodePartial.final_price || 354,
      ui_coordinates: { x: maxX + 300, y: 140 },
      ai_metadata: nodePartial.ai_metadata,
      details: nodePartial.details
    };

    const newNodes = [...nodes, newNode];
    const newEdges = [...edges];

    if (nodes.length > 0) {
      const prev = nodes[nodes.length - 1];
      newEdges.push({
        id: `e-${Date.now()}`,
        itinerary_id: itinerary.id,
        source_node_id: prev.id,
        target_node_id: newNode.id,
        edge_type: 'next_step',
        travel_time_minutes: 30
      });
    }

    setNodes(newNodes);
    setEdges(newEdges);
    await dbService.saveNodesAndEdges(itinerary.id, newNodes, newEdges);
    recalculateTotals(newNodes);
  };

  const handleApplyAiChanges = async (
    newNodes: ItineraryNode[],
    newEdges: ItineraryEdge[],
    reasoning: string[]
  ) => {
    setNodes(newNodes);
    setEdges(newEdges);
    if (itinerary) {
      const updatedItin = {
        ...itinerary,
        ai_context: {
          last_prompt: reasoning.join(' | '),
          agent_reasoning: reasoning,
        }
      };
      setItinerary(updatedItin);
      await dbService.saveNodesAndEdges(itinerary.id, newNodes, newEdges);
      recalculateTotals(newNodes, updatedItin);
    }
  };

  const handleStartDrag = (e: React.MouseEvent, node: ItineraryNode) => {
    e.stopPropagation();
    setDraggingNodeId(node.id);
    const rect = canvasRef.current?.getBoundingClientRect();
    if (rect) {
      setDragOffset({
        x: (e.clientX - rect.left) / zoomLevel - node.ui_coordinates.x,
        y: (e.clientY - rect.top) / zoomLevel - node.ui_coordinates.y,
      });
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!draggingNodeId || !canvasRef.current) return;
    const rect = canvasRef.current.getBoundingClientRect();
    const newX = Math.max(20, Math.round((e.clientX - rect.left) / zoomLevel - dragOffset.x));
    const newY = Math.max(20, Math.round((e.clientY - rect.top) / zoomLevel - dragOffset.y));

    setNodes(prev => prev.map(n => n.id === draggingNodeId ? {
      ...n,
      ui_coordinates: { x: newX, y: newY }
    } : n));
  };

  const handleMouseUp = async () => {
    if (draggingNodeId && itinerary) {
      await dbService.saveNodesAndEdges(itinerary.id, nodes, edges);
      setDraggingNodeId(null);
    }
  };

  const handleSendQuotation = async () => {
    if (!itinerary) return;
    const activeOp = await dbService.getActiveOperator();
    const resolvedOpId = (activeOp?.id && activeOp.id !== '00000000-0000-0000-0000-000000000000' && activeOp.id !== '11111111-1111-1111-1111-111111111111') 
      ? activeOp.id 
      : (itinerary.operator_id && itinerary.operator_id !== '00000000-0000-0000-0000-000000000000' && itinerary.operator_id !== '11111111-1111-1111-1111-111111111111')
        ? itinerary.operator_id
        : 'dc3d36fb-0502-432a-920d-c3daa95c981a';

    const updatedItin: Itinerary = {
      ...itinerary,
      operator_id: resolvedOpId,
      status: 'sent_to_user',
      version: itinerary.version + 1,
    };
    setItinerary(updatedItin);
    await dbService.saveItinerary(updatedItin);
    await dbService.updateRequestStatus(request.id, 'quoted');

    try {
      await fetch('/api/quotations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-operator-id': resolvedOpId
        },
        body: JSON.stringify({
          trip_request_id: request.id,
          operator_id: resolvedOpId,
          title: `${request.destination} Customized Itinerary`,
          status: 'sent',
          currency: 'INR',
          nodes,
          edges
        })
      });
    } catch (err) {
      console.warn('Failed to sync quotation to quotations table:', err);
    }

    alert(`Quotation of ₹${itinerary.final_quotation_price.toLocaleString()} saved in database and marked as Quoted.`);
  };

  const handleApplyNegotiatedPrice = async (newNodes: ItineraryNode[]) => {
    setNodes(newNodes);
    await dbService.saveNodesAndEdges(itinerary!.id, newNodes, edges);
    recalculateTotals(newNodes);
    setIsNegotiationOpen(false);
  };

  const handleFinalizeItinerary = async () => {
    if (!itinerary) return;
    const updated: Itinerary = {
      ...itinerary,
      status: 'finalized',
    };
    setItinerary(updated);
    await dbService.saveItinerary(updated);
    await dbService.updateRequestStatus(request.id, 'finalized');
    setIsNegotiationOpen(false);
    setIsGuideModalOpen(true);
  };

  const handleAssignmentComplete = (assignment: GuideAssignment) => {
    setGuideAssignment(assignment);
  };

  const targetMaxBudget = request.budget_range[1] || 6000;
  const currentQuote = itinerary?.final_quotation_price || 0;
  const isWithinBudget = currentQuote <= targetMaxBudget;
  const marginPct = itinerary && itinerary.total_base_cost > 0
    ? ((itinerary.total_margin / itinerary.total_base_cost) * 100).toFixed(1)
    : '0.0';

  return (
    <div className="flex flex-col h-[calc(100vh-3.25rem)] bg-[#09090b] overflow-hidden select-none">
      {/* Workflow Top Header */}
      <div className="h-12 border-b border-zinc-800 bg-[#121215] px-4 flex items-center justify-between z-20">
        <div className="flex items-center gap-3">
          <button
            onClick={onBackToDashboard}
            className="flex items-center gap-1 px-2.5 py-1 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-xs font-medium transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Dashboard</span>
          </button>

          <div className="h-4 w-[1px] bg-zinc-800" />

          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-xs font-bold text-white truncate max-w-xs sm:max-w-md">
                {request.destination}
              </h2>
              <span className="text-[10px] font-mono px-1.5 py-0.2 rounded bg-zinc-800 text-zinc-300 border border-zinc-700">
                {request.status.toUpperCase()}
              </span>
            </div>
            <div className="flex items-center gap-2 text-[10px] text-zinc-400">
              <span className="flex items-center gap-1">
                <Calendar className="w-2.5 h-2.5 text-zinc-500" />
                {request.travel_dates}
              </span>
              <span>•</span>
              <span>
                Budget: ${request.budget_range[0]?.toLocaleString()} - ${request.budget_range[1]?.toLocaleString()}
              </span>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-2 text-xs">
          <button
            onClick={() => setIsCartOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium transition-colors border border-zinc-700"
          >
            <ShoppingCart className="w-3.5 h-3.5 text-zinc-400" />
            <span>Inventory Cart</span>
          </button>

          <button
            onClick={() => setIsAiOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium transition-colors border border-zinc-700"
          >
            <Sparkles className="w-3.5 h-3.5 text-zinc-400" />
            <span>AI Copilot</span>
          </button>

          <button
            onClick={() => setIsNegotiationOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium transition-colors border border-zinc-700"
          >
            <SlidersHorizontal className="w-3.5 h-3.5 text-zinc-400" />
            <span>Negotiation</span>
          </button>

          <button
            onClick={() => setIsGuideModalOpen(true)}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border font-medium transition-colors ${
              guideAssignment
                ? 'bg-zinc-800 text-emerald-300 border-zinc-700'
                : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-300 border-zinc-700'
            }`}
          >
            <UserCheck className="w-3.5 h-3.5 text-zinc-400" />
            <span>{guideAssignment ? `Guide: ${guideAssignment.guide?.first_name || 'Assigned'}` : 'Assign Guide'}</span>
          </button>
        </div>
      </div>

      {/* Canvas Area */}
      <div 
        ref={canvasRef}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        className="flex-1 relative overflow-auto canvas-grid"
      >
        {/* Controls */}
        <div className="absolute top-3 left-3 z-10 flex items-center gap-1 bg-zinc-900 border border-zinc-800 rounded-lg p-1 shadow">
          <button
            onClick={() => setZoomLevel(prev => Math.min(prev + 0.1, 1.5))}
            className="p-1 rounded text-zinc-400 hover:text-white"
            title="Zoom In"
          >
            <ZoomIn className="w-3.5 h-3.5" />
          </button>
          <span className="text-[10px] font-mono text-zinc-400 px-1">
            {Math.round(zoomLevel * 100)}%
          </span>
          <button
            onClick={() => setZoomLevel(prev => Math.max(prev - 0.1, 0.6))}
            className="p-1 rounded text-zinc-400 hover:text-white"
            title="Zoom Out"
          >
            <ZoomOut className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={() => setZoomLevel(1)}
            className="p-1 rounded text-zinc-400 hover:text-white"
            title="Reset"
          >
            <Maximize2 className="w-3 h-3" />
          </button>
        </div>

        {/* Empty Canvas Prompt */}
        {nodes.length === 0 && (
          <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
            <div className="p-6 rounded-xl bg-zinc-900/90 border border-zinc-800 text-center max-w-sm pointer-events-auto">
              <h3 className="text-xs font-semibold text-white mb-1">Canvas is Ready</h3>
              <p className="text-[11px] text-zinc-400 mb-3">
                Use the Inventory Cart to add your contracted hotels, tours, and fleet, or open the AI Copilot to draft a plan.
              </p>
              <div className="flex justify-center gap-2">
                <button
                  onClick={() => setIsCartOpen(true)}
                  className="px-3 py-1.5 bg-zinc-800 hover:bg-zinc-700 text-zinc-200 text-xs font-medium rounded-lg border border-zinc-700"
                >
                  + Add from Inventory
                </button>
                <button
                  onClick={() => setIsAiOpen(true)}
                  className="px-3 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 text-xs font-semibold rounded-lg"
                >
                  Auto-Draft with AI
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Scaled Canvas Container */}
        <div
          style={{
            transform: `scale(${zoomLevel})`,
            transformOrigin: '0 0',
            width: '2800px',
            height: '1800px',
            position: 'relative',
          }}
        >
          {/* SVG Connection Lines */}
          <svg className="absolute inset-0 w-full h-full pointer-events-none z-0">
            {edges.map((edge) => {
              const src = nodes.find(n => n.id === edge.source_node_id);
              const tgt = nodes.find(n => n.id === edge.target_node_id);
              if (!src || !tgt) return null;

              const sx = src.ui_coordinates.x + 288;
              const sy = src.ui_coordinates.y + 100;
              const tx = tgt.ui_coordinates.x;
              const ty = tgt.ui_coordinates.y + 100;

              const dx = (tx - sx) * 0.5;
              const pathD = `M ${sx} ${sy} C ${sx + dx} ${sy}, ${tx - dx} ${ty}, ${tx} ${ty}`;
              const midX = (sx + tx) / 2;
              const midY = (sy + ty) / 2;

              return (
                <g key={edge.id}>
                  <path
                    d={pathD}
                    fill="none"
                    stroke="#52525b"
                    strokeWidth="1.5"
                    strokeDasharray={edge.edge_type === 'alternative_option' ? '4,4' : 'none'}
                  />
                  {(edge.travel_time_minutes || edge.distance_km) && (
                    <foreignObject
                      x={midX - 35}
                      y={midY - 12}
                      width="70"
                      height="24"
                      className="overflow-visible"
                    >
                      <div className="px-1.5 py-0.5 rounded bg-zinc-900 border border-zinc-700 text-[9px] font-mono text-zinc-300 text-center">
                        {edge.travel_time_minutes ? `${edge.travel_time_minutes}m` : ''}
                        {edge.distance_km ? ` • ${edge.distance_km}km` : ''}
                      </div>
                    </foreignObject>
                  )}
                </g>
              );
            })}
          </svg>

          {/* Nodes */}
          {nodes.map((node) => (
            <CanvasNodeCard
              key={node.id}
              node={node}
              isSelected={selectedNodeId === node.id}
              onSelect={() => setSelectedNodeId(node.id)}
              onUpdate={handleUpdateNode}
              onDelete={handleDeleteNode}
              onStartDrag={handleStartDrag}
            />
          ))}
        </div>
      </div>

      {/* Floating Bottom Financial Dock */}
      <div className="h-14 border-t border-zinc-800 bg-[#121215] px-4 sm:px-6 flex items-center justify-between z-20">
        <div className="flex items-center gap-5 text-xs">
          <div>
            <span className="text-[10px] text-zinc-500 block">Base Cost</span>
            <span className="font-semibold text-zinc-300 font-mono">
              ${itinerary?.total_base_cost.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="h-6 w-[1px] bg-zinc-800" />

          <div>
            <span className="text-[10px] text-zinc-500 block">Margin ({marginPct}%)</span>
            <span className="font-semibold text-zinc-300 font-mono">
              +${itinerary?.total_margin.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="h-6 w-[1px] bg-zinc-800" />

          <div>
            <span className="text-[10px] text-zinc-500 block">Quotation Price</span>
            <span className="font-bold text-sm text-white font-mono">
              ${itinerary?.final_quotation_price.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="hidden md:block pl-3 border-l border-zinc-800">
            <span className={`px-2 py-0.5 rounded text-[10px] font-medium ${
              isWithinBudget ? 'bg-zinc-800 text-emerald-400' : 'bg-zinc-800 text-rose-400'
            }`}>
              {isWithinBudget ? 'Within Budget' : 'Exceeds Budget'}
            </span>
          </div>
        </div>

        <button
          onClick={handleSendQuotation}
          className="flex items-center gap-1.5 px-4 py-2 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold text-xs rounded-lg transition-colors shadow-sm"
        >
          <Send className="w-3.5 h-3.5" />
          <span>Send Quotation</span>
        </button>
      </div>

      {/* Modals & Drawers */}
      <CartDrawer
        isOpen={isCartOpen}
        onClose={() => setIsCartOpen(false)}
        onAddNodeToCanvas={handleAddNodeFromCart}
        itineraryId={itinerary?.id || 'itin-active'}
      />

      {itinerary && (
        <AgenticAiDrawer
          isOpen={isAiOpen}
          onClose={() => setIsAiOpen(false)}
          request={request}
          itineraryId={itinerary.id}
          nodes={nodes}
          edges={edges}
          onApplyAiChanges={handleApplyAiChanges}
        />
      )}

      {itinerary && (
        <NegotiationModal
          isOpen={isNegotiationOpen}
          onClose={() => setIsNegotiationOpen(false)}
          itinerary={itinerary}
          request={request}
          nodes={nodes}
          onApplyNegotiatedPrice={handleApplyNegotiatedPrice}
          onFinalizeItinerary={handleFinalizeItinerary}
        />
      )}

      {itinerary && (
        <GuideAssignmentModal
          isOpen={isGuideModalOpen}
          onClose={() => setIsGuideModalOpen(false)}
          itinerary={itinerary}
          request={request}
          onAssignmentComplete={handleAssignmentComplete}
        />
      )}
    </div>
  );
};

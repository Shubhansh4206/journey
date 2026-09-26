'use client';

import React, { useState, useCallback, useMemo } from 'react';
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
  NodeProps,
  Handle,
  Position,
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
  Save, 
  Clock, 
  MapPin, 
  BedDouble, 
  Plane, 
  Car, 
  ArrowLeft,
  CheckCircle2,
  RefreshCw
} from 'lucide-react';
import Link from 'next/link';

// --- 1. CUSTOM NODE COMPONENTS ---
// These dictate how the JSON payload visually renders on the canvas

const HotelNode = ({ data }: NodeProps<Node>) => (
  <div className="w-64 rounded-xl border-2 border-blue-400/80 bg-white dark:bg-slate-900 p-4 shadow-lg shadow-blue-500/10 transition-all hover:shadow-blue-500/20">
    <Handle type="target" position={Position.Top} className="!h-3 !w-3 !bg-blue-500" />
    <div className="flex items-center justify-between">
      <span className="rounded-full bg-blue-100 dark:bg-blue-950/80 px-2.5 py-0.5 text-xs font-bold text-blue-700 dark:text-blue-300">
        Day {data.day !== undefined ? (data.day as number) : 1}
      </span>
      <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
        <Clock className="mr-1 h-3.5 w-3.5" />
        {data.time ? String(data.time) : 'Overnight'}
      </div>
    </div>
    <div className="mt-3 flex items-center font-bold text-slate-900 dark:text-slate-100">
      <BedDouble className="mr-2 h-5 w-5 shrink-0 text-blue-500" />
      <span className="truncate">{data.title ? String(data.title) : 'Hotel Stay'}</span>
    </div>
    {Boolean(data.cost || data.price) && (
      <div className="mt-2 text-xs font-medium text-blue-600 dark:text-blue-400">
        ₹{Number(data.cost || data.price).toLocaleString()}
      </div>
    )}
    <Handle type="source" position={Position.Bottom} className="!h-3 !w-3 !bg-blue-500" />
  </div>
);

const PlaceNode = ({ data }: NodeProps<Node>) => (
  <div className="w-64 rounded-xl border-2 border-emerald-400/80 bg-white dark:bg-slate-900 p-4 shadow-lg shadow-emerald-500/10 transition-all hover:shadow-emerald-500/20">
    <Handle type="target" position={Position.Top} className="!h-3 !w-3 !bg-emerald-500" />
    <div className="flex items-center justify-between">
      <span className="rounded-full bg-emerald-100 dark:bg-emerald-950/80 px-2.5 py-0.5 text-xs font-bold text-emerald-700 dark:text-emerald-300">
        Day {data.day !== undefined ? (data.day as number) : 1}
      </span>
      <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
        <Clock className="mr-1 h-3.5 w-3.5" />
        {data.time ? String(data.time) : 'Afternoon'}
      </div>
    </div>
    <div className="mt-3 flex items-center font-bold text-slate-900 dark:text-slate-100">
      <MapPin className="mr-2 h-5 w-5 shrink-0 text-emerald-500" />
      <span className="truncate">{data.title ? String(data.title) : 'Sightseeing Place'}</span>
    </div>
    {Boolean(data.cost || data.price) && (
      <div className="mt-2 text-xs font-medium text-emerald-600 dark:text-emerald-400">
        ₹{Number(data.cost || data.price).toLocaleString()}
      </div>
    )}
    <Handle type="source" position={Position.Bottom} className="!h-3 !w-3 !bg-emerald-500" />
  </div>
);

const ActivityNode = ({ data }: NodeProps<Node>) => (
  <div className="w-64 rounded-xl border-2 border-purple-400/80 bg-white dark:bg-slate-900 p-4 shadow-lg shadow-purple-500/10 transition-all hover:shadow-purple-500/20">
    <Handle type="target" position={Position.Top} className="!h-3 !w-3 !bg-purple-500" />
    <div className="flex items-center justify-between">
      <span className="rounded-full bg-purple-100 dark:bg-purple-950/80 px-2.5 py-0.5 text-xs font-bold text-purple-700 dark:text-purple-300">
        Day {data.day !== undefined ? (data.day as number) : 1}
      </span>
      <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
        <Clock className="mr-1 h-3.5 w-3.5" />
        {data.time ? String(data.time) : 'Morning'}
      </div>
    </div>
    <div className="mt-3 flex items-center font-bold text-slate-900 dark:text-slate-100">
      <Sparkles className="mr-2 h-5 w-5 shrink-0 text-purple-500" />
      <span className="truncate">{data.title ? String(data.title) : 'Adventure Activity'}</span>
    </div>
    {Boolean(data.cost || data.price) && (
      <div className="mt-2 text-xs font-medium text-purple-600 dark:text-purple-400">
        ₹{Number(data.cost || data.price).toLocaleString()}
      </div>
    )}
    <Handle type="source" position={Position.Bottom} className="!h-3 !w-3 !bg-purple-500" />
  </div>
);

const FlightNode = ({ data }: NodeProps<Node>) => (
  <div className="w-64 rounded-xl border-2 border-sky-400/80 bg-white dark:bg-slate-900 p-4 shadow-lg shadow-sky-500/10 transition-all hover:shadow-sky-500/20">
    <Handle type="target" position={Position.Top} className="!h-3 !w-3 !bg-sky-500" />
    <div className="flex items-center justify-between">
      <span className="rounded-full bg-sky-100 dark:bg-sky-950/80 px-2.5 py-0.5 text-xs font-bold text-sky-700 dark:text-sky-300">
        Day {data.day !== undefined ? (data.day as number) : 1}
      </span>
      <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
        <Clock className="mr-1 h-3.5 w-3.5" />
        {data.time ? String(data.time) : 'Departure'}
      </div>
    </div>
    <div className="mt-3 flex items-center font-bold text-slate-900 dark:text-slate-100">
      <Plane className="mr-2 h-5 w-5 shrink-0 text-sky-500" />
      <span className="truncate">{data.title ? String(data.title) : 'Flight'}</span>
    </div>
    <Handle type="source" position={Position.Bottom} className="!h-3 !w-3 !bg-sky-500" />
  </div>
);

const TransferNode = ({ data }: NodeProps<Node>) => (
  <div className="w-64 rounded-xl border-2 border-amber-400/80 bg-white dark:bg-slate-900 p-4 shadow-lg shadow-amber-500/10 transition-all hover:shadow-amber-500/20">
    <Handle type="target" position={Position.Top} className="!h-3 !w-3 !bg-amber-500" />
    <div className="flex items-center justify-between">
      <span className="rounded-full bg-amber-100 dark:bg-amber-950/80 px-2.5 py-0.5 text-xs font-bold text-amber-700 dark:text-amber-300">
        Day {data.day !== undefined ? (data.day as number) : 1}
      </span>
      <div className="flex items-center text-xs text-slate-500 dark:text-slate-400">
        <Clock className="mr-1 h-3.5 w-3.5" />
        {data.time ? String(data.time) : 'Transit'}
      </div>
    </div>
    <div className="mt-3 flex items-center font-bold text-slate-900 dark:text-slate-100">
      <Car className="mr-2 h-5 w-5 shrink-0 text-amber-500" />
      <span className="truncate">{data.title ? String(data.title) : 'Transfer'}</span>
    </div>
    <Handle type="source" position={Position.Bottom} className="!h-3 !w-3 !bg-amber-500" />
  </div>
);

// --- 2. MAIN CANVAS COMPONENT ---
function CanvasInner() {
  const [nodes, setNodes] = useState<Node[]>([]);
  const [edges, setEdges] = useState<Edge[]>([]);
  const [isGenerating, setIsGenerating] = useState(false);
  const [agentThoughts, setAgentThoughts] = useState<string>('');
  
  // Trip request ID provided for testing
  const [tripId, setTripId] = useState<string>('0ec1aea6-9bb9-45a4-963a-e2c994ff7997');
  const [saveStatus, setSaveStatus] = useState<string | null>(null);

  const { fitView } = useReactFlow();

  // Register the custom nodes with React Flow
  const nodeTypes = useMemo(() => ({
    hotelNode: HotelNode,
    placeNode: PlaceNode,
    activityNode: ActivityNode,
    flightNode: FlightNode,
    transferNode: TransferNode,
    // Aliases to handle common naming
    hotel: HotelNode,
    place: PlaceNode,
    activity: ActivityNode,
    flight: FlightNode,
    transfer: TransferNode
  }), []);

  // Standard React Flow dragging & connecting logic
  const onNodesChange = useCallback((changes: NodeChange[]) => setNodes((nds) => applyNodeChanges(changes, nds)), []);
  const onEdgesChange = useCallback((changes: EdgeChange[]) => setEdges((eds) => applyEdgeChanges(changes, eds)), []);
  const onConnect = useCallback((connection: Connection) => setEdges((eds) => addEdge({ ...connection, animated: true, type: 'smoothstep' }, eds)), []);

  // --- TRIGGER THE AGENTIC AI ---
  const handleAutoDraft = async () => {
    if (!tripId.trim()) {
      alert('Please enter a valid trip_request_id');
      return;
    }

    setIsGenerating(true);
    setSaveStatus(null);
    setAgentThoughts('Agent initialized. Connecting to tools and fetching trip request context...\n');
    
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
      
      // Inject the AI's data into the canvas state
      const rawNodes = result.data?.nodes || result.nodes || [];
      const rawEdges = result.data?.edges || result.edges || [];
      
      // Ensure all nodes have valid position and type mappings
      const formattedNodes: Node[] = rawNodes.map((node: any, idx: number) => {
        let type = node.type || 'placeNode';
        // Map backend types if they don't have 'Node' suffix
        if (type === 'hotel') type = 'hotelNode';
        else if (type === 'place') type = 'placeNode';
        else if (type === 'activity') type = 'activityNode';
        else if (type === 'flight') type = 'flightNode';
        else if (type === 'transfer') type = 'transferNode';

        return {
          id: String(node.id || `node-${idx + 1}`),
          type,
          position: node.position && typeof node.position.x === 'number' 
            ? node.position 
            : { x: 250, y: idx * 140 },
          data: node.data || {
            title: node.title || 'Itinerary Item',
            day: node.day || 1,
            time: node.time || 'TBD',
            cost: node.cost || node.price || 0,
            ...node
          }
        };
      });

      const formattedEdges: Edge[] = rawEdges.map((edge: any, idx: number) => ({
        id: String(edge.id || `edge-${idx + 1}`),
        source: String(edge.source || edge.source_node_id),
        target: String(edge.target || edge.target_node_id),
        animated: edge.animated ?? true,
        type: edge.type || 'smoothstep',
        ...edge
      }));

      setNodes(formattedNodes);
      setEdges(formattedEdges);
      
      // Normalize thoughts whether array of objects ({ type, text }), string, or object
      let parsedThoughts = '';
      if (typeof result.agent_thoughts === 'string') {
        parsedThoughts = result.agent_thoughts;
      } else if (Array.isArray(result.agent_thoughts)) {
        parsedThoughts = result.agent_thoughts
          .map((item: any) => {
            if (typeof item === 'string') return item;
            if (item && item.text) return item.text;
            return JSON.stringify(item);
          })
          .join('\n');
      } else if (result.agent_thoughts) {
        parsedThoughts = JSON.stringify(result.agent_thoughts, null, 2);
      } else {
        parsedThoughts = 'Generated draft successfully with ' + formattedNodes.length + ' itinerary nodes.';
      }

      setAgentThoughts(parsedThoughts);

      // Re-center the camera to look at the newly generated graph
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

  // --- FINALIZE AND SAVE TO DB ---
  const handleSave = () => {
    // Bulk INSERT or save payload to Supabase / local state
    console.log('Saving these nodes to Supabase:', nodes);
    console.log('Saving these edges to Supabase:', edges);
    setSaveStatus(`Saved ${nodes.length} nodes & ${edges.length} edges successfully!`);
    alert(`Draft saved to database! Check your console to see the JSON payload (${nodes.length} nodes, ${edges.length} edges).`);
  };

  return (
    <div className="flex h-screen w-full bg-slate-950 text-slate-100 overflow-hidden">
      
      {/* LEFT SIDEBAR: Agent Terminal & Controls */}
      <div className="w-[420px] border-r border-slate-800 bg-slate-900/95 p-6 flex flex-col justify-between shadow-2xl z-10">
        <div>
          {/* Header navigation & title */}
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="flex items-center gap-2">
                <span className="h-2 w-2 rounded-full bg-emerald-400 animate-ping" />
                <h2 className="text-lg font-bold text-white tracking-tight">Itinerary Studio</h2>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">Agentic AI Canvas Sandbox</p>
            </div>

            <Link
              href="/"
              className="flex items-center gap-1 text-xs text-slate-400 hover:text-white px-2.5 py-1.5 rounded-lg border border-slate-700 bg-slate-800/80 transition-colors"
            >
              <ArrowLeft className="w-3.5 h-3.5" />
              <span>Dashboard</span>
            </Link>
          </div>

          {/* Trip Request ID input */}
          <div className="mb-4 bg-slate-950/60 p-3 rounded-lg border border-slate-800">
            <label className="block text-[11px] font-mono uppercase text-slate-400 mb-1.5 font-semibold">
              Trip Request UUID
            </label>
            <input
              type="text"
              value={tripId}
              onChange={(e) => setTripId(e.target.value)}
              placeholder="e.g. 0ec1aea6-9bb9-45a4-963a-e2c994ff7997"
              className="w-full text-xs font-mono bg-slate-900 border border-slate-700 rounded px-2.5 py-1.5 text-slate-200 focus:outline-none focus:border-indigo-500 selection:bg-indigo-500/40"
            />
          </div>

          {/* Action buttons */}
          <div className="flex flex-col gap-2.5 mb-5">
            <button
              onClick={handleAutoDraft}
              disabled={isGenerating}
              className="flex items-center justify-center rounded-lg bg-gradient-to-r from-indigo-600 to-violet-600 px-4 py-3 font-semibold text-white shadow-lg shadow-indigo-600/25 transition-all hover:from-indigo-500 hover:to-violet-500 active:scale-[0.99] disabled:opacity-50 disabled:pointer-events-none"
            >
              {isGenerating ? (
                <span className="flex items-center gap-2">
                  <RefreshCw className="w-4 h-4 animate-spin text-white" />
                  <span>Agent Thinking & Drafting...</span>
                </span>
              ) : (
                <span className="flex items-center">
                  <Sparkles className="mr-2 h-4 w-4 text-indigo-200" />
                  <span>Auto-Draft with AI</span>
                </span>
              )}
            </button>
            
            <button
              onClick={handleSave}
              disabled={isGenerating || nodes.length === 0}
              className="flex items-center justify-center rounded-lg border border-slate-700 bg-slate-800/80 px-4 py-2.5 font-semibold text-slate-200 transition-all hover:bg-slate-800 hover:border-slate-600 active:scale-[0.99] disabled:opacity-40 disabled:pointer-events-none"
            >
              <Save className="mr-2 h-4 w-4 text-emerald-400" />
              <span>Save & Finalize ({nodes.length} Nodes)</span>
            </button>

            {saveStatus && (
              <div className="flex items-center gap-1.5 text-xs text-emerald-400 bg-emerald-950/40 border border-emerald-900/60 px-3 py-1.5 rounded-md">
                <CheckCircle2 className="w-3.5 h-3.5 shrink-0" />
                <span>{saveStatus}</span>
              </div>
            )}
          </div>
        </div>

        {/* The Agent "Brain" Display */}
        <div className="flex-1 flex flex-col rounded-xl border border-slate-800 bg-slate-950 overflow-hidden shadow-2xl min-h-[300px]">
          <div className="flex items-center justify-between border-b border-slate-800/80 bg-slate-900 px-4 py-2">
            <div className="flex items-center">
              <Terminal className="mr-2 h-3.5 w-3.5 text-emerald-400" />
              <span className="text-xs font-mono font-bold text-emerald-400 tracking-wider">AGENT LOG</span>
            </div>
            {isGenerating && (
              <span className="inline-flex items-center gap-1 text-[10px] font-mono text-amber-400">
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
                STREAMING
              </span>
            )}
          </div>
          <div className="flex-1 overflow-y-auto p-4 font-mono text-xs text-emerald-300 leading-relaxed scrollbar-thin scrollbar-thumb-slate-800">
            <pre className="whitespace-pre-wrap font-mono">
              {agentThoughts || '// Waiting for task... Click "Auto-Draft with AI" to trigger agent.'}
            </pre>
          </div>
        </div>
      </div>

      {/* RIGHT SIDE: The React Flow Canvas */}
      <div className="flex-1 relative h-full bg-[#0a0f1d]">
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onConnect={onConnect}
          nodeTypes={nodeTypes}
          fitView
        >
          <Background variant={BackgroundVariant.Dots} gap={20} size={1.2} color="#334155" />
          <Controls className="!bg-slate-900 !border-slate-800 !fill-slate-200 [&>button]:!bg-slate-800 [&>button]:!border-slate-700 hover:[&>button]:!bg-slate-700" />
        </ReactFlow>

        {nodes.length === 0 && !isGenerating && (
          <div className="absolute inset-0 pointer-events-none flex flex-col items-center justify-center text-slate-500 p-6">
            <div className="w-14 h-14 rounded-2xl bg-slate-900/80 border border-slate-800 flex items-center justify-center mb-3 text-slate-400">
              <Sparkles className="w-7 h-7 text-indigo-400" />
            </div>
            <p className="text-sm font-semibold text-slate-300">Canvas Ready for Auto-Draft</p>
            <p className="text-xs text-slate-500 max-w-sm text-center mt-1">
              Click &quot;Auto-Draft with AI&quot; on the left to invoke the Gemini backend agent with Trip Request #{tripId.slice(0, 8)}...
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

// React Flow requires the provider to wrap the hooks
export default function ItineraryStudio() {
  return (
    <ReactFlowProvider>
      <CanvasInner />
    </ReactFlowProvider>
  );
}

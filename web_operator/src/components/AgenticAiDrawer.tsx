'use client';

import React, { useState } from 'react';
import { TripRequest, ItineraryNode, ItineraryEdge } from '../lib/types';
import { executeAiPrompt, autoDraftItineraryForRequest } from '../lib/agenticAi';
import { 
  X, 
  Sparkles, 
  Send, 
  CheckCircle2, 
  Loader2, 
  Zap, 
  Sliders, 
  Layers,
  ArrowRight,
  RefreshCw
} from 'lucide-react';

interface AgenticAiDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  request: TripRequest;
  itineraryId: string;
  nodes: ItineraryNode[];
  edges: ItineraryEdge[];
  onApplyAiChanges: (newNodes: ItineraryNode[], newEdges: ItineraryEdge[], reasoning: string[]) => void;
}

export const AgenticAiDrawer: React.FC<AgenticAiDrawerProps> = ({
  isOpen,
  onClose,
  request,
  itineraryId,
  nodes,
  edges,
  onApplyAiChanges,
}) => {
  const [prompt, setPrompt] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [activeReasoning, setActiveReasoning] = useState<string[]>([]);
  const [historyLogs, setHistoryLogs] = useState<Array<{
    prompt: string;
    action: string;
    summary: string;
    timestamp: string;
  }>>([]);

  if (!isOpen) return null;

  const handleSendPrompt = async (customPrompt?: string) => {
    const textToRun = customPrompt || prompt;
    if (!textToRun.trim() || isProcessing) return;

    setIsProcessing(true);
    setActiveReasoning(['Parsing instruction and active graph topology...']);

    setTimeout(() => {
      setActiveReasoning(prev => [...prev, 'Evaluating constraints: destination, budget, and contracted inventory...']);
    }, 250);

    setTimeout(() => {
      setActiveReasoning(prev => [...prev, 'Applying coordinate layout and price calculations...']);
    }, 500);

    setTimeout(() => {
      const result = executeAiPrompt(textToRun, nodes, edges, request, itineraryId);
      
      setActiveReasoning(result.reasoning);
      onApplyAiChanges(result.updatedNodes, result.updatedEdges, result.reasoning);

      setHistoryLogs(prev => [
        {
          prompt: textToRun,
          action: result.suggestedAction,
          summary: result.summaryMessage,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
        ...prev,
      ]);

      setIsProcessing(false);
      if (!customPrompt) setPrompt('');
    }, 800);
  };

  const handleAutoDraft = () => {
    setIsProcessing(true);
    setActiveReasoning([
      `Analyzing traveler request: ${request.destination}`,
      `Budget bracket: $${request.budget_range[0]} - $${request.budget_range[1]}`,
      'Selecting optimal flight routes and contracted accommodations...',
      'Synthesizing chronological edges and computing operator margins...'
    ]);

    setTimeout(() => {
      const { nodes: newNodes, edges: newEdges } = autoDraftItineraryForRequest(request, itineraryId);
      onApplyAiChanges(newNodes, newEdges, [
        `Generated complete itinerary matching ${request.destination}`,
        'Balanced cultural excursions with luxury ryokan and rail transit.',
        'Calculated base pricing with optimal margins.'
      ]);

      setHistoryLogs(prev => [
        {
          prompt: 'Auto-draft complete itinerary',
          action: 'Itinerary Synthesized',
          summary: `Generated ${newNodes.length} nodes and ${newEdges.length} sequence edges.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
        ...prev,
      ]);

      setIsProcessing(false);
    }, 850);
  };

  const quickPrompts = [
    { label: 'Auto-draft itinerary from brief', action: handleAutoDraft, icon: Zap },
    { label: 'Standardize all margins to 18%', prompt: 'Standardize all item margins to 18%', icon: Sliders },
    { label: 'Connect all nodes in travel sequence', prompt: 'Connect all nodes in chronological sequence', icon: Layers },
    { label: 'Optimize pricing to match traveler budget', prompt: 'Optimize pricing to fit traveler budget', icon: RefreshCw },
  ];

  return (
    <>
      <div 
        onClick={onClose}
        className="fixed inset-0 z-40 backdrop-blur-overlay bg-black/60 transition-opacity" 
      />
      <div className="fixed inset-y-0 right-0 z-50 w-full sm:w-[440px] bg-[#121215] border-l border-zinc-800 shadow-2xl flex flex-col spring-drawer animate-in slide-in-from-right duration-300">
        {/* Header */}
        <div className="p-4 border-b border-zinc-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-6 h-6 rounded bg-zinc-800 flex items-center justify-center text-zinc-300">
              <Sparkles className="w-3.5 h-3.5 text-cyan-400" />
            </div>
            <div>
              <h2 className="text-xs font-bold text-white">AI Itinerary Copilot</h2>
              <p className="text-[10px] text-zinc-500">Autonomous planning and margin calculations.</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="btn-interactive p-1 rounded text-zinc-500 hover:text-white"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 text-xs">
        <div>
          <span className="text-[10px] font-semibold uppercase tracking-wider text-zinc-500 block mb-2">
            Quick Actions
          </span>
          <div className="space-y-1.5">
            {quickPrompts.map((qp, idx) => {
              const Icon = qp.icon;
              return (
                <button
                  key={idx}
                  onClick={() => qp.action ? qp.action() : handleSendPrompt(qp.prompt)}
                  disabled={isProcessing}
                  className="w-full flex items-center justify-between p-2 rounded-lg bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 text-zinc-200 text-xs font-medium transition-colors text-left group"
                >
                  <div className="flex items-center gap-2">
                    <Icon className="w-3.5 h-3.5 text-zinc-400" />
                    <span>{qp.label}</span>
                  </div>
                  <ArrowRight className="w-3 h-3 text-zinc-600 group-hover:text-zinc-300" />
                </button>
              );
            })}
          </div>
        </div>

        {/* Live Reasoning */}
        {(isProcessing || activeReasoning.length > 0) && (
          <div className="p-3 rounded-lg bg-zinc-950 border border-zinc-800 space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5 text-xs font-semibold text-zinc-200">
                {isProcessing ? (
                  <Loader2 className="w-3.5 h-3.5 text-zinc-400 animate-spin" />
                ) : (
                  <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                )}
                <span>{isProcessing ? 'Executing...' : 'Execution Output'}</span>
              </div>
              <span className="text-[10px] font-mono text-zinc-500">{activeReasoning.length} steps</span>
            </div>

            <div className="space-y-1 text-[11px] text-zinc-400">
              {activeReasoning.map((step, idx) => (
                <p key={idx} className="leading-snug">
                  <span className="text-zinc-600 mr-1.5">{idx + 1}.</span>
                  {step}
                </p>
              ))}
            </div>
          </div>
        )}

        {/* Audit Log */}
        {historyLogs.length > 0 && (
          <div>
            <span className="text-[10px] font-semibold uppercase tracking-wider text-zinc-500 block mb-2">
              Action History
            </span>
            <div className="space-y-2">
              {historyLogs.map((log, idx) => (
                <div key={idx} className="p-2.5 rounded-lg bg-zinc-900 border border-zinc-800 text-xs">
                  <div className="flex items-center justify-between mb-0.5">
                    <span className="font-semibold text-zinc-200">{log.action}</span>
                    <span className="text-[10px] font-mono text-zinc-500">{log.timestamp}</span>
                  </div>
                  <p className="text-zinc-400 text-[11px] leading-tight">{log.summary}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Input */}
      <div className="p-3 border-t border-zinc-800 bg-zinc-900/60">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSendPrompt();
          }}
          className="flex items-center gap-2"
        >
          <input
            type="text"
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            disabled={isProcessing}
            placeholder="Instruct the copilot..."
            className="flex-1 px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600 disabled:opacity-50"
          />
          <button
            type="submit"
            disabled={isProcessing || !prompt.trim()}
            className="btn-interactive p-2 rounded-lg bg-white hover:bg-zinc-200 text-zinc-950 disabled:opacity-50 transition-colors"
          >
            {isProcessing ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Send className="w-3.5 h-3.5" />}
          </button>
        </form>
      </div>
    </div>
    </>
  );
};

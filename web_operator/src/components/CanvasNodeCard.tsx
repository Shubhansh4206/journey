'use client';

import React, { useState } from 'react';
import { ItineraryNode, NodeType } from '../lib/types';
import { 
  Plane, 
  Building2, 
  Car, 
  Compass, 
  Trash2, 
  GripVertical, 
  Sparkles, 
  DollarSign, 
  ChevronDown,
  ChevronUp
} from 'lucide-react';

interface CanvasNodeCardProps {
  node: ItineraryNode;
  onUpdate: (updatedNode: ItineraryNode) => void;
  onDelete: (nodeId: string) => void;
  isSelected?: boolean;
  onSelect?: () => void;
  onStartDrag?: (e: React.MouseEvent, node: ItineraryNode) => void;
}

export const CanvasNodeCard: React.FC<CanvasNodeCardProps> = ({
  node,
  onUpdate,
  onDelete,
  isSelected,
  onSelect,
  onStartDrag,
}) => {
  const [showAiReasoning, setShowAiReasoning] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);

  const getNodeInfo = (type: NodeType) => {
    switch (type) {
      case 'flight':
        return { icon: Plane, label: 'Flight' };
      case 'hotel':
        return { icon: Building2, label: 'Hotel' };
      case 'transfer':
        return { icon: Car, label: 'Transfer' };
      case 'activity':
        return { icon: Compass, label: 'Activity' };
    }
  };

  const info = getNodeInfo(node.node_type);
  const IconComponent = info.icon;

  const handleBaseCostChange = (newBase: number) => {
    const base = Math.max(0, newBase);
    const final_price = Number((base * (1 + node.margin_percentage / 100)).toFixed(2));
    onUpdate({
      ...node,
      base_cost: base,
      final_price,
    });
  };

  const handleMarginChange = (newMargin: number) => {
    const margin = Math.max(0, Math.min(100, newMargin));
    const final_price = Number((node.base_cost * (1 + margin / 100)).toFixed(2));
    onUpdate({
      ...node,
      margin_percentage: margin,
      final_price,
    });
  };

  const marginDollar = Number((node.base_cost * (node.margin_percentage / 100)).toFixed(2));
  const finalPrice = node.final_price || Number((node.base_cost + marginDollar).toFixed(2));

  return (
    <div
      onClick={onSelect}
      style={{
        transform: `translate(${node.ui_coordinates.x}px, ${node.ui_coordinates.y}px)`,
        position: 'absolute',
      }}
      className={`w-72 select-none rounded-xl bg-[#121215] border transition-all ${
        isSelected
          ? 'border-zinc-400 shadow-md ring-1 ring-zinc-400/20'
          : 'border-zinc-800 hover:border-zinc-700'
      }`}
    >
      {/* Node Header */}
      <div className="p-2.5 rounded-t-xl bg-zinc-900/80 border-b border-zinc-800 flex items-center justify-between">
        <div 
          onMouseDown={(e) => onStartDrag && onStartDrag(e, node)}
          className="flex items-center gap-2 cursor-grab active:cursor-grabbing flex-1"
        >
          <GripVertical className="w-3.5 h-3.5 text-zinc-500" />
          <div className="w-5 h-5 rounded bg-zinc-800 flex items-center justify-center text-zinc-300">
            <IconComponent className="w-3 h-3" />
          </div>
          <span className="text-[11px] font-medium uppercase tracking-wider text-zinc-300">
            {info.label}
          </span>
        </div>

        <div className="flex items-center gap-1">
          {node.ai_metadata?.generated_by === 'agent' && (
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                setShowAiReasoning(!showAiReasoning);
              }}
              className="p-1 rounded text-zinc-400 hover:text-zinc-200"
              title="AI Generated"
            >
              <Sparkles className="w-3 h-3 text-zinc-400" />
            </button>
          )}

          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onDelete(node.id);
            }}
            className="p-1 rounded text-zinc-500 hover:text-red-400 transition-colors"
          >
            <Trash2 className="w-3 h-3" />
          </button>
        </div>
      </div>

      {/* AI Reasoning box */}
      {showAiReasoning && node.ai_metadata?.reasoning && (
        <div className="p-2 bg-zinc-950 border-b border-zinc-800 text-[11px] text-zinc-300">
          <p className="text-zinc-400 font-medium">AI Reasoning:</p>
          <p className="text-zinc-300 mt-0.5 leading-snug">{node.ai_metadata.reasoning}</p>
        </div>
      )}

      {/* Body */}
      <div className="p-3 space-y-2.5">
        <div>
          <h4 className="text-xs font-semibold text-white leading-tight">
            {node.title}
          </h4>
          {node.details?.provider && (
            <p className="text-[10px] text-zinc-400 mt-0.5">
              {node.details.provider} {node.details.city ? `• ${node.details.city}` : ''}
            </p>
          )}
        </div>

        {/* Costing calculation */}
        <div className="p-2 rounded-lg bg-zinc-950 border border-zinc-800/80 space-y-1.5">
          <div className="grid grid-cols-2 gap-2 text-xs">
            <div>
              <span className="text-[10px] text-zinc-500 block mb-0.5">Base Cost ($)</span>
              <input
                type="number"
                value={node.base_cost}
                onChange={(e) => handleBaseCostChange(parseFloat(e.target.value) || 0)}
                className="w-full px-2 py-1 bg-zinc-900 border border-zinc-800 rounded text-xs font-mono text-zinc-200 focus:outline-none focus:border-zinc-600"
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-0.5">
                <span className="text-[10px] text-zinc-500">Margin (%)</span>
                <span className="text-[10px] text-zinc-400 font-mono">+${marginDollar}</span>
              </div>
              <input
                type="number"
                value={node.margin_percentage}
                onChange={(e) => handleMarginChange(parseFloat(e.target.value) || 0)}
                className="w-full px-2 py-1 bg-zinc-900 border border-zinc-800 rounded text-xs font-mono text-zinc-200 focus:outline-none focus:border-zinc-600"
              />
            </div>
          </div>

          <div className="pt-1.5 border-t border-zinc-900 flex items-center justify-between text-xs">
            <span className="text-[10px] text-zinc-500">Quotation Price:</span>
            <span className="font-semibold text-xs text-zinc-100 font-mono">
              ${finalPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </span>
          </div>
        </div>

        {/* Details Toggle */}
        {node.details && (
          <div>
            <button
              type="button"
              onClick={() => setIsExpanded(!isExpanded)}
              className="w-full flex items-center justify-between text-[10px] text-zinc-500 hover:text-zinc-300 py-0.5"
            >
              <span>{isExpanded ? 'Hide Specs' : 'View Specs'}</span>
              {isExpanded ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />}
            </button>

            {isExpanded && (
              <div className="pt-1.5 space-y-1 text-[10px] text-zinc-400 border-t border-zinc-900">
                {node.details.room_type && (
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Room:</span>
                    <span className="text-zinc-300">{node.details.room_type}</span>
                  </div>
                )}
                {node.details.duration && (
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Duration:</span>
                    <span className="text-zinc-300">{node.details.duration}</span>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Connection dots */}
      <div className="w-2.5 h-2.5 rounded-full bg-zinc-800 border border-zinc-600 absolute -left-1.5 top-1/2 -translate-y-1/2" />
      <div className="w-2.5 h-2.5 rounded-full bg-zinc-800 border border-zinc-600 absolute -right-1.5 top-1/2 -translate-y-1/2" />
    </div>
  );
};

'use client';

import React, { memo, useState } from 'react';
import { Handle, Position, NodeProps } from '@xyflow/react';
import { 
  GripVertical, 
  Trash2, 
  Building, 
  Ticket, 
  Car, 
  Plane, 
  MapPin, 
  Sparkles, 
  ChevronDown, 
  ChevronUp, 
  Check, 
  Clock, 
  Star 
} from 'lucide-react';

export interface DarkItineraryNodeData {
  id?: string;
  type?: string; // 'HOTEL' | 'ACTIVITY' | 'TRANSFER' | 'PLACE' | 'FLIGHT'
  title: string;
  location?: string;
  location_subtitle?: string;
  baseCost: number;
  margin: number;
  quotationPrice?: number;
  currency?: string;
  day?: number;
  time?: string;
  badge?: string;
  specs?: {
    duration_minutes?: number;
    duration?: string;
    inclusions?: string[];
    vehicle_type?: string;
    star_rating?: number;
    address?: string;
    notes?: string;
    [key: string]: any;
  };
  onBaseCostChange?: (id: string, newBaseCost: number) => void;
  onMarginChange?: (id: string, newMargin: number) => void;
  onDeleteNode?: (id: string) => void;
}

export const DarkItineraryNode = memo(({ id, data }: NodeProps) => {
  const nodeData = (data as unknown) as DarkItineraryNodeData;
  const rawType = (nodeData.type || 'ACTIVITY').toUpperCase();
  const currency = nodeData.currency || '₹';

  const [baseCost, setBaseCost] = useState<number>(Number(nodeData.baseCost ?? 0));
  const [margin, setMargin] = useState<number>(Number(nodeData.margin ?? 15));
  const [isSpecsOpen, setIsSpecsOpen] = useState(false);

  // Dynamic calculations
  const marginAmount = Math.round(baseCost * (margin / 100));
  const computedQuotationPrice = baseCost + marginAmount;

  // Icon selector based on node type
  const getIcon = () => {
    switch (rawType) {
      case 'HOTEL':
        return Building;
      case 'TRANSFER':
      case 'TRANSPORT':
        return Car;
      case 'FLIGHT':
        return Plane;
      case 'PLACE':
      case 'ATTRACTION':
        return MapPin;
      case 'ACTIVITY':
      default:
        return Sparkles;
    }
  };

  const Icon = getIcon();

  const handleBaseCostChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = Math.max(0, parseFloat(e.target.value) || 0);
    setBaseCost(val);
    if (nodeData.onBaseCostChange) {
      nodeData.onBaseCostChange(id, val);
    }
  };

  const handleMarginChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = parseFloat(e.target.value) || 0;
    setMargin(val);
    if (nodeData.onMarginChange) {
      nodeData.onMarginChange(id, val);
    }
  };

  const handleDelete = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (nodeData.onDeleteNode) {
      nodeData.onDeleteNode(id);
    }
  };

  const locationText = nodeData.location || nodeData.location_subtitle || 'Destination';

  return (
    <div className="w-80 rounded-xl border border-neutral-800 bg-[#121212] p-4 text-white shadow-2xl font-sans transition-all duration-150 hover:border-neutral-700">
      
      {/* HEADER */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center text-neutral-400">
          <GripVertical className="mr-1.5 h-4 w-4 cursor-grab hover:text-white" />
          <Icon className="mr-2 h-4 w-4 text-cyan-400" />
          <span className="text-[11px] font-bold tracking-wider uppercase text-neutral-300">{rawType}</span>
          {nodeData.day !== undefined && (
            <span className="ml-2 text-[10px] font-mono px-1.5 py-0.5 rounded bg-neutral-800 text-neutral-400">
              D{nodeData.day}
            </span>
          )}
        </div>
        <div className="flex items-center gap-1.5">
          {nodeData.badge && (
            <span className="text-[9px] font-semibold uppercase tracking-wider px-1.5 py-0.5 rounded bg-amber-500/10 text-amber-400 border border-amber-500/30">
              {nodeData.badge}
            </span>
          )}
          <button 
            onClick={handleDelete}
            title="Remove item"
            className="text-neutral-500 hover:text-red-400 transition-colors p-1 rounded hover:bg-neutral-800/80"
          >
            <Trash2 className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>

      {/* TITLE & SUBTITLE */}
      <div className="mb-4">
        <h3 className="text-sm font-bold text-neutral-100 truncate" title={nodeData.title}>
          {nodeData.title || 'Itinerary Item'}
        </h3>
        <div className="flex items-center justify-between mt-0.5">
          <p className="text-xs text-neutral-400 truncate max-w-[200px]" title={locationText}>
            {locationText}
          </p>
          {nodeData.time && (
            <span className="text-[10px] font-mono text-neutral-500 flex items-center shrink-0">
              <Clock className="w-3 h-3 mr-1 inline" />
              {nodeData.time}
            </span>
          )}
        </div>
      </div>

      {/* PRICING SECTION & HORIZONTAL CYAN HANDLES */}
      <div className="relative mb-3 rounded-lg border border-neutral-800 bg-[#1a1a1a] p-3">
        {/* Cyan Target Handle (Left) */}
        <Handle
          type="target"
          position={Position.Left}
          className="!-left-[21px] !h-4 !w-4 !border-2 !border-[#121212] !bg-cyan-500 hover:!scale-110 transition-transform"
        />

        <div className="grid grid-cols-2 gap-3 mb-2.5">
          <div>
            <label className="mb-1 block text-[10px] uppercase font-semibold text-neutral-400">
              Base Cost ({currency})
            </label>
            <input 
              type="number" 
              value={baseCost}
              onChange={handleBaseCostChange}
              className="w-full rounded bg-[#2a2a2a] border border-neutral-700/60 px-2 py-1 text-xs text-white focus:outline-none focus:ring-1 focus:ring-cyan-500 font-mono"
            />
          </div>
          <div>
            <div className="mb-1 flex justify-between text-[10px] uppercase font-semibold text-neutral-400">
              <label>Margin (%)</label>
              <span className="text-cyan-400 font-mono">+{currency}{marginAmount.toLocaleString()}</span>
            </div>
            <input 
              type="number" 
              value={margin}
              onChange={handleMarginChange}
              className="w-full rounded bg-[#2a2a2a] border border-neutral-700/60 px-2 py-1 text-xs text-white focus:outline-none focus:ring-1 focus:ring-cyan-500 font-mono"
            />
          </div>
        </div>

        <div className="flex items-center justify-between border-t border-neutral-800/80 pt-2.5">
          <span className="text-xs text-neutral-400 font-medium">Quotation Price:</span>
          <span className="text-sm font-bold text-white font-mono tracking-tight">
            {currency}{computedQuotationPrice.toLocaleString()}
          </span>
        </div>

        {/* Cyan Source Handle (Right) */}
        <Handle
          type="source"
          position={Position.Right}
          className="!-right-[21px] !h-4 !w-4 !border-2 !border-[#121212] !bg-cyan-500 hover:!scale-110 transition-transform"
        />
      </div>

      {/* FOOTER: EXPANDABLE SPECS ACCORDION */}
      <div>
        <button 
          onClick={() => setIsSpecsOpen(!isSpecsOpen)}
          className="flex w-full items-center justify-between text-xs text-neutral-400 hover:text-neutral-200 transition-colors py-1"
        >
          <span className="font-medium text-[11px]">View Specs & Inclusions</span>
          {isSpecsOpen ? <ChevronUp className="h-3.5 w-3.5" /> : <ChevronDown className="h-3.5 w-3.5" />}
        </button>

        {isSpecsOpen && (
          <div className="mt-2.5 pt-2.5 border-t border-neutral-800 text-[11px] text-neutral-400 space-y-1.5 animate-in fade-in duration-150">
            {nodeData.specs?.star_rating && (
              <div className="flex items-center gap-1 text-amber-400">
                <Star className="w-3 h-3 fill-amber-400" />
                <span className="text-neutral-300 font-semibold">{nodeData.specs.star_rating}-Star Accommodation</span>
              </div>
            )}
            {nodeData.specs?.duration && (
              <div className="flex items-center gap-1.5">
                <Clock className="w-3 h-3 text-neutral-500" />
                <span>Duration: {nodeData.specs.duration}</span>
              </div>
            )}
            {nodeData.specs?.duration_minutes && !nodeData.specs?.duration && (
              <div className="flex items-center gap-1.5">
                <Clock className="w-3 h-3 text-neutral-500" />
                <span>Duration: {nodeData.specs.duration_minutes} mins</span>
              </div>
            )}
            {nodeData.specs?.vehicle_type && (
              <div className="flex items-center gap-1.5">
                <Car className="w-3 h-3 text-neutral-500" />
                <span>Vehicle: {nodeData.specs.vehicle_type}</span>
              </div>
            )}
            {nodeData.specs?.address && (
              <p className="text-[10px] text-neutral-400 truncate">
                Address: {nodeData.specs.address}
              </p>
            )}
            {Array.isArray(nodeData.specs?.inclusions) && nodeData.specs!.inclusions.length > 0 && (
              <div className="pt-1">
                <span className="block text-[10px] uppercase font-semibold text-neutral-400 mb-1">Inclusions:</span>
                <div className="flex flex-wrap gap-1">
                  {nodeData.specs!.inclusions.map((inc, i) => (
                    <span key={i} className="text-[10px] px-1.5 py-0.5 rounded bg-neutral-800 text-neutral-300 border border-neutral-700/50 flex items-center gap-1">
                      <Check className="w-2.5 h-2.5 text-cyan-400" />
                      {inc}
                    </span>
                  ))}
                </div>
              </div>
            )}
            {nodeData.specs?.notes && (
              <p className="text-[10px] text-neutral-400 italic pt-1">
                {nodeData.specs.notes}
              </p>
            )}
          </div>
        )}
      </div>

    </div>
  );
});

DarkItineraryNode.displayName = 'DarkItineraryNode';

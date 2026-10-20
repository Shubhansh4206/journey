'use client';

import React, { useState, useEffect } from 'react';
import { Negotiation, Itinerary, ItineraryNode, TripRequest } from '../lib/types';
import { dbService } from '../lib/dbService';
import { 
  X, 
  MessageSquare, 
  Sparkles, 
  CheckCircle2, 
  SlidersHorizontal, 
  Send, 
  Smartphone
} from 'lucide-react';

interface NegotiationModalProps {
  isOpen: boolean;
  onClose: () => void;
  itinerary: Itinerary;
  request: TripRequest;
  nodes: ItineraryNode[];
  onApplyNegotiatedPrice: (newNodes: ItineraryNode[], acceptedPrice: number) => void;
  onFinalizeItinerary: () => void;
}

export const NegotiationModal: React.FC<NegotiationModalProps> = ({
  isOpen,
  onClose,
  itinerary,
  request,
  nodes,
  onApplyNegotiatedPrice,
  onFinalizeItinerary,
}) => {
  const [negotiations, setNegotiations] = useState<Negotiation[]>([]);
  const [operatorReply, setOperatorReply] = useState('');
  const [isSimulatingTraveler, setIsSimulatingTraveler] = useState(false);
  const [simTargetPrice, setSimTargetPrice] = useState(
    Math.round(itinerary.final_quotation_price * 0.9)
  );
  const [simMessage, setSimMessage] = useState(
    'Can we adjust the price slightly? We are looking for $4,200 for this itinerary.'
  );

  useEffect(() => {
    if (isOpen) {
      loadNegotiations();
    }
  }, [isOpen, itinerary.id]);

  const loadNegotiations = async () => {
    const list = await dbService.getNegotiations(itinerary.id);
    setNegotiations(list);
  };

  if (!isOpen) return null;

  const latestCustomerOffer = [...negotiations]
    .reverse()
    .find(n => n.sender_type === 'customer' && n.status === 'pending_review');

  const priceDiff = latestCustomerOffer?.requested_price 
    ? itinerary.final_quotation_price - latestCustomerOffer.requested_price 
    : 0;

  const handleAiAutoResolve = () => {
    if (!latestCustomerOffer?.requested_price) return;
    const target = latestCustomerOffer.requested_price;
    const totalBase = nodes.reduce((sum, n) => sum + n.base_cost, 0);

    if (target < totalBase) {
      alert('Requested price is lower than total supplier base cost ($' + totalBase + ').');
      return;
    }

    const neededMarginTotal = target - totalBase;
    const uniformMarginPct = Number(((neededMarginTotal / totalBase) * 100).toFixed(1));

    const adjustedNodes = nodes.map(n => {
      const margin_percentage = Math.max(5, uniformMarginPct);
      const final_price = Number((n.base_cost * (1 + margin_percentage / 100)).toFixed(2));
      return {
        ...n,
        margin_percentage,
        final_price,
        ai_metadata: {
          ...n.ai_metadata,
          reasoning: `Adjusted to ${uniformMarginPct}% margin to meet counter offer ($${target.toLocaleString()}).`
        }
      };
    });

    onApplyNegotiatedPrice(adjustedNodes, target);
  };

  const handleAcceptOffer = async () => {
    if (latestCustomerOffer) {
      await dbService.updateNegotiationStatus(latestCustomerOffer.id, itinerary.id, 'accepted');
    }
    
    const confirmMsg: Negotiation = {
      id: `neg-${Date.now()}`,
      itinerary_id: itinerary.id,
      sender_type: 'operator',
      sender_id: 'operator',
      message: `Counter-offer accepted. Itinerary locked for guide dispatch.`,
      status: 'accepted',
      created_at: new Date().toISOString()
    };
    await dbService.addNegotiation(confirmMsg);
    await loadNegotiations();
    onFinalizeItinerary();
  };

  const handleSendOperatorReply = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!operatorReply.trim()) return;

    const msg: Negotiation = {
      id: `neg-${Date.now()}`,
      itinerary_id: itinerary.id,
      sender_type: 'operator',
      sender_id: 'operator',
      message: operatorReply,
      status: 'pending_review',
      created_at: new Date().toISOString()
    };

    await dbService.addNegotiation(msg);
    setOperatorReply('');
    await loadNegotiations();
  };

  const handleSimulateTravelerCounter = async (e: React.FormEvent) => {
    e.preventDefault();
    const simOffer: Negotiation = {
      id: `neg-cust-${Date.now()}`,
      itinerary_id: itinerary.id,
      sender_type: 'customer',
      sender_id: request.customer_id || 'customer-1',
      message: simMessage,
      requested_price: simTargetPrice,
      requested_changes: {
        budget_target: simTargetPrice,
      },
      status: 'pending_review',
      created_at: new Date().toISOString()
    };

    await dbService.addNegotiation(simOffer);
    await dbService.updateRequestStatus(request.id, 'negotiating');
    setIsSimulatingTraveler(false);
    await loadNegotiations();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-overlay">
      <div className="w-full max-w-xl bg-zinc-900 border border-zinc-800 rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="p-4 border-b border-zinc-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <SlidersHorizontal className="w-4 h-4 text-cyan-400" />
            <div>
              <h2 className="text-xs font-bold text-white">Negotiation & Counter-Offers</h2>
              <p className="text-[10px] text-zinc-400">Review traveler counter-offers and adjust margins.</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="btn-interactive p-1 rounded text-zinc-400 hover:text-white"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Pricing comparison */}
        <div className="px-4 py-2.5 bg-zinc-950 border-b border-zinc-800 grid grid-cols-3 gap-2 text-xs">
          <div>
            <span className="text-[10px] text-zinc-500 block">Sent Quotation</span>
            <span className="font-semibold text-zinc-200 font-mono">
              ${itinerary.final_quotation_price.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div>
            <span className="text-[10px] text-zinc-500 block">Traveler Target</span>
            <span className="font-semibold text-zinc-200 font-mono">
              {latestCustomerOffer?.requested_price
                ? `$${latestCustomerOffer.requested_price.toLocaleString('en-US', { minimumFractionDigits: 2 })}`
                : 'None'}
            </span>
          </div>

          <div>
            <span className="text-[10px] text-zinc-500 block">Difference</span>
            <span className="font-semibold text-zinc-200 font-mono">
              {priceDiff > 0 ? `-$${priceDiff.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '$0.00'}
            </span>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {latestCustomerOffer && (
            <div className="p-3 rounded-lg bg-zinc-950 border border-zinc-800">
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-semibold text-white">
                  Counter Offer: ${latestCustomerOffer.requested_price?.toLocaleString()}
                </span>
                <span className="text-[10px] font-mono text-zinc-500">Pending</span>
              </div>
              <p className="text-xs text-zinc-300 mb-2.5 leading-relaxed">"{latestCustomerOffer.message}"</p>

              <div className="flex gap-2">
                <button
                  onClick={handleAiAutoResolve}
                  className="px-2.5 py-1 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-200 text-xs font-medium border border-zinc-700 transition-colors flex items-center gap-1"
                >
                  <Sparkles className="w-3 h-3 text-zinc-400" />
                  Auto-Adjust Margins
                </button>
                <button
                  onClick={handleAcceptOffer}
                  className="px-3 py-1 rounded bg-white hover:bg-zinc-200 text-zinc-950 text-xs font-semibold transition-colors"
                >
                  Accept & Finalize
                </button>
              </div>
            </div>
          )}

          {negotiations.length === 0 ? (
            <div className="text-center py-8 text-xs text-zinc-500">
              <MessageSquare className="w-6 h-6 text-zinc-600 mx-auto mb-1.5" />
              <p>No negotiation messages yet</p>
            </div>
          ) : (
            negotiations.map((msg) => (
              <div
                key={msg.id}
                className={`p-2.5 rounded-lg text-xs ${
                  msg.sender_type === 'operator'
                    ? 'bg-zinc-800 text-zinc-200 ml-8'
                    : 'bg-zinc-950 border border-zinc-800 text-zinc-300 mr-8'
                }`}
              >
                <div className="flex items-center justify-between mb-1 text-[10px] text-zinc-500">
                  <span className="font-medium text-zinc-400">
                    {msg.sender_type === 'operator' ? 'Operator' : 'Traveler'}
                  </span>
                  {msg.requested_price && (
                    <span className="font-mono text-zinc-300">Target: ${msg.requested_price}</span>
                  )}
                </div>
                <p>{msg.message}</p>
              </div>
            ))
          )}
        </div>

        {/* Bottom Reply & Sim */}
        <div className="p-3 border-t border-zinc-800 bg-zinc-950/60 space-y-2">
          <form onSubmit={handleSendOperatorReply} className="flex gap-2">
            <input
              type="text"
              value={operatorReply}
              onChange={(e) => setOperatorReply(e.target.value)}
              placeholder="Send message to traveler..."
              className="flex-1 px-3 py-1.5 bg-zinc-900 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600"
            />
            <button
              type="submit"
              disabled={!operatorReply.trim()}
              className="px-3 py-1.5 bg-zinc-800 hover:bg-zinc-700 text-white rounded-lg text-xs font-medium disabled:opacity-50"
            >
              <Send className="w-3.5 h-3.5" />
            </button>
          </form>

          <div className="flex items-center justify-between text-[11px] pt-1 border-t border-zinc-900">
            <span className="text-zinc-500">Testing:</span>
            <button
              type="button"
              onClick={() => setIsSimulatingTraveler(!isSimulatingTraveler)}
              className="text-zinc-400 hover:text-zinc-200 font-medium"
            >
              {isSimulatingTraveler ? 'Cancel Simulation' : '+ Simulate Traveler Counter Offer'}
            </button>
          </div>

          {isSimulatingTraveler && (
            <form onSubmit={handleSimulateTravelerCounter} className="p-2.5 rounded-lg bg-zinc-900 border border-zinc-800 space-y-2 text-xs">
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="text-[10px] text-zinc-500 block mb-0.5">Target Price ($)</label>
                  <input
                    type="number"
                    value={simTargetPrice}
                    onChange={(e) => setSimTargetPrice(parseFloat(e.target.value) || 0)}
                    className="w-full px-2 py-1 bg-zinc-950 border border-zinc-800 rounded text-xs text-white"
                  />
                </div>
                <div>
                  <label className="text-[10px] text-zinc-500 block mb-0.5">Message</label>
                  <input
                    type="text"
                    value={simMessage}
                    onChange={(e) => setSimMessage(e.target.value)}
                    className="w-full px-2 py-1 bg-zinc-950 border border-zinc-800 rounded text-xs text-white"
                  />
                </div>
              </div>
              <button
                type="submit"
                className="w-full py-1 bg-zinc-800 hover:bg-zinc-700 text-zinc-200 rounded text-xs font-medium"
              >
                Send Simulated Counter
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};

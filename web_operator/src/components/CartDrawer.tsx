'use client';

import React, { useState, useEffect } from 'react';
import { 
  NodeType, 
  ItineraryNode, 
  OperatorHotel, 
  OperatorPlace, 
  OperatorActivity, 
  OperatorTransport 
} from '../lib/types';
import { dbService } from '../lib/dbService';
import { 
  X, 
  Search, 
  Plus, 
  Plane, 
  Building2, 
  Car, 
  Compass, 
  MapPin,
  Star, 
  DollarSign, 
  Percent,
  Layers
} from 'lucide-react';

interface CartDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onAddNodeToCanvas: (node: Partial<ItineraryNode>) => void;
  itineraryId: string;
}

export const CartDrawer: React.FC<CartDrawerProps> = ({
  isOpen,
  onClose,
  onAddNodeToCanvas,
  itineraryId,
}) => {
  const [activeTab, setActiveTab] = useState<'tied_up' | 'custom'>('tied_up');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');

  // Tied up inventory state
  const [hotels, setHotels] = useState<OperatorHotel[]>([]);
  const [places, setPlaces] = useState<OperatorPlace[]>([]);
  const [activities, setActivities] = useState<OperatorActivity[]>([]);
  const [transport, setTransport] = useState<OperatorTransport[]>([]);

  // Custom node state
  const [customTitle, setCustomTitle] = useState('');
  const [customType, setCustomType] = useState<NodeType>('hotel');
  const [customBaseCost, setCustomBaseCost] = useState(300);
  const [customMargin, setCustomMargin] = useState(18);
  const [customCity, setCustomCity] = useState('');
  const [customProvider, setCustomProvider] = useState('');

  useEffect(() => {
    if (isOpen) {
      loadInventory();
    }
  }, [isOpen]);

  const loadInventory = async () => {
    const [h, p, a, t] = await Promise.all([
      dbService.getOperatorHotels(),
      dbService.getOperatorPlaces(),
      dbService.getOperatorActivities(),
      dbService.getOperatorTransport(),
    ]);
    setHotels(h);
    setPlaces(p);
    setActivities(a);
    setTransport(t);
  };

  if (!isOpen) return null;

  const handleAddHotelNode = (h: OperatorHotel) => {
    const defaultMargin = 18;
    const final_price = Number((h.contracted_rate_per_night * (1 + defaultMargin / 100)).toFixed(2));
    onAddNodeToCanvas({
      itinerary_id: itineraryId,
      node_type: 'hotel',
      title: `${h.name} (${h.star_rating}★)`,
      base_cost: h.contracted_rate_per_night,
      margin_percentage: defaultMargin,
      final_price,
      ai_metadata: {
        generated_by: 'operator',
        confidence_score: 1.0,
      },
      details: {
        city: h.city,
        provider: h.name,
        room_type: 'Contracted Suite',
        amenities: h.amenities,
        contact_phone: h.contact_phone
      }
    });
  };

  const handleAddPlaceNode = (p: OperatorPlace) => {
    const defaultMargin = 20;
    const baseCost = p.entry_fee_per_person || 30;
    const final_price = Number((baseCost * (1 + defaultMargin / 100)).toFixed(2));
    onAddNodeToCanvas({
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: p.name,
      base_cost: baseCost,
      margin_percentage: defaultMargin,
      final_price,
      details: {
        city: p.city,
        duration: `${p.recommended_duration_minutes || 60} mins`,
        tags: p.tags,
        description: p.description
      }
    });
  };

  const handleAddActivityNode = (a: OperatorActivity) => {
    const defaultMargin = 20;
    const final_price = Number((a.cost_per_person * (1 + defaultMargin / 100)).toFixed(2));
    onAddNodeToCanvas({
      itinerary_id: itineraryId,
      node_type: 'activity',
      title: a.title,
      base_cost: a.cost_per_person,
      margin_percentage: defaultMargin,
      final_price,
      details: {
        city: a.location,
        duration: `${a.duration_minutes} mins`,
        inclusions: a.inclusions
      }
    });
  };

  const handleAddTransportNode = (t: OperatorTransport) => {
    const defaultMargin = 15;
    const baseCost = t.cost_per_day || 250;
    const final_price = Number((baseCost * (1 + defaultMargin / 100)).toFixed(2));
    onAddNodeToCanvas({
      itinerary_id: itineraryId,
      node_type: 'transfer',
      title: `${t.vehicle_type} (${t.capacity_passengers} Pax)`,
      base_cost: baseCost,
      margin_percentage: defaultMargin,
      final_price,
      details: {
        transport_mode: t.vehicle_type,
        features: t.features,
        provider: t.vendor_company_name
      }
    });
  };

  const handleAddCustomItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!customTitle) return;

    const final_price = Number((customBaseCost * (1 + customMargin / 100)).toFixed(2));
    onAddNodeToCanvas({
      itinerary_id: itineraryId,
      node_type: customType,
      title: customTitle,
      base_cost: customBaseCost,
      margin_percentage: customMargin,
      final_price,
      ai_metadata: {
        generated_by: 'operator',
      },
      details: {
        provider: customProvider || 'Custom Supplier',
        city: customCity || 'Destination',
      }
    });

    setCustomTitle('');
    setCustomProvider('');
    setActiveTab('tied_up');
  };

  const totalInventoryCount = hotels.length + places.length + activities.length + transport.length;

  return (
    <>
      <div 
        onClick={onClose}
        className="fixed inset-0 z-40 backdrop-blur-overlay bg-black/60 transition-opacity" 
      />
      <div className="fixed inset-y-0 right-0 z-50 w-full sm:w-[460px] bg-slate-950/95 border-l border-slate-800 shadow-2xl backdrop-blur-2xl flex flex-col spring-drawer animate-in slide-in-from-right duration-300">
        {/* Drawer Header */}
        <div className="p-4 border-b border-slate-800 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-white flex items-center gap-2">
              <span>Add Inventory to Itinerary Canvas</span>
            </h2>
            <p className="text-[11px] text-slate-400 mt-0.5">
              Drop your contracted hotels, activities, and fleet onto the canvas.
            </p>
          </div>

          <button
            onClick={onClose}
            className="btn-interactive p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

      {/* Tabs */}
      <div className="flex border-b border-slate-800 px-4 bg-slate-900/60 text-xs">
        <button
          onClick={() => setActiveTab('tied_up')}
          className={`py-2.5 px-3 font-semibold border-b-2 transition-colors ${
            activeTab === 'tied_up'
              ? 'border-sky-400 text-sky-300'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          Tied-Up Partners ({totalInventoryCount})
        </button>
        <button
          onClick={() => setActiveTab('custom')}
          className={`py-2.5 px-3 font-semibold border-b-2 transition-colors ${
            activeTab === 'custom'
              ? 'border-sky-400 text-sky-300'
              : 'border-transparent text-slate-400 hover:text-slate-200'
          }`}
        >
          + Custom Service
        </button>
      </div>

      {/* Content */}
      {activeTab === 'tied_up' ? (
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {totalInventoryCount === 0 ? (
            <div className="py-12 text-center text-xs text-slate-500">
              <Layers className="w-8 h-8 text-slate-600 mx-auto mb-2" />
              <p className="font-semibold text-slate-400">No partner inventory added yet</p>
              <p className="text-[11px] text-slate-500 mt-1 max-w-xs mx-auto">
                Go to "Tied-Up Partners" tab in the top navigation to add your partner hotels, attractions, tours, and transport fleet.
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Hotels */}
              {hotels.length > 0 && (
                <div>
                  <h3 className="text-[11px] font-bold uppercase tracking-wider text-amber-400 mb-2 flex items-center gap-1.5">
                    <Building2 className="w-3.5 h-3.5" />
                    Contracted Hotels
                  </h3>
                  <div className="space-y-2">
                    {hotels.map((h) => (
                      <div key={h.id} className="p-3 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                        <div>
                          <h4 className="text-xs font-bold text-white">{h.name}</h4>
                          <p className="text-[10px] text-slate-400">{h.city} • ${h.contracted_rate_per_night}/night</p>
                        </div>
                        <button
                          onClick={() => handleAddHotelNode(h)}
                          className="px-2.5 py-1 rounded-lg bg-amber-500/15 text-amber-300 hover:bg-amber-500 hover:text-slate-950 font-semibold text-[11px] transition-colors"
                        >
                          + Add Node
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Places */}
              {places.length > 0 && (
                <div>
                  <h3 className="text-[11px] font-bold uppercase tracking-wider text-sky-400 mb-2 flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5" />
                    Sightseeing Spots
                  </h3>
                  <div className="space-y-2">
                    {places.map((p) => (
                      <div key={p.id} className="p-3 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                        <div>
                          <h4 className="text-xs font-bold text-white">{p.name}</h4>
                          <p className="text-[10px] text-slate-400">{p.city} • {p.entry_fee_per_person > 0 ? `$${p.entry_fee_per_person}` : 'Free'}</p>
                        </div>
                        <button
                          onClick={() => handleAddPlaceNode(p)}
                          className="px-2.5 py-1 rounded-lg bg-sky-500/15 text-sky-300 hover:bg-sky-500 hover:text-white font-semibold text-[11px] transition-colors"
                        >
                          + Add Node
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Activities */}
              {activities.length > 0 && (
                <div>
                  <h3 className="text-[11px] font-bold uppercase tracking-wider text-emerald-400 mb-2 flex items-center gap-1.5">
                    <Compass className="w-3.5 h-3.5" />
                    Curated Experiences
                  </h3>
                  <div className="space-y-2">
                    {activities.map((a) => (
                      <div key={a.id} className="p-3 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                        <div>
                          <h4 className="text-xs font-bold text-white">{a.title}</h4>
                          <p className="text-[10px] text-slate-400">{a.location} • ${a.cost_per_person}/pax</p>
                        </div>
                        <button
                          onClick={() => handleAddActivityNode(a)}
                          className="px-2.5 py-1 rounded-lg bg-emerald-500/15 text-emerald-300 hover:bg-emerald-500 hover:text-slate-950 font-semibold text-[11px] transition-colors"
                        >
                          + Add Node
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Transport */}
              {transport.length > 0 && (
                <div>
                  <h3 className="text-[11px] font-bold uppercase tracking-wider text-indigo-400 mb-2 flex items-center gap-1.5">
                    <Car className="w-3.5 h-3.5" />
                    Transport Fleet
                  </h3>
                  <div className="space-y-2">
                    {transport.map((t) => (
                      <div key={t.id} className="p-3 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                        <div>
                          <h4 className="text-xs font-bold text-white">{t.vehicle_type}</h4>
                          <p className="text-[10px] text-slate-400">{t.capacity_passengers} Pax • ${t.cost_per_day}/day</p>
                        </div>
                        <button
                          onClick={() => handleAddTransportNode(t)}
                          className="px-2.5 py-1 rounded-lg bg-indigo-500/15 text-indigo-300 hover:bg-indigo-500 hover:text-white font-semibold text-[11px] transition-colors"
                        >
                          + Add Node
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      ) : (
        /* CUSTOM NODE FORM */
        <form onSubmit={handleAddCustomItem} className="flex-1 overflow-y-auto p-4 space-y-3.5 text-xs">
          <div>
            <label className="block text-slate-300 mb-1">Block Type</label>
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => setCustomType('hotel')}
                className={`p-2 rounded-xl border text-xs font-semibold flex items-center gap-2 ${
                  customType === 'hotel' ? 'bg-amber-500/20 border-amber-500/40 text-amber-300' : 'bg-slate-900 border-slate-800 text-slate-400'
                }`}
              >
                <Building2 className="w-3.5 h-3.5" /> Hotel
              </button>
              <button
                type="button"
                onClick={() => setCustomType('flight')}
                className={`p-2 rounded-xl border text-xs font-semibold flex items-center gap-2 ${
                  customType === 'flight' ? 'bg-sky-500/20 border-sky-500/40 text-sky-300' : 'bg-slate-900 border-slate-800 text-slate-400'
                }`}
              >
                <Plane className="w-3.5 h-3.5" /> Flight
              </button>
              <button
                type="button"
                onClick={() => setCustomType('transfer')}
                className={`p-2 rounded-xl border text-xs font-semibold flex items-center gap-2 ${
                  customType === 'transfer' ? 'bg-indigo-500/20 border-indigo-500/40 text-indigo-300' : 'bg-slate-900 border-slate-800 text-slate-400'
                }`}
              >
                <Car className="w-3.5 h-3.5" /> Transfer
              </button>
              <button
                type="button"
                onClick={() => setCustomType('activity')}
                className={`p-2 rounded-xl border text-xs font-semibold flex items-center gap-2 ${
                  customType === 'activity' ? 'bg-emerald-500/20 border-emerald-500/40 text-emerald-300' : 'bg-slate-900 border-slate-800 text-slate-400'
                }`}
              >
                <Compass className="w-3.5 h-3.5" /> Activity
              </button>
            </div>
          </div>

          <div>
            <label className="block text-slate-300 mb-1">Title</label>
            <input
              type="text"
              value={customTitle}
              onChange={(e) => setCustomTitle(e.target.value)}
              placeholder="e.g. Scenic Shinkansen Bullet Train"
              required
              className="w-full px-3 py-2 bg-slate-900 border border-slate-800 rounded-xl text-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div>
              <label className="block text-slate-300 mb-1">Base Cost ($)</label>
              <input
                type="number"
                value={customBaseCost}
                onChange={(e) => setCustomBaseCost(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 bg-slate-900 border border-slate-800 rounded-xl text-white"
              />
            </div>
            <div>
              <label className="block text-slate-300 mb-1">Margin (%)</label>
              <input
                type="number"
                value={customMargin}
                onChange={(e) => setCustomMargin(parseFloat(e.target.value) || 0)}
                className="w-full px-3 py-2 bg-slate-900 border border-slate-800 rounded-xl text-emerald-400"
              />
            </div>
          </div>

          <button
            type="submit"
            className="btn-interactive w-full py-2 bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold rounded-xl mt-3"
          >
            Add Node to Canvas
          </button>
        </form>
      )}
    </div>
    </>
  );
};

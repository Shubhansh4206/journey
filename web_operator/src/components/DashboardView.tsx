'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { TripRequest, RequestStatus } from '../lib/types';
import { 
  Calendar, 
  MapPin, 
  ArrowRight, 
  RefreshCw, 
  Plus, 
  Clock, 
  CheckCircle,
  FileText,
  AlertCircle,
  Sparkles,
  Users,
  Compass
} from 'lucide-react';

interface DashboardViewProps {
  requests: TripRequest[];
  onSelectRequest: (request: TripRequest) => void;
  onRefresh: () => void;
  onCreateRealRequest: (data: { destination: string; travel_dates: string; min_budget: number; max_budget: number; preferences: string }) => Promise<void>;
  isLoading?: boolean;
}

export const DashboardView: React.FC<DashboardViewProps> = ({
  requests,
  onSelectRequest,
  onRefresh,
  onCreateRealRequest,
  isLoading,
}) => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [destination, setDestination] = useState('');
  const [dates, setDates] = useState('');
  const [minBudget, setMinBudget] = useState(3000);
  const [maxBudget, setMaxBudget] = useState(6000);
  const [preferences, setPreferences] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!destination) return;
    setIsSubmitting(true);
    await onCreateRealRequest({
      destination,
      travel_dates: dates || '[2026-10-15, 2026-10-22]',
      min_budget: minBudget,
      max_budget: maxBudget,
      preferences
    });
    setIsSubmitting(false);
    setShowCreateModal(false);
    setDestination('');
    setPreferences('');
  };

  const getStatusBadge = (status: RequestStatus) => {
    switch (status) {
      case 'pending':
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-amber-300 border border-zinc-700">Pending Review</span>;
      case 'reviewing':
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-zinc-300 border border-zinc-700">In Planning</span>;
      case 'quoted':
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-sky-300 border border-zinc-700">Quotation Sent</span>;
      case 'negotiating':
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-rose-300 border border-zinc-700">Negotiating</span>;
      case 'finalized':
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-emerald-300 border border-zinc-700">Finalized</span>;
      default:
        return <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-800 text-zinc-400 border border-zinc-700">{status}</span>;
    }
  };

  const router = useRouter();

  const handleCardClick = (req: TripRequest) => {
    onSelectRequest(req);
    router.push(`/studio?trip_id=${encodeURIComponent(req.id)}`);
  };

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b border-zinc-800 mb-6">
        <div>
          <h1 className="text-lg font-semibold tracking-tight text-white flex items-center gap-2">
            <span>Customer Trip Requests</span>
            <span className="text-xs font-mono text-emerald-400 bg-emerald-950/80 px-2 py-0.5 rounded border border-emerald-800/60">
              {requests.length} in Supabase
            </span>
          </h1>
          <p className="text-xs text-zinc-400 mt-0.5">
            Click any request to automatically ingest its UUID into the Agentic AI Studio and render selected items on canvas.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={onRefresh}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 rounded-lg text-xs text-zinc-300 font-medium transition-colors"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>

          <button
            onClick={() => setShowCreateModal(true)}
            className="flex items-center gap-1.5 px-3.5 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 rounded-lg text-xs font-semibold transition-colors shadow-sm"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>New Request</span>
          </button>
        </div>
      </div>

      {/* Requests Content */}
      {requests.length === 0 ? (
        <div className="py-16 text-center border border-zinc-800/80 rounded-xl bg-zinc-900/30">
          <FileText className="w-8 h-8 text-zinc-600 mx-auto mb-2" />
          <h3 className="text-sm font-semibold text-zinc-200">No requests found in database</h3>
          <p className="text-xs text-zinc-400 max-w-sm mx-auto mt-1 mb-4">
            The <code className="font-mono text-zinc-300">trip_requests</code> table in your Supabase project is currently empty.
          </p>
          <button
            onClick={() => setShowCreateModal(true)}
            className="px-3.5 py-1.5 bg-zinc-800 hover:bg-zinc-700 text-zinc-200 rounded-lg text-xs font-medium border border-zinc-700 transition-colors"
          >
            + Create New Trip Request
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          {requests.map((req) => (
            <div
              key={req.id}
              onClick={() => handleCardClick(req)}
              className="p-4 rounded-xl bg-zinc-900/70 border border-zinc-800 hover:border-indigo-500/50 hover:bg-zinc-900 cursor-pointer transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-4 group shadow-sm hover:shadow-indigo-500/5"
            >
              <div className="space-y-2 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <h3 className="text-sm font-semibold text-white group-hover:text-indigo-300 transition-colors">
                    {req.destination}
                  </h3>
                  {getStatusBadge(req.status as RequestStatus)}
                  {req.trip_mode && (
                    <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-indigo-950/60 text-indigo-300 border border-indigo-800/60">
                      {req.trip_mode} {req.assigned_group_name ? `• ${req.assigned_group_name}` : ''}
                    </span>
                  )}
                  <span className="text-[10px] font-mono text-zinc-500 bg-zinc-950 px-1.5 py-0.5 rounded border border-zinc-800">
                    ID: {req.id.slice(0, 8)}...
                  </span>
                </div>

                <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-zinc-400">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-3 h-3 text-zinc-500" />
                    <span>{req.travel_dates}</span>
                  </span>
                  <span>•</span>
                  <span>
                    Budget: <strong className="text-zinc-200 font-mono">₹{req.per_person_budget ? Number(req.per_person_budget).toLocaleString() : Number(req.budget_range[0]).toLocaleString()}</strong>
                  </span>
                  {req.created_at && (
                    <>
                      <span>•</span>
                      <span className="text-zinc-500 text-[11px]">
                        {new Date(req.created_at).toLocaleDateString()}
                      </span>
                    </>
                  )}
                </div>

                {/* Selected Inventory Badges */}
                <div className="flex flex-wrap items-center gap-1.5 pt-0.5">
                  {req.selected_hotels && req.selected_hotels.length > 0 && (
                    <span className="text-[10px] font-medium px-2 py-0.5 rounded bg-blue-950/60 text-blue-300 border border-blue-800/50">
                      🏨 {req.selected_hotels.length} Hotel{req.selected_hotels.length > 1 ? 's' : ''}
                    </span>
                  )}
                  {req.selected_places && req.selected_places.length > 0 && (
                    <span className="text-[10px] font-medium px-2 py-0.5 rounded bg-emerald-950/60 text-emerald-300 border border-emerald-800/50">
                      📍 {req.selected_places.length} Place{req.selected_places.length > 1 ? 's' : ''}
                    </span>
                  )}
                  {req.selected_activities && req.selected_activities.length > 0 && (
                    <span className="text-[10px] font-medium px-2 py-0.5 rounded bg-purple-950/60 text-purple-300 border border-purple-800/50">
                      ✨ {req.selected_activities.length} Activit{req.selected_activities.length > 1 ? 'ies' : 'y'}
                    </span>
                  )}
                  {req.selected_transport && req.selected_transport.length > 0 && (
                    <span className="text-[10px] font-medium px-2 py-0.5 rounded bg-amber-950/60 text-amber-300 border border-amber-800/50">
                      🚗 {req.selected_transport.length} Vehicle{req.selected_transport.length > 1 ? 's' : ''}
                    </span>
                  )}
                  {(!req.selected_hotels?.length && !req.selected_places?.length && !req.selected_activities?.length && !req.selected_transport?.length) && (
                    <span className="text-[10px] text-zinc-500 italic">
                      Open Request (No pre-selected items)
                    </span>
                  )}
                </div>

                {req.user_preferences && (
                  <p className="text-xs text-zinc-400 line-clamp-1">
                    &ldquo;{req.user_preferences}&rdquo;
                  </p>
                )}
              </div>

              <div className="flex items-center gap-2 shrink-0 self-end sm:self-center">
                <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-indigo-600 group-hover:bg-indigo-500 text-white font-semibold text-xs transition-colors shadow-sm">
                  <Sparkles className="w-3.5 h-3.5" />
                  <span>Open in Studio</span>
                  <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" />
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Real Request Creation Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div className="w-full max-w-md bg-zinc-900 border border-zinc-800 rounded-2xl p-5 shadow-2xl">
            <h3 className="text-sm font-bold text-white mb-1">Create New Trip Request</h3>
            <p className="text-xs text-zinc-400 mb-4">
              Directly inserts a new record into Supabase <code className="font-mono text-zinc-300">trip_requests</code>.
            </p>

            <form onSubmit={handleCreate} className="space-y-3 text-xs">
              <div>
                <label className="block text-zinc-300 mb-1">Destination</label>
                <input
                  type="text"
                  value={destination}
                  onChange={(e) => setDestination(e.target.value)}
                  placeholder="e.g. Kyoto & Osaka Culinary Journey"
                  required
                  className="w-full px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600"
                />
              </div>

              <div>
                <label className="block text-zinc-300 mb-1">Travel Dates</label>
                <input
                  type="text"
                  value={dates}
                  onChange={(e) => setDates(e.target.value)}
                  placeholder="2026-10-15 to 2026-10-22"
                  className="w-full px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-zinc-300 mb-1">Min Budget ($)</label>
                  <input
                    type="number"
                    value={minBudget}
                    onChange={(e) => setMinBudget(parseFloat(e.target.value) || 0)}
                    className="w-full px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-white focus:outline-none focus:border-zinc-600"
                  />
                </div>
                <div>
                  <label className="block text-zinc-300 mb-1">Max Budget ($)</label>
                  <input
                    type="number"
                    value={maxBudget}
                    onChange={(e) => setMaxBudget(parseFloat(e.target.value) || 0)}
                    className="w-full px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-white focus:outline-none focus:border-zinc-600"
                  />
                </div>
              </div>

              <div>
                <label className="block text-zinc-300 mb-1">User Preferences</label>
                <textarea
                  rows={3}
                  value={preferences}
                  onChange={(e) => setPreferences(e.target.value)}
                  placeholder="Client requests private ryokan with onsen, bullet train transfers, and guided temple visits..."
                  className="w-full px-3 py-2 bg-zinc-950 border border-zinc-800 rounded-lg text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-zinc-800">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-3 py-1.5 text-zinc-400 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded-lg transition-colors"
                >
                  {isSubmitting ? 'Saving...' : 'Save to Supabase'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

'use client';

import React, { useState, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { TripRequest, RequestStatus, TourOperator } from '../lib/types';
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
  Compass,
  Search,
  Filter,
  DollarSign,
  TrendingUp,
  Building2,
  Car,
  Ticket,
  ChevronRight,
  ShieldCheck,
  Send,
  Zap,
  PhoneCall,
  Briefcase
} from 'lucide-react';

interface DashboardViewProps {
  requests: TripRequest[];
  operator?: TourOperator | null;
  onSelectRequest: (request: TripRequest) => void;
  onRefresh: () => void;
  onCreateRealRequest: (data: { destination: string; travel_dates: string; min_budget: number; max_budget: number; preferences: string }) => Promise<void>;
  isLoading?: boolean;
}

// Curated high-res destination assets for authentic travel agency feel
const DESTINATION_META: Record<string, { img: string; code: string; state: string }> = {
  'Mumbai': {
    img: 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=600&auto=format&fit=crop&q=80',
    code: 'BOM',
    state: 'Maharashtra'
  },
  'Tokyo & Kyoto': {
    img: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600&auto=format&fit=crop&q=80',
    code: 'TYO',
    state: 'Japan Inbound'
  },
  'Goa': {
    img: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=600&auto=format&fit=crop&q=80',
    code: 'GOI',
    state: 'Goa Coastal'
  },
  'Jaipur': {
    img: 'https://images.unsplash.com/photo-1603262110263-fb010d6e59d4?w=600&auto=format&fit=crop&q=80',
    code: 'JAI',
    state: 'Rajasthan'
  },
  'Udaipur': {
    img: 'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=600&auto=format&fit=crop&q=80',
    code: 'UDR',
    state: 'Rajasthan'
  }
};

export const DashboardView: React.FC<DashboardViewProps> = ({
  requests,
  operator,
  onSelectRequest,
  onRefresh,
  onCreateRealRequest,
  isLoading,
}) => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [destination, setDestination] = useState('');
  const [dates, setDates] = useState('');
  const [minBudget, setMinBudget] = useState(15000);
  const [maxBudget, setMaxBudget] = useState(25000);
  const [preferences, setPreferences] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'quoted' | 'finalized'>('all');
  const [cityFilter, setCityFilter] = useState<string>('all');

  const router = useRouter();

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!destination) return;
    setIsSubmitting(true);
    await onCreateRealRequest({
      destination,
      travel_dates: dates || '[2026-10-18, 2026-10-22]',
      min_budget: minBudget,
      max_budget: maxBudget,
      preferences
    });
    setIsSubmitting(false);
    setShowCreateModal(false);
    setDestination('');
    setPreferences('');
  };

  const handleCardClick = (req: TripRequest) => {
    onSelectRequest(req);
    const opParam = operator?.id ? `&operator_id=${encodeURIComponent(operator.id)}` : '';
    router.push(`/studio?trip_id=${encodeURIComponent(req.id)}${opParam}`);
  };

  // Operational KPI aggregates
  const stats = useMemo(() => {
    let totalPipeline = 0;
    let groupSquads = 0;
    let pendingCount = 0;
    let quotedCount = 0;

    requests.forEach(r => {
      const budget = Number(r.per_person_budget || r.budget_range?.[0] || 15000);
      const pax = r.trip_mode?.includes('Group') ? 6 : 1;
      totalPipeline += (budget * pax);

      if (r.trip_mode?.includes('Group')) groupSquads++;
      if (r.status === 'pending') pendingCount++;
      if (r.status === 'quoted') quotedCount++;
    });

    return {
      totalPipeline,
      groupSquads,
      solos: requests.length - groupSquads,
      pendingCount,
      quotedCount
    };
  }, [requests]);

  // Filtered requests
  const filteredRequests = useMemo(() => {
    return requests.filter((r) => {
      const matchSearch = 
        r.destination.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (r.assigned_group_name && r.assigned_group_name.toLowerCase().includes(searchQuery.toLowerCase())) ||
        r.id.toLowerCase().includes(searchQuery.toLowerCase());

      const matchStatus = statusFilter === 'all' || r.status === statusFilter;
      const matchCity = cityFilter === 'all' || r.destination.toLowerCase().includes(cityFilter.toLowerCase());

      return matchSearch && matchStatus && matchCity;
    });
  }, [requests, searchQuery, statusFilter, cityFilter]);

  const getStatusBadge = (status: RequestStatus) => {
    switch (status) {
      case 'pending':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-amber-50 text-amber-800 border border-amber-200">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
            Awaiting Quotation
          </span>
        );
      case 'quoted':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-[#0A2647]/10 text-[#0A2647] border border-[#0A2647]/20">
            <CheckCircle className="w-3 h-3 text-[#0A2647]" />
            Quotation Sent
          </span>
        );
      case 'finalized':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200">
            <CheckCircle className="w-3 h-3 text-emerald-600" />
            Booked & Confirmed
          </span>
        );
      case 'negotiating':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-purple-50 text-purple-800 border border-purple-200">
            Client Revision
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center px-3 py-1 rounded-full text-[11px] font-medium bg-[#F5F6F8] text-[#9AA0A6] border border-slate-200">
            {status}
          </span>
        );
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-8 py-8 space-y-8">
      
      {/* 1. EXECUTIVE AGENCY METRIC CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1: Inbound Inquiries */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div className="flex items-center justify-between text-[#9AA0A6] mb-3">
            <span className="text-xs font-semibold text-[#0A2647]">New Inquiries</span>
            <div className="w-8 h-8 rounded-lg bg-[#F5F6F8] flex items-center justify-center text-[#0A2647]">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div>
            <div className="flex items-baseline gap-2">
              <span className="text-3xl font-bold font-heading text-[#1A1A1A]">{requests.length}</span>
              <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/60">+4 today</span>
            </div>
            <p className="text-xs text-[#9AA0A6] mt-1.5 font-medium">
              Awaiting custom itineraries
            </p>
          </div>
        </div>

        {/* Card 2: Pipeline Value */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div className="flex items-center justify-between text-[#9AA0A6] mb-3">
            <span className="text-xs font-semibold text-[#0A2647]">Active Proposals</span>
            <div className="w-8 h-8 rounded-lg bg-[#F5F6F8] flex items-center justify-center text-[#0A2647]">
              <DollarSign className="w-4 h-4" />
            </div>
          </div>
          <div>
            <div className="flex items-baseline gap-2">
              <span className="text-3xl font-bold font-heading text-[#1A1A1A]">
                ₹{(stats.totalPipeline / 100000).toFixed(1)} Lakhs
              </span>
            </div>
            <p className="text-xs text-[#9AA0A6] mt-1.5 font-medium">
              Total quotation pipeline
            </p>
          </div>
        </div>

        {/* Card 3: Next Departure */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div className="flex items-center justify-between text-[#9AA0A6] mb-3">
            <span className="text-xs font-semibold text-[#0A2647]">Next Departure</span>
            <div className="w-8 h-8 rounded-lg bg-[#F5F6F8] flex items-center justify-center text-[#0A2647]">
              <Calendar className="w-4 h-4" />
            </div>
          </div>
          <div>
            <div className="flex items-baseline gap-2">
              <span className="text-3xl font-bold font-heading text-[#1A1A1A]">Oct 18</span>
              <span className="text-xs font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200/70">
                In 21 days
              </span>
            </div>
            <p className="text-xs text-[#9AA0A6] mt-1.5 font-medium">
              Mumbai Heritage Group Tour
            </p>
          </div>
        </div>

        {/* Card 4: Local Partners */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-[0_4px_20px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div className="flex items-center justify-between text-[#9AA0A6] mb-3">
            <span className="text-xs font-semibold text-[#0A2647]">Local Partners</span>
            <div className="w-8 h-8 rounded-lg bg-[#F5F6F8] flex items-center justify-center text-[#0A2647]">
              <Building2 className="w-4 h-4" />
            </div>
          </div>
          <div>
            <div className="flex items-baseline gap-2">
              <span className="text-3xl font-bold font-heading text-[#1A1A1A]">42 Partners</span>
              <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/60">Verified</span>
            </div>
            <p className="text-xs text-[#9AA0A6] mt-1.5 font-medium">
              Boutique hotels & local experts
            </p>
          </div>
        </div>
      </div>

      {/* 2. MAIN OPERATIONS DECK (Queue & Command Sidebar) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        
        {/* LEFT COLUMN: Inbound Trip Inquiries Dossier Queue (8 cols) */}
        <div className="lg:col-span-8 space-y-6">
          
          {/* Controls Bar: Search & Status Chips */}
          <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs space-y-4">
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
              {/* Search Bar */}
              <div className="relative flex-1">
                <Search className="w-4 h-4 text-[#9AA0A6] absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search destinations, traveler groups, or preferences..."
                  className="w-full bg-[#F5F6F8] border border-slate-200/60 text-[#1A1A1A] placeholder-[#9AA0A6] text-xs rounded-xl pl-10 pr-4 py-2.5 focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              {/* Action Buttons */}
              <div className="flex items-center gap-2">
                <button
                  onClick={onRefresh}
                  disabled={isLoading}
                  className="p-2.5 bg-[#F5F6F8] hover:bg-slate-200 border border-slate-200 rounded-xl text-[#0A2647] transition-all"
                  title="Refresh Inquiries"
                >
                  <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
                </button>

                <button
                  onClick={() => setShowCreateModal(true)}
                  className="flex items-center gap-1.5 px-4 py-2.5 bg-[#0A2647] hover:bg-[#081f3a] text-white rounded-xl text-xs font-semibold transition-all shadow-sm shrink-0"
                >
                  <Plus className="w-3.5 h-3.5" />
                  <span>New Inquiry</span>
                </button>
              </div>
            </div>

            {/* Filter Tabs */}
            <div className="flex items-center justify-between gap-2 border-t border-slate-100 pt-3 flex-wrap">
              <div className="flex items-center gap-1.5 overflow-x-auto">
                <button
                  onClick={() => setStatusFilter('all')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    statusFilter === 'all'
                      ? 'bg-[#0A2647] text-white shadow-xs'
                      : 'text-[#9AA0A6] hover:text-[#1A1A1A] bg-[#F5F6F8]'
                  }`}
                >
                  All Inquiries ({requests.length})
                </button>

                <button
                  onClick={() => setStatusFilter('pending')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 ${
                    statusFilter === 'pending'
                      ? 'bg-[#0A2647] text-white shadow-xs'
                      : 'text-[#9AA0A6] hover:text-[#1A1A1A] bg-[#F5F6F8]'
                  }`}
                >
                  <span>Awaiting Itinerary</span>
                  <span className="w-2 h-2 rounded-full bg-amber-500" />
                </button>

                <button
                  onClick={() => setStatusFilter('quoted')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    statusFilter === 'quoted'
                      ? 'bg-[#0A2647] text-white shadow-xs'
                      : 'text-[#9AA0A6] hover:text-[#1A1A1A] bg-[#F5F6F8]'
                  }`}
                >
                  Quoted ({stats.quotedCount})
                </button>

                <button
                  onClick={() => setStatusFilter('finalized')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    statusFilter === 'finalized'
                      ? 'bg-[#0A2647] text-white shadow-xs'
                      : 'text-[#9AA0A6] hover:text-[#1A1A1A] bg-[#F5F6F8]'
                  }`}
                >
                  Confirmed
                </button>
              </div>

              {/* City quick filter */}
              <div className="flex items-center gap-1.5 text-xs text-[#9AA0A6]">
                <span>Destination:</span>
                <select
                  value={cityFilter}
                  onChange={(e) => setCityFilter(e.target.value)}
                  className="bg-[#F5F6F8] border border-slate-200 rounded-lg px-2.5 py-1 text-xs font-semibold text-[#1A1A1A] focus:outline-none"
                >
                  <option value="all">All Destinations</option>
                  <option value="Mumbai">Mumbai</option>
                  <option value="Tokyo">Tokyo & Kyoto</option>
                  <option value="Goa">Goa</option>
                  <option value="Jaipur">Jaipur</option>
                  <option value="Udaipur">Udaipur</option>
                </select>
              </div>
            </div>
          </div>

          {/* Dossier Cards List */}
          {filteredRequests.length === 0 ? (
            <div className="py-20 text-center rounded-2xl bg-white border border-slate-200/80 shadow-xs p-8">
              <Compass className="w-10 h-10 text-[#9AA0A6] mx-auto mb-3" />
              <h3 className="text-base font-bold font-heading text-[#1A1A1A]">No Inquiries Found</h3>
              <p className="text-xs text-[#9AA0A6] max-w-sm mx-auto mt-1 mb-5">
                No active requests match your filter. Create a new trip inquiry to start crafting a custom itinerary.
              </p>
              <button
                onClick={() => setShowCreateModal(true)}
                className="px-5 py-2.5 bg-[#0A2647] text-white rounded-xl text-xs font-semibold shadow-sm hover:bg-[#081f3a]"
              >
                + Create New Inquiry
              </button>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredRequests.map((req) => {
                const meta = DESTINATION_META[req.destination] || {
                  img: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=600&auto=format&fit=crop&q=80',
                  code: req.destination.slice(0, 3).toUpperCase(),
                  state: 'Custom Tour'
                };

                const paxCount = req.trip_mode?.includes('Group') ? 6 : 1;
                const perPaxBudget = Number(req.per_person_budget || req.budget_range?.[0] || 15000);
                const estTotalRevenue = perPaxBudget * paxCount;

                return (
                  <div
                    key={req.id}
                    onClick={() => handleCardClick(req)}
                    className="group bg-white rounded-2xl border border-slate-200/80 shadow-[0_2px_12px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgba(10,38,71,0.08)] transition-all cursor-pointer overflow-hidden flex flex-col md:flex-row items-stretch"
                  >
                    {/* Visual Destination Header Thumbnail */}
                    <div 
                      className="md:w-52 h-40 md:h-auto relative bg-cover bg-center shrink-0"
                      style={{ backgroundImage: `url(${meta.img})` }}
                    >
                      <div className="absolute inset-0 bg-gradient-to-t md:bg-gradient-to-r from-black/80 via-black/40 to-transparent" />
                      <div className="absolute top-3 left-3 flex items-center gap-1.5">
                        <span className="px-2.5 py-0.5 rounded-full bg-black/60 backdrop-blur-md text-white text-[11px] font-medium border border-white/20">
                          {req.destination}
                        </span>
                      </div>
                      <div className="absolute bottom-3 left-3 text-white">
                        <p className="text-[11px] font-medium text-slate-300">
                          {paxCount > 1 ? `${paxCount} Travelers • Group` : 'Private Journey'}
                        </p>
                        <h4 className="text-base font-bold font-heading tracking-tight leading-snug">{req.destination}</h4>
                      </div>
                    </div>

                    {/* Main Dossier Content */}
                    <div className="p-5 flex-1 flex flex-col justify-between space-y-4">
                      {/* Top Row: Lead & Group Tagging */}
                      <div>
                        <div className="flex flex-wrap items-center justify-between gap-2 mb-2.5">
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-bold font-heading text-[#1A1A1A] group-hover:text-[#0A2647] transition-colors">
                              {req.assigned_group_name ? `${req.assigned_group_name}` : 'Bespoke Tour Package'}
                            </span>
                            {getStatusBadge(req.status as RequestStatus)}
                          </div>

                          <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-[#F5F6F8] text-[#0A2647] border border-slate-200">
                            {paxCount > 1 ? `${paxCount} Travelers` : 'Solo Explorer'}
                          </span>
                        </div>

                        {/* Travel Parameters (Dates, Length, Revenue) */}
                        <div className="flex flex-wrap items-center gap-x-4 gap-y-1.5 text-xs text-[#9AA0A6] mb-3">
                          <span className="flex items-center gap-1.5 text-[#1A1A1A] font-semibold">
                            <Calendar className="w-3.5 h-3.5 text-[#0A2647]" />
                            <span>{req.travel_dates}</span>
                          </span>
                          <span>•</span>
                          <span>
                            Budget / Traveler: <strong className="text-[#1A1A1A]">₹{perPaxBudget.toLocaleString()}</strong>
                          </span>
                          <span>•</span>
                          <span>
                            Total Value: <strong className="text-[#0A2647] font-semibold">₹{estTotalRevenue.toLocaleString()}</strong>
                          </span>
                        </div>

                        {/* Traveler Selected Assets Bar */}
                        <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-slate-100">
                          {req.selected_hotels && req.selected_hotels.length > 0 && (
                            <span className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-full bg-[#F5F6F8] text-[#1A1A1A] border border-slate-200">
                              <Building2 className="w-3.5 h-3.5 text-[#0A2647]" />
                              <span>Boutique Hotel Selected</span>
                            </span>
                          )}

                          {req.selected_places && req.selected_places.length > 0 && (
                            <span className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-full bg-[#F5F6F8] text-[#1A1A1A] border border-slate-200">
                              <MapPin className="w-3.5 h-3.5 text-[#0A2647]" />
                              <span>{req.selected_places.length} Sights & Stops</span>
                            </span>
                          )}

                          {req.selected_activities && req.selected_activities.length > 0 && (
                            <span className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-full bg-[#F5F6F8] text-[#1A1A1A] border border-slate-200">
                              <Ticket className="w-3.5 h-3.5 text-[#0A2647]" />
                              <span>{req.selected_activities.length} Local Experiences</span>
                            </span>
                          )}

                          {req.selected_transport && req.selected_transport.length > 0 && (
                            <span className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1 rounded-full bg-[#F5F6F8] text-[#1A1A1A] border border-slate-200">
                              <Car className="w-3.5 h-3.5 text-[#0A2647]" />
                              <span>Chauffeur Vehicle Included</span>
                            </span>
                          )}

                          {(!req.selected_hotels?.length && !req.selected_places?.length && !req.selected_activities?.length && !req.selected_transport?.length) && (
                            <span className="text-xs text-[#9AA0A6] italic flex items-center gap-1">
                              <Sparkles className="w-3.5 h-3.5 text-[#0A2647] shrink-0" />
                              <span>Open for custom operator curation</span>
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Bottom Footer: Preferences & Studio CTA */}
                      <div className="flex items-center justify-between pt-3 border-t border-slate-100">
                        <div className="flex items-center gap-3 text-xs flex-1 mr-3">
                          {req.user_preferences ? (
                            <p className="text-xs text-[#9AA0A6] italic line-clamp-1">
                              &ldquo;{req.user_preferences}&rdquo;
                            </p>
                          ) : (
                            <p className="text-xs text-[#9AA0A6]">
                              Ready to assemble itinerary nodes & generate client quotation
                            </p>
                          )}
                        </div>

                        {/* CTA */}
                        <div className="flex items-center gap-2 shrink-0">
                          <button
                            onClick={(e) => { e.stopPropagation(); handleCardClick(req); }}
                            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#0A2647] group-hover:bg-[#081f3a] text-white font-semibold text-xs transition-all shadow-sm"
                          >
                            <Sparkles className="w-3.5 h-3.5 text-amber-300" />
                            <span>Design Itinerary</span>
                            <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-1 transition-transform" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* RIGHT COLUMN: Travel Highlights & Stays Rail (4 cols) */}
        <div className="lg:col-span-4 space-y-6">
          
          {/* Curated Experiences Showcase */}
          <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-xs space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div className="flex items-center gap-2 text-[#0A2647]">
                <Compass className="w-4 h-4 text-[#0A2647]" />
                <h3 className="text-xs font-bold uppercase tracking-wider font-heading">Curated Inclusions</h3>
              </div>
              <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                Ready to Add
              </span>
            </div>

            <div className="space-y-3 text-xs">
              <div className="p-3.5 rounded-xl bg-[#F5F6F8] border border-slate-200/60 space-y-1">
                <span className="text-[11px] font-bold text-amber-800 flex items-center gap-1.5">
                  <Compass className="w-3.5 h-3.5 text-amber-600 shrink-0" />
                  <span>Sunrise Harbor Sailing</span>
                </span>
                <p className="font-semibold text-[#1A1A1A]">
                  Mumbai Coast Private Yacht
                </p>
                <p className="text-[11px] text-[#9AA0A6]">
                  Morning sailing past the Gateway of India with tea & breakfast on deck.
                </p>
              </div>

              <div className="p-3.5 rounded-xl bg-[#F5F6F8] border border-slate-200/60 space-y-1">
                <span className="text-[11px] font-bold text-[#0A2647] flex items-center gap-1.5">
                  <Building2 className="w-3.5 h-3.5 text-[#0A2647] shrink-0" />
                  <span>UNESCO Archaeologist Tour</span>
                </span>
                <p className="font-semibold text-[#1A1A1A]">
                  Elephanta Caves Guided Heritage
                </p>
                <p className="text-[11px] text-[#9AA0A6]">
                  Dedicated licensed historian escort, ferry transfers & audio guide.
                </p>
              </div>
            </div>
          </div>

          {/* Preferred Hotel & Transport Partners */}
          <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-xs space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="text-xs font-bold uppercase tracking-wider text-[#0A2647] font-heading">Verified Stays & Fleet</h3>
              <a href="/studio" className="text-xs text-[#0A2647] font-semibold hover:underline">
                Explore Studio
              </a>
            </div>

            <div className="space-y-2.5 text-xs">
              <div className="flex items-center justify-between p-3 rounded-xl bg-[#F5F6F8] border border-slate-200/60">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center font-bold text-sm shadow-2xs text-[#0A2647]">
                    <Building2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h5 className="font-bold text-[#1A1A1A]">The Oberoi Mumbai</h5>
                    <p className="text-[11px] text-[#9AA0A6]">5-Star Luxury • Nariman Point</p>
                  </div>
                </div>
                <span className="font-semibold text-[#0A2647] text-xs">₹280/nt</span>
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-[#F5F6F8] border border-slate-200/60">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center font-bold text-sm shadow-2xs text-[#0A2647]">
                    <Car className="w-4 h-4" />
                  </div>
                  <div>
                    <h5 className="font-bold text-[#1A1A1A]">Innova Crysta AC</h5>
                    <p className="text-[11px] text-[#9AA0A6]">Chauffeur Driven • Full Day</p>
                  </div>
                </div>
                <span className="font-semibold text-[#0A2647] text-xs">₹120/day</span>
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-[#F5F6F8] border border-slate-200/60">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center font-bold text-sm shadow-2xs text-[#0A2647]">
                    <Building2 className="w-4 h-4 text-purple-600" />
                  </div>
                  <div>
                    <h5 className="font-bold text-[#1A1A1A]">Taj Lake Palace</h5>
                    <p className="text-[11px] text-[#9AA0A6]">Royal Heritage • Udaipur</p>
                  </div>
                </div>
                <span className="font-semibold text-[#0A2647] text-xs">₹450/nt</span>
              </div>
            </div>
          </div>

          {/* Quick Itinerary Designer Action */}
          <div className="rounded-2xl p-5 bg-[#0A2647] text-white shadow-md shadow-[#0A2647]/15 space-y-3">
            <h4 className="font-bold text-sm font-heading">Design Custom Itineraries</h4>
            <p className="text-xs text-slate-300 leading-relaxed">
              Open the interactive canvas to assemble hotels, activities, and transport nodes with automated pricing quotations.
            </p>
            <a
              href="/studio"
              className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white text-[#0A2647] font-semibold text-xs shadow-xs hover:bg-slate-100 transition-colors"
            >
              <Sparkles className="w-3.5 h-3.5 text-[#0A2647]" />
              <span>Open Itinerary Canvas</span>
            </a>
          </div>

        </div>

      </div>

      {/* Real Request Creation Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="w-full max-w-md bg-white border border-slate-100 rounded-3xl p-6 shadow-2xl animate-in fade-in duration-200">
            <h3 className="text-base font-bold font-heading text-[#1A1A1A] mb-1">Create New Trip Inquiry</h3>
            <p className="text-xs text-[#9AA0A6] mb-5">
              Log a new traveler or group request to craft a personalized itinerary.
            </p>

            <form onSubmit={handleCreate} className="space-y-3.5 text-xs">
              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Destination Name *</label>
                <input
                  type="text"
                  value={destination}
                  onChange={(e) => setDestination(e.target.value)}
                  placeholder="e.g. Mumbai & Elephanta Heritage Tour"
                  required
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Travel Dates *</label>
                <input
                  type="text"
                  value={dates}
                  onChange={(e) => setDates(e.target.value)}
                  placeholder="2026-10-18 to 2026-10-22"
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#1A1A1A] font-semibold mb-1">Min Budget (₹)</label>
                  <input
                    type="number"
                    value={minBudget}
                    onChange={(e) => setMinBudget(parseFloat(e.target.value) || 0)}
                    className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] focus:outline-none focus:border-[#0A2647] font-medium"
                  />
                </div>
                <div>
                  <label className="block text-[#1A1A1A] font-semibold mb-1">Max Budget (₹)</label>
                  <input
                    type="number"
                    value={maxBudget}
                    onChange={(e) => setMaxBudget(parseFloat(e.target.value) || 0)}
                    className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] focus:outline-none focus:border-[#0A2647] font-medium"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Traveler Preferences & Notes</label>
                <textarea
                  rows={3}
                  value={preferences}
                  onChange={(e) => setPreferences(e.target.value)}
                  placeholder="e.g. Sea-facing rooms, licensed heritage guide, chauffeur vehicle..."
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2 text-[#9AA0A6] hover:text-[#1A1A1A] font-medium transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-5 py-2.5 bg-[#0A2647] hover:bg-[#081f3a] text-white font-semibold rounded-xl shadow-md shadow-[#0A2647]/15 transition-all"
                >
                  {isSubmitting ? 'Creating Inquiry...' : 'Create Trip Inquiry'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

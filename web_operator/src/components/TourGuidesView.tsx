'use client';

import React, { useState, useEffect } from 'react';
import { TourGuide, TourOperator, SUPPORTED_CITIES, SupportedCity } from '../lib/types';
import { dbService } from '../lib/dbService';
import { 
  UserCheck, 
  Phone, 
  Plus, 
  Check, 
  X,
  Edit2,
  Trash2,
  RefreshCw,
  MapPin,
  Search,
  CheckCircle2,
  AlertCircle,
  DollarSign
} from 'lucide-react';

interface TourGuidesViewProps {
  operator?: TourOperator | null;
}

export const TourGuidesView: React.FC<TourGuidesViewProps> = ({ operator }) => {
  const [guides, setGuides] = useState<TourGuide[]>([]);
  const [selectedCity, setSelectedCity] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [notification, setNotification] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // Form modal
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Clean, essential form fields
  const [guideName, setGuideName] = useState('');
  const [guideCity, setGuideCity] = useState<SupportedCity>('Mumbai');
  const [guidePhone, setGuidePhone] = useState('');
  const [guideRate, setGuideRate] = useState(150);
  const [guideLanguages, setGuideLanguages] = useState('English, Hindi');

  useEffect(() => {
    loadGuides();
  }, [selectedCity, operator?.id]);

  useEffect(() => {
    if (notification) {
      const timer = setTimeout(() => setNotification(null), 4000);
      return () => clearTimeout(timer);
    }
  }, [notification]);

  const loadGuides = async () => {
    setIsLoading(true);
    try {
      const cityFilter = selectedCity === 'all' ? undefined : selectedCity;
      const list = await dbService.getTourGuides(operator?.id, cityFilter);
      setGuides(list);
    } catch (err: any) {
      setNotification({ type: 'error', message: err.message || 'Failed to load guides from Supabase' });
    } finally {
      setIsLoading(false);
    }
  };

  const resetForm = () => {
    setEditingId(null);
    setIsModalOpen(false);
    setIsSaving(false);
    setGuideName('');
    setGuideCity(selectedCity !== 'all' ? (selectedCity as SupportedCity) : 'Mumbai');
    setGuidePhone('');
    setGuideRate(150);
    setGuideLanguages('English, Hindi');
  };

  const handleOpenAdd = () => {
    resetForm();
    setIsModalOpen(true);
  };

  const handleEditGuide = (guide: TourGuide) => {
    setEditingId(guide.id);
    setGuideName(guide.name || `${guide.first_name || ''} ${guide.last_name || ''}`.trim());
    setGuideCity((guide.city as SupportedCity) || 'Mumbai');
    setGuidePhone(guide.contact_number || '');
    setGuideRate(guide.daily_rate || 150);
    setGuideLanguages(guide.languages?.join(', ') || 'English, Hindi');
    setIsModalOpen(true);
  };

  const handleSaveGuide = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!guideName.trim()) return;

    setIsSaving(true);
    const guidePayload: Partial<TourGuide> = {
      operator_id: operator?.id,
      name: guideName.trim(),
      city: guideCity,
      contact_number: guidePhone.trim() || null,
      daily_rate: Number(guideRate) || 150,
      languages: guideLanguages.split(',').map(s => s.trim()).filter(Boolean),
      is_active: true
    };

    if (editingId) {
      const res = await dbService.updateTourGuide({ id: editingId, ...guidePayload } as TourGuide);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Update Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Tour guide updated in Supabase.' });
      }
    } else {
      const res = await dbService.createTourGuide(guidePayload);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Insert Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Tour guide saved to Supabase.' });
      }
    }

    await loadGuides();
    resetForm();
  };

  const handleDeleteGuide = async (id: string, name: string) => {
    if (confirm(`Delete guide "${name}" from Supabase?`)) {
      const res = await dbService.deleteTourGuide(id);
      if (res.error) {
        setNotification({ type: 'error', message: `Delete error: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Tour guide removed from Supabase.' });
      }
      setGuides(prev => prev.filter(g => g.id !== id));
    }
  };

  const filteredGuides = guides.filter(g => {
    const displayName = g.name || `${g.first_name || ''} ${g.last_name || ''}`.trim();
    const matchesSearch = 
      displayName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      g.languages?.some(l => l.toLowerCase().includes(searchQuery.toLowerCase()));
    
    if (selectedCity === 'all') return matchesSearch;
    return matchesSearch && g.city?.toLowerCase() === selectedCity.toLowerCase();
  });

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8">
      {/* Toast Notification */}
      {notification && (
        <div className={`mb-6 p-3 rounded-lg border text-xs flex items-center justify-between transition-all ${
          notification.type === 'success' 
            ? 'bg-zinc-900 border-emerald-500/40 text-emerald-300' 
            : 'bg-zinc-900 border-red-500/40 text-red-300'
        }`}>
          <div className="flex items-center gap-2">
            {notification.type === 'success' ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
            ) : (
              <AlertCircle className="w-4 h-4 text-red-400 shrink-0" />
            )}
            <span>{notification.message}</span>
          </div>
          <button onClick={() => setNotification(null)} className="text-zinc-500 hover:text-zinc-300">
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b border-zinc-800 mb-6">
        <div>
          <h1 className="text-lg font-semibold tracking-tight text-white flex items-center gap-2">
            <span>Tour Guides</span>
            <span className="text-[11px] font-mono text-zinc-300 bg-zinc-900 px-2 py-0.5 rounded border border-zinc-800">
              Supabase CRUD
            </span>
          </h1>
          <p className="text-xs text-zinc-400 mt-0.5">
            Manage your certified local guides across Mumbai, Udaipur, Jaipur, and Goa.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={loadGuides}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 rounded-lg text-xs text-zinc-300 font-medium transition-colors"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>

          <button
            onClick={handleOpenAdd}
            className="flex items-center gap-1.5 px-3.5 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded-lg text-xs transition-colors shadow-sm"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Add Guide</span>
          </button>
        </div>
      </div>

      {/* City Filters & Search Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pb-4 border-b border-zinc-800/80 mb-6">
        {/* 4 City Options Only */}
        <div className="flex items-center gap-1.5 overflow-x-auto w-full sm:w-auto">
          <button
            onClick={() => setSelectedCity('all')}
            className={`px-3 py-1 rounded-lg text-xs font-medium transition-colors ${
              selectedCity === 'all'
                ? 'bg-zinc-800 text-white'
                : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            All Cities
          </button>
          {SUPPORTED_CITIES.map((c) => (
            <button
              key={c}
              onClick={() => setSelectedCity(c)}
              className={`px-3 py-1 rounded-lg text-xs font-medium transition-colors whitespace-nowrap flex items-center gap-1 ${
                selectedCity === c
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <MapPin className="w-3 h-3 text-zinc-500" />
              <span>{c}</span>
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="relative w-full sm:w-60">
          <Search className="w-3.5 h-3.5 text-zinc-500 absolute left-2.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search guide name or language..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-8 pr-3 py-1.5 bg-zinc-900 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-500"
          />
        </div>
      </div>

      {/* Guide Create/Edit Modal (Clean & Essential Fields Only) */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div className="w-full max-w-md bg-zinc-900 border border-zinc-800 rounded-xl p-5 shadow-2xl overflow-y-auto">
            <div className="flex items-center justify-between pb-3 border-b border-zinc-800 mb-4">
              <h3 className="text-xs font-bold text-white uppercase tracking-wider">
                {editingId ? 'Edit Guide' : 'Add New Guide'}
              </h3>
              <button onClick={resetForm} className="text-zinc-500 hover:text-white">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSaveGuide} className="space-y-3 text-xs">
              <div>
                <label className="block text-zinc-300 mb-1">Guide Full Name *</label>
                <input
                  type="text"
                  value={guideName}
                  onChange={(e) => setGuideName(e.target.value)}
                  placeholder="e.g. Rahul Sharma"
                  required
                  className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-zinc-300 mb-1">City *</label>
                  <select
                    value={guideCity}
                    onChange={(e) => setGuideCity(e.target.value as SupportedCity)}
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  >
                    {SUPPORTED_CITIES.map((c) => (
                      <option key={c} value={c}>
                        {c}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-zinc-300 mb-1">Daily Rate ($/day) *</label>
                  <input
                    type="number"
                    min="0"
                    step="5"
                    value={guideRate}
                    onChange={(e) => setGuideRate(parseFloat(e.target.value) || 0)}
                    required
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-zinc-300 mb-1">Contact Phone</label>
                <input
                  type="text"
                  value={guidePhone}
                  onChange={(e) => setGuidePhone(e.target.value)}
                  placeholder="+91 98765-43210"
                  className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                />
              </div>

              <div>
                <label className="block text-zinc-300 mb-1">Languages (comma-separated)</label>
                <input
                  type="text"
                  value={guideLanguages}
                  onChange={(e) => setGuideLanguages(e.target.value)}
                  placeholder="English, Hindi, French, Spanish"
                  className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                />
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-zinc-800">
                <button
                  type="button"
                  onClick={resetForm}
                  disabled={isSaving}
                  className="px-3 py-1.5 text-zinc-400 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSaving}
                  className="flex items-center gap-1.5 px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded disabled:opacity-50"
                >
                  {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                  <span>{editingId ? 'Update in Supabase' : 'Save Guide'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Guide Cards Grid */}
      {filteredGuides.length === 0 ? (
        <div className="py-12 text-center text-xs text-zinc-500 border border-zinc-800/80 rounded-xl bg-zinc-900/20">
          No tour guides registered {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click "+ Add Guide" to insert into Supabase.
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {filteredGuides.map((guide) => {
            const displayName = guide.name || `${guide.first_name || ''} ${guide.last_name || ''}`.trim();
            return (
              <div
                key={guide.id}
                className="p-3.5 rounded-xl bg-zinc-900/80 border border-zinc-800 flex flex-col justify-between hover:border-zinc-700 transition-colors"
              >
                <div>
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <h3 className="font-semibold text-xs text-white">
                        {displayName}
                      </h3>
                      <span className="text-[11px] text-zinc-400 flex items-center gap-1 mt-0.5">
                        <MapPin className="w-3 h-3 text-zinc-500" />
                        <span>{guide.city || 'Mumbai'}</span>
                      </span>
                    </div>
                    <span className="font-mono text-xs font-semibold text-zinc-200 bg-zinc-950 px-2 py-0.5 rounded border border-zinc-800">
                      ${guide.daily_rate}/day
                    </span>
                  </div>

                  {guide.contact_number && (
                    <p className="text-[11px] text-zinc-400 flex items-center gap-1.5 mb-2">
                      <Phone className="w-3 h-3 text-zinc-500" />
                      <span>{guide.contact_number}</span>
                    </p>
                  )}

                  {/* Languages */}
                  <div className="flex flex-wrap gap-1 mb-2">
                    {guide.languages?.map((lang, i) => (
                      <span key={i} className="text-[9px] px-1.5 py-0.2 rounded bg-zinc-950 text-zinc-300 border border-zinc-800">
                        {lang}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-zinc-800/80 flex items-center justify-between text-[11px]">
                  <span className="text-zinc-400 text-[10px]">Certified Guide</span>

                  {/* Action buttons (Edit / Delete) */}
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => handleEditGuide(guide)}
                      className="p-1 rounded hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors"
                      title="Edit in Supabase"
                    >
                      <Edit2 className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => handleDeleteGuide(guide.id, displayName)}
                      className="p-1 rounded hover:bg-zinc-800 text-zinc-400 hover:text-red-400 transition-colors"
                      title="Delete from Supabase"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

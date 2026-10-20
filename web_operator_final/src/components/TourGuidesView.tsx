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
      contact_number: guidePhone.trim(),
      daily_rate: Number(guideRate) || 150,
      languages: guideLanguages.split(',').map(s => s.trim()).filter(Boolean),
      is_active: true,
    };

    try {
      if (editingId) {
        const res = await dbService.updateTourGuide({ id: editingId, ...guidePayload } as TourGuide);
        if (res.error) throw new Error(res.error);
        setNotification({ type: 'success', message: 'Tour guide updated in Supabase.' });
      } else {
        const res = await dbService.createTourGuide(guidePayload);
        if (res.error) throw new Error(res.error);
        setNotification({ type: 'success', message: 'Tour guide created in Supabase.' });
      }
      await loadGuides();
      resetForm();
    } catch (err: any) {
      setNotification({ type: 'error', message: err.message || 'Operation failed' });
    } finally {
      setIsSaving(false);
    }
  };

  const handleDeleteGuide = async (id: string, name: string) => {
    if (confirm(`Remove guide "${name}" from Supabase?`)) {
      try {
        const res = await dbService.deleteTourGuide(id);
        if (res.error) throw new Error(res.error);
        setNotification({ type: 'success', message: 'Tour guide removed from database.' });
        setGuides(prev => prev.filter(g => g.id !== id));
      } catch (err: any) {
        setNotification({ type: 'error', message: err.message || 'Delete failed' });
      }
    }
  };

  const filteredGuides = guides.filter(g => {
    const displayName = g.name || `${g.first_name || ''} ${g.last_name || ''}`.trim();
    const matchesSearch = displayName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          g.languages?.some(l => l.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchesSearch;
  });

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8">
      {/* Toast Notification */}
      {notification && (
        <div className={`mb-6 p-3.5 rounded-2xl border text-xs flex items-center justify-between transition-all ${
          notification.type === 'success' 
            ? 'bg-emerald-50 border-emerald-200 text-emerald-800' 
            : 'bg-red-50 border-red-200 text-red-800'
        }`}>
          <div className="flex items-center gap-2.5">
            {notification.type === 'success' ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
            ) : (
              <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
            )}
            <span className="font-medium">{notification.message}</span>
          </div>
          <button onClick={() => setNotification(null)} className="text-[#9AA0A6] hover:text-[#1A1A1A]">
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-slate-200 mb-8">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-[#1A1A1A] flex items-center gap-3">
            <span>Tour Guides</span>
            <span className="text-xs font-semibold text-[#0A2647] bg-[#F5F6F8] px-3 py-1 rounded-full border border-slate-200">
              {guides.length} Certified Guides
            </span>
          </h1>
          <p className="text-xs text-[#9AA0A6] mt-1.5">
            Manage your certified local guides across Mumbai, Udaipur, Jaipur, and Goa.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={loadGuides}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-4 py-2 bg-white hover:bg-[#F5F6F8] border border-slate-200 rounded-full text-xs text-[#1A1A1A] font-semibold transition-all shadow-xs active:scale-[0.99]"
          >
            <RefreshCw className={`w-3.5 h-3.5 text-[#9AA0A6] ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>

          <button
            onClick={handleOpenAdd}
            className="flex items-center gap-1.5 px-5 py-2 bg-[#0A2647] hover:bg-[#081f3a] text-white rounded-full text-xs font-semibold transition-all shadow-md shadow-[#0A2647]/15 active:scale-[0.99]"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>Add Guide</span>
          </button>
        </div>
      </div>

      {/* City Filters & Search Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 pb-4 border-b border-slate-100 mb-8">
        {/* City Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto w-full sm:w-auto pb-1">
          <button
            onClick={() => setSelectedCity('all')}
            className={`px-4 py-1.5 rounded-full text-xs font-semibold transition-all ${
              selectedCity === 'all'
                ? 'bg-[#0A2647] text-white shadow-sm'
                : 'bg-white text-[#9AA0A6] hover:text-[#1A1A1A] border border-slate-200'
            }`}
          >
            All Cities
          </button>
          {SUPPORTED_CITIES.map((c) => (
            <button
              key={c}
              onClick={() => setSelectedCity(c)}
              className={`px-4 py-1.5 rounded-full text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1 ${
                selectedCity === c
                  ? 'bg-[#0A2647] text-white shadow-sm'
                  : 'bg-white text-[#9AA0A6] hover:text-[#1A1A1A] border border-slate-200'
              }`}
            >
              <MapPin className="w-3 h-3 text-[#9AA0A6]" />
              <span>{c}</span>
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="relative w-full sm:w-64">
          <Search className="w-3.5 h-3.5 text-[#9AA0A6] absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search guide name or language..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-9 pr-3.5 py-2 bg-[#F5F6F8] border border-slate-200 rounded-full text-xs text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
          />
        </div>
      </div>

      {/* Guide Create/Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="w-full max-w-md bg-white border border-slate-100 rounded-3xl p-6 shadow-2xl animate-in fade-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-base font-bold text-[#1A1A1A]">
                {editingId ? 'Edit Guide' : 'Add New Guide'}
              </h3>
              <button onClick={resetForm} className="text-[#9AA0A6] hover:text-[#1A1A1A]">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSaveGuide} className="space-y-3.5 text-xs">
              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Full Name *</label>
                <input
                  type="text"
                  value={guideName}
                  onChange={(e) => setGuideName(e.target.value)}
                  placeholder="e.g. Ramesh Kulkarni"
                  required
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#1A1A1A] font-semibold mb-1">City *</label>
                  <select
                    value={guideCity}
                    onChange={(e) => setGuideCity(e.target.value as SupportedCity)}
                    className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] focus:outline-none focus:border-[#0A2647] font-medium"
                  >
                    {SUPPORTED_CITIES.map(c => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-[#1A1A1A] font-semibold mb-1">Daily Rate (₹)</label>
                  <input
                    type="number"
                    value={guideRate}
                    onChange={(e) => setGuideRate(parseFloat(e.target.value) || 0)}
                    required
                    className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] focus:outline-none focus:border-[#0A2647] font-medium font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Contact Phone</label>
                <input
                  type="text"
                  value={guidePhone}
                  onChange={(e) => setGuidePhone(e.target.value)}
                  placeholder="+91 98200 12345"
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div>
                <label className="block text-[#1A1A1A] font-semibold mb-1">Languages (comma-separated)</label>
                <input
                  type="text"
                  value={guideLanguages}
                  onChange={(e) => setGuideLanguages(e.target.value)}
                  placeholder="English, Hindi, Marathi, French"
                  className="w-full px-3.5 py-2.5 bg-[#F5F6F8] border border-slate-200 rounded-xl text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] font-medium"
                />
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={resetForm}
                  className="px-4 py-2 text-[#9AA0A6] hover:text-[#1A1A1A] font-medium transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSaving}
                  className="px-5 py-2 bg-[#0A2647] hover:bg-[#081f3a] text-white font-semibold rounded-full shadow-md shadow-[#0A2647]/15 transition-all flex items-center gap-1.5"
                >
                  {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                  <span>{editingId ? 'Update Guide' : 'Save Guide'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Guide Cards Grid */}
      {filteredGuides.length === 0 ? (
        <div className="py-20 text-center rounded-3xl bg-white border border-slate-100 shadow-[0_8px_30px_rgb(0,0,0,0.03)] p-8">
          <UserCheck className="w-10 h-10 text-[#9AA0A6] mx-auto mb-3" />
          <h3 className="text-base font-bold text-[#1A1A1A]">No tour guides registered</h3>
          <p className="text-xs text-[#9AA0A6] max-w-sm mx-auto mt-1 mb-5">
            No guides found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click &quot;Add Guide&quot; to insert into Supabase.
          </p>
          <button
            onClick={handleOpenAdd}
            className="px-5 py-2 bg-[#0A2647] text-white rounded-full text-xs font-semibold shadow-sm hover:bg-[#081f3a] transition-colors"
          >
            + Add New Guide
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredGuides.map((guide) => {
            const displayName = guide.name || `${guide.first_name || ''} ${guide.last_name || ''}`.trim();
            return (
              <div
                key={guide.id}
                className="p-5 rounded-2xl sm:rounded-3xl bg-white border border-slate-100 shadow-[0_4px_25px_rgb(0,0,0,0.03)] hover:shadow-[0_12px_35px_rgba(10,38,71,0.07)] flex flex-col justify-between transition-all"
              >
                <div>
                  <div className="flex items-start justify-between mb-2.5">
                    <div>
                      <h3 className="font-bold text-sm text-[#1A1A1A]">
                        {displayName}
                      </h3>
                      <span className="text-xs text-[#9AA0A6] flex items-center gap-1 mt-0.5">
                        <MapPin className="w-3 h-3 text-[#9AA0A6]" />
                        <span>{guide.city || 'Mumbai'}</span>
                      </span>
                    </div>
                    <span className="font-mono text-xs font-bold text-[#0A2647] bg-[#F5F6F8] px-2.5 py-1 rounded-full border border-slate-200">
                      ₹{guide.daily_rate}/day
                    </span>
                  </div>

                  {guide.contact_number && (
                    <p className="text-xs text-[#9AA0A6] flex items-center gap-1.5 mb-2.5">
                      <Phone className="w-3 h-3 text-[#9AA0A6]" />
                      <span>{guide.contact_number}</span>
                    </p>
                  )}

                  {/* Languages */}
                  <div className="flex flex-wrap gap-1 mb-3">
                    {guide.languages?.map((lang, i) => (
                      <span key={i} className="text-[10px] px-2.5 py-0.5 rounded-full bg-[#F5F6F8] text-[#1A1A1A] border border-slate-200">
                        {lang}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                  <span className="text-[#9AA0A6] text-[11px] font-medium">Verified Partner</span>

                  {/* Action buttons (Edit / Delete) */}
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => handleEditGuide(guide)}
                      className="p-1.5 rounded-full hover:bg-[#F5F6F8] text-[#9AA0A6] hover:text-[#0A2647] transition-colors"
                      title="Edit in Supabase"
                    >
                      <Edit2 className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => handleDeleteGuide(guide.id, displayName)}
                      className="p-1.5 rounded-full hover:bg-red-50 text-[#9AA0A6] hover:text-red-500 transition-colors"
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

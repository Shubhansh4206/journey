'use client';

import React, { useState, useEffect } from 'react';
import { 
  OperatorHotel, 
  OperatorPlace, 
  OperatorActivity, 
  OperatorTransport, 
  TourOperator,
  SUPPORTED_CITIES,
  SupportedCity
} from '../lib/types';
import { dbService } from '../lib/dbService';
import { 
  Building2, 
  Compass, 
  Car, 
  MapPin, 
  Plus, 
  Clock, 
  Phone, 
  Check, 
  X,
  Edit2,
  Trash2,
  RefreshCw,
  AlertCircle,
  Database,
  Copy,
  CheckCircle2,
  DollarSign,
  Tag,
  Search
} from 'lucide-react';

interface TiedUpInventoryViewProps {
  operator: TourOperator;
}

export const TiedUpInventoryView: React.FC<TiedUpInventoryViewProps> = ({ operator }) => {
  const [activeTab, setActiveTab] = useState<'hotels' | 'places' | 'activities' | 'transport'>('hotels');
  const [selectedCity, setSelectedCity] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [notification, setNotification] = useState<{ type: 'success' | 'error' | 'info'; message: string } | null>(null);
  const [showSqlGuide, setShowSqlGuide] = useState(false);
  const [copiedSql, setCopiedSql] = useState(false);

  const [hotels, setHotels] = useState<OperatorHotel[]>([]);
  const [places, setPlaces] = useState<OperatorPlace[]>([]);
  const [activities, setActivities] = useState<OperatorActivity[]>([]);
  const [transport, setTransport] = useState<OperatorTransport[]>([]);

  // Modal / Form state
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Hotel Form
  const [hotelName, setHotelName] = useState('');
  const [hotelCity, setHotelCity] = useState<SupportedCity>('Mumbai');
  const [hotelAddress, setHotelAddress] = useState('');
  const [hotelStar, setHotelStar] = useState(5);
  const [hotelRate, setHotelRate] = useState(250);
  const [hotelAmenities, setHotelAmenities] = useState('wifi, breakfast_included, pool');
  const [hotelContact, setHotelContact] = useState('');
  const [hotelPhone, setHotelPhone] = useState('');

  // Place Form
  const [placeName, setPlaceName] = useState('');
  const [placeCity, setPlaceCity] = useState<SupportedCity>('Mumbai');
  const [placeDesc, setPlaceDesc] = useState('');
  const [placeFee, setPlaceFee] = useState(0);
  const [placeDuration, setPlaceDuration] = useState(60);
  const [placeTags, setPlaceTags] = useState('heritage, architecture, photography');

  // Activity Form
  const [actTitle, setActTitle] = useState('');
  const [actLocation, setActLocation] = useState('Mumbai');
  const [actCost, setActCost] = useState(120);
  const [actDuration, setActDuration] = useState(120);
  const [actType, setActType] = useState('cultural');
  const [actInclusions, setActInclusions] = useState('Guide, Entry Tickets');

  // Transport Form
  const [transVehicle, setTransVehicle] = useState('Innova Crysta Luxury');
  const [transCapacity, setTransCapacity] = useState(6);
  const [transCostDay, setTransCostDay] = useState(120);
  const [transCostKm, setTransCostKm] = useState(1.5);
  const [transVendor, setTransVendor] = useState('Fleet Partner');
  const [transPhone, setTransPhone] = useState('');
  const [transFeatures, setTransFeatures] = useState('AC, WiFi, Luggage Carrier');

  useEffect(() => {
    loadAllInventory();
  }, [operator?.id]);

  // Clear notifications after 5 seconds
  useEffect(() => {
    if (notification) {
      const timer = setTimeout(() => setNotification(null), 5000);
      return () => clearTimeout(timer);
    }
  }, [notification]);

  const loadAllInventory = async () => {
    setIsLoading(true);
    try {
      const [h, p, a, t] = await Promise.all([
        dbService.getOperatorHotels(operator?.id),
        dbService.getOperatorPlaces(operator?.id),
        dbService.getOperatorActivities(operator?.id),
        dbService.getOperatorTransport(operator?.id),
      ]);

      setHotels(h);
      setPlaces(p);
      setActivities(a);
      setTransport(t);
    } catch (e: any) {
      setNotification({
        type: 'error',
        message: e.message || 'Failed to fetch inventory from Supabase.'
      });
    } finally {
      setIsLoading(false);
    }
  };

  const resetForm = () => {
    setEditingId(null);
    setIsFormOpen(false);
    setIsSaving(false);
    const defaultCity: SupportedCity = selectedCity !== 'all' ? (selectedCity as SupportedCity) : 'Mumbai';
    
    // Hotel
    setHotelName('');
    setHotelCity(defaultCity);
    setHotelAddress('');
    setHotelStar(5);
    setHotelRate(250);
    setHotelAmenities('wifi, breakfast_included, pool');
    setHotelContact('');
    setHotelPhone('');
    // Place
    setPlaceName('');
    setPlaceCity(defaultCity);
    setPlaceDesc('');
    setPlaceFee(0);
    setPlaceDuration(60);
    setPlaceTags('heritage, architecture, photography');
    // Activity
    setActTitle('');
    setActLocation(defaultCity);
    setActCost(120);
    setActDuration(120);
    setActType('cultural');
    setActInclusions('Guide, Entry Tickets');
    // Transport
    setTransVehicle('Innova Crysta Luxury');
    setTransCapacity(6);
    setTransCostDay(120);
    setTransCostKm(1.5);
    setTransVendor('');
    setTransPhone('');
    setTransFeatures('AC, WiFi, Luggage Carrier');
  };

  // --- CRUD: HOTELS ---
  const handleEditHotel = (h: OperatorHotel) => {
    setEditingId(h.id);
    setHotelName(h.name);
    setHotelCity((h.city as SupportedCity) || 'Mumbai');
    setHotelAddress(h.address || '');
    setHotelStar(h.star_rating || 5);
    setHotelRate(h.contracted_rate_per_night);
    setHotelAmenities(h.amenities?.join(', ') || '');
    setHotelContact(h.contact_person || '');
    setHotelPhone(h.contact_phone || '');
    setIsFormOpen(true);
  };

  const handleSaveHotel = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    const hotelData: Partial<OperatorHotel> = {
      operator_id: operator?.id,
      name: hotelName.trim(),
      city: hotelCity,
      address: hotelAddress.trim(),
      star_rating: Number(hotelStar) || 5,
      contracted_rate_per_night: Number(hotelRate) || 0,
      amenities: hotelAmenities.split(',').map(s => s.trim()).filter(Boolean),
      contact_person: hotelContact.trim(),
      contact_phone: hotelPhone.trim(),
      is_active: true,
    };

    if (editingId) {
      const res = await dbService.updateOperatorHotel({ id: editingId, ...hotelData } as OperatorHotel);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Update Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Hotel updated in Supabase successfully.' });
      }
    } else {
      const res = await dbService.addOperatorHotel(hotelData);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Insert Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Hotel created in Supabase successfully.' });
      }
    }

    await loadAllInventory();
    resetForm();
  };

  const handleDeleteHotel = async (id: string) => {
    if (confirm('Delete this hotel tie-up from Supabase?')) {
      const res = await dbService.deleteOperatorHotel(id);
      if (res.error) {
        setNotification({ type: 'error', message: `Delete error: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Hotel removed from Supabase.' });
      }
      setHotels(prev => prev.filter(h => h.id !== id));
    }
  };

  // --- CRUD: PLACES ---
  const handleEditPlace = (p: OperatorPlace) => {
    setEditingId(p.id);
    setPlaceName(p.name);
    setPlaceCity((p.city as SupportedCity) || 'Mumbai');
    setPlaceDesc(p.description || '');
    setPlaceFee(p.entry_fee_per_person);
    setPlaceDuration(p.recommended_duration_minutes || 60);
    setPlaceTags(p.tags?.join(', ') || '');
    setIsFormOpen(true);
  };

  const handleSavePlace = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    const placeData: Partial<OperatorPlace> = {
      operator_id: operator?.id,
      name: placeName.trim(),
      city: placeCity,
      description: placeDesc.trim(),
      entry_fee_per_person: Number(placeFee) || 0,
      recommended_duration_minutes: Number(placeDuration) || 60,
      tags: placeTags.split(',').map(s => s.trim()).filter(Boolean),
      is_active: true,
    };

    if (editingId) {
      const res = await dbService.updateOperatorPlace({ id: editingId, ...placeData } as OperatorPlace);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Update Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Place updated in Supabase successfully.' });
      }
    } else {
      const res = await dbService.addOperatorPlace(placeData);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Insert Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Place created in Supabase successfully.' });
      }
    }

    await loadAllInventory();
    resetForm();
  };

  const handleDeletePlace = async (id: string) => {
    if (confirm('Delete this place of interest from Supabase?')) {
      const res = await dbService.deleteOperatorPlace(id);
      if (res.error) {
        setNotification({ type: 'error', message: `Delete error: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Place removed from Supabase.' });
      }
      setPlaces(prev => prev.filter(p => p.id !== id));
    }
  };

  // --- CRUD: ACTIVITIES ---
  const handleEditActivity = (a: OperatorActivity) => {
    setEditingId(a.id);
    setActTitle(a.title);
    setActLocation(a.location || 'Mumbai');
    setActCost(a.cost_per_person);
    setActDuration(a.duration_minutes);
    setActType(a.activity_type || 'cultural');
    setActInclusions(a.inclusions?.join(', ') || '');
    setIsFormOpen(true);
  };

  const handleSaveActivity = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    const actData: Partial<OperatorActivity> = {
      operator_id: operator?.id,
      title: actTitle.trim(),
      location: actLocation.trim(),
      cost_per_person: Number(actCost) || 0,
      duration_minutes: Number(actDuration) || 120,
      activity_type: actType,
      inclusions: actInclusions.split(',').map(s => s.trim()).filter(Boolean),
      is_active: true,
    };

    if (editingId) {
      const res = await dbService.updateOperatorActivity({ id: editingId, ...actData } as OperatorActivity);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Update Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Activity updated in Supabase successfully.' });
      }
    } else {
      const res = await dbService.addOperatorActivity(actData);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Insert Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Activity created in Supabase successfully.' });
      }
    }

    await loadAllInventory();
    resetForm();
  };

  const handleDeleteActivity = async (id: string) => {
    if (confirm('Delete this experience from Supabase?')) {
      const res = await dbService.deleteOperatorActivity(id);
      if (res.error) {
        setNotification({ type: 'error', message: `Delete error: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Activity removed from Supabase.' });
      }
      setActivities(prev => prev.filter(a => a.id !== id));
    }
  };

  // --- CRUD: TRANSPORT ---
  const handleEditTransport = (t: OperatorTransport) => {
    setEditingId(t.id);
    setTransVehicle(t.vehicle_type);
    setTransCapacity(t.capacity_passengers);
    setTransCostDay(t.cost_per_day || 120);
    setTransCostKm(t.cost_per_km || 1.5);
    setTransVendor(t.vendor_company_name || '');
    setTransPhone(t.contact_phone || '');
    setTransFeatures(t.features?.join(', ') || '');
    setIsFormOpen(true);
  };

  const handleSaveTransport = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    const transData: Partial<OperatorTransport> = {
      operator_id: operator?.id,
      vehicle_type: transVehicle.trim(),
      capacity_passengers: Number(transCapacity) || 4,
      cost_per_day: Number(transCostDay) || 0,
      cost_per_km: Number(transCostKm) || 0,
      vendor_company_name: transVendor.trim(),
      contact_phone: transPhone.trim(),
      features: transFeatures.split(',').map(s => s.trim()).filter(Boolean),
      is_active: true,
    };

    if (editingId) {
      const res = await dbService.updateOperatorTransport({ id: editingId, ...transData } as OperatorTransport);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Update Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Transport updated in Supabase successfully.' });
      }
    } else {
      const res = await dbService.addOperatorTransport(transData);
      if (res.error) {
        setNotification({ type: 'error', message: `Supabase Insert Warning: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Transport vehicle created in Supabase successfully.' });
      }
    }

    await loadAllInventory();
    resetForm();
  };

  const handleDeleteTransport = async (id: string) => {
    if (confirm('Delete this vehicle from Supabase?')) {
      const res = await dbService.deleteOperatorTransport(id);
      if (res.error) {
        setNotification({ type: 'error', message: `Delete error: ${res.error}` });
      } else {
        setNotification({ type: 'success', message: 'Transport vehicle removed from Supabase.' });
      }
      setTransport(prev => prev.filter(t => t.id !== id));
    }
  };

  const filteredHotels = hotels.filter(h => {
    const matchesSearch = h.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          h.city.toLowerCase().includes(searchQuery.toLowerCase());
    if (selectedCity === 'all') return matchesSearch;
    return matchesSearch && h.city.toLowerCase() === selectedCity.toLowerCase();
  });

  const filteredPlaces = places.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          p.city.toLowerCase().includes(searchQuery.toLowerCase());
    if (selectedCity === 'all') return matchesSearch;
    return matchesSearch && p.city.toLowerCase() === selectedCity.toLowerCase();
  });

  const filteredActivities = activities.filter(a => {
    const matchesSearch = a.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          (a.location && a.location.toLowerCase().includes(searchQuery.toLowerCase()));
    if (selectedCity === 'all') return matchesSearch;
    return matchesSearch && a.location && a.location.toLowerCase().includes(selectedCity.toLowerCase());
  });

  const filteredTransport = transport.filter(t => {
    return t.vehicle_type.toLowerCase().includes(searchQuery.toLowerCase()) ||
           (t.vendor_company_name && t.vendor_company_name.toLowerCase().includes(searchQuery.toLowerCase()));
  });

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8">
      {/* Toast Notification */}
      {notification && (
        <div className={`mb-6 p-3 rounded-lg border text-xs flex items-center justify-between transition-all ${
          notification.type === 'success' 
            ? 'bg-zinc-900 border-emerald-500/40 text-emerald-300' 
            : notification.type === 'error'
            ? 'bg-zinc-900 border-red-500/40 text-red-300'
            : 'bg-zinc-900 border-zinc-700 text-zinc-300'
        }`}>
          <div className="flex items-center gap-2">
            {notification.type === 'success' && <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />}
            {notification.type === 'error' && <AlertCircle className="w-4 h-4 text-red-400 shrink-0" />}
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
            <span>Tied-Up Partner Inventory</span>
            <span className="text-[11px] font-mono text-zinc-300 bg-zinc-900 px-2 py-0.5 rounded border border-zinc-800">
              Supabase CRUD
            </span>
          </h1>
          <p className="text-xs text-zinc-400 mt-0.5">
            Manage your contracted hotels, sightseeing landmarks, activities, and transport fleet.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={loadAllInventory}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 rounded-lg text-xs text-zinc-300 font-medium transition-colors"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>

          <button
            onClick={() => { resetForm(); setIsFormOpen(true); }}
            className="flex items-center gap-1.5 px-3.5 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold text-xs rounded-lg transition-colors shadow-sm"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>
              {activeTab === 'hotels' && 'Add Hotel'}
              {activeTab === 'places' && 'Add Place'}
              {activeTab === 'activities' && 'Add Activity'}
              {activeTab === 'transport' && 'Add Vehicle'}
            </span>
          </button>
        </div>
      </div>

      {/* Category Tabs & City Filters */}
      <div className="flex flex-col gap-4 border-b border-zinc-800 pb-4 mb-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          {/* Category Tabs */}
          <div className="flex gap-1.5 overflow-x-auto text-xs">
            <button
              onClick={() => { setActiveTab('hotels'); resetForm(); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors ${
                activeTab === 'hotels'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <Building2 className="w-3.5 h-3.5" />
              Hotels ({hotels.length})
            </button>
            <button
              onClick={() => { setActiveTab('places'); resetForm(); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors ${
                activeTab === 'places'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <MapPin className="w-3.5 h-3.5" />
              Places ({places.length})
            </button>
            <button
              onClick={() => { setActiveTab('activities'); resetForm(); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors ${
                activeTab === 'activities'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <Compass className="w-3.5 h-3.5" />
              Activities ({activities.length})
            </button>
            <button
              onClick={() => { setActiveTab('transport'); resetForm(); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors ${
                activeTab === 'transport'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <Car className="w-3.5 h-3.5" />
              Transport ({transport.length})
            </button>
          </div>

          {/* Search Box */}
          <div className="relative w-full sm:w-56">
            <Search className="w-3.5 h-3.5 text-zinc-500 absolute left-2.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search inventory..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-8 pr-3 py-1.5 bg-zinc-900 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-500"
            />
          </div>
        </div>

        {/* 4 Supported City Pills (Mumbai, Udaipur, Jaipur, Goa) */}
        <div className="flex items-center gap-1.5 overflow-x-auto text-xs pt-1 border-t border-zinc-800/60">
          <span className="text-zinc-500 text-[11px] mr-1 font-medium">City:</span>
          <button
            onClick={() => setSelectedCity('all')}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors ${
              selectedCity === 'all'
                ? 'bg-zinc-700 text-white'
                : 'text-zinc-400 hover:text-zinc-200 bg-zinc-900/60'
            }`}
          >
            All Cities
          </button>
          {SUPPORTED_CITIES.map((c) => (
            <button
              key={c}
              onClick={() => setSelectedCity(c)}
              className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors whitespace-nowrap flex items-center gap-1 ${
                selectedCity === c
                  ? 'bg-zinc-700 text-white'
                  : 'text-zinc-400 hover:text-zinc-200 bg-zinc-900/60'
              }`}
            >
              <MapPin className="w-2.5 h-2.5 text-zinc-400" />
              <span>{c}</span>
            </button>
          ))}
        </div>
      </div>

      {/* CRUD FORM DRAWER / MODAL */}
      {isFormOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div className="w-full max-w-lg bg-zinc-900 border border-zinc-800 rounded-xl p-5 shadow-2xl overflow-y-auto max-h-[90vh]">
            <div className="flex items-center justify-between pb-3 border-b border-zinc-800 mb-4">
              <h3 className="text-xs font-bold text-white uppercase tracking-wider">
                {editingId ? 'Edit' : 'Add'} {activeTab === 'hotels' ? 'Contracted Hotel' : activeTab === 'places' ? 'Sightseeing Place' : activeTab === 'activities' ? 'Activity / Tour' : 'Vehicle Fleet'}
              </h3>
              <button onClick={resetForm} className="text-zinc-500 hover:text-white">
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* HOTELS FORM */}
            {activeTab === 'hotels' && (
              <form onSubmit={handleSaveHotel} className="space-y-3 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Hotel / Resort Name *</label>
                    <input
                      type="text"
                      value={hotelName}
                      onChange={(e) => setHotelName(e.target.value)}
                      placeholder="e.g. The Taj Mahal Palace"
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">City *</label>
                    <select
                      value={hotelCity}
                      onChange={(e) => setHotelCity(e.target.value as SupportedCity)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Contracted Base Rate ($/night) *</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={hotelRate}
                      onChange={(e) => setHotelRate(parseFloat(e.target.value) || 0)}
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Star Rating (1-5)</label>
                    <input
                      type="number"
                      min="1"
                      max="5"
                      value={hotelStar}
                      onChange={(e) => setHotelStar(parseInt(e.target.value) || 5)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Address</label>
                  <input
                    type="text"
                    value={hotelAddress}
                    onChange={(e) => setHotelAddress(e.target.value)}
                    placeholder="e.g. Apollo Bunder, Colaba"
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Amenities (comma-separated)</label>
                  <input
                    type="text"
                    value={hotelAmenities}
                    onChange={(e) => setHotelAmenities(e.target.value)}
                    placeholder="wifi, breakfast_included, pool, spa, sea_view"
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Contact Person</label>
                    <input
                      type="text"
                      value={hotelContact}
                      onChange={(e) => setHotelContact(e.target.value)}
                      placeholder="Reservations Manager"
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Contact Phone</label>
                    <input
                      type="text"
                      value={hotelPhone}
                      onChange={(e) => setHotelPhone(e.target.value)}
                      placeholder="+91 22 6665 3366"
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-zinc-800">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-3 py-1.5 text-zinc-400 hover:text-white">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-1.5 px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Hotel'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* PLACES FORM */}
            {activeTab === 'places' && (
              <form onSubmit={handleSavePlace} className="space-y-3 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Place / Landmark Name *</label>
                    <input
                      type="text"
                      value={placeName}
                      onChange={(e) => setPlaceName(e.target.value)}
                      placeholder="e.g. Gateway of India / City Palace"
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">City *</label>
                    <select
                      value={placeCity}
                      onChange={(e) => setPlaceCity(e.target.value as SupportedCity)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Entry Fee ($)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={placeFee}
                      onChange={(e) => setPlaceFee(parseFloat(e.target.value) || 0)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Recommended Duration (Minutes)</label>
                    <input
                      type="number"
                      min="15"
                      step="15"
                      value={placeDuration}
                      onChange={(e) => setPlaceDuration(parseInt(e.target.value) || 60)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Tags (comma-separated)</label>
                  <input
                    type="text"
                    value={placeTags}
                    onChange={(e) => setPlaceTags(e.target.value)}
                    placeholder="monument, sea_view, photography, heritage"
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Description</label>
                  <textarea
                    rows={2}
                    value={placeDesc}
                    onChange={(e) => setPlaceDesc(e.target.value)}
                    placeholder="Iconic waterfront arch built during the British Raj..."
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-zinc-800">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-3 py-1.5 text-zinc-400 hover:text-white">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-1.5 px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Place'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* ACTIVITIES FORM */}
            {activeTab === 'activities' && (
              <form onSubmit={handleSaveActivity} className="space-y-3 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Activity Title *</label>
                    <input
                      type="text"
                      value={actTitle}
                      onChange={(e) => setActTitle(e.target.value)}
                      placeholder="e.g. Sunset Boat Cruise on Lake Pichola"
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Location City *</label>
                    <select
                      value={actLocation}
                      onChange={(e) => setActLocation(e.target.value)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Cost / Pax ($) *</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={actCost}
                      onChange={(e) => setActCost(parseFloat(e.target.value) || 0)}
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Duration (Mins)</label>
                    <input
                      type="number"
                      min="15"
                      step="15"
                      value={actDuration}
                      onChange={(e) => setActDuration(parseInt(e.target.value) || 120)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Type</label>
                    <select
                      value={actType}
                      onChange={(e) => setActType(e.target.value)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    >
                      <option value="cultural">Cultural</option>
                      <option value="adventure">Adventure</option>
                      <option value="culinary">Culinary</option>
                      <option value="leisure">Leisure</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Inclusions (comma-separated)</label>
                  <input
                    type="text"
                    value={actInclusions}
                    onChange={(e) => setActInclusions(e.target.value)}
                    placeholder="Private Boat, Champagne, Certified Historian Guide"
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-zinc-800">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-3 py-1.5 text-zinc-400 hover:text-white">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-1.5 px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Activity'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* TRANSPORT FORM */}
            {activeTab === 'transport' && (
              <form onSubmit={handleSaveTransport} className="space-y-3 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Vehicle Type *</label>
                    <input
                      type="text"
                      value={transVehicle}
                      onChange={(e) => setTransVehicle(e.target.value)}
                      placeholder="e.g. Toyota Innova Crysta / BMW 5-Series"
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Passenger Capacity *</label>
                    <input
                      type="number"
                      min="1"
                      max="60"
                      value={transCapacity}
                      onChange={(e) => setTransCapacity(parseInt(e.target.value) || 4)}
                      required
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Cost per Day ($)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={transCostDay}
                      onChange={(e) => setTransCostDay(parseFloat(e.target.value) || 0)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Cost per KM ($)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={transCostKm}
                      onChange={(e) => setTransCostKm(parseFloat(e.target.value) || 0)}
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-zinc-300 mb-1">Vendor / Fleet Partner</label>
                    <input
                      type="text"
                      value={transVendor}
                      onChange={(e) => setTransVendor(e.target.value)}
                      placeholder="e.g. Royal Rajasthan Chauffeurs"
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                  <div>
                    <label className="block text-zinc-300 mb-1">Vendor Phone</label>
                    <input
                      type="text"
                      value={transPhone}
                      onChange={(e) => setTransPhone(e.target.value)}
                      placeholder="+91 294 242 1234"
                      className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-zinc-300 mb-1">Features (comma-separated)</label>
                  <input
                    type="text"
                    value={transFeatures}
                    onChange={(e) => setTransFeatures(e.target.value)}
                    placeholder="AC, WiFi, Chauffeur Uniform, Luggage Carrier"
                    className="w-full px-2.5 py-1.5 bg-zinc-950 border border-zinc-800 rounded text-white focus:outline-none focus:border-zinc-500"
                  />
                </div>

                <div className="flex justify-end gap-2 pt-3 border-t border-zinc-800">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-3 py-1.5 text-zinc-400 hover:text-white">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-1.5 px-4 py-1.5 bg-white hover:bg-zinc-200 text-zinc-950 font-semibold rounded disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Vehicle'}</span>
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

      {/* ITEMS LIST (READ / UPDATE / DELETE) */}
      <div className="space-y-2.5">
        {/* HOTELS */}
        {activeTab === 'hotels' && (
          filteredHotels.length === 0 ? (
            <div className="py-12 text-center text-xs text-zinc-500 border border-zinc-800/80 rounded-xl bg-zinc-900/20">
              No hotels found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click "+ Add Hotel" to insert into Supabase.
            </div>
          ) : (
            filteredHotels.map((h) => (
              <div key={h.id} className="p-3.5 rounded-xl bg-zinc-900/80 border border-zinc-800 flex items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold text-xs text-white">{h.name}</h3>
                    <span className="text-[10px] font-mono px-1.5 py-0.2 rounded bg-zinc-800 text-zinc-300">
                      {h.star_rating}★
                    </span>
                    <span className="text-xs font-mono font-medium text-zinc-200">
                      ${h.contracted_rate_per_night}/night
                    </span>
                  </div>
                  <p className="text-[11px] text-zinc-400 flex items-center gap-1.5">
                    <span className="text-zinc-300 font-medium">{h.city}</span>
                    {h.address ? `• ${h.address}` : ''} 
                    {h.contact_phone ? `• ${h.contact_phone}` : ''}
                  </p>
                  <div className="flex flex-wrap gap-1">
                    {h.amenities?.map((am, i) => (
                      <span key={i} className="text-[9px] px-1.5 py-0.2 rounded bg-zinc-950 text-zinc-400 border border-zinc-800">
                        {am}
                      </span>
                    ))}
                  </div>
                </div>

                {/* CRUD actions */}
                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => handleEditHotel(h)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors"
                    title="Edit in Supabase"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeleteHotel(h.id)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-red-400 transition-colors"
                    title="Delete from Supabase"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* PLACES */}
        {activeTab === 'places' && (
          filteredPlaces.length === 0 ? (
            <div className="py-12 text-center text-xs text-zinc-500 border border-zinc-800/80 rounded-xl bg-zinc-900/20">
              No sightseeing spots found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click "+ Add Place" to insert into Supabase.
            </div>
          ) : (
            filteredPlaces.map((p) => (
              <div key={p.id} className="p-3.5 rounded-xl bg-zinc-900/80 border border-zinc-800 flex items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold text-xs text-white">{p.name}</h3>
                    <span className="text-[10px] text-zinc-300 font-medium">({p.city})</span>
                    <span className="text-xs font-mono text-zinc-200">
                      {p.entry_fee_per_person > 0 ? `$${p.entry_fee_per_person} entry` : 'Free entry'}
                    </span>
                    <span className="text-[10px] text-zinc-500">• {p.recommended_duration_minutes}m</span>
                  </div>
                  {p.description && <p className="text-[11px] text-zinc-400 line-clamp-1">{p.description}</p>}
                </div>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => handleEditPlace(p)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors"
                    title="Edit in Supabase"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeletePlace(p.id)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-red-400 transition-colors"
                    title="Delete from Supabase"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* ACTIVITIES */}
        {activeTab === 'activities' && (
          filteredActivities.length === 0 ? (
            <div className="py-12 text-center text-xs text-zinc-500 border border-zinc-800/80 rounded-xl bg-zinc-900/20">
              No experiences found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click "+ Add Activity" to insert into Supabase.
            </div>
          ) : (
            filteredActivities.map((a) => (
              <div key={a.id} className="p-3.5 rounded-xl bg-zinc-900/80 border border-zinc-800 flex items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold text-xs text-white">{a.title}</h3>
                    <span className="text-xs font-mono font-medium text-zinc-200">
                      ${a.cost_per_person}/pax
                    </span>
                    <span className="text-[10px] text-zinc-500">• {a.duration_minutes}m</span>
                    <span className="text-[9px] px-1.5 py-0.2 rounded bg-zinc-950 text-zinc-400 border border-zinc-800">
                      {a.activity_type}
                    </span>
                  </div>
                  <p className="text-[11px] text-zinc-400">{a.location} • Inclusions: {a.inclusions?.join(', ')}</p>
                </div>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => handleEditActivity(a)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors"
                    title="Edit in Supabase"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeleteActivity(a.id)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-red-400 transition-colors"
                    title="Delete from Supabase"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* TRANSPORT */}
        {activeTab === 'transport' && (
          filteredTransport.length === 0 ? (
            <div className="py-12 text-center text-xs text-zinc-500 border border-zinc-800/80 rounded-xl bg-zinc-900/20">
              No vehicle fleet found. Click "+ Add Vehicle" to insert into Supabase.
            </div>
          ) : (
            filteredTransport.map((t) => (
              <div key={t.id} className="p-3.5 rounded-xl bg-zinc-900/80 border border-zinc-800 flex items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold text-xs text-white">{t.vehicle_type}</h3>
                    <span className="text-[10px] text-zinc-400">({t.capacity_passengers} Pax)</span>
                    <span className="text-xs font-mono font-medium text-zinc-200">
                      ${t.cost_per_day}/day • ${t.cost_per_km}/km
                    </span>
                  </div>
                  <p className="text-[11px] text-zinc-400">
                    {t.vendor_company_name ? `${t.vendor_company_name} • ` : ''}
                    Features: {t.features?.join(', ')}
                  </p>
                </div>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => handleEditTransport(t)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors"
                    title="Edit in Supabase"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeleteTransport(t.id)}
                    className="p-1.5 rounded hover:bg-zinc-800 text-zinc-400 hover:text-red-400 transition-colors"
                    title="Delete from Supabase"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )
        )}
      </div>
    </div>
  );
};

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
  PRESET_HOTELS, 
  PRESET_PLACES, 
  PRESET_ACTIVITIES, 
  PRESET_TRANSPORT,
  PresetHotel,
  PresetPlace,
  PresetActivity,
  PresetTransport
} from '../lib/presets';
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
  Search,
  Sparkles,
  Layers
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
  const [isSyncingAll, setIsSyncingAll] = useState(false);
  const [notification, setNotification] = useState<{ type: 'success' | 'error' | 'info'; message: string } | null>(null);

  const [hotels, setHotels] = useState<OperatorHotel[]>([]);
  const [places, setPlaces] = useState<OperatorPlace[]>([]);
  const [activities, setActivities] = useState<OperatorActivity[]>([]);
  const [transport, setTransport] = useState<OperatorTransport[]>([]);

  // Modal / Form state
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Hotel Form
  const [hotelName, setHotelName] = useState(PRESET_HOTELS[0].name);
  const [hotelCity, setHotelCity] = useState<SupportedCity>(PRESET_HOTELS[0].city as SupportedCity);
  const [hotelAddress, setHotelAddress] = useState(PRESET_HOTELS[0].address);
  const [hotelStar, setHotelStar] = useState(PRESET_HOTELS[0].star_rating);
  const [hotelRate, setHotelRate] = useState(PRESET_HOTELS[0].contracted_rate_per_night);
  const [hotelAmenities, setHotelAmenities] = useState(PRESET_HOTELS[0].amenities.join(', '));
  const [hotelContact, setHotelContact] = useState(PRESET_HOTELS[0].contact_person);
  const [hotelPhone, setHotelPhone] = useState(PRESET_HOTELS[0].contact_phone);
  const [hotelLat, setHotelLat] = useState<number>(PRESET_HOTELS[0].latitude);
  const [hotelLng, setHotelLng] = useState<number>(PRESET_HOTELS[0].longitude);

  // Place Form
  const [placeName, setPlaceName] = useState(PRESET_PLACES[0].name);
  const [placeCity, setPlaceCity] = useState<SupportedCity>(PRESET_PLACES[0].city as SupportedCity);
  const [placeDesc, setPlaceDesc] = useState(PRESET_PLACES[0].description);
  const [placeFee, setPlaceFee] = useState(PRESET_PLACES[0].entry_fee_per_person);
  const [placeDuration, setPlaceDuration] = useState(PRESET_PLACES[0].recommended_duration_minutes);
  const [placeTags, setPlaceTags] = useState(PRESET_PLACES[0].tags.join(', '));
  const [placeLat, setPlaceLat] = useState<number>(PRESET_PLACES[0].latitude);
  const [placeLng, setPlaceLng] = useState<number>(PRESET_PLACES[0].longitude);

  // Activity Form
  const [actTitle, setActTitle] = useState(PRESET_ACTIVITIES[0].title);
  const [actLocation, setActLocation] = useState(PRESET_ACTIVITIES[0].location);
  const [actCost, setActCost] = useState(PRESET_ACTIVITIES[0].cost_per_person);
  const [actDuration, setActDuration] = useState(PRESET_ACTIVITIES[0].duration_minutes);
  const [actType, setActType] = useState(PRESET_ACTIVITIES[0].activity_type);
  const [actInclusions, setActInclusions] = useState(PRESET_ACTIVITIES[0].inclusions.join(', '));
  const [actLat, setActLat] = useState<number>(PRESET_ACTIVITIES[0].latitude);
  const [actLng, setActLng] = useState<number>(PRESET_ACTIVITIES[0].longitude);

  // Transport Form
  const [transVehicle, setTransVehicle] = useState(PRESET_TRANSPORT[0].vehicle_type);
  const [transCapacity, setTransCapacity] = useState(PRESET_TRANSPORT[0].capacity_passengers);
  const [transCostDay, setTransCostDay] = useState(PRESET_TRANSPORT[0].cost_per_day);
  const [transCostKm, setTransCostKm] = useState(PRESET_TRANSPORT[0].cost_per_km);
  const [transVendor, setTransVendor] = useState(PRESET_TRANSPORT[0].vendor_company_name);
  const [transPhone, setTransPhone] = useState(PRESET_TRANSPORT[0].contact_phone);
  const [transFeatures, setTransFeatures] = useState(PRESET_TRANSPORT[0].features.join(', '));
  const [transLat, setTransLat] = useState<number>(PRESET_TRANSPORT[0].latitude);
  const [transLng, setTransLng] = useState<number>(PRESET_TRANSPORT[0].longitude);

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

  // --- PRESET SELECTION HANDLERS ---
  const handleSelectPresetHotel = (name: string) => {
    const p = PRESET_HOTELS.find(x => x.name === name);
    if (!p) return;
    setHotelName(p.name);
    setHotelCity(p.city as SupportedCity);
    setHotelAddress(p.address);
    setHotelStar(p.star_rating);
    setHotelRate(p.contracted_rate_per_night);
    setHotelAmenities(p.amenities.join(', '));
    setHotelContact(p.contact_person);
    setHotelPhone(p.contact_phone);
    setHotelLat(p.latitude);
    setHotelLng(p.longitude);
  };

  const handleSelectPresetPlace = (name: string) => {
    const p = PRESET_PLACES.find(x => x.name === name);
    if (!p) return;
    setPlaceName(p.name);
    setPlaceCity(p.city as SupportedCity);
    setPlaceDesc(p.description);
    setPlaceFee(p.entry_fee_per_person);
    setPlaceDuration(p.recommended_duration_minutes);
    setPlaceTags(p.tags.join(', '));
    setPlaceLat(p.latitude);
    setPlaceLng(p.longitude);
  };

  const handleSelectPresetActivity = (title: string) => {
    const p = PRESET_ACTIVITIES.find(x => x.title === title);
    if (!p) return;
    setActTitle(p.title);
    setActLocation(p.location);
    setActCost(p.cost_per_person);
    setActDuration(p.duration_minutes);
    setActType(p.activity_type);
    setActInclusions(p.inclusions.join(', '));
    setActLat(p.latitude);
    setActLng(p.longitude);
  };

  const handleSelectPresetTransport = (vehicle: string) => {
    const p = PRESET_TRANSPORT.find(x => x.vehicle_type === vehicle);
    if (!p) return;
    setTransVehicle(p.vehicle_type);
    setTransCapacity(p.capacity_passengers);
    setTransCostDay(p.cost_per_day);
    setTransCostKm(p.cost_per_km);
    setTransVendor(p.vendor_company_name);
    setTransPhone(p.contact_phone);
    setTransFeatures(p.features.join(', '));
    setTransLat(p.latitude);
    setTransLng(p.longitude);
  };

  const resetForm = () => {
    setEditingId(null);
    setIsFormOpen(false);
    setIsSaving(false);
    
    // Default to first preset in each category
    handleSelectPresetHotel(PRESET_HOTELS[0].name);
    handleSelectPresetPlace(PRESET_PLACES[0].name);
    handleSelectPresetActivity(PRESET_ACTIVITIES[0].title);
    handleSelectPresetTransport(PRESET_TRANSPORT[0].vehicle_type);
  };

  // --- 1-CLICK SYNC ALL HARDCODED PRESETS TO SUPABASE ---
  const handleSyncAllPresets = async () => {
    setIsSyncingAll(true);
    try {
      let addedCount = 0;
      
      // 1. Hotels
      for (const ph of PRESET_HOTELS) {
        const exists = hotels.some(h => h.name.toLowerCase() === ph.name.toLowerCase());
        if (!exists) {
          await dbService.addOperatorHotel({
            operator_id: operator?.id,
            name: ph.name,
            city: ph.city as SupportedCity,
            address: ph.address,
            star_rating: ph.star_rating,
            contracted_rate_per_night: ph.contracted_rate_per_night,
            amenities: ph.amenities,
            contact_person: ph.contact_person,
            contact_phone: ph.contact_phone,
            latitude: ph.latitude,
            longitude: ph.longitude,
            is_active: true
          });
          addedCount++;
        }
      }

      // 2. Places
      for (const pp of PRESET_PLACES) {
        const exists = places.some(p => p.name.toLowerCase() === pp.name.toLowerCase());
        if (!exists) {
          await dbService.addOperatorPlace({
            operator_id: operator?.id,
            name: pp.name,
            city: pp.city as SupportedCity,
            description: pp.description,
            entry_fee_per_person: pp.entry_fee_per_person,
            recommended_duration_minutes: pp.recommended_duration_minutes,
            tags: pp.tags,
            latitude: pp.latitude,
            longitude: pp.longitude,
            is_active: true
          });
          addedCount++;
        }
      }

      // 3. Activities
      for (const pa of PRESET_ACTIVITIES) {
        const exists = activities.some(a => a.title.toLowerCase() === pa.title.toLowerCase());
        if (!exists) {
          await dbService.addOperatorActivity({
            operator_id: operator?.id,
            title: pa.title,
            location: pa.location,
            cost_per_person: pa.cost_per_person,
            duration_minutes: pa.duration_minutes,
            activity_type: pa.activity_type,
            inclusions: pa.inclusions,
            latitude: pa.latitude,
            longitude: pa.longitude,
            is_active: true
          });
          addedCount++;
        }
      }

      // 4. Transport
      for (const pt of PRESET_TRANSPORT) {
        const exists = transport.some(t => t.vehicle_type.toLowerCase() === pt.vehicle_type.toLowerCase());
        if (!exists) {
          await dbService.addOperatorTransport({
            operator_id: operator?.id,
            vehicle_type: pt.vehicle_type,
            capacity_passengers: pt.capacity_passengers,
            cost_per_day: pt.cost_per_day,
            cost_per_km: pt.cost_per_km,
            vendor_company_name: pt.vendor_company_name,
            contact_phone: pt.contact_phone,
            features: pt.features,
            latitude: pt.latitude,
            longitude: pt.longitude,
            is_active: true
          });
          addedCount++;
        }
      }

      await loadAllInventory();
      setNotification({
        type: 'success',
        message: `Synced ${addedCount} curated options with geo-coordinates to Supabase!`
      });
    } catch (e: any) {
      setNotification({
        type: 'error',
        message: `Sync failed: ${e.message}`
      });
    } finally {
      setIsSyncingAll(false);
    }
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
    setHotelLat(h.latitude || 18.921700);
    setHotelLng(h.longitude || 72.833300);
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
      latitude: hotelLat != null ? Number(hotelLat) : null,
      longitude: hotelLng != null ? Number(hotelLng) : null,
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
        setNotification({ type: 'success', message: 'Hotel created in Supabase successfully with Lat/Lng.' });
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
    setPlaceLat(p.latitude || 18.922000);
    setPlaceLng(p.longitude || 72.834700);
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
      latitude: placeLat != null ? Number(placeLat) : null,
      longitude: placeLng != null ? Number(placeLng) : null,
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
        setNotification({ type: 'success', message: 'Place created in Supabase with Lat/Lng.' });
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
    setActLat(a.latitude || 19.166800);
    setActLng(a.longitude || 72.852600);
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
      latitude: actLat != null ? Number(actLat) : null,
      longitude: actLng != null ? Number(actLng) : null,
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
        setNotification({ type: 'success', message: 'Activity created in Supabase with Lat/Lng.' });
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
    setTransLat(t.latitude || 19.089600);
    setTransLng(t.longitude || 72.865600);
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
      latitude: transLat != null ? Number(transLat) : null,
      longitude: transLng != null ? Number(transLng) : null,
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
        setNotification({ type: 'success', message: 'Transport vehicle created in Supabase with Lat/Lng.' });
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
        <div className={`mb-6 p-3.5 rounded-2xl border text-xs flex items-center justify-between transition-all ${
          notification.type === 'success' 
            ? 'bg-emerald-50 border-emerald-200 text-emerald-800' 
            : notification.type === 'error'
            ? 'bg-rose-50 border-rose-200 text-rose-800'
            : 'bg-slate-50 border-slate-200 text-slate-800'
        }`}>
          <div className="flex items-center gap-2">
            {notification.type === 'success' && <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />}
            {notification.type === 'error' && <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />}
            <span className="font-medium">{notification.message}</span>
          </div>
          <button onClick={() => setNotification(null)} className="text-[#64748B] hover:text-[#0F172A]">
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-slate-200 mb-6">
        <div>
          <h1 className="text-2xl font-bold font-heading tracking-tight text-[#0F172A] flex items-center gap-3">
            <span>Partner Inventory</span>
            <span className="text-xs font-semibold text-emerald-800 bg-emerald-50 px-3 py-0.5 rounded-full border border-emerald-200/70">
              Verified Geo-Coordinates
            </span>
          </h1>
          <p className="text-xs text-[#64748B] mt-1.5">
            Curated hotels, sightseeing stops, curated activities, and chauffeur vehicle fleet.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={handleSyncAllPresets}
            disabled={isSyncingAll}
            className="flex items-center gap-1.5 px-4 py-2 bg-[#FAF9F6] hover:bg-slate-200/80 border border-slate-200/80 rounded-full text-xs text-[#0F172A] font-semibold transition-all shadow-xs disabled:opacity-50"
            title="Auto-insert all curated hotels, places, activities, and transport to Supabase"
          >
            <Sparkles className={`w-3.5 h-3.5 text-[#0F172A] ${isSyncingAll ? 'animate-spin' : ''}`} />
            <span>{isSyncingAll ? 'Syncing...' : '1-Click Sync Presets'}</span>
          </button>

          <button
            onClick={loadAllInventory}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-4 py-2 bg-white hover:bg-[#FAF9F6] border border-slate-200 rounded-full text-xs text-[#0F172A] font-semibold transition-all shadow-xs"
          >
            <RefreshCw className={`w-3.5 h-3.5 text-[#64748B] ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>

          <button
            onClick={() => { resetForm(); setIsFormOpen(true); }}
            className="flex items-center gap-1.5 px-5 py-2 bg-[#0F172A] hover:bg-[#081f3a] text-white font-semibold text-xs rounded-full transition-all shadow-md shadow-[#0F172A]/15"
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
      <div className="flex flex-col gap-4 border-b border-slate-100 pb-5 mb-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          {/* Category Tabs */}
          <div className="flex gap-2 overflow-x-auto text-xs">
            <button
              onClick={() => { setActiveTab('hotels'); resetForm(); }}
              className={`flex items-center gap-2 px-4 py-2 rounded-full font-semibold transition-all ${
                activeTab === 'hotels'
                  ? 'bg-[#0F172A] text-white shadow-xs'
                  : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
              }`}
            >
              <Building2 className="w-3.5 h-3.5" />
              <span>Hotels ({hotels.length})</span>
            </button>
            <button
              onClick={() => { setActiveTab('places'); resetForm(); }}
              className={`flex items-center gap-2 px-4 py-2 rounded-full font-semibold transition-all ${
                activeTab === 'places'
                  ? 'bg-[#0F172A] text-white shadow-xs'
                  : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
              }`}
            >
              <MapPin className="w-3.5 h-3.5" />
              <span>Places ({places.length})</span>
            </button>
            <button
              onClick={() => { setActiveTab('activities'); resetForm(); }}
              className={`flex items-center gap-2 px-4 py-2 rounded-full font-semibold transition-all ${
                activeTab === 'activities'
                  ? 'bg-[#0F172A] text-white shadow-xs'
                  : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
              }`}
            >
              <Compass className="w-3.5 h-3.5" />
              <span>Activities ({activities.length})</span>
            </button>
            <button
              onClick={() => { setActiveTab('transport'); resetForm(); }}
              className={`flex items-center gap-2 px-4 py-2 rounded-full font-semibold transition-all ${
                activeTab === 'transport'
                  ? 'bg-[#0F172A] text-white shadow-xs'
                  : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
              }`}
            >
              <Car className="w-3.5 h-3.5" />
              <span>Transport ({transport.length})</span>
            </button>
          </div>

          {/* Search Box */}
          <div className="relative w-full sm:w-64">
            <Search className="w-3.5 h-3.5 text-[#64748B] absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search inventory..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3.5 py-2 bg-white border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder-[#64748B] focus:outline-none focus:border-[#0F172A] font-medium shadow-2xs"
            />
          </div>
        </div>

        {/* 4 Supported City Pills (Mumbai, Udaipur, Jaipur, Goa) */}
        <div className="flex items-center gap-2 overflow-x-auto text-xs pt-2">
          <span className="text-[#64748B] text-xs mr-1 font-medium">City:</span>
          <button
            onClick={() => setSelectedCity('all')}
            className={`px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
              selectedCity === 'all'
                ? 'bg-[#0F172A] text-white shadow-xs'
                : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
            }`}
          >
            All Cities
          </button>
          {SUPPORTED_CITIES.map((c) => (
            <button
              key={c}
              onClick={() => setSelectedCity(c)}
              className={`px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1.5 ${
                selectedCity === c
                  ? 'bg-[#0F172A] text-white shadow-xs'
                  : 'bg-white text-[#64748B] hover:text-[#0F172A] border border-slate-200'
              }`}
            >
              <MapPin className="w-3 h-3 text-[#64748B]" />
              <span>{c}</span>
            </button>
          ))}
        </div>
      </div>

      {/* CRUD FORM DRAWER / MODAL */}
      {isFormOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
          <div className="w-full max-w-lg bg-white border border-slate-200 rounded-3xl p-6 shadow-2xl overflow-y-auto max-h-[90vh]">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-sm font-bold text-[#0F172A] font-heading flex items-center gap-2">
                <span>{editingId ? 'Edit' : 'Add'} {activeTab === 'hotels' ? 'Contracted Hotel' : activeTab === 'places' ? 'Sightseeing Place' : activeTab === 'activities' ? 'Activity / Tour' : 'Vehicle Fleet'}</span>
                <span className="text-[10px] font-mono text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/70">
                  Supabase DB
                </span>
              </h3>
              <button onClick={resetForm} className="p-1 rounded-full text-[#64748B] hover:text-[#0F172A] hover:bg-[#FAF9F6] transition-colors">
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* CURATED PRESET DROPDOWN */}
            <div className="bg-[#0F172A]/5 border border-[#0F172A]/15 rounded-2xl p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-1.5 text-xs font-bold text-[#0F172A] font-heading">
                  <Sparkles className="w-3.5 h-3.5 text-[#0F172A]" />
                  <span>⚡ Select Curated Preset</span>
                </div>
                <span className="text-[10px] font-semibold text-[#0F172A] bg-white px-2 py-0.5 rounded-full border border-slate-200">
                  Auto-Populate
                </span>
              </div>
              
              {activeTab === 'hotels' && (
                <select
                  value={hotelName}
                  onChange={(e) => handleSelectPresetHotel(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] font-medium shadow-2xs"
                >
                  {PRESET_HOTELS.map((p) => (
                    <option key={p.name} value={p.name}>
                      {p.name} ({p.city}) — ₹{p.contracted_rate_per_night}/nt [Lat: {p.latitude}, Lng: {p.longitude}]
                    </option>
                  ))}
                </select>
              )}

              {activeTab === 'places' && (
                <select
                  value={placeName}
                  onChange={(e) => handleSelectPresetPlace(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] font-medium shadow-2xs"
                >
                  {PRESET_PLACES.map((p) => (
                    <option key={p.name} value={p.name}>
                      {p.name} ({p.city}) — ₹{p.entry_fee_per_person} fee [Lat: {p.latitude}, Lng: {p.longitude}]
                    </option>
                  ))}
                </select>
              )}

              {activeTab === 'activities' && (
                <select
                  value={actTitle}
                  onChange={(e) => handleSelectPresetActivity(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] font-medium shadow-2xs"
                >
                  {PRESET_ACTIVITIES.map((p) => (
                    <option key={p.title} value={p.title}>
                      {p.title} ({p.location}) — ₹{p.cost_per_person}/pax [Lat: {p.latitude}, Lng: {p.longitude}]
                    </option>
                  ))}
                </select>
              )}

              {activeTab === 'transport' && (
                <select
                  value={transVehicle}
                  onChange={(e) => handleSelectPresetTransport(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] font-medium shadow-2xs"
                >
                  {PRESET_TRANSPORT.map((p) => (
                    <option key={p.vehicle_type} value={p.vehicle_type}>
                      {p.vehicle_type} — ₹{p.cost_per_day}/day [Lat: {p.latitude}, Lng: {p.longitude}]
                    </option>
                  ))}
                </select>
              )}
            </div>

            {/* HOTELS FORM */}
            {activeTab === 'hotels' && (
              <form onSubmit={handleSaveHotel} className="space-y-3.5 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Hotel / Resort Name *</label>
                    <input
                      type="text"
                      value={hotelName}
                      onChange={(e) => setHotelName(e.target.value)}
                      placeholder="e.g. The Taj Mahal Palace"
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">City *</label>
                    <select
                      value={hotelCity}
                      onChange={(e) => setHotelCity(e.target.value as SupportedCity)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Geo Coordinates Inputs */}
                <div className="grid grid-cols-2 gap-3 bg-emerald-50/60 p-3 rounded-2xl border border-emerald-200/80">
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Latitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={hotelLat ?? ''}
                      onChange={(e) => setHotelLat(parseFloat(e.target.value) || 0)}
                      placeholder="18.921700"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Longitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={hotelLng ?? ''}
                      onChange={(e) => setHotelLng(parseFloat(e.target.value) || 0)}
                      placeholder="72.833300"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Contracted Base Rate (₹/night) *</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={hotelRate}
                      onChange={(e) => setHotelRate(parseFloat(e.target.value) || 0)}
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-semibold"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Star Rating (1-5)</label>
                    <input
                      type="number"
                      min="1"
                      max="5"
                      value={hotelStar}
                      onChange={(e) => setHotelStar(parseInt(e.target.value) || 5)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Address</label>
                  <input
                    type="text"
                    value={hotelAddress}
                    onChange={(e) => setHotelAddress(e.target.value)}
                    placeholder="e.g. Apollo Bunder, Colaba"
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Amenities (comma-separated)</label>
                  <input
                    type="text"
                    value={hotelAmenities}
                    onChange={(e) => setHotelAmenities(e.target.value)}
                    placeholder="wifi, breakfast_included, pool, spa, sea_view"
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Contact Person</label>
                    <input
                      type="text"
                      value={hotelContact}
                      onChange={(e) => setHotelContact(e.target.value)}
                      placeholder="Reservations Manager"
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Contact Phone</label>
                    <input
                      type="text"
                      value={hotelPhone}
                      onChange={(e) => setHotelPhone(e.target.value)}
                      placeholder="+91 22 6665 3366"
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                </div>

                <div className="flex justify-end items-center gap-2 pt-4 border-t border-slate-100">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-4 py-2 text-xs font-semibold text-[#64748B] hover:text-[#0F172A] transition-colors">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-2 px-5 py-2.5 bg-[#0F172A] hover:bg-[#0F172A]/90 text-white font-semibold rounded-xl text-xs shadow-xs transition-all disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Hotel to Supabase'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* PLACES FORM */}
            {activeTab === 'places' && (
              <form onSubmit={handleSavePlace} className="space-y-3.5 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Place / Landmark Name *</label>
                    <input
                      type="text"
                      value={placeName}
                      onChange={(e) => setPlaceName(e.target.value)}
                      placeholder="e.g. Gateway of India / City Palace"
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">City *</label>
                    <select
                      value={placeCity}
                      onChange={(e) => setPlaceCity(e.target.value as SupportedCity)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Geo Coordinates Inputs */}
                <div className="grid grid-cols-2 gap-3 bg-emerald-50/60 p-3 rounded-2xl border border-emerald-200/80">
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Latitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={placeLat ?? ''}
                      onChange={(e) => setPlaceLat(parseFloat(e.target.value) || 0)}
                      placeholder="18.922000"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Longitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={placeLng ?? ''}
                      onChange={(e) => setPlaceLng(parseFloat(e.target.value) || 0)}
                      placeholder="72.834700"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Entry Fee (₹)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={placeFee}
                      onChange={(e) => setPlaceFee(parseFloat(e.target.value) || 0)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-semibold"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Recommended Duration (Minutes)</label>
                    <input
                      type="number"
                      min="15"
                      step="15"
                      value={placeDuration}
                      onChange={(e) => setPlaceDuration(parseInt(e.target.value) || 60)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Tags (comma-separated)</label>
                  <input
                    type="text"
                    value={placeTags}
                    onChange={(e) => setPlaceTags(e.target.value)}
                    placeholder="monument, sea_view, photography, heritage"
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Description</label>
                  <textarea
                    rows={2}
                    value={placeDesc}
                    onChange={(e) => setPlaceDesc(e.target.value)}
                    placeholder="Iconic waterfront arch built during the British Raj..."
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div className="flex justify-end items-center gap-2 pt-4 border-t border-slate-100">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-4 py-2 text-xs font-semibold text-[#64748B] hover:text-[#0F172A] transition-colors">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-2 px-5 py-2.5 bg-[#0F172A] hover:bg-[#0F172A]/90 text-white font-semibold rounded-xl text-xs shadow-xs transition-all disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Place to Supabase'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* ACTIVITIES FORM */}
            {activeTab === 'activities' && (
              <form onSubmit={handleSaveActivity} className="space-y-3.5 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Activity Title *</label>
                    <input
                      type="text"
                      value={actTitle}
                      onChange={(e) => setActTitle(e.target.value)}
                      placeholder="e.g. Bollywood Studio & Film City Guided Tour"
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Location City *</label>
                    <select
                      value={actLocation}
                      onChange={(e) => setActLocation(e.target.value)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    >
                      {SUPPORTED_CITIES.map((c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Geo Coordinates Inputs */}
                <div className="grid grid-cols-2 gap-3 bg-emerald-50/60 p-3 rounded-2xl border border-emerald-200/80">
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Latitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={actLat ?? ''}
                      onChange={(e) => setActLat(parseFloat(e.target.value) || 0)}
                      placeholder="19.166800"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Longitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={actLng ?? ''}
                      onChange={(e) => setActLng(parseFloat(e.target.value) || 0)}
                      placeholder="72.852600"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Cost / Pax (₹) *</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={actCost}
                      onChange={(e) => setActCost(parseFloat(e.target.value) || 0)}
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-semibold"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Duration (Mins)</label>
                    <input
                      type="number"
                      min="15"
                      step="15"
                      value={actDuration}
                      onChange={(e) => setActDuration(parseInt(e.target.value) || 120)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Type</label>
                    <select
                      value={actType}
                      onChange={(e) => setActType(e.target.value)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    >
                      <option value="cultural">Cultural</option>
                      <option value="adventure">Adventure</option>
                      <option value="culinary">Culinary</option>
                      <option value="leisure">Leisure</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Inclusions (comma-separated)</label>
                  <input
                    type="text"
                    value={actInclusions}
                    onChange={(e) => setActInclusions(e.target.value)}
                    placeholder="Round-trip Boat Ferry, UNESCO Entry Tickets, Certified Guide"
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div className="flex justify-end items-center gap-2 pt-4 border-t border-slate-100">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-4 py-2 text-xs font-semibold text-[#64748B] hover:text-[#0F172A] transition-colors">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-2 px-5 py-2.5 bg-[#0F172A] hover:bg-[#0F172A]/90 text-white font-semibold rounded-xl text-xs shadow-xs transition-all disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Activity to Supabase'}</span>
                  </button>
                </div>
              </form>
            )}

            {/* TRANSPORT FORM */}
            {activeTab === 'transport' && (
              <form onSubmit={handleSaveTransport} className="space-y-3.5 text-xs">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Vehicle Type *</label>
                    <input
                      type="text"
                      value={transVehicle}
                      onChange={(e) => setTransVehicle(e.target.value)}
                      placeholder="e.g. Toyota Innova Crysta Chauffeur SUV"
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Passenger Capacity *</label>
                    <input
                      type="number"
                      min="1"
                      max="60"
                      value={transCapacity}
                      onChange={(e) => setTransCapacity(parseInt(e.target.value) || 4)}
                      required
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-medium"
                    />
                  </div>
                </div>

                {/* Geo Coordinates Inputs */}
                <div className="grid grid-cols-2 gap-3 bg-emerald-50/60 p-3 rounded-2xl border border-emerald-200/80">
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Latitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={transLat ?? ''}
                      onChange={(e) => setTransLat(parseFloat(e.target.value) || 0)}
                      placeholder="19.089600"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-mono text-emerald-900 mb-1 flex items-center gap-1 font-semibold">
                      <MapPin className="w-3 h-3 text-emerald-700" /> Longitude (6 Decimals) *
                    </label>
                    <input
                      type="number"
                      step="0.000001"
                      value={transLng ?? ''}
                      onChange={(e) => setTransLng(parseFloat(e.target.value) || 0)}
                      placeholder="72.865600"
                      required
                      className="w-full px-3 py-2 bg-white border border-emerald-200 rounded-xl text-xs font-mono text-emerald-900 focus:outline-none focus:border-emerald-600 shadow-2xs"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Cost per Day (₹)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={transCostDay}
                      onChange={(e) => setTransCostDay(parseFloat(e.target.value) || 0)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-semibold"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Cost per KM (₹)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={transCostKm}
                      onChange={(e) => setTransCostKm(parseFloat(e.target.value) || 0)}
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all font-semibold"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Vendor / Fleet Partner</label>
                    <input
                      type="text"
                      value={transVendor}
                      onChange={(e) => setTransVendor(e.target.value)}
                      placeholder="e.g. Royal Chauffeur Fleet Mumbai"
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#0F172A] mb-1">Vendor Phone</label>
                    <input
                      type="text"
                      value={transPhone}
                      onChange={(e) => setTransPhone(e.target.value)}
                      placeholder="+91 22 4000 1234"
                      className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#0F172A] mb-1">Features (comma-separated)</label>
                  <input
                    type="text"
                    value={transFeatures}
                    onChange={(e) => setTransFeatures(e.target.value)}
                    placeholder="AC, WiFi, Uniformed Chauffeur, Luggage Carrier"
                    className="w-full px-3 py-2 bg-[#FAF9F6] border border-slate-200 rounded-xl text-xs text-[#0F172A] placeholder:text-[#64748B] focus:outline-none focus:border-[#0F172A] focus:bg-white transition-all"
                  />
                </div>

                <div className="flex justify-end items-center gap-2 pt-4 border-t border-slate-100">
                  <button type="button" onClick={resetForm} disabled={isSaving} className="px-4 py-2 text-xs font-semibold text-[#64748B] hover:text-[#0F172A] transition-colors">
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={isSaving}
                    className="flex items-center gap-2 px-5 py-2.5 bg-[#0F172A] hover:bg-[#0F172A]/90 text-white font-semibold rounded-xl text-xs shadow-xs transition-all disabled:opacity-50"
                  >
                    {isSaving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                    <span>{editingId ? 'Update in Supabase' : 'Save Vehicle to Supabase'}</span>
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

      {/* ITEMS LIST (READ / UPDATE / DELETE WITH GEO BADGES) */}
      <div className="space-y-3">
        {/* HOTELS */}
        {activeTab === 'hotels' && (
          filteredHotels.length === 0 ? (
            <div className="py-16 text-center text-xs text-[#64748B] border border-slate-200/80 rounded-2xl bg-white shadow-xs p-8">
              No hotels found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click &quot;+ Add Hotel&quot; or &quot;1-Click Sync Presets&quot; to populate your contracted partner stays.
            </div>
          ) : (
            filteredHotels.map((h) => (
              <div key={h.id} className="p-4 sm:p-5 rounded-2xl bg-white border border-slate-200/80 shadow-[0_2px_12px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgba(10,38,71,0.07)] flex items-center justify-between gap-4 transition-all">
                <div className="space-y-1.5 flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="font-bold font-heading text-sm text-[#0F172A]">{h.name}</h3>
                    <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-amber-50 text-amber-800 border border-amber-200/70">
                      {h.star_rating}★ Luxury
                    </span>
                    <span className="text-xs font-bold text-[#0F172A] font-heading">
                      ₹{h.contracted_rate_per_night}/night
                    </span>
                  </div>
                  
                  <p className="text-xs text-[#64748B] flex flex-wrap items-center gap-1.5">
                    <span className="text-[#0F172A] font-semibold">{h.city}</span>
                    {h.address ? `• ${h.address}` : ''} 
                    {h.contact_phone ? `• ${h.contact_phone}` : ''}
                  </p>

                  <div className="flex flex-wrap items-center gap-2 pt-1">
                    {/* Geo Coordinates Badge */}
                    {h.latitude != null && h.longitude != null ? (
                      <span className="inline-flex items-center gap-1.5 text-[11px] font-medium px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/70">
                        <MapPin className="w-3 h-3 text-emerald-600" />
                        Lat: {Number(h.latitude).toFixed(6)} | Lng: {Number(h.longitude).toFixed(6)}
                      </span>
                    ) : (
                      <span className="text-[11px] text-[#64748B]">
                        No Geo-Coordinates
                      </span>
                    )}

                    {h.amenities?.map((am, i) => (
                      <span key={i} className="text-[11px] font-medium px-2.5 py-0.5 rounded-lg bg-[#FAF9F6] text-[#0F172A] border border-slate-200/80">
                        {am}
                      </span>
                    ))}
                  </div>
                </div>

                {/* CRUD actions */}
                <div className="flex items-center gap-1.5 shrink-0">
                  <button
                    onClick={() => handleEditHotel(h)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-[#0F172A] hover:bg-[#FAF9F6] transition-colors"
                    title="Edit Hotel"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteHotel(h.id)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-rose-600 hover:bg-rose-50 transition-colors"
                    title="Delete Hotel"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* PLACES */}
        {activeTab === 'places' && (
          filteredPlaces.length === 0 ? (
            <div className="py-16 text-center text-xs text-[#64748B] border border-slate-200/80 rounded-2xl bg-white shadow-xs p-8">
              No sightseeing spots found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click &quot;+ Add Place&quot; or &quot;1-Click Sync Presets&quot; to populate curated sights.
            </div>
          ) : (
            filteredPlaces.map((p) => (
              <div key={p.id} className="p-4 sm:p-5 rounded-2xl bg-white border border-slate-200/80 shadow-[0_2px_12px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgba(10,38,71,0.07)] flex items-center justify-between gap-4 transition-all">
                <div className="space-y-1.5 flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="font-bold font-heading text-sm text-[#0F172A]">{p.name}</h3>
                    <span className="text-xs text-[#0F172A] font-semibold">({p.city})</span>
                    <span className="text-xs font-bold text-[#0F172A] font-heading">
                      {p.entry_fee_per_person > 0 ? `₹${p.entry_fee_per_person} entry` : 'Free entry'}
                    </span>
                    <span className="text-[11px] text-[#64748B] font-medium">• {p.recommended_duration_minutes}m duration</span>
                  </div>

                  {p.description && <p className="text-xs text-[#64748B] line-clamp-1">{p.description}</p>}

                  <div className="flex flex-wrap items-center gap-2 pt-1">
                    {/* Geo Coordinates Badge */}
                    {p.latitude != null && p.longitude != null ? (
                      <span className="inline-flex items-center gap-1.5 text-[11px] font-medium px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/70">
                        <MapPin className="w-3 h-3 text-emerald-600" />
                        Lat: {Number(p.latitude).toFixed(6)} | Lng: {Number(p.longitude).toFixed(6)}
                      </span>
                    ) : (
                      <span className="text-[11px] text-[#64748B]">
                        No Geo-Coordinates
                      </span>
                    )}

                    {p.tags?.map((t, i) => (
                      <span key={i} className="text-[11px] font-medium px-2.5 py-0.5 rounded-lg bg-[#FAF9F6] text-[#0F172A] border border-slate-200/80">
                        {t}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="flex items-center gap-1.5 shrink-0">
                  <button
                    onClick={() => handleEditPlace(p)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-[#0F172A] hover:bg-[#FAF9F6] transition-colors"
                    title="Edit Place"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeletePlace(p.id)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-rose-600 hover:bg-rose-50 transition-colors"
                    title="Delete Place"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* ACTIVITIES */}
        {activeTab === 'activities' && (
          filteredActivities.length === 0 ? (
            <div className="py-16 text-center text-xs text-[#64748B] border border-slate-200/80 rounded-2xl bg-white shadow-xs p-8">
              No experiences found {selectedCity !== 'all' ? `in ${selectedCity}` : ''}. Click &quot;+ Add Activity&quot; or &quot;1-Click Sync Presets&quot; to populate experiences.
            </div>
          ) : (
            filteredActivities.map((a) => (
              <div key={a.id} className="p-4 sm:p-5 rounded-2xl bg-white border border-slate-200/80 shadow-[0_2px_12px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgba(10,38,71,0.07)] flex items-center justify-between gap-4 transition-all">
                <div className="space-y-1.5 flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="font-bold font-heading text-sm text-[#0F172A]">{a.title}</h3>
                    <span className="text-xs font-bold text-[#0F172A] font-heading">
                      ₹{a.cost_per_person}/pax
                    </span>
                    <span className="text-[11px] text-[#64748B] font-medium">• {a.duration_minutes}m duration</span>
                    <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-[#0F172A]/5 text-[#0F172A] border border-[#0F172A]/15 capitalize">
                      {a.activity_type}
                    </span>
                  </div>

                  <p className="text-xs text-[#64748B]">{a.location} • Inclusions: {a.inclusions?.join(', ')}</p>

                  <div className="flex flex-wrap items-center gap-2 pt-1">
                    {/* Geo Coordinates Badge */}
                    {a.latitude != null && a.longitude != null ? (
                      <span className="inline-flex items-center gap-1.5 text-[11px] font-medium px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/70">
                        <MapPin className="w-3 h-3 text-emerald-600" />
                        Lat: {Number(a.latitude).toFixed(6)} | Lng: {Number(a.longitude).toFixed(6)}
                      </span>
                    ) : (
                      <span className="text-[11px] text-[#64748B]">
                        No Geo-Coordinates
                      </span>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-1.5 shrink-0">
                  <button
                    onClick={() => handleEditActivity(a)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-[#0F172A] hover:bg-[#FAF9F6] transition-colors"
                    title="Edit Activity"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteActivity(a.id)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-rose-600 hover:bg-rose-50 transition-colors"
                    title="Delete Activity"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))
          )
        )}

        {/* TRANSPORT */}
        {activeTab === 'transport' && (
          filteredTransport.length === 0 ? (
            <div className="py-16 text-center text-xs text-[#64748B] border border-slate-200/80 rounded-2xl bg-white shadow-xs p-8">
              No vehicle fleet found. Click &quot;+ Add Vehicle&quot; or &quot;1-Click Sync Presets&quot; to populate vehicles.
            </div>
          ) : (
            filteredTransport.map((t) => (
              <div key={t.id} className="p-4 sm:p-5 rounded-2xl bg-white border border-slate-200/80 shadow-[0_2px_12px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgba(10,38,71,0.07)] flex items-center justify-between gap-4 transition-all">
                <div className="space-y-1.5 flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="font-bold font-heading text-sm text-[#0F172A]">{t.vehicle_type}</h3>
                    <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-[#FAF9F6] text-[#0F172A] border border-slate-200">
                      {t.capacity_passengers} Pax Capacity
                    </span>
                    <span className="text-xs font-bold text-[#0F172A] font-heading">
                      ₹{t.cost_per_day}/day • ₹{t.cost_per_km}/km
                    </span>
                  </div>

                  <p className="text-xs text-[#64748B]">
                    {t.vendor_company_name ? `${t.vendor_company_name} • ` : ''}
                    Features: {t.features?.join(', ')}
                  </p>

                  <div className="flex flex-wrap items-center gap-2 pt-1">
                    {/* Geo Coordinates Badge */}
                    {t.latitude != null && t.longitude != null ? (
                      <span className="inline-flex items-center gap-1.5 text-[11px] font-medium px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/70">
                        <MapPin className="w-3 h-3 text-emerald-600" />
                        Lat: {Number(t.latitude).toFixed(6)} | Lng: {Number(t.longitude).toFixed(6)}
                      </span>
                    ) : (
                      <span className="text-[11px] text-[#64748B]">
                        No Geo-Coordinates
                      </span>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-1.5 shrink-0">
                  <button
                    onClick={() => handleEditTransport(t)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-[#0F172A] hover:bg-[#FAF9F6] transition-colors"
                    title="Edit Transport"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteTransport(t.id)}
                    className="p-2 rounded-xl text-[#64748B] hover:text-rose-600 hover:bg-rose-50 transition-colors"
                    title="Delete Transport"
                  >
                    <Trash2 className="w-4 h-4" />
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

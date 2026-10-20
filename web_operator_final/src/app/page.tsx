'use client';

import React, { useState, useEffect } from 'react';
import { TourOperator, TripRequest } from '../lib/types';
import { dbService } from '../lib/dbService';
import { Header } from '../components/Header';
import { AuthLogin } from '../components/AuthLogin';
import { DashboardView } from '../components/DashboardView';
import { ItineraryBuilder } from '../components/ItineraryBuilder';
import { TourGuidesView } from '../components/TourGuidesView';
import { TiedUpInventoryView } from '../components/TiedUpInventoryView';
import { supabase } from '../lib/supabase';
import { Loader2 } from 'lucide-react';

const DEFAULT_OPERATOR: TourOperator = {
  id: 'dc3d36fb-0502-432a-920d-c3daa95c981a',
  company_name: 'FLAMINGO',
  contact_email: 'flamingo1010@gmail.com'
};

export default function App() {
  const [operator, setOperator] = useState<TourOperator | null>(DEFAULT_OPERATOR);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [activeView, setActiveView] = useState<'dashboard' | 'builder' | 'inventory' | 'guides'>('dashboard');
  const [requests, setRequests] = useState<TripRequest[]>([]);
  const [selectedRequest, setSelectedRequest] = useState<TripRequest | null>(null);

  useEffect(() => {
    refreshRequests();
    dbService.getActiveOperator().then((op) => {
      if (op) setOperator(op);
    }).catch(console.warn);
  }, []);

  const refreshRequests = async () => {
    setRefreshing(true);
    try {
      const list = await dbService.getTripRequests();
      if (Array.isArray(list) && list.length > 0) {
        setRequests(list);
      }
    } catch (err) {
      console.error('Failed to load trip requests:', err);
    } finally {
      setRefreshing(false);
    }
  };

  const handleLoginSuccess = async (op: TourOperator) => {
    setOperator(op);
    dbService.setActiveOperator(op);
    const list = await dbService.getTripRequests();
    setRequests(list);
    setActiveView('dashboard');
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    dbService.setActiveOperator(null);
    setOperator(null);
    setSelectedRequest(null);
    setRequests([]);
  };

  const handleSelectRequest = (request: TripRequest) => {
    setSelectedRequest(request);
    setActiveView('builder');
  };

  const handleCreateRealRequest = async (data: {
    destination: string;
    travel_dates: string;
    min_budget: number;
    max_budget: number;
    preferences: string;
  }) => {
    await dbService.createTripRequest({
      destination: data.destination,
      travel_dates: data.travel_dates,
      budget_range: [data.min_budget, data.max_budget],
      user_preferences: data.preferences
    });
    await refreshRequests();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F5F6F8] flex flex-col items-center justify-center text-[#9AA0A6] gap-2">
        <Loader2 className="w-5 h-5 text-[#0A2647] animate-spin" />
        <p className="text-xs font-medium text-[#9AA0A6]">Loading Journey Operator...</p>
      </div>
    );
  }

  // Operator Auth check - Sign In & Sign Up
  if (!operator) {
    return <AuthLogin onLoginSuccess={handleLoginSuccess} />;
  }

  return (
    <div className="min-h-screen flex flex-col bg-[#F5F6F8] text-[#1A1A1A]">
      {/* Minimal Header */}
      <Header
        operator={operator}
        onLogout={handleLogout}
        activeView={activeView}
        setActiveView={setActiveView}
        hasActiveRequest={Boolean(selectedRequest)}
      />

      {/* Main View */}
      <main className="flex-1 flex flex-col">
        {activeView === 'dashboard' && (
          <DashboardView
            requests={requests}
            operator={operator}
            onSelectRequest={handleSelectRequest}
            onRefresh={refreshRequests}
            onCreateRealRequest={handleCreateRealRequest}
            isLoading={refreshing}
          />
        )}

        {activeView === 'builder' && selectedRequest && (
          <ItineraryBuilder
            request={selectedRequest}
            onBackToDashboard={() => setActiveView('dashboard')}
          />
        )}

        {activeView === 'inventory' && (
          <TiedUpInventoryView operator={operator} />
        )}

        {activeView === 'guides' && (
          <TourGuidesView operator={operator} />
        )}
      </main>
    </div>
  );
}

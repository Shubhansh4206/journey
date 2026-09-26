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

export default function App() {
  const [operator, setOperator] = useState<TourOperator | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeView, setActiveView] = useState<'dashboard' | 'builder' | 'inventory' | 'guides'>('dashboard');
  const [requests, setRequests] = useState<TripRequest[]>([]);
  const [selectedRequest, setSelectedRequest] = useState<TripRequest | null>(null);

  useEffect(() => {
    initApp();
  }, []);

  const initApp = async () => {
    setLoading(true);
    const op = await dbService.getActiveOperator();
    setOperator(op);

    if (op) {
      await refreshRequests();
    }
    setLoading(false);
  };

  const refreshRequests = async () => {
    setRefreshing(true);
    const list = await dbService.getTripRequests();
    setRequests(list);
    setRefreshing(false);
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
      <div className="min-h-screen bg-[#09090b] flex flex-col items-center justify-center text-zinc-400 gap-2">
        <Loader2 className="w-5 h-5 text-zinc-400 animate-spin" />
        <p className="text-xs font-mono text-zinc-500">Loading Journey Operator...</p>
      </div>
    );
  }

  // Operator Auth check - Sign In & Sign Up
  if (!operator) {
    return <AuthLogin onLoginSuccess={handleLoginSuccess} />;
  }

  return (
    <div className="min-h-screen flex flex-col bg-[#09090b] text-zinc-100">
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

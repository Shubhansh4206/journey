'use client';

import React from 'react';
import { TourOperator } from '../lib/types';
import { 
  Compass, 
  Sparkles, 
  LogOut, 
  LayoutDashboard, 
  UserCheck, 
  Layers, 
  Bell, 
  ShieldCheck,
  Clock
} from 'lucide-react';

interface HeaderProps {
  operator: TourOperator | null;
  onLogout: () => void;
  activeView: 'dashboard' | 'builder' | 'inventory' | 'guides';
  setActiveView: (view: 'dashboard' | 'builder' | 'inventory' | 'guides') => void;
  hasActiveRequest: boolean;
}

export const Header: React.FC<HeaderProps> = ({
  operator,
  onLogout,
  activeView,
  setActiveView,
  hasActiveRequest,
}) => {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-slate-200/80 bg-white shadow-xs">
      {/* Top Travel Desk Bar */}
      <div className="bg-[#0A2647] text-white px-4 sm:px-8 py-1.5 text-xs flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="flex items-center gap-1.5 text-slate-200 font-medium">
            <Compass className="w-3.5 h-3.5 text-amber-300" />
            <span>Tour Operator Desk</span>
          </span>
          <span className="hidden sm:inline text-slate-500">•</span>
          <span className="hidden sm:inline text-slate-300 text-[11px]">
            Mumbai • Rajasthan • Goa • Tokyo
          </span>
        </div>

        <div className="flex items-center gap-3 text-slate-300 text-[11px]">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-emerald-400" />
            <span className="text-emerald-300 font-medium">Desk Open</span>
          </span>
        </div>
      </div>

      {/* Main Navigation Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-8 h-16 flex items-center justify-between">
        {/* Brand Identity */}
        <div className="flex items-center gap-8">
          <div 
            onClick={() => setActiveView('dashboard')}
            className="flex items-center gap-3 cursor-pointer group"
          >
            <div className="w-9 h-9 rounded-xl bg-[#0A2647] flex items-center justify-center text-white shadow-md shadow-[#0A2647]/15 transition-transform group-hover:scale-105">
              <Compass className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-heading font-bold tracking-tight text-[#0A2647] text-base">
                  JOURNEY
                </span>
                <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-[#F5F6F8] text-[#0A2647] border border-slate-200">
                  Concierge
                </span>
              </div>
              <p className="text-[11px] text-[#9AA0A6] font-medium leading-none mt-0.5">
                Boutique Tour Operator Portal
              </p>
            </div>
          </div>

          {/* Core Navigation Tabs */}
          <nav className="hidden lg:flex items-center gap-1.5 pl-6 border-l border-slate-200">
            <button
              onClick={() => setActiveView('dashboard')}
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
                activeView === 'dashboard'
                  ? 'bg-[#0A2647] text-white shadow-xs'
                  : 'text-[#9AA0A6] hover:text-[#1A1A1A] hover:bg-[#F5F6F8]'
              }`}
            >
              <LayoutDashboard className="w-3.5 h-3.5" />
              <span>Trip Inquiries</span>
            </button>

            {hasActiveRequest && (
              <button
                onClick={() => setActiveView('builder')}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
                  activeView === 'builder'
                    ? 'bg-[#0A2647] text-white shadow-xs'
                    : 'text-[#9AA0A6] hover:text-[#1A1A1A] hover:bg-[#F5F6F8]'
                }`}
              >
                <Sparkles className="w-3.5 h-3.5 text-amber-500" />
                <span>Custom Builder</span>
              </button>
            )}

            <button
              onClick={() => setActiveView('inventory')}
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
                activeView === 'inventory'
                  ? 'bg-[#0A2647] text-white shadow-xs'
                  : 'text-[#9AA0A6] hover:text-[#1A1A1A] hover:bg-[#F5F6F8]'
              }`}
            >
              <Layers className="w-3.5 h-3.5" />
              <span>Hotels & Stays</span>
            </button>

            <button
              onClick={() => setActiveView('guides')}
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all ${
                activeView === 'guides'
                  ? 'bg-[#0A2647] text-white shadow-xs'
                  : 'text-[#9AA0A6] hover:text-[#1A1A1A] hover:bg-[#F5F6F8]'
              }`}
            >
              <UserCheck className="w-3.5 h-3.5" />
              <span>Local Guides</span>
            </button>

            <a
              href={operator?.id ? `/studio?operator_id=${encodeURIComponent(operator.id)}` : '/studio'}
              className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold transition-all text-[#0A2647] bg-[#F5F6F8] hover:bg-slate-200 border border-slate-200/80 shadow-2xs ml-1"
            >
              <Sparkles className="w-3.5 h-3.5 text-[#0A2647]" />
              <span>Itinerary Studio</span>
            </a>
          </nav>
        </div>

        {/* Right Operator Profile & Quick Stats */}
        <div className="flex items-center gap-3.5">
          {operator && (
            <div className="flex items-center gap-3">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-bold text-[#1A1A1A] leading-tight">
                  {operator.company_name}
                </p>
                <p className="text-[10px] text-[#9AA0A6] leading-tight mt-0.5">
                  {operator.contact_email}
                </p>
              </div>

              <div className="w-8 h-8 rounded-full bg-[#0A2647] text-white font-bold text-xs flex items-center justify-center shadow-xs">
                {operator.company_name ? operator.company_name.charAt(0).toUpperCase() : 'V'}
              </div>

              <button
                onClick={onLogout}
                title="Log Out"
                className="p-2 rounded-full text-[#9AA0A6] hover:text-[#1A1A1A] hover:bg-[#F5F6F8] transition-colors"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

'use client';

import React from 'react';
import { TourOperator } from '../lib/types';
import { Compass, Sparkles, LogOut, LayoutDashboard, UserCheck, Layers } from 'lucide-react';

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
    <header className="sticky top-0 z-40 w-full border-b border-zinc-800 bg-[#09090b]/90 backdrop-blur-md">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 h-13 py-3 flex items-center justify-between">
        {/* Brand */}
        <div className="flex items-center gap-6">
          <div 
            onClick={() => setActiveView('dashboard')}
            className="flex items-center gap-2 cursor-pointer"
          >
            <div className="w-6 h-6 rounded bg-zinc-800 border border-zinc-700 flex items-center justify-center text-zinc-200">
              <Compass className="w-3.5 h-3.5" />
            </div>
            <span className="font-semibold tracking-tight text-white text-xs">JOURNEY OPERATOR</span>
          </div>

          {/* Nav */}
          <nav className="hidden md:flex items-center gap-1 pl-4 border-l border-zinc-800">
            <button
              onClick={() => setActiveView('dashboard')}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-colors ${
                activeView === 'dashboard'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <LayoutDashboard className="w-3.5 h-3.5 text-zinc-400" />
              Requests
            </button>

            {hasActiveRequest && (
              <button
                onClick={() => setActiveView('builder')}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-colors ${
                  activeView === 'builder'
                    ? 'bg-zinc-800 text-white'
                    : 'text-zinc-400 hover:text-zinc-200'
                }`}
              >
                <Sparkles className="w-3.5 h-3.5 text-zinc-400" />
                Canvas & AI
              </button>
            )}

            <button
              onClick={() => setActiveView('inventory')}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-colors ${
                activeView === 'inventory'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <Layers className="w-3.5 h-3.5 text-zinc-400" />
              Tied-Up Partners
            </button>

            <button
              onClick={() => setActiveView('guides')}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-colors ${
                activeView === 'guides'
                  ? 'bg-zinc-800 text-white'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <UserCheck className="w-3.5 h-3.5 text-zinc-400" />
              Guides
            </button>

            <a
              href="/studio"
              className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-colors text-indigo-400 hover:text-indigo-300 hover:bg-indigo-950/40 border border-indigo-800/50"
            >
              <Sparkles className="w-3.5 h-3.5 text-indigo-400" />
              Agent Studio
            </a>
          </nav>
        </div>

        {/* Right Operator Info */}
        <div className="flex items-center gap-3">
          {operator && (
            <div className="flex items-center gap-3">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-medium text-zinc-200 leading-none">
                  {operator.company_name}
                </p>
                <p className="text-[10px] text-zinc-500 leading-tight mt-0.5">
                  {operator.contact_email}
                </p>
              </div>

              <button
                onClick={onLogout}
                title="Log Out"
                className="p-1.5 rounded text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800 transition-colors"
              >
                <LogOut className="w-3.5 h-3.5" />
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

'use client';

import React, { useState } from 'react';
import { TourOperator } from '../lib/types';
import { dbService } from '../lib/dbService';
import { Compass, Lock, Mail, Building2, ArrowRight, Loader2, AlertCircle, CheckCircle2 } from 'lucide-react';

interface AuthLoginProps {
  onLoginSuccess: (operator: TourOperator) => void;
}

export const AuthLogin: React.FC<AuthLoginProps> = ({ onLoginSuccess }) => {
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    setSuccessMessage(null);

    if (!email || !password) {
      setErrorMessage('Please enter your email and password.');
      return;
    }

    if (mode === 'signup' && !companyName) {
      setErrorMessage('Please enter your tour operator company name.');
      return;
    }

    setLoading(true);

    if (mode === 'signup') {
      const { operator, error } = await dbService.signUpOperator(companyName, email, password);
      setLoading(false);

      if (error) {
        setErrorMessage(error);
        return;
      }

      if (operator) {
        setSuccessMessage('Account created successfully! Logging you in...');
        setTimeout(() => {
          onLoginSuccess(operator);
        }, 600);
      }
    } else {
      const { operator, error } = await dbService.signInOperator(email, password);
      setLoading(false);

      if (error) {
        setErrorMessage(error);
        return;
      }

      if (operator) {
        onLoginSuccess(operator);
      }
    }
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center p-4 bg-[#09090b]">
      <div className="w-full max-w-sm">
        {/* Brand */}
        <div className="text-center mb-6">
          <div className="inline-flex items-center justify-center w-9 h-9 rounded-lg bg-zinc-900 border border-zinc-800 mb-2.5 text-zinc-300">
            <Compass className="w-4 h-4" />
          </div>
          <h1 className="text-lg font-semibold tracking-tight text-white">
            Tour Operator Portal
          </h1>
          <p className="text-xs text-zinc-500 mt-0.5">
            {mode === 'signin' ? 'Sign in to access your dashboard' : 'Create your operator account'}
          </p>
        </div>

        {/* Card */}
        <div className="bg-[#121215] border border-zinc-800 rounded-xl p-5 shadow-lg">
          {/* Mode Switcher */}
          <div className="grid grid-cols-2 p-1 bg-zinc-950 rounded-lg mb-4 border border-zinc-800/80">
            <button
              type="button"
              onClick={() => {
                setMode('signin');
                setErrorMessage(null);
                setSuccessMessage(null);
              }}
              className={`py-1 text-xs font-medium rounded-md transition-all ${
                mode === 'signin'
                  ? 'bg-zinc-800 text-white shadow-sm'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              Sign In
            </button>
            <button
              type="button"
              onClick={() => {
                setMode('signup');
                setErrorMessage(null);
                setSuccessMessage(null);
              }}
              className={`py-1 text-xs font-medium rounded-md transition-all ${
                mode === 'signup'
                  ? 'bg-zinc-800 text-white shadow-sm'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              Sign Up
            </button>
          </div>

          {errorMessage && (
            <div className="mb-3.5 p-2.5 rounded-lg bg-red-950/40 border border-red-800/50 flex items-start gap-2 text-xs text-red-300">
              <AlertCircle className="w-3.5 h-3.5 text-red-400 flex-shrink-0 mt-0.5" />
              <span>{errorMessage}</span>
            </div>
          )}

          {successMessage && (
            <div className="mb-3.5 p-2.5 rounded-lg bg-emerald-950/40 border border-emerald-800/50 flex items-start gap-2 text-xs text-emerald-300">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400 flex-shrink-0 mt-0.5" />
              <span>{successMessage}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3">
            {mode === 'signup' && (
              <div>
                <label className="block text-[11px] font-medium text-zinc-300 mb-1">
                  Company / Agency Name
                </label>
                <div className="relative">
                  <Building2 className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={companyName}
                    onChange={(e) => setCompanyName(e.target.value)}
                    placeholder="e.g. Kyoto Bespoke Journeys"
                    required
                    className="w-full pl-8 pr-3 py-1.5 bg-zinc-950 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600 transition-colors"
                  />
                </div>
              </div>
            )}

            <div>
              <label className="block text-[11px] font-medium text-zinc-300 mb-1">
                Operator Email
              </label>
              <div className="relative">
                <Mail className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="operator@agency.com"
                  required
                  className="w-full pl-8 pr-3 py-1.5 bg-zinc-950 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600 transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-medium text-zinc-300 mb-1">
                Password
              </label>
              <div className="relative">
                <Lock className="w-3.5 h-3.5 text-zinc-500 absolute left-3 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  required
                  className="w-full pl-8 pr-3 py-1.5 bg-zinc-950 border border-zinc-800 rounded-lg text-xs text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-600 transition-colors"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2 px-4 bg-white hover:bg-zinc-200 text-zinc-950 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5 transition-all disabled:opacity-50 mt-3.5 shadow-sm"
            >
              {loading ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <>
                  <span>{mode === 'signin' ? 'Sign In to Dashboard' : 'Create Operator Account'}</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </>
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

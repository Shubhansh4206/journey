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
    <div className="min-h-screen w-full flex items-center justify-center p-4 bg-[#F5F6F8]">
      <div className="w-full max-w-sm">
        {/* Brand */}
        <div className="text-center mb-6">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-[#0A2647] mb-3 text-white shadow-md shadow-[#0A2647]/20">
            <Compass className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-[#1A1A1A]">
            Tour Operator Portal
          </h1>
          <p className="text-xs text-[#9AA0A6] mt-1">
            {mode === 'signin' ? 'Sign in to access your dashboard' : 'Create your verified operator account'}
          </p>
        </div>

        {/* Card */}
        <div className="bg-white border border-slate-100 rounded-3xl p-6 shadow-[0_10px_35px_rgba(0,0,0,0.05)]">
          {/* Mode Switcher */}
          <div className="grid grid-cols-2 p-1 bg-[#F5F6F8] rounded-full mb-5 border border-slate-200/80">
            <button
              type="button"
              onClick={() => {
                setMode('signin');
                setErrorMessage(null);
                setSuccessMessage(null);
              }}
              className={`py-1.5 text-xs font-semibold rounded-full transition-all ${
                mode === 'signin'
                  ? 'bg-[#0A2647] text-white shadow-sm'
                  : 'text-[#9AA0A6] hover:text-[#1A1A1A]'
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
              className={`py-1.5 text-xs font-semibold rounded-full transition-all ${
                mode === 'signup'
                  ? 'bg-[#0A2647] text-white shadow-sm'
                  : 'text-[#9AA0A6] hover:text-[#1A1A1A]'
              }`}
            >
              Sign Up
            </button>
          </div>

          {errorMessage && (
            <div className="mb-4 p-3 rounded-xl bg-red-50 border border-red-200/80 flex items-start gap-2.5 text-xs text-red-700">
              <AlertCircle className="w-4 h-4 text-red-500 shrink-0 mt-0.5" />
              <span>{errorMessage}</span>
            </div>
          )}

          {successMessage && (
            <div className="mb-4 p-3 rounded-xl bg-emerald-50 border border-emerald-200/80 flex items-start gap-2.5 text-xs text-emerald-800">
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
              <span>{successMessage}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3.5">
            {mode === 'signup' && (
              <div>
                <label className="block text-[11px] font-semibold text-[#1A1A1A] mb-1">
                  Company / Agency Name
                </label>
                <div className="relative">
                  <Building2 className="w-4 h-4 text-[#9AA0A6] absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={companyName}
                    onChange={(e) => setCompanyName(e.target.value)}
                    placeholder="e.g. Kyoto Bespoke Journeys"
                    required
                    className="w-full pl-10 pr-3.5 py-2 bg-[#F5F6F8] border border-slate-200 rounded-xl text-xs text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] transition-colors font-medium"
                  />
                </div>
              </div>
            )}

            <div>
              <label className="block text-[11px] font-semibold text-[#1A1A1A] mb-1">
                Operator Email
              </label>
              <div className="relative">
                <Mail className="w-4 h-4 text-[#9AA0A6] absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="operator@agency.com"
                  required
                  className="w-full pl-10 pr-3.5 py-2 bg-[#F5F6F8] border border-slate-200 rounded-xl text-xs text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] transition-colors font-medium"
                />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-semibold text-[#1A1A1A] mb-1">
                Password
              </label>
              <div className="relative">
                <Lock className="w-4 h-4 text-[#9AA0A6] absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  required
                  className="w-full pl-10 pr-3.5 py-2 bg-[#F5F6F8] border border-slate-200 rounded-xl text-xs text-[#1A1A1A] placeholder-[#9AA0A6] focus:outline-none focus:border-[#0A2647] transition-colors font-medium"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2.5 px-4 bg-[#0A2647] hover:bg-[#081f3a] text-white text-xs font-semibold rounded-full flex items-center justify-center gap-1.5 transition-all disabled:opacity-50 mt-4 shadow-md shadow-[#0A2647]/15 active:scale-[0.99]"
            >
              {loading ? (
                <Loader2 className="w-4 h-4 animate-spin text-white" />
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

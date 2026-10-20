'use client';

import React from 'react';

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="min-h-screen bg-[#F5F6F8] flex flex-col items-center justify-center p-4 text-[#1A1A1A] font-sans">
      <div className="max-w-md w-full bg-white rounded-3xl p-8 border border-slate-100 shadow-xl text-center">
        <h2 className="text-lg font-bold text-[#1A1A1A] mb-2">System Notice</h2>
        <p className="text-xs text-[#9AA0A6] mb-6">
          {error?.message || 'An unexpected operational error occurred.'}
        </p>
        <button
          onClick={() => reset()}
          className="px-6 py-2.5 bg-[#0A2647] hover:bg-[#081f3a] text-white rounded-full text-xs font-semibold shadow-md shadow-[#0A2647]/15 transition-all"
        >
          Try Again
        </button>
      </div>
    </div>
  );
}

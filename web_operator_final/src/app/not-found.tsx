import Link from 'next/link';
import { Compass } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-[#F5F6F8] flex flex-col items-center justify-center text-[#1A1A1A] p-4">
      <div className="max-w-md w-full bg-white rounded-3xl p-8 border border-slate-100 shadow-xl text-center">
        <div className="w-12 h-12 rounded-full bg-[#0A2647] text-white flex items-center justify-center mx-auto mb-4 shadow-md shadow-[#0A2647]/15">
          <Compass className="w-6 h-6" />
        </div>
        <h1 className="text-3xl font-bold font-heading text-[#0A2647] mb-1">404</h1>
        <h2 className="text-base font-bold text-[#1A1A1A] mb-2 font-heading">Itinerary Not Found</h2>
        <p className="text-xs text-[#9AA0A6] mb-6">
          The requested tour dossier or page could not be located in the dispatch system.
        </p>
        <Link
          href="/"
          className="inline-block px-6 py-2.5 bg-[#0A2647] hover:bg-[#081f3a] text-white rounded-full text-xs font-semibold shadow-md shadow-[#0A2647]/15 transition-all"
        >
          Return to Dashboard
        </Link>
      </div>
    </div>
  );
}

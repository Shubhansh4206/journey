import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-slate-950 flex flex-col items-center justify-center text-slate-100 p-4">
      <div className="text-center space-y-3">
        <h1 className="text-4xl font-bold font-mono text-indigo-400">404</h1>
        <h2 className="text-lg font-semibold">Page Not Found</h2>
        <p className="text-xs text-slate-400 max-w-sm">
          The requested page could not be located on Journey Operator.
        </p>
        <Link
          href="/"
          className="inline-block mt-4 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-xs font-semibold transition-colors"
        >
          Return to Dashboard
        </Link>
      </div>
    </div>
  );
}

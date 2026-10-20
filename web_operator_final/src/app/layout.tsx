import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Journey Operator | Boutique Tour & Itinerary Management',
  description: 'Luxury tour operator portal for designing bespoke travel itineraries, pricing quotations, and managing traveler requests.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="bg-[#F5F6F8] text-[#1A1A1A] min-h-screen antialiased selection:bg-[#0A2647]/10 selection:text-[#0A2647]">
        {children}
      </body>
    </html>
  );
}

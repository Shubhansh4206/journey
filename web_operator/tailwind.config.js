/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primaryDarkBlue: '#0A2647',
        navyDeep: '#12233F',
        pureWhite: '#FFFFFF',
        softGrey: '#F5F6F8',
        mediumGrey: '#9AA0A6',
        nearBlack: '#1A1A1A',
        // Semantic status tags preserved
        status: {
          pending: '#F59E0B',
          reviewing: '#3B82F6',
          quoted: '#0A2647',
          negotiating: '#E11D48',
          finalized: '#10B981',
          cancelled: '#94A3B8'
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
        display: ['"Outfit"', '"Plus Jakarta Sans"', 'sans-serif'],
        heading: ['"Outfit"', '"Plus Jakarta Sans"', 'sans-serif'],
        mono: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 8px 30px rgba(0, 0, 0, 0.04)',
        'soft-lg': '0 14px 40px rgba(10, 38, 71, 0.07)',
        'card': '0 4px 20px -2px rgba(10, 38, 71, 0.05)',
        'float': '0 20px 40px -10px rgba(10, 38, 71, 0.12)',
      },
      borderRadius: {
        'card': '20px',
        'pill': '9999px',
      }
    },
  },
  plugins: [],
};

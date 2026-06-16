import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
        display: ['Instrument Sans', 'system-ui', 'sans-serif'],
      },
      colors: {
        transport: {
          navy: '#0a0f1a',
          amber: '#f59e0b',
        },
      },
    },
  },
  plugins: [],
};

export default config;

import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#ecb613",
          50: "#fffbeb",
          100: "#fef3c7",
          200: "#fde68a",
          300: "#fcd34d",
          400: "#fbbf24",
          500: "#ecb613",
          600: "#d97706",
          700: "#b45309",
          800: "#92400e",
          900: "#78350f",
        },
        background: {
          light: "#f8f8f6",
          dark: "#0F1115",
        },
        surface: {
          light: "#ffffff",
          dark: "#1a160d",
        },
        border: {
          light: "#e5e7eb",
          dark: "#483f23",
        },
        accent: {
          indigo: "#6366f1",
          emerald: "#10b981",
          rose: "#f43f5e",
          amber: "#f59e0b",
        },
      },
      fontFamily: {
        display: ["Manrope", "sans-serif"],
        inter: ["Inter", "sans-serif"],
        jakarta: ["Plus Jakarta Sans", "sans-serif"],
      },
      borderRadius: {
        DEFAULT: "0.25rem",
        lg: "0.5rem",
        xl: "0.75rem",
        "2xl": "1rem",
        "3xl": "1.5rem",
        full: "9999px",
      },
      boxShadow: {
        'glow': '0 0 20px rgba(236, 182, 19, 0.15)',
        'glow-lg': '0 0 40px rgba(236, 182, 19, 0.2)',
      },
    },
  },
  plugins: [],
} satisfies Config;

# Transport BI Platform

A world-class **Transport Business Intelligence & Management Platform** for Android, iPhone, Tablet, and Web.

## Features

| Module | Description |
|--------|-------------|
| Dashboard | Investment, revenue, profit, fleet metrics, health & risk scores |
| Vehicle Intelligence | 19+ vehicles with full cost analysis, EMI, ROI |
| AI Business Advisor | Vehicle selection, platform analysis, growth strategy |
| Vehicle Recommendation | Budget/city/income-based AI recommendations |
| Driver Management | Database, recruitment guides, performance tracking |
| Load & Trip Management | Posting, assignment, profit per trip |
| Customer Management | Profiles, dues, booking history |
| Finance & Dues | EMI, insurance, permits, reminders (Push/SMS/Email ready) |
| Ola/Uber/Rapido Analysis | Platform comparison by city & vehicle |
| Route Profitability | Profit per trip/km, risk scoring |
| Business Plan Generator | ₹5L to ₹1 Crore plans |
| Documents | RC, insurance, permits, licenses |
| Reports & Analytics | Charts, PDF/Excel export |
| Multi-language | English, Tamil, Hindi |
| Dark/Light Mode | Premium glassmorphism UI |

## Project Structure

```
transport-bi-platform/
├── apps/
│   ├── web/                 # Next.js 14 web app
│   └── mobile/              # Expo React Native (iOS/Android/Tablet)
├── server/                  # Node.js + Express API
├── packages/
│   └── shared/              # Shared types & calculations
├── database/
│   ├── schema.sql           # PostgreSQL schema
│   └── seeds/vehicles.json  # Vehicle intelligence data
└── docs/
    ├── API.md               # API architecture
    └── DEPLOYMENT.md        # Deployment guide
```

## Quick Start

### Web App (works standalone with embedded data)

```bash
cd apps/web
npm install
npm run dev
```

Open http://localhost:3000

### Backend API

```bash
cd server
npm install
cp .env.example .env
npm run dev
```

API runs at http://localhost:4000

### Mobile App

```bash
cd apps/mobile
npm install
npx expo start
```

Scan QR with Expo Go (Android/iOS) or press `i`/`a` for simulators.

### Database

```bash
createdb transport_bi
psql -U postgres -d transport_bi -f database/schema.sql
```

## Tech Stack

- **Frontend Web:** Next.js 14, React, Tailwind CSS, Recharts
- **Mobile:** React Native (Expo), Expo Router
- **Backend:** Node.js, Express.js, TypeScript
- **Database:** PostgreSQL
- **Auth:** Email, Phone OTP, Google (JWT)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard/metrics` | Dashboard KPIs |
| GET | `/api/vehicles` | Vehicle database |
| POST | `/api/vehicles/recommend` | AI recommendation |
| POST | `/api/ai/advisor` | AI business advisor |
| GET | `/api/drivers` | Driver list |
| GET | `/api/trips` | Trip management |
| GET | `/api/finance/summary` | Dues & finance |
| GET | `/api/platform/compare` | Ola/Uber/Rapido |
| GET | `/api/routes` | Route profitability |
| GET | `/api/business-plans` | Business plan generator |
| GET | `/api/reports/analytics` | Reports & charts |

See [docs/API.md](docs/API.md) for full documentation.

## License

Proprietary — Transport BI Platform

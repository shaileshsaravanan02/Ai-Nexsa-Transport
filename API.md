# API Architecture

## Base URL

- Development: `http://localhost:4000/api`
- Production: `https://api.yourdomain.com/api`

## Authentication

All protected routes require `Authorization: Bearer <JWT>` header.

### Auth Endpoints

```
POST /auth/register     { email, password, fullName, phone? }
POST /auth/login        { email, password }
POST /auth/phone        { phone, otp? }        # Demo OTP: 123456
POST /auth/google       { googleId, email, fullName }
```

## Module APIs

### 1. Dashboard
```
GET /dashboard/metrics    → totalInvestment, revenue, profit, vehicles, drivers, dues, health, risk
GET /dashboard/trends     → monthly profit/revenue time series
```

### 2. Vehicle Intelligence
```
GET  /vehicles                    ?category=car&search=swift&maxPrice=1000000
GET  /vehicles/:id                → full specs, costs, business analysis
GET  /vehicles/:id/platform       ?city=Chennai → Ola/Uber/Rapido breakdown
POST /vehicles/recommend          { budget, city, expectedIncome, loanAmount }
```

### 3. AI Advisor
```
POST /ai/advisor                  { question, budget?, city?, vehicleCount? }
POST /ai/predict-profit           { historicalMonthly[], monthsAhead? }
GET  /ai/suggested-questions
```

### 4. Drivers
```
GET  /drivers
GET  /drivers/:id
GET  /drivers/recruitment         → hiring guide, checklist, templates
```

### 5. Trips & Loads
```
GET   /trips
POST  /trips/loads                { loadDescription, rate, pickupDate, ... }
PATCH /trips/:id/status           { status: pending|accepted|in_progress|delivered|completed }
```

### 6. Customers
```
GET /customers
GET /customers/:id
```

### 7. Finance
```
GET /finance/dues
GET /finance/summary              → pending, overdue, emi totals
```

### 8. Platform Analysis
```
GET /platform/compare             ?city=Chennai
GET /platform/:vehicleId          ?city=Chennai
```

### 9. Routes
```
GET /routes                       → profit per trip/km, risk scores
GET /routes/:id
```

### 10. Business Plans
```
GET /business-plans
GET /business-plans/:id           → 5L, 10L, 20L, 50L, 1Cr plans
```

### 11. Documents
```
GET  /documents
POST /documents                   { docType, title, fileUrl, expiryDate, ... }
```

### 12. Reports
```
GET /reports/analytics
GET /reports/export/:format       → pdf | excel
```

### 13. Settings (Admin)
```
GET /settings/contact
PUT /settings/contact             { phone, whatsapp, email, consultationEnabled }
```

### 14. Consultation
```
POST /consultation                { name, phone, email?, planInterest?, message? }
GET  /consultation                (admin)
```

## Response Format

```json
{
  "success": true,
  "data": { ... },
  "message": "optional"
}
```

## Error Format

```json
{
  "success": false,
  "message": "Error description"
}
```

## Database Tables

See `database/schema.sql` for full PostgreSQL schema including:
- users, businesses, fleet_vehicles
- vehicle_models (intelligence database)
- drivers, driver_performance, driver_assignments
- customers, routes, loads, trips
- financial_dues, payments, documents
- ai_conversations, vehicle_recommendations
- business_plan_templates, platform_analysis
- notifications, app_settings, consultation_requests
- dashboard_snapshots

## Future AI Integration

Replace rule-based advisor in `aiAdvisorService.ts` with OpenAI/Claude API:

```typescript
// server/src/services/aiAdvisorService.ts
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [{ role: 'system', content: TRANSPORT_ADVISOR_PROMPT }, { role: 'user', content: question }],
});
```

Vehicle recommendation can use embedding search over vehicle_models + structured filters.

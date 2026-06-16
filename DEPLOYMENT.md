# Deployment Guide

## Prerequisites

- Node.js 18+
- PostgreSQL 15+
- npm or yarn
- For mobile: Expo account, EAS CLI
- For production: VPS (AWS/DigitalOcean) or Vercel + Railway

---

## 1. Database Setup (PostgreSQL)

```bash
# Create database
sudo -u postgres createdb transport_bi

# Run schema
psql -U postgres -d transport_bi -f database/schema.sql

# Optional: seed vehicles via server
cd server && npm run seed
```

### Production DB (Railway / Supabase / AWS RDS)

1. Create PostgreSQL instance
2. Copy connection string to `DATABASE_URL`
3. Enable SSL: `?sslmode=require`

---

## 2. Backend Deployment

### Option A: Railway / Render

```bash
cd server
npm install
npm run build
```

Environment variables:
```
PORT=4000
NODE_ENV=production
DATABASE_URL=postgresql://...
JWT_SECRET=<strong-random-secret>
CORS_ORIGIN=https://yourdomain.com,https://app.yourdomain.com
```

Start command: `npm start`

### Option B: Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY server/package*.json ./
RUN npm ci --production
COPY server/dist ./dist
EXPOSE 4000
CMD ["node", "dist/index.js"]
```

```bash
docker build -t transport-bi-api .
docker run -p 4000:4000 --env-file server/.env transport-bi-api
```

---

## 3. Web App Deployment (Vercel)

```bash
cd apps/web
npm install
npm run build
```

### Vercel Setup

1. Connect GitHub repo
2. Root directory: `apps/web`
3. Environment variable:
   ```
   NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api
   ```
4. Deploy

### Self-hosted (PM2)

```bash
cd apps/web
npm run build
pm2 start npm --name "transport-bi-web" -- start
```

---

## 4. Mobile App Deployment

### Development

```bash
cd apps/mobile
npm install
npx expo start
```

### Production Build (EAS)

```bash
npm install -g eas-cli
eas login
eas build:configure

# Android APK/AAB
eas build --platform android --profile production

# iOS
eas build --platform ios --profile production

# Submit to stores
eas submit --platform android
eas submit --platform ios
```

Update API URL in mobile app config:
```typescript
const API_BASE = 'https://api.yourdomain.com/api';
```

---

## 5. SSL & Domain

| Service | Domain Example |
|---------|---------------|
| Web | `app.transportbi.com` |
| API | `api.transportbi.com` |
| Admin | `admin.transportbi.com` |

Use Cloudflare or Let's Encrypt for SSL.

---

## 6. Notification Services (Future)

### Push Notifications
- Firebase Cloud Messaging (FCM) for Android
- Apple Push Notification Service (APNs) for iOS

### SMS
- Twilio / MSG91 / AWS SNS
- Architecture ready in `notifications` table

### Email
- SendGrid / AWS SES
- Trigger on `financial_dues` due dates

---

## 7. Monitoring

- **Health check:** `GET /health`
- **Logging:** Winston + CloudWatch/Datadog
- **Uptime:** UptimeRobot on `/health`
- **Errors:** Sentry integration recommended

---

## 8. Security Checklist

- [ ] Change `JWT_SECRET` to 256-bit random string
- [ ] Enable PostgreSQL SSL
- [ ] Set restrictive CORS origins
- [ ] Rate limit auth endpoints
- [ ] Hash passwords with bcrypt (already implemented)
- [ ] Validate all inputs (express-validator)
- [ ] Never commit `.env` files
- [ ] Use HTTPS everywhere in production

---

## 9. Local Development (All Services)

Terminal 1 — API:
```bash
cd server && npm install && npm run dev
```

Terminal 2 — Web:
```bash
cd apps/web && npm install && npm run dev
```

Terminal 3 — Mobile:
```bash
cd apps/mobile && npm install && npx expo start
```

Web works standalone without API (embedded demo data in `apps/web/src/lib/data.ts`).

---

## 10. Scaling

| Component | Scale Strategy |
|-----------|---------------|
| API | Horizontal scaling behind load balancer |
| Database | Read replicas, connection pooling (PgBouncer) |
| Web | Vercel edge / CDN for static assets |
| File uploads | AWS S3 for documents |
| AI features | Queue-based (Bull/Redis) for LLM calls |

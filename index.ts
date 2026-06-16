import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { errorHandler } from './middleware/errorHandler';
import authRoutes from './routes/auth';
import dashboardRoutes from './routes/dashboard';
import vehicleRoutes from './routes/vehicles';
import aiRoutes from './routes/ai';
import driverRoutes from './routes/drivers';
import tripRoutes from './routes/trips';
import customerRoutes from './routes/customers';
import financeRoutes from './routes/finance';
import platformRoutes from './routes/platform';
import routeRoutes from './routes/routes';
import businessPlanRoutes from './routes/businessPlans';
import documentRoutes from './routes/documents';
import reportRoutes from './routes/reports';
import settingsRoutes from './routes/settings';
import consultationRoutes from './routes/consultation';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors({ origin: process.env.CORS_ORIGIN?.split(',') || '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'Transport BI API', version: '1.0.0' }));

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/platform', platformRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/business-plans', businessPlanRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/consultation', consultationRoutes);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Transport BI API running on http://localhost:${PORT}`);
});

export default app;

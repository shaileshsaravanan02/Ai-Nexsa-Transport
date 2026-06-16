-- Transport BI Platform - PostgreSQL Schema
-- Run: psql -U postgres -d transport_bi -f schema.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- USERS & AUTH
-- ============================================================

CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'driver', 'viewer');
CREATE TYPE auth_provider AS ENUM ('email', 'phone', 'google');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255),
  google_id VARCHAR(255) UNIQUE,
  auth_provider auth_provider NOT NULL DEFAULT 'email',
  full_name VARCHAR(255) NOT NULL,
  role user_role NOT NULL DEFAULT 'owner',
  avatar_url TEXT,
  preferred_language VARCHAR(5) DEFAULT 'en',
  theme VARCHAR(10) DEFAULT 'dark',
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE businesses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  city VARCHAR(100),
  state VARCHAR(100),
  gstin VARCHAR(20),
  total_investment DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_businesses (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
  role user_role NOT NULL DEFAULT 'viewer',
  PRIMARY KEY (user_id, business_id)
);

CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- VEHICLE INTELLIGENCE DATABASE
-- ============================================================

CREATE TYPE vehicle_category AS ENUM ('car', 'lcv', 'truck', 'bus');

CREATE TABLE vehicle_models (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  brand VARCHAR(100) NOT NULL,
  category vehicle_category NOT NULL,
  image_url TEXT,
  specifications JSONB DEFAULT '{}',
  ex_showroom_price DECIMAL(12,2) NOT NULL,
  on_road_price DECIMAL(12,2) NOT NULL,
  down_payment_pct DECIMAL(5,2) DEFAULT 20,
  loan_interest_rate DECIMAL(5,2) DEFAULT 9.5,
  loan_tenure_months INT DEFAULT 60,
  insurance_annual DECIMAL(10,2),
  permit_cost DECIMAL(10,2),
  fc_cost DECIMAL(10,2),
  tax_annual DECIMAL(10,2),
  fuel_cost_monthly DECIMAL(10,2),
  service_cost_monthly DECIMAL(10,2),
  maintenance_cost_monthly DECIMAL(10,2),
  driver_salary_monthly DECIMAL(10,2),
  tyre_cost_annual DECIMAL(10,2),
  unexpected_expense_monthly DECIMAL(10,2),
  monthly_revenue_estimate DECIMAL(12,2),
  monthly_expense_estimate DECIMAL(12,2),
  monthly_profit_estimate DECIMAL(12,2),
  yearly_profit_estimate DECIMAL(12,2),
  roi_pct DECIMAL(6,2),
  break_even_months INT,
  growth_potential VARCHAR(20),
  risk_score INT CHECK (risk_score BETWEEN 1 AND 100),
  ola_daily_income DECIMAL(10,2),
  uber_daily_income DECIMAL(10,2),
  rapido_daily_income DECIMAL(10,2),
  platform_commission_pct DECIMAL(5,2) DEFAULT 25,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicle_models_category ON vehicle_models(category);
CREATE INDEX idx_vehicle_models_name_trgm ON vehicle_models USING gin (name gin_trgm_ops);

-- ============================================================
-- FLEET (USER OWNED VEHICLES)
-- ============================================================

CREATE TYPE vehicle_status AS ENUM ('active', 'inactive', 'maintenance', 'sold');

CREATE TABLE fleet_vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  vehicle_model_id UUID REFERENCES vehicle_models(id),
  registration_number VARCHAR(20) NOT NULL,
  purchase_date DATE,
  purchase_price DECIMAL(12,2),
  current_value DECIMAL(12,2),
  loan_amount DECIMAL(12,2) DEFAULT 0,
  emi_amount DECIMAL(10,2) DEFAULT 0,
  emi_due_day INT,
  status vehicle_status DEFAULT 'active',
  odometer_km INT DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DRIVERS
-- ============================================================

CREATE TABLE drivers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  full_name VARCHAR(255) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  license_number VARCHAR(50),
  license_expiry DATE,
  experience_years INT DEFAULT 0,
  previous_companies TEXT[],
  address TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  salary_monthly DECIMAL(10,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE driver_performance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  month DATE NOT NULL,
  trips_completed INT DEFAULT 0,
  revenue_generated DECIMAL(12,2) DEFAULT 0,
  fuel_efficiency_kmpl DECIMAL(5,2),
  attendance_days INT DEFAULT 0,
  driver_score INT CHECK (driver_score BETWEEN 0 AND 100),
  UNIQUE(driver_id, month)
);

CREATE TABLE driver_assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  fleet_vehicle_id UUID NOT NULL REFERENCES fleet_vehicles(id) ON DELETE CASCADE,
  assigned_from DATE NOT NULL,
  assigned_to DATE,
  is_current BOOLEAN DEFAULT true
);

-- ============================================================
-- CUSTOMERS
-- ============================================================

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  company VARCHAR(255),
  mobile VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  gstin VARCHAR(20),
  outstanding_dues DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- LOADS & TRIPS
-- ============================================================

CREATE TYPE trip_status AS ENUM ('pending', 'accepted', 'in_progress', 'delivered', 'completed', 'cancelled');

CREATE TABLE routes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  origin VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  distance_km DECIMAL(8,2) NOT NULL,
  toll_estimate DECIMAL(10,2) DEFAULT 0,
  fuel_estimate DECIMAL(10,2) DEFAULT 0,
  avg_profit_per_trip DECIMAL(10,2),
  profit_per_km DECIMAL(8,2),
  risk_score INT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE loads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  customer_id UUID REFERENCES customers(id),
  route_id UUID REFERENCES routes(id),
  load_description TEXT,
  weight_kg DECIMAL(10,2),
  rate DECIMAL(12,2) NOT NULL,
  pickup_date TIMESTAMPTZ,
  delivery_date TIMESTAMPTZ,
  status trip_status DEFAULT 'pending',
  posted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  load_id UUID REFERENCES loads(id),
  route_id UUID REFERENCES routes(id),
  fleet_vehicle_id UUID REFERENCES fleet_vehicles(id),
  driver_id UUID REFERENCES drivers(id),
  customer_id UUID REFERENCES customers(id),
  distance_km DECIMAL(8,2),
  fuel_cost DECIMAL(10,2) DEFAULT 0,
  toll_cost DECIMAL(10,2) DEFAULT 0,
  driver_cost DECIMAL(10,2) DEFAULT 0,
  other_expenses DECIMAL(10,2) DEFAULT 0,
  revenue DECIMAL(12,2) NOT NULL,
  profit DECIMAL(12,2),
  status trip_status DEFAULT 'pending',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- FINANCE & DUES
-- ============================================================

CREATE TYPE due_type AS ENUM (
  'vehicle_emi', 'insurance', 'permit_renewal', 'fc_renewal',
  'driver_salary', 'vendor_payment', 'customer_payment', 'tax', 'other'
);

CREATE TYPE due_status AS ENUM ('pending', 'paid', 'overdue', 'partial');

CREATE TABLE financial_dues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  due_type due_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  paid_amount DECIMAL(12,2) DEFAULT 0,
  due_date DATE NOT NULL,
  status due_status DEFAULT 'pending',
  fleet_vehicle_id UUID REFERENCES fleet_vehicles(id),
  driver_id UUID REFERENCES drivers(id),
  customer_id UUID REFERENCES customers(id),
  reminder_sent BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  customer_id UUID REFERENCES customers(id),
  trip_id UUID REFERENCES trips(id),
  amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(50),
  reference_number VARCHAR(100),
  paid_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT
);

-- ============================================================
-- DOCUMENTS
-- ============================================================

CREATE TYPE document_type AS ENUM (
  'rc', 'insurance', 'permit', 'fc', 'loan', 'driver_license', 'agreement', 'other'
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  doc_type document_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  expiry_date DATE,
  fleet_vehicle_id UUID REFERENCES fleet_vehicles(id),
  driver_id UUID REFERENCES drivers(id),
  customer_id UUID REFERENCES customers(id),
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- AI & RECOMMENDATIONS
-- ============================================================

CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id UUID REFERENCES businesses(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE ai_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE vehicle_recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  budget DECIMAL(12,2),
  city VARCHAR(100),
  expected_income DECIMAL(12,2),
  loan_amount DECIMAL(12,2),
  recommended_vehicle_id UUID REFERENCES vehicle_models(id),
  expected_roi DECIMAL(6,2),
  estimated_profit DECIMAL(12,2),
  risk_score INT,
  suitability_score INT,
  response JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- BUSINESS PLANS
-- ============================================================

CREATE TABLE business_plan_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  investment_amount DECIMAL(15,2) NOT NULL,
  recommended_vehicles JSONB NOT NULL,
  funding_requirement JSONB,
  expected_revenue JSONB,
  roi_projection JSONB,
  description TEXT,
  is_active BOOLEAN DEFAULT true
);

-- ============================================================
-- PLATFORM ANALYSIS (OLA/UBER/RAPIDO)
-- ============================================================

CREATE TABLE platform_analysis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehicle_model_id UUID NOT NULL REFERENCES vehicle_models(id) ON DELETE CASCADE,
  city VARCHAR(100) NOT NULL,
  platform VARCHAR(20) NOT NULL,
  daily_income DECIMAL(10,2),
  monthly_income DECIMAL(12,2),
  fuel_cost_monthly DECIMAL(10,2),
  commission_pct DECIMAL(5,2),
  commission_amount DECIMAL(10,2),
  driver_cost_monthly DECIMAL(10,2),
  net_profit_monthly DECIMAL(12,2),
  roi_pct DECIMAL(6,2),
  UNIQUE(vehicle_model_id, city, platform)
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TYPE notification_channel AS ENUM ('push', 'sms', 'email', 'in_app');

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id UUID REFERENCES businesses(id),
  channel notification_channel DEFAULT 'in_app',
  title VARCHAR(255) NOT NULL,
  body TEXT,
  due_id UUID REFERENCES financial_dues(id),
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SETTINGS & CONTACT
-- ============================================================

CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(100) UNIQUE NOT NULL,
  value JSONB NOT NULL,
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE consultation_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  business_id UUID REFERENCES businesses(id),
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255),
  plan_interest VARCHAR(100),
  message TEXT,
  status VARCHAR(20) DEFAULT 'new',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ANALYTICS SNAPSHOTS
-- ============================================================

CREATE TABLE dashboard_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL,
  total_investment DECIMAL(15,2),
  total_revenue DECIMAL(15,2),
  total_profit DECIMAL(15,2),
  active_vehicles INT,
  active_drivers INT,
  pending_payments DECIMAL(12,2),
  upcoming_emi DECIMAL(12,2),
  due_amounts DECIMAL(12,2),
  business_health_score INT,
  risk_score INT,
  UNIQUE(business_id, snapshot_date)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_fleet_business ON fleet_vehicles(business_id);
CREATE INDEX idx_drivers_business ON drivers(business_id);
CREATE INDEX idx_trips_business_status ON trips(business_id, status);
CREATE INDEX idx_dues_business_date ON financial_dues(business_id, due_date);
CREATE INDEX idx_dues_status ON financial_dues(status);
CREATE INDEX idx_documents_expiry ON documents(expiry_date);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER fleet_vehicles_updated_at BEFORE UPDATE ON fleet_vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER drivers_updated_at BEFORE UPDATE ON drivers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trips_updated_at BEFORE UPDATE ON trips FOR EACH ROW EXECUTE FUNCTION update_updated_at();

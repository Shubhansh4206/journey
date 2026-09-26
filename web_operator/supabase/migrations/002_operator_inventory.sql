-- ==============================================================================
-- JOURNEY TOUR OPERATOR: TIED-UP PARTNER INVENTORY & GUIDES SCHEMA
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/gwisnrgiuunhfcjernar/sql/new
-- ==============================================================================

-- Enable UUID extension if available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 0. Ensure Tour Operators table exists (references auth.users)
CREATE TABLE IF NOT EXISTS tour_operators (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Automated trigger: Automatically populate tour_operators whenever a user signs up via auth
CREATE OR REPLACE FUNCTION public.handle_new_tour_operator()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.tour_operators (id, company_name, contact_email, created_at)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'company_name', 'Tour Operator Agency'),
        COALESCE(new.email, ''),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        company_name = EXCLUDED.company_name,
        contact_email = EXCLUDED.contact_email;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_tour_operator();

-- 1. Tied-up Hotels & Accommodations (Mumbai, Udaipur, Jaipur, Goa)
CREATE TABLE IF NOT EXISTS operator_hotels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID REFERENCES tour_operators(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL, -- 'Mumbai', 'Udaipur', 'Jaipur', 'Goa'
    address TEXT,
    star_rating INT CHECK (star_rating >= 1 AND star_rating <= 5),
    contracted_rate_per_night NUMERIC(10, 2) NOT NULL, -- Vendor base cost
    amenities JSONB DEFAULT '[]'::jsonb,
    contact_person VARCHAR(100),
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Places of Interest / Sightseeing (Mumbai, Udaipur, Jaipur, Goa)
CREATE TABLE IF NOT EXISTS operator_places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID REFERENCES tour_operators(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL, -- 'Mumbai', 'Udaipur', 'Jaipur', 'Goa'
    description TEXT,
    entry_fee_per_person NUMERIC(10, 2) DEFAULT 0.00,
    recommended_duration_minutes INT DEFAULT 60,
    tags JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Activities & Experiences
CREATE TABLE IF NOT EXISTS operator_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID REFERENCES tour_operators(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    location VARCHAR(255), -- 'Mumbai', 'Udaipur', 'Jaipur', 'Goa'
    cost_per_person NUMERIC(10, 2) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 120,
    activity_type VARCHAR(100) DEFAULT 'cultural',
    inclusions JSONB DEFAULT '[]'::jsonb,
    restrictions JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Travel / Transport Fleet & Partners
CREATE TABLE IF NOT EXISTS operator_transport (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID REFERENCES tour_operators(id) ON DELETE SET NULL,
    vehicle_type VARCHAR(100) NOT NULL,
    capacity_passengers INT NOT NULL DEFAULT 4,
    cost_per_day NUMERIC(10, 2) DEFAULT 0.00,
    cost_per_km NUMERIC(10, 2) DEFAULT 0.00,
    vendor_company_name VARCHAR(255),
    contact_phone VARCHAR(50),
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Licensed Tour Guides (Essential fields only)
CREATE TABLE IF NOT EXISTS tour_guides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID REFERENCES tour_operators(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL DEFAULT 'Mumbai', -- 'Mumbai', 'Udaipur', 'Jaipur', 'Goa'
    contact_number VARCHAR(50),
    languages JSONB DEFAULT '["English", "Hindi"]'::jsonb,
    daily_rate NUMERIC(10, 2) NOT NULL DEFAULT 150.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE tour_operators ENABLE ROW LEVEL SECURITY;
ALTER TABLE operator_hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE operator_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE operator_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE operator_transport ENABLE ROW LEVEL SECURITY;
ALTER TABLE tour_guides ENABLE ROW LEVEL SECURITY;

-- Operator isolation policies: Operators can only select, insert, update, delete their own inventory
DROP POLICY IF EXISTS "Allow public read/write on tour_operators" ON tour_operators;
DROP POLICY IF EXISTS "Allow public read/write on operator_hotels" ON operator_hotels;
DROP POLICY IF EXISTS "Allow public read/write on operator_places" ON operator_places;
DROP POLICY IF EXISTS "Allow public read/write on operator_activities" ON operator_activities;
DROP POLICY IF EXISTS "Allow public read/write on operator_transport" ON operator_transport;
DROP POLICY IF EXISTS "Allow public read/write on tour_guides" ON tour_guides;

DROP POLICY IF EXISTS "Operators can manage own profile" ON tour_operators;
DROP POLICY IF EXISTS "Operators can manage own hotels" ON operator_hotels;
DROP POLICY IF EXISTS "Operators can manage own places" ON operator_places;
DROP POLICY IF EXISTS "Operators can manage own activities" ON operator_activities;
DROP POLICY IF EXISTS "Operators can manage own transport" ON operator_transport;
DROP POLICY IF EXISTS "Operators can manage own guides" ON tour_guides;

-- Operator profile policies: Allow signup creation and authenticated management
CREATE POLICY "Allow insert profile on signup" ON tour_operators
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow select tour operators" ON tour_operators
    FOR SELECT USING (true);

CREATE POLICY "Allow update own profile" ON tour_operators
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Operators can manage own hotels" ON operator_hotels
    FOR ALL USING (auth.uid() = operator_id OR operator_id IS NULL) WITH CHECK (auth.uid() = operator_id OR operator_id IS NULL);

CREATE POLICY "Operators can manage own places" ON operator_places
    FOR ALL USING (auth.uid() = operator_id OR operator_id IS NULL) WITH CHECK (auth.uid() = operator_id OR operator_id IS NULL);

CREATE POLICY "Operators can manage own activities" ON operator_activities
    FOR ALL USING (auth.uid() = operator_id OR operator_id IS NULL) WITH CHECK (auth.uid() = operator_id OR operator_id IS NULL);

CREATE POLICY "Operators can manage own transport" ON operator_transport
    FOR ALL USING (auth.uid() = operator_id OR operator_id IS NULL) WITH CHECK (auth.uid() = operator_id OR operator_id IS NULL);

CREATE POLICY "Operators can manage own guides" ON tour_guides
    FOR ALL USING (auth.uid() = operator_id OR operator_id IS NULL) WITH CHECK (auth.uid() = operator_id OR operator_id IS NULL);

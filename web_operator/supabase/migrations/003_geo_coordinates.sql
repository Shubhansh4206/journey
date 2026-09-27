-- ==============================================================================
-- JOURNEY TOUR OPERATOR: LATITUDE & LONGITUDE SPATIAL COLUMNS & INDICES
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/gwisnrgiuunhfcjernar/sql/new
-- ==============================================================================

-- 1. Operator Hotels
ALTER TABLE IF EXISTS public.operator_hotels 
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6) NULL,
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6) NULL;

CREATE INDEX IF NOT EXISTS idx_hotels_lat_lng 
  ON public.operator_hotels USING btree (latitude, longitude);

-- 2. Operator Places
ALTER TABLE IF EXISTS public.operator_places 
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6) NULL,
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6) NULL;

CREATE INDEX IF NOT EXISTS idx_places_lat_lng 
  ON public.operator_places USING btree (latitude, longitude);

-- 3. Operator Activities
ALTER TABLE IF EXISTS public.operator_activities 
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6) NULL,
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6) NULL;

CREATE INDEX IF NOT EXISTS idx_activities_lat_lng 
  ON public.operator_activities USING btree (latitude, longitude);

-- 4. Operator Transport Fleet
ALTER TABLE IF EXISTS public.operator_transport 
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6) NULL,
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6) NULL;

CREATE INDEX IF NOT EXISTS idx_transport_lat_lng 
  ON public.operator_transport USING btree (latitude, longitude);

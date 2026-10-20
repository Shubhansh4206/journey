-- ==============================================================================
-- JOURNEY TOUR OPERATOR: TRIP REQUESTS READ & WRITE POLICIES
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/gwisnrgiuunhfcjernar/sql/new
-- ==============================================================================

-- 1. Enable RLS on trip_requests
ALTER TABLE IF EXISTS public.trip_requests ENABLE ROW LEVEL SECURITY;

-- 2. Allow operators and clients to read trip_requests
DROP POLICY IF EXISTS "Allow public read trip_requests" ON public.trip_requests;
CREATE POLICY "Allow public read trip_requests" 
  ON public.trip_requests 
  FOR SELECT 
  USING (true);

-- 3. Allow inserting trip_requests
DROP POLICY IF EXISTS "Allow public insert trip_requests" ON public.trip_requests;
CREATE POLICY "Allow public insert trip_requests" 
  ON public.trip_requests 
  FOR INSERT 
  WITH CHECK (true);

-- 4. Allow updating trip_requests status
DROP POLICY IF EXISTS "Allow public update trip_requests" ON public.trip_requests;
CREATE POLICY "Allow public update trip_requests" 
  ON public.trip_requests 
  FOR UPDATE 
  USING (true);

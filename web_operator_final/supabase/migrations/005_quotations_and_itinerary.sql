-- ==============================================================================
-- JOURNEY TOUR OPERATOR: QUOTATIONS & ITINERARY GRAPH SCHEMA
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/gwisnrgiuunhfcjernar/sql/new
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. The Parent Quotations Table
CREATE TABLE IF NOT EXISTS public.quotations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_request_id UUID NOT NULL REFERENCES public.trip_requests(id) ON DELETE CASCADE,
    operator_id UUID NOT NULL,
    title VARCHAR(255) DEFAULT 'Your Customized Itinerary',
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'user_modified', 'accepted', 'declined')),
    currency VARCHAR(10) DEFAULT 'INR',
    total_base_cost NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_margin_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_final_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    customer_notes TEXT NULL,
    operator_notes TEXT NULL,
    valid_until TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Itinerary Nodes Table
CREATE TABLE IF NOT EXISTS public.itinerary_nodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_id UUID NOT NULL REFERENCES public.quotations(id) ON DELETE CASCADE,
    node_type VARCHAR(50) NOT NULL CHECK (node_type IN ('HOTEL', 'ACTIVITY', 'TRANSFER', 'PLACE', 'FLIGHT')),
    title VARCHAR(255) NOT NULL,
    location_subtitle VARCHAR(255) NULL,
    day_number INT DEFAULT 1,
    time_slot VARCHAR(50) NULL,
    base_cost NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    margin_percentage NUMERIC(5, 2) NOT NULL DEFAULT 0.00,
    -- Generated Always column storing computed final customer price
    final_price NUMERIC(10, 2) GENERATED ALWAYS AS (
        (base_cost + ((base_cost * margin_percentage) / 100::NUMERIC))
    ) STORED,
    ui_coordinates JSONB NULL DEFAULT '{"x": 100, "y": 100}'::jsonb,
    specs JSONB NULL DEFAULT '{}'::jsonb, -- inclusions, duration_minutes, vehicle_info, rating, address
    original_inventory_id UUID NULL,
    is_optional BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Itinerary Edges Table
CREATE TABLE IF NOT EXISTS public.itinerary_edges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_id UUID NOT NULL REFERENCES public.quotations(id) ON DELETE CASCADE,
    source_node_id UUID NOT NULL REFERENCES public.itinerary_nodes(id) ON DELETE CASCADE,
    target_node_id UUID NOT NULL REFERENCES public.itinerary_nodes(id) ON DELETE CASCADE,
    edge_type VARCHAR(50) DEFAULT 'transit', -- 'transit', 'walk', 'flight', 'sequential'
    travel_time_minutes INT NULL DEFAULT 0,
    distance_km NUMERIC(6, 2) NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Customer-Safe Views (hiding internal operator cost and profit margins)
CREATE OR REPLACE VIEW public.customer_quotations_view AS
SELECT 
    q.id AS quotation_id,
    q.trip_request_id,
    q.title,
    q.status,
    q.currency,
    q.total_final_price,
    q.valid_until,
    q.customer_notes,
    q.created_at,
    q.updated_at
FROM public.quotations q;

CREATE OR REPLACE VIEW public.customer_itinerary_nodes_view AS
SELECT 
    n.id AS node_id,
    n.quotation_id,
    n.node_type,
    n.title,
    n.location_subtitle,
    n.day_number,
    n.time_slot,
    n.final_price,
    n.is_optional,
    n.specs,
    n.ui_coordinates
FROM public.itinerary_nodes n;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_quotations_trip_req ON public.quotations(trip_request_id);
CREATE INDEX IF NOT EXISTS idx_quotations_operator ON public.quotations(operator_id);
CREATE INDEX IF NOT EXISTS idx_itinerary_nodes_quote ON public.itinerary_nodes(quotation_id);
CREATE INDEX IF NOT EXISTS idx_itinerary_edges_quote ON public.itinerary_edges(quotation_id);

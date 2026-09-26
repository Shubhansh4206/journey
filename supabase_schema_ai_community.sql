-- ==============================================================================
-- AI Solo Traveler Community - Supabase SQL Schema
-- ==============================================================================

-- 1. Trip "Post-Its" (Individual solo trip drafts waiting for AI clustering)
CREATE TABLE IF NOT EXISTS public.trip_post_its (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    destination TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget_per_pax NUMERIC NOT NULL,
    desired_hotels JSONB DEFAULT '[]'::jsonb,
    desired_activities JSONB DEFAULT '[]'::jsonb,
    desired_places JSONB DEFAULT '[]'::jsonb,
    desired_transport JSONB DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'clustered', 'archived')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. AI Communities (Clustered master community itineraries)
CREATE TABLE IF NOT EXISTS public.ai_communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    tagline TEXT,
    cover_image_url TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    -- Fixed Core Base: Hotel and Transport are strictly fixed
    fixed_hotel JSONB NOT NULL DEFAULT '{}'::jsonb,
    fixed_transport JSONB NOT NULL DEFAULT '{}'::jsonb,
    -- Flexible Activity Roster: Open activities with opt-out capability
    activity_roster JSONB NOT NULL DEFAULT '[]'::jsonb,
    places_roster JSONB NOT NULL DEFAULT '[]'::jsonb,
    master_estimated_budget NUMERIC NOT NULL,
    max_members INT NOT NULL DEFAULT 8,
    status TEXT NOT NULL DEFAULT 'forming' CHECK (status IN ('forming', 'locked', 'in_progress', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Community Members (Memberships, Compatibility scores & Opt-out states)
CREATE TABLE IF NOT EXISTS public.community_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID NOT NULL REFERENCES public.ai_communities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT,
    compatibility_score INT NOT NULL CHECK (compatibility_score BETWEEN 0 AND 100),
    status TEXT NOT NULL DEFAULT 'invited' CHECK (status IN ('invited', 'accepted', 'declined', 'bookmarked')),
    -- Array of activity IDs the user has opted out of
    opted_out_activity_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
    personal_estimated_budget NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(community_id, user_id)
);

-- 4. Community Polls / Activity Votes (For group negotiation)
CREATE TABLE IF NOT EXISTS public.community_polls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID NOT NULL REFERENCES public.ai_communities(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES auth.users(id),
    creator_name TEXT NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of { id, text, vote_count, voter_ids: [] }
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved', 'closed')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Community Chat Messages
CREATE TABLE IF NOT EXISTS public.community_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID NOT NULL REFERENCES public.ai_communities(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id),
    sender_name TEXT NOT NULL,
    sender_avatar TEXT,
    message TEXT NOT NULL,
    poll_id UUID REFERENCES public.community_polls(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Indexes for performance ──────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_trip_post_its_dest_status ON public.trip_post_its(destination, status);
CREATE INDEX IF NOT EXISTS idx_community_members_user_status ON public.community_members(user_id, status);
CREATE INDEX IF NOT EXISTS idx_community_messages_community ON public.community_messages(community_id, created_at);

-- ── Enable Row Level Security (RLS) ──────────────────────────────────────────
ALTER TABLE public.trip_post_its ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_messages ENABLE ROW LEVEL SECURITY;

-- ── RLS Policies ─────────────────────────────────────────────────────────────
CREATE POLICY "Allow users to manage their own post-its"
    ON public.trip_post_its FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Allow public read of active ai communities"
    ON public.ai_communities FOR SELECT
    USING (true);

CREATE POLICY "Allow members to view community memberships"
    ON public.community_members FOR SELECT
    USING (true);

CREATE POLICY "Allow members to update their own community status & opt-outs"
    ON public.community_members FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Allow community members to view and create polls"
    ON public.community_polls FOR ALL
    USING (true);

CREATE POLICY "Allow community members to view and post chat messages"
    ON public.community_messages FOR ALL
    USING (true);

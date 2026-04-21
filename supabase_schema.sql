-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/wkvakrcappcyftdoejjw/sql

-- Quiz sessions (one per room)
CREATE TABLE IF NOT EXISTS wsi_sessions (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  room_code    text UNIQUE NOT NULL,
  questions    jsonb NOT NULL,          -- [{text, author, choices[]}]
  participant_names text[] NOT NULL,
  created_at   timestamptz DEFAULT now(),
  expires_at   timestamptz DEFAULT (now() + interval '24 hours')
);

-- Player scores
CREATE TABLE IF NOT EXISTS wsi_scores (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id   uuid REFERENCES wsi_sessions(id) ON DELETE CASCADE,
  player_name  text NOT NULL,
  score        integer NOT NULL,
  total        integer NOT NULL,
  answers      jsonb,
  created_at   timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE wsi_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wsi_scores   ENABLE ROW LEVEL SECURITY;

-- Open policies (anon key, friend-group app — no auth needed)
CREATE POLICY "anon_all_sessions" ON wsi_sessions FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_scores"   ON wsi_scores   FOR ALL TO anon USING (true) WITH CHECK (true);

-- Enable Realtime for live lobby updates
ALTER PUBLICATION supabase_realtime ADD TABLE wsi_scores;

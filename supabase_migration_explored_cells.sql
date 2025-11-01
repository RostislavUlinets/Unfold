-- Migration: Create explored_cells table for fog of exploration feature
-- Run this in your Supabase SQL Editor

-- Create explored_cells table
CREATE TABLE IF NOT EXISTS explored_cells (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    cell_id TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    explored_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, cell_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_explored_cells_user ON explored_cells(user_id);
CREATE INDEX IF NOT EXISTS idx_explored_cells_location ON explored_cells(latitude, longitude);

-- Enable Row Level Security
ALTER TABLE explored_cells ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user data isolation
CREATE POLICY "Users can view own cells"
    ON explored_cells FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cells"
    ON explored_cells FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Grant necessary permissions
GRANT ALL ON explored_cells TO authenticated;

-- Verify table creation
COMMENT ON TABLE explored_cells IS 'Stores explored grid cells for fog of exploration feature';

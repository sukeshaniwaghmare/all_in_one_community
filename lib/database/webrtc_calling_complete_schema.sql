-- ============================================
-- WebRTC Calling System - Complete Schema
-- ============================================

-- 1. Calls Table
CREATE TABLE IF NOT EXISTS calls (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    call_type VARCHAR(10) NOT NULL CHECK (call_type IN ('audio', 'video')),
    status VARCHAR(20) NOT NULL DEFAULT 'ringing' CHECK (status IN ('ringing', 'accepted', 'rejected', 'ended', 'missed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER DEFAULT 0,
    CONSTRAINT different_users CHECK (caller_id != receiver_id)
);

-- 2. Call Signals Table (for SDP and ICE candidates)
CREATE TABLE IF NOT EXISTS call_signals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    call_id UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    signal_type VARCHAR(20) NOT NULL CHECK (signal_type IN ('offer', 'answer', 'ice_candidate')),
    signal_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_calls_caller ON calls(caller_id);
CREATE INDEX IF NOT EXISTS idx_calls_receiver ON calls(receiver_id);
CREATE INDEX IF NOT EXISTS idx_calls_status ON calls(status);
CREATE INDEX IF NOT EXISTS idx_calls_created_at ON calls(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_signals_call_id ON call_signals(call_id);
CREATE INDEX IF NOT EXISTS idx_call_signals_created_at ON call_signals(created_at DESC);

-- 4. Enable Row Level Security
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_signals ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for calls table
CREATE POLICY "Users can view their own calls" ON calls
    FOR SELECT USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can initiate calls" ON calls
    FOR INSERT WITH CHECK (auth.uid() = caller_id);

CREATE POLICY "Users can update their calls" ON calls
    FOR UPDATE USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can delete their calls" ON calls
    FOR DELETE USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

-- 6. RLS Policies for call_signals table
CREATE POLICY "Users can view signals for their calls" ON call_signals
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM calls 
            WHERE calls.id = call_signals.call_id 
            AND (calls.caller_id = auth.uid() OR calls.receiver_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert signals for their calls" ON call_signals
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM calls 
            WHERE calls.id = call_signals.call_id 
            AND (calls.caller_id = auth.uid() OR calls.receiver_id = auth.uid())
        )
    );

-- 7. Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE calls;
ALTER PUBLICATION supabase_realtime ADD TABLE call_signals;

-- 8. Function to auto-update call duration
CREATE OR REPLACE FUNCTION update_call_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'ended' AND NEW.started_at IS NOT NULL THEN
        NEW.duration = EXTRACT(EPOCH FROM (NEW.ended_at - NEW.started_at))::INTEGER;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Trigger for auto-updating duration
DROP TRIGGER IF EXISTS trigger_update_call_duration ON calls;
CREATE TRIGGER trigger_update_call_duration
    BEFORE UPDATE ON calls
    FOR EACH ROW
    WHEN (NEW.status = 'ended')
    EXECUTE FUNCTION update_call_duration();
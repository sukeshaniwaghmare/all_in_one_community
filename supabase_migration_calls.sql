-- Calls table for WebRTC signaling
CREATE TABLE calls (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caller_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    call_type VARCHAR(10) CHECK (call_type IN ('audio', 'video')) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('ringing', 'accepted', 'rejected', 'ended', 'missed')) DEFAULT 'ringing',
    offer JSONB,
    answer JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER DEFAULT 0
);

-- ICE candidates table
CREATE TABLE ice_candidates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    call_id UUID REFERENCES calls(id) ON DELETE CASCADE,
    candidate JSONB NOT NULL,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE ice_candidates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for calls
CREATE POLICY "Users can view their own calls" ON calls
    FOR SELECT USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can insert calls they initiate" ON calls
    FOR INSERT WITH CHECK (auth.uid() = caller_id);

CREATE POLICY "Users can update their own calls" ON calls
    FOR UPDATE USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

-- RLS Policies for ice_candidates
CREATE POLICY "Users can view candidates for their calls" ON ice_candidates
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM calls 
            WHERE calls.id = ice_candidates.call_id 
            AND (calls.caller_id = auth.uid() OR calls.receiver_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert candidates for their calls" ON ice_candidates
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM calls 
            WHERE calls.id = ice_candidates.call_id 
            AND (calls.caller_id = auth.uid() OR calls.receiver_id = auth.uid())
        )
    );

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE calls;
ALTER PUBLICATION supabase_realtime ADD TABLE ice_candidates;
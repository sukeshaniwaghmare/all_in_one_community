-- Add deleted_for column to messages table
-- This column stores the user_id who deleted the message (for "delete for me" feature)

ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS deleted_for UUID REFERENCES user_profiles(id);

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_messages_deleted_for ON messages(deleted_for);

-- Comment
COMMENT ON COLUMN messages.deleted_for IS 'User ID who deleted this message (for delete for me feature)';

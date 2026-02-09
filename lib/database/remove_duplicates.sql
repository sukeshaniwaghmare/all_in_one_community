-- Run this SQL query in Supabase SQL Editor to remove duplicate group_members

-- Delete duplicates, keeping only the first entry for each group_id + user_id combination
DELETE FROM group_members
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM group_members
  GROUP BY group_id, user_id
);

-- Verify no duplicates remain
SELECT group_id, user_id, COUNT(*) as count
FROM group_members
GROUP BY group_id, user_id
HAVING COUNT(*) > 1;

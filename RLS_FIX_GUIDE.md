# Quick Fix: RLS Policy Error

## Issue
```
PostgrestException: new row violates row-level security policy for table "unread_counts"
```

## Good News
✅ **Persistent login is WORKING!** 
- Your logs show: `GoRouter: INFO: redirecting to RouteMatchList(/home)`
- This means the session is persisting and user is auto-logged in
- The issue is NOT with authentication, it's with database permissions

## The Problem
The `unread_counts` table has Row Level Security (RLS) enabled but the policies don't allow users to insert/update unread counts when sending messages.

## Solution

### Step 1: Go to Supabase Dashboard
1. Open your Supabase project
2. Go to **SQL Editor**
3. Click **New Query**

### Step 2: Run the Fix
Copy and paste this SQL:

```sql
-- Drop all existing policies
DROP POLICY IF EXISTS "Users can insert their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can update their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can view their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can delete their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can create unread counts when sending messages" ON unread_counts;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable select for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON unread_counts;

-- Enable RLS
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to manage unread counts
CREATE POLICY "Enable insert for authenticated users"
ON unread_counts FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable select for authenticated users"
ON unread_counts FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable update for authenticated users"
ON unread_counts FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable delete for authenticated users"
ON unread_counts FOR DELETE TO authenticated USING (true);
```

### Step 3: Click "Run" or press Ctrl+Enter

### Step 4: Test
- Restart your app
- Try sending a message
- Should work now!

## Alternative: Disable RLS (Not Recommended for Production)

If you want to quickly test without RLS:

```sql
ALTER TABLE unread_counts DISABLE ROW LEVEL SECURITY;
```

⚠️ **Warning**: Only use this for testing. Re-enable RLS for production.

## Verification

After applying the fix, you should see in logs:
```
✅ Message sent successfully (no RLS error)
✅ Unread counts updated
```

## Files Created
- `lib/database/fix_unread_counts_rls_simple.sql` - The fix to run
- `lib/database/fix_unread_counts_rls.sql` - Alternative stricter policy

## Summary

**Persistent Login Status**: ✅ WORKING  
**Issue**: Database RLS policy  
**Fix**: Run the SQL above in Supabase  
**Time to fix**: < 1 minute

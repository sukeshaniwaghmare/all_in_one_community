# Database Fix Instructions

## Problem
The error `infinite recursion detected in policy for relation "chat_room_members"` occurs because the RLS policies are referencing the same table they're protecting, creating a circular dependency.

## Solution
1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Run the SQL script in `lib/database/fix_chat_policies.sql`

## What the fix does:
- Removes the problematic self-referencing policies
- Creates helper functions to check room membership without recursion
- Implements new policies that use these functions
- Fixes the circular dependency issue

## Performance Improvements Applied:
- Optimized contact loading to use background processing
- Reduced main thread blocking during contact operations
- Limited contact photo loading for better performance

After applying these fixes, your chat functionality should work without the PostgreSQL recursion error.
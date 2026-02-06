# Supabase Setup Guide

## Prerequisites
1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project in Supabase

## Database Setup

### Step 1: Run Database Schema
1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `lib/database/setup_database.sql`
4. Run the script to create all necessary tables and policies

### Step 2: Configure Environment Variables
Your `.env` file should contain:
```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Step 3: Setup Storage for Chat Media
1. In Supabase dashboard, go to Storage
2. Run the SQL script from `supabase/storage_setup.sql` in the SQL Editor
3. This creates a public bucket called 'chat-media' for images and videos

### Step 4: Enable Authentication
1. In Supabase dashboard, go to Authentication > Settings
2. Enable Email authentication
3. Configure any additional auth providers if needed

## Database Tables Created

### 1. profiles
- Stores user profile information
- Linked to Supabase auth.users
- Includes name, email, avatar, bio, etc.

### 2. communities
- Stores community information
- Different types: society, village, college, office, openGroup
- Public/private communities with member management

### 3. community_members
- Junction table for community membership
- Roles: admin, moderator, member
- Automatic member count updates

### 4. cart_items
- Shopping cart functionality
- User-specific cart items
- Product details and quantities

## Row Level Security (RLS)
All tables have RLS enabled with appropriate policies:
- Users can only access their own data
- Community members can view community data
- Admins have additional permissions

## Flutter Integration
The app uses:
- `SupabaseService` for database operations
- `AuthProvider` for authentication
- `CartProvider` for cart management
- Proper error handling and loading states

## Testing the Connection
1. Run `flutter pub get` to install dependencies
2. Ensure your `.env` file is properly configured
3. Run the app and test authentication
4. Check Supabase dashboard for user registration and data

## Troubleshooting
- Verify environment variables are correct
- Check Supabase project URL and keys
- Ensure RLS policies allow your operations
- Check network connectivity
- Review Supabase logs for errors
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')!

Deno.serve(async (req) => {
  try {
    const { receiver_id, sender_id, sender_name, message } = await req.json()

    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get receiver FCM token
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('fcm_token')
      .eq('id', receiver_id)
      .single()

    if (!profile?.fcm_token) {
      return new Response(JSON.stringify({ error: 'No FCM token' }), { status: 400 })
    }

    // Send FCM notification
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: profile.fcm_token,
        priority: 'high',
        notification: {
          title: sender_name,
          body: message,
          sound: 'default',
        },
        data: {
          sender_id: sender_id,
          sender_name: sender_name,
          message: message,
        },
      }),
    })

    const result = await fcmResponse.json()
    return new Response(JSON.stringify({ success: true, result }), { status: 200 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})

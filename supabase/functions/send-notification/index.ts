import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { message_id, chat_id, sender_id, content } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: sender } = await supabase
      .from('users')
      .select('name')
      .eq('id', sender_id)
      .single()

    const { data: participants } = await supabase
      .from('chat_participants')
      .select('user_id, users!inner(fcm_token)')
      .eq('chat_id', chat_id)
      .neq('user_id', sender_id)

    if (!participants?.length) {
      return new Response('No recipients', { status: 200, headers: corsHeaders })
    }

    const fcmKey = Deno.env.get('FCM_SERVER_KEY')
    const notifications = participants
      .filter(p => p.users.fcm_token)
      .map(async (participant) => {
        const payload = {
          to: participant.users.fcm_token,
          notification: {
            title: sender?.name || 'New Message',
            body: content.startsWith('IMAGE:') ? '📷 Photo' : 
                  content.startsWith('VIDEO:') ? '🎥 Video' : content,
            sound: 'default',
          },
          data: {
            type: 'chat_message',
            chat_id: chat_id,
            message_id: message_id,
          }
        }

        return fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Authorization': `key=${fcmKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(payload),
        })
      })

    await Promise.all(notifications)

    return new Response('Sent', { status: 200, headers: corsHeaders })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
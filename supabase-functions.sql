-- Elite Services - Supabase Functions
-- Run this in your Supabase SQL Editor after deploying schema.sql

-- ═══════════════════════════════════════════════════════════════════════════
-- Function: get_or_create_conversation
-- Purpose: Find existing conversation or create new one for incoming message
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_or_create_conversation(
  p_sender_id TEXT,
  p_channel TEXT,
  p_agent_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_conversation conversations;
  v_result JSON;
BEGIN
  -- Try to find existing open conversation from this sender
  SELECT * INTO v_conversation
  FROM conversations
  WHERE agent_id = p_agent_id
    AND channel = p_channel
    AND (
      -- Match by phone/email if captured
      contact_phone = p_sender_id
      OR contact_email = p_sender_id
      -- Or match by sender_id stored in flow_state
      OR flow_state->>'sender_id' = p_sender_id
    )
    AND status IN ('open', 'escalated')
  ORDER BY updated_at DESC
  LIMIT 1;

  -- If no conversation found, create a new one
  IF v_conversation.id IS NULL THEN
    INSERT INTO conversations (
      agent_id,
      channel,
      status,
      flow_state,
      created_at,
      updated_at
    ) VALUES (
      p_agent_id,
      p_channel,
      'open',
      jsonb_build_object(
        'current_step', 'greeting',
        'collected_data', jsonb_build_object(),
        'sender_id', p_sender_id,
        'started_at', NOW()
      ),
      NOW(),
      NOW()
    )
    RETURNING * INTO v_conversation;
  END IF;

  -- Build JSON response
  v_result := jsonb_build_object(
    'conversation', row_to_json(v_conversation)
  );

  RETURN v_result;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Function: mark_conversation_complete
-- Purpose: Mark conversation as complete and calculate final metrics
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION mark_conversation_complete(
  p_conversation_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  v_conversation conversations;
  v_message_count INT;
  v_result JSON;
BEGIN
  -- Count messages in conversation
  SELECT COUNT(*) INTO v_message_count
  FROM messages
  WHERE conversation_id = p_conversation_id;

  -- Update conversation status
  UPDATE conversations
  SET
    status = 'closed',
    updated_at = NOW(),
    flow_state = flow_state || jsonb_build_object(
      'completed_at', NOW(),
      'total_messages', v_message_count
    )
  WHERE id = p_conversation_id
  RETURNING * INTO v_conversation;

  v_result := jsonb_build_object(
    'success', true,
    'conversation', row_to_json(v_conversation)
  );

  RETURN v_result;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Function: get_conversation_transcript
-- Purpose: Get full conversation history as formatted text
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_conversation_transcript(
  p_conversation_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_transcript TEXT := '';
  v_message RECORD;
BEGIN
  FOR v_message IN
    SELECT
      role,
      content,
      created_at
    FROM messages
    WHERE conversation_id = p_conversation_id
    ORDER BY created_at ASC
  LOOP
    v_transcript := v_transcript ||
      CASE v_message.role
        WHEN 'user' THEN '👤 User: '
        WHEN 'assistant' THEN '🤖 Assistant: '
        ELSE v_message.role || ': '
      END ||
      v_message.content ||
      E'\n' ||
      '   (' || TO_CHAR(v_message.created_at, 'YYYY-MM-DD HH24:MI:SS') || ')' ||
      E'\n\n';
  END LOOP;

  RETURN v_transcript;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Function: get_hot_leads
-- Purpose: Get all HOT leads with conversation context
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_hot_leads(
  p_organization_id UUID,
  p_limit INT DEFAULT 50
)
RETURNS TABLE (
  lead_id UUID,
  lead_name TEXT,
  lead_phone TEXT,
  lead_email TEXT,
  service_type TEXT,
  lead_score INT,
  urgency TEXT,
  source_channel TEXT,
  created_at TIMESTAMPTZ,
  conversation_transcript TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    l.id AS lead_id,
    l.name AS lead_name,
    l.phone AS lead_phone,
    l.email AS lead_email,
    l.service_type,
    l.lead_score,
    l.urgency,
    l.source_channel,
    l.created_at,
    get_conversation_transcript(
      (SELECT id FROM conversations WHERE contact_email = l.email OR contact_phone = l.phone LIMIT 1)
    ) AS conversation_transcript
  FROM leads l
  WHERE l.organization_id = p_organization_id
    AND l.is_hot = true
  ORDER BY l.lead_score DESC, l.created_at DESC
  LIMIT p_limit;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- View: recent_conversations_with_lead_status
-- Purpose: Easy view of recent conversations with lead info
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW recent_conversations_with_lead_status AS
SELECT
  c.id AS conversation_id,
  c.contact_name,
  c.contact_phone,
  c.contact_email,
  c.channel,
  c.status AS conversation_status,
  c.flow_state->>'current_step' AS current_step,
  c.created_at AS conversation_started,
  c.updated_at AS last_activity,
  l.id AS lead_id,
  l.service_type,
  l.lead_score,
  l.is_hot,
  l.urgency,
  (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id) AS message_count
FROM conversations c
LEFT JOIN leads l ON (
  l.email = c.contact_email OR l.phone = c.contact_phone
)
ORDER BY c.updated_at DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- Grant permissions to service role
-- ═══════════════════════════════════════════════════════════════════════════

-- The service role key bypasses RLS, but explicit grants are good practice
GRANT EXECUTE ON FUNCTION get_or_create_conversation TO service_role;
GRANT EXECUTE ON FUNCTION mark_conversation_complete TO service_role;
GRANT EXECUTE ON FUNCTION get_conversation_transcript TO service_role;
GRANT EXECUTE ON FUNCTION get_hot_leads TO service_role;

-- ═══════════════════════════════════════════════════════════════════════════
-- Test the function (optional)
-- ═══════════════════════════════════════════════════════════════════════════

-- Test creating/getting a conversation
-- SELECT get_or_create_conversation(
--   'test-sender-123',
--   'web',
--   'your-agent-uuid-here'::UUID
-- );

-- Test getting hot leads
-- SELECT * FROM get_hot_leads('your-org-uuid-here'::UUID, 10);

-- Test viewing recent conversations
-- SELECT * FROM recent_conversations_with_lead_status LIMIT 10;

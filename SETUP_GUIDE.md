# Elite Services N8N Workflow - Setup Guide

## Overview

This N8N workflow powers an AI-driven lead generation assistant for Elite Services, handling conversations across Facebook Messenger, Instagram DMs, and web chat.

## What It Does

- **Natural Conversations**: AI-powered chat that sounds human (no "bot" mentions)
- **Multi-Channel**: Facebook Messenger, Instagram, and web chat support
- **Smart Lead Scoring**: Automatically scores leads 1-10 and flags HOT leads
- **Instant Alerts**: Slack + Email notifications for high-value leads
- **Complete Tracking**: All conversations saved to Supabase + Google Sheets
- **Service-Specific Flows**: Different questions for each of 5 cleaning services

## Architecture

```
Webhook (FB/IG/Web)
  → Normalize Message
  → Get/Create Conversation (Supabase)
  → Check Human Handover
  → Save User Message
  → AI Processor (OpenRouter)
  → Parse Response
  → Typing Delay (1-3s)
  → Update State
  → Save Assistant Message
  → If Complete → Score Lead → Create Lead → Notify if HOT
  → Send Response
```

---

## Prerequisites

1. **N8N Instance** - Self-hosted or cloud
2. **Supabase Project** - With schema.sql deployed
3. **OpenRouter Account** - For AI processing
4. **Meta Developer Account** - For Facebook/Instagram
5. **Google Workspace** - For Sheets and Gmail
6. **Slack Workspace** - For HOT lead alerts

---

## Step 1: Deploy Supabase Schema

First, create the required Supabase function for conversation management.

### Create SQL Function

Run this in your Supabase SQL Editor:

```sql
-- Function to get existing conversation or create new one
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
  -- Try to find existing open conversation
  SELECT * INTO v_conversation
  FROM conversations
  WHERE agent_id = p_agent_id
    AND channel = p_channel
    AND (
      contact_phone = p_sender_id
      OR contact_email = p_sender_id
      OR flow_state->>'sender_id' = p_sender_id
    )
    AND status IN ('open', 'escalated')
  ORDER BY updated_at DESC
  LIMIT 1;

  -- If no conversation found, create one
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
        'collected_data', '{}',
        'sender_id', p_sender_id
      ),
      NOW(),
      NOW()
    )
    RETURNING * INTO v_conversation;
  END IF;

  -- Return as JSON
  v_result := jsonb_build_object(
    'conversation', row_to_json(v_conversation)
  );

  RETURN v_result;
END;
$$;
```

---

## Step 2: Environment Variables

Create these environment variables in your N8N instance:

### Required Variables

```bash
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key

# OpenRouter AI
OPENROUTER_API_KEY=your-openrouter-api-key
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1/chat/completions
AI_MODEL=anthropic/claude-3.5-sonnet  # or any OpenRouter model

# Meta (Facebook/Instagram)
META_PAGE_ACCESS_TOKEN=your-page-access-token

# Elite Services Config
ELITE_ORG_ID=your-organization-uuid
ELITE_AGENT_ID=your-agent-uuid

# Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
ELITE_ALERT_EMAIL=alerts@eliteservices.london

# Google Sheets
GOOGLE_SHEET_ID=your-sheet-id-from-url
```

### How to Get These Values

**Supabase:**
1. Go to Project Settings → API
2. Copy Project URL (SUPABASE_URL)
3. Copy service_role key (SUPABASE_SERVICE_KEY)
4. Create organization and agent in your database, copy UUIDs

**OpenRouter:**
1. Sign up at https://openrouter.ai
2. Go to API Keys
3. Create new key

**Meta (Facebook/Instagram):**
1. Go to https://developers.facebook.com
2. Create/select your app
3. Add Messenger and Instagram products
4. Generate Page Access Token
5. Subscribe to webhooks

**Slack:**
1. Go to https://api.slack.com/apps
2. Create new app
3. Enable Incoming Webhooks
4. Add webhook to your channel
5. Copy webhook URL

**Google Sheets:**
1. Create a new Google Sheet
2. Name it "Elite Services Leads"
3. Create sheet tab named "Leads"
4. Add headers: Date, Name, Phone, Email, Service Type, Urgency, Lead Score, Is HOT, Channel, Postcode, Service Data
5. Copy sheet ID from URL (between /d/ and /edit)

---

## Step 3: Configure N8N Credentials

### 1. Gmail OAuth2
- Node: Gmail
- Auth Type: OAuth2
- Follow N8N's Gmail OAuth setup guide

### 2. Google Sheets OAuth2
- Node: Google Sheets
- Auth Type: OAuth2
- Follow N8N's Google Sheets OAuth setup guide

---

## Step 4: Import Workflow

1. In N8N, go to **Workflows** → **Import from File**
2. Select `elite-services-main.json`
3. Activate the workflow

---

## Step 5: Configure Meta Webhooks

### Facebook Messenger Setup

1. Go to Meta Developer Console
2. Select your app → Messenger → Settings
3. In Webhooks section, click "Add Callback URL"
4. Enter: `https://your-n8n-domain.com/webhook/facebook`
5. Enter Verify Token (any string you choose)
6. Subscribe to these fields:
   - `messages`
   - `messaging_postbacks`
   - `messaging_optins`

### Instagram Setup

1. In Meta Developer Console → Instagram → Settings
2. Configure webhook callback: `https://your-n8n-domain.com/webhook/instagram`
3. Subscribe to:
   - `messages`
   - `messaging_postbacks`

---

## Step 6: Test the Workflow

### Test 1: Web Chat (Easiest)

```bash
curl -X POST https://your-n8n-domain.com/webhook/web \
  -H "Content-Type: application/json" \
  -d '{
    "sender_id": "test-user-123",
    "message": "I need a quote for office cleaning"
  }'
```

You should receive a JSON response with the assistant's reply.

### Test 2: Check Supabase

After sending a test message:
1. Go to Supabase → Table Editor
2. Check `conversations` table - should have 1 row
3. Check `messages` table - should have 2 rows (user + assistant)

### Test 3: Complete a Conversation

Send messages to simulate a full conversation:
1. "I need office cleaning"
2. Answer service questions
3. Provide contact details
4. Complete flow

Then check:
- `leads` table should have 1 row
- Google Sheet should have 1 row
- If lead_score >= 7, check Slack and email for alerts

---

## How the AI Conversation Works

The OpenRouter AI node receives a system prompt that:

1. **Defines Role**: "Professional receptionist for Elite Services"
2. **Sets Tone Rules**: UK English, friendly, concise, never mention "bot"
3. **Provides Context**: Current step and collected data from flow_state
4. **Expects JSON Output**:
```json
{
  "response_text": "Thanks! What's the postcode?",
  "next_step": "office_cleaning_postcode",
  "collected_data": {"service_type": "office_cleaning"},
  "quick_replies": ["Continue", "Not now"],
  "needs_escalation": false,
  "conversation_complete": false
}
```

The workflow:
- Extracts collected data
- Merges with existing data
- Updates flow_state in Supabase
- Sends response to user

---

## Conversation Flow Steps

| Step | AI Task | Data Collected |
|------|---------|----------------|
| `greeting` | Welcome user, detect intent | Initial service interest |
| `service_selection` | Offer 6 service types | `service_type` |
| `office_cleaning` | Ask 8 questions | business_name, role, postcode, space_type, size, locations, frequency, times |
| `fm_support` | Ask 7 questions | business_name, role, postcode, sites, portfolio_type, current_setup, reason |
| `end_of_tenancy` | Ask 7 questions | postcode, property_type, bathrooms, carpet, oven, parking, date |
| `airbnb` | Ask 6 questions | postcode, property_type, bathrooms, checkouts_per_week, laundry, restocking |
| `deep_clean` | Ask 4 questions | postcode, property_type, focus_areas, special_requirements |
| `contact_capture` | Get name, phone, email | name, phone, email |
| `timing` | Ask urgency | urgency |
| `booking_offer` | Offer call/site visit | booking_preference |
| `confirmation` | Thank you message | - |

---

## Lead Scoring Logic

```javascript
Base score: 5

+2 if urgency = "within_48h"
+1 if urgency = "within_7days"
+2 if office/FM with daily cleaning
+2 if locations >= 4
+1 if size >= 500m²
+2 if Airbnb with 4+ checkouts/week
+1 if 3-bed+ property

Max score: 10
HOT threshold: 7+
```

---

## Human Handover

To hand over a conversation to staff:

1. In Supabase, update the conversation:
```sql
UPDATE conversations
SET status = 'escalated'
WHERE id = 'conversation-uuid';
```

2. The workflow will detect `status = 'escalated'` and:
   - Stop automated responses
   - Show message: "This conversation has been transferred to our team"
   - Wait for manual intervention

To resume automation, set `status = 'open'`.

---

## Monitoring & Logs

### Check Workflow Executions
- N8N → Executions tab
- Filter by workflow name
- View successful/failed runs

### Check Supabase Logs
```sql
-- Recent conversations
SELECT * FROM conversations
ORDER BY created_at DESC
LIMIT 10;

-- Recent leads
SELECT * FROM leads
ORDER BY created_at DESC
LIMIT 10;

-- HOT leads
SELECT * FROM leads
WHERE is_hot = true
ORDER BY lead_score DESC;
```

### Check Google Sheet
- Open your sheet
- Filter by "Is HOT" column
- Sort by "Lead Score" descending

---

## Troubleshooting

### Issue: Webhook not receiving messages

**Check:**
1. Webhook URLs are accessible (test with curl)
2. Meta webhooks are subscribed and verified
3. N8N workflow is activated
4. Firewall allows incoming connections

### Issue: AI not responding naturally

**Check:**
1. OPENROUTER_API_KEY is valid
2. AI_MODEL exists on OpenRouter
3. Check N8N execution logs for AI response
4. Verify system prompt in AI node

### Issue: Leads not saving to Supabase

**Check:**
1. SUPABASE_SERVICE_KEY has full permissions
2. RLS policies allow service role access
3. Check N8N execution errors
4. Verify conversation_complete = true in flow

### Issue: No HOT lead notifications

**Check:**
1. Lead score >= 7
2. SLACK_WEBHOOK_URL is correct
3. Gmail OAuth is connected
4. Check execution logs for notification nodes

---

## Customization

### Change Lead Scoring Rules

Edit the "Calculate Lead Score" Code node:
```javascript
// Add your custom rules
if (data.custom_field === 'high_value') {
  score += 3;
}
```

### Add New Service Type

1. Update AI system prompt with new service type
2. Add new step in conversation flow
3. Update lead scoring logic if needed

### Change AI Model

Set environment variable:
```bash
AI_MODEL=openai/gpt-4-turbo
# or
AI_MODEL=anthropic/claude-3-opus
# or any model from https://openrouter.ai/models
```

### Customize Response Timing

Edit "Typing Delay" node:
```javascript
// Current: 1-3 seconds random
amount: "={{ Math.floor(Math.random() * 2000) + 1000 }}"

// Change to fixed 2 seconds:
amount: 2000
```

---

## Support

For issues with:
- **N8N**: https://docs.n8n.io
- **Supabase**: https://supabase.com/docs
- **OpenRouter**: https://openrouter.ai/docs
- **Meta APIs**: https://developers.facebook.com/docs

---

## Next Steps

1. ✅ Import workflow into N8N
2. ✅ Configure all environment variables
3. ✅ Set up OAuth credentials (Gmail, Sheets)
4. ✅ Deploy Supabase function
5. ✅ Configure Meta webhooks
6. ✅ Test with web chat curl command
7. ✅ Test complete conversation flow
8. ✅ Verify lead appears in Supabase + Sheets
9. ✅ Test HOT lead notification
10. ✅ Go live and monitor!

Good luck! 🚀

# Elite Services - Quick Reference Card

## 🚀 Test the Workflow

### Web Chat Test (Easiest)
```bash
curl -X POST https://your-n8n-domain.com/webhook/web \
  -H "Content-Type: application/json" \
  -d '{
    "sender_id": "test-user-123",
    "message": "I need office cleaning"
  }'
```

### Facebook Messenger Test
Send a message to your Facebook Page from your personal account.

### Instagram Test
Send a DM to your Instagram business account.

---

## 📊 Useful SQL Queries

### View Recent Leads
```sql
SELECT
  name,
  phone,
  email,
  service_type,
  lead_score,
  is_hot,
  urgency,
  created_at
FROM leads
ORDER BY created_at DESC
LIMIT 20;
```

### View HOT Leads
```sql
SELECT
  name,
  phone,
  service_type,
  lead_score,
  urgency,
  created_at
FROM leads
WHERE is_hot = true
ORDER BY lead_score DESC;
```

### View Active Conversations
```sql
SELECT
  id,
  contact_name,
  channel,
  status,
  flow_state->>'current_step' as step,
  updated_at
FROM conversations
WHERE status = 'open'
ORDER BY updated_at DESC;
```

### Get Conversation Transcript
```sql
SELECT get_conversation_transcript('conversation-uuid-here');
```

### Today's Stats
```sql
SELECT
  COUNT(*) as total_leads,
  SUM(CASE WHEN is_hot THEN 1 ELSE 0 END) as hot_leads,
  AVG(lead_score) as avg_score
FROM leads
WHERE created_at >= CURRENT_DATE;
```

### Leads by Service Type
```sql
SELECT
  service_type,
  COUNT(*) as count,
  AVG(lead_score) as avg_score
FROM leads
GROUP BY service_type
ORDER BY count DESC;
```

---

## 🔧 Common N8N Tasks

### Activate Workflow
1. N8N → Workflows
2. Find "Elite Services - Lead Generation Assistant"
3. Toggle switch to **Active**

### View Recent Executions
1. N8N → Executions
2. Filter by workflow name
3. Click execution to see details

### Test Single Node
1. Open workflow
2. Click node you want to test
3. Click "Execute Node"

### View Webhook URLs
1. Open workflow
2. Click webhook node
3. Copy "Test URL" or "Production URL"

---

## 🚨 Troubleshooting Commands

### Check Supabase Connection
```bash
curl -X GET "https://your-project.supabase.co/rest/v1/leads?limit=1" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Test OpenRouter API
```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3.5-sonnet",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### Test Slack Webhook
```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test notification from Elite Services"}'
```

### Verify Meta Webhook
```bash
# Facebook will call this when you set up webhook
# Your N8N webhook should respond with the challenge
curl "https://your-n8n.com/webhook/facebook?hub.mode=subscribe&hub.challenge=test&hub.verify_token=YOUR_TOKEN"
```

---

## 🔄 Common Operations

### Hand Over Conversation to Human
```sql
UPDATE conversations
SET status = 'escalated'
WHERE id = 'conversation-uuid';
```

### Resume Automated Conversation
```sql
UPDATE conversations
SET status = 'open'
WHERE id = 'conversation-uuid';
```

### Close Old Conversations
```sql
UPDATE conversations
SET status = 'closed'
WHERE status = 'open'
  AND updated_at < NOW() - INTERVAL '48 hours';
```

### Mark Lead as Contacted
```sql
UPDATE leads
SET status = 'contacted'
WHERE id = 'lead-uuid';
```

### Re-score All Leads (if you change scoring rules)
```sql
-- This is just an example - actual scoring logic is in N8N
UPDATE leads
SET lead_score =
  CASE
    WHEN urgency = 'within_48h' THEN lead_score + 1
    ELSE lead_score
  END;
```

---

## 📝 Environment Variables Quick Reference

```bash
# Must have
SUPABASE_URL=
SUPABASE_SERVICE_KEY=
OPENROUTER_API_KEY=
META_PAGE_ACCESS_TOKEN=
ELITE_ORG_ID=
ELITE_AGENT_ID=
SLACK_WEBHOOK_URL=
ELITE_ALERT_EMAIL=
GOOGLE_SHEET_ID=

# Optional but recommended
AI_MODEL=anthropic/claude-3.5-sonnet
HOT_LEAD_THRESHOLD=7
ELITE_CONTACT_EMAIL=info@eliteservices.london
ELITE_PRIVACY_POLICY_URL=https://eliteservices.london/privacy
```

---

## 🎯 Lead Scoring Quick Formula

```
Base: 5 points

+2 = Within 48h urgency
+1 = Within 7 days urgency
+2 = Office/FM with daily cleaning
+2 = 4+ locations
+1 = Large space (500m²+)
+2 = Airbnb with 4+ checkouts/week
+1 = 3-bed+ property

Max: 10 points
HOT: ≥ 7 points
```

---

## 📞 Webhook Endpoints

```
Facebook Messenger:
https://your-n8n-domain.com/webhook/facebook

Instagram DM:
https://your-n8n-domain.com/webhook/instagram

Web Chat:
https://your-n8n-domain.com/webhook/web
```

---

## 🔐 Where to Find Credentials

| Credential | Where to Get It |
|------------|----------------|
| Supabase URL | Supabase → Project Settings → API → URL |
| Supabase Service Key | Supabase → Project Settings → API → service_role |
| OpenRouter API Key | https://openrouter.ai/keys |
| Meta Page Token | Meta Developer Console → Your App → Messenger → Settings |
| Slack Webhook | Slack → Apps → Incoming Webhooks |
| Google Sheet ID | Sheet URL between `/d/` and `/edit` |
| Org/Agent UUID | After creating in Supabase, from tables |

---

## 🚨 Error Messages & Fixes

| Error | Fix |
|-------|-----|
| "Supabase connection failed" | Check SUPABASE_URL and SUPABASE_SERVICE_KEY |
| "OpenRouter authentication failed" | Verify OPENROUTER_API_KEY is valid |
| "Conversation not found" | Check ELITE_AGENT_ID matches database |
| "Gmail send failed" | Re-authenticate Gmail OAuth in N8N |
| "Slack webhook error" | Test webhook URL with curl command above |
| "Meta webhook verification failed" | Check META_VERIFY_TOKEN matches |

---

## 📊 Monitoring Dashboard (SQL View)

```sql
-- Create a monitoring view
CREATE OR REPLACE VIEW daily_stats AS
SELECT
  DATE(created_at) as date,
  COUNT(*) as total_leads,
  SUM(CASE WHEN is_hot THEN 1 ELSE 0 END) as hot_leads,
  AVG(lead_score) as avg_score,
  COUNT(DISTINCT service_type) as service_types,
  COUNT(DISTINCT source_channel) as channels_used
FROM leads
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Use it
SELECT * FROM daily_stats LIMIT 7;
```

---

## 🎨 Conversation Flow States

```
greeting
  ↓
service_selection
  ↓
[Service-specific questions]
  • office_cleaning (8 questions)
  • fm_support (7 questions)
  • end_of_tenancy (7 questions)
  • airbnb (6 questions)
  • deep_clean (4 questions)
  ↓
contact_capture (name, phone, email)
  ↓
timing (urgency)
  ↓
booking_offer (optional)
  ↓
confirmation
  ↓
COMPLETE ✓
```

---

## 🔄 Quick Restart Steps

If workflow stops working:

1. **Check N8N**
   - Is workflow activated?
   - Any error executions?
   - Webhook nodes showing correct URLs?

2. **Check Supabase**
   - Database online?
   - Tables exist?
   - Functions deployed?

3. **Check OpenRouter**
   - API key valid?
   - Credits remaining?
   - Model name correct?

4. **Check Meta**
   - Page access token valid?
   - Webhooks subscribed?
   - App not rate-limited?

5. **Restart N8N**
   - Sometimes a simple restart fixes issues
   - Re-import workflow if needed

---

## 📱 Contact Info for Fallback Messages

Update these in `.env`:
```bash
ELITE_CONTACT_EMAIL=info@eliteservices.london
ELITE_CONTACT_PHONE=+44 20 1234 5678
ELITE_PRIVACY_POLICY_URL=https://eliteservices.london/privacy
```

---

## ✅ Pre-Launch Checklist

- [ ] Supabase schema deployed
- [ ] Supabase functions created
- [ ] All environment variables set
- [ ] N8N workflow imported and activated
- [ ] Gmail OAuth connected
- [ ] Google Sheets OAuth connected
- [ ] Slack webhook tested
- [ ] Meta webhooks configured
- [ ] Test conversation completed successfully
- [ ] Test lead appears in Supabase
- [ ] Test lead appears in Google Sheets
- [ ] HOT lead notification received in Slack
- [ ] HOT lead email received

---

**Need more help?** → See [SETUP_GUIDE.md](SETUP_GUIDE.md)

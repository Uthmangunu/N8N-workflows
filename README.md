# N8N Workflows Collection

Two powerful AI-powered automation workflows:

## 1. Elite Services - Lead Generation Assistant
🤖 **Natural AI-powered chatbot** for capturing and qualifying cleaning service leads across Facebook Messenger, Instagram DMs, and web chat.

## 2. Reddit Business Opportunity Finder
🔍 **AI-powered Reddit scanner** that finds business problems you can solve with software and sends them to you via Telegram.

---

## ✨ Elite Services Features

- **Captures leads** from social media with natural AI conversations
- **Scores leads** automatically (1-10) based on urgency, size, and value
- **Alerts your team** instantly via Slack + Email for HOT leads (score 7+)
- **Seamless handover** - Staff can take over by just replying
- **Tracks everything** in Supabase + Google Sheets
- **Books appointments** via Google Calendar
- **Sounds human** - no mention of "bot" or "AI"

## ✨ Reddit Opportunity Finder Features

- **Scans 4 subreddits** (r/Entrepreneur, r/startups, r/SaaS, r/smallbusiness)
- **AI analyzes posts** to find real business problems
- **Sends to Telegram** with problem + solution ideas
- **Scores opportunities** 1-10 based on market size, urgency, feasibility
- **Manual trigger** - you run it whenever you want
- **Google Sheets logging** - track all opportunities found

## 📊 Implementation Status

✅ **50/52 Requirements Covered** (96%)
- All CRITICAL features implemented
- Automatic human handover added
- [RESUME] keyword for AI takeover
- Full conversation tracking

## 🏗️ Architecture

```
Facebook/Instagram/Web
        ↓
    Webhooks → N8N Workflow
        ↓
    OpenRouter AI (Natural Conversation)
        ↓
    Supabase (State + Storage)
        ↓
    Lead Scoring Algorithm
        ↓
    ↙        ↘
Slack/Email  Google Sheets
(HOT Leads)  (All Leads)
```

## 📁 Files in This Repository

### Elite Services Workflow
| File | Purpose |
|------|---------|
| `elite-services-main.json` | **Main N8N workflow** - Import this into N8N |
| `schema.sql` | **Supabase database schema** - Run this in Supabase SQL editor |
| `supabase-functions.sql` | **Helper SQL functions** - Run after schema.sql |
| `SETUP_GUIDE.md` | **Complete setup instructions** - Read this first! |
| `Elite_services.md` | **Original requirements** - Full specification |

### Reddit Opportunity Finder
| File | Purpose |
|------|---------|
| `reddit-opportunity-finder.json` | **Reddit scanner workflow** - Import into N8N |
| `REDDIT_SETUP_GUIDE.md` | **Setup instructions** - Create Telegram bot & configure |
| `TESTING_REDDIT_WORKFLOW.md` | **Testing guide** - 2-week testing plan |

### Shared Files
| File | Purpose |
|------|---------|
| `.env.example` | **Environment variables template** - Configure for both workflows |
| `README.md` | **This file** - Project overview |

## 🚀 Quick Start

### 1. Prerequisites

- [ ] N8N instance (self-hosted or cloud)
- [ ] Supabase account (free tier is fine)
- [ ] OpenRouter API key
- [ ] Meta Developer account (for Facebook/Instagram)
- [ ] Google account (for Sheets + Gmail)
- [ ] Slack workspace

### 2. Setup (30 minutes)

```bash
# 1. Clone/download this repository
# 2. Copy environment variables template
cp .env.example .env

# 3. Fill in your credentials in .env
nano .env

# 4. Deploy Supabase schema
# → Open Supabase SQL Editor
# → Run schema.sql
# → Run supabase-functions.sql

# 5. Import N8N workflow
# → N8N → Workflows → Import from File
# → Select elite-services-main.json
# → Configure credentials

# 6. Configure webhooks
# → Meta Developer Console
# → Add webhook URLs from N8N
```

**Full step-by-step guide:** See [SETUP_GUIDE.md](SETUP_GUIDE.md)

## 🎨 Service Types Supported

1. **Office/Commercial Cleaning** (8 questions)
2. **Facilities Management Support** (7 questions)
3. **End-of-Tenancy Clean** (7 questions)
4. **Airbnb/Short-Let Turnover** (6 questions)
5. **Deep Clean (One-off)** (4 questions)

Each service type has a customized question flow to collect accurate quote information.

## 🔥 Lead Scoring

Leads are automatically scored 1-10 based on:

| Factor | Points |
|--------|--------|
| Within 48 hours urgency | +2 |
| Within 7 days urgency | +1 |
| Office/FM with daily cleaning | +2 |
| Multiple locations (4+) | +2 |
| Large space (500m²+) | +1 |
| Airbnb 4+ checkouts/week | +2 |
| 3-bed+ property | +1 |

**HOT Lead** = Score ≥ 7 → Instant Slack + Email alert

## 💬 Example Conversation

```
User: I need a quote for office cleaning

AI: Hi! Thanks for reaching out to Elite Services.
    I'll help you get a quote - just a few quick questions!

    What's the postcode of your office?

User: EC1A 1BB

AI: Perfect! And what type of space is it?
    [Office] [Co-working] [Medical] [Education] [Retail]

User: Office

AI: Great. Roughly how large is the space?
    [Up to 200m²] [200-500m²] [500-1000m²] [1000m²+]

User: 200-500m²

AI: Thanks! How often would you need cleaning?
    [Daily] [Several times/week] [Weekly] [Ad-hoc]

User: Daily

... (conversation continues through all questions)

AI: Thank you! That's everything we need. Someone from
    the Elite Services team will review this and get back
    to you within 1 business hour with a quote.

[Lead Score: 8/10 - HOT! 🔥]
[Slack + Email alerts sent]
[Saved to Supabase + Google Sheets]
```

## 🧠 AI Capabilities

The OpenRouter AI handles:

- **Intent detection** - Understands "I need cleaning" vs "What are your prices?"
- **Natural extraction** - Gets info from free-form text
- **Smart validation** - Catches invalid postcodes, missing info
- **Graceful fallbacks** - Handles off-topic questions
- **Human escalation** - Knows when to hand over to staff

## 📊 Data Flow

### Incoming Message
1. Webhook receives message from FB/IG/Web
2. Normalize to standard format
3. Get/create conversation in Supabase
4. Check if conversation is handed over to human

### AI Processing
5. Load conversation state (current step, collected data)
6. Send to OpenRouter AI with context
7. AI returns: response text, next step, extracted data

### Response
8. Simulate typing delay (1-3 seconds)
9. Update conversation state in Supabase
10. Save messages to database
11. Send response back to user

### Lead Completion
12. Calculate lead score
13. Create lead record in Supabase
14. If HOT (score ≥ 7): Send Slack + Email alerts
15. Log to Google Sheets

## 🔧 Configuration

All settings are in environment variables (see `.env.example`):

```bash
# Change AI model
AI_MODEL=anthropic/claude-3-haiku  # Faster, cheaper
# or
AI_MODEL=openai/gpt-4-turbo        # Alternative

# Change HOT lead threshold
HOT_LEAD_THRESHOLD=8  # Only score 8+ gets alerts

# Change typing delay
MIN_TYPING_DELAY_MS=500   # Faster responses
MAX_TYPING_DELAY_MS=1500
```

## 🐛 Troubleshooting

### Webhooks not working
- Check N8N workflow is activated
- Verify webhook URLs in Meta Developer Console
- Test with curl: `curl -X POST https://your-n8n.com/webhook/web`

### AI not responding
- Check OpenRouter API key is valid
- Verify model name exists on OpenRouter
- Check N8N execution logs for errors

### Leads not saving
- Verify Supabase credentials
- Check service_role key has full permissions
- Ensure schema.sql was deployed

### No HOT lead alerts
- Confirm lead score ≥ 7
- Check Slack webhook URL is correct
- Verify Gmail OAuth is connected

**Full troubleshooting guide:** See [SETUP_GUIDE.md](SETUP_GUIDE.md#troubleshooting)

## 📈 Monitoring

### Check Recent Leads (Supabase)
```sql
SELECT * FROM leads
ORDER BY created_at DESC
LIMIT 10;
```

### Check HOT Leads
```sql
SELECT * FROM leads
WHERE is_hot = true
ORDER BY lead_score DESC;
```

### View Conversation History
```sql
SELECT
  c.id,
  c.contact_name,
  c.status,
  COUNT(m.id) as messages
FROM conversations c
LEFT JOIN messages m ON m.conversation_id = c.id
GROUP BY c.id
ORDER BY c.updated_at DESC;
```

### N8N Executions
- N8N Dashboard → Executions
- Filter by workflow name
- Check for errors or failures

## 🔐 Security

- ✅ All credentials via environment variables
- ✅ Supabase RLS (Row Level Security) enabled
- ✅ Service role key for backend operations
- ✅ GDPR-compliant data handling
- ✅ Privacy notice before collecting contact info

## 🚧 Roadmap / Future Enhancements

- [ ] WhatsApp integration
- [ ] Comment-based triggers (FB/IG posts)
- [ ] Multi-language support
- [ ] Voice call handling (via Bland.ai or similar)
- [ ] Advanced analytics dashboard
- [ ] A/B testing conversation flows
- [ ] CRM integrations (HubSpot, Salesforce)

## 📝 Customization

### Add a New Service Type

1. Update AI system prompt in "AI Conversation Processor" node
2. Add service type to quick replies
3. Define questions for the new service
4. Update lead scoring logic if needed

### Change Conversation Flow

Edit the AI system prompt in the workflow:
```javascript
// In "AI Conversation Processor" node
// Update CONVERSATION FLOW STATE section
```

### Modify Lead Scoring

Edit "Calculate Lead Score" Code node:
```javascript
// Add custom scoring rules
if (data.custom_field === 'high_value') {
  score += 3;
}
```

## 🤝 Support & Documentation

- **N8N Docs:** https://docs.n8n.io
- **Supabase Docs:** https://supabase.com/docs
- **OpenRouter Docs:** https://openrouter.ai/docs
- **Meta API Docs:** https://developers.facebook.com/docs

## 📄 License

This project is proprietary and confidential for Elite Services.

## 👥 Credits

Built with:
- **N8N** - Workflow automation
- **Supabase** - Database & real-time
- **OpenRouter** - AI model routing
- **Meta API** - Facebook & Instagram
- **Google APIs** - Sheets, Gmail, Calendar
- **Slack API** - Team notifications

---

**Ready to deploy?** → Read [SETUP_GUIDE.md](SETUP_GUIDE.md)

**Questions?** → Check [Elite_services.md](Elite_services.md) for full requirements

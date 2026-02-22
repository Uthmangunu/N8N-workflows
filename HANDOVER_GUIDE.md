# Human Handover Guide - Seamless AI ↔ Staff Transition

## 🔄 How Handovers Work

This workflow features **automatic handover detection** - staff can take over conversations simply by replying, and the AI automatically pauses.

---

## 🎯 Taking Over a Conversation (AI → Staff)

### Method 1: Just Reply (Automatic - RECOMMENDED)

**Staff member:**
1. Sees conversation in Facebook Page Messenger or Instagram DM
2. Simply replies to the customer from the business account
3. **AI automatically detects this** and pauses

**What happens behind the scenes:**
- Workflow detects the sender ID matches the page/business ID
- Conversation status changes to `escalated` in database
- Staff message is saved to conversation history
- AI stops sending automated responses
- All future customer messages go to staff (not AI)

**No manual action needed!**

---

### Method 2: Manual (Backup)

If automatic detection isn't working, manually escalate in Supabase:

```sql
UPDATE conversations
SET status = 'escalated'
WHERE id = 'conversation-uuid';
```

---

## 🤖 Handing Back to AI (Staff → AI)

### Option 1: [RESUME] Keyword (Quick)

**Staff member** sends this message in the conversation:
```
[RESUME]
```

**What happens:**
- AI detects the keyword
- Status changes back to `open`
- Next customer message triggers AI response
- Staff gets confirmation: "AI automation resumed"

**Alternative keywords:** `[AUTO]` or `[AI]`

---

### Option 2: Manual Resume

In Supabase:
```sql
UPDATE conversations
SET status = 'open'
WHERE id = 'conversation-uuid';
```

---

## 🔍 How Detection Works

### Facebook Messenger

**Customer message:**
```json
{
  "sender": {"id": "user-123456"},      ← Customer ID
  "recipient": {"id": "page-789012"}    ← Your page ID
}
```

**Staff reply:**
```json
{
  "sender": {"id": "page-789012"},      ← Your page ID (MATCH!)
  "recipient": {"id": "user-123456"}    ← Customer ID
}
```

When `sender.id === META_PAGE_ID`, it's a staff reply → Auto-pause AI

---

### Instagram

Same logic:
- Customer: `sender.id` = their Instagram ID
- Staff: `sender.id` = `META_INSTAGRAM_ID`

**CRITICAL:** You MUST set these environment variables:
```bash
META_PAGE_ID=your-facebook-page-id
META_INSTAGRAM_ID=your-instagram-business-id
```

Without these, handover detection won't work!

---

## 📊 Conversation States

| Status | What It Means | Who Responds |
|--------|---------------|--------------|
| `open` | Normal AI mode | AI Assistant |
| `escalated` | Staff handling | Human Staff |
| `closed` | Conversation ended | Nobody (archived) |

---

## 💬 Example Flow

### Scenario: Staff Takes Over

```
Customer: "I need office cleaning"
AI: "Great! What's your postcode?"
Customer: "EC1A 1BB"
AI: "Perfect! And what type of space is it?"

[Staff notices conversation in Messenger inbox]

Staff: "Hi there! I can help you personally with this"
→ AI DETECTS: Message from page ID
→ Status → 'escalated'
→ AI PAUSED

Customer: "Thanks! When can you come?"
→ Goes to staff, NOT AI

Staff: "We can come tomorrow at 2pm"
Customer: "Perfect!"
→ Conversation continues with staff

[Later, staff wants to hand back]

Staff: "[RESUME]"
→ Status → 'open'
→ AI ACTIVE again

Customer: "Actually, can I change the time?"
AI: "Of course! What time works better for you?"
```

---

## ⚙️ Setup Requirements

### 1. Get Your Page/Business IDs

**Facebook Page ID:**
1. Go to your Facebook Page
2. Click "About"
3. Scroll to "Page ID"
4. Copy the number

Or use Graph API:
```bash
curl "https://graph.facebook.com/v18.0/me?access_token=YOUR_TOKEN"
```

**Instagram Business ID:**
1. Go to Instagram Settings
2. Click Account
3. Look in the URL: `instagram.com/accounts/edit/?id=INSTAGRAM_ID`

Or use Graph API:
```bash
curl "https://graph.facebook.com/v18.0/me/accounts?access_token=YOUR_TOKEN"
```

### 2. Add to N8N Environment Variables

```bash
META_PAGE_ID=123456789012345
META_INSTAGRAM_ID=987654321098765
```

### 3. Test It Works

1. Start a conversation with the bot
2. Reply from your Facebook Page/Instagram Business account
3. Check Supabase: `status` should change to `'escalated'`
4. Send another customer message → should NOT trigger AI
5. Send `[RESUME]` from staff account
6. Status changes back to `'open'`
7. Next customer message triggers AI again

---

## 🐛 Troubleshooting

### Handover Detection Not Working

**Problem:** Staff replies but AI still responds

**Check:**
1. Are `META_PAGE_ID` and `META_INSTAGRAM_ID` set correctly?
   ```bash
   # In N8N, check environment variables
   echo $META_PAGE_ID
   ```

2. Is the staff replying from the correct account?
   - Must reply from the Facebook Page account (not personal profile)
   - Must reply from Instagram Business account

3. Check webhook payload:
   - Look at N8N execution logs
   - Find the `sender.id` in the incoming message
   - Does it match your `META_PAGE_ID`?

**Debug query:**
```sql
-- Check recent conversations and their status
SELECT
  id,
  status,
  channel,
  updated_at
FROM conversations
ORDER BY updated_at DESC
LIMIT 10;
```

---

### [RESUME] Not Working

**Problem:** Staff sends [RESUME] but AI doesn't take back over

**Check:**
1. Is `is_staff_reply` being detected?
   - Check N8N execution for "Check Resume Keyword" node
   - Should show `should_resume: true`

2. Is conversation actually escalated?
   ```sql
   SELECT status FROM conversations WHERE id = 'conv-uuid';
   ```
   Must be `'escalated'` for resume to work

3. Did status change after [RESUME]?
   ```sql
   SELECT status FROM conversations WHERE id = 'conv-uuid';
   ```
   Should now be `'open'`

---

### Web Chat Handover

For web chat, handover is slightly different:

**To escalate:**
- Include `is_staff: true` in the message payload from your web app

**To resume:**
- Same [RESUME] keyword works

Example web chat staff message:
```json
{
  "sender_id": "session-123",
  "message": "Hi, I can help you with that",
  "is_staff": true
}
```

---

## 📈 Monitoring Handovers

### View Active Handovers

```sql
SELECT
  c.id,
  c.contact_name,
  c.channel,
  c.updated_at,
  COUNT(m.id) as message_count
FROM conversations c
LEFT JOIN messages m ON m.conversation_id = c.id
WHERE c.status = 'escalated'
GROUP BY c.id
ORDER BY c.updated_at DESC;
```

### View Handover History

```sql
-- Conversations that were escalated at some point
SELECT
  id,
  contact_name,
  channel,
  status,
  created_at,
  updated_at
FROM conversations
WHERE status = 'escalated' OR status = 'closed'
ORDER BY updated_at DESC
LIMIT 50;
```

### Count Handovers per Day

```sql
SELECT
  DATE(updated_at) as date,
  COUNT(*) as escalated_conversations
FROM conversations
WHERE status = 'escalated'
GROUP BY DATE(updated_at)
ORDER BY date DESC;
```

---

## 🎓 Staff Training

### For Customer Service Team

**When to take over:**
- Customer is angry or frustrated
- Complex question AI can't handle
- Complaint or refund request
- Technical issue with booking
- VIP customer

**How to take over:**
1. Open conversation in Facebook/Instagram Messenger
2. Just reply normally from the business account
3. AI automatically stops
4. Continue conversation as normal

**When to hand back to AI:**
- Simple follow-up questions
- Standard quote request
- Booking confirmation
- After resolving the issue

**How to hand back:**
- Type `[RESUME]` in the conversation
- AI takes over on next customer message

**Tips:**
- Check conversation history before replying
- All messages are saved in Supabase
- Be aware customer doesn't know they switched from AI to human

---

## 🔒 Security

**Important:** Handover detection relies on sender ID matching

**Security measures:**
- Only messages from YOUR page/business ID trigger handover
- Can't be spoofed (Meta validates sender ID)
- Staff must have page admin access to reply
- All handovers are logged in database

---

## 📝 Best Practices

### Do:
✅ Reply from the business account when you want to take over
✅ Use [RESUME] when handing back to AI
✅ Monitor escalated conversations daily
✅ Train staff on when to take over vs let AI handle it

### Don't:
❌ Reply from personal Facebook/Instagram account (won't detect)
❌ Manually change status without using [RESUME]
❌ Take over unnecessarily (AI handles most queries well)
❌ Forget to hand back to AI after resolving the issue

---

## 📞 Support

**Having issues with handover detection?**

1. Check setup guide above
2. Verify environment variables are set
3. Test with curl command (see troubleshooting)
4. Check N8N execution logs
5. Review conversation status in Supabase

---

**Seamless handovers make your team more efficient while maintaining great customer experience! 🎯**

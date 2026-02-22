# Testing the Reddit Opportunity Finder

Quick testing guide for your 2-week preparation period.

## Testing Timeline

### Days 1-3: Basic Setup
- [ ] Install N8N locally (if not already)
- [ ] Create Telegram bot (5 min)
- [ ] Get Telegram chat ID (2 min)
- [ ] Import workflow
- [ ] Add environment variables

### Days 4-7: First Tests
- [ ] Trigger workflow manually
- [ ] Verify Telegram messages arrive
- [ ] Check message formatting
- [ ] Test with 1 subreddit first

### Days 8-14: Refinement
- [ ] Test all 4 subreddits
- [ ] Adjust keyword filters
- [ ] Fine-tune AI scoring
- [ ] Set up Google Sheets (optional)
- [ ] Document any customizations

## Quick Test Methods

### Method 1: Local N8N (Recommended for Testing)

**Install N8N locally:**
```bash
npm install n8n -g
n8n start
```

**Open browser:**
```
http://localhost:5678
```

**Import workflow:**
1. Workflows → Import from File
2. Select `reddit-opportunity-finder.json`
3. Activate workflow

**Trigger test:**
```bash
curl -X POST http://localhost:5678/webhook/reddit-opportunities
```

### Method 2: N8N Cloud (14-day trial)

**Sign up:**
```
https://n8n.io/cloud
```

**Import workflow:**
1. Upload `reddit-opportunity-finder.json`
2. Configure credentials
3. Activate

**Trigger test:**
Use the webhook URL from the workflow (looks like `https://yourinstance.app.n8n.cloud/webhook/reddit-opportunities`)

### Method 3: Test Individual Components

**Test Reddit API (no auth needed):**
```bash
curl -H "User-Agent: business-opportunity-bot/1.0" \
  "https://www.reddit.com/r/Entrepreneur/new.json?limit=5"
```

Expected: JSON with recent posts

**Test Telegram bot:**
```bash
curl -X POST "https://api.telegram.org/bot<YOUR_TOKEN>/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "<YOUR_CHAT_ID>",
    "text": "Test message from Reddit workflow!"
  }'
```

Expected: Message appears in your Telegram chat

**Test OpenRouter AI:**
```bash
curl -X POST "https://openrouter.ai/api/v1/chat/completions" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3.5-sonnet",
    "messages": [
      {"role": "user", "content": "Say hello"}
    ]
  }'
```

Expected: AI response in JSON

## What to Test

### ✅ Core Functionality
- [ ] Workflow triggers without errors
- [ ] Reddit API returns posts
- [ ] Posts get filtered correctly
- [ ] AI analyzes posts
- [ ] Telegram messages sent
- [ ] Messages are well-formatted

### ✅ Quality Checks
- [ ] No spam/irrelevant posts
- [ ] AI scoring makes sense (8-10 for great opps)
- [ ] Solution ideas are actionable
- [ ] Only 5-15 results per scan (not 100)

### ✅ Error Handling
- [ ] Works if Reddit is slow
- [ ] Works if no good posts found
- [ ] Works if AI fails (fallback behavior)
- [ ] Completes within 60 seconds

## Expected Results

### Good Test Run

You should receive **5-10 Telegram messages** like this:

```
🔥 HIGH PRIORITY (Score: 9/10)

📋 Problem: "Can't track which customers actually use new features"

👥 Who: SaaS founders and product managers

💡 Solution: Build analytics tool that connects Stripe and product usage, showing revenue per feature adoption.

🤔 Why this score: Large market, clear urgency, willing to pay

From: r/SaaS
👍 45 upvotes | 💬 18 comments
🔗 https://reddit.com/r/saas/comments/xyz123

━━━━━━━━━━━━━━━━━━━━
```

Plus a summary message:
```
✅ Reddit Opportunity Scan Complete

📊 Results:
- Posts analyzed: 8
- Opportunities found and sent above

Next steps:
1. Review opportunities in Telegram
2. Click Reddit links to read full discussions
3. Update Google Sheet status when pursuing

Run again anytime by triggering the webhook!
```

### Bad Signs (Need Fixing)

❌ **No messages:** Check Telegram credentials
❌ **Too many messages (50+):** Filters too loose
❌ **Irrelevant posts:** Adjust keywords
❌ **All low scores (1-3):** AI prompt too harsh
❌ **Errors in N8N:** Check API keys and environment variables

## Debugging Tips

### Enable N8N Debug Logs

Add to `.env`:
```bash
N8N_LOG_LEVEL=debug
```

Restart N8N and check console for detailed logs.

### Test Nodes Individually

In N8N editor:
1. Click on a node (e.g., "Fetch r/Entrepreneur")
2. Click "Execute Node" button
3. Check output in right panel
4. Verify data looks correct

### Check Execution History

N8N Dashboard → Executions:
- See all past runs
- Click to see detailed flow
- Red nodes = errors
- Green = success

## Common Issues & Fixes

### "Reddit API 429 Error"
**Problem:** Too many requests
**Fix:** Wait 1 minute, try again

### "Telegram 401 Unauthorized"
**Problem:** Wrong bot token
**Fix:** Double-check token from BotFather, no extra spaces

### "No opportunities found"
**Normal scenarios:**
- Quiet time on Reddit
- No recent posts with problem keywords
- All posts scored below 5

**Try:**
- Test during US business hours (higher activity)
- Lower minimum score from 5 to 3 temporarily
- Add more subreddits

### "AI analysis failed"
**Problem:** OpenRouter API issue
**Fix:**
1. Check API key is valid
2. Check balance: https://openrouter.ai/credits
3. Verify model name is exact: `anthropic/claude-3.5-sonnet`

### "Workflow takes > 2 minutes"
**Problem:** Too many posts to analyze
**Fix:** In "Filter & Score Posts" node, change:
```javascript
const topPosts = allPosts.slice(0, 10); // Reduce from 10 to 5
```

## Performance Benchmarks

**Normal execution:**
- Duration: 30-60 seconds
- Reddit API calls: 4 (one per subreddit)
- AI calls: 5-10 (one per filtered post)
- Telegram messages: 5-10 opportunities + 1 summary
- Cost: ~$0.03 per run

**If slower than this:**
- Check internet connection
- Check API response times in execution log
- Consider running fewer subreddits simultaneously

## Test Scenarios

### Scenario 1: Quiet Day
**Setup:** Run during off-hours (2-6 AM EST)
**Expected:** 0-2 opportunities found
**Result:** "No opportunities found" is normal

### Scenario 2: Peak Time
**Setup:** Run during US business hours (9 AM - 5 PM EST)
**Expected:** 8-12 opportunities found
**Result:** Should get mix of high/medium priority

### Scenario 3: Specific Niche
**Setup:** Change to niche subreddit (r/freelance only)
**Expected:** 2-5 very targeted opportunities
**Result:** Higher quality, lower quantity

## Pre-Meeting Checklist

Two weeks from now, you should be able to:

- [ ] Trigger workflow on demand
- [ ] Receive Telegram messages within 60 seconds
- [ ] Explain what the workflow does
- [ ] Show 3-5 real opportunities you found
- [ ] Demonstrate how you'd validate one
- [ ] Know your API costs (~$0.03/scan)
- [ ] Have Google Sheet with logged results (optional)

## Next Steps After Testing

1. **Document what worked:**
   - Which subreddits gave best results
   - What time of day is most productive
   - Any keyword adjustments made

2. **Prepare examples:**
   - Screenshot 2-3 best opportunities found
   - Note which ones you'd actually pursue
   - Prepare to explain why

3. **Consider automation:**
   - Schedule to run 2x daily?
   - Set up mobile notifications?
   - Integrate with project management tool?

## Support Resources

- **N8N Community:** https://community.n8n.io
- **Reddit API Docs:** https://www.reddit.com/dev/api
- **Telegram Bot Guide:** https://core.telegram.org/bots
- **OpenRouter Models:** https://openrouter.ai/models

## Quick Reference Commands

**Start N8N:**
```bash
n8n start
```

**Trigger workflow:**
```bash
curl -X POST http://localhost:5678/webhook/reddit-opportunities
```

**Check Telegram bot:**
```bash
curl https://api.telegram.org/bot<TOKEN>/getMe
```

**View Reddit posts manually:**
```
https://reddit.com/r/Entrepreneur/new
```

Good luck with your testing! 🚀

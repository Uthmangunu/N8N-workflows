# Reddit Opportunity Finder - Setup Guide

Quick guide to get your Reddit business opportunity scanner running in 15 minutes.

## Prerequisites

- N8N installed (local or cloud)
- OpenRouter API key (you already have this)
- Telegram account

## Step 1: Create Telegram Bot (5 minutes)

### Get Bot Token

1. Open Telegram and search for `@BotFather`
2. Start a chat and send `/newbot`
3. Follow prompts:
   - Bot name: `My Opportunity Scanner` (or any name)
   - Username: `my_opp_scanner_bot` (must end in `_bot`)
4. BotFather will give you a token like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
5. **Save this token** - you'll need it for `.env`

### Get Your Chat ID

1. Start a chat with your new bot (click the link BotFather gave you)
2. Send any message to your bot (e.g., "Hello")
3. Open this URL in your browser (replace `YOUR_BOT_TOKEN`):
   ```
   https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
   ```
4. Look for `"chat":{"id":123456789` - that number is your chat ID
5. **Save this chat ID** - you'll need it for `.env`

**Example:**
```json
{
  "update_id": 123456789,
  "message": {
    "chat": {
      "id": 987654321,  ← This is your TELEGRAM_CHAT_ID
      "first_name": "John",
      "type": "private"
    }
  }
}
```

## Step 2: Set Up Environment Variables

Add these to your `.env` file:

```bash
# Reddit API
REDDIT_USER_AGENT=business-opportunity-bot/1.0

# Telegram Bot
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=987654321

# AI (already configured)
OPENROUTER_API_KEY=your-existing-key
OPENROUTER_MODEL=anthropic/claude-3.5-sonnet

# Google Sheets (optional - for logging opportunities)
GOOGLE_SHEET_ID_OPPORTUNITIES=your-google-sheet-id
```

## Step 3: Import Workflow to N8N

### Option A: N8N Desktop/Self-Hosted

1. Open N8N in your browser (usually `http://localhost:5678`)
2. Click **Workflows** → **Import from File**
3. Select `reddit-opportunity-finder.json`
4. Click **Import**
5. The workflow will appear in your workflows list

### Option B: N8N Cloud

1. Log into your N8N Cloud account
2. Click **Add Workflow** → **Import**
3. Upload `reddit-opportunity-finder.json`
4. Activate the workflow

## Step 4: Configure Credentials (Optional)

### Google Sheets (if you want logging)

1. Create a new Google Sheet named "Reddit Opportunities"
2. Add headers: `Timestamp | Subreddit | Score | Priority | Problem | Solution | Target | Upvotes | Comments | URL | Status`
3. In N8N:
   - Click **Credentials** → **Add Credential**
   - Select **Google Sheets OAuth2**
   - Follow OAuth flow to connect your Google account
4. Copy the Sheet ID from the URL:
   ```
   https://docs.google.com/spreadsheets/d/SHEET_ID_HERE/edit
   ```
5. Add to `.env` as `GOOGLE_SHEET_ID_OPPORTUNITIES`

## Step 5: Test the Workflow

### Get Your Webhook URL

1. Open the workflow in N8N
2. Click on the **Manual Trigger** node
3. Copy the **Production URL** (looks like):
   ```
   https://your-n8n-url.com/webhook/reddit-opportunities
   ```

### Trigger a Test Scan

**Option 1: cURL (from terminal)**
```bash
curl -X POST https://your-n8n-url.com/webhook/reddit-opportunities
```

**Option 2: Browser**
Just paste the webhook URL in your browser and press Enter.

**Option 3: Postman/Insomnia**
Make a POST request to the webhook URL.

### What to Expect

Within 30-60 seconds, you should receive Telegram messages like:

```
🔥 HIGH PRIORITY (Score: 9/10)

📋 Problem: "SaaS founders can't track feature usage across tools"

👥 Who: SaaS company founders and product managers

💡 Solution: Build a unified analytics dashboard that connects Stripe, Intercom, and GA4, showing feature usage correlated with revenue per customer.

🤔 Why this score: Large market, clear pain point, urgent need

From: r/SaaS
👍 47 upvotes | 💬 23 comments
🔗 https://reddit.com/r/saas/xyz123
```

## Step 6: Customize (Optional)

### Add More Subreddits

Edit the workflow and duplicate the "Fetch" nodes:

1. Right-click a Fetch node → **Duplicate**
2. Change URL to new subreddit: `https://www.reddit.com/r/YourSubreddit/new.json`
3. Connect to the **Merge** node
4. Update merge node to accept the new input

**Popular subreddits to add:**
- r/productivity
- r/freelance
- r/webdev
- r/marketing
- r/ecommerce

### Adjust Keyword Filters

In the **Filter & Score Posts** node, edit the `problemKeywords` array:

```javascript
const problemKeywords = [
  'frustrated', 'problem', 'issue', 'need',
  // Add your own keywords:
  'inefficient', 'waste time', 'manual process'
];
```

### Change Minimum Score

In the **Parse & Format** node, change this line:

```javascript
if (!analysis.is_opportunity || analysis.opportunity_score < 5) {
```

Change `< 5` to `< 7` for higher quality (fewer results) or `< 3` for more results.

## Troubleshooting

### No Telegram messages received

1. **Check bot token:**
   ```bash
   curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe
   ```
   Should return bot info. If error, token is wrong.

2. **Check chat ID:**
   - Make sure you started a chat with your bot first
   - Verify the chat ID is a number, not a string

3. **Check N8N logs:**
   - Look for errors in the workflow execution
   - Check if "Send to Telegram" node failed

### Reddit API errors

**Error: 429 Too Many Requests**
- Reddit rate limit hit (60 requests/min)
- Wait a minute and try again
- Reduce number of subreddits

**Error: 403 Forbidden**
- Missing User-Agent header
- Check `REDDIT_USER_AGENT` in `.env`

### No opportunities found

This is normal if:
- No recent posts match the keywords
- All posts scored below 5/10
- Try different subreddits or adjust keyword filters

### AI analysis failed

**Check OpenRouter:**
```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

If this works, your key is valid. Check model name in `.env`.

## Advanced: Schedule Automatic Scans

To run every 6 hours instead of manual trigger:

1. Replace **Manual Trigger** node with **Schedule Trigger**
2. Set cron: `0 */6 * * *` (every 6 hours)
3. Save and activate

**Recommended cron schedules:**
- `0 */1 * * *` - Every hour
- `0 */6 * * *` - Every 6 hours
- `0 9 * * *` - Daily at 9 AM
- `0 9,17 * * *` - Twice daily (9 AM and 5 PM)

## Usage Tips

### Best Times to Scan

- **Morning (9-10 AM):** Catch overnight US posts
- **Evening (5-6 PM):** End of workday, people post problems
- **Sunday:** High engagement, people plan for the week

### Refining Results

After first few runs:
1. Check Google Sheets for patterns
2. Adjust keywords based on what's working
3. Tweak AI scoring prompt if too harsh/lenient
4. Add/remove subreddits based on quality

### Taking Action

When you find a good opportunity:
1. Click the Reddit link to read full discussion
2. Reply to the thread with follow-up questions
3. Update Google Sheet status to "Researching" or "Building"
4. Validate the problem before building

## Reddit API Limits

- **No authentication:** 60 requests per minute
- **With authentication:** 600 requests per 10 minutes (not implemented)
- This workflow uses ~4 requests per scan (well within limits)

## Cost Estimate

**OpenRouter (AI analysis):**
- ~10 posts analyzed per scan
- Claude 3.5 Sonnet: ~$0.003 per post
- **Cost per scan:** ~$0.03
- **Monthly (4 scans/day):** ~$3.60

**N8N:**
- Self-hosted: Free
- N8N Cloud: $20/month (includes 5k workflow executions)

**Total:** $3-24/month depending on hosting choice

## Next Steps

1. ✅ Create Telegram bot
2. ✅ Configure environment variables
3. ✅ Import workflow to N8N
4. ✅ Test with webhook trigger
5. ⬜ Review first results
6. ⬜ Customize keywords/subreddits
7. ⬜ Set up automatic scheduling (optional)
8. ⬜ Start validating opportunities!

## Support

- N8N Docs: https://docs.n8n.io
- OpenRouter Docs: https://openrouter.ai/docs
- Reddit API: https://www.reddit.com/dev/api
- Telegram Bot API: https://core.telegram.org/bots/api

Happy opportunity hunting! 🚀

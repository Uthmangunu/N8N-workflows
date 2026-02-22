# Repository Structure

## 📁 Current File Organization

```
N8N-workflows/
│
├── 📄 README.md                          # Project overview & quick start
├── 📄 Elite_services.md                  # Original requirements spec
│
├── 🔧 WORKFLOW FILES
│   ├── elite-services-main.json          # Main N8N workflow (IMPORT THIS)
│   ├── schema.sql                        # Supabase database schema
│   └── supabase-functions.sql            # Helper SQL functions
│
├── 📚 SETUP DOCUMENTATION
│   ├── SETUP_GUIDE.md                    # Complete setup instructions
│   ├── BUSINESS_HANDOFF_GUIDE.md         # Guide for business owners
│   ├── QUICK_REFERENCE.md                # Commands & SQL queries
│   └── .env.example                      # Environment variables template
│
├── 📖 FEATURE GUIDES
│   ├── HANDOVER_GUIDE.md                 # Human handover system
│   └── PROJECT_SUMMARY.md                # Technical architecture
│
└── 📋 PLANNING
    └── .claude/plans/                    # Development planning docs
```

---

## 🎯 Which File Do I Need?

### For First-Time Setup
1. **BUSINESS_HANDOFF_GUIDE.md** - If you're a business owner
2. **SETUP_GUIDE.md** - If you're doing technical setup
3. **elite-services-main.json** - Import this into N8N
4. **schema.sql** + **supabase-functions.sql** - Run in Supabase
5. **.env.example** - Copy to `.env` and fill in your values

### For Daily Use
- **QUICK_REFERENCE.md** - SQL queries, test commands
- **HANDOVER_GUIDE.md** - How to take over conversations
- **README.md** - Quick links to everything

### For Understanding the System
- **PROJECT_SUMMARY.md** - Full technical architecture
- **Elite_services.md** - Original business requirements

---

## 📦 Optional: Organize Into Folders

If you want to restructure the repository, here's the recommended layout:

```
N8N-workflows/
│
├── README.md
├── Elite_services.md
│
├── workflows/
│   ├── elite-services-main.json
│   └── README.md                   (workflow-specific notes)
│
├── database/
│   ├── schema.sql
│   ├── supabase-functions.sql
│   └── README.md                   (database setup notes)
│
├── docs/
│   ├── setup/
│   │   ├── SETUP_GUIDE.md
│   │   ├── BUSINESS_HANDOFF_GUIDE.md
│   │   └── .env.example
│   │
│   ├── features/
│   │   ├── HANDOVER_GUIDE.md
│   │   └── LEAD_SCORING.md
│   │
│   ├── reference/
│   │   ├── QUICK_REFERENCE.md
│   │   └── API_ENDPOINTS.md
│   │
│   └── architecture/
│       └── PROJECT_SUMMARY.md
│
└── .claude/
    └── plans/
```

---

## 🚀 Deployment Checklist Files

Use these files in this order for deployment:

### Phase 1: Understanding (5 min)
- [ ] Read **README.md** - Overview
- [ ] Read **BUSINESS_HANDOFF_GUIDE.md** - What you're getting

### Phase 2: Accounts (15 min)
- [ ] Follow **SETUP_GUIDE.md** Step 1 - Create accounts
- [ ] Copy **.env.example** → `.env`

### Phase 3: Database (5 min)
- [ ] Run **schema.sql** in Supabase
- [ ] Run **supabase-functions.sql**

### Phase 4: Workflow (10 min)
- [ ] Import **elite-services-main.json** into N8N
- [ ] Configure environment variables from `.env`

### Phase 5: Testing (15 min)
- [ ] Use **QUICK_REFERENCE.md** test commands
- [ ] Verify lead appears in database

### Phase 6: Production (5 min)
- [ ] Configure Meta webhooks
- [ ] Activate N8N workflow
- [ ] Test with real Facebook message

---

## 📝 Documentation by Audience

### For Business Owners
1. **BUSINESS_HANDOFF_GUIDE.md** - Start here
2. **HANDOVER_GUIDE.md** - How staff take over conversations
3. **QUICK_REFERENCE.md** - Basic monitoring

### For Developers/Technical Team
1. **SETUP_GUIDE.md** - Full technical setup
2. **PROJECT_SUMMARY.md** - Architecture overview
3. **QUICK_REFERENCE.md** - SQL queries & debugging
4. **HANDOVER_GUIDE.md** - Handover system details

### For Operations/Support Team
1. **HANDOVER_GUIDE.md** - How to take over conversations
2. **QUICK_REFERENCE.md** - Daily SQL queries
3. **README.md** - Quick links

---

## 🔄 Keeping Files Updated

When you update the workflow:

1. **Export from N8N** → Save as `elite-services-main-v2.json`
2. **Update PROJECT_SUMMARY.md** with any architecture changes
3. **Update SETUP_GUIDE.md** if setup process changed
4. **Update HANDOVER_GUIDE.md** if handover behavior changed
5. **Update .env.example** if new variables added

---

## 📊 File Sizes

| File | Lines | Purpose |
|------|-------|---------|
| elite-services-main.json | ~900 | N8N workflow definition |
| schema.sql | ~220 | Database structure |
| supabase-functions.sql | ~180 | Helper functions |
| SETUP_GUIDE.md | ~600 | Setup instructions |
| HANDOVER_GUIDE.md | ~500 | Handover documentation |
| PROJECT_SUMMARY.md | ~400 | Technical overview |
| QUICK_REFERENCE.md | ~300 | Quick reference |
| BUSINESS_HANDOFF_GUIDE.md | ~250 | Business guide |
| Elite_services.md | ~400 | Requirements |

**Total:** ~3,750 lines of code + documentation

---

## 🎯 One-Page Cheat Sheet

```
┌─────────────────────────────────────────────────┐
│  ELITE SERVICES N8N LEAD GEN - QUICK START      │
└─────────────────────────────────────────────────┘

📥 IMPORT:        elite-services-main.json
🗄️  DATABASE:      schema.sql + supabase-functions.sql
⚙️  CONFIG:        .env.example → .env
📖 SETUP:         SETUP_GUIDE.md
🤝 HANDOVER:      HANDOVER_GUIDE.md
💡 DAILY USE:     QUICK_REFERENCE.md

🔥 WORKS ON:      Facebook, Instagram, Web
🤖 AI:            OpenRouter (any model)
💾 STORAGE:       Supabase + Google Sheets
📢 ALERTS:        Slack + Email
📅 BOOKING:       Google Calendar

💰 COST:          £5-36/month
⏱️  SETUP TIME:    ~2 hours
📊 FEATURES:      Auto-scoring, handover, tracking
```

---

## 🔧 Development Workflow

If you're making changes:

1. **Update workflow** in N8N UI
2. **Export JSON** → Overwrite `elite-services-main.json`
3. **Test locally** with curl commands from QUICK_REFERENCE
4. **Update docs** if behavior changed
5. **Commit changes** with clear message
6. **Tag version** (e.g., `v1.1.0`)

---

## 📚 Additional Documentation to Create (Future)

Consider adding these files as the project grows:

- `CHANGELOG.md` - Version history
- `TROUBLESHOOTING.md` - Common issues & fixes
- `INTEGRATIONS.md` - How to add new integrations
- `LEAD_SCORING.md` - Detailed scoring rules
- `AI_PROMPTS.md` - Conversation prompt engineering
- `TESTING.md` - Testing procedures
- `DEPLOYMENT.md` - Production deployment guide
- `MONITORING.md` - Observability & analytics

---

**This structure keeps everything organized and easy to find! 📁**

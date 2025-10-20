# OATutor Deployment - Quick Start Guide

## TL;DR - Deploy to Production

To deploy your changes to gh-pages (production):

```bash
cd /path/to/OATutor
./deploy-to-ghpages.sh
```

That's it! The script handles everything automatically.

## What You Have Now

There are three new files to help streamline deployment workflow:

### 1. `deploy-to-ghpages.sh` 
**Automated deployment script** - Replaces the manual 4-step process from your notes.

**Usage:**
```bash
./deploy-to-ghpages.sh
```

**What it does:**
- Builds the project from main branch
- Copies build files to temp folder
- Switches to gh-pages and cleans it
- Deploys the new build
- Commits and pushes
- Returns you to main branch

### 2. `DEPLOYMENT.md`
**Complete deployment documentation** covering:
- Quick automated deployment
- Manual deployment steps (backup)
- Repository structure explanation
- GitHub Actions workflows
- Troubleshooting guide

### 3. `BKTPARAMS-EXPLAINED.md`
**Deep dive into the bktParams renaming issue**:
- Why files get renamed
- Where the renaming happens
- Expected directory structure
- How to fix common errors

## Understanding the Workflow

### Current Automated Workflows (GitHub Actions)

1. **Production Deployment** (`deploy-production.yml`)
   - Triggers: Push to `main` branch
   - Builds and deploys to `gh-pages` automatically
   - You usually don't need to run the manual script if this works

2. **Automated Content Update** (`deploy-content-staging.yml`)
   - Triggers: Twice daily (3am, 3pm) OR manual trigger
   - Reads from Google Sheets Problem Bank URL
   - Generates content → `content-staging` branch
   - Builds and deploys to OATutor-Content-Staging repo
   - **This is where bktParams gets renamed!**

### Repository Structure

```
Desktop/OATutor/
├── OATutor-Tooling/          ← Content generation scripts
│   ├── content_script/
│   │   ├── process_sheet.py   ← Processes Google Sheets → JSON
│   │   └── final.py           ← Runs full content update
│   └── selenium/              ← Testing scripts
│
└── OATutor/                   ← Main application (React app)
    ├── src/
    │   ├── content-sources/
    │   │   └── oatutor/       ← Content files (submodule)
    │   └── tools/
    ├── deploy-to-ghpages.sh  ← NEW: Deployment script
    ├── DEPLOYMENT.md          ← NEW: Deployment docs
    ├── BKTPARAMS-EXPLAINED.md ← NEW: bktParams docs
    └── package.json
```

### Branches Explained

- **main**: Development branch for the React app
- **content-staging**: Testing branch for new content from Google Sheets
- **gh-pages**: Production deployment (what users see)

### Separate Repositories

- **OATutor**: Main React application
- **OATutor-Tooling**: Content generation scripts
- **OATutor-Content**: Content submodule (referenced in OATutor)
- **OATutor-Content-Staging**: Content preview deployment (separate repo, like a staging GitHub Pages)

## Common Workflows

### Deploy Updated Content to Production

**Scenario**: You updated Google Sheets and want to deploy to production

1. Wait for automated content update (runs at 3am/3pm) OR manually trigger it from GitHub Actions
2. Content goes to `content-staging` branch
3. Test on Content-Staging preview site
4. If good, merge changes to main
5. GitHub Actions automatically deploys to gh-pages

**OR manually:**
```bash
cd OATutor
./deploy-to-ghpages.sh
```

### Update Content from Google Sheets (Manual)

**Scenario**: You want to manually trigger content generation

From OATutor-Tooling:
```bash
cd content_script
python3 final.py online full
```

### Test a Single Problem

**Scenario**: You want to test one problem works correctly

From OATutor-Tooling:
```bash
cd selenium
python3 test_page.py <problem_name>
```

### Preview Content Before Production

**Scenario**: You want to see content changes before deploying

1. Push changes to `content-staging` branch
2. Automated workflow builds and deploys to OATutor-Content-Staging repo
3. View at the Content-Staging URL (check repo settings for the link)

## Next Steps

### ✅ Done
- [x] Automated build file deployment script
- [x] Documentation of the manual 4-step process
- [x] Explanation of bktParam renaming issue

## Useful Commands

```bash
# Build locally
npm run build

# Start development server
npm start

# Run tests
npm test

# Check git status
git status

# Check current branch
git branch

# View recent commits
git log --oneline -10

# View GitHub Actions workflows
ls -la .github/workflows/
```

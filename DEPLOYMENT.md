# OATutor Deployment Guide

## Quick Deployment to gh-pages

Instead of manually running the 4-step process documented in the team notes, you can now use the automated deployment script:

```bash
./deploy-to-ghpages.sh
```

This script automates the entire process:
1. Builds the project from main branch
2. Copies build files to a temp folder
3. Switches to gh-pages branch and cleans it
4. Copies the build files to gh-pages
5. Commits and pushes the changes
6. Cleans up and returns you to main branch

## Manual Deployment (Old Method)

If you need to run the deployment manually for any reason, here are the commands:

### Step 1: On main branch - build and copy build files to a temp folder

```bash
git checkout main

# Run your build command (replace with your actual build command)
npm run build

# Create a temp folder (you can change this path)
mkdir -p /tmp/build-copy

# Copy build contents to temp folder
cp -r build/* /tmp/build-copy/
```

### Step 2: Switch to gh-pages branch, clean, and copy build files from temp

```bash
git checkout gh-pages

# Remove all tracked files
git rm -rf .

# Remove all untracked files and folders
git clean -fd

# Copy the build files from temp folder to current directory (gh-pages root)
cp -r /tmp/build-copy/* .
```

### Step 3: Stage, commit, and push your changes

```bash
git add -A
git commit -m "Deploy updated build to gh-pages"
git push origin gh-pages
```

### Step 4: Delete the temp build copy folder

```bash
rm -rf /tmp/build-copy
```

## Understanding the Workflow

### Repository Structure

- **OATutor-Tooling**: Content generation from Google Sheets → JSON files
- **OATutor Main Repo**: React application (this repo)
  - `main` branch: Development branch
  - `content-staging` branch: For testing content updates
  - `gh-pages` branch: Production deployment
- **OATutor-Content-Staging**: Separate repo for content previews

### Content Deployment Flow

1. Content is created in Google Sheets
2. OATutor-Tooling processes sheets → generates JSON files
3. Content goes to `content-staging` branch for testing
4. After testing, content is moved to production
5. Main application is built and deployed to `gh-pages`

### The bktParams Issue

During the automated content update workflow, `bktParams.json` is renamed and reorganized:

```bash
mv bktParams.json bkt-params/bktParams1.json
cp bkt-params/bktParams1.json bkt-params/bktParams2.json
```

This happens in `.github/workflows/deploy-content-staging.yml` (lines 56-62).

If you encounter errors about `bktparam1` vs `bktParam`, this is likely due to the naming convention change during deployment.

## GitHub Actions Workflows

The repository has several automated workflows:

1. **deploy-production.yml**: Automatically deploys to gh-pages when pushing to main
2. **deploy-content-staging.yml**: Runs twice daily (3am, 3pm) to update content from Google Sheets
3. **deploy-staging.yml**: Deploys to staging environment
4. **manually-trigger-gh-pages.yml**: Manually trigger a gh-pages rebuild

## Troubleshooting

### Build fails
- Ensure all dependencies are installed: `npm install`
- Check that you're on the correct branch: `git branch`
- Check Node.js version matches project requirements

### gh-pages not updating
- Verify you have push permissions to the gh-pages branch
- Check GitHub Pages settings in the repository settings
- Wait a few minutes for GitHub Pages to rebuild

### bktParams errors
- This file gets renamed during automated deployments
- Check the content structure matches what the application expects
- Review the `deploy-content-staging.yml` workflow for the expected structure

## Need Help?

- Review the main README.md for project setup
- Check existing GitHub Issues
- Review GitHub Actions logs for automated deployment errors

#!/bin/bash

# Automated deployment script for OATutor
# This script automates the process of building and deploying to gh-pages
# Based on the manual workflow documented in the team notes

set -e  # Exit on any error

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OATutor Deployment to gh-pages${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found. Are you in the OATutor root directory?${NC}"
    exit 1
fi

# Confirm with user
echo -e "${YELLOW}This script will:${NC}"
echo "1. Build the project from main branch"
echo "2. Copy build files to a temp folder"
echo "3. Switch to gh-pages branch"
echo "4. Replace all files with the new build"
echo "5. Commit and push to gh-pages"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# Step 1: Ensure we're on main branch and it's up to date
echo -e "${GREEN}[1/7] Checking out main branch...${NC}"
git checkout main
git pull origin main

# Step 2: Run build command
echo -e "${GREEN}[2/7] Running build (this may take a few minutes)...${NC}"
npm run build

if [ ! -d "build" ]; then
    echo -e "${RED}Error: Build directory not found. Build may have failed.${NC}"
    exit 1
fi

# Step 3: Create temp folder and copy build files
echo -e "${GREEN}[3/7] Creating temp folder and copying build files...${NC}"
TEMP_DIR="/tmp/oatutor-build-copy-$(date +%s)"
mkdir -p "$TEMP_DIR"
cp -r build/* "$TEMP_DIR/"

echo -e "${GREEN}Build files copied to: ${TEMP_DIR}${NC}"

# Step 4: Switch to gh-pages branch
echo -e "${GREEN}[4/7] Switching to gh-pages branch...${NC}"
git checkout gh-pages
git pull origin gh-pages

# Step 5: Clean gh-pages branch
echo -e "${GREEN}[5/7] Cleaning gh-pages branch...${NC}"
# Remove all tracked files (except .git)
git rm -rf . 2>/dev/null || true
# Remove all untracked files and folders
git clean -fxd

# Step 6: Copy build files from temp to gh-pages
echo -e "${GREEN}[6/7] Copying build files to gh-pages...${NC}"
cp -r "$TEMP_DIR"/* .

# Step 7: Stage, commit, and push
echo -e "${GREEN}[7/7] Committing and pushing to gh-pages...${NC}"
git add -A

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}No changes detected. gh-pages is already up to date.${NC}"
else
    git commit -m "Deploy updated build to gh-pages ($(date '+%Y-%m-%d %H:%M:%S'))"
    git push origin gh-pages
    echo -e "${GREEN}✓ Successfully deployed to gh-pages!${NC}"
fi

# Clean up temp folder
echo -e "${GREEN}Cleaning up temp folder...${NC}"
rm -rf "$TEMP_DIR"

# Switch back to main branch
echo -e "${GREEN}Switching back to main branch...${NC}"
git checkout main

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Your changes are now live on gh-pages.${NC}"
echo -e "View your deployment at: $(git config --get remote.origin.url | sed 's/\.git$//' | sed 's/github\.com/github.io/' | sed 's/:/\//' | sed 's/git@/https:\/\//')"

#!/bin/bash
# ============================================
# Auto Installer Termux - Update Script
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITHUB_REPO="username/auto-installer"
SCRIPT_DIR="$HOME/.auto_installer"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_REPO/main"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║     Auto Installer - Update Script        ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Check internet
echo -e "${BLUE}🔍 Checking for updates...${NC}"

# Get latest version from GitHub
LATEST_VERSION=$(curl -s "$RAW_URL/version.txt" 2>/dev/null | head -1)

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}❌ Failed to check version!${NC}"
    exit 1
fi

# Check current version
if [ -f "$SCRIPT_DIR/version.txt" ]; then
    CURRENT_VERSION=$(cat "$SCRIPT_DIR/version.txt")
else
    CURRENT_VERSION="0.0.0"
fi

echo -e "${BLUE}Current version: $CURRENT_VERSION${NC}"
echo -e "${BLUE}Latest version: $LATEST_VERSION${NC}"

if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
    echo -e "${GREEN}✅ You have the latest version!${NC}"
    exit 0
fi

# Update
echo -e "\n${YELLOW}⚠️  New version available! Update now? (y/n):${NC}"
read -p "➤ " update

if [[ "$update" != "y" && "$update" != "Y" ]]; then
    echo -e "${RED}Update cancelled!${NC}"
    exit 0
fi

echo -e "${GREEN}📥 Downloading updates...${NC}"

# Download scripts
scripts=("install.sh" "multi_install.sh" "batch_install.sh")

for script in "${scripts[@]}"; do
    echo -e "${YELLOW}Updating: $script${NC}"
    curl -s "$RAW_URL/$script" -o "$HOME/$script"
    chmod +x "$HOME/$script"
done

# Save version
echo "$LATEST_VERSION" > "$SCRIPT_DIR/version.txt"

echo -e "\n${GREEN}✅ Update complete!${NC}"
echo -e "${YELLOW}⚠️  Restart Termux or run: source ~/.bashrc${NC}"

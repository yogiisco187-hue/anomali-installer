#!/bin/bash
# ============================================
# Auto Installer Termux - Single Download
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION="2.0.0"
DOWNLOAD_DIR="$HOME/downloads"
mkdir -p "$DOWNLOAD_DIR"

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     Auto Installer Termux v$VERSION                         ║"
    echo "║     Google Drive Downloader & Installer                  ║"
    echo "║     GitHub: https://github.com/username/auto-installer   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Extract Google Drive ID
extract_gdrive_id() {
    local link="$1"
    local id=""
    
    if [[ "$link" =~ /d/([a-zA-Z0-9_-]+) ]]; then
        id="${BASH_REMATCH[1]}"
    elif [[ "$link" =~ id=([a-zA-Z0-9_-]+) ]]; then
        id="${BASH_REMATCH[1]}"
    elif [[ "$link" =~ file/d/([a-zA-Z0-9_-]+) ]]; then
        id="${BASH_REMATCH[1]}"
    fi
    
    echo "$id"
}

# Download file
download_file() {
    local file_id="$1"
    local filename="$2"
    local url="https://drive.google.com/uc?export=download&id=$file_id"
    
    echo -e "${YELLOW}📥 Downloading: $filename${NC}"
    
    # Handle large files with cookie
    curl -sc /tmp/cookie "$url" > /dev/null
    local confirm=$(curl -Lb /tmp/cookie "$url" | grep -o 'confirm=[^&]*' | head -1 | cut -d'=' -f2)
    
    if [ -n "$confirm" ]; then
        curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=$confirm&id=$file_id" \
            -o "$DOWNLOAD_DIR/$filename" --progress-bar
    else
        curl -L "$url" -o "$DOWNLOAD_DIR/$filename" --progress-bar
    fi
    
    rm -f /tmp/cookie
    
    if [ -f "$DOWNLOAD_DIR/$filename" ]; then
        local size=$(du -h "$DOWNLOAD_DIR/$filename" | cut -f1)
        echo -e "${GREEN}✅ Download complete! ($size)${NC}"
        return 0
    else
        echo -e "${RED}❌ Download failed!${NC}"
        return 1
    fi
}

# Install APK
install_apk() {
    local apk_path="$1"
    local apk_name=$(basename "$apk_path")
    
    echo -e "${YELLOW}📱 Installing: $apk_name${NC}"
    
    pm install "$apk_path" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Installation successful!${NC}"
        return 0
    else
        echo -e "${RED}❌ Installation failed!${NC}"
        return 1
    fi
}

# Main function
main() {
    show_banner
    
    # Get link
    if [ -z "$1" ]; then
        echo -e "${YELLOW}📎 Enter Google Drive link:${NC}"
        read -p "➤ " LINK
    else
        LINK="$1"
    fi
    
    # Validate link
    if [ -z "$LINK" ]; then
        echo -e "${RED}❌ Link cannot be empty!${NC}"
        exit 1
    fi
    
    # Extract ID
    FILE_ID=$(extract_gdrive_id "$LINK")
    
    if [ -z "$FILE_ID" ]; then
        echo -e "${RED}❌ Invalid Google Drive link!${NC}"
        echo -e "${YELLOW}Supported formats:${NC}"
        echo "  • https://drive.google.com/file/d/FILE_ID/view"
        echo "  • https://drive.google.com/open?id=FILE_ID"
        exit 1
    fi
    
    echo -e "${GREEN}✅ File ID: $FILE_ID${NC}"
    
    # Get filename
    echo -e "${YELLOW}📝 Filename (press Enter for auto):${NC}"
    read -p "➤ " FILENAME
    
    if [ -z "$FILENAME" ]; then
        FILENAME="app_$(date +%s).apk"
    fi
    
    # Download
    if download_file "$FILE_ID" "$FILENAME"; then
        # Ask for installation
        echo -e "\n${YELLOW}📱 Install this app? (y/n):${NC}"
        read -p "➤ " INSTALL_CHOICE
        
        if [[ "$INSTALL_CHOICE" == "y" || "$INSTALL_CHOICE" == "Y" ]]; then
            install_apk "$DOWNLOAD_DIR/$FILENAME"
        fi
        
        echo -e "\n${GREEN}✨ Done! File saved to: $DOWNLOAD_DIR/$FILENAME${NC}"
    else
        echo -e "\n${RED}❌ Download failed!${NC}"
        exit 1
    fi
}

# Run
main "$@"

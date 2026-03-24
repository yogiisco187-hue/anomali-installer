#!/bin/bash
# ============================================
# Auto Installer Termux - Batch Install
# Read links from file
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_DIR="$HOME/.auto_installer"
LINKS_FILE="$CONFIG_DIR/links.txt"
DOWNLOAD_DIR="$HOME/downloads"

mkdir -p "$CONFIG_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║     Auto Installer - Batch Install        ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to extract ID
extract_id() {
    if [[ "$1" =~ /d/([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$1" =~ id=([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Check if links file exists
if [ ! -f "$LINKS_FILE" ]; then
    echo -e "${YELLOW}📝 No links file found. Create one? (y/n):${NC}"
    read -p "➤ " create
    
    if [[ "$create" == "y" || "$create" == "Y" ]]; then
        echo -e "${BLUE}Enter links (one per line, Ctrl+D to finish):${NC}"
        cat > "$LINKS_FILE"
        echo -e "${GREEN}✅ Links saved to: $LINKS_FILE${NC}"
    else
        echo -e "${RED}❌ No links file provided!${NC}"
        exit 1
    fi
fi

# Count total links
total=$(grep -c '^https\?://' "$LINKS_FILE" 2>/dev/null || echo 0)

if [ $total -eq 0 ]; then
    echo -e "${RED}❌ No valid links found in $LINKS_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found $total links in $LINKS_FILE${NC}"
echo -ne "${YELLOW}Start download? (y/n): ${NC}"
read confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}Cancelled!${NC}"
    exit 0
fi

# Process each link
success=0
failed=0
count=1

echo -e "\n${CYAN}════════════════════════════════════════════${NC}"
echo -e "${CYAN}           STARTING BATCH DOWNLOAD          ${NC}"
echo -e "${CYAN}════════════════════════════════════════════${NC}\n"

while IFS= read -r link; do
    # Skip empty lines and comments
    [[ -z "$link" || "$link" =~ ^[[:space:]]*# ]] && continue
    
    echo -e "${BLUE}[$count/$total]${NC} Processing: $link"
    
    id=$(extract_id "$link")
    
    if [ -n "$id" ]; then
        filename="batch_${count}_$(date +%s).apk"
        echo -e "${YELLOW}📥 Downloading...${NC}"
        
        curl -L -# "https://drive.google.com/uc?export=download&id=$id" -o "$DOWNLOAD_DIR/$filename" 2>&1
        
        if [ -f "$DOWNLOAD_DIR/$filename" ]; then
            size=$(du -h "$DOWNLOAD_DIR/$filename" | cut -f1)
            echo -e "${GREEN}✅ Downloaded: $filename ($size)${NC}"
            ((success++))
        else
            echo -e "${RED}❌ Download failed!${NC}"
            ((failed++))
        fi
    else
        echo -e "${RED}❌ Invalid link format!${NC}"
        ((failed++))
    fi
    
    ((count++))
    echo ""
done < "$LINKS_FILE"

# Summary
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo -e "${CYAN}              BATCH SUMMARY                  ${NC}"
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Successful downloads: $success${NC}"
echo -e "${RED}❌ Failed downloads: $failed${NC}"
echo -e "${BLUE}📁 Location: $DOWNLOAD_DIR/${NC}"

# Auto install
if [ $success -gt 0 ]; then
    echo -e "\n${YELLOW}📱 Auto install all APKs? (y/n):${NC}"
    read -p "➤ " auto_install
    
    if [[ "$auto_install" == "y" || "$auto_install" == "Y" ]]; then
        installed=0
        install_failed=0
        
        for apk in "$DOWNLOAD_DIR"/batch_*.apk; do
            if [ -f "$apk" ]; then
                echo -e "${YELLOW}Installing: $(basename "$apk")${NC}"
                pm install "$apk" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Installed!${NC}"
                    ((installed++))
                else
                    echo -e "${RED}❌ Failed!${NC}"
                    ((install_failed++))
                fi
            fi
        done
        
        echo -e "\n${GREEN}✅ Installation complete: $installed installed, $install_failed failed${NC}"
    fi
fi

echo -e "\n${GREEN}✨ Batch process completed!${NC}"

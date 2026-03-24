#!/bin/bash
# ============================================
# Auto Installer Termux - Multiple Download
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOWNLOAD_DIR="$HOME/downloads"
mkdir -p "$DOWNLOAD_DIR"

# Extract ID
extract_id() {
    if [[ "$1" =~ /d/([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$1" =~ id=([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Download file
download_file() {
    local id="$1"
    local name="$2"
    
    echo -e "${YELLOW}📥 Downloading: $name${NC}"
    curl -L -# "https://drive.google.com/uc?export=download&id=$id" -o "$DOWNLOAD_DIR/$name"
    
    if [ -f "$DOWNLOAD_DIR/$name" ]; then
        local size=$(du -h "$DOWNLOAD_DIR/$name" | cut -f1)
        echo -e "${GREEN}✅ Done! ($size)${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed!${NC}"
        return 1
    fi
}

# Main
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║     Auto Installer - Multiple Download    ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}Enter links (type 'done' to finish):${NC}\n"

links=()
count=1

while true; do
    echo -ne "${GREEN}Link $count: ${NC}"
    read link
    
    if [[ "$link" == "done" || "$link" == "Done" ]]; then
        break
    fi
    
    if [ -n "$link" ]; then
        links+=("$link")
        ((count++))
    fi
done

total=${#links[@]}

if [ $total -eq 0 ]; then
    echo -e "${RED}❌ No links provided!${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ Total links: $total${NC}"
echo -ne "${YELLOW}Start download? (y/n): ${NC}"
read confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}Cancelled!${NC}"
    exit 0
fi

success=0
failed=0

echo -e "\n${CYAN}════════════════════════════════════════════${NC}"
echo -e "${CYAN}           STARTING DOWNLOAD...              ${NC}"
echo -e "${CYAN}════════════════════════════════════════════${NC}\n"

for i in "${!links[@]}"; do
    echo -e "${BLUE}[$((i+1))/$total]${NC} Processing..."
    
    id=$(extract_id "${links[$i]}")
    
    if [ -n "$id" ]; then
        filename="app_$((i+1))_$(date +%s).apk"
        if download_file "$id" "$filename"; then
            ((success++))
        else
            ((failed++))
        fi
    else
        echo -e "${RED}❌ Invalid link: ${links[$i]}${NC}"
        ((failed++))
    fi
    
    echo ""
done

# Summary
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo -e "${CYAN}              DOWNLOAD SUMMARY               ${NC}"
echo -e "${CYAN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Successful: $success${NC}"
echo -e "${RED}❌ Failed: $failed${NC}"
echo -e "${BLUE}📁 Location: $DOWNLOAD_DIR/${NC}"

# Install all
if [ $success -gt 0 ]; then
    echo -e "\n${YELLOW}📱 Install all downloaded APKs? (y/n):${NC}"
    read -p "➤ " install_all
    
    if [[ "$install_all" == "y" || "$install_all" == "Y" ]]; then
        installed=0
        install_failed=0
        
        for apk in "$DOWNLOAD_DIR"/*.apk; do
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
        
        echo -e "\n${GREEN}✅ Installation: $installed installed, $install_failed failed${NC}"
    fi
fi

echo -e "\n${GREEN}✨ All done!${NC}"

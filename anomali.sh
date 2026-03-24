#!/bin/bash

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
NC='\033[0m'

clear
echo -e "${R}╔════════════════════════════════════╗${NC}"
echo -e "${R}║${NC}      ${C}A N O M A L I${NC}      ${R}║${NC}"
echo -e "${R}║${NC}     ${C}I N S T A L L E R${NC}     ${R}║${NC}"
echo -e "${R}╚════════════════════════════════════╝${NC}"
echo ""

read -p "🔗 Link Folder Google Drive: " folder_link

FOLDER_ID=$(echo $folder_link | grep -oE 'folders/[^/]+|id=[^&]+' | head -1 | cut -d'/' -f2 | cut -d'=' -f2)

if [ -z "$FOLDER_ID" ]; then
    echo -e "\n${R}[!] Link tidak valid!${NC}"
    exit 1
fi

echo -e "\n${Y}[~] Menginstall gdown...${NC}"
pip install gdown -q 2>/dev/null

echo -e "${Y}[~] Downloading folder...${NC}"
gdown --folder "https://drive.google.com/drive/folders/$FOLDER_ID" --folder

echo -e "\n${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${G}[✓] ANOMALI INSTALLER SELESAI!${NC}"
echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${C}File yang didownload:${NC}"
ls -la
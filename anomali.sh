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

# Ambil ID folder (lebih fleksibel)
FOLDER_ID=$(echo "$folder_link" | sed -n 's/.*\/folders\/\([^\/?]*\).*/\1/p')
if [ -z "$FOLDER_ID" ]; then
    FOLDER_ID=$(echo "$folder_link" | grep -o '1[A-Za-z0-9_-]*')
fi

if [ -z "$FOLDER_ID" ]; then
    echo -e "\n${R}[!] Link tidak valid!${NC}"
    echo -e "${Y}Pastikan link seperti:${NC}"
    echo -e "${C}https://drive.google.com/drive/folders/1NTAzQEj_thsZEgWJ04omFXmuwJghRd2Y${NC}"
    exit 1
fi

echo -e "\n${Y}[✓] Folder ID: ${C}$FOLDER_ID${NC}"
echo -e "\n${Y}[~] Menginstall gdown...${NC}"
pip install gdown -q 2>/dev/null

echo -e "${Y}[~] Downloading folder...${NC}"
gdown --folder "https://drive.google.com/drive/folders/$FOLDER_ID" --folder

echo -e "\n${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${G}[✓] ANOMALI INSTALLER SELESAI!${NC}"
echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${C}File yang didownload:${NC}"
ls -la

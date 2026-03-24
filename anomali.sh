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

# === PERBAIKAN: Cara mengambil ID folder yang lebih ampuh ===
# Coba ambil dari pola "folders/ID"
FOLDER_ID=$(echo "$folder_link" | grep -oP '(?<=folders/)[^/?]+' | head -1)

# Jika gagal, coba ambil dari pola "id=ID"
if [ -z "$FOLDER_ID" ]; then
    FOLDER_ID=$(echo "$folder_link" | grep -oP '(?<=id=)[^&]+' | head -1)
fi

# Jika masih gagal, coba ambi pola ID Google Drive (huruf, angka, underscore, strip)
if [ -z "$FOLDER_ID" ]; then
    FOLDER_ID=$(echo "$folder_link" | grep -oE '[0-9A-Za-z_-]{28,}' | head -1)
fi
# ===========================================

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

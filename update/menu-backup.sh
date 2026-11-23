#!/bin/bash
[ -f /usr/local/lib/vpsbox.sh ] && . /usr/local/lib/vpsbox.sh && vpsbox_init
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(head -1 /etc/yokkovpn/theme/color.conf 2>/dev/null | tr -d ' \r\n')
[ -z "$colornow" ] && colornow=green
[ -f "/etc/yokkovpn/theme/$colornow" ] || colornow=green
NC="\e[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
COLOR1="$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLOR1" ] && COLOR1='\033[0;32m'
COLBG1="$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLBG1" ] && COLBG1='\E[40;1;42m'
vpsbox_init
###########- END COLOR CODE -##########
INFO="${GREEN}[INFO]${NC}"

REPO="https://raw.githubusercontent.com/Masbrow33/dxavier/main/backup"
BKPDIR="/root/backup"
API_FILES="/root/multi/bot.conf /root/ResBotAuth /etc/xray/domain"

# ---------- BACKUP VPS ----------
function backup(){
    clear
_box_top
_bcenter "• BACKUP VPS •"
_box_bot
_bline "${INFO} Mengunduh skrip backup..."
    cd /root
    wget -q -O backup.sh "$REPO/backup.sh"
    if [ ! -s backup.sh ]; then
_bline "${RED}[ERROR]${NC} Gagal mengunduh backup.sh"
_bline "${INFO} Cek koneksi atau URL repo."
    else
        chmod +x backup.sh
_bline "${INFO} Menjalankan backup..."
_box_bot
        ./backup.sh
        rm -f backup.sh
    fi
_box_bot
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- RESTORE VPS ----------
function restore(){
    clear
_box_top
_bcenter "• RESTORE VPS •"
_box_bot
_bline "${INFO} Mengunduh skrip restore..."
    cd /root
    wget -q -O restore.sh "$REPO/restore.sh"
    if [ ! -s restore.sh ]; then
_bline "${RED}[ERROR]${NC} Gagal mengunduh restore.sh"
_bline "${INFO} Cek koneksi atau URL repo."
    else
        chmod +x restore.sh
_bline "${INFO} Menjalankan restore..."
_box_bot
        ./restore.sh
        rm -f restore.sh
    fi
_box_bot
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- BACKUP API ----------
function backupapi(){
    clear
    mkdir -p "$BKPDIR"
    local out="$BKPDIR/api-$(date +%Y%m%d-%H%M%S).tar.gz"
_box_top
_bcenter "• BACKUP API •"
_box_bot
    local found=""
    for f in $API_FILES; do
        [ -e "$f" ] && found="$found $f"
    done
    if [ -z "$found" ]; then
_bline "${RED}[ERROR]${NC} Tidak ada file konfigurasi API ditemukan"
    else
        # shellcheck disable=SC2086
        tar -czf "$out" $found 2>/dev/null
        if [ -s "$out" ]; then
_bline "${INFO} Tersimpan: ${GREEN}$out${NC}"
_bline "${INFO} Ukuran   : $(du -h "$out" | cut -f1)"
_bline "${INFO} Isi      :"
            while IFS= read -r line; do
_bline "$line"
            done < <(tar -tzf "$out" 2>/dev/null)
        else
_bline "${RED}[ERROR]${NC} Gagal membuat arsip"
        fi
    fi
_box_bot
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- RESET API ----------
function resetapi(){
    clear
_box_top
_bcenter "• RESET API •"
_box_bot
_bline "${YELLOW}Ini akan menghapus konfigurasi API/bot:${NC}"
    for f in $API_FILES; do
        [ -e "$f" ] && _bline "    - $f"
    done
_bline ""
_bline "${YELLOW}Semua akun VPN di config.json akan dihapus.${NC}"
_bline "Cadangan otomatis dibuat lebih dulu."
_bline ""
    read -p "│   Lanjutkan? [Y/N]: " -e answer
    if [[ "$answer" = 'y' || "$answer" = 'Y' ]]; then
        mkdir -p "$BKPDIR"
        local out="$BKPDIR/api-sebelum-reset-$(date +%Y%m%d-%H%M%S).tar.gz"
        local found=""
        for f in $API_FILES; do
            [ -e "$f" ] && found="$found $f"
        done
        [ -n "$found" ] && tar -czf "$out" $found 2>/dev/null
_bline "${INFO} Cadangan: $out"

        for f in /root/multi/bot.conf /root/ResBotAuth; do
            [ -e "$f" ] && rm -f "$f" && _bline " ${INFO} Dihapus: $f"
        done

        if [ -f /etc/xray/config.json ]; then
            cp /etc/xray/config.json "/etc/xray/config.json.bak-$(date +%Y%m%d-%H%M%S)"
            python3 - <<'PYEOF'
import json
p = "/etc/xray/config.json"
try:
    d = json.load(open(p))
    n = 0
    for ib in d.get("inbounds", []):
        if "clients" in ib.get("settings", {}):
            n += len(ib["settings"]["clients"])
            ib["settings"]["clients"] = []
    json.dump(d, open(p, "w"), indent=2)
    print(f"  {n} akun dihapus dari config.json")
except Exception as e:
    print(f"  gagal: {e}")
PYEOF
            systemctl restart xray >/dev/null 2>&1
_bline "${INFO} Xray direstart"
        fi
_bline "${GREEN}Reset selesai.${NC}"
    else
_bline "${INFO} Dibatalkan."
    fi
_box_bot
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

clear
_box_top
_bcenter "• BACKUP PANEL MENU •"
_box_bot
_box_top
_bmenu2 "01" "BACKUP VPS" "03" "BACKUP API"
_bmenu2 "02" "RESTORE VPS" "04" "RESET API"
_bline ""
_bmenu1 "00" "GO BACK"
_byline
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; backup ;;
02 | 2) clear ; restore ;;
03 | 3) clear ; backupapi ;;
04 | 4) clear ; resetapi ;;
00 | 0) clear ; menu ;;
*) clear ; menu-backup ;;
esac

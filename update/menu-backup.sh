#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/yokkovpn/theme/color.conf 2>/dev/null)
NC="\e[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
COLOR1="$(cat /etc/yokkovpn/theme/$colornow 2>/dev/null | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/yokkovpn/theme/$colornow 2>/dev/null | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
###########- END COLOR CODE -##########
INFO="${GREEN}[INFO]${NC}"

REPO="https://raw.githubusercontent.com/Masbrow33/dxavier/main/backup"
BKPDIR="/root/backup"
API_FILES="/root/multi/bot.conf /root/ResBotAuth /etc/xray/domain"

# ---------- BACKUP VPS ----------
function backup(){
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}                • BACKUP VPS •                 ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1│${NC}  ${INFO} Mengunduh skrip backup..."
    cd /root
    wget -q -O backup.sh "$REPO/backup.sh"
    if [ ! -s backup.sh ]; then
        echo -e "$COLOR1│${NC}  ${RED}[ERROR]${NC} Gagal mengunduh backup.sh"
        echo -e "$COLOR1│${NC}  ${INFO} Cek koneksi atau URL repo."
    else
        chmod +x backup.sh
        echo -e "$COLOR1│${NC}  ${INFO} Menjalankan backup..."
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        ./backup.sh
        rm -f backup.sh
    fi
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- RESTORE VPS ----------
function restore(){
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}               • RESTORE VPS •                 ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1│${NC}  ${INFO} Mengunduh skrip restore..."
    cd /root
    wget -q -O restore.sh "$REPO/restore.sh"
    if [ ! -s restore.sh ]; then
        echo -e "$COLOR1│${NC}  ${RED}[ERROR]${NC} Gagal mengunduh restore.sh"
        echo -e "$COLOR1│${NC}  ${INFO} Cek koneksi atau URL repo."
    else
        chmod +x restore.sh
        echo -e "$COLOR1│${NC}  ${INFO} Menjalankan restore..."
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        ./restore.sh
        rm -f restore.sh
    fi
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- BACKUP API ----------
function backupapi(){
    clear
    mkdir -p "$BKPDIR"
    local out="$BKPDIR/api-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}                • BACKUP API •                 ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    local found=""
    for f in $API_FILES; do
        [ -e "$f" ] && found="$found $f"
    done
    if [ -z "$found" ]; then
        echo -e "$COLOR1│${NC}  ${RED}[ERROR]${NC} Tidak ada file konfigurasi API ditemukan"
    else
        # shellcheck disable=SC2086
        tar -czf "$out" $found 2>/dev/null
        if [ -s "$out" ]; then
            echo -e "$COLOR1│${NC}  ${INFO} Tersimpan: ${GREEN}$out${NC}"
            echo -e "$COLOR1│${NC}  ${INFO} Ukuran   : $(du -h "$out" | cut -f1)"
            echo -e "$COLOR1│${NC}  ${INFO} Isi      :"
            while IFS= read -r line; do
                echo -e "$COLOR1│${NC}     $line"
            done < <(tar -tzf "$out" 2>/dev/null)
        else
            echo -e "$COLOR1│${NC}  ${RED}[ERROR]${NC} Gagal membuat arsip"
        fi
    fi
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

# ---------- RESET API ----------
function resetapi(){
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}                 • RESET API •                 ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1│${NC}   ${YELLOW}Ini akan menghapus konfigurasi API/bot:${NC}"
    for f in $API_FILES; do
        [ -e "$f" ] && echo -e "$COLOR1│${NC}     - $f"
    done
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1│${NC}   ${YELLOW}Semua akun VPN di config.json akan dihapus.${NC}"
    echo -e "$COLOR1│${NC}   Cadangan otomatis dibuat lebih dulu."
    echo -e "$COLOR1│${NC}"
    read -p "│   Lanjutkan? [Y/N]: " -e answer
    if [[ "$answer" = 'y' || "$answer" = 'Y' ]]; then
        mkdir -p "$BKPDIR"
        local out="$BKPDIR/api-sebelum-reset-$(date +%Y%m%d-%H%M%S).tar.gz"
        local found=""
        for f in $API_FILES; do
            [ -e "$f" ] && found="$found $f"
        done
        [ -n "$found" ] && tar -czf "$out" $found 2>/dev/null
        echo -e "$COLOR1│${NC}  ${INFO} Cadangan: $out"

        for f in /root/multi/bot.conf /root/ResBotAuth; do
            [ -e "$f" ] && rm -f "$f" && echo -e "$COLOR1│${NC}  ${INFO} Dihapus: $f"
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
            echo -e "$COLOR1│${NC}  ${INFO} Xray direstart"
        fi
        echo -e "$COLOR1│${NC}  ${GREEN}Reset selesai.${NC}"
    else
        echo -e "$COLOR1│${NC}  ${INFO} Dibatalkan."
    fi
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-backup
}

clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             • BACKUP PANEL MENU •             ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e " $COLOR1┌───────────────────────────────────────────────┐${NC}"
echo -e " $COLOR1│$NC   ${COLOR1}[01]${NC} • BACKUP VPS      ${COLOR1}[03]${NC} • BACKUP API    $COLOR1│$NC"
echo -e " $COLOR1│$NC   ${COLOR1}[02]${NC} • RESTORE VPS     ${COLOR1}[04]${NC} • RESET API     $COLOR1│$NC"
echo -e " $COLOR1│$NC                                               $COLOR1│$NC"
echo -e " $COLOR1│$NC   ${COLOR1}[00]${NC} • GO BACK${NC}                              $COLOR1│$NC"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
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

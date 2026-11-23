#!/bin/bash
# ============================================================
#  EKO BELLICK PREMIUM — VPS PANEL MENU
#  Renderer baris rata (fixed-width 49) + status realtime
# ============================================================

export LC_ALL=C.UTF-8 2>/dev/null

###########- COLOR CODE -##############
colornow=$(head -1 /etc/yokkovpn/theme/color.conf 2>/dev/null | tr -d ' \r\n')
[ -z "$colornow" ] && colornow=green
[ -f "/etc/yokkovpn/theme/$colornow" ] || colornow=green
[ -z "$colornow" ] && colornow="green"
NC=$'\033[0m'
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
COLOR1=$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')
[ -z "$COLOR1" ] && COLOR1=$'\033[0;32m'
COLOR1=$(printf '%b' "$COLOR1")
COLBG1=$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')
COLBG1=$(printf '%b' "$COLBG1")
#########- END COLOR CODE -##########

W=49                      # lebar dalam kotak
BOX_T="${COLOR1}┌$(printf '─%.0s' $(seq 1 $W))┐${NC}"
BOX_B="${COLOR1}└$(printf '─%.0s' $(seq 1 $W))┘${NC}"

# hitung lebar tampak (tanpa kode warna) — KARAKTER, bukan byte.
# awk length menghitung byte, sehingga "•" (3 byte) dianggap 3 kolom
# dan padding meleset 2 kolom per karakter.
_vlen() { printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g' | tr -d '\n' | wc -m | tr -d ' '; }

# baris isi rata kiri:  │ <isi><padding> │
bline() {
    local t="$1" w pad max
    max=$(( W - 1 ))
    w=$(_vlen "$t")
    # potong teks yang melebihi lebar kotak, kalau tidak dinding kanan meluber
    if [ "$w" -gt "$max" ]; then
        t=$(printf '%s' "$t" | sed $'s/\033\\[[0-9;]*m//g' | cut -c1-"$max")
        w=$(_vlen "$t")
    fi
    pad=$(( W - 1 - w ))
    [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$t"
    printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}

# baris judul rata tengah
bcenter() {
    local t="$1" w l r
    w=$(_vlen "$t")
    l=$(( (W - w) / 2 )); [ "$l" -lt 0 ] && l=0
    r=$(( W - w - l ));    [ "$r" -lt 0 ] && r=0
    printf '%s│%s' "$COLOR1" "$NC"
    printf '%*s' "$l" ''
    printf '%s' "$t"
    printf '%*s' "$r" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}

# baris dua kolom:  │ [nn] LABEL      [nn] LABEL │
bmenu2() {
    local n1="$1" l1="$2" n2="$3" l2="$4"
    local left right wl wr gap
    left="${COLOR1}[${n1}]${NC} $(printf '%-14s' "$l1")"
    right="${COLOR1}[${n2}]${NC} ${l2}"
    wl=$(_vlen "$left"); wr=$(_vlen "$right")
    gap=$(( W - 2 - wl - wr )); [ "$gap" -lt 1 ] && gap=1
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"
    printf '%*s' "$gap" ''
    printf '%s %s│%s\n' "$right" "$COLOR1" "$NC"
}

# baris satu kolom (untuk opsi tunggal)
bmenu1() {
    local n="$1" l="$2" left wl pad
    left="${COLOR1}[${n}]${NC} ${l}"
    wl=$(_vlen "$left")
    pad=$(( W - 1 - wl )); [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"
    printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}

# --- status service ---
svc_state() {
    local s
    s=$(systemctl is-active "$1" 2>/dev/null)
    [ "$s" = "active" ] && printf '%sON%s' "$GREEN" "$NC" || printf '%sOFF%s' "$RED" "$NC"
}

###########- DATA -##############
IFACE=$(ip -o -4 route show default 2>/dev/null | awk '{print $5}' | head -1)
[ -z "$IFACE" ] && IFACE="eth0"

tram=$(free -h | awk 'NR==2 {print $2}')
uram=$(free -h | awk 'NR==2 {print $3}')

# Geo dipakai dua kali per render. Tanpa cache, setiap menu memanggil
# ipinfo 3x; setelah beberapa kali API membalas JSON error ({...}) dan
# nilai berisi newline -> baris kotak pecah jadi "│ ISP & City : {" lalu "}│".
# Cache 1 jam + bersihkan newline/kurung kurawal/tanda kutip.
_geo() {
    local url="$1" key="$2" cache="/run/yokkovpn-geo-$2" v="" age
    if [ -f "$cache" ]; then
        age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
        if [ "$age" -ge 0 ] && [ "$age" -lt 3600 ]; then
            v=$(cat "$cache" 2>/dev/null)
        fi
    fi
    if [ -z "$v" ]; then
        v=$(curl -s --max-time 5 "$url" 2>/dev/null)
        printf '%s' "$v" > "$cache" 2>/dev/null
    fi
    # Sanitasi SELALU (baik dari cache maupun API): buang newline, kurung
    # kurawal, kutip, dan karakter kontrol; batasi panjang.
    v=$(printf '%s' "$v" | tr -d '\r\n{}"' | tr -d '[:cntrl:]' | cut -c1-40)
    case "$v" in
        *error*|*Error*|*ERROR*|"") v="N/A" ;;
    esac
    printf '%s' "$v"
}
ISP=$(_geo https://ipinfo.io/org isp | sed 's/^AS[0-9]* //')
CITY=$(_geo https://ipinfo.io/city city)
IPVPS=$(_geo https://ipinfo.io/ip ip)
[ -z "$IPVPS" ] || [ "$IPVPS" = "N/A" ] && IPVPS=$(ip -o -4 addr show "$IFACE" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)
[ -z "$ISP" ] && ISP="N/A"
[ -z "$CITY" ] && CITY="N/A"
DOMAIN=$(cat /etc/xray/domain 2>/dev/null)
[ -z "$DOMAIN" ] && DOMAIN="N/A"

# uptime ringkas
UPRAW=$(uptime -p 2>/dev/null | sed 's/^up //')
[ -z "$UPRAW" ] && UPRAW="N/A"

# traffic
ttoday=$(vnstat -i "$IFACE" 2>/dev/null | grep "today" | awk '{print $2" "$3" RX / "$5" "$6" TX"}')
tmonth=$(vnstat -i "$IFACE" 2>/dev/null | grep -A3 "monthly" | grep "$(date +%Y-%m)" | awk '{print $2" "$3" RX / "$5" "$6" TX"}')
[ -z "$ttoday" ] && ttoday="N/A"
[ -z "$tmonth" ] && tmonth="N/A"

myver="$(cat /opt/.ver 2>/dev/null)"
[ -z "$myver" ] && myver="1.1"
serverV=$(curl -sS --max-time 6 https://raw.githubusercontent.com/Masbrow33/prokontrol/main/version 2>/dev/null)
[ -z "$serverV" ] && serverV="$myver"

status_ws=$(svc_state ws-stunnel)
status_nginx=$(svc_state nginx)
status_xray=$(svc_state xray)

###########- FUNGSI MENU -##############
function add-host(){
    clear
    echo -e "$BOX_T"
    bcenter "• ADD VPS HOST •"
    echo -e "$BOX_B"
    echo -e "$BOX_T"
    bline ""
    printf '%s│%s  New Host Name : ' "$COLOR1" "$NC"
    read -r -e host
    echo -e "$BOX_B"
    echo ""
    if [ -z "$host" ]; then
        echo -e "  ${RED}[INFO]${NC} Type Your Domain / Sub Domain"
    else
        echo "IP=$host" > /var/lib/yokkovpn-pro/ipvps.conf 2>/dev/null
        echo -e "  ${GREEN}[INFO]${NC} Host disimpan: $host"
        echo -e "  ${YELLOW}[INFO]${NC} Jangan lupa renew cert"
    fi
    echo ""
    read -n 1 -s -r -p "  Press any key to back on menu"
    menu
}

function updatews(){
    clear
    echo -e "$BOX_T"
    bcenter "• UPDATE SCRIPT VPS •"
    echo -e "$BOX_B"
    echo -e "$BOX_T"
    bline "${YELLOW}[INFO]${NC} Checking for updates..."
    echo -e "$BOX_B"
    sleep 1
    wget -q --timeout=15 -O /root/install_up.sh "https://raw.githubusercontent.com/Masbrow33/btr/main/update/update.sh" && chmod +x /root/install_up.sh
    if [ -s /root/install_up.sh ]; then
        ./install_up.sh
        sleep 3
        rm -f /root/install_up.sh
        version_up=$(curl -sS --max-time 6 https://raw.githubusercontent.com/Masbrow33/btr/main/version 2>/dev/null)
        [ -n "$version_up" ] && echo "$version_up" > /opt/.ver
        echo -e "  ${GREEN}[INFO]${NC} Successfully Up To Date!"
    else
        echo -e "  ${RED}[INFO]${NC} Gagal ambil update (cek koneksi)"
    fi
    echo ""
    echo -e "$BOX_T"
    bcenter "${GREEN}• EKO BELLICK PREMIUM •${NC}"
    echo -e "$BOX_B"
    echo ""
    read -n 1 -s -r -p "  Press any key to back on menu"
    menu
}

###########- TAMPILAN UTAMA -##############
clear

echo -e "$BOX_T"
bcenter "• VPS PANEL MENU •"
echo -e "$BOX_B"

echo -e "$BOX_T"
bline "User Roles     : ${GREEN}Premium User${NC}"
bline "System Uptime  : $UPRAW"
bline "Memory Usage   : $uram / $tram"
bline "ISP & City     : $ISP / $CITY"
bline "Current Domain : $DOMAIN"
bline "IP VPS         : $COLOR1$IPVPS$NC"
echo -e "$BOX_B"

echo -e "$BOX_T"
bline "SSH WS  : ${status_ws}     XRAY  : ${status_xray}     NGINX : ${status_nginx}"
echo -e "$BOX_B"

echo -e "$BOX_T"
bline "Traffic Today  : $ttoday"
bline "Traffic Month  : $tmonth"
echo -e "$BOX_B"

echo -e "$BOX_T"
bmenu2 "01" "SSH WS"  "07" "THEME"
bmenu2 "02" "VMESS"   "08" "BACKUP"
bmenu2 "03" "VLESS"   "09" "ADD HOST"
bmenu2 "04" "TROJAN"  "10" "RENEW CERT"
bmenu2 "05" "SS WS"   "11" "SETTINGS"
bmenu2 "06" "SET DNS" "12" "INFO"
if [ "$Isadmin" = "ON" ]; then
    bmenu2 "13" "REG IP" "14" "SET BOT"
    ressee="menu-ip"
    bottt="menu-bot"
else
    ressee="menu"
    bottt="menu"
fi
echo -e "$BOX_B"

if [ "$(printf '%s\n%s\n' "$serverV" "$myver" | sort -V | tail -1)" != "$myver" ]; then
    echo -e "${RED}${BOX_T/$COLOR1/$RED}"
    bmenu1 "100" "UPDATE TO V$serverV"
    echo -e "${RED}${BOX_B/$COLOR1/$RED}"
    up2u="updatews"
else
    up2u="menu"
fi

echo -e "$BOX_T"
bline "Version     : $myver (latest)"
bline "Client Name : ${GREEN}EKO BELLICK${NC}"
bline "License     : ${GREEN}LIFETIME${NC}"
echo -e "$BOX_B"

echo -e "$BOX_T"
bcenter "${GREEN}• EKO BELLICK PREMIUM •${NC}"
echo -e "$BOX_B"
echo ""
printf ' Select menu : '
read opt
case $opt in
01 | 1) clear ; menu-ssh ;;
02 | 2) clear ; menu-vmess ;;
03 | 3) clear ; menu-vless ;;
04 | 4) clear ; menu-trojan ;;
05 | 5) clear ; menu-ss ;;
06 | 6) clear ; menu-dns ;;
7)     clear ; menu-theme ;;
8)     clear ; menu-backup ;;
09 | 9) clear ; add-host ;;
10)    clear ; crtxray ;;
11)    clear ; menu-set ;;
12)    clear ; info ;;
13)    clear ; $ressee ;;
14)    clear ; $bottt ;;
100)   clear ; $up2u ;;
00 | 0) clear ; menu ;;
*)     clear ; menu ;;
esac

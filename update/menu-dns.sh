#!/bin/bash
[ -f /usr/local/lib/vpsbox.sh ] && . /usr/local/lib/vpsbox.sh && vpsbox_init
MYIP=$(wget -qO- ipinfo.io/ip);

colornow=$(head -1 /etc/yokkovpn/theme/color.conf 2>/dev/null | tr -d ' \r\n')
[ -z "$colornow" ] && colornow=green
[ -f "/etc/yokkovpn/theme/$colornow" ] || colornow=green
NC="\e[0m"
COLOR1="$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLOR1" ] && COLOR1='\033[0;32m'
COLBG1="$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLBG1" ] && COLBG1='\E[40;1;42m'
vpsbox_init

# File config GitHub dibuat oleh menu-ip saat pertama kali dipakai.
# Tanpa guard ini, membuka menu sebelum konfigurasi menghasilkan
# "cat: No such file or directory" di layar.
mkdir -p /etc/yokkovpn/github 2>/dev/null
APIGIT=$(cat /etc/yokkovpn/github/api 2>/dev/null)
EMAILGIT=$(cat /etc/yokkovpn/github/email 2>/dev/null)
USERGIT=$(cat /etc/yokkovpn/github/username 2>/dev/null)

export RED='\033[0;31m';
export GREEN='\033[0;32m';
# RED/GREEN ditimpa setelah init, jadi harus dikonversi lagi —
# kalau tidak, printf '%s' mencetak teks "\033[0;32m" apa adanya.
RED=$(printf '%b' "$RED")
GREEN=$(printf '%b' "$GREEN")
export ERROR="[${RED}ERROR${NC}]";
export INFO="[${GREEN}INFO${NC}]";


function setdns(){
clear
_box_top
_bcenter "• USERS LOGS •"
_box_bot
_box_top
read -p "│  DNS : " setdnss

if [ -z $setdnss ]; then
_bline ""
_bline "${ERROR} DNS Cannot Be Empty"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
else
echo "$setdnss" > /root/dns
_bline "${INFO} Copy DNS To Resolv.conf"
echo "nameserver $setdnss" > /etc/resolv.conf
sleep 2
_bline "${INFO} Copy DNS To Resolv.conf.d/head"
echo "nameserver $setdnss" > /etc/resolvconf/resolv.conf.d/head
sleep 2
_bline "${INFO} DNS Update Successfully"
fi
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
}

function resdns(){
    clear
_box_top
_bcenter "• USERS LOGS •"
_box_bot
_box_top
read -p "│   Reset Default DNS [Y/N]: " -e answer
if [[ "$answer" = 'y' ]]; then
dnsfile="/root/dns"
if test -f "$dnsfile"; then
rm /root/dns
fi
_bline ""
_bline "${INFO} Delete Resolv.conf DNS"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sleep 2
_bline "${INFO} Delete Resolv.conf.d/head DNS"
echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
sleep 2
else
_bline ""
_bline "$INFO Operation Cancelled By User"
fi
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
}

# Cek konten: DNS aktif, resolv.conf, konektivitas
function contentcek(){
    clear
_box_top
_bcenter "• CONTENT CEK •"
_box_bot
_bline ""
_bline "Domain    : ${GREEN}$(cat /etc/xray/domain 2>/dev/null || echo '-')${NC}"
_bline "IP VPS    : ${GREEN}$(curl -s -m 8 https://ipinfo.io/ip 2>/dev/null || echo '-')${NC}"
    if [ -f /root/dns ]; then
_bline "DNS aktif : ${GREEN}$(cat /root/dns 2>/dev/null)${NC}"
    else
_bline "DNS aktif : ${GREEN}(default sistem)${NC}"
    fi
_bline ""
_bline "${INFO} nameserver di /etc/resolv.conf:"
    while IFS= read -r line; do
_bline "$line"
    done < <(grep -E "^nameserver" /etc/resolv.conf 2>/dev/null || echo "(kosong)")
_bline ""
_bline "${INFO} Uji resolve:"
    for d in google.com cloudflare.com; do
        if getent hosts "$d" >/dev/null 2>&1; then
_bline "${GREEN}OK${NC}  $d"
        else
_bline "${RED}GAGAL${NC}  $d"
        fi
    done
_bline ""
_box_bot
_byline
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-dns
}

# Reboot VPS dengan konfirmasi
function doreboot(){
    clear
_box_top
_bcenter "• REBOOT •"
_box_bot
_bline ""
_bline "${YELLOW}VPS akan reboot sekarang.${NC}"
_bline "Semua koneksi aktif akan terputus."
_bline ""
    read -p "│   Lanjutkan reboot? [Y/N]: " -e answer
    if [[ "$answer" = 'y' || "$answer" = 'Y' ]]; then
_bline "${INFO} Rebooting..."
        sleep 2
        reboot
    else
_bline "${INFO} Dibatalkan."
        sleep 2
        menu-dns
    fi
}

clear
_box_top
_bcenter "• USERS LOGS •"
_box_bot
_box_top

dnsfile="/root/dns"
if test -f "$dnsfile"; then
udns=$(cat /root/dns)
_bline ""
_bline "Active DNS : $udns"
_bline ""
fi
_bmenu2 "01" "CHANGE DNS" "03" "CONTENT CEK"
_bmenu2 "02" "RESET DNS" "04" "REBOOT"
_bline ""
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo -e ""
read -p " Select menu :  "  opt
echo -e   ""
case $opt in
01 | 1) clear ; setdns ;;
02 | 2) clear ; resdns ;;
03 | 3) clear ; contentcek ;;
04 | 4) clear ; doreboot ;;
00 | 0) clear ; menu ;;
*) clear ; menu-dns ;;
esac

#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);

colornow=$(cat /etc/yokkovpn/theme/color.conf)
NC="\e[0m"
COLOR1="$(cat /etc/yokkovpn/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/yokkovpn/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"

# File config GitHub dibuat oleh menu-ip saat pertama kali dipakai.
# Tanpa guard ini, membuka menu sebelum konfigurasi menghasilkan
# "cat: No such file or directory" di layar.
mkdir -p /etc/yokkovpn/github 2>/dev/null
APIGIT=$(cat /etc/yokkovpn/github/api 2>/dev/null)
EMAILGIT=$(cat /etc/yokkovpn/github/email 2>/dev/null)
USERGIT=$(cat /etc/yokkovpn/github/username 2>/dev/null)

export RED='\033[0;31m';
export GREEN='\033[0;32m';
export ERROR="[${RED}ERROR${NC}]";
export INFO="[${GREEN}INFO${NC}]";


function setdns(){
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}                 • USERS LOGS •                ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -p "│  DNS : " setdnss

if [ -z $setdnss ]; then
echo -e "$COLOR1│${NC}"
echo -e "$COLOR1│${NC}  ${ERROR} DNS Cannot Be Empty";
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
else
echo "$setdnss" > /root/dns
echo -e "$COLOR1│${NC}  ${INFO} Copy DNS To Resolv.conf";
echo "nameserver $setdnss" > /etc/resolv.conf
sleep 2
echo -e "$COLOR1│${NC}  ${INFO} Copy DNS To Resolv.conf.d/head";
echo "nameserver $setdnss" > /etc/resolvconf/resolv.conf.d/head
sleep 2
echo -e "$COLOR1│${NC}  ${INFO} DNS Update Successfully";
fi
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
}

function resdns(){
    clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}                 • USERS LOGS •                ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -p "│   Reset Default DNS [Y/N]: " -e answer
if [[ "$answer" = 'y' ]]; then
dnsfile="/root/dns"
if test -f "$dnsfile"; then
rm /root/dns
fi
echo -e "$COLOR1│${NC}"
echo -e "$COLOR1│${NC}  ${INFO} Delete Resolv.conf DNS";
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sleep 2
echo -e "$COLOR1│${NC}  ${INFO} Delete Resolv.conf.d/head DNS";
echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
sleep 2
else
echo -e "$COLOR1│${NC}"
echo -e "$COLOR1│${NC}   $INFO Operation Cancelled By User"
fi
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-dns 
}

# Cek konten: DNS aktif, resolv.conf, konektivitas
function contentcek(){
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}               • CONTENT CEK •                 ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1│${NC}  Domain    : ${GREEN}$(cat /etc/xray/domain 2>/dev/null || echo '-')${NC}"
    echo -e "$COLOR1│${NC}  IP VPS    : ${GREEN}$(curl -s -m 8 https://ipinfo.io/ip 2>/dev/null || echo '-')${NC}"
    if [ -f /root/dns ]; then
        echo -e "$COLOR1│${NC}  DNS aktif : ${GREEN}$(cat /root/dns 2>/dev/null)${NC}"
    else
        echo -e "$COLOR1│${NC}  DNS aktif : ${GREEN}(default sistem)${NC}"
    fi
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1│${NC}  ${INFO} nameserver di /etc/resolv.conf:"
    while IFS= read -r line; do
        echo -e "$COLOR1│${NC}    $line"
    done < <(grep -E "^nameserver" /etc/resolv.conf 2>/dev/null || echo "(kosong)")
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1│${NC}  ${INFO} Uji resolve:"
    for d in google.com cloudflare.com; do
        if getent hosts "$d" >/dev/null 2>&1; then
            echo -e "$COLOR1│${NC}    ${GREEN}OK${NC}  $d"
        else
            echo -e "$COLOR1│${NC}    ${RED}GAGAL${NC}  $d"
        fi
    done
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
    echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    menu-dns
}

# Reboot VPS dengan konfirmasi
function doreboot(){
    clear
    echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
    echo -e "$COLOR1│${NC} ${COLBG1}                  • REBOOT •                   ${NC} $COLOR1│$NC"
    echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
    echo -e "$COLOR1│${NC}"
    echo -e "$COLOR1│${NC}   ${YELLOW}VPS akan reboot sekarang.${NC}"
    echo -e "$COLOR1│${NC}   Semua koneksi aktif akan terputus."
    echo -e "$COLOR1│${NC}"
    read -p "│   Lanjutkan reboot? [Y/N]: " -e answer
    if [[ "$answer" = 'y' || "$answer" = 'Y' ]]; then
        echo -e "$COLOR1│${NC}   ${INFO} Rebooting..."
        sleep 2
        reboot
    else
        echo -e "$COLOR1│${NC}   ${INFO} Dibatalkan."
        sleep 2
        menu-dns
    fi
}

clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}                 • USERS LOGS •                ${NC} $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"

dnsfile="/root/dns"
if test -f "$dnsfile"; then
udns=$(cat /root/dns)
echo -e "$COLOR1│${NC}"
echo -e "$COLOR1│${NC}   Active DNS : $udns"
echo -e "$COLOR1│${NC}"
fi
echo -e "$COLOR1│${NC}  $COLOR1 [01]$NC • CHANGE DNS       $COLOR1 [03]$NC • CONTENT CEK" 
echo -e "$COLOR1│${NC}  $COLOR1 [02]$NC • RESET DNS        $COLOR1 [04]$NC • REBOOT"
echo -e "$COLOR1│${NC}"
echo -e "$COLOR1│${NC}  $COLOR1 [00]$NC • GO BACK"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1│${NC}           ${GREEN}  • EKO BELLICK PREMIUM •   $NC          $COLOR1│$NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
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

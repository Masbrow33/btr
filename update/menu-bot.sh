#!/bin/bash

# --- pembatas rekursi ---
# Menu memanggil dirinya sendiri untuk "kembali ke menu". Bila stdin
# bukan terminal (pipa, cron, skrip), read langsung mengembalikan kosong
# sehingga rekursi tidak pernah berhenti: RAM dan PID habis (fork bomb).
# Saat interaktif (TTY) tidak dibatasi, jadi perilaku normal tidak berubah.
if [ ! -t 0 ]; then
    _vd=$(( ${VPSBOX_DEPTH:-0} + 1 ))
    if [ "$_vd" -gt 8 ]; then exit 0; fi
    export VPSBOX_DEPTH=$_vd
fi
# --- akhir pembatas ---
[ -f /usr/local/lib/vpsbox.sh ] && . /usr/local/lib/vpsbox.sh && vpsbox_init
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(head -1 /etc/yokkovpn/theme/color.conf 2>/dev/null | tr -d ' \r\n')
[ -z "$colornow" ] && colornow=green
[ -f "/etc/yokkovpn/theme/$colornow" ] || colornow=green
NC="\e[0m"
export GREEN='\033[0;32m';
RED="\033[0;31m" 
COLOR1="$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLOR1" ] && COLOR1='\033[0;32m'
COLBG1="$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLBG1" ] && COLBG1='\E[40;1;42m'
vpsbox_init
###########- END COLOR CODE -##########

ipes=$(curl -sS ipv4.icanhazip.com)
if ! command -v jq >/dev/null 2>&1; then
    # jq dari apt (binary jq-linux64 di GitHub hanya x86_64, gagal di ARM)
    apt-get install -y -qq jq >/dev/null 2>&1 || true
fi
if ! command -v jq >/dev/null 2>&1; then
    red "jq tidak tersedia — beberapa fitur menu bisa terbatas."
fi

dircreate() {
    [[ ! -d /root/multi ]] && mkdir -p /root/multi && touch /root/multi/voucher && touch /root/multi/claimed && touch /root/multi/reseller && touch /root/multi/public && touch /root/multi/hist && echo "off" >/root/multi/public
    [[ ! -d /etc/.maAsiss ]] && mkdir -p /etc/.maAsiss
}


function botonoff(){
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "$COLBG1                  • BOT PANEL •                   $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
dircreate
[[ ! -f /root/multi/bot.conf ]] && {
echo -e "
• Status ${GREEN}Installer${NC} And ${GREEN}Running!${NC}
"
[[ ! -f /root/ResBotAuth ]] && {
echo -ne " API TOKEN : "
read bot_tkn
echo "Toket: $bot_tkn" >/root/ResBotAuth
echo -ne " ADMIN ID  : "
read adm_ids
echo "Admin_ID: $adm_ids" >>/root/ResBotAuth
}
echo -ne " BOT NAMME : "
read bot_user
[[ -z $bot_user ]] && bot_user="YokkoEddyStore"
echo ""
echo -ne " LIMIT     : "
read limit_pnl
[[ -z $limit_pnl ]] && limit_pnl="1"
echo ""
cat <<-EOF >/root/multi/bot.conf
Botname: $bot_user
Limit: $limit_pnl
EOF

fun_bot1() {
clear
if [[ ! -x /usr/bin/bbt ]]; then
    wget -q --no-check-certificate -O /usr/bin/bbt "https://raw.githubusercontent.com/Masbrow33/dxavier/main/bot_panel/BotAPI.sh" 2>/dev/null
    chmod +x /usr/bin/bbt
    mkdir -p /etc/.maAsiss 2>/dev/null
    touch /etc/.maAsiss/.Shellbtsss 2>/dev/null
fi
[[ "$(grep -wc "sam_bot" "/etc/rc.local" 2>/dev/null)" = '0' ]] && {
    [ -f /etc/rc.local ] || printf '#!/bin/sh -e\nexit 0\n' > /etc/rc.local
    sed -i '$ i\screen -dmS sam_bot bbt' /etc/rc.local >/dev/null 2>&1
    chmod +x /etc/rc.local 2>/dev/null
}
}
fun_bot1
screen -dmS sam_bot bbt >/dev/null 2>&1
[[ $(ps x | grep "sam_bot" | grep -v grep | wc -l) != '0' ]] && {
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "$COLBG1                  • BOT PANEL •                   $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
echo -e " [INFO]  Bot successfully activated !" 
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
read -n 1 -s -r -p " Press any key to back on menu"
menu-bot
} || {
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "$COLBG1                  • BOT PANEL •                   $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
echo -e " [INFO] Information not valid !"
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
read -n 1 -s -r -p " Press any key to back on menu"
menu-bot
}
} || {
clear
fun_bot2() {
screen -r -S "sam_bot" -X quit >/dev/null 2>&1
[[ $(grep -wc "sam_bot" /etc/rc.local) != '0' ]] && {
sed -i '/sam_bot/d' /etc/rc.local
}
rm -f /root/multi/bot.conf
sleep 1
}
fun_bot2
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "$COLBG1                  • BOT PANEL •                   $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
echo -e " [INFO] Bot Stoped Successfully"
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
read -n 1 -s -r -p " Press any key to back on menu"
menu-bot
}
}
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "$COLBG1                  • BOT PANEL •                   $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
echo -e " $COLOR1 [01]$NC • Start & Stop Bot"
echo -e ""
echo -e " $COLOR1 [00]$NC • Back To Main Menu"
echo -e ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e ""
read -p " Select menu :  "  opt
echo -e   ""
case $opt in
01 | 1) clear ; botonoff ;;
00 | 0) clear ; menu ;;
*) clear ; menu-bot ;;
esac

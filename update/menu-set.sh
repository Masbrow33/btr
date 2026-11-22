#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/yokkovpn/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m" 
COLOR1="$(grep -w "TEXT" /etc/yokkovpn/theme/$colornow 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
COLBG1="$(grep -w "BG" /etc/yokkovpn/theme/$colornow 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
###########- END COLOR CODE -##########
red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'

# ===== helper render kotak (lebar dalam 49) =====
W=49
_vlen() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g; s/\\e\[[0-9;]*m//g' | awk '{print length}'; }
_dashes() { printf '─%.0s' $(seq 1 $1); }
_box_top() { printf '%s┌%s┐%s\n' "$COLOR1" "$(_dashes $W)" "$NC"; }
_box_bot() { printf '%s└%s┘%s\n' "$COLOR1" "$(_dashes $W)" "$NC"; }
_box_mid() { printf '%s├%s┤%s\n' "$COLOR1" "$(_dashes $W)" "$NC"; }
_bline() {
    local t="$1" w pad
    w=$(_vlen "$t"); pad=$(( W - 1 - w )); [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$t"; printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}
_bcenter() {
    local t="$1" w l r
    w=$(_vlen "$t")
    l=$(( (W - w) / 2 )); [ "$l" -lt 0 ] && l=0
    r=$(( W - w - l ));    [ "$r" -lt 0 ] && r=0
    printf '%s│%s' "$COLOR1" "$NC"; printf '%*s' "$l" ''; printf '%s' "$t"
    printf '%*s' "$r" ''; printf '%s│%s\n' "$COLOR1" "$NC"
}
_bstat() {
    local lbl="$1" val="$2" wl wv gap
    wl=$(_vlen "  • $lbl"); wv=$(_vlen "$val")
    gap=$(( W - 2 - wl - wv )); [ "$gap" -lt 1 ] && gap=1
    printf '%s│%s  • %s' "$COLOR1" "$NC" "$lbl"
    printf '%*s' "$gap" ''; printf '%s %s│%s\n' "$val" "$COLOR1" "$NC"
}
_bmenu2() {
    local n1="$1" l1="$2" n2="$3" l2="$4"
    local left right wl wr gap
    left="${COLOR1}[${n1}]${NC} $(printf '%-16s' "$l1")"
    right="${COLOR1}[${n2}]${NC} ${l2}"
    wl=$(_vlen "$left"); wr=$(_vlen "$right")
    gap=$(( W - 2 - wl - wr )); [ "$gap" -lt 1 ] && gap=1
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"; printf '%*s' "$gap" ''
    printf '%s %s│%s\n' "$right" "$COLOR1" "$NC"
}
_bmenu1() {
    local n="$1" l="$2" left wl pad
    left="${COLOR1}[${n}]${NC} ${l}"
    wl=$(_vlen "$left"); pad=$(( W - 1 - wl )); [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"; printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}
_byline() {
    printf '%s┌%s BY %s┐%s\n' "$COLOR1" "$(_dashes 22)" "$(_dashes 23)" "$NC"
    _bcenter "${GREEN}• EKO BELLICK PREMIUM •${NC}"
    _box_bot
}
# ===== end helper =====
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
COLOR1=$(printf '%b' "$COLOR1")
COLBG1=$(printf '%b' "$COLBG1")
NC=$(printf '%b' "$NC")
RED=$(printf '%b' "$RED")
red=$(printf '%b' "$red")
green=$(printf '%b' "$green")
GREEN=$(printf '%b' "$GREEN")
YELLOW=$(printf '%b' "$YELLOW")


function status(){
clear
cek=$(service ssh status | grep active | cut -d ' ' -f5)
if [ "$cek" = "active" ]; then
stat=-f5
else
stat=-f7
fi
cekray=`cat /root/log-install.txt | grep -ow "XRAY" | sort | uniq`
if [ "$cekray" = "XRAY" ]; then
rekk='xray'
becek='XRAY'
else
rekk='v2ray'
becek='V2RAY'
fi

ssh=$(service ssh status | grep active | cut -d ' ' $stat)
if [ "$ssh" = "active" ]; then
ressh="${green}ONLINE${NC}"
else
ressh="${red}OFFLINE${NC}"
fi
sshstunel=$(service stunnel4 status | grep active | cut -d ' ' $stat)
if [ "$sshstunel" = "active" ]; then
resst="${green}ONLINE${NC}"
else
resst="${red}OFFLINE${NC}"
fi
sshws=$(service ws-dropbear status | grep active | cut -d ' ' $stat)
if [ "$sshws" = "active" ]; then
rews="${green}ONLINE${NC}"
else
rews="${red}OFFLINE${NC}"
fi

sshws2=$(service ws-stunnel status | grep active | cut -d ' ' $stat)
if [ "$sshws2" = "active" ]; then
rews2="${green}ONLINE${NC}"
else
rews2="${red}OFFLINE${NC}"
fi

db=$(service dropbear status | grep active | cut -d ' ' $stat)
if [ "$db" = "active" ]; then
resdb="${green}ONLINE${NC}"
else
resdb="${red}OFFLINE${NC}"
fi
 
# Status per protokol: cek service xray hidup DAN inbound-nya ada di config.
# Sebelumnya keempat baris (XRAY-SS/XRAY/VLESS/TROJAN) hanya membaca status
# service yang sama, jadi satu protokol rusak tetap tampil ONLINE semua.
proto_status() {
    local proto="$1"
    local svc
    svc=$(systemctl is-active "$rekk" 2>/dev/null)
    if [ "$svc" != "active" ]; then
        echo "${red}OFFLINE${NC}"
        return
    fi
    if [ -f /etc/xray/config.json ] && grep -q "\"protocol\": *\"$proto\"" /etc/xray/config.json 2>/dev/null; then
        echo "${green}ONLINE${NC}"
    else
        echo "${red}OFFLINE${NC}"
    fi
}

resv2r=$(proto_status "shadowsocks")
resvles=$(proto_status "vless")
restr=$(proto_status "trojan")
resvmess=$(proto_status "vmess")

# Status service xray itu sendiri (bukan per protokol)
if [ "$(systemctl is-active "$rekk" 2>/dev/null)" = "active" ]; then
    resxray="${green}ONLINE${NC}"
else
    resxray="${red}OFFLINE${NC}"
fi

ningx=$(service nginx status | grep active | cut -d ' ' $stat)
if [ "$ningx" = "active" ]; then
resnx="${green}ONLINE${NC}"
else
resnx="${red}OFFLINE${NC}"
fi

squid=$(service squid status | grep active | cut -d ' ' $stat)
if [ "$squid" = "active" ]; then
ressq="${green}ONLINE${NC}"
else
ressq="${red}OFFLINE${NC}"
fi
_box_top
_bcenter "• SERVER STATUS •"
_box_bot
_box_top
_bstat "SSH & VPN" "$ressh"
_bstat "SQUID" "$ressq"
_bstat "DROPBEAR" "$resdb"
_bstat "NGINX" "$resnx"
_bstat "WS DROPBEAR" "$rews"
_bstat "WS STUNNEL" "$rews2"
_bstat "STUNNEL" "$resst"
_bstat "XRAY-SS" "$resv2r"
_bstat "XRAY" "$resxray"
_bstat "VMESS" "$resvmess"
_bstat "VLESS" "$resvles"
_bstat "TROJAN" "$restr"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-set
}
function restart(){
clear
_box_top
_bcenter "• SERVER STATUS •"
_box_bot
_box_top
systemctl daemon-reload
_bline "[INFO] • Starting ..."
sleep 1
systemctl restart ssh
_bline "[INFO] • Restarting SSH Services"
sleep 1
if systemctl list-unit-files 2>/dev/null | grep -q "^squid.service"; then
    systemctl restart squid >/dev/null 2>&1 || true
_bline "[INFO] • Restarting Squid Services"
else
_bline "[SKIP] • Squid tidak terpasang"
fi
sleep 1
systemctl restart openvpn >/dev/null 2>&1 || true
systemctl restart nginx
_bline "[INFO] • Restarting Nginx Services"
sleep 1
systemctl restart dropbear
_bline "[INFO] • Restarting Dropbear Services"
sleep 1
systemctl restart ws-dropbear
_bline "[INFO] • Restarting Ws-Dropbear Services"
sleep 1
systemctl restart ws-stunnel
_bline "[INFO] • Restarting Ws-Stunnel Services"
sleep 1
systemctl restart stunnel4
_bline "[INFO] • Restarting Stunnel4 Services"
sleep 1
systemctl restart xray
_bline "[INFO] • Restarting Xray Services"
sleep 1
systemctl restart cron
_bline "[INFO] • Restarting Cron Services"
_bline "[INFO] • All Services Restates Successfully"
# pastikan service inti hidup walau ada restart yang gagal/terpotong
for svc in nginx xray stunnel4 dropbear ws-dropbear ws-stunnel ws-openssh ssh; do
    systemctl is-active --quiet "$svc" 2>/dev/null || systemctl start "$svc" >/dev/null 2>&1 || true
done
sleep 1
_box_bot
_byline
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-set
}

[[ -f /etc/ontorrent ]] && sts="\033[0;32mON \033[0m" || sts="\033[1;31mOFF\033[0m"

enabletorrent() {
[[ ! -f /etc/ontorrent ]] && {
sudo iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
sudo iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
sudo iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
sudo iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
sudo iptables-save > /etc/iptables.up.rules
sudo iptables-restore -t < /etc/iptables.up.rules
sudo netfilter-persistent save >/dev/null 2>&1  
sudo netfilter-persistent reload >/dev/null 2>&1 
touch /etc/ontorrent
menu-set
} || {
sudo iptables -D FORWARD -m string --string "get_peers" --algo bm -j DROP
sudo iptables -D FORWARD -m string --string "announce_peer" --algo bm -j DROP
sudo iptables -D FORWARD -m string --string "find_node" --algo bm -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "BitTorrent" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "peer_id=" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string ".torrent" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "torrent" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "announce" -j DROP
sudo iptables -D FORWARD -m string --algo bm --string "info_hash" -j DROP
sudo iptables-save > /etc/iptables.up.rules
sudo iptables-restore -t < /etc/iptables.up.rules
sudo netfilter-persistent save >/dev/null 2>&1
sudo netfilter-persistent reload >/dev/null 2>&1 
rm -f /etc/ontorrent
menu-set
}
}

clear
_box_top
_bcenter "• VPS SETTING •"
_box_bot
_box_top
_bmenu2 "01" "RUNNING"        "06" "TCP TWEAK"
_bmenu2 "02" "SET BANNER"     "07" "RESTART ALL"
_bmenu2 "03" "BANDWITH USAGE" "08" "AUTO REBOOT"
_bmenu2 "04" "ANTI TORRENT"   "09" "SPEEDTEST"
_bmenu1 "05" "SET WAKTU REBOOT"
_box_mid
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo -e ""
read -p "  Select menu :  "  opt
echo -e   ""
case $opt in
01 | 1) clear ; status ;;
02 | 2) clear ; nano /etc/issue.net ;;
03 | 3) clear ; mbandwith ;;
04 | 4) clear ; enabletorrent ;;
05 | 5) clear ; jam ;;
06 | 6) clear ; menu-tcp ;;
07 | 7) clear ; restart ;;
08 | 8) clear ; autoboot ;;
09 | 9) clear ; mspeed ;;
00 | 0) clear ; menu ;;
*) clear ; menu-set ;;
esac

       

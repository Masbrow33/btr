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
COLOR1="$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLOR1" ] && COLOR1='\033[0;32m'
COLBG1="$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLBG1" ] && COLBG1='\E[40;1;42m'
vpsbox_init
###########- END COLOR CODE -##########


function delvmess(){
    clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
_box_top
_bcenter "• DELETE XRAY USER •"
_box_bot
_box_top
_bline "• You Dont have any existing clients!"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
fi
clear
_box_top
_bcenter "• DELETE XRAY USER •"
_box_bot
_box_top
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | nl
_bline ""
_bline "• [NOTE] Press any key to back on menu"
_box_bot
echo -e "$COLOR1───────────────────────────────────────────────────${NC}"
read -rp "   Input Username : " user
if [ -z $user ]; then
menu-vmess
else
exp=$(grep -wE "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
systemctl restart xray > /dev/null 2>&1
clear
_box_top
_bcenter "• DELETE XRAY USER •"
_box_bot
_box_top
_bline "• Accound Delete Successfully"
_bline ""
_bline "• Client Name : $user"
_bline "• Expired On  : $exp"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
fi
}
function renewvmess(){
clear
_box_top
_bcenter "• RENEW VMESS USER •"
_box_bot
_box_top
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
_bline "• You have no existing clients!"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
fi
clear
_box_top
_bcenter "• RENEW VMESS USER •"
_box_bot
_box_top
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | nl
_bline ""
_bline "• [NOTE] Press any key to back on menu"
_box_bot
_byline
echo -e "$COLOR1───────────────────────────────────────────────────${NC}"
read -rp "   Input Username : " user
if [ -z $user ]; then
menu-vmess
else
read -p "   Expired (days): " masaaktif
if [ -z $masaaktif ]; then
masaaktif="1"
fi
exp=$(grep -E "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "/### $user/c\### $user $exp4" /etc/xray/config.json
systemctl restart xray > /dev/null 2>&1
clear
_box_top
_bcenter "• RENEW VMESS USER •"
_box_bot
_box_top
_bline "[INFO]  $user Account Renewed Successfully"
_bline ""
_bline "Client Name : $user"
_bline "Days Added  : $masaaktif Days"
_bline "Expired On  : $exp4"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
fi
}

function cekvmess(){
clear
echo -n > /tmp/other.txt
data=( `cat /etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
_box_top
_bcenter "• VMESS USER ONLINE •"
_box_bot
_box_top

for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi

echo -n > /tmp/ipvmess.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do

jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvmess.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvmess.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done

jum=$(cat /tmp/ipvmess.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipvmess.txt | nl)
_bline "user : $akun"
_bline "$jum2"
fi
rm -rf /tmp/ipvmess.txt
done

rm -rf /tmp/other.txt
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
}

function addvmess(){
clear
source /var/lib/yokkovpn-pro/ipvps.conf
domain=$(cat /etc/xray/domain)
_box_top
_bcenter "• CREATE VMESS USER •"
_box_bot
_box_top
tls="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do

read -rp "   Input Username : " -e user
      
if [ -z $user ]; then
_bline "[Error] Username cannot be empty"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
fi
		CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
_box_top
_bcenter "• CREATE VMESS USER •"
_box_bot
_box_top
_bline "Please choose another name."
_box_bot
_byline
			read -n 1 -s -r -p "   Press any key to back on menu"
menu
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "   Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
asu=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "$domain",
      "tls": "tls"
}
EOF`
ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "$domain",
      "tls": "none"
}
EOF`
grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "$domain",
      "tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
_box_top
_bcenter "• CREATE VMESS USER •"
_box_bot
_box_top
_bline "Remarks       : ${user}"
_bline "Expired On    : $exp"
_bline "Domain        : ${domain}"
_bline "Port TLS      : ${tls}"
_bline "Port none TLS : ${none}"
_bline "Port  GRPC    : ${tls}"
_bline "alterId       : 0"
_bline "Security      : auto"
_bline "Network       : ws"
_bline "Path          : /vmess"
_bline "ServiceName   : vmess-grpc"
_box_bot
echo ""
# UUID dan link dicetak di LUAR kotak, tanpa pemotongan, supaya bisa
# disalin utuh ke v2rayNG / HTTP Custom / NapsternetV.
_braw "UUID :"
_braw "${uuid}"
echo ""
_braw "Path WSS :"
_braw "wss://${domain}/vmess"
echo ""
_braw "Link TLS :"
_braw "${vmesslink1}"
echo ""
_braw "Link none TLS :"
_braw "${vmesslink2}"
echo ""
_braw "Link GRPC :"
_braw "${vmesslink3}"
echo ""
_byline
echo ""

read -n 1 -s -r -p "   Press any key to back on menu"
menu-vmess
}


clear
_box_top
_bcenter "• VMESS PANEL MENU •"
_box_bot
_box_top
_bmenu2 "01" "ADD VMESS" "03" "DELETE VMESS"
_bmenu2 "02" "RENEW VMESS" "04" "USER ONLINE"
_bline ""
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; addvmess ;;
02 | 2) clear ; renewvmess ;;
03 | 3) clear ; delvmess ;;
04 | 4) clear ; cekvmess ;;
00 | 0) clear ; menu ;;
*) clear ; menu-vmess ;;
esac

       

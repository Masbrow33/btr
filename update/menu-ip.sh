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


function setapi(){
    clear
_box_top
_bcenter "• IPVPS GITHUB API •"
_box_bot
_box_top

if [[ -f /etc/yokkovpn/github/api && -f /etc/yokkovpn/github/email && -f /etc/yokkovpn/github/username ]]; then
   rec="OK"
else
    mkdir /etc/yokkovpn/github > /dev/null 2>&1
fi

read -p " E-mail   : " EMAIL1
if [ -z $EMAIL1 ]; then
_bline "[INFO] Please Input Your Github Email Adress"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi

read -p " Username : " USERNAME1
if [ -z $USERNAME1 ]; then
_bline "[INFO] Please Input Your Github Username"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi

read -p " API      : " API1
if [ -z $API1 ]; then
_bline "[INFO] Please Input Your Github API"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-ip
fi

sleep 2
echo "$EMAIL1" > /etc/yokkovpn/github/email
echo "$USERNAME1" > /etc/yokkovpn/github/username
echo "$API1" > /etc/yokkovpn/github/api
echo "ON" > /etc/yokkovpn/github/gitstat
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "[INFO] Github Api Setup Successfully"
_bline ""
_bline "• Email : $EMAIL1"
_bline "• User  : $USERNAME1"
_bline "• API   : $API1"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}

function viewapi(){
    clear
_box_top
_bcenter "• LIST REGISTER IP •"
_box_bot
_box_top
_bline "• Email : $EMAILGIT"
_bline "• User  : $USERGIT"
_bline "• API   : $APIGIT"
_bline "• All U need Is Create a new repository"
_bline "& Nammed : permission"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}

function add_ip(){
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
rm -rf /root/permission
read -p "│  NEW IPVPS : " daftar
_bline ""
_bline "[INFO] Checking the IPVPS!"
sleep 1
REQIP=$(curl -sS https://raw.githubusercontent.com/${USERGIT}/permission/main/ipmini | awk '{print $4}' | grep $daftar)
if [[ $daftar = $REQIP ]]; then
_bline "[INFO] VPS IP Already Registered!!"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
else
_bline "[INFO] OK! IP VPS is not Registered!"
_bline "[INFO] Lets Regester it!"
sleep 3
clear
fi
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
read -p "│  User Name  : " client
if [ -z $client ]; then
cd
_bline "[INFO] Please Input client"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi


read -p "│  EXP Date   : " exp
if [ -z $exp ]; then
cd
_bline "[INFO] Please Input exp date"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi

x="ok"

satu="ON"
dua="OFF"
while true $x != "ok"
do
_bline ""
_bmenu2 "01" "ADMIN" "02" "NORMAL"
_bline ""
echo -ne "│  Input your choice : "; read list
echo ""
case "$list" in 
   1) isadmin="$satu";break;;
   2) isadmin="$dua";break;;
esac
done


exp=$(date -d "$exp days" +"%Y-%m-%d")
hariini=$(date -d "0 days" +"%Y-%m-%d")
git config --global user.email "${EMAILGIT}" &> /dev/null
git config --global user.name "${USERGIT}" &> /dev/null
git clone https://github.com/${USERGIT}/permission.git &> /dev/null
cd /root/permission/ &> /dev/null
rm -rf .git &> /dev/null
git init &> /dev/null
touch ipmini &> /dev/null
touch newuser &> /dev/null
TEXT="
Name        : $client 
Admin Panel : $isadmin
Exp         : $exp 
IPVPS       : $daftar 
Reg Date    : $hariini
" 
echo "${TEXT}" >>/root/permission/newuser 
echo "### $client $exp $daftar $isadmin" >>/root/permission/ipmini 
git add .
git commit -m register &> /dev/null
git branch -M main &> /dev/null
git remote add origin https://github.com/${USERGIT}/permission.git &> /dev/null
git push -f https://${APIGIT}@github.com/${USERGIT}/permission.git &> /dev/null
sleep 1
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "Client IP Regested Successfully"
_bline ""
_bline "Client Name   : $client"
_bline "Admin Panel   : $isadmin"
_bline "IP VPS        : $daftar"
_bline "Register Date : $hariini"
_bline "Expired Date  : $exp"
cd
rm -rf /root/permission
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}
function delipvps(){
clear
rm -rf /root/permission &> /dev/null
git config --global user.email "${EMAILGIT}" &> /dev/null
git config --global user.name "${USERGIT}" &> /dev/null
git clone https://github.com/${USERGIT}/permission.git &> /dev/null
cd /root/permission/ &> /dev/null
rm -rf .git &> /dev/null
git init &> /dev/null
touch ipmini &> /dev/null
clear
_box_top
_bcenter "• DELETE IPVPS •"
_box_bot
_box_top
grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 2-4 | nl -s '. '
_box_bot
_byline
echo ""
read -rp "   Please Input Number : " nombor
if [ -z $nombor ]; then
cd
clear
_box_top
_bcenter "• DELETE IPVPS •"
_box_bot
_bline "[INFO] Please Input Correct Number"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi

name1=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 2 | sed -n "$nombor"p) #name
exp=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 3 | sed -n "$nombor"p) #exp
ivps1=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 4 | sed -n "$nombor"p) #ip
sed -i "s/### $name1 $exp $ivps1//g" /root/permission/ipmini &> /dev/null
hariini2=$(date -d "0 days" +"%Y-%m-%d")
TEXTD="
Name     : $name1
IPVPS    : $ivps1  
Status   : Deleted on  $hariini2
" 
echo "${TEXTD}" >>/root/permission/delete_log  &> /dev/null

git add . &> /dev/null
git commit -m remove &> /dev/null
git branch -M main &> /dev/null
git remote add origin https://github.com/${USERGIT}/permission.git &> /dev/null
git push -f https://${APIGIT}@github.com/${USERGIT}/permission.git &> /dev/null
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "Client IP Deleted Successfully"
_bline ""
_bline "Ip VPS       : $ivps1"
_bline "Expired Date : $exp"
_bline "Client Name  : $name1"
cd
rm -rf /root/permission
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}

function renewipvps(){
 clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
rm -rf /root/permission
git config --global user.email "${EMAILGIT}" &> /dev/null
git config --global user.name "${USERGIT}" &> /dev/null
git clone https://github.com/${USERGIT}/permission.git
cd /root/permission/
rm -rf .git
git init
touch ipmini
echo -e "   [ ${Lyellow}INFO${NC} ] Checking list.."

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/root/permission/ipmini")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
  clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "[INFO] You have no existing clients!"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 2-4 | nl -s '. '
_box_bot
_byline
echo -e ""
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
  if [[ ${CLIENT_NUMBER} == '1' ]]; then
    read -rp " Select one client [1]: " CLIENT_NUMBER
  else
    read -rp " Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
  fi
if [ -z $CLIENT_NUMBER ]; then
cd
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "[INFO] Please Input Correct Number"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi
done
echo -e ""
read -p " Expired (days): " masaaktif
if [ -z $masaaktif ]; then
cd
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "[INFO] Please Input Correct Number"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
fi
name1=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p) #name
exp=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p) #exp
ivps1=$(grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p) #ip

now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(((d1 - d2) / 86400))
exp3=$(($exp2 + $masaaktif))
exp4=$(date -d "$exp3 days" +"%Y-%m-%d")
sed -i "s/### $name1 $exp $ivps1/### $name1 $exp4 $ivps1/g" /root/permission/ipmini
git add .
git commit -m renew
git branch -M main
git remote add origin https://github.com/${USERGIT}/permission.git
git push -f https://${APIGIT}@github.com/${USERGIT}/permission.git
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "Client IP VPS Renew Successfully"
_bline ""
_bline "Ip VPS        : $ivps1"
_bline "Renew Date    : $now"
_bline "Days Added    : $masaaktif Days"
_bline "Expired Date  : $exp4"
_bline "Client Name   : $name1"
cd
rm -rf /root/permission
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}

function useripvps(){
clear
rm -rf /root/permission
git config --global user.email "${EMAILGIT}"
git config --global user.name "${USERGIT}"
git clone https://github.com/${USERGIT}/permission.git
cd /root/permission/
rm -rf .git
git init
touch ipmini
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
grep -E "^### " "/root/permission/ipmini" | cut -d ' ' -f 2 | nl -s '. '
_box_bot
_byline
cd
rm -rf /root/permission
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip
}
function resetipvps(){
clear
rm -f /etc/yokkovpn/github/email
rm -f /etc/yokkovpn/github/username
rm -f /etc/yokkovpn/github/api
rm -f /etc/yokkovpn/github/gitstat
echo "OFF" > /etc/yokkovpn/github/gitstat
_box_top
_bcenter "• RESET GITUB API •"
_box_bot
_box_top
_bline "[INFO] Github API Reseted Successfully"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip  
}
Isadmin=$(curl -sS https://raw.githubusercontent.com/${USERGIT:-Masbrow33}/permission/main/ipmini | grep $MYIP | awk '{print $5}')
if [ "$Isadmin" = "OFF" ]; then
clear
_box_top
_bcenter "• PREMIUM USER ONLY •"
_box_bot
_box_top
_bline "[INFO] Only PRO Users Can Use This Panel"
_bline "[INFO] Buy Premium Membership :"
_bline "[INFO] PM : Yokko Eddy Store / wa.me/6281949400586/"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ip  
fi
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
GITREQ=/etc/yokkovpn/github/gitstat
if [ -f "$GITREQ" ]; then
    cekk="ok"
else 
    mkdir /etc/yokkovpn/github
    touch /etc/yokkovpn/github/gitstat
    echo "OFF" > /etc/yokkovpn/github/gitstat
fi

stst1=$(cat /etc/yokkovpn/github/gitstat)
if [ "$stst1" = "OFF" ]; then
clear
_box_top
_bcenter "• REGISTER IPVPS •"
_box_bot
_box_top
_bline "• You Need To Set Github API First!"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to Set API"
setapi
fi
stst=$(cat /etc/yokkovpn/github/gitstat)
if [ "$stst" = "ON" ]; then
APIOK="CEK API"
rex="viewapi"
else
APIOK="SET API"
rex="setapi"
fi
if [ "$stst" = "ON" ]; then
ISON="RESET API"
ressee="resetipvps"
else
ISON=""
ressee="menu-ip"
fi
echo -e "   $COLOR1 [01]$NC • $APIOK        $COLOR1 [04]$NC • RENEW IPVPS" 
echo -e "   $COLOR1 [02]$NC • ADD IPVPS      $COLOR1 [05]$NC • LIST IPVPS"
echo -e "   $COLOR1 [03]$NC • DELETE IPVPS   $COLOR1 [06]$NC • $ISON"
echo -e "   "
echo -e "   $COLOR1 [00]$NC • GO BACK"

_box_bot
_byline
echo -e ""
read -p " Select menu :  "  opt
echo -e   ""
case $opt in
01 | 1) clear ; $rex ;;
02 | 2) clear ; add_ip ;;
03 | 3) clear ; delipvps ;;
04 | 4) clear ; renewipvps ;;
05 | 5) clear ; useripvps ;;
06 | 6) clear ; $ressee ;;
00 | 0) clear ; menu ;;
*) clear ; menu-ip ;;
esac

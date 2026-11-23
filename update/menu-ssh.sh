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
RED="\033[0;31m" 
COLOR1="$(grep -w "TEXT" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLOR1" ] && COLOR1='\033[0;32m'
COLBG1="$(grep -w "BG" "/etc/yokkovpn/theme/$colornow" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' \r\n')"
[ -z "$COLBG1" ] && COLBG1='\E[40;1;42m'
vpsbox_init
###########- END COLOR CODE -##########


function addssh(){
clear
domen=`cat /etc/xray/domain`
portsshws=`cat ~/log-install.txt | grep -w "SSH Websocket" | cut -d: -f2 | awk '{print $1}'`
wsssl=`cat /root/log-install.txt | grep -w "SSH SSL Websocket" | cut -d: -f2 | awk '{print $1}'`

_box_top
_bcenter "• SSH PANEL MENU •"
_box_bot
_box_top
read -p "   Username : " Login

CEKFILE=/etc/xray/ssh.txt
if [ -f "$CEKFILE" ]; then
file001="OK"
else
touch /etc/xray/ssh.txt
fi

if grep -qw "$Login" /etc/xray/ssh.txt; then
_bline "[Error] Username \e[31m$Login\e[0m already exist"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-ssh
else
echo "$Login" >> /etc/xray/ssh.txt
fi

if [ -z $Login ]; then
_bline "[Error] Username cannot be empty"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "    Press any key to back on menu"
menu-ssh
fi

read -p "   Password : " Pass
if [ -z $Pass ]; then
_bline "[Error] Password cannot be empty"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
fi
read -p "   Expired (hari): " masaaktif
if [ -z $masaaktif ]; then
_bline "[Error] EXP Date cannot be empty"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-ssh
fi

IP=$(curl -sS ifconfig.me);
ossl=`cat /root/log-install.txt | grep -w "OpenVPN" | cut -f2 -d: | awk '{print $6}'`
opensh=`cat /root/log-install.txt | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1}'`
db=`cat /root/log-install.txt | grep -w "Dropbear" | cut -f2 -d: | awk '{print $1,$2}'`
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"

OhpSSH=`cat /root/log-install.txt | grep -w "OHP SSH" | cut -d: -f2 | awk '{print $1}'`
OhpDB=`cat /root/log-install.txt | grep -w "OHP DBear" | cut -d: -f2 | awk '{print $1}'`
OhpOVPN=`cat /root/log-install.txt | grep -w "OHP OpenVPN" | cut -d: -f2 | awk '{print $1}'`

sleep 1
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`

if [[ ! -z "${PID}" ]]; then
_box_top
_bcenter "• SSH PANEL MENU •"
_box_bot
_box_top
_bline "Username   : $Login"
_bline "Password   : $Pass"
_bline "Expired On : $exp"
_box_bot
_box_top
_bline "IP         : $IP"
_bline "Host       : $domen"
_bline "OpenSSH    : $opensh"
_bline "Dropbear   : $db"
_bline "SSH-WS     : $portsshws"
_bline "SSH-SSL-WS : $wsssl"
_bline "SSL/TLS    :$ssl"
_bline "UDPGW      : 7100-7300"
_box_bot
_box_top
echo -e "  GET wss://$domen/ssh-ws HTTP/1.1[crlf]Host: $domen [crlf]Upgrade: websocket[crlf][crlf]"
_box_bot
_byline
else
_box_top
_bcenter "• SSH PANEL MENU •"
_box_bot
_box_top
_bline "Username   : $Login"
_bline "Password   : $Pass"
_bline "Expired On : $exp"
_box_bot
_box_top
_bline "IP         : $IP"
_bline "Host       : $domen"
_bline "OpenSSH    : $opensh"
_bline "Dropbear   : $db"
_bline "SSH-WS     : $portsshws"
_bline "SSH-SSL-WS : $wsssl"
_bline "SSL/TLS    :$ssl"
_bline "UDPGW      : 7100-7300"
_box_bot
_box_top
echo -e "  GET wss://$domen/ssh-ws HTTP/1.1[crlf]Host: $domen [crlf]Upgrade: websocket[crlf][crlf]"
_box_bot
_byline
fi
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-ssh
}
function sshwss(){
    clear
portdb=`cat ~/log-install.txt | grep -w "Dropbear" | cut -d: -f2|sed 's/ //g' | cut -f2 -d","`
portsshws=`cat ~/log-install.txt | grep -w "SSH Websocket" | cut -d: -f2 | awk '{print $1}'`
if [ -f "/etc/systemd/system/sshws.service" ]; then
clear
else
wget -q -O /usr/bin/proxy3.js "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/proxy3.js"
cat <<EOF > /etc/systemd/system/sshws.service
[Unit]
Description=WSenabler
Documentation=https://SSHSEDANG.MY.ID

[Service]
Type=simple
ExecStart=/usr/bin/ssh-wsenabler
KillMode=process
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

fi

function start() {
        clear
_box_top
_bcenter "• WEBSOCKET MENU •"
_box_bot
_box_top
wget -q -O /usr/bin/ssh-wsenabler "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/sshws-true.sh" && chmod +x /usr/bin/ssh-wsenabler
systemctl daemon-reload >/dev/null 2>&1
systemctl enable sshws.service >/dev/null 2>&1
systemctl start sshws.service >/dev/null 2>&1
sed -i "/SSH Websocket/c\   - SSH Websocket           : $portsshws [ON]" /root/log-install.txt
_bline "[INFO] • ${green}SSH Websocket Started${NC}"
_bline "[INFO] • Restart is require for Changes"
_bline "to take effect"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
sshwss 
}

function stop() {
        clear
_box_top
_bcenter "• WEBSOCKET MENU •"
_box_bot
_box_top
systemctl stop sshws.service >/dev/null 2>&1
tmux kill-session -t sshws >/dev/null 2>&1
sed -i "/SSH Websocket/c\   - SSH Websocket           : $portsshws [OFF]" /root/log-install.txt
_bline "[INFO] • ${red}SSH Websocket Stopped${NC}"
_bline "[INFO] • Restart is require for Changes"
_bline "to take effect"
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
sshwss 
}

clear
_box_top
_bcenter "• WEBSOCKET MENU •"
_box_bot
_box_top
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`
if [[ ! -z "${PID}" ]]; then
_bline "• Websocket Is ${COLOR1}Running$NC"
else
_bline "• Websocket Is ${red}Not Running$NC"
fi
_bline ""
_bmenu2 "01" "Enable SSH WS" "02" "Disable SSH WS"
_bline ""
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; start ;;
02 | 2) clear ; stop ;;
00 | 0) clear ; menu ;;
*) clear ; menu-set ;;
esac
}
function cekssh(){

clear
_box_top
_bcenter "• SSH ACTIVE USERS •"
_box_bot
_box_top
echo -e ""

if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure";
fi
               
data=( `ps aux | grep -i dropbear | awk '{print $2}'`);
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt;
for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $10}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $12}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi

done
echo " "
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=`cat /tmp/login-db-pid.txt | wc -l`;
        USER=`cat /tmp/login-db-pid.txt | awk '{print $9}'`;
        IP=`cat /tmp/login-db-pid.txt | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi


done
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
        echo " "

        cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
        cat /tmp/vpn-login-tcp.txt
fi

if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
        echo " "

        cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
        cat /tmp/vpn-login-udp.txt
fi


rm -f /tmp/login-db-pid.txt
rm -f /tmp/login-db.txt
rm -f /tmp/vpn-login-tcp.txt
rm -f /tmp/vpn-login-udp.txt
_box_bot
_byline
echo "";
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
}

function delssh(){
clear
_box_top
_bcenter "• SSH DELETE USERS •"
_box_bot
_box_top
read -p "   Username : " Pengguna

if [ -z $Pengguna ]; then
echo -e "   [Error] Username cannot be empty "
else
if getent passwd $Pengguna > /dev/null 2>&1; then
userdel $Pengguna > /dev/null 2>&1
sed -i "s/$Pengguna//g" /etc/xray/ssh.txt
echo -e "   [INFO] User $Pengguna was removed."
else
echo -e "   [INFO] Failure: User $Pengguna Not Exist."
fi
fi
_box_bot
_byline
echo -e ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
}

function renewssh(){
clear
_box_top
_bcenter "• RENEW SSH ACCOUNT •"
_box_bot
_box_top
read -p "   Username : " User

if getent passwd $User > /dev/null 2>&1; then
ok="ok"
else
_bline "[INFO] Failure: User $User Not Exist."
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
fi

if [ -z $User ]; then
_bline "[Error] Username cannot be empty"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu
fi

egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Day Extend : " Days
if [ -z $Days ]; then
Days="1"
fi
Today=`date +%s`
Days_Detailed=$(( $Days * 86400 ))
Expire_On=$(($Today + $Days_Detailed))
Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
passwd -u $User
usermod -e  $Expiration $User
egrep "^$User" /etc/passwd >/dev/null
echo -e "$Pass\n$Pass\n"|passwd $User &> /dev/null
clear
_box_top
_bcenter "• RENEW SSH ACCOUNT •"
_box_bot
_box_top
echo -e "   Username   : $User"
echo -e "   Days Added : $Days Days"
echo -e "   Expires on : $Expiration_Display"
_box_bot
_byline
else
clear
_box_top
_bcenter "• RENEW SSH ACCOUNT •"
_box_bot
_box_top
echo -e "   Username Doesnt Exist      "
_box_bot
_byline
fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
}


function memberssh(){
clear
_box_top
_bcenter "• RENEW SSH ACCOUNT •"
_box_bot
_box_top
echo "   USERNAME          EXP DATE          STATUS"
_box_bot
_box_top
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-17s %2s %-17s %2s \n" "   • $AKUN" "$exp     " "LOCKED"
else
printf "%-17s %2s %-17s %2s \n" "   • $AKUN" "$exp     " "UNLOCKED"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
_box_bot
_box_top
echo "   Total: $JUMLAH User"
_box_bot
_byline
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
}

function trialssh(){
clear
domen=`cat /etc/xray/domain`
portsshws=`cat ~/log-install.txt | grep -w "SSH Websocket" | cut -d: -f2 | awk '{print $1}'`
wsssl=`cat /root/log-install.txt | grep -w "SSH SSL Websocket" | cut -d: -f2 | awk '{print $1}'`
clear
IP=$(curl -sS ifconfig.me);
ossl=`cat /root/log-install.txt | grep -w "OpenVPN" | cut -f2 -d: | awk '{print $6}'`
opensh=`cat /root/log-install.txt | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1}'`
db=`cat /root/log-install.txt | grep -w "Dropbear" | cut -f2 -d: | awk '{print $1,$2}'`
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
OhpSSH=`cat /root/log-install.txt | grep -w "OHP SSH" | cut -d: -f2 | awk '{print $1}'`


Login=artavpn`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=1
echo Ping Host &> /dev/null
echo Create Akun: $Login &> /dev/null
sleep 0.5
echo Setting Password: $Pass &> /dev/null
sleep 0.5
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
PID=`ps -ef |grep -v grep | grep sshws |awk '{print $2}'`

if [[ ! -z "${PID}" ]]; then
_box_top
_bcenter "• SSH TRIAL ACCOUNT •"
_box_bot
_box_top
_bline "Username   : $Login"
_bline "Password   : $Pass"
_bline "Expired On : $exp"
_box_bot
_box_top
_bline "IP         : $IP"
_bline "Host       : $domen"
_bline "OpenSSH    : $opensh"
_bline "Dropbear   : $db"
_bline "SSH-WS     : $portsshws"
_bline "SSH-SSL-WS : $wsssl"
_bline "SSL/TLS    :$ssl"
_bline "UDPGW      : 7100-7300"
_box_bot
_box_top
echo -e "  GET wss://$domen/ssh-ws HTTP/1.1[crlf]Host: $domen [crlf]Upgrade: websocket[crlf][crlf]"
_box_bot
_byline

else

_box_top
_bcenter "• SSH TRIAL ACCOUNT •"
_box_bot
_box_top
_bline "Username   : $Login"
_bline "Password   : $Pass"
_bline "Expired On : $exp"
_box_bot
_box_top
_bline "IP         : $IP"
_bline "Host       : $domen"
_bline "OpenSSH    : $opensh"
_bline "Dropbear   : $db"
_bline "SSH-WS     : $portsshws"
_bline "SSH-SSL-WS : $wsssl"
_bline "SSL/TLS    :$ssl"
_bline "UDPGW      : 7100-7300"
_box_bot
_box_top
_bline "GET wss://$domen/ HTTP/1.1[crlf]Host: $domen [crlf]Upgrade: websocket[crlf][crlf]"
_box_bot
_byline
fi
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
}
clear
_box_top
_bcenter "• SSH PANEL MENU •"
_box_bot
_box_top
_bmenu2 "01" "ADD SSH" "05" "DELETE SSH"
_bmenu2 "02" "TRIAL SSH" "06" "RENEW SSH"
_bmenu2 "03" "USER ONLINE" "07" "USERS LIST"
_bmenu1 "04" "ENABLE WS"
_bline ""
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
01 | 1) clear ; addssh ;;
02 | 2) clear ; trialssh ;;
03 | 3) clear ; cekssh ;;
04 | 4) clear ; sshwss ;;
05 | 5) clear ; delssh ;;
06 | 6) clear ; renewssh ;;
07 | 7) clear ; memberssh ;;
00 | 0) clear ; menu ;;
*) clear ; menu-ssh ;;
esac

       

#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : Awaludin Feriyanto
# (C) Copyright 2021 By FsidVPN
# =========================================

# // Root Checking
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi

# // Exporting Language to UTF-8
export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export LC_CTYPE='en_US.utf8'

# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

# // Export Banner Status Information
export EROR="[${RED} ERROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"

# // Export Align
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"

# // Exporting URL Host
export Server_URL="raw.githubusercontent.com/Masbrow33/prokontrol/main"
export Server_Port="443"
export Server_IP="underfined"
export Script_Mode="Stable"
export Auther="FsidVPN"

# // Exporting Script Version
export VERSION="1.0"
 
# // Exporint IP AddressInformation
export IP=$( curl -s https://ipinfo.io/ip/ )


# // License Validating
echo ""
read -p "Input Your License Key : " Input_License_Key

# // Checking Input Blank
if [[ $Input_License_Key ==  "" ]]; then
    echo -e "${EROR} Please Input License Key !${NC}"
    exit 1
fi

# // Checking License Validate
Key="$Input_License_Key"

# // Set Time To Jakarta / GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# // Algoritma Key
algoritmakeys="1920192019209129403940293013912" 
hashsuccess="$(echo -n "$Key" | sha256sum | cut -d ' ' -f 1)" 
Sha256Successs="$(echo -n "$hashsuccess$algoritmakeys" | sha256sum | cut -d ' ' -f 1)" 
License_Key=$Sha256Successs
echo ""
echo -e "${OKEY} Successfull Connected To ${Server_URL}"
sleep 1

# // Validate Result
Getting_Data_On_Server=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep $License_Key | cut -d ' ' -f 1 )
if [[ "$Getting_Data_On_Server" == "$License_Key" ]]; then
    mkdir -p /etc/${Auther}/
    echo "$License_Key" > /etc/${Auther}/license.key
    echo -e "${OKEY} License Validated !"
    sleep 1
else
    echo -e "${EROR} Your License Key Not Valid !"
    exit 1
fi
# // Checking Your VPS Blocked Or No
if [[ $IP == "" ]]; then
    echo -e "${EROR} Your IP Address Not Detected !"
    exit 1
else
    # // Checking Data
    export Check_Blacklist_Atau_Tidak=$( curl -s https://${Server_URL}/Blacklist.txt | grep -w $License_Key | awk '{print $1}' | tr -d '\r' | tr -d '\r\n' | head -n1 )
    if [[ $Check_Blacklist_Atau_Tidak == $IP ]]; then
        echo -e "${EROR} 403 Forbidden ( Your VPS Has Been Blocked ) !"
        exit 1
    else
        Skip='true'
    fi
fi

# // License Key Detail
export Tanggal_Pembelian_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 3 | tr -d '\r' | tr -d '\r\n')
export Nama_Issued_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 9-100 | tr -d '\r' | tr -d '\r\n')
export Masa_Laku_License_Berlaku_Sampai=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 4 | tr -d '\r' | tr -d '\r\n')
export Install_Limit=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 2 | tr -d '\r' | tr -d '\r\n')
export Tipe_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 8 | tr -d '\r' | tr -d '\r\n')

# // Ouputing Information
echo -e "${OKEY} License Type / Edition ( ${GREEN}$Tipe_License Edition${NC} )" # > // Output Tipe License Dari Exporting 
echo -e "${OKEY} This License Issued to (${GREEN} $Nama_Issued_License ${NC})"
echo -e "${OKEY} Subscription Started On (${GREEN} $Tanggal_Pembelian_License${NC} )"
echo -e "${OKEY} Subscription Ended On ( ${GREEN}${Masa_Laku_License_Berlaku_Sampai}${NC} )"
echo -e "${OKEY} Installation Limit ( ${GREEN}$Install_Limit VPS${NC} )"

# // Exporting Expired Date
export Tanggal_Sekarang=`date -d "0 days" +"%Y-%m-%d"`
export Masa_Aktif_Dalam_Satuan_Detik=$(date -d "$Masa_Laku_License_Berlaku_Sampai" +%s)
export Tanggal_Sekarang_Dalam_Satuan_Detik=$(date -d "$Tanggal_Sekarang" +%s)
export Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik=$(( (Masa_Aktif_Dalam_Satuan_Detik - Tanggal_Sekarang_Dalam_Satuan_Detik) / 86400 ))
if [[ $Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik -lt 0 ]]; then
    echo -e "${EROR} Your License Expired On ( ${RED}$Masa_Laku_License_Berlaku_Sampai${NC} )"
    exit 1
else
    echo -e "${OKEY} Your License Key = $(if [[ ${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik} -lt 5 ]]; then 
    echo -e "${RED}${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik}${NC} Days Left"; else
    echo -e "${GREEN}${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik}${NC} Days Left"; fi )"
fi

# // Validate Successfull
echo ""
read -p "$( echo -e "Press ${CYAN}[ ${NC}${GREEN}Enter${NC} ${CYAN}]${NC} For Starting Installation") "
echo ""

# // Installing Update
echo -e "${GREEN}Starting Installation............${NC}"

dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd /root
#System version number
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
mkdir -p /etc/xray

echo -e "[ ${tyblue}NOTES${NC} ] Before we go.. "
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] I need check your headers first.."
sleep 2
echo -e "[ ${green}INFO${NC} ] Checking headers"
sleep 1
totet=`uname -r`
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  sleep 2
  echo -e "[ ${yell}WARNING${NC} ] Try to install ...."
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  apt-get --yes install $REQUIRED_PKG
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] If error you need.. to do this"
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 1. apt update -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 2. apt upgrade -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 3. apt dist-upgrade -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 4. reboot"
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] After rebooting"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] Then run this script again"
  echo -e "[ ${tyblue}NOTES${NC} ] if you understand then tap enter now"
  read
else
  echo -e "[ ${green}INFO${NC} ] Oke installed"
fi

ttet=`uname -r`
ReqPKG="linux-headers-$ttet"
if ! dpkg -s $ReqPKG  >/dev/null 2>&1; then
  rm /root/setup.sh >/dev/null 2>&1 
  exit
else
  clear
fi


secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
END
chmod 644 /root/.profile

echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aight good ... installation file is ready"
sleep 3

mkdir -p /etc/yokkovpn
mkdir -p /etc/yokkovpn/theme
mkdir -p /var/lib/yokkovpn-pro >/dev/null 2>&1
echo "IP=" >> /var/lib/yokkovpn-pro/ipvps.conf

if [ -f "/etc/xray/domain" ]; then
echo ""
echo -e "[ ${green}INFO${NC} ] Script Already Installed"
echo -ne "[ ${yell}WARNING${NC} ] Do you want to install again ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
rm setup.sh
sleep 10
exit 0
else
clear
fi
fi

echo ""
wget -q https://raw.githubusercontent.com/artanodrop/dxavier/main/dependencies.sh;chmod +x dependencies.sh;./dependencies.sh
rm dependencies.sh
clear

yellow "Add Domain for vmess/vless/trojan dll"
echo " "
read -rp "Input ur domain : " -e pp
echo "$pp" > /root/domain
echo "$pp" > /root/scdomain
echo "$pp" > /etc/xray/domain
echo "$pp" > /etc/xray/scdomain
echo "IP=$pp" > /var/lib/yokkovpn-pro/ipvps.conf

#THEME RED
cat <<EOF>> /etc/yokkovpn/theme/red
BG : \E[40;1;41m
TEXT : \033[0;31m
EOF
#THEME BLUE
cat <<EOF>> /etc/yokkovpn/theme/blue
BG : \E[40;1;44m
TEXT : \033[0;34m
EOF
#THEME GREEN
cat <<EOF>> /etc/yokkovpn/theme/green
BG : \E[40;1;42m
TEXT : \033[0;32m
EOF
#THEME YELLOW
cat <<EOF>> /etc/yokkovpn/theme/yellow
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME MAGENTA
cat <<EOF>> /etc/yokkovpn/theme/magenta
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME CYAN
cat <<EOF>> /etc/yokkovpn/theme/cyan
BG : \E[40;1;46m
TEXT : \033[0;36m
EOF
#THEME CONFIG
cat <<EOF>> /etc/yokkovpn/theme/color.conf
blue
EOF
    
#install ssh ovpn
echo -e "$green[INFO]$NC Install SSH & OpenVPN!"
sleep 2
clear
wget https://raw.githubusercontent.com/Masbrow33/btr/main/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
#Instal Xray
echo -e "$green[INFO]$NC Install Install XRAY!"
sleep 2
clear
wget https://raw.githubusercontent.com/artanodrop/dxavier/main/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear
wget https://raw.githubusercontent.com/artanodrop/dxavier/main/slowdnss/install-sldns.sh && chmod +x install-sldns.sh && ./install-sldns.sh
clear
wget https://raw.githubusercontent.com/artanodrop/dxavier/main/backup/set-br.sh && chmod +x set-br.sh && ./set-br.sh
clear
wget https://raw.githubusercontent.com/artanodrop/dxavier/main/websocket/insshws.sh && chmod +x insshws.sh && ./insshws.sh
clear
echo -e "$green[INFO]$NC Download Extra Menu"
sleep 2
wget https://raw.githubusercontent.com/Masbrow33/btr/main/update/update.sh && chmod +x update.sh && ./update.sh
clear
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi
history -c
serverV=$( curl -sS https://raw.githubusercontent.com/Masbrow33/prokontrol/main/version  )
echo $serverV > /opt/.ver
aureb=$(cat /home/re_otm)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
curl -sS ifconfig.me > /etc/myipvps

echo " "
echo "====================-[ EKO CRISTIAN Premium ]-===================="
echo ""
echo "------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - SSH Websocket           : 80 [ON]" | tee -a log-install.txt
echo "   - SSH SSL Websocket       : 443" | tee -a log-install.txt
echo "   - Stunnel4                : 447, 777" | tee -a log-install.txt
echo "   - Dropbear                : 109, 143" | tee -a log-install.txt
echo "   - Badvpn                  : 7100-7900" | tee -a log-install.txt
echo "   - Nginx                   : 81" | tee -a log-install.txt
echo "   - XRAY  Vmess TLS         : 443" | tee -a log-install.txt
echo "   - XRAY  Vmess None TLS    : 80" | tee -a log-install.txt
echo "   - XRAY  Vless TLS         : 443" | tee -a log-install.txt
echo "   - XRAY  Vless None TLS    : 80" | tee -a log-install.txt
echo "   - Trojan GRPC             : 443" | tee -a log-install.txt
echo "   - Trojan WS               : 443" | tee -a log-install.txt
echo "   - Sodosok WS/GRPC         : 443" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On           : $aureb:00 $gg GMT +7" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - AutoKill Multi Login User" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Fully automatic script" | tee -a log-install.txt
echo "   - VPS settings" | tee -a log-install.txt
echo "   - Admin Control" | tee -a log-install.txt
echo "   - Backup & Restore Data" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo ""
echo ""
echo "------------------------------------------------------------"
echo ""
echo "===============-[ Script Created By EKO CRISTIAN ]-==============="
echo -e ""
echo ""
echo "" | tee -a log-install.txt
rm /root/cf.sh >/dev/null 2>&1
rm /root/setup.sh >/dev/null 2>&1
rm /root/insshws.sh 
rm /root/update.sh
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
echo -e ""
read -n 1 -s -r -p "Press any key to reboot"
reboot

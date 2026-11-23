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
###########- END COLOR CODE -##########


# COLOR
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
vpsbox_init

MYIP=$(curl -s https://icanhazip.com)

clear
tcp_status() {
  if [[ $(grep -c "^#PH56" /etc/sysctl.conf) -eq 1 ]]; then
_bline "TCP 1 Current status : ${green}Installed${NC}"
  else
_bline "TCP 1 Current status : ${red}Not Installed${NC}"
  fi
}

# status tweak
tcp_2_status() {
  if [[ $(grep -c "^##VpsPack" /etc/sysctl.conf) -eq 1 ]]; then
_bline "TCP 2 Current status : ${green}Installed${NC}"
  else
_bline "TCP 2 Current status : ${red}Not Installed${NC}"
  fi
}

# status bbr
bbr_status() {
  local param=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
  if [[ x"${param}" == x"bbr" ]]; then
_bline "BBR status : ${green}Installed${NC}"
  else
_bline "BBR status : ${red}Not Installed${NC}"
  fi
}

delete_bbr() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Do you want to remove BBR? [y/n]: " -e answer0
  if [[ "$answer0" = 'y' ]]; then
    grep -v "^#BBR
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf >/tmp/syscl && mv /tmp/syscl /etc/sysctl.conf
sysctl -p /etc/sysctl.conf >/dev/null
echo "cubic" >/proc/sys/net/ipv4/tcp_congestion_control
_bline "[INFO] BBR settings successfully removed."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  else
    echo ""
    menu-tcp
  fi
}

sysctl_config() {
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  echo "" >>/etc/sysctl.conf
  echo "#BBR" >>/etc/sysctl.conf
  echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
  sysctl -p >/dev/null 2>&1
}

check_bbr_status() {
  local param=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
  if [[ x"${param}" == x"bbr" ]]; then
    return 0
  else
    return 1
  fi
}

version_ge() {
  test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

check_kernel_version() {
  local kernel_version=$(uname -r | cut -d- -f1)
  if version_ge ${kernel_version} 4.9; then
    return 0
  else
    return 1
  fi
}

install_bbr2() {
  check_bbr_status
  if [ $? -eq 0 ]; then
_bline "[INFO]  TCP BBR already  installed."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  fi
  check_kernel_version
  if [ $? -eq 0 ]; then
_bline "[INFO]  Your kernel version is greater than 4.9, directly setting TCP BBR..."
    sysctl_config
_bline "[INFO]  Setting TCP BBR completed..."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  fi

  if [[ x"${release}" == x"centos" ]]; then
_bline "[ERROR] Centos not support"
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  fi
}

install_bbr() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Proceed with installation? [y/n]: " -e answer
  if [[ "$answer" = 'y' ]]; then
    install_bbr2
  else
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  fi
}

delete_Tweaker() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Remove TCP Tweaker settings? [y/n]: " -e answer0
  if [[ "$answer0" = 'y' ]]; then
    grep -v "^#PH56
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf >/tmp/syscl && mv /tmp/syscl /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf >/dev/null
_bline "[INFO] TCP Tweaker settings successfully removed."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  else
    echo ""
    menu-tcp
  fi
}

install_Tweaker() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Proceed with installation? [y/n]: " -e answer
  if [[ "$answer" = 'y' ]]; then
    echo " " >>/etc/sysctl.conf
    echo "#PH56" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" >>/etc/sysctl.conf
    sysctl -p /etc/sysctl.conf >/dev/null
_bline "[INFO] TCP Tweaker settings added successfully."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  else
_bline "Installation was canceled by the user!"
  fi
}

delete_Tweaker_2() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Remove TCP Tweaker settings? [y/n]: " -e answer0
  if [[ "$answer0" = 'y' ]]; then
    grep -v "^##VpsPack
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_orphans = 16384
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384" /etc/sysctl.conf >/tmp/syscl && mv /tmp/syscl /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf >/dev/null
_bline "TCP Tweaker settings successfully removed."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  else
    echo ""
    menu-tcp
  fi
}

install_Tweaker_2() {
  clear
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
  read -p "   [INFO] Proceed with installation? [y/n]: " -e answer
  if [[ "$answer" = 'y' ]]; then
    echo " " >>/etc/sysctl.conf
    echo "##VpsPack" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_orphans = 16384
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384" >>/etc/sysctl.conf
    sysctl -p /etc/sysctl.conf >/dev/null
_bline "[INFO] TCP Tweaker settings added successfully."
_box_bot
_byline
    echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
    menu-tcp
  else
    
_bline "Installation was canceled by the user!"
    
  fi
}

# menu tweaker
_box_top
echo -e "$COLOR1│ $NC$COLBG1              • TCP TWEAK PANEL •              $COLOR1 │$NC"
_box_bot
_box_top
tcp_status
tcp_2_status
bbr_status
_bline ""
_bmenu2 "01" "Install BBR" "04" "Delete BBR"
_bmenu2 "02" "Install TCP 1" "05" "Delete TCP 1"
_bmenu2 "03" "Install TCP 2" "06" "Delete TCP 2"
_bline ""
_bmenu2 "00" "GO BACK" "07" "REBOOT"
_box_bot
_byline
echo -e ""
read -p " Select menu :  " opt
echo -e "$DF"
case $opt in
01 | 1) clear ; install_bbr ;;
02 | 2) clear ; install_Tweaker ;;
03 | 3) clear ; install_Tweaker_2 ;;
04 | 4) clear ; delete_bbr ;;
05 | 5) clear ; delete_Tweaker ;;
06 | 6) clear ; delete_Tweaker_2 ;;
00 | 0) clear ; menu-set ;;
*) clear ; menu-tcp ;;
esac

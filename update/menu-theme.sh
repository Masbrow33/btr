#!/bin/bash
[ -f /usr/local/lib/vpsbox.sh ] && . /usr/local/lib/vpsbox.sh && vpsbox_init
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/yokkovpn/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m" 
COLOR1="$(cat /etc/yokkovpn/theme/$colornow | grep -w "TEXT" | head -1 | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/yokkovpn/theme/$colornow | grep -w "BG" | head -1 | cut -d: -f2|sed 's/ //g')"                    
vpsbox_init
###########- END COLOR CODE -##########


clear
_box_top
_bcenter "• THEME PANEL •"
_box_bot
_box_top
_bmenu2 "01" "BLUE YODO" "04" "CYAN MEOW"
_bmenu2 "02" "RED HOTLINK" "05" "GREEN DAUN"
_bmenu2 "03" "YELLOW DIGI" "06" "MAGENTA AXIS"
_bline ""
_bmenu1 "00" "GO BACK"
_box_bot
_byline
echo -e ""
read -p "  Select Options :  " colormenu 
case $colormenu in
01 | 1)
clear
echo "blue" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• BLUE THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM BLUE Active Successfully"
_bline ""
_box_bot
_byline
;;
02 | 2)
clear
echo "red" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• RED THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM RED Active Successfully"
_bline ""
_box_bot
_byline
;;
03 | 3)
clear
echo "yellow" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• YELLOW THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM YELLOW Active Successfully"
_bline ""
_box_bot
_byline
;;
04 | 4)
clear
echo "cyan" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• CYAN THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM CYAN Active Successfully"
_bline ""
_box_bot
_byline
;;
05 | 5)
clear
echo "green" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• GREEN THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM GREEN Active Successfully"
_bline ""
_box_bot
_byline
;;
06 | 6)
clear
echo "magenta" >/etc/yokkovpn/theme/color.conf
_box_top
_bcenter "• MAGENTA THEME •"
_box_bot
_box_top
_bline ""
_bline "[INFO] TEAM MAGENTA Active Successfully"
_bline ""
_box_bot
_byline
;;
00 | 0)
clear
menu
;;
*)
clear
menu-theme
;;
esac
echo -e ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu-theme 

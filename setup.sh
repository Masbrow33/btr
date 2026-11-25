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

# // Satu instalasi dalam satu waktu
# Tanpa ini, menjalankan script dua kali (misalnya karena mengira
# instalasi berhenti) membuat dua proses memperebutkan lock dpkg dan
# menghabiskan memori sampai VPS tidak bisa di-SSH.
exec 9>/var/lock/yokkovpn-install.lock 2>/dev/null
if ! flock -n 9; then
    _pid=$(fuser /var/lock/yokkovpn-install.lock 2>/dev/null | tr -d ' ')
    echo ""
    echo -e "\033[1;33m[ PERHATIAN ]\033[0m Instalasi lain sedang berjalan${_pid:+ (PID $_pid)}."
    echo -e "\033[1;33m[ PERHATIAN ]\033[0m Tunggu sampai selesai, jangan jalankan ulang."
    echo ""
    echo "  Kemungkinan besar itu instalasi yang sudah SELESAI tetapi"
    echo "  tertahan di prompt reboot. Cek dulu:"
    echo ""
    echo -e "    \033[1;32mps aux | grep setup.sh\033[0m        # masih ada prosesnya?"
    echo -e "    \033[1;32mscreen -ls\033[0m                    # ada sesi 'setup'?"
    echo -e "    \033[1;32mtail -5 /root/log-install.txt\033[0m  # instalasi sudah tuntas?"
    echo ""
    echo "  Kalau instalasi sudah selesai, hentikan prosesnya lalu ulangi:"
    echo -e "    \033[1;32mpkill -f 'bash ./setup.sh'\033[0m"
    echo -e "    \033[1;32mscreen -S setup -X quit\033[0m"
    echo ""
    echo "  Untuk membersihkan semuanya sebelum instal ulang, pakai menu"
    echo "  uninstall:  bash /root/uninstall.sh"
    echo ""
    exit 1
fi

# // Exporting Language to UTF-8
export LC_ALL='C.UTF-8'
export LANG='C.UTF-8'
export LANGUAGE='C.UTF-8'
export LC_CTYPE='C.UTF-8'

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
# Prompt dicetak dengan echo, bukan lewat "read -p". Prompt bawaan read
# hanya tampil bila stdin berupa terminal; kalau script dijalankan lewat
# pipa, cron, atau pembungkus lain, pengguna tidak melihat permintaan
# token sama sekali dan script seolah berhenti tanpa alasan.
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}  \e[1mAKTIVASI SCRIPT\e[0m                                ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  Masukkan license key untuk melanjutkan.        ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  Tekan ENTER tanpa isi untuk membatalkan.       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""
printf '  License Key : '
read -r Input_License_Key
printf '  Domain      : '
read -r pp
echo ""

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
    echo ""
    echo -e "${INFO} Kemungkinan penyebab:"
    echo -e "  1. License key salah ketik"
    echo -e "  2. License key belum terdaftar di repo"
    echo -e "  3. Server tidak bisa mengakses ${Server_URL}"
    echo ""
    echo -e "${INFO} Cek koneksi ke server lisensi:"
    echo -e "  curl -s https://${Server_URL}/validated-registered-license-key.txt | head -1"
    echo ""
    echo -e "${INFO} Tambahkan license baru (hash = sha256 dua lapis):"
    echo -e "  printf '%s' \"KEYKAMU\" | sha256sum | cut -d' ' -f1 | tr -d '\\n' > /tmp/h1"
    echo -e "  cat /tmp/h1 | tr -d '\\n' | sed 's/$/1920192019209129403940293013912/' | sha256sum | cut -d' ' -f1"
    echo ""
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
export Sisa_Hari=$(( (Masa_Aktif_Dalam_Satuan_Detik - Tanggal_Sekarang_Dalam_Satuan_Detik) / 86400 ))
if [[ $Sisa_Hari -lt 0 ]]; then
    echo -e "${EROR} Your License Expired On ( ${RED}$Masa_Laku_License_Berlaku_Sampai${NC} )"
    exit 1
else
    if [[ $Sisa_Hari -lt 5 ]]; then
        echo -e "${OKEY} Your License Key = ${RED}${Sisa_Hari}${NC} Days Left"
    else
        echo -e "${OKEY} Your License Key = ${GREEN}${Sisa_Hari}${NC} Days Left"
    fi
fi

# // Menu Opsi Instalasi (setelah license valid)
if [ -z "$STY" ]; then
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}  \e[1mOPSI INSTALASI\e[0m                                   ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  1. Install di foreground (langsung)          ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  2. Install di background (screen)            ${CYAN}│${NC}"
echo -e "${CYAN}│${NC}  3. Lihat proses instalasi yang berjalan       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""
printf '  Pilihan [1/2/3] : '
read -r install_option
echo ""
    
case "$install_option" in
    3)
        # Check for existing screen sessions
        existing_sessions=$(screen -ls 2>/dev/null | grep -E 'setup|yokkovpn' | awk -F. '{print $1}' | tr -d ' \t')
        if [ -z "$existing_sessions" ]; then
            echo -e "${EROR} Tidak ada sesi instalasi yang berjalan.${NC}"
            exit 1
        else
            echo -e "${INFO} Sesi instalasi yang berjalan:${NC}"
            screen -ls 2>/dev/null | grep -E 'setup|yokkovpn'
            echo ""
            printf '  Pilih sesi untuk dilihat (nomor/ID) : '
            read -r session_id
            if screen -ls 2>/dev/null | grep -q "$session_id"; then
                echo -e "${OKEY} Menampilkan sesi $session_id...${NC}"
                screen -r "$session_id"
                exit 0
            else
                echo -e "${EROR} Sesi $session_id tidak ditemukan.${NC}"
                exit 1
            fi
        fi
        ;;
    2)
        # Start installation in background screen session
        echo -e "${INFO} Memulai instalasi di background (screen -S setup)...${NC}"
        # Simpan variabel yang sudah di-input ke file environment
        echo "Input_License_Key=${Input_License_Key}" > /tmp/install_env
        echo "pp=${pp}" >> /tmp/install_env
        # Unduh setup.sh terlebih dahulu
        wget -q -O /root/setup.sh https://raw.githubusercontent.com/Masbrow33/btr/main/setup.sh
        chmod +x /root/setup.sh
        # Jalankan dengan variabel yang sudah di-set (tidak minta lagi)
        screen -S setup -dm bash -c "set -a; source /tmp/install_env; /root/setup.sh"
        echo -e "${OKEY} Instalasi berjalan di latar belakang.${NC}"
        echo -e "${INFO} Untuk melihat progres: screen -r setup${NC}"
        echo -e "${INFO} Untuk keluar dari sesi: Ctrl+A lalu D${NC}"
        echo -e "${INFO} Untuk kembali ke sesi: screen -r setup${NC}"
        exit 0
        ;;
    *)
        # Default: run in foreground
        echo -e "${INFO} Melanjutkan instalasi di foreground...${NC}"
        ;;
esac
fi

# // Validate Successfull
echo ""
printf '  Tekan %sENTER%s untuk mulai instalasi... ' "$green" "$NC"
read -r
echo ""

# // Installing Update
echo -e "${GREEN}Starting Installation............${NC}"

dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

clear
# Warna di-EXPORT, bukan hanya variabel biasa. ssh-vpn.sh, ins-xray.sh,
# insshws.sh, dan set-br.sh dijalankan sebagai proses terpisah
# (./script.sh), sehingga tanpa export semua pesan mereka tampil tanpa
# warna: "[ ok ]" alih-alih "[ ok ]" berwarna hijau.
export red='\e[1;31m'
export green='\e[0;32m'
export yell='\e[1;33m'
export tyblue='\e[1;36m'
export NC='\e[0m'
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

# ----------------------------------------------------------
#  Cek linux-headers (TIDAK FATAL)
#  Sebelumnya: kalau headers tidak ada, script menghapus
#  dirinya sendiri lalu exit tanpa pesan -> instalasi mati
#  diam-diam. Banyak kernel VPS (aws/azure/ovh/custom) tidak
#  punya paket linux-headers di repo. Headers hanya dibutuhkan
#  fitur tertentu (WireGuard, modul kernel), bukan SSH/Xray.
# ----------------------------------------------------------
ttet=`uname -r`
ReqPKG="linux-headers-$ttet"
if dpkg -s "$ReqPKG" >/dev/null 2>&1; then
  echo -e "[ ${green}INFO${NC} ] Kernel headers OK ($ReqPKG)"
else
  echo -e "[ ${yell}WARNING${NC} ] $ReqPKG belum terpasang, mencoba memasang..."
  apt-get update -y >/dev/null 2>&1
  apt-get --yes install "$ReqPKG" >/dev/null 2>&1 || true
  if dpkg -s "$ReqPKG" >/dev/null 2>&1; then
    echo -e "[ ${green}INFO${NC} ] Kernel headers berhasil dipasang"
  else
    echo -e "[ ${yell}WARNING${NC} ] $ReqPKG tidak tersedia di repo."
    echo -e "[ ${yell}WARNING${NC} ] Instalasi DILANJUTKAN tanpa kernel headers."
    echo -e "[ ${yell}WARNING${NC} ] SSH/Xray/WebSocket tetap jalan."
    echo -e "[ ${yell}WARNING${NC} ] Hanya fitur modul kernel (mis. WireGuard) yang tidak aktif."
    sleep 3
  fi
fi
clear


secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''
cat> /root/.profile << 'END'
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true

# clear hanya untuk login interaktif, supaya output
# perintah ssh jarak jauh tidak tercemar kode escape.
[ -t 0 ] && clear
END
chmod 644 /root/.profile

echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aight good ... installation file is ready"
sleep 3

# Bersihkan salinan lama. wget tanpa -O tidak menimpa: kalau file sudah
# ada, versi baru disimpan sebagai file.1 dan file LAMA yang dijalankan.
# Akibatnya instalasi menjalankan kode usang dan config berlipat.
rm -f /root/ssh-vpn.sh /root/ssh-vpn.sh.[0-9]*
rm -f /root/dependencies.sh /root/ins-xray.sh /root/install-sldns.sh
rm -f /root/set-br.sh /root/insshws.sh /root/update.sh
rm -f /root/ssh-vpn.sh.[0-9]*

mkdir -p /etc/yokkovpn
mkdir -p /etc/yokkovpn/theme
mkdir -p /var/lib/yokkovpn-pro >/dev/null 2>&1
echo "IP=" >> /var/lib/yokkovpn-pro/ipvps.conf

if [ -f "/etc/xray/domain" ]; then
echo ""
echo -e "[ ${green}INFO${NC} ] Script Already Installed (ditemukan /etc/xray/domain)"
echo -ne "[ ${yell}WARNING${NC} ] Install ulang? [y = ya / n = batal] : "
read answer
case "$answer" in
    [Yy]|[Yy][Ee][Ss])
        echo -e "[ ${green}INFO${NC} ] Melanjutkan instalasi ulang..."
        sleep 1
        clear
        ;;
    [Nn]|[Nn][Oo])
        echo -e "[ ${INFO} ] Dibatalkan oleh user."
        echo -e "[ ${INFO} ] Script TIDAK dihapus, bisa dijalankan lagi kapan saja."
        sleep 2
        exit 0
        ;;
    *)
        echo -e "[ ${yell}WARNING${NC} ] Jawaban '$answer' tidak dikenali."
        echo -e "[ ${yell}WARNING${NC} ] Dibatalkan. Jalankan ulang dan jawab y atau n."
        sleep 2
        exit 0
        ;;
esac
fi

echo ""
wget -q -O dependencies.sh https://raw.githubusercontent.com/Masbrow33/dxavier/main/dependencies.sh;chmod +x dependencies.sh;./dependencies.sh
rm dependencies.sh
clear

# Domain kosong membuat nginx gagal start (server_name tanpa argumen)
# dan Xray tidak bisa membuat sertifikat. Pakai placeholder yang aman.
if [ -z "$pp" ]; then
    pp=$(curl -s -m 10 https://ipinfo.io/ip/ 2>/dev/null | tr -d '\r\n')
    [ -z "$pp" ] && pp="127.0.0.1"
    yellow "Domain kosong — memakai IP server: $pp"
fi
echo "$pp" > /root/domain
echo "$pp" > /root/scdomain
echo "$pp" > /etc/xray/domain
echo "$pp" > /etc/xray/scdomain
echo "IP=$pp" > /var/lib/yokkovpn-pro/ipvps.conf

#THEME RED
cat <<EOF> /etc/yokkovpn/theme/red
BG : \E[40;1;41m
TEXT : \033[0;31m
EOF
#THEME BLUE
cat <<EOF> /etc/yokkovpn/theme/blue
BG : \E[40;1;44m
TEXT : \033[0;34m
EOF
#THEME GREEN
cat <<EOF> /etc/yokkovpn/theme/green
BG : \E[40;1;42m
TEXT : \033[0;32m
EOF
#THEME YELLOW
cat <<EOF> /etc/yokkovpn/theme/yellow
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME MAGENTA
cat <<EOF> /etc/yokkovpn/theme/magenta
BG : \E[40;1;43m
TEXT : \033[0;33m
EOF
#THEME CYAN
cat <<EOF> /etc/yokkovpn/theme/cyan
BG : \E[40;1;46m
TEXT : \033[0;36m
EOF
#THEME CONFIG
cat <<EOF> /etc/yokkovpn/theme/color.conf
blue
EOF

# --- rapikan tema dari instalasi lama ---
# Versi lama menulis file tema dengan >> sehingga isinya menumpuk
# (BG/TEXT berulang) dan color.conf bisa berisi beberapa baris.
# Akibatnya nama file tema jadi tidak valid, COLOR1 kosong, warna
# hilang, dan kotak menu tidak lurus. Dirapikan tiap kali install.
for _tf in /etc/yokkovpn/theme/*; do
    [ -f "$_tf" ] || continue
    case "$_tf" in */color.conf) continue ;; esac
    _uniq="$(awk 'NF && !seen[$0]++' "$_tf" 2>/dev/null)"
    [ -n "$_uniq" ] && printf '%s\n' "$_uniq" > "$_tf"
done
_cnow="$(head -1 /etc/yokkovpn/theme/color.conf 2>/dev/null | tr -d ' \r\n')"
[ -f "/etc/yokkovpn/theme/$_cnow" ] || _cnow=green
printf '%s\n' "$_cnow" > /etc/yokkovpn/theme/color.conf
unset _tf _uniq _cnow

#install ssh ovpn
echo -e "$green[INFO]$NC Install SSH & OpenVPN!"
sleep 2
clear
wget -O ssh-vpn.sh https://raw.githubusercontent.com/Masbrow33/btr/main/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
# Install Xray
clear
echo -e "$green[INFO]$NC Install XRAY!"
sleep 2
wget -O ins-xray.sh https://raw.githubusercontent.com/Masbrow33/dxavier/main/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh

# Install BadVPN
clear
wget -O install-badvpn.sh https://raw.githubusercontent.com/Masbrow33/dxavier/main/badvpn/install-badvpn.sh && chmod +x install-badvpn.sh
# Cek arsitektur sebelum jalankan BadVPN (hanya x86_64 yang support)
if [[ $(uname -m) == "x86_64" ]]; then
    ./install-badvpn.sh
else
    echo -e "[ ${yell}WARNING${NC} ] BadVPN tidak tersedia untuk $(uname -m), melewati..."
    rm -f install-badvpn.sh
    sleep 2
fi
clear
wget -O set-br.sh https://raw.githubusercontent.com/Masbrow33/dxavier/main/backup/set-br.sh && chmod +x set-br.sh && ./set-br.sh
clear
wget -O insshws.sh https://raw.githubusercontent.com/Masbrow33/dxavier/main/websocket/insshws.sh && chmod +x insshws.sh && ./insshws.sh
clear
echo -e "$green[INFO]$NC Download Extra Menu"
sleep 2
wget -O update.sh https://raw.githubusercontent.com/Masbrow33/btr/main/update/update.sh && chmod +x update.sh && ./update.sh
clear
cat> /root/.profile << 'END'
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true

# Menu hanya untuk login interaktif.
# Tanpa penjaga ini, setiap perintah ssh jarak jauh ikut membuka menu
# lalu menggantung, sehingga perintah tidak pernah dijalankan
# (gejalanya: "exec request failed on channel 0").
if [ -t 0 ] && [ -n "${SSH_TTY:-}" ]; then
  clear
  menu
fi
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
echo "   - OpenSSH                 : 22,200,500,40000,51443,58080"  | tee -a log-install.txt
echo "   - SSH Websocket           : 80 [ON]" | tee -a log-install.txt
echo "   - SSH SSL Websocket       : 443" | tee -a log-install.txt
echo "   - Stunnel4                : 222, 777, 2096" | tee -a log-install.txt
echo "   - Dropbear                : 69, 109, 110, 143, 50000" | tee -a log-install.txt
_bv_port=$(ss -lun 2>/dev/null | awk '{print $4}' | grep -cE ':(7100|7200|7300|7400|7500|7600|7700|7800|7900)$')
if [ "${_bv_port:-0}" -ge 9 ]; then
echo "   - Badvpn                  : 7100-7900" | tee -a log-install.txt
else
echo "   - Badvpn                  : [OFF] tidak tersedia untuk $(uname -m)" | tee -a log-install.txt
fi
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
echo "------------------------------------------------------------"
echo -e "${GREEN}[ SELESAI ]${NC} Instalasi selesai."
echo ""
echo "  VPS perlu di-reboot supaya semua layanan berjalan normal."
printf '  Tekan %sENTER%s untuk reboot sekarang,\n' "$green" "$NC"
echo "  atau tunggu 60 detik (reboot otomatis)."
printf '  Tekan %sN%s lalu ENTER untuk reboot manual nanti.\n' "$yell" "$NC"
echo ""
read -t 60 -r -p "  Pilihan [ENTER/n] : " _reb
case "${_reb:-}" in
    [Nn]|[Nn][Oo])
        echo ""
        echo -e "\033[1;33m[ INFO ]\033[0m Reboot dilewati. Jalankan 'reboot' kapan saja."
        echo "  Layanan sudah aktif sekarang; reboot hanya merapikan state."
        exit 0
        ;;
    *)
        echo ""
        printf '\033[1;32m[ INFO ]\033[0m Rebooting...\n'
        sleep 2
        reboot
        ;;
esac

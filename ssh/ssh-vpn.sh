#!/bin/bash
#
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=INDONESIA
locality=JAWATENGAH
organization=Blogger
organizationalunit=Blogger
commonname=none
email=admin@sedang.my.id

# simple password minimal
curl -sS https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/password | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END


# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

#install jq
apt -y install jq

#install shc
apt -y install shc

# install wget and curl
apt -y install wget curl

#figlet
apt-get install figlet -y
apt-get install ruby -y
gem install lolcat

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config


install_ssl(){
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            else
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            fi
    else
        yum install -y nginx certbot
        sleep 3s
    fi

    systemctl stop nginx.service

    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            else
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            fi
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
        sleep 3s
    fi
}

# install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/nginx.conf"
rm /etc/nginx/conf.d/vps.conf
wget -q O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/vps.conf"
/etc/init.d/nginx restart

mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart
cd
mkdir /home/vps
mkdir /home/vps/public_html
wget -q -O /home/vps/public_html/index.html "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/multiport"
wget -q -O /home/vps/public_html/.htaccess "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/.htaccess"
mkdir /home/vps/public_html/ss-ws
mkdir /home/vps/public_html/clash-ws
# install badvpn
cd
wget -q -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/newudpgw"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500

# setting port ssh
cd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g'
# /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config

# Ubuntu 24.04 mengaktifkan ssh.socket (socket activation). Saat socket
# aktif, systemd yang memegang port 22 dan sshd TIDAK membaca direktif
# "Port" di sshd_config — akibatnya port 200/500/40000/51443/58080 tidak
# pernah terbuka meski tertulis di config, dan semua klien hanya bisa
# masuk lewat port 22. Matikan socket, pakai service biasa.
if systemctl list-unit-files 2>/dev/null | grep -q '^ssh.socket'; then
    systemctl disable --now ssh.socket >/dev/null 2>&1 || true
    systemctl enable ssh >/dev/null 2>&1 || true
fi
/etc/init.d/ssh restart
sleep 2

echo "=== Install Dropbear ==="
# install dropbear
#apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
# Ubuntu 24.04 mengomentari semua variabel di /etc/default/dropbear
# (#DROPBEAR_PORT=143), jadi sed ke DROPBEAR_PORT=22 tidak pernah cocok.
# Tulis ulang file secara eksplisit agar dropbear benar-benar mendengarkan.
cat > /etc/default/dropbear <<'DBEOF'
# Dropbear configuration
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109 -p 50000 -p 110 -p 69"
DROPBEAR_RECEIVE_WINDOW=65536
DBEOF
# Idempoten: jalankan install berkali-kali tidak boleh menduplikasi baris.
# Tanpa penjaga ini, setiap instalasi ulang menambah satu baris lagi dan
# /etc/shells membengkak.
grep -qxF '/bin/false' /etc/shells 2>/dev/null || echo "/bin/false" >> /etc/shells
grep -qxF '/usr/sbin/nologin' /etc/shells 2>/dev/null || echo "/usr/sbin/nologin" >> /etc/shells
# Rapikan duplikat yang mungkin sudah terlanjur ada dari instalasi lama.
if [ -f /etc/shells ]; then
    awk '!seen[$0]++' /etc/shells > /etc/shells.tmp && mv /etc/shells.tmp /etc/shells
    chmod 644 /etc/shells
fi
/etc/init.d/ssh restart
/etc/init.d/dropbear restart

cd
# install stunnel
#apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear-222]
accept = 222
connect = 127.0.0.1:22

[dropbear-777]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 700

[openvpn]
accept = 442
connect = 127.0.0.1:1194

END

# stunnel butuh nama section unik. Versi lama memakai [dropbear] dua kali.
#
# "pid =" WAJIB ada dan pathnya harus SAMA dengan DEFAULTPIDFILE di
# /etc/init.d/stunnel4 (/var/run/stunnel4.pid). Init script memanggil
# "start_daemon -p <pidfile>"; tanpa pid= stunnel tidak menulis pidfile,
# start_daemon menganggap gagal, systemd menandai unit failed, TAPI proses
# stunnel tetap jalan sebagai orphan dan memegang port 222/777/2096.
# Gejalanya menyesatkan: port terbuka, tapi "systemctl is-active stunnel4"
# bilang failed dan restart berikutnya ikut gagal.
mkdir -p /var/run/stunnel4

# Aktifkan stunnel secara eksplisit: tanpa ini port 222/777/2096 mati
# setelah reboot.
if [ -f /etc/default/stunnel4 ]; then
    sed -i 's/^ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    grep -q '^ENABLED=1' /etc/default/stunnel4 || echo 'ENABLED=1' >> /etc/default/stunnel4
else
    echo 'ENABLED=1' > /etc/default/stunnel4
fi
systemctl enable stunnel4 >/dev/null 2>&1 || true

# Proses stunnel lama (dari percobaan start sebelumnya) bisa masih memegang
# port 222/777 dan membuat restart gagal. Matikan dulu.
pkill -9 -f "/usr/bin/stunnel4 /etc/stunnel/stunnel.conf" 2>/dev/null || true
sleep 2
rm -f /var/run/stunnel4.pid 2>/dev/null || true
systemctl reset-failed stunnel4 >/dev/null 2>&1 || true
systemctl restart stunnel4 >/dev/null 2>&1 || true
sleep 2
if ! systemctl is-active stunnel4 >/dev/null 2>&1; then
    systemctl start stunnel4 >/dev/null 2>&1 || true
    sleep 1
fi

# make a certificate
# Tulis ULANG (>) bukan tambahkan (>>). Dengan >>, instalasi kedua
# menyisipkan key+cert lagi sehingga stunnel.pem berisi
# key, cert, key, cert — file membengkak tiap kali install diulang.
# Stunnel hanya membaca key dan cert pertama, jadi tetap jalan, tapi
# isinya kacau dan makin besar.
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
mkdir -p /etc/stunnel
cat key.pem cert.pem > /etc/stunnel/stunnel.pem
chmod 600 /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart


# install fail2ban
apt -y install fail2ban

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# banner /etc/issue.net
sleep 1
echo -e "[ ${green}INFO$NC ] Settings banner"
# PENTING soal banner: sshd meng-escape karakter non-printable di file
# Banner. Kode warna ANSI (ESC[...m) TIDAK akan pernah tampil — selalu
# muncul sebagai teks "\033[0;32m" sehingga banner terlihat rusak.
# Ini perilaku bawaan OpenSSH, bukan bug script.
# Karena itu issue.net HARUS memakai teks biasa + karakter kotak Unicode
# (┌ ─ │ └), tanpa kode warna sama sekali.
# Jangan tambahkan ANSI escape di issue.net walau terlihat lebih bagus
# di terminal biasa.
wget -q -O /etc/issue.net "https://raw.githubusercontent.com/Masbrow33/btr/main/issue.net"
chmod +x /etc/issue.net

# Jaring pengaman: kalau file dari repo ternyata mengandung ANSI/HTML,
# bersihkan supaya banner tidak tampil berantakan.
if grep -q $'\033' /etc/issue.net 2>/dev/null; then
    sed -i 's/\x1b\[[0-9;]*m//g' /etc/issue.net
fi
if grep -q '<font\|<p style\|<br>' /etc/issue.net 2>/dev/null; then
    # Versi lama menyimpan HTML; kalau masih terjadi, pakai banner cadangan.
    sed -i 's/<[^>]*>//g' /etc/issue.net
fi

# Dropbear: hanya ganti kalau masih kosong. Kalau sudah terisi, biarkan —
# supaya instalasi ulang tidak menumpuk.
if grep -q '^DROPBEAR_BANNER=""' /etc/default/dropbear 2>/dev/null; then
    sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@' /etc/default/dropbear
fi
grep -q '^DROPBEAR_BANNER=' /etc/default/dropbear 2>/dev/null || \
    echo 'DROPBEAR_BANNER="/etc/issue.net"' >> /etc/default/dropbear

# Tuning sshd untuk VPS kecil.
# Default MaxStartups 10:30:100 terlalu ketat: 10 koneksi yang belum
# terautentikasi sudah membuat sshd membuang koneksi baru
# ("drop connection past MaxStartups"). Gejalanya membingungkan karena
# TCP handshake tetap berhasil dan port terlihat terbuka, tapi SSH
# tidak pernah mengirim banner -> klien timeout. GSSAPI dan reverse
# DNS juga memperlambat banner, jadi dimatikan.
sed -i '/^MaxStartups/d; /^MaxSessions/d; /^LoginGraceTime/d; /^UseDNS/d; /^GSSAPIAuthentication/d' /etc/ssh/sshd_config
# Hapus HANYA baris penanda komentar. Isi blok sudah dibuang oleh sed di
# atas, jadi cukup buang penandanya. JANGAN pakai rentang seperti
# '/awal/,/akhir/d': kalau penanda akhir belum ada (instalasi versi lama),
# sed menganggap rentangnya sampai AKHIR FILE dan ikut menghapus baris
# Banner yang baru ditulis. Ini pernah terjadi dan membuat banner hilang.
sed -i '/^# --- tuning untuk VPS kecil ---$/d; /^# --- end tuning ---$/d' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config <<'SSHEOF'

# --- tuning untuk VPS kecil ---
MaxStartups 50:30:200
MaxSessions 30
LoginGraceTime 60
GSSAPIAuthentication no
UseDNS no
# --- end tuning ---
SSHEOF

# Banner ditulis PALING AKHIR, setelah semua sed selesai. Dengan urutan ini
# tidak ada operasi berikutnya yang bisa menghapusnya.
sed -i '/^Banner[[:space:]]/d' /etc/ssh/sshd_config
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# Swap: VPS 1 GB RAM kehabisan memori saat banyak service jalan
# (xray + squid + nginx + stunnel + python WS). Tanpa swap sistem
# bisa macet total. Tambah 2 GB bila belum ada.
if ! swapon --show 2>/dev/null | grep -q .; then
    fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null 2>&1
    swapon /swapfile
    grep -q "^/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    sysctl -w vm.swappiness=20 >/dev/null 2>&1
    grep -q "^vm.swappiness" /etc/sysctl.conf || echo 'vm.swappiness=20' >> /etc/sysctl.conf
    echo -e "[ ${green}ok${NC} ] Swap 2 GB ditambahkan"
fi

# download script
cd /usr/bin
wget -q -O speedtest "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/speedtest_cli.py"
wget -q -O xp "https://raw.githubusercontent.com/Masbrow33/dxavier/main/ssh/xp.sh"
wget -q -O auto-set "https://raw.githubusercontent.com/Masbrow33/dxavier/main/xray/auto-set.sh"
wget -q -O jam "https://raw.githubusercontent.com/Masbrow33/dxavier/main/jam.sh"
chmod +x speedtest
chmod +x xp
chmod +x auto-set
chmod +x jam
cd

cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 7 * * * root /sbin/reboot
END

cat > /etc/cron.d/xp_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/bin/xp
END

cat > /home/re_otm <<-END
7
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1

# remove unnecessary files
sleep 1
echo -e "[ ${green}INFO$NC ] Clearing trash"
apt autoclean -y >/dev/null 2>&1

if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi

# apt-get -y --purge remove samba* >/dev/null 2>&1
# apt-get -y --purge remove apache2* >/dev/null 2>&1
# apt-get -y --purge remove bind9* >/dev/null 2>&1
# apt-get -y remove sendmail* >/dev/null 2>&1
# apt autoremove -y >/dev/null 2>&1
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
sleep 1
echo -e "$yell[SERVICE]$NC Restart All service SSH & OVPN"
/etc/init.d/nginx restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting nginx"
/etc/init.d/openvpn restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting cron "
/etc/init.d/ssh restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting ssh "
/etc/init.d/dropbear restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting dropbear "
/etc/init.d/fail2ban restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting fail2ban "
/etc/init.d/stunnel4 restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting stunnel4 "
/etc/init.d/vnstat restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting vnstat "

# ----------------------------------------------------------
#  Squid: paket di Ubuntu 24.04 bernama "squid" (bukan "squid3").
#  Script lama hanya me-restart squid tanpa pernah membuat config,
#  jadi service selalu OFFLINE. Buat config minimal yang berfungsi.
# ----------------------------------------------------------
if command -v squid >/dev/null 2>&1; then
    if [ ! -f /etc/squid/squid.conf ] || ! grep -q "autoscript-squid" /etc/squid/squid.conf 2>/dev/null; then
        cat > /etc/squid/squid.conf <<'SQEOF'
# autoscript-squid
http_port 3128
visible_hostname vpn-server
via off
forwarded_for delete

acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src 127.0.0.1/32
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localnet
http_access allow localhost
http_access deny all

coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
SQEOF
        mkdir -p /var/spool/squid
        chown -R proxy:proxy /var/spool/squid 2>/dev/null || true
        squid -z >/dev/null 2>&1 || true
    fi
    systemctl enable squid >/dev/null 2>&1 || true
    systemctl restart squid >/dev/null 2>&1 || true
    if systemctl is-active squid >/dev/null 2>&1; then
        echo -e "[ ${green}ok${NC} ] Squid aktif di port 3128"
    else
        echo -e "[ ${yellow}WARN${NC} ] Squid gagal start, cek: journalctl -u squid"
    fi
else
    echo -e "[ ${yellow}WARN${NC} ] Squid tidak terpasang (paket 'squid' tidak tersedia)"
fi

screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500
history -c
# Idempoten: jangan tambah baris berulang di /etc/profile.
grep -qxF 'unset HISTFILE' /etc/profile 2>/dev/null || echo "unset HISTFILE" >> /etc/profile


rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/bbr.sh

# finihsing
clear

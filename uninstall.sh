#!/bin/bash
# ==========================================================
#  uninstall.sh — bersihkan autoscript sebelum instal ulang
#
#  Kenapa ada: instalasi yang diulang di atas sisa instalasi lama
#  menghasilkan config bertumpuk (/etc/shells, stunnel.pem, config.json),
#  port bentrok, dan service lama yang masih memegang file. Membersihkan
#  dulu membuat hasil instalasi deterministik.
#
#  Pemakaian:
#     bash uninstall.sh            -> menu interaktif
#     bash uninstall.sh --all      -> bersihkan semuanya tanpa tanya
#     bash uninstall.sh --soft     -> hanya config, paket tetap
#     bash uninstall.sh --dry-run  -> tampilkan rencana, tidak menghapus
# ==========================================================

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

MODE="${1:-menu}"
DRY=0
[ "$MODE" = "--dry-run" ] && { DRY=1; MODE="--all"; }

if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}[ ERROR ]${NC} Jalankan sebagai root."
    exit 1
fi

# ---------------------------------------------------------------- helper
say()  { echo -e "  $*"; }
ok()   { echo -e "  ${GREEN}[ OK ]${NC} $*"; }
warn() { echo -e "  ${YELLOW}[ !! ]${NC} $*"; }

run() {
    # jalankan perintah, atau cetak saja kalau --dry-run
    if [ "$DRY" = "1" ]; then
        echo -e "  ${CYAN}[dry]${NC} $*"
        return 0
    fi
    eval "$@" >/dev/null 2>&1 || true
}

header() {
    clear 2>/dev/null || true
    # Lebar dalam kotak 49 kolom, sama dengan menu lain. Padding dihitung,
    # bukan diketik manual, supaya dinding kanan selalu lurus.
    local W=49 line
    echo ""
    printf '%s┌%s┐%s\n' "$CYAN" "$(printf '─%.0s' $(seq 1 $W))" "$NC"
    for line in "EKO BELLICK PREMIUM" "UNINSTALL / BERSIHKAN"; do
        local n=${#line} l r
        l=$(( (W - n) / 2 )); r=$(( W - n - l ))
        printf '%s│%s%*s%s%*s%s│%s\n' "$CYAN" "$NC" "$l" '' "$line" "$r" '' "$CYAN" "$NC"
    done
    printf '%s└%s┘%s\n' "$CYAN" "$(printf '─%.0s' $(seq 1 $W))" "$NC"
    echo ""
}

# ---------------------------------------------------------------- langkah
stop_services() {
    echo -e "${YELLOW}[1] Hentikan layanan${NC}"
    local units="xray nginx dropbear stunnel4 squid fail2ban vnstat chrony
        ws-dropbear ws-openssh ws-stunnel ws-ssh sshws
        badvpn runn sldns-client slowdns"
    for u in $units; do
        if systemctl list-unit-files 2>/dev/null | grep -q "^${u}\.service"; then
            run "systemctl stop ${u} 2>/dev/null"
            run "systemctl disable ${u} 2>/dev/null"
            say "  $u dihentikan"
        fi
    done
    # ssh jangan dimatikan: kita sedang masuk lewat situ
    warn "SSH sengaja TIDAK dihentikan (koneksi Anda lewat SSH)"
    # screen badvpn / setup
    # Hanya sesi milik autoscript. Jangan sentuh sesi lain milik user
    # (misalnya sesi tempat uninstall ini dijalankan).
    for name in setup badvpn slowdns sldns sshws; do
        screen -ls 2>/dev/null | grep -qE "[.]${name}[[:space:]]" || continue
        run "screen -S ${name} -X quit"
        say "  screen '$name' ditutup"
    done
    echo ""
}

remove_files() {
    echo -e "${YELLOW}[2] Hapus file konfigurasi${NC}"
    local paths="/etc/xray /etc/yokkovpn /etc/v2ray /usr/local/etc/xray
        /var/log/xray /usr/local/lib/vpsbox.sh
        /home/vps/public_html/akun /home/vps/public_html/ss-ws
        /home/vps/public_html/clash-ws
        /usr/local/bin/xray /usr/bin/xray
        /usr/local/bin/ws-dropbear /usr/local/bin/ws-openssh /usr/local/bin/ws-stunnel
        /usr/bin/ssh-wsenabler /usr/bin/proxy3.js /usr/bin/bbt
        /usr/local/bin/sldns-client /usr/local/bin/badvpn-udpgw
        /root/log-install.txt /root/domain /root/scdomain /root/ipvps
        /var/lib/yokkovpn-pro /var/lib/vnstat"
    for p in $paths; do
        [ -e "$p" ] || continue
        run "rm -rf $p"
        say "  $p"
    done
    # menu
    for m in /usr/bin/menu /usr/bin/menu-*; do
        [ -e "$m" ] || continue
        run "rm -f $m"
    done
    say "  /usr/bin/menu*"
    echo ""
}

restore_shells() {
    echo -e "${YELLOW}[3] Bersihkan /etc/shells${NC}"
    if [ -f /etc/shells ]; then
        if [ "$DRY" = "1" ]; then
            echo -e "  ${CYAN}[dry]${NC} hapus /bin/false dan nologin dari /etc/shells"
        else
            grep -vE '^(/bin/false|/usr/sbin/nologin)$' /etc/shells > /tmp/.shells.$$ 2>/dev/null
            [ -s /tmp/.shells.$$ ] && mv /tmp/.shells.$$ /etc/shells
            rm -f /tmp/.shells.$$
            ok "duplikat dibersihkan ($(wc -l < /etc/shells) baris)"
        fi
    fi
    echo ""
}

remove_profile() {
    echo -e "${YELLOW}[4] Kembalikan /root/.profile${NC}"
    if [ -f /root/.profile ]; then
        if [ "$DRY" = "1" ]; then
            echo -e "  ${CYAN}[dry]${NC} buang baris 'menu' dari /root/.profile"
        else
            grep -vE '^\s*(menu|clear)\s*$' /root/.profile > /tmp/.prof.$$ 2>/dev/null
            mv /tmp/.prof.$$ /root/.profile
            chmod 644 /root/.profile
            ok "baris menu dihapus"
        fi
    fi
    echo ""
}

remove_packages() {
    echo -e "${YELLOW}[6] Hapus paket autoscript${NC}"
    local pkgs="stunnel4 dropbear fail2ban squid vnstat openvpn easy-rsa
        badvpn xl2tpd pptpd libpam0g-dev libcap-ng-dev"
    local list=""
    for p in $pkgs; do
        dpkg -s "$p" >/dev/null 2>&1 && list="$list $p"
    done
    if [ -z "$list" ]; then
        say "  tidak ada paket yang perlu dihapus"
    else
        if [ "$DRY" = "1" ]; then
            echo -e "  ${CYAN}[dry]${NC} apt-get remove --purge -y$list"
        else
            DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y $list >/dev/null 2>&1 || true
            ok "dihapus:$list"
        fi
    fi
    echo ""
}

remove_users() {
    echo -e "${YELLOW}[7] Hapus user autoscript${NC}"
    local n=0
    for u in xray vnstat proxy; do
        if id "$u" >/dev/null 2>&1; then
            run "userdel -r $u 2>/dev/null || userdel $u 2>/dev/null"
            say "  user $u"
            n=$((n+1))
        fi
    done
    [ "$n" -eq 0 ] && say "  tidak ada user khusus autoscript"
    echo ""
}

remove_nginx() {
    echo -e "${YELLOW}[5] Bersihkan konfigurasi nginx${NC}"
    for f in /etc/nginx/conf.d/xray.conf /etc/nginx/conf.d/vps.conf \
             /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default; do
        [ -e "$f" ] || continue
        run "rm -f $f"
        say "  $f"
    done
    if [ "$DRY" = "0" ] && command -v nginx >/dev/null 2>&1; then
        nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1
    fi
    echo ""
}

remove_firewall() {
    echo -e "${YELLOW}[8] Bersihkan aturan iptables autoscript${NC}"
    if [ "$DRY" = "1" ]; then
        echo -e "  ${CYAN}[dry]${NC} flush aturan autoscript"
    else
        iptables -t nat -F PREROUTING >/dev/null 2>&1 || true
        iptables -F >/dev/null 2>&1 || true
        ok "aturan di-flush"
    fi
    echo ""
}

summary() {
    echo -e "${CYAN}─────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}[ SELESAI ]${NC} Pembersihan selesai."
    echo ""
    echo "  Instal ulang dari awal:"
    echo -e "    ${CYAN}cd /root${NC}"
    echo -e "    ${CYAN}rm -f setup.sh${NC}"
    echo -e "    ${CYAN}wget -O setup.sh https://raw.githubusercontent.com/Masbrow33/btr/main/setup.sh${NC}"
    echo -e "    ${CYAN}chmod +x setup.sh && ./setup.sh${NC}"
    echo ""
    echo "  Catatan: SSH tidak disentuh, jadi koneksi Anda tetap aman."
    echo ""
}

# ---------------------------------------------------------------- alur
case "$MODE" in
    --all)
        header
        echo -e "${RED}Mode: BERSIHKAN SEMUA${NC} (config + paket + user)"
        [ "$DRY" = "1" ] && echo -e "${CYAN}Mode: DRY-RUN (tidak ada yang dihapus)${NC}"
        echo ""
        stop_services
        remove_files
        restore_shells
        remove_profile
        remove_nginx
        remove_packages
        remove_users
        remove_firewall
        summary
        ;;
    --soft)
        header
        echo -e "${YELLOW}Mode: HANYA CONFIG${NC} (paket tetap terpasang)"
        echo ""
        stop_services
        remove_files
        restore_shells
        remove_profile
        remove_nginx
        summary
        ;;
    *)
        header
        echo "  Pilih yang akan dibersihkan:"
        echo ""
        echo -e "   ${GREEN}01${NC}) Bersihkan SEMUA  (config + paket + user)"
        echo -e "   ${GREEN}02${NC}) Hanya config     (paket tetap, instal ulang cepat)"
        echo -e "   ${GREEN}03${NC}) Lihat rencana    (dry-run, tidak menghapus)"
        echo -e "   ${GREEN}00${NC}) Batal"
        echo ""
        printf '  Pilihan : '
        read -r opt
        echo ""
        case "$opt" in
            01|1)  exec bash "$0" --all ;;
            02|2)  exec bash "$0" --soft ;;
            03|3)  exec bash "$0" --dry-run ;;
            *)     echo "  Dibatalkan."; exit 0 ;;
        esac
        ;;
esac

#!/bin/bash
# ==========================================================
#  update.sh — perbarui seluruh menu & library dari repo
#
#  Kenapa ditulis ulang: versi lama memakai
#      wget -q -O /usr/bin/menu <url>
#  langsung ke file tujuan. Bila unduhan gagal (jaringan putus,
#  GitHub lambat, DNS bermasalah), wget sudah MENIMPA file lama
#  dengan berkas kosong sebelum menyadari gagal. Hasilnya menu yang
#  tadinya berfungsi langsung rusak, dan tidak bisa dipulihkan dari
#  mesin itu sendiri karena menu untuk memperbaikinya juga rusak.
#
#  Versi ini mengunduh ke berkas sementara, memeriksa bahwa isinya
#  tidak kosong dan sintaksnya sah, baru memindahkannya menimpa yang
#  lama. Bila satu berkas gagal, berkas lama dibiarkan utuh.
# ==========================================================

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

RAW="https://raw.githubusercontent.com/Masbrow33/btr/main"
TMP=$(mktemp -d /tmp/upd.XXXXXX) || { echo "Gagal membuat direktori sementara"; exit 1; }
trap 'rm -rf "$TMP"' EXIT

OK=0
GAGAL=0
GAGAL_LIST=""

# ---------------------------------------------------------------- pengunduh aman
aman_ambil() {
    local path="$1" tujuan="$2" jenis="${3:-sh}"
    local tmpf="$TMP/$(basename "$tujuan")"
    local nama
    nama=$(basename "$tujuan")

    rm -f "$tmpf"

    if ! wget -q --timeout=20 --tries=2 -O "$tmpf" "$RAW/$path"; then
        printf '  %s[GAGAL]%s %-14s unduhan gagal\n' "$RED" "$NC" "$nama"
        GAGAL=$((GAGAL + 1)); GAGAL_LIST="$GAGAL_LIST $nama"
        return 1
    fi

    # Berkas kosong berarti wget melaporkan berhasil tetapi isinya tidak ada.
    if [ ! -s "$tmpf" ]; then
        printf '  %s[GAGAL]%s %-14s berkas kosong\n' "$RED" "$NC" "$nama"
        GAGAL=$((GAGAL + 1)); GAGAL_LIST="$GAGAL_LIST $nama"
        return 1
    fi

    # Berkas .sh wajib lolos pemeriksaan sintaks. Ini yang menangkap
    # unduhan terpotong — jauh lebih baik gagal di sini daripada
    # meninggalkan menu yang tidak bisa dijalankan.
    if [ "$jenis" = "sh" ] && ! bash -n "$tmpf" 2>/dev/null; then
        printf '  %s[GAGAL]%s %-14s sintaks rusak\n' "$RED" "$NC" "$nama"
        GAGAL=$((GAGAL + 1)); GAGAL_LIST="$GAGAL_LIST $nama"
        return 1
    fi

    mkdir -p "$(dirname "$tujuan")"
    if mv -f "$tmpf" "$tujuan"; then
        [ "$jenis" = "sh" ] && chmod +x "$tujuan"
        printf '  %s[ ok ]%s %-14s %s byte\n' "$GREEN" "$NC" "$nama" "$(stat -c%s "$tujuan")"
        OK=$((OK + 1))
        return 0
    fi

    printf '  %s[GAGAL]%s %-14s tidak bisa menulis\n' "$RED" "$NC" "$nama"
    GAGAL=$((GAGAL + 1)); GAGAL_LIST="$GAGAL_LIST $nama"
    return 1
}

clear 2>/dev/null || true
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               \033[1mUPDATE SCRIPT\033[0m                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""

# ---------------------------------------------------------------- library dulu
# Wajib paling awal: seluruh menu memanggil _box_top/_bline/_bmenu2 dari
# berkas ini. Tanpa library, menu error "command not found".
echo -e "  ${YELLOW}[1/3]${NC} Library"
aman_ambil "lib/vpsbox.sh" "/usr/local/lib/vpsbox.sh"

# ---------------------------------------------------------------- menu
echo ""
echo -e "  ${YELLOW}[2/3]${NC} Menu"
for m in menu menu-ss menu-vmess menu-vless menu-trojan menu-bot menu-ssh \
         menu-set menu-theme menu-backup menu-ip menu-tor menu-tcp menu-dns; do
    aman_ambil "update/$m.sh" "/usr/bin/$m"
done

# Nama berkas di repo berbeda dari nama perintah yang dipasang.
aman_ambil "update/menu-speedtest.sh" "/usr/bin/mspeed"
aman_ambil "update/menu-bandwith.sh"  "/usr/bin/mbandwith"

# ---------------------------------------------------------------- pendukung
echo ""
echo -e "  ${YELLOW}[3/3]${NC} Pendukung"
aman_ambil "update/autoboot.sh" "/usr/bin/autoboot"
aman_ambil "update/info.sh"     "/usr/bin/info"
aman_ambil "corn/rebootvps.sh"  "/usr/bin/rebootvps"

# ---------------------------------------------------------------- ringkasan
echo ""
echo -e "  ${CYAN}─────────────────────────────────────────────────${NC}"
if [ "$GAGAL" -eq 0 ]; then
    echo -e "  ${GREEN}[ SELESAI ]${NC} $OK berkas diperbarui."
else
    echo -e "  ${RED}[ PERHATIAN ]${NC} $OK berhasil, $GAGAL gagal."
    echo "  Berkas yang gagal tetap memakai versi lama, jadi tidak ada yang rusak:"
    for f in $GAGAL_LIST; do echo "    - $f"; done
    echo ""
    echo "  Periksa koneksi lalu jalankan ulang update dari menu."
fi
echo ""
printf '  Tekan ENTER untuk kembali... '
read -r
clear 2>/dev/null || true

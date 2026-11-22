#!/bin/bash
# ============================================================
#  EKO BELLICK PREMIUM — shared box renderer
#  Dipakai oleh semua script menu (menu, menu-*).
#  Lebar dalam kotak = 49 kolom (total 51 termasuk border).
#
#  Kenapa ada file ini: sebelumnya setiap menu menggambar kotak
#  sendiri dengan "echo -e", dan 285 baris di 10 menu dibuka
#  dengan │ tetapi TIDAK ditutup │ — dinding kanan hilang
#  sehingga kotak terlihat berantakan. Semua penggambaran kotak
#  sekarang lewat fungsi di sini supaya lebarnya konsisten.
# ============================================================

VPSBOX_W=49

# konversi escape literal (\033.. / \e[..) jadi escape asli
vpsbox_init() {
    COLOR1=$(printf '%b' "${COLOR1:-}")
    COLBG1=$(printf '%b' "${COLBG1:-}")
    NC=$(printf '%b' "${NC:-}")
    RED=$(printf '%b' "${RED:-}")
    GREEN=$(printf '%b' "${GREEN:-}")
    YELLOW=$(printf '%b' "${YELLOW:-}")
    CYAN=$(printf '%b' "${CYAN:-}")
    red=$(printf '%b' "${red:-}")
    green=$(printf '%b' "${green:-}")
}

# panjang teks setelah ANSI dibuang — WAJIB hitung KARAKTER, bukan byte.
# awk length menghitung byte, sehingga "•" dan "│" (3 byte) dianggap 3
# kolom padahal hanya 1 — padding jadi meleset dan kotak tidak lurus.
_vlen() {
    printf '%s' "$1" \
        | sed 's/\x1b\[[0-9;]*[A-Za-z]//g; s/\\e\[[0-9;]*m//g' \
        | tr -d '\n' | wc -m | tr -d ' '
}
_dashes() { printf '─%.0s' $(seq 1 "$1"); }

# potong teks agar tidak melebihi lebar kotak (mencegah border meluber)
_vclip() {
    local t="$1" max="$2" w
    w=$(_vlen "$t")
    [ "$w" -le "$max" ] && { printf '%s' "$t"; return; }
    # potong berdasarkan karakter, ANSI diabaikan
    printf '%s' "$t" | sed 's/\x1b\[[0-9;]*[A-Za-z]//g' | cut -c1-"$max"
}

_box_top() { printf '%s┌%s┐%s\n' "$COLOR1" "$(_dashes $VPSBOX_W)" "$NC"; }
_box_bot() { printf '%s└%s┘%s\n' "$COLOR1" "$(_dashes $VPSBOX_W)" "$NC"; }
_box_mid() { printf '%s├%s┤%s\n' "$COLOR1" "$(_dashes $VPSBOX_W)" "$NC"; }

# isi rata kiri
_bline() {
    local t w pad
    t=$(_vclip "$1" $(( VPSBOX_W - 1 )))
    w=$(_vlen "$t"); pad=$(( VPSBOX_W - 1 - w )); [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$t"; printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}

# judul rata tengah
_bcenter() {
    local t w l r
    t=$(_vclip "$1" "$VPSBOX_W")
    w=$(_vlen "$t")
    l=$(( (VPSBOX_W - w) / 2 )); [ "$l" -lt 0 ] && l=0
    r=$(( VPSBOX_W - w - l ));    [ "$r" -lt 0 ] && r=0
    printf '%s│%s' "$COLOR1" "$NC"; printf '%*s' "$l" ''; printf '%s' "$t"
    printf '%*s' "$r" ''; printf '%s│%s\n' "$COLOR1" "$NC"
}

# dua kolom menu
_bmenu2() {
    local n1="$1" l1="$2" n2="$3" l2="$4"
    local left right wl wr gap
    left="${COLOR1}[${n1}]${NC} $(printf '%-16s' "$l1")"
    right="${COLOR1}[${n2}]${NC} ${l2}"
    wl=$(_vlen "$left"); wr=$(_vlen "$right")
    gap=$(( VPSBOX_W - 2 - wl - wr )); [ "$gap" -lt 1 ] && gap=1
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"; printf '%*s' "$gap" ''
    printf '%s %s│%s\n' "$right" "$COLOR1" "$NC"
}

# satu kolom menu
_bmenu1() {
    local n="$1" l="$2" left wl pad
    left="${COLOR1}[${n}]${NC} ${l}"
    wl=$(_vlen "$left"); pad=$(( VPSBOX_W - 1 - wl )); [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s' "$COLOR1" "$NC" "$left"; printf '%*s' "$pad" ''
    printf '%s│%s\n' "$COLOR1" "$NC"
}

# baris status label + nilai (nilai rata kanan)
_bstat() {
    local lbl="$1" val="$2" wl wv gap
    val=$(_vclip "$val" $(( VPSBOX_W / 2 )))
    wl=$(_vlen "  • $lbl"); wv=$(_vlen "$val")
    # gap = W - 1 - wl - wv  (bukan W-2): total baris harus 51
    gap=$(( VPSBOX_W - 1 - wl - wv )); [ "$gap" -lt 1 ] && gap=1
    printf '%s│%s  • %s' "$COLOR1" "$NC" "$lbl"
    printf '%*s' "$gap" ''; printf '%s %s│%s\n' "$val" "$COLOR1" "$NC"
}

# footer BY
_byline() {
    printf '%s┌%s BY %s┐%s\n' "$COLOR1" "$(_dashes 22)" "$(_dashes 23)" "$NC"
    _bcenter "${GREEN}• EKO BELLICK PREMIUM •${NC}"
    _box_bot
}

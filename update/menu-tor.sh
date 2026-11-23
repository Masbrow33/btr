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
# menu-tor.sh — wrapper kompatibilitas
# update.sh mengunduh file ini ke /usr/bin/menu-tor.
# Fungsinya sama dengan menu-trojan, jadi cukup diteruskan.
exec menu-trojan "$@"

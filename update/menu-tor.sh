#!/bin/bash
# menu-tor.sh — wrapper kompatibilitas
# update.sh mengunduh file ini ke /usr/bin/menu-tor.
# Fungsinya sama dengan menu-trojan, jadi cukup diteruskan.
exec menu-trojan "$@"

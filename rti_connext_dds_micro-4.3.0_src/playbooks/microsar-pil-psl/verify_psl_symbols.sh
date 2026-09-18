#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET="i86leElfgcc13.3.0-MICROSAR4"
CONFIG="${1:-Debug}"
if [[ "$CONFIG" == "Debug" ]]; then
    archive_suffix="zd"
else
    archive_suffix="z"
fi
ARCHIVE="${2:-$ROOT_DIR/lib/$TARGET/librti_me_netiopsl${archive_suffix}.a}"
OBJECT_ROOT="${3:-$ROOT_DIR/build/cmake/$CONFIG/$TARGET}"

[[ -f "$ARCHIVE" ]] || { echo "[ERROR] Missing PSL archive: $ARCHIVE" >&2; exit 1; }

object_path=$(find "$OBJECT_ROOT" -type f \( -name 'autosarSocket.o' -o -name 'autosarSocket.c.o' \) -print -quit)
[[ -n "$object_path" ]] || { echo "[ERROR] autosarSocket object not found under $OBJECT_ROOT" >&2; exit 1; }

object_name="$(basename "$object_path")"
ar t "$ARCHIVE" | grep -Fx "$object_name" >/dev/null || {
    echo "[ERROR] $object_name is not present in $ARCHIVE" >&2
    exit 1
}

symbols=$(nm --defined-only "$object_path")
for symbol in \
    NETIO_Autosar_TcpIp_udp_rx_indication \
    NETIO_Autosar_on_ip_assigned \
    NETIO_Autosar_on_socket_event; do
    grep -Eq "[[:space:]]${symbol}$" <<<"$symbols" || {
        echo "[ERROR] Missing required symbol: $symbol" >&2
        exit 1
    }
    echo "[OK] Symbol present: $symbol"
done

echo "[OK] PSL ELF symbol verification passed."
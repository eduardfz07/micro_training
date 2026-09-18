#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIL_TARGET="i86leElfgcc13.3.0"
PSL_TARGET="${PIL_TARGET}-MICROSAR4"
MODE="all"
CONFIG="Debug"
VERIFY="verify"

usage() {
    cat <<EOF
Usage: $(basename "$0") [all|pil|psl] [Debug|Release] [verify|noverify]
       $(basename "$0") MODE=all|pil|psl CONFIG=Debug|Release VERIFY=verify|noverify
EOF
}

position=0
for argument in "$@"; do
    case "$argument" in
        MODE=*) MODE="${argument#MODE=}" ;;
        CONFIG=*) CONFIG="${argument#CONFIG=}" ;;
        VERIFY=*) VERIFY="${argument#VERIFY=}" ;;
        -h|--help) usage; exit 0 ;;
        *)
            case "$position" in
                0) MODE="$argument" ;;
                1) CONFIG="$argument" ;;
                2) VERIFY="$argument" ;;
                *) echo "[ERROR] Too many arguments: $argument" >&2; usage; exit 2 ;;
            esac
            position=$((position + 1))
            ;;
    esac
done

MODE="${MODE,,}"
VERIFY="${VERIFY,,}"
case "${CONFIG,,}" in
    debug) CONFIG="Debug" ;;
    release) CONFIG="Release" ;;
esac

[[ "$MODE" =~ ^(all|pil|psl)$ ]] || { echo "[ERROR] Invalid mode: $MODE" >&2; usage; exit 2; }
[[ "$CONFIG" =~ ^(Debug|Release)$ ]] || { echo "[ERROR] Invalid config: $CONFIG" >&2; usage; exit 2; }
[[ "$VERIFY" =~ ^(verify|noverify)$ ]] || { echo "[ERROR] Invalid verification mode: $VERIFY" >&2; usage; exit 2; }

for command in cmake gcc-13 g++-13 ar nm; do
    command -v "$command" >/dev/null || { echo "[ERROR] Required command not found: $command" >&2; exit 1; }
done

if [[ "$MODE" != "pil" ]]; then
    [[ -n "${OSEK_PATH:-}" ]] || { echo "[ERROR] OSEK_PATH must point to the MICROSAR SIP root." >&2; exit 1; }
    [[ -d "$OSEK_PATH" ]] || { echo "[ERROR] OSEK_PATH does not exist: $OSEK_PATH" >&2; exit 1; }
fi

export RTIMEHOME="$SCRIPT_DIR"
export NDDSHOME="$SCRIPT_DIR"
export RTIME_DIST="$SCRIPT_DIR"
export PATH="$SCRIPT_DIR/bin:$SCRIPT_DIR/resource/scripts:$PATH"

build_target() {
    local target="$1"
    export RTIMEARCH="$target"

    echo "[INFO] Building $target ($CONFIG)"
    bash "$SCRIPT_DIR/resource/scripts/rtime-make" \
        --config "$CONFIG" \
        --build \
        --delete \
        --target "$target" \
        --name "$target" \
        -G "Unix Makefiles" \
        -DRTIME_EXCLUDE_CPP=TRUE \
        -DRTI_BUILD_UNITTESTS=FALSE

    local build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$target"
    local output_dir="$SCRIPT_DIR/lib/$target"
    mkdir -p "$output_dir"
    find "$build_dir" -maxdepth 2 -type f -name '*.a' -exec cp -f {} "$output_dir/" \;
    compgen -G "$output_dir/*.a" >/dev/null || { echo "[ERROR] No archives produced for $target" >&2; exit 1; }
}

verify_archives() {
    local target="$1"
    local output_dir="$SCRIPT_DIR/lib/$target"
    local count
    count=$(find "$output_dir" -maxdepth 1 -type f -name '*.a' | wc -l)
    [[ "$count" -gt 0 ]] || { echo "[ERROR] No archives found in $output_dir" >&2; exit 1; }
    echo "[OK] Found $count archive(s) in $output_dir"
}

if [[ "$MODE" == "all" || "$MODE" == "pil" ]]; then
    build_target "$PIL_TARGET"
fi
if [[ "$MODE" == "all" || "$MODE" == "psl" ]]; then
    build_target "$PSL_TARGET"
fi

if [[ "$VERIFY" == "verify" ]]; then
    if [[ "$MODE" == "all" || "$MODE" == "pil" ]]; then
        verify_archives "$PIL_TARGET"
    fi
    if [[ "$MODE" == "all" || "$MODE" == "psl" ]]; then
        verify_archives "$PSL_TARGET"
        "$SCRIPT_DIR/playbooks/microsar-pil-psl/verify_psl_symbols.sh" "$CONFIG"
    fi
fi

echo "[OK] Linux MICROSAR build completed."
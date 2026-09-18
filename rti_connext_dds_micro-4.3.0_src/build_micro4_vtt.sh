#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIL_TARGET="x86_64leElfgcc13.3.0"
PSL_TARGET="${PIL_TARGET}-MICROSAR4"
MODE="all"
CONFIG="Debug"
VERIFY="verify"
PIL_DELIVERY_PREFIXES=(
    librti_me_appgen
    librti_me_ddsfilter
    librti_me_ddsxtypes
    librti_me_discdpde
    librti_me_discdpse
    librti_me_netiosdm
    librti_me_netioshmem
    librti_me_netiozcopy
    librti_me_rhsm
    librti_me_whsm
    librti_me
)
PSL_DELIVERY_PREFIXES=(
    librti_me_netiopsl
    librti_me_ospsl
    librti_me_rti_me_psl
)

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

for command in cmake gcc-13 g++-13 ar file nm; do
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

}

archive_suffix() {
    if [[ "$CONFIG" == "Debug" ]]; then
        printf 'zd'
    else
        printf 'z'
    fi
}

sync_pil_archives() {
    local suffix
    suffix="$(archive_suffix)"
    local build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$PIL_TARGET"
    local output_dir="$SCRIPT_DIR/lib/$PIL_TARGET"

    mkdir -p "$output_dir"
    find "$output_dir" -maxdepth 1 -type f -name "*${suffix}.a" -delete
    find "$build_dir" -maxdepth 1 -type f -name "*${suffix}.a" -exec cp -f {} "$output_dir/" \;
    compgen -G "$output_dir/*${suffix}.a" >/dev/null || {
        echo "[ERROR] No PIL archives produced for $CONFIG" >&2
        exit 1
    }
}

sync_microsar_archives() {
    local suffix
    suffix="$(archive_suffix)"
    local pil_build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$PIL_TARGET"
    local psl_build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$PSL_TARGET"
    local output_dir="$SCRIPT_DIR/lib/$PSL_TARGET"
    local archive_name archive_prefix

    mkdir -p "$output_dir"
    find "$output_dir" -maxdepth 1 -type f -name "*${suffix}.a" -delete

    for archive_prefix in "${PIL_DELIVERY_PREFIXES[@]}"; do
        archive_name="${archive_prefix}${suffix}.a"
        [[ -f "$pil_build_dir/$archive_name" ]] || {
            echo "[ERROR] Missing PIL archive: $pil_build_dir/$archive_name" >&2
            exit 1
        }
        cp -f "$pil_build_dir/$archive_name" "$output_dir/"
    done

    for archive_prefix in "${PSL_DELIVERY_PREFIXES[@]}"; do
        archive_name="${archive_prefix}${suffix}.a"
        [[ -f "$psl_build_dir/$archive_name" ]] || {
            echo "[ERROR] Missing MICROSAR archive: $psl_build_dir/$archive_name" >&2
            exit 1
        }
        cp -f "$psl_build_dir/$archive_name" "$output_dir/"
    done
}

verify_archives() {
    local target="$1"
    local expected_count="$2"
    local output_dir="$SCRIPT_DIR/lib/$target"
    local suffix count archive member format
    suffix="$(archive_suffix)"
    count=$(find "$output_dir" -maxdepth 1 -type f -name "*${suffix}.a" | wc -l)
    [[ "$count" -eq "$expected_count" ]] || {
        echo "[ERROR] Expected $expected_count archives in $output_dir, found $count" >&2
        exit 1
    }

    for archive in "$output_dir"/*"${suffix}.a"; do
        member="$(ar t "$archive" | head -n 1)"
        [[ -n "$member" ]] || { echo "[ERROR] Empty archive: $archive" >&2; exit 1; }
        format="$(ar p "$archive" "$member" | file -b -)"
        [[ "$format" == *"ELF 64-bit"* && "$format" == *"x86-64"* ]] || {
            echo "[ERROR] Archive is not ELF64 x86-64: $archive ($format)" >&2
            exit 1
        }
    done

    echo "[OK] Found $count ELF64 x86-64 archive(s) in $output_dir"
}

verify_pic_flags() {
    local target="$1"
    local flags_root="$SCRIPT_DIR/build/cmake/$CONFIG/$target/CMakeFiles"

    grep -R --include='flags.make' -q -- '-fPIC' "$flags_root" || {
        echo "[ERROR] -fPIC not found in $target compile flags" >&2
        exit 1
    }
    if grep -R --include='flags.make' -q -- '-m32' "$flags_root"; then
        echo "[ERROR] Unexpected -m32 found in $target compile flags" >&2
        exit 1
    fi
}

verify_no_realloc_dependency() {
    local target="$1"
    local suffix archive
    suffix="$(archive_suffix)"
    archive="$SCRIPT_DIR/lib/$target/librti_me${suffix}.a"

    [[ -f "$archive" ]] || { echo "[ERROR] Missing core archive: $archive" >&2; exit 1; }
    if nm -u "$archive" | grep -qi realloc; then
        echo "[ERROR] Realloc dependency found in $archive" >&2
        nm -u "$archive" | grep -i realloc >&2
        exit 1
    fi

    echo "[OK] No realloc dependency in $archive"
}

verify_microsar_sources() {
    local suffix archive_name
    suffix="$(archive_suffix)"
    local output_dir="$SCRIPT_DIR/lib/$PSL_TARGET"
    local pil_build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$PIL_TARGET"
    local psl_build_dir="$SCRIPT_DIR/build/cmake/$CONFIG/$PSL_TARGET"

    for archive_name in \
        "librti_me_netiopsl${suffix}.a" \
        "librti_me_ospsl${suffix}.a" \
        "librti_me_rti_me_psl${suffix}.a"; do
        cmp -s "$output_dir/$archive_name" "$psl_build_dir/$archive_name" || {
            echo "[ERROR] $archive_name is not the MICROSAR4 variant" >&2
            exit 1
        }
        if cmp -s "$output_dir/$archive_name" "$pil_build_dir/$archive_name"; then
            echo "[ERROR] $archive_name matches the generic PIL variant" >&2
            exit 1
        fi
    done
}

if [[ "$MODE" == "all" || "$MODE" == "pil" || "$MODE" == "psl" ]]; then
    build_target "$PIL_TARGET"
fi
if [[ "$MODE" == "all" || "$MODE" == "pil" ]]; then
    sync_pil_archives
fi
if [[ "$MODE" == "all" || "$MODE" == "psl" ]]; then
    build_target "$PSL_TARGET"
    sync_microsar_archives
fi

if [[ "$VERIFY" == "verify" ]]; then
    if [[ "$MODE" == "all" || "$MODE" == "pil" ]]; then
        verify_archives "$PIL_TARGET" 14
        verify_pic_flags "$PIL_TARGET"
        verify_no_realloc_dependency "$PIL_TARGET"
    fi
    if [[ "$MODE" == "all" || "$MODE" == "psl" ]]; then
        verify_archives "$PSL_TARGET" 14
        verify_pic_flags "$PSL_TARGET"
        verify_microsar_sources
        verify_no_realloc_dependency "$PSL_TARGET"
        "$SCRIPT_DIR/playbooks/microsar-pil-psl/verify_psl_symbols.sh" "$CONFIG"
    fi
fi

echo "[OK] Linux MICROSAR build completed."
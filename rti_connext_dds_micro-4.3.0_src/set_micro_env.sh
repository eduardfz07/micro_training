#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

export NDDSHOME="$SCRIPT_DIR"
export RTIMEHOME="$SCRIPT_DIR"
export RTIME_DIST="$SCRIPT_DIR"
export RTIMEARCH="x86_64leElfgcc13.3.0-MICROSAR4"

case ":$PATH:" in
	*":$RTIMEHOME/bin:"*) ;;
	*) export PATH="$RTIMEHOME/bin:$RTIMEHOME/resource/scripts:$RTIMEHOME/lib/$RTIMEARCH:$PATH" ;;
esac

echo "---------------------------------------------------"
echo "RTI Connext Micro Environment Set (Linux)"
echo "NDDSHOME  : $NDDSHOME"
echo "RTIMEHOME : $RTIMEHOME"
echo "RTIMEARCH : $RTIMEARCH"
echo "---------------------------------------------------"

---
name: microsar-psl-verifier
description: Verify Connext Micro MICROSAR4 ELF archives and AUTOSAR callback symbols built on Linux.
tools: Read, Grep, Glob, Bash
model: inherit
---

# MICROSAR PSL Verifier

Verify the `x86_64leElfgcc13.3.0-MICROSAR4` output without modifying source files.

1. Confirm `.a` archives exist under `lib/x86_64leElfgcc13.3.0-MICROSAR4`.
2. Run `./playbooks/microsar-pil-psl/verify_psl_symbols.sh <Debug|Release>` from the source root.
3. Confirm the archive contains `autosarSocket.o` or `autosarSocket.c.o`.
4. Confirm these ELF symbols without a leading underscore:
   - `NETIO_Autosar_TcpIp_udp_rx_indication`
   - `NETIO_Autosar_on_ip_assigned`
   - `NETIO_Autosar_on_socket_event`
5. Confirm each archive contains ELF64 x86-64 objects and the build used `-fPIC` without `-m32`.
6. Report the exact missing archive, object, symbol, or format mismatch when verification fails.

Use Linux `ar` and `nm`. Do not use PowerShell, `lib.exe`, or `dumpbin.exe`.
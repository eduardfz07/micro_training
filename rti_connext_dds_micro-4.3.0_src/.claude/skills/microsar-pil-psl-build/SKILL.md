---
name: microsar-pil-psl-build
description: "Use when building or verifying 32-bit Connext Micro PIL and MICROSAR4 PSL archives on Linux with GCC 13.3.0."
---

# Linux MICROSAR PIL/PSL Build

Run commands from the source root.

1. Confirm `gcc-13`, `g++-13`, `ar`, `nm`, CMake, and 32-bit multilib support are available.
2. For PSL builds, confirm `OSEK_PATH` points to the MICROSAR SIP root.
3. Run `./build_micro4_vtt.sh pil|psl|all Debug|Release verify|noverify`.
4. Confirm archives under `lib/i86leElfgcc13.3.0` and `lib/i86leElfgcc13.3.0-MICROSAR4`.
5. For PSL builds, run `./playbooks/microsar-pil-psl/verify_psl_symbols.sh <Config>`.

Do not use Visual Studio, MSVC, Windows batch scripts, PowerShell, `lib.exe`, or `dumpbin.exe` for this workflow.
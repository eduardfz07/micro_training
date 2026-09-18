---
name: microsar-pil-psl-build
description: "Use when building or verifying ELF64 x86-64 Connext Micro PIL and MICROSAR4 PSL archives on Linux with GCC 13.3.0."
---

# Linux MICROSAR PIL/PSL Build

Run commands from the source root.

1. Confirm `gcc-13`, `g++-13`, `ar`, `file`, `nm`, and CMake are available.
2. For PSL builds, confirm `OSEK_PATH` points to the MICROSAR SIP root.
3. Run `./build_micro4_vtt.sh pil|psl|all Debug|Release verify|noverify`.
4. Confirm archives under `lib/x86_64leElfgcc13.3.0` and `lib/x86_64leElfgcc13.3.0-MICROSAR4`.
5. Confirm all delivered objects are ELF64 x86-64 and compile flags contain `-fPIC` but not `-m32`.
6. For PSL builds, run `./playbooks/microsar-pil-psl/verify_psl_symbols.sh <Config>`.

Do not use Visual Studio, MSVC, Windows batch scripts, PowerShell, `lib.exe`, or `dumpbin.exe` for this workflow.
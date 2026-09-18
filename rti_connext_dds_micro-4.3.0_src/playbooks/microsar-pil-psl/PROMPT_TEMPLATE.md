# Linux MICROSAR Build Prompt

Build and verify the 32-bit Connext Micro 4.3.0 PIL and MICROSAR4 PSL libraries on Linux.

Requirements:

- Use PIL target `x86_64leElfgcc13.3.0`.
- Use PSL target `x86_64leElfgcc13.3.0-MICROSAR4`.
- Use GCC/G++ 13.3.0 with `-fPIC` and Unix Makefiles.
- Require `OSEK_PATH` only for PSL or combined builds.
- Synchronize `.a` archives into `lib/<target>`.
- Replace generic PSL archives with MICROSAR4 variants in the SUT directory.
- Reject ELF32/i386 output and any `-m32` compile flag.
- Verify PSL contents and callback symbols with `ar` and `nm`.
- Do not introduce Visual Studio, MSVC, PE/COFF, batch, or PowerShell dependencies.

Run `./build_micro4_vtt.sh all Debug verify` and report the produced archives and verification result.
# Linux MICROSAR Build Prompt

Build and verify the 32-bit Connext Micro 4.3.0 PIL and MICROSAR4 PSL libraries on Linux.

Requirements:

- Use PIL target `i86leElfgcc13.3.0`.
- Use PSL target `i86leElfgcc13.3.0-MICROSAR4`.
- Use GCC/G++ 13.3.0 with `-m32` and Unix Makefiles.
- Require `OSEK_PATH` only for PSL or combined builds.
- Synchronize `.a` archives into `lib/<target>`.
- Verify PSL contents and callback symbols with `ar` and `nm`.
- Do not introduce Visual Studio, MSVC, PE/COFF, batch, or PowerShell dependencies.

Run `./build_micro4_vtt.sh all Debug verify` and report the produced archives and verification result.
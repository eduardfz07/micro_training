# MICROSAR PIL/PSL Linux Workflow

This playbook covers the Linux GCC 13.3.0 targets:

- `i86leElfgcc13.3.0`
- `i86leElfgcc13.3.0-MICROSAR4`

Use `../../build_micro4_vtt.sh` from the source root. PIL builds require GCC multilib; PSL builds also require `OSEK_PATH`.

Outputs are synchronized to `lib/<target>`. The Linux verifier uses ELF tools `ar` and `nm`; it does not require PowerShell, `lib.exe`, or `dumpbin.exe`.

See `build_micro_vtt.md` for complete usage and `COMMANDS.md` for command examples.
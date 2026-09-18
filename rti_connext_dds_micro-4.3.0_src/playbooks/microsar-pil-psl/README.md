# MICROSAR PIL/PSL Linux Workflow

This playbook covers the ELF64 Linux GCC 13.3.0 targets:

- `x86_64leElfgcc13.3.0`
- `x86_64leElfgcc13.3.0-MICROSAR4`

Use `./build_micro4_vtt.sh` from the source root. PSL builds require `OSEK_PATH`.

The MICROSAR output directory is a complete SUT link directory. It excludes the
generic PIL variants of `netiopsl`, `ospsl`, and `rti_me_psl` and includes the
MICROSAR4 variants instead.

See `build_micro_vtt.md` for complete usage and `COMMANDS.md` for command examples.
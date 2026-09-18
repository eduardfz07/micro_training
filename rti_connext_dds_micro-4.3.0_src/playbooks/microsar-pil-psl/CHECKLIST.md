# Build Checklist

- [ ] `/usr/bin/gcc-13` and `/usr/bin/g++-13` report version 13.3.0
- [ ] A trivial `gcc-13 -m32` compile succeeds
- [ ] `OSEK_PATH` points to the MICROSAR SIP for PSL builds
- [ ] `./build_micro4_vtt.sh pil Debug verify` succeeds
- [ ] `./build_micro4_vtt.sh psl Debug verify` succeeds
- [ ] PIL archives exist under `lib/i86leElfgcc13.3.0`
- [ ] PSL archives exist under `lib/i86leElfgcc13.3.0-MICROSAR4`
- [ ] `verify_psl_symbols.sh` confirms all required ELF symbols
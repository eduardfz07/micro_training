# Build Checklist

- [ ] `/usr/bin/gcc-13` and `/usr/bin/g++-13` report version 13.3.0
- [ ] A trivial native x86-64 `gcc-13 -fPIC` compile succeeds
- [ ] `OSEK_PATH` points to the MICROSAR SIP for PSL builds
- [ ] `./build_micro4_vtt.sh pil Debug verify` succeeds
- [ ] `./build_micro4_vtt.sh psl Debug verify` succeeds
- [ ] PIL archives exist under `lib/x86_64leElfgcc13.3.0`
- [ ] Curated SUT archives exist under `lib/x86_64leElfgcc13.3.0-MICROSAR4`
- [ ] Every delivered object is ELF64 x86-64
- [ ] The three PSL archives differ from their generic PIL counterparts
- [ ] `verify_psl_symbols.sh` confirms all required ELF symbols
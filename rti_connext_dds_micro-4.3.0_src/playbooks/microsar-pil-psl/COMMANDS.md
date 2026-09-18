# Commands

Run from the source root.

```bash
./build_micro4_vtt.sh pil Debug verify

export OSEK_PATH=/path/to/microsar/sip
./build_micro4_vtt.sh psl Debug verify
./build_micro4_vtt.sh all Release verify

find lib/x86_64leElfgcc13.3.0 -maxdepth 1 -name '*.a' -print
find lib/x86_64leElfgcc13.3.0-MICROSAR4 -maxdepth 1 -name '*.a' -print

./playbooks/microsar-pil-psl/verify_psl_symbols.sh Debug
```
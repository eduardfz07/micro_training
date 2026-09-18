# Linux GCC MICROSAR Build Workflow

This source bundle builds position-independent ELF64 x86-64 archives on a Linux
host with GCC 13.3.0.

## Architecture Files

- `resource/cmake/architectures/x86_64leElfgcc13.3.0.tc`: PIL
- `resource/cmake/architectures/x86_64leElfgcc13.3.0-MICROSAR4.tc`: MICROSAR4 PSL

Both targets use `/usr/bin/gcc-13`, `/usr/bin/g++-13`, and `-fPIC`. Neither
target uses `-m32` or `RTI_32SYSTEM`.

## Environment

The PSL build requires `OSEK_PATH` to point to the MICROSAR SIP root:

```bash
export OSEK_PATH=/home/efiego/Projects/CBD1500710_D12/
```

`build_micro4_vtt.sh` initializes `RTIMEHOME`, `NDDSHOME`, `RTIME_DIST`, `RTIMEARCH`, and `PATH`. Sourcing `set_micro_env.sh` is only needed for subsequent manual commands.

## Wrapper Usage

```bash
./build_micro4_vtt.sh [all|pil|psl] [Debug|Release] [verify|noverify]
./build_micro4_vtt.sh MODE=all CONFIG=Debug VERIFY=verify
```

Defaults are `all`, `Debug`, and `verify`.

Examples:

```bash
./build_micro4_vtt.sh pil Debug verify
./build_micro4_vtt.sh psl Release verify
./build_micro4_vtt.sh all Debug noverify
```

The wrapper builds the PIL dependency before the PSL. It creates a curated SUT
directory at `lib/x86_64leElfgcc13.3.0-MICROSAR4`: non-PSL PIL archives are
copied first, then the three MICROSAR4 archives are copied in. Generic PIL
`netiopsl`, `ospsl`, and `rti_me_psl` archives are never copied there.

## Direct Commands

```bash
bash resource/scripts/rtime-make --config Debug --build --delete \
  --target x86_64leElfgcc13.3.0 --name x86_64leElfgcc13.3.0 \
  -G "Unix Makefiles" -DRTIME_EXCLUDE_CPP=TRUE -DRTI_BUILD_UNITTESTS=FALSE

bash resource/scripts/rtime-make --config Debug --build --delete \
  --target x86_64leElfgcc13.3.0-MICROSAR4 --name x86_64leElfgcc13.3.0-MICROSAR4 \
  -G "Unix Makefiles" -DRTIME_EXCLUDE_CPP=TRUE -DRTI_BUILD_UNITTESTS=FALSE
```

## Verification

PIL verification confirms that `.a` archives were produced. PSL verification also runs:

```bash
./playbooks/microsar-pil-psl/verify_psl_symbols.sh Debug
```

The wrapper verifies every delivered archive as ELF64 x86-64, confirms `-fPIC`
and the absence of `-m32`, and proves the three PSL archives match the MICROSAR
build rather than the generic PIL build. The symbol verifier uses `ar` and `nm`
to confirm the AUTOSAR socket object and required callbacks.

## SUT Archive Manifest

The Debug deliverable contains these `zd.a` archives; Release contains the same
names with `z.a` instead:

```text
librti_me_appgenzd.a
librti_me_ddsfilterzd.a
librti_me_ddsxtypeszd.a
librti_me_discdpdezd.a
librti_me_discdpsezd.a
librti_me_netiopslzd.a
librti_me_netiosdmzd.a
librti_me_netioshmemzd.a
librti_me_netiozcopyzd.a
librti_me_ospslzd.a
librti_me_rhsmzd.a
librti_me_rti_me_pslzd.a
librti_me_whsmzd.a
librti_mezd.a
```

Verify an archive with:

```bash
archive=lib/x86_64leElfgcc13.3.0-MICROSAR4/librti_mezd.a
member=$(ar t "$archive" | head -n 1)
ar p "$archive" "$member" | file -
```

Expected output contains `ELF 64-bit LSB relocatable, x86-64`.
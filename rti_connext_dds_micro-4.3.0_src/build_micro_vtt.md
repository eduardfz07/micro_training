# Linux GCC MICROSAR Build Workflow

This source bundle builds 32-bit ELF archives on a Linux host with GCC 13.3.0.

## Architecture Files

- `resource/cmake/architectures/i86leElfgcc13.3.0.tc`: AUTOSAR PIL
- `resource/cmake/architectures/i86leElfgcc13.3.0-MICROSAR4.tc`: MICROSAR4 PSL

Both targets use `/usr/bin/gcc-13`, `/usr/bin/g++-13`, and `-m32`. The PSL target uses the shared MICROSAR CMake platform and does not define Windows or MSVC compiler settings.

## Environment

The PIL build needs GCC 13.3.0 with multilib support. The PSL build additionally requires `OSEK_PATH` to point to the MICROSAR SIP root:

```bash
export OSEK_PATH=/path/to/microsar/sip
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

The wrapper calls the Unix `resource/scripts/rtime-make` entry point with `Unix Makefiles`, C++ disabled, and unit tests disabled. Archives are copied from `build/cmake/<Config>/<Target>` to `lib/<Target>`.

## Direct Commands

```bash
bash resource/scripts/rtime-make --config Debug --build --delete \
  --target i86leElfgcc13.3.0 --name i86leElfgcc13.3.0 \
  -G "Unix Makefiles" -DRTIME_EXCLUDE_CPP=TRUE -DRTI_BUILD_UNITTESTS=FALSE

bash resource/scripts/rtime-make --config Debug --build --delete \
  --target i86leElfgcc13.3.0-MICROSAR4 --name i86leElfgcc13.3.0-MICROSAR4 \
  -G "Unix Makefiles" -DRTIME_EXCLUDE_CPP=TRUE -DRTI_BUILD_UNITTESTS=FALSE
```

## Verification

PIL verification confirms that `.a` archives were produced. PSL verification also runs:

```bash
./playbooks/microsar-pil-psl/verify_psl_symbols.sh Debug
```

The verifier uses `ar` and `nm` to confirm that the ELF archive contains the AUTOSAR socket object and required callback symbols.
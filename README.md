# Connext Micro 4.3.0 Linux Build

This workspace builds 32-bit Connext Micro libraries on Linux with GCC 13.3.0.

## Targets

- PIL: `i86leElfgcc13.3.0`
- MICROSAR4 PSL: `i86leElfgcc13.3.0-MICROSAR4`

The PSL target uses the PIL libraries and requires a compatible MICROSAR SIP.

## Prerequisites

On Ubuntu, install CMake, Make, GCC 13.3.0, and 32-bit development support:

```bash
sudo apt update
sudo apt install cmake make gcc-13 g++-13 gcc-13-multilib g++-13-multilib binutils
```

## Build

```bash
cd rti_connext_dds_micro-4.3.0_src

# PIL only; OSEK_PATH is not required
./build_micro4_vtt.sh pil Debug verify

# MICROSAR PSL only
export OSEK_PATH=/path/to/microsar/sip
./build_micro4_vtt.sh psl Debug verify

# PIL followed by PSL
./build_micro4_vtt.sh all Release verify
```

Generated archives are synchronized to:

```text
rti_connext_dds_micro-4.3.0_src/lib/i86leElfgcc13.3.0/
rti_connext_dds_micro-4.3.0_src/lib/i86leElfgcc13.3.0-MICROSAR4/
```

To use the PIL target in the current shell:

```bash
source set_micro_env.sh
```

See [build_micro_vtt.md](rti_connext_dds_micro-4.3.0_src/build_micro_vtt.md) for the complete workflow.
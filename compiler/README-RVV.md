# Parsimony for RISC-V

## Build Steps:

0. Build LLVM with the preset `parsimony-rvv` in the provided `utils/CMakeUserPresets.json`.

We assume the environment variable $RISCV points to the directory you want the toolchains installed.

1. Build the RISC-V GNU Compiler Toolchain (https://github.com/riscv-collab/riscv-gnu-toolchain)
`./configure --prefix=$RISCV --with-abi=lp64d --with-arch=rv64imafdc`
2. Build the Spike RISC-V ISA Simulator (https://github.com/riscv-software-src/riscv-isa-sim)
`../configure --prefix=$RISCV`
3. Build the RISC-V Proxy Kernel and Boot Loader (https://github.com/riscv-software-src/riscv-pk)
`../configure --prefix=$RISCV --host=riscv64-unknown-linux-gnu --with-arch=rv64gc_zifencei --with-abi=lp64d`

For some reason, `clang` doesn't like the default installation [1] of these files so we have to symlink them into the new sysroots:
`cd $RISCV/sysroot/lib`
`ln -s ../../lib/gcc/riscv64-unknown-linux-gnu/12.2.0/crtbeginT.o .`
`ln -s ../../lib/gcc/riscv64-unknown-linux-gnu/12.2.0/crtend.o .`

After this, `tests/run_rvv.sh` should run.


## Notes:

I added a new `-rvv` flag to `parsimony` so it uses RISC-V as a target. The
default vector width is set to be 128 as well, so currently parsimony doesn't
actually use it to specify a max vector width (unlike the case for SVE). There
is no replacement for `PsimCollectiveAddAbsDiff` in RISC-V so parsimony will
throw an error. There is a replacement for `pmulhu` in RISC-V but it doesn't
seem to work yet. There are also errors from the proxy kernel on Spike when
running programs that use cout and other such complicated calls. Additionally,
a few of the basic tests in `compiler/tests` are designed for x86 so those
obviously fail since they cannot be compiled for RISCV-V.

## TODO:
- Actually run parsimony for RISC-V on the benchmark suites used in the paper, check for functional correctness.

[1] https://stackoverflow.com/questions/73776689/cross-compiling-with-clang-crtbegins-o-no-such-file-or-directory

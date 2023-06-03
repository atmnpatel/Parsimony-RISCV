#!/bin/bash

PSV_EXTRA=""
FILES=""

while test $# -gt 0
do
    case "$1" in
        -E) PSV_EXTRA="${PSV_EXTRA} -Werror"
            ;;
        -I) PSV_EXTRA="${PSV_EXTRA} -Iwarnset"
            ;;
        *) 	FILES="${FILES} $1"
            ;;
    esac
    shift
done

if [ "$FILES" = "" ];
then
    FILES=`ls *.cpp`
fi

mkdir -p bin

for i in $FILES; do
  echo $i
  BIN=$(echo $i | sed "s/.cpp$//")
  cmd="parsimony -O3 -mprefer-vector-width=128 -I../../apps/synet-simd/src $i -o bin/$BIN --Xpsv=\"$PSV_EXTRA\" --Xtmp tmp -rvv"
  echo $cmd
  eval $cmd
  $RISCV/bin/spike --isa=RV64IMAFDCV $RISCV/riscv64-unknown-linux-gnu/bin/pk bin/$BIN
  echo
done

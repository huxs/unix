#! /bin/sh

DIRNAME=$(dirname $0)
NAME=${1%.*}
TMP="$NAME.s"

echo ".section .data
formatstr:\t.asciz \"%d\\n\"
.section .bss
symbols:\t .fill 25, 4, 0\n
.section .text
.globl _start
_start:
\tleal\tsymbols,%ebx" > $TMP

./calc3asm < $1 >> $TMP

echo "\tpushl\t\$0
\tcall\texit" >> $TMP

# Debug..
echo "$(cat "$TMP")"

as -gstabs $TMP -o "$NAME.o"
gcc "$NAME.o" -L$DIRNAME -lc -lcalc3 -nostdlib -o "$NAME"


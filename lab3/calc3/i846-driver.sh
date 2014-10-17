#! /bin/sh

TMP=$(mktemp)

echo ".section .data
formatstr:\t.asciz \"%d\\n\"
.section .bss
symbols:\t .fill 25, 4, 0\n
.section .text
.globl _start
_start:
\tleal\tsymbols,%ebx" >> $TMP

./calc3asm < $1 >> $TMP

echo "\tpushl\t\$0
\tcall\texit" >> $TMP

# Debug..
echo "$(cat "$TMP")"

as -gstabs $TMP -o "$1.o"
gcc "$1.o" -lc -nostdlib -o "$1.foo"


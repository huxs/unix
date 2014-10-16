#! /bin/sh

TMP=$(mktemp)

#echo ".section .bss" >> $TMP
#echo "symbols:\t .fill 25, 4, 0\n" >> $TMP

echo ".section .text
.globl _start
_start:" >> $TMP

#echo "\tleal\tsymbols,%eax" >> $TMP

./calc3asm < $1 >> $TMP

echo "\tpushl\t\$0
\tcall\texit" >> $TMP

echo "\tmovl\t\$1, %eax
\tmovl\t\$0, %ebx
\tint\t\$0x80" >> $TMP

# Debug..
echo "$(cat "$TMP")"

as -gstabs $TMP -o "$1.o"
gcc -lc -nostdlib "$1.o" -o "$1.foo"


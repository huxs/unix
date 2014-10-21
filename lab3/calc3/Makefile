all:
	gcc y.tab.o lex.yy.o calc3i.c -o calc3asm
	as -gstabs calc3l.s -o calc3l.o
	gcc -shared calc3l.o -o libcalc3.so

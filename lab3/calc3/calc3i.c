#include <stdio.h>
#include "calc3.h"
#include "y.tab.h"

static int lbl;

int ex(nodeType *p) {
    int lbl1, lbl2;

    if (!p) return 0;
    switch(p->type) {
    case typeCon: // constant value
        printf("\tpush\t$%d\n", p->con.value);
        break;
    case typeId: // id value
        printf("\tpush\t%d(%%ebx)\n", p->id.i * 4);
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case WHILE: // while
            printf("L%03d:\n", lbl1 = lbl++); // emit lb1
            ex(p->opr.op[0]); // emit expression.
            printf("\tL%03d\n", lbl2 = lbl++); //emit jump location lb2
            ex(p->opr.op[1]); // emit body
            printf("\tjmp\tL%03d\n", lbl1); // emit lb1
            printf("L%03d:\n", lbl2); // emit lb2
            break;
        case IF:
            ex(p->opr.op[0]); // emit if expression.
            if (p->opr.nops > 2) {
                /* if else */
                printf("\tL%03d\n", lbl1 = lbl++); // emit jump location else (lb1)
                ex(p->opr.op[1]); // emit if body
                printf("\tjmp\tL%03d\n", lbl2 = lbl++); // if taken jump to end (lb2)
                printf("L%03d:\n", lbl1); // emit else (lb1)
                ex(p->opr.op[2]); // emit else body
                printf("L%03d:\n", lbl2); // emit end (lb2)
            } else {
                /* if */
                printf("\tL%03d\n", lbl1 = lbl++); // emit jump location end (lbl1)
                ex(p->opr.op[1]); // emit if body
                printf("L%03d:\n", lbl1); // emit end (lbl1)
            }
            break;
        case PRINT: // print
            ex(p->opr.op[0]);
            printf("\tpush\t$formatstr\n");
            printf("\tcall\tprintf\n"); // clib call
            printf("\taddl\t$8,%%esp\n");
            break;
        case '=': // assign
            ex(p->opr.op[1]);
            printf("\tmovl\t(%%esp),%%ecx\n");
            printf("\tmovl\t%%ecx,%d(%%ebx)\n", p->opr.op[0]->id.i * 4);
            printf("\taddl\t$4,%%esp\n");
            break;
        case UMINUS: // minus
            ex(p->opr.op[0]);
            printf("\tnegl\t(%%esp)\n");
            break;
        case FACT:
            ex(p->opr.op[0]);
            printf("\tfact\n");
            break;
        case LNTWO:
            ex(p->opr.op[0]);
            printf("\lntwo\n");
            break;
        default:
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            switch(p->opr.oper) {
            case GCD:   printf("\tgcd\n"); break;
            case '+':
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\taddl\t(%%esp),%%eax\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tpushl\t%%eax\n");
                break;
            case '-':
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tsubl\t(%%esp),%%eax\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tpushl\t%%eax\n");
                break;
            case '*':
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\timull\t(%%esp)\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tpushl\t%%eax\n");
                break;
            case '/':
                printf("\txorl\t%%edx,%%edx\n");
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tidivl\t(%%esp)\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tpushl\t%%eax\n");
                break;
            case '<':
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tjge");
                break;
            case '>':
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tjle");
                break;
            case GE:
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tjs");
                break;
            case LE:
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tjg");
                break;
            case NE:
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tje");
                break;
            case EQ:
                printf("\tmovl\t4(%%esp),%%eax\n");
                printf("\tmovl\t(%%esp),%%ecx\n");
                printf("\taddl\t$8,%%esp\n");
                printf("\tcmpl\t%%ecx,%%eax\n");
                printf("\tjne");
                break;
            }
        }
    }
    return 0;
}

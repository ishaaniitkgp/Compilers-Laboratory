#include <stdio.h>
extern int yyparse();

int main() {
    printf(".......................On Line No. 1.......................\n\n");
    yyparse();
    return 0;
}

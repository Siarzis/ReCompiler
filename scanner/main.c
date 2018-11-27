#include "token.h"
#include <stdio.h>

extern FILE *yyin;
extern int yylex();
extern char *yytext;

int main() {
	yyin = fopen("input.txt","r");
	if(!yyin) {
		printf("could not open input text!\n");
		return 1;
	}

	while(1) {
		token t = yylex();
		if(t==T_eof) break;
		printf("token: %d  text: %s\n",t,yytext);
	}
}

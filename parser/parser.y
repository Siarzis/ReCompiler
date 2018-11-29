%{
#include <stdio.h>
%}

%token T_INT
%token T_PLUS
%token T_MINUS
%token T_MUL
%token T_DIV
%token T_LPAREN
%token T_RPAREN
%token T_SEMI

%%

program : expr T_SEMI;

expr 	: expr T_PLUS term
	| expr T_MINUS term
	| term
	;

term 	: factor T_MUL term
	| factor T_DIV term
	| factor
	;

factor	:
	| T_MINUS factor
	| T_LPAREN expr T_RPAREN
	| T_INT
	;

%%

int yywrap() {}

int main()
{
	if (yyparse()==0) {
		printf("Parse successful!\n"); }
	else {
		printf("Parse failed.\n"); }
}

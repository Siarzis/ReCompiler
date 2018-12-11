%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "ast.h"

extern int yylex();
extern char *yytext;

char parser_result;
%}

%union{
	int n;
	char c;
}

%token T_byte	"byte"
%token T_int	"int"
%token T_if	"if"
%token T_else	"else"
%token T_while	"while"
%token T_true	"true"
%token T_false	"false"
%token T_proc	"proc"
%token T_return "return"
%token T_reference "reference"

%token T_ID
%token<n> T_CONST
%token<c> T_CHAR
%token T_STRING
%token T_DOUBLEOP

%token T_ERROR

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'

%type<c> program
%type<c> fnct
%type<c> compound_stmt
%type<c> opt_stmt
%type<c> stmt
%type<c> expr
%type<c> opt_else
%type<c> cond

%%

program : fnct  { parser_result = $1; }
	;

fnct : T_ID '(' param_list ')' ':' r_type local_def compound_stmt { $$ = $8; }
     ;

param_list : /* empty */
	   | param_def opt_comma_param
	   ;

opt_comma_param : /* empty */
		| opt_comma_param ',' param_def
		;

param_def : T_ID ':' opt_ref type;

opt_ref : /* empty */
	| "reference"
	;

type : data_type opt_brackets;

opt_brackets : /* empty */
	     | '[' ']'
	     ;

r_type : data_type
       | "proc"
       ;

data_type : "int" | "byte" ;

local_def : /* empty */
	  | local_def fnct
	  | local_def var_def
	  ;

var_def : T_ID ':' data_type opt_int_brackets ';' ;

opt_int_brackets : /* empty */
		 | '[' T_CONST ']'
		 ;

compound_stmt : '{' opt_stmt '}' { $$ = $2; }
	      ;

opt_stmt : /* empty */
	 | opt_stmt stmt { $$ = $2; }
	 ;

stmt : ';'
     | compound_stmt
     | l_value '=' expr ';' { $$ = $3; }
     | fnct_call ';'
     | "if" '(' cond ')' stmt opt_else { $$ = $5; }
     | "while" '(' cond ')' stmt 
     | "return" opt_ret_expr ';'
     ;

fnct_call : T_ID '(' expr_list ')' ;

expr_list : /* empty */
	  | expr opt_comma_expr
	  ;

opt_comma_expr : /* empty */
	       | opt_comma_expr ',' expr
	       ;

opt_else : /* empty */
	 | "else" stmt { $$ = $2; }
	 ;

opt_ret_expr : /* empty */
	     | expr
	     ;

expr : T_CONST { $$ = $1; }
     | T_CHAR { $$ = yytext[1]; }
     | l_value
     | '(' expr ')' { $$ = $2; }
     | fnct_call
     | '+' expr { $$ = $2; }
     | '-' expr { $$ = $2; }
     | expr '+' expr { $$ = $1 + $3; }
     | expr '-' expr { $$ = $1 - $3; }
     | expr '*' expr { $$ = $1 * $3; }
     | expr '/' expr { $$ = $1 / $3; }
     | expr '%' expr { $$ = $1 % $3; }
     ;

l_value : T_ID opt_expr_brackets
	| T_STRING
	;

opt_expr_brackets : /* empty */
		  | '[' expr ']'
		  ;

cond : "true" { $$ = true; }
     | "false" { $$ = false; }
     | '(' cond ')' { $$ = $2; }
     | '!' cond { $$ = !$2; }
     | expr T_DOUBLEOP expr
     | cond '&' cond { $$ = $1 && $3; }
     | cond '|' cond { $$ = $1 || $3; }
     ;

%%

extern FILE *yyin;

int yywrap() {}

int yyerror(char *s)
{
	fprintf(stderr, "%s\n",s);
}

int main()
{
	yyin = fopen("input.txt","r");
	if (yyparse()==0) {
		printf("Parse successful!\n");
		printf("Result: %c\n", parser_result);
	} else {
		printf("Parse failed.\n"); }
}

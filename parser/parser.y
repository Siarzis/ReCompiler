%{
#include <stdio.h>
#include <string.h>
%}

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
%token T_CONST
%token T_CHAR
%token T_STRING
%token T_DOUBLEOP

%token T_ERROR

%%

program : fnct;

fnct : T_ID '(' param_list ')' ':' r_type local_def compound_stmt;

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

compound_stmt : '{' opt_stmt '}';

opt_stmt : /* empty */
	 | opt_stmt stmt
	 ;

stmt : ';'
     | compound_stmt
     | l_value '=' expr ';'
     | fnct_call ';'
     | "if" '(' cond ')' stmt opt_else
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
	 | "else" stmt
	 ;

opt_ret_expr : /* empty */
	     | expr
	     ;

expr : T_CONST
     | T_CHAR
     | l_value
     | '(' expr ')'
     | fnct_call
     | '+' expr
     | '-' expr
     | expr '+' expr
     | expr '-' expr
     | expr '*' expr
     | expr '/' expr
     | expr '%' expr
     ;

l_value : T_ID opt_expr_brackets
	| T_STRING
	;

opt_expr_brackets : /* empty */
		  | '[' expr ']'
		  ;

cond : "true"
     | "false"
     | '(' cond ')'
     | '!' cond
     | expr T_DOUBLEOP expr
     | cond '&' cond
     | cond '|' cond
     ;

%%

extern FILE *yyin;

int yywrap() {}

int yyerror(char *s) {fprintf(stderr, "%s\n",s);}

int main()
{
	yyin = fopen("input.txt","r");
	if (yyparse()==0) {
		printf("Parse successful!\n"); }
	else {
		printf("Parse failed.\n"); }
}

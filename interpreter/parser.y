%{
#include <stdio.h>
#include <stdbool.h>
#include "ast.h"

extern int yylex();
extern char *yytext;

struct decl *parser_result = NULL;
%}

%union{
	struct decl *decl;
	struct stmt *stmt;
	struct expr *expr;
	struct type *type;
	int n;
	char *c;
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

%token T_eq "=="
%token T_le "<="
%token T_ge ">="
%token T_ne "!="

%token<c> T_ID
%token<n> T_CONST
%token<c> T_CHAR
%token<c> T_STRING

%token T_ERROR

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'

%type<decl> program
%type<decl> fnct
%type<c> data_type
%type<c> r_type
%type<stmt> compound_stmt
%type<stmt> opt_stmt
%type<stmt> stmt
%type<expr> fnct_call
%type<expr> expr_list
%type<expr> opt_comma_expr
%type<stmt> opt_ret_expr
%type<expr> expr
%type<expr> l_value
%type<expr> opt_else
%type<expr> cond

%%

program : fnct  { parser_result = $1; }
	;

fnct : T_ID '(' param_list ')' ':' r_type local_def compound_stmt { $$ = decl_create($1, NULL, NULL, $8, NULL); }
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
       | "proc" { $$ = "void"; }
       ;

data_type : "int" { $$ = "int"; }
	  | "byte" { $$ = "byte"; }
	  ;

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

opt_stmt : /* empty */ { $$ = NULL; }
	 | stmt opt_stmt { $$ = $1; $1->next = $2; }
	 ;

stmt : ';'
     | compound_stmt { $$ = $1; }
     | l_value '=' expr ';' { $$ = stmt_create(STMT_ASSIGN, NULL, $3, $1, NULL, NULL, NULL); }
     | fnct_call ';' { $$ = stmt_create(STMT_BLOCK, NULL, $1, NULL, NULL, NULL, NULL); }
     | "if" '(' cond ')' stmt opt_else { $$ = stmt_create(STMT_IF_ELSE, NULL, $3, NULL, $5, $6, NULL); }
     | "while" '(' cond ')' stmt { $$ = stmt_create(STMT_WHILE, NULL, $3, NULL, $5, NULL, NULL); }
     | "return" opt_ret_expr ';' { $$ = $2; }
     ;

fnct_call : T_ID '(' expr_list ')' { $$ = expr_create(EXPR_CALL, expr_create_name($1), $3); }
	  ;

expr_list : /* empty */ { $$ = NULL; }
	  | expr opt_comma_expr { $$ = expr_create(EXPR_ARG, $1, $2); }
	  ;

opt_comma_expr : /* empty */ { $$ = NULL; }
	       | ',' expr opt_comma_expr { $$ = expr_create(EXPR_ARG, $2, $3); }
	       ;

opt_else : /* empty */ { $$ = NULL; }
	 | "else" stmt { $$ = $2; }
	 ;

opt_ret_expr : /* empty */ { $$ = NULL; }
	     | expr { $$ = stmt_create(STMT_RETURN, NULL, $1, NULL, NULL, NULL, NULL); }
	     ;

expr : T_CONST { $$ = expr_create_int_literal($1); }
     | T_CHAR { $$ = expr_create_int_literal($1); }
     | expr '+' expr { $$ = expr_create(EXPR_ADD, $1, $3); }
     | expr '-' expr { $$ = expr_create(EXPR_SUB, $1, $3); }
     | expr '*' expr { $$ = expr_create(EXPR_MUL, $1, $3); }
     | expr '/' expr { $$ = expr_create(EXPR_DIV, $1, $3); }
     | expr '%' expr { $$ = expr_create(EXPR_MOD, $1, $3); }
     | l_value { $$ = $1; }
     | '(' expr ')' { $$ = $2; }
     | fnct_call { $$ = $1; }
     | '-' expr { $$ = $2; }
     ;

l_value : T_ID opt_expr_brackets { $$ = expr_create_name($1); }
	| T_STRING { $$ = expr_create_string_literal($1); }
	;

opt_expr_brackets : /* empty */
		  | '[' expr ']'
		  ;

cond : "true"
     | "false"
     | '(' cond ')' { $$ = $2; }
     | '!' cond { $$ = expr_create(EXPR_NOT, $2, NULL); }
     | expr "<" expr { $$ = expr_create(EXPR_LT, $1, $3); }
     | expr ">" expr { $$ = expr_create(EXPR_GT, $1, $3); }
     | expr "==" expr { $$ = expr_create(EXPR_EQ, $1, $3); }
     | expr "<=" expr { $$ = expr_create(EXPR_LE, $1, $3); }
     | expr ">=" expr { $$ = expr_create(EXPR_GE, $1, $3); }
     | expr "!=" expr { $$ = expr_create(EXPR_NE, $1, $3); }
     | cond '&' cond { $$ = expr_create(EXPR_AND, $1, $3); }
     | cond '|' cond { $$ = expr_create(EXPR_OR, $1, $3); }
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
		printf("Result: %d\n", stmt_evaluate(parser_result->code));
	} else {
		printf("Parse failed.\n");
	}
}

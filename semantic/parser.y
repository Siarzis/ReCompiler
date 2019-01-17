%{
#include <stdio.h>
#include <stdbool.h>
#include "ast.h"
#include "hashtable.h"

extern int yylex();
extern char *yytext;

struct decl *parser_result = NULL;
%}

%union{
	struct decl *decl;
	struct stmt *stmt;
	struct expr *expr;
	struct type *type;
	struct param_list *param;
	int n;
	unsigned char *c;
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
%type<param> param_list
%type<param> opt_comma_param
%type<param> param_def
%type<stmt> opt_ref
%type<param> type
%type<type> opt_brackets
%type<type> r_type
%type<type> data_type
%type<decl> local_def
%type<decl> var_def
%type<type> opt_int_brackets
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
%type<expr> opt_expr_brackets
%type<expr> cond

%%

program : fnct  { parser_result = $1; }
	;

fnct : T_ID '(' param_list ')' ':' r_type local_def compound_stmt { $$ = decl_create($1, create_type(TYPE_FUNCTION, $6, $3), $7, $8, NULL); }
     ;

param_list : /* empty */ { $$ = NULL; }
	   | param_def opt_comma_param { $$ = $1; $1->next = $2; }
	   ;

opt_comma_param : /* empty */ { $$ = NULL; }
		| ',' param_def opt_comma_param  { $$ = $2; $2->next = $3; }
		;

param_def : T_ID ':' opt_ref type { $$ = create_parameters($1, $4, NULL); }
	  ;

opt_ref : /* empty */ { $$ = NULL; }
	| "reference"
	;

type : data_type opt_brackets { if ($2 == NULL) $$ = $1; else $2->subtype=$1; };

opt_brackets : /* empty */ { $$ = NULL; }
	     | '[' ']' { $$ = create_type(TYPE_ARRAY, NULL, NULL); }
	     ;

r_type : data_type { $$ = $1; }
       | "proc" { $$ = create_type(TYPE_VOID, NULL, NULL); }
       ;

data_type : "int" { $$ = create_type(TYPE_INT, NULL, NULL); }
	  | "byte" { $$ = create_type(TYPE_BYTE, NULL, NULL); }
	  ;

local_def : /* empty */ { $$ = NULL; }
	  | fnct local_def { $$ = $1; $1->next = $2; }
	  | var_def local_def { $$ = $1; $1->next = $2; }
	  ;

var_def : T_ID ':' data_type opt_int_brackets ';'  { if ($4 == NULL) $$ = decl_create($1, $3, NULL, NULL, NULL); else {$4->subtype=$1; decl_create($1, $4, NULL, NULL, NULL);} }
	; 

opt_int_brackets : /* empty */ { $$ = NULL; }
		 | '[' T_CONST ']' { $$ = create_type(TYPE_ARRAY, NULL, NULL); }
		 ;

compound_stmt : '{' opt_stmt '}' { $$ = $2; }
	      ;

opt_stmt : /* empty */ { $$ = NULL; }
	 | stmt opt_stmt { $$ = $1; $1->next = $2; }
	 ;

stmt : ';'
     | compound_stmt { $$ = $1; }
     | l_value '=' expr ';' { $$ = stmt_create(STMT_ASSIGN, $3, $1, NULL, NULL, NULL); }
     | fnct_call ';' { $$ = stmt_create(STMT_BLOCK, $1, NULL, NULL, NULL, NULL); }
     | "if" '(' cond ')' stmt opt_else { $$ = stmt_create(STMT_IF_ELSE, $3, NULL, $5, $6, NULL); }
     | "while" '(' cond ')' stmt { $$ = stmt_create(STMT_WHILE, $3, NULL, $5, NULL, NULL); }
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
	     | expr { $$ = stmt_create(STMT_RETURN, $1, NULL, NULL, NULL, NULL); }
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

l_value : T_ID opt_expr_brackets { if ($2 == NULL) $$ = expr_create_name($1); else $$ = expr_create(EXPR_SUBSCRIPT, expr_create_name($1), $2); }
	| T_STRING { $$ = expr_create_string_literal($1); }
	;

opt_expr_brackets : /* empty */ { $$ = NULL; }
		  | '[' expr ']'  { $$ = $2; }
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
		printf("Result: %d\n", run_interpreter(parser_result));
	} else {
		printf("Parse failed.\n");
	}
}

%{
#define T_eof 0
#define T_byte 1001
#define T_int 1002
#define T_if 1003
#define T_else 1004
#define T_while 1005
#define T_true 1006
#define T_false 1007
#define T_proc 1008
#define T_return 1009
#define T_reference 1010
%}

CONST [0-9]
NAME [a-zA-Z][a-zA-Z0-9_]*
OP "="|"+"|"-"|"*"|"/"|"%"|"!"|"&"|"|"|"=="|"!="|"<"|">"|"<="|">="
OPERATOR [!%&*+/=|]|"-"|"=="|"!="|"<"|">"|"<="|">="
SEPARATOR [(),:;{}]|"["|"]"

%%
"byte"		{ return T_byte; }
"int"		{ return T_int; }
"if"		{ return T_if; }
"else"		{ return T_else; }
"while"		{ return T_while; }
"true"		{ return T_true; }
"false"		{ return T_false; }
"proc"		{ return T_proc; }
"return"     	{ return T_return; }
"reference"     { return T_reference; }

{CONST}+	{ printf("A constant was identified: %s\n", yytext); }
{NAME}		{ printf("A name was found: %s\n", yytext); }
{OPERATOR}	{ printf("An operator was found: %s\n", yytext); }
{SEPARATOR}	{ printf("A separator was found: %s\n", yytext); }

\n		{ printf(""); }
%%

int yywrap(){}

int main() {
	yylex();
}


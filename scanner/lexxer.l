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

DIGIT [0-9]

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

{DIGIT}+	{
		printf( "An integer was found: %s (%d)\n", yytext, atoi(yytext));
		}

%%

int yywrap(){}

int main() {
	yylex();
}


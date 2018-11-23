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
NAME [a-zA-Z][a-zA-Z0-9_]*
CHAR .|\\[\"'0\\nrt]
STRING .*
OPERATOR [!%&*+/=|]|"-"|"=="|"!="|"<"|">"|"<="|">="
SEPARATOR [(),:;{}]|"["|"]"
EMPTY [ \n\t\r]
ONELINECOM "--".*"\n"
MULLINECOM "(*".*"*)"

%%
byte|int|if|else|while|true|false|proc|return|reference	{ printf("A wild keyword appeared: %s\n", yytext); }

{DIGIT}+	{ printf("A constant was identified: %s\n", yytext); }
{NAME}		{ printf("A name was found: %s\n", yytext); }
'{CHAR}'	{ printf("A char was identified: %s\n", yytext); }
\"{STRING}\"	{ printf("A string was detected: %s\n", yytext); }
{OPERATOR}	{ printf("An operator was found: %s\n", yytext); }
{SEPARATOR}	{ printf("A separator was found: %s\n", yytext); }

{EMPTY}+|{ONELINECOM}|{MULLINECOM}	{ /* should be ingored */ }
%%

int yywrap(){}

int main(int argc, char **argv) {
	yyin = fopen(argv[1], "r");
	yylex();
}


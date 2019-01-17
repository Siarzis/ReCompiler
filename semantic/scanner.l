%{
#include "token.h"
#include "ast.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
ALPHANUMERIC [a-zA-Z0-9]
CHAR .
BS \\
ESC [\"'0\\nrt]
HEX x[a-fA-F0-9]{2}
STRING .*
SINGLE_OP [!%&*+\-/<=>|]
SEPARATOR [(),:;\[\]{}]
EMPTY [ \n\t\r]
ONELINECOM --.*\n
MULLINECOM "(*"(.|\n)*"*)"

%%
byte		{ printf("%s\n", yytext); return T_byte; }
int		{ printf("%s\n", yytext); return T_int; }
if		{ printf("%s\n", yytext); return T_if; }
else		{ printf("%s\n", yytext); return T_else; }
while		{ printf("%s\n", yytext); return T_while; }
true		{ printf("%s\n", yytext); return T_true; }
false		{ printf("%s\n", yytext); return T_false; }
proc		{ printf("%s\n", yytext); return T_proc; }
return		{ printf("%s\n", yytext); return T_return; }
reference	{ printf("%s\n", yytext); return T_reference; }

"=="		{ printf("%s\n", yytext); return T_eq; }
"<="		{ printf("%s\n", yytext); return T_le; }
">="		{ printf("%s\n", yytext); return T_ge; }
"!="		{ printf("%s\n", yytext); return T_ne; }

{SINGLE_OP}				{ printf("%s\n", yytext); return yytext[0]; }
{SEPARATOR}				{ printf("%s\n", yytext); return yytext[0]; }

{DIGIT}+				{ printf("%s\n", yytext); yylval.n = atoi(yytext); return T_CONST; }
{LETTER}(_|{ALPHANUMERIC})* 		{ printf("%s\n", yytext); yylval.c = strdup(yytext); return T_ID; }

'{CHAR}'|'{BS}{ESC}'|'{BS}{HEX}'	{ printf("%s\n", yytext); yylval.c = yytext; return T_CHAR; }
\"{STRING}\"				{ printf("%s\n", yytext); return T_STRING; }


{EMPTY}|{ONELINECOM}|{MULLINECOM}	{ /* should be ingored */ }

.					{ printf("lexical error! "); return T_ERROR; }
%%


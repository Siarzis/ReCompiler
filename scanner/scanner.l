%{
#include "token.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
ALPHANUMERIC [a-zA-Z0-9]
CHAR .|\\[\"'0\\nrt]
STRING .*
SINGLE_OP [!%&*+\-/<=>|]
DOUBLE_OP ==|!=|<=|>=
SEPARATOR [(),:;\[\]{}]
EMPTY [ \n\t\r]
ONELINECOM --.*\n
MULLINECOM "(*"(.|\n)*"*)"

%%
byte		{ return T_byte; }
int		{ return T_int; }
if		{ return T_if; }
else		{ return T_else; }
while		{ return T_while; }
true		{ return T_true; }
false		{ return T_false; }
proc		{ return T_proc; }
return		{ return T_return; }
reference	{ return T_reference; }

{DIGIT}+	{ return T_CONST; }
{LETTER}(_|{ALPHANUMERIC})* {printf("identifier\n"); return T_ID; }

'{CHAR}'	{ return T_CHAR; }
\"{STRING}\"	{ printf("string\n"); return T_STRING; }
{SINGLE_OP}	{ printf("single operator\n"); return yytext[0]; }
{DOUBLE_OP}	{ printf("double operator\n"); return T_DOUBLEOP; }
{SEPARATOR}	{ printf("separator\n"); return yytext[0]; }

{EMPTY}|{ONELINECOM}|{MULLINECOM}	{ /* should be ingored */ }

.	{ printf("lexical error! "); return T_ERROR; }
%%


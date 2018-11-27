%{
#include "token.h"
%}

DIGIT [0-9]
NAME [a-zA-Z][a-zA-Z0-9_]*
CHAR .|\\[\"'0\\nrt]
STRING .*
OPERATOR [!%&*+\-/=|]|==|!=|<|>|<=|>=
SEPARATOR [(),:;\[\]{}]
EMPTY [ \n\t\r]
ONELINECOM --.*\n
MULLINECOM "(*"(.|\n)*"*)"

%%
byte|int|if|else|while|true|false|proc|return|reference	{ return T_KEYWORD; }

{DIGIT}+	{ return T_CONSTANT; }
{NAME}		{ return T_NAME; }
'{CHAR}'	{ return T_CHARACTER; }
\"{STRING}\"	{ return T_STRING; }
{OPERATOR}	{ return T_OPERATOR; }
{SEPARATOR}	{ return T_SEPARATOR; }

{EMPTY}|{ONELINECOM}|{MULLINECOM}	{ /* should be ingored */ }

.	{ printf("lexical error! "); return T_ERROR; }
%%

int yywrap(){}


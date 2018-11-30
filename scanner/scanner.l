%{
#include "token.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
ALPHANUMERIC [a-zA-Z0-9]
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
{LETTER}(_|{ALPHANUMERIC})* { return T_IDENTIFIER; }

'{CHAR}'	{ return T_CHARACTER; }
\"{STRING}\"	{ return T_STRING; }

{OPERATOR}	{ return T_OPERATOR; }
{SEPARATOR}	{ return T_SEPARATOR; }

{EMPTY}|{ONELINECOM}|{MULLINECOM}	{ /* should be ingored */ }

.	{ printf("lexical error! "); return T_ERROR; }
%%


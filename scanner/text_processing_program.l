		#include <stdio.h>
		int num_chars = 0;

%%
[a-zA-Z]	++num_chars;
\n		return 0;
%%

int yywrap(){}

int main()
		{
		yylex();
		printf( "# of characters = %d\n", num_chars );
		}

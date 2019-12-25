%{
#include<stdio.h>
#include "node.h"
#include "shiyaner.tab.h"
%}

%option yylineno
ANNOTATION (\/\*([^*]|[\r\n]|(\*+([^\*\/]|[\r\n])))*\*+\/)|(\/\/.*)
ILLEGALANNO (\/\*)|(\*\/)
TYPE	int|float|bool|char
STRUCT 	struct
RETURN	return
IF	if
ELSE	else
WHILE	while
INT 	[+-]?[0-9]+
FLOAT	{INT}"."[0-9]+
HEX	[+-]?O[xX][0-9A-Fa-f]+
IMHEX	[+-]?O[xX][0-9A-Fa-f]*[g-zG-Z]+[0-9A-Za-z]*
OCT	0[0-9A-Za-z]+
SCIENNUM [+-]?[0-9]+(\.[0-9]+)?[eE][+\-0-9a-zA-Z]*
ID	[A-Z_a-z]([A-Za-z_0-9])*
STRUC	{ID}\.{ID}
SPACE	[ \t\r]*
EOL	\n
SEMI	;
COMMA	,
ASSIGNOP =
RELOP	<|<=|>=|>|==|!=
PLUS	"+"
MINUS	"-"
STAR	"*"
DIV	"/"
AND	"&&"
OR	"||"
DOT	"."
NOT	"!"
LP	"("
RP	")"
LB	"["
RB	"]"
LC	"{"
RC	"}"
AEEROR	.

%%
{ANNOTATION}	{yylval.node = newNode("ANNOTATION", yytext, yylineno, 0); 
		return ANNOTATION;}
{ILLEGALANNO}	{ printf("Error type A at Line %d: ILLEGALANNO %s\n", yylineno, yytext);}
{TYPE}		{yylval.node = newNode("TYPE", yytext, yylineno, 0); 
		return TYPE;}
{STRUCT} 	{yylval.node = newNode("STRUCT", yytext, yylineno, 0); 
		return STRUCT;}
{RETURN}	{yylval.node = newNode("RETURN", yytext, yylineno, 0); 
		return RETURN;}
{IF}		{yylval.node = newNode("IF", yytext, yylineno, 0); 
		return IF;}
{ELSE}		{yylval.node = newNode("ELSE", yytext, yylineno, 0); 
		return ELSE;}
{WHILE}		{yylval.node = newNode("WHILE", yytext, yylineno, 0); 
		return WHILE;}
{INT} 		{yylval.node = newNode("INT", yytext, yylineno, 0); 
		return INT;}
{FLOAT}		{yylval.node = newNode("FLOAT", yytext, yylineno, 0); 
		return FLOAT;}
{HEX}		{yylval.node = newNode("HEX", yytext, yylineno, 0); 
		return HEX;}
{IMHEX}		{ printf("Error type A at Line %d: IMHEX %s\n", yylineno, yytext);}	
{OCT}		{ printf("Error type A at Line %d: OCT %s\n", yylineno, yytext);}
{SCIENNUM}	{
		char * point = NULL;
		int tag = 0;
		point = strchr(yytext, 'e');
		if (point != NULL) {
			point = point + sizeof(char);
			if (*point == '+' || *point == '-') {
				while (*(point = point + sizeof(char)) != '\0') {
					if(*point > '0' && *point < '9') {
					} else {
							printf("Error type A at Line %d: Can't indentify Scientific number %s\n", yylineno, yytext);}
							tag = 1;
							break;
					}
				}
			}
		else {
			printf("Error type A at Line %d: Can't indentify Scientific number %s\n", yylineno, yytext);
			tag = 1;
		}
		if (tag == 0) {
			yylval.node = newNode("SCIENNUM", yytext, yylineno, 0); 
			return SCIENNUM;
		}
		}
				
{ID}		{yylval.node = newNode("ID", yytext, yylineno, 0); 
		return ID;}
{STRUC}		{yylval.node = newNode("STRUC", yytext, yylineno, 0); 
		return STRUC;}
{SPACE}		{}
{EOL}		{}
{SEMI}		{yylval.node = newNode("SEMI", yytext, yylineno, 0); 
		return SEMI;}
{COMMA}		{yylval.node = newNode("COMMA", yytext, yylineno, 0); 
		return COMMA;}
{ASSIGNOP} 	{yylval.node = newNode("ASSIGNOP", yytext, yylineno, 0); 
		return ASSIGNOP;}
{RELOP}		{yylval.node = newNode("RELOP", yytext, yylineno, 0); 
		return RELOP;}
{PLUS}		{yylval.node = newNode("PLUS", yytext, yylineno, 0); 
		return PLUS;}
{MINUS}		{yylval.node = newNode("MINUS", yytext, yylineno, 0); 
		return MINUS;}
{STAR}		{yylval.node = newNode("STAR", yytext, yylineno, 0); 
		return STAR;}
{DIV}		{yylval.node = newNode("DIV", yytext, yylineno, 0); 
		return DIV;}
{AND}		{yylval.node = newNode("AND", yytext, yylineno, 0); 
		return AND;}
{OR}		{yylval.node = newNode("OR", yytext, yylineno, 0); 
		return OR;}
{DOT}		{yylval.node = newNode("DOT", yytext, yylineno, 0); 
		return DOT;}
{NOT}		{yylval.node = newNode("NOT", yytext, yylineno, 0); 
		return NOT;}
{LP}		{yylval.node = newNode("LP", yytext, yylineno, 0); 
		return LP;}
{RP}		{yylval.node = newNode("RP", yytext, yylineno, 0); 
		return RP;}
{LB}		{yylval.node = newNode("LB", yytext, yylineno, 0); 
		return LB;}
{RB}		{yylval.node = newNode("RB", yytext, yylineno, 0); 
		return RB;}
{LC}		{yylval.node = newNode("LC", yytext, yylineno, 0); 
		return LC;}
{RC}		{yylval.node = newNode("RC", yytext, yylineno, 0); 
		return RC;}

{AEEROR}	{ printf("Error type A at Line %d: Mysterious character %s\n", yylineno, yytext);}
%%
int yywrap()
{
	return 1;
}



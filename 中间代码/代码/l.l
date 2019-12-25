/*
*Name:l.l
*Author:Wangqianyun
*Created on:2016-11-24
*Function:lexical analyzer
*/
%{
#include "stdio.h"
#include "stdlib.h"
# include "h.h"
#include "y.tab.h"
%}
%option yylineno
TYPE int|float
STRUCT struct
RETURN return
IF if
ELSE else
WHILE while
PLUS \+
MINUS \-
ID [a-z_A-Z][a-zA-Z_0-9]*
FLOAT1 	[0-9]+"."[0-9]+
FLOAT2 	({INTEGER}|{FLOAT1})[Ee][+-]?[0-9]+
IMFLOAT	({INTEGER}|{FLOAT1})[Ee][+-]?[A-Za-z_]*
FLOAT 	{FLOAT1}|{FLOAT2}
BINT 	0|[1-9][0-9]*
IMOCT	[+-]?0[0-7]*[89a-zA-Z]+[0-9A-Za-z]*
OCT 	[+-]?0[0-7]+
HEX 	[+-]?0[xX][0-9A-Fa-f]+
INTEGER	{BINT}|{OCT}|{HEX}
IMHEX	[+-]?0[xX][0-9A-Fa-f]*[g-zG-Z]+[0-9A-Za-z]*
SPACE [ \t\r]*
EOL \n
SEMI ;
COMMA ,
ASSIGNOP =
RELOP >|<|>=|<=|==|!=
STAR \*
DIV \/
AND &&
OR \|\|
DOT \.
NOT \!
LP \(
RP \)
LB \[
RB \]
LC \{
RC \}
AERROR .
%%
int|float {yylval.a=newast("TYPE",0,yylineno);return TYPE;}
struct {yylval.a=newast("STRUCT",0,yylineno);return STRUCT;}
{RETURN} {yylval.a=newast("RETURN",0,yylineno); return RETURN;}
{IF} { yylval.a=newast("IF",0,yylineno);return IF;}
{ELSE} {yylval.a=newast("ELSE",0,yylineno); return ELSE;}
{WHILE} {yylval.a=newast("WHILE",0,yylineno); return WHILE;}
{PLUS} {yylval.a=newast("PLUS",0,yylineno); return PLUS;}
{MINUS} {yylval.a=newast("MINUS",0,yylineno); return MINUS;}
{INTEGER} {yylval.a=newast("INTEGER",0,yylineno); return INTEGER;}
{FLOAT} {yylval.a=newast("FLOAT",0,yylineno); return FLOAT;}
{ID} {yylval.a=newast("ID",0,yylineno); return ID;}
{SPACE} {}
{EOL} {}
{SEMI} {yylval.a=newast("SEMI",0,yylineno); return SEMI;}
{COMMA} {yylval.a=newast("COMMA",0,yylineno); return COMMA;}
{ASSIGNOP} {yylval.a=newast("ASSIGNOP",0,yylineno); return ASSIGNOP;}
{RELOP} {yylval.a=newast("RELOP",0,yylineno); return RELOP;}
{STAR} {yylval.a=newast("STAR",0,yylineno); return STAR;}
{DIV} {yylval.a=newast("DIV",0,yylineno); return DIV;}
{AND} {yylval.a=newast("AND",0,yylineno); return AND;}
{OR} {yylval.a=newast("OR",0,yylineno); return OR;}
{DOT} {yylval.a=newast("DOT",0,yylineno); return DOT;}
{NOT} {yylval.a=newast("NOT",0,yylineno); return NOT;}
{LP} {yylval.a=newast("LP",0,yylineno); return LP;}
{RP} {yylval.a=newast("RP",0,yylineno); return RP;}
{LB} {yylval.a=newast("LB",0,yylineno); return LB;}
{RB} {yylval.a=newast("RB",0,yylineno); return RB;}
{LC} {yylval.a=newast("LC",0,yylineno); return LC;}
{RC} {yylval.a=newast("RC",0,yylineno); return RC;}
{IMHEX}	{printf("Error type A at Line %d: IMHEX %s\n", yylineno, yytext);}	
{IMFLOAT} {printf("Error type A at line %d: Illegal FLOAT \" %s \".\n", yylineno, yytext);};
{IMOCT}	{printf("Error type A at line %d: Illegal OCT \" %s \".\n", yylineno, yytext);}	
{AERROR} { printf("Error type A at line %d: Mystirious charachter '%s'\n",yylineno,yytext);}

%%
int yywrap()
{
        return 1;
}

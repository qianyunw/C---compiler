%{
	#include<stdio.h>
	#include "lex.yy.c"
	#include "node.h"
%}
%union {
    struct Node *node;
}

//declare
%token <node> INT FLOAT HEX SCIENNUM ID STRUC
%token <node> TYPE STRUCT RETURN IF ELSE WHILE SPACE SEMI COMMA ASSIGNOP RELOP ANNOTATION PLUS MINUS STAR DIV AND OR DOT NOT LP RP LB RB LC RC AEEROR	
%token <node> EOL
%type <node> Program ExtDefList ExtDef ExtDecList Specifier StructSpecifier OptTag Tag VarDec FunDec VarList ParamDec CompSt StmtList Stmt DefList Def DecList Dec Exp Args

//priority
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV 
%right NOT
%left DOT LP RP LB RB
%%
Program : ExtDefList{$$ = newNode("Program", NULL,0 , 1, $1);
		print($$, 0);}
	;
ExtDefList:ExtDef ExtDefList {$$ = newNode("ExtDefList", NULL, 0, 2, $1, $2);}
	| {$$ = newNode("ExtDefList", NULL, 0, 0);}
	;
ExtDef: Specifier ExtDecList SEMI	{$$ = newNode("ExtDef", NULL, 0, 3, $1, $2, $3);}
	| Specifier SEMI	{$$ = newNode("ExtDef", NULL, 0, 2, $1, $2);}
	| Specifier FunDec CompSt	{$$ = newNode("ExtDef", NULL, 0, 3, $1, $2, $3);}
	;
ExtDecList:VarDec	{$$ = newNode("ExtDecList", NULL, 0, 1, $1);}
	| VarDec COMMA ExtDecList {$$ = newNode("ExtDecList", NULL, 0, 3, $1, $2, $3);}
	;

//Specifire
Specifier:TYPE	{$$ = newNode("Specifier", NULL, 0, 1, $1);}
	| StructSpecifier {$$ = newNode("Specifier", NULL, 0, 1, $1);}
	;
StructSpecifier:STRUCT OptTag LC DefList RC {$$ = newNode("StructSpecifier", NULL, 0, 5, $1, $2, $3, $4, $5);}
	| STRUCT Tag {$$ = newNode("StructSpecifier", NULL, 0, 2, $1, $2);}
	;
//Declarators
OptTag:ID {$$ = newNode("OptTag", NULL, 0, 1, $1);}
	|{$$ = newNode("OptTag", NULL, 0, 0);}
	;
Tag: ID {$$ = newNode("Tag", NULL, 0, 1, $1);}
	;
VarDec: ID	{$$ = newNode("VarDec", NULL, 0, 1, $1);}
	| VarDec LB INT RB {$$ = newNode("VarDec", NULL, 0, 4, $1, $2, $3,$4);}
	;
FunDec: ID LP VarList RP {$$ = newNode("FunDec", NULL, 0, 4, $1, $2, $3, $4);}
|ID LP RP {$$ = newNode("FunDec", NULL, 0, 3, $1, $2, $3);};
VarList : ParamDec COMMA VarList {$$ = newNode("VarList", NULL, 0, 3, $1, $2, $3);}
	| ParamDec {$$ = newNode("VarList", NULL, 0, 1, $1);}
	;
ParamDec:Specifier VarDec {$$ = newNode("ParamDec", NULL, 0, 2, $1, $2);}
	;
//Statements
CompSt: LC DefList StmtList RC {$$ = newNode("CompSt", NULL, 0, 4, $1, $2, $3, $4);}
	;
StmtList: Stmt StmtList {$$ = newNode("StmtList", NULL, 0, 2, $1, $2);}
	| {$$ = newNode("StmtList", NULL, 0, 0);}
	;
Stmt: Exp SEMI {$$ = newNode("Stmt", NULL, 0, 2, $1, $2);}
	| CompSt {$$ = newNode("Stmt", NULL, 0, 1, $1);}
	| RETURN Exp SEMI {$$ = newNode("Stmt", NULL, 0, 3, $1, $2, $3);}
	| IF LP Exp RP Stmt {$$ = newNode("Stmt", NULL, 0, 5, $1, $2, $3, $4, $5);}
	| IF LP Exp RP Stmt ELSE Stmt {$$ = newNode("Stmt", NULL, 0, 7, $1, $2, $3, $4, $5, $6, $7);}
	| WHILE LP Exp RP Stmt {$$ = newNode("Stmt", NULL, 0, 5, $1, $2, $3, $4, $5);}
	;
//Local Definitions 
DefList:Def DefList {$$ = newNode("DefList", NULL, 0, 2, $1, $2);}
	| {$$ = newNode("DefList", NULL, 0, 0);}
	;
Def: Specifier DecList SEMI {$$ = newNode("Def", NULL, 0, 3, $1, $2, $3);}
	;
DecList: Dec {$$ = newNode("DecList", NULL, 0, 1, $1);}
	| Dec COMMA DecList {$$ = newNode("DecList", NULL, 0, 3, $1, $2, $3);}
	;
Dec: VarDec {$$ = newNode("Dec", NULL, 0, 1, $1);}
	| VarDec ASSIGNOP Exp {$$ = newNode("Dec", NULL, 0, 3, $1, $2, $3);}
	;
//Expressions
Exp : Exp ASSIGNOP Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp AND Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp OR Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp RELOP Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp PLUS Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp MINUS Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp STAR Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp DIV Exp {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| LP Exp RP {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| MINUS Exp {$$ = newNode("Exp", NULL, 0, 2, $1, $2);}
	| NOT Exp {$$ = newNode("Exp", NULL, 0, 2, $1, $2);}
	| ID LP Args RP {$$ = newNode("Exp", NULL, 0, 4, $1, $2, $3, $4);}
	| ID LP RP {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| Exp LB Exp RB {$$ = newNode("Exp", NULL, 0, s4, $1, $2, $3, $4);}
	| Exp DOT ID {$$ = newNode("Exp", NULL, 0, 3, $1, $2, $3);}
	| ID {$$ = newNode("Exp", NULL, 0, 1, $1);}
	| INT {$$ = newNode("Exp", NULL, 0, 1, $1);}
	| FLOAT {$$ = newNode("Exp", NULL, 0, 1, $1);}
	;
Args : Exp COMMA Args {$$ = newNode("Args", NULL, 0, 3, $1, $2, $3);}
	| Exp {$$ = newNode("Args", NULL, 0, 1, $1);}
	;
%%
int main(int argc, char** argv)
{
	if(argc>1) {
		if(!(yyin=fopen(argv[1],"r"))) {
	            	perror(argv[1]);
			return 1;
		}
	}
	return yyparse();
}

int yyerror(char *s) {
	return -1;
}



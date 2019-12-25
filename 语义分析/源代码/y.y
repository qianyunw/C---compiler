/*
*Name:y.y
*Author:Wangqianyun
*Created on:2015-11-24
*Version 2.0
*Function:grammatical && semantic analysis
*/
%{
#include<unistd.h>
#include<stdio.h>
#include "h.h"
%}
%union{
struct ast* a;
double d;
}
/*declare tokens*/
%token  <a> INTEGER FLOAT
%token <a> TYPE STRUCT RETURN IF ELSE WHILE ID SPACE SEMI COMMA ASSIGNOP RELOP PLUS
MINUS STAR DIV AND OR DOT NOT LP RP LB RB LC RC AERROR
%token <a> EOL
%type  <a> Program ExtDefList ExtDef ExtDecList Specifire StructSpecifire
OptTag  Tag VarDec  FunDec VarList ParamDec Compst StmtList Stmt DefList Def DecList Dec Exp Args

/*priority*/
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left LP RP LB RB DOT
%%
Program:ExtDefList {$$=newast("Program",1,$1);}
        ;
ExtDefList:ExtDef ExtDefList {$$=newast("ExtDefList",2,$1,$2);}
        | {$$=newast("ExtDefList",0,-1);}
        ;
ExtDef:Specifire ExtDecList SEMI //Error type 3
        {
        $$=newast("ExtDef",3,$1,$2,$3);
	ErrorType3($2);
        newvar(2,$1,$2);
        }
        |Specifire SEMI {$$=newast("ExtDef",2,$1,$2);}
        |Specifire FunDec Compst  //Error type 8
        {
        $$=newast("ExtDef",3,$1,$2,$3);
        newfunc(4,$1);
	ErrorType8();
        }
        ;
ExtDecList:VarDec {$$=newast("ExtDecList",1,$1);}
        |VarDec COMMA ExtDecList {$$=newast("ExtDecList",3,$1,$2,$3);}
        ;

/*Specifire*/
Specifire:TYPE {$$=newast("Specifire",1,$1);}
        |StructSpecifire {$$=newast("Specifire",1,$1);}
        ;

StructSpecifire:STRUCT OptTag LC DefList RC  //Error type 16
        {
        $$=newast("StructSpecifire",5,$1,$2,$3,$4,$5);
	ErrorType16($2);
	newstruc(1,$2);
        }
        |STRUCT Tag  //Error type 17
	{
        $$=newast("StructSpecifire",2,$1,$2);
	ErrorType17($2);
        }
        ;

OptTag:ID {$$=newast("OptTag",1,$1);}
        |{$$=newast("OptTag",0,-1);}
        ;
Tag:ID {$$=newast("Tag",1,$1);}
        ;
/*Declarators*/
VarDec:ID {$$=newast("VarDec",1,$1);$$->tag=1;}
        | VarDec LB INTEGER RB {$$=newast("VarDec",4,$1,$2,$3,$4);$$->content=$1->content;$$->tag=4;}
        ;
FunDec:ID LP VarList RP //Error type 4
        {
	$$=newast("FunDec",4,$1,$2,$3,$4);$$->content=$1->content;
	ErrorType4($1);     
        newfunc(2,$1);
	}
        |ID LP RP //Error type 4
        {
	$$=newast("FunDec",3,$1,$2,$3);$$->content=$1->content;
	ErrorType4($1);     
        newfunc(2,$1);
	}
        ;
VarList:ParamDec COMMA VarList {$$=newast("VarList",3,$1,$2,$3);}
        |ParamDec {$$=newast("VarList",1,$1);}
        ;
ParamDec:Specifire VarDec {$$=newast("ParamDec",2,$1,$2);newvar(2,$1,$2);newfunc(1);}
        ;

/*Statement*/
Compst:LC DefList StmtList RC {$$=newast("Compst",4,$1,$2,$3,$4);}
        ;
StmtList:Stmt StmtList{$$=newast("StmtList",2,$1,$2);}
        | {$$=newast("StmtList",0,-1);}
        ;
Stmt:Exp SEMI {$$=newast("Stmt",2,$1,$2);}
        |Compst {$$=newast("Stmt",1,$1);}
        |RETURN Exp SEMI {$$=newast("Stmt",3,$1,$2,$3);
	$1->type=$2->type;
        newfunc(3,$1);
	}
        |IF LP Exp RP Stmt ELSE Stmt {$$=newast("Stmt",7,$1,$2,$3,$4,$5,$6,$7);}
        |WHILE LP Exp RP Stmt {$$=newast("Stmt",5,$1,$2,$3,$4,$5);}
        ;
/*Local Definitions*/
DefList:Def DefList{$$=newast("DefList",2,$1,$2);}
        | {$$=newast("DefList",0,-1);}
        ;
Def:Specifire DecList SEMI //Error type 3
	{
	$$=newast("Def",3,$1,$2,$3);
	ErrorType3($2);  
        if($2->tag==4) newarray(2,$1,$2);
        else newvar(2,$1,$2);
	}
        ;
DecList:Dec {$$=newast("DecList",1,$1);}
        |Dec COMMA DecList {$$=newast("DecList",3,$1,$2,$3);$$->tag=$3->tag;}
        ;
Dec:VarDec {$$=newast("Dec",1,$1);}
        |VarDec ASSIGNOP Exp {$$=newast("Dec",3,$1,$2,$3);$$->content=$1->content;}
        ;
/*Expressions*/
Exp:Exp ASSIGNOP Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 5
	ErrorType5($1,$3);
	ErrorType6($1);
	}
        |Exp AND Exp{$$=newast("Exp",3,$1,$2,$3);}

        |Exp PLUS Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	ErrorType7($1,$3);
	}
        |Exp MINUS Exp{$$=newast("Exp",3,$1,$2);//Error type 7
	ErrorType7($1,$3);
	}
        |Exp STAR Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	ErrorType7($1,$3);
	}

        |Exp DIV Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	ErrorType7($1,$3);
	}

        |LP Exp RP{$$=newast("Exp",3,$1,$2,$3);}
        |NOT Exp {$$=newast("Exp",2,$1,$2);}

        |ID LP Args RP {$$=newast("Exp",4,$1,$2,$3,$4);//Error type 2 
	ErrorType210($1);
	ErrorType11($1);
	ErrorType9($1);}

        |ID LP RP {$$=newast("Exp",3,$1,$2,$3);}

        |Exp LB Exp RB
        {$$=newast("Exp",4,$1,$2,$3,$4);
	ErrorType210($1);
	//Error type 12 
	ErrorType12($3);
	}

        |Exp DOT ID //Error type 13
        {$$=newast("Exp",3,$1,$2,$3);
	ErrorType13($1);
	if(exitstruc($1)) 
		ErrorType14($1,$3);
	}

        |ID //Error type 1 
        {
        $$=newast("Exp",1,$1);
	ErrorType1($1);
	$$->type=typevar($1);
	}
        
        |INTEGER {$$=newast("Exp",1,$1);$$->tag=3;$$->type="int";$$->value=$1->value;} //int
        |FLOAT{$$=newast("Exp",1,$1);$$->tag=3;$$->type="float";$$->value=$1->value;} //float
        ;
Args:Exp COMMA Args {$$=newast("Args",3,$1,$2,$3);rpnum+=1;} //formal para
        |Exp {$$=newast("Args",1,$1);rpnum+=1;} //formal para
        ;
%%

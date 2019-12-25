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
#include<string.h>
#include "h.h"

int _totalPlace = 1;
int _totalLine = 1;
int _totalLabel = 1;
%}
%union{
struct ast* a;
double d;
}
/*declare tokens*/
%token  <a> INTEGER FLOAT
%token <a> TYPE STRUCT RETURN IF ELSE WHILE ID SPACE SEMI COMMA ASSIGNOP RELOP PLUS MINUS STAR DIV AND OR DOT NOT LP RP LB RB LC RC AERROR
%token <a> EOL
%type  <a> Program ExtDefList ExtDef ExtDecList Specifire StructSpecifire
OptTag  Tag VarDec  FunDec VarList ParamDec Compst StmtList Stmt DefList Def DecList Dec Exp Args IfBegin IfElseBegin WhileBegin

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
Program:ExtDefList {$$=newast("Program",1,$1);
	//printf("print tree\n");
	//eval($$,0);	
	}
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
	printf("%d  FUNCTION %s :\n",_totalLine,$1->content);
	_totalLine = _totalLine + 1;
	}
        |ID LP RP //Error type 4
        {
	$$=newast("FunDec",3,$1,$2,$3);$$->content=$1->content;
	ErrorType4($1);     
        newfunc(2,$1);
	printf("%d  FUNCTION %s :\n",_totalLine,$1->content);
	_totalLine = _totalLine + 1;
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

IfBegin: IF LP Exp RP{$$=newast("IfBegin",4,$1,$2,$3,$4);
	printf("%d  IF %c%d == FALSE GOTO _else_label_%d\n",_totalLine,$3->_vt,$3->_place,_totalLabel);
	$$->_label = _totalLabel;
	_totalLine = _totalLine +1;
	_totalLabel = _totalLabel + 1;	
}
;
IfElseBegin:IfBegin Stmt ELSE{$$=newast("IfElseBegin",3,$1,$2,$3);
	printf("%d  GOTO _else_end_label%d\n",_totalLine,$1->_label);
	printf("%d  LABEL _else_label%d\n",_totalLine+1,$1->_label);
	_totalLine = _totalLine +2 ;
	$$->_label = $1->_label;
}
;
WhileBegin: WHILE LP{$$=newast("WhileBegin",2,$1,$2);
	printf("%d  LABEL _while_label%d\n",_totalLine,_totalLabel);
	_totalLine = _totalLine + 1;
	$$->_label = _totalLabel ;
	_totalLabel = _totalLabel + 1;
}
;

StmtList:Stmt StmtList{$$=newast("StmtList",2,$1,$2);}
        | {$$=newast("StmtList",0,-1);}
        ;
Stmt:	Exp SEMI {$$=newast("Stmt",2,$1,$2);}
        |Compst {$$=newast("Stmt",1,$1);}
        |RETURN Exp SEMI {$$=newast("Stmt",3,$1,$2,$3);
	$1->type=$2->type;
        newfunc(3,$1);
	printf("%d  RETURN %c%d\n",_totalLine,$2->_vt,$2->_place);
	_totalLine = _totalLine + 1;
	}
	|IfBegin Stmt{$$=newast("Stmt",2,$1,$2);
		printf("%d  LABEL _else_label_%d\n",_totalLine,$1->_label);
		_totalLine = _totalLine + 1;
	}
	|IfElseBegin Stmt {$$=newast("Stmt",2,$1,$2);
		printf("%d  LABEL _else_end_label%d\n",_totalLine,$1->_label);
		_totalLine = _totalLine +1;
	}
	|WhileBegin Exp RP Stmt {$$=newast("Stmt",4,$1,$2,$3,$4);
		printf("%d  IF %c%d == TRUE GOTO _while_label%d\n",_totalLine,$2->_vt,$2->_place,$1->_label);
		_totalLine = _totalLine + 1;
	}
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
        |Dec COMMA DecList {$$=newast("DecList",3,$1,$2,$3);
	$$->tag=$3->tag;}
        ;
Dec:VarDec {$$=newast("Dec",1,$1);}
        |VarDec ASSIGNOP Exp {$$=newast("Dec",3,$1,$2,$3);
	$$->content=$1->content;}
        ;
/*Expressions*/
Exp:Exp ASSIGNOP Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 5
	ErrorType5($1,$3);
	ErrorType6($1);
	$$->type = $1->type;
	printf("%d  %c%d := %c%d\n",_totalLine,$1->_vt,$1->_place,$3->_vt,$3->_place);
	_totalLine = _totalLine +1;
	}
        |Exp AND Exp{$$=newast("Exp",3,$1,$2,$3);
	$$->type = "int";
        printf("%d  t%d := %c%d && %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
        _totalLine = _totalLine + 1;
        $$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace + 1;
	}

        |Exp OR Exp{$$=newast("Exp",3,$1,$2,$3);
	$$->type = $1->type;
        printf("%d  t%d := %c%d || %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
        _totalLine = _totalLine + 1;
        $$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace + 1;
	}
	|Exp RELOP Exp {$$=newast("Exp",3,$1,$2,$3);
        $$->type = $1->type;
        $$->_dim = $1->_dim;
	//printf("*****name: %s\n",$2->name);
        printf("%d  t%d := %c%d %s %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$2->content,$3->_vt,$3->_place);
         _totalLine = _totalLine + 1;
         $$->_vt = 't';
         $$->_place = _totalPlace;
         _totalPlace = _totalPlace + 1;
}
        |Exp PLUS Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	$$->type = $1->type;
	$$->value = ($1->value+$3->value);
	ErrorType7($1,$3);
	printf("%d  t%d := %c%d + %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
	_totalLine = _totalLine + 1;
	$$->_vt = 't';
	$$->_place = _totalPlace;
	_totalPlace = _totalPlace + 1;
	}

        |Exp MINUS Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	$$->type = $1->type;
	$$->value = ($1->value-$3->value);
	ErrorType7($1,$3);
 	printf("%d  t%d := %c%d - %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
        _totalLine = _totalLine + 1;
        $$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace + 1; 
	}
        |Exp STAR Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	$$->type = $1->type;
	$$->value = ($1->value*$3->value);
	ErrorType7($1,$3);
 	printf("%d  t%d := %c%d * %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
        _totalLine = _totalLine + 1;
        $$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace + 1;
	}

        |Exp DIV Exp{$$=newast("Exp",3,$1,$2,$3);//Error type 7
	$$->type = $1->type;
	$$->value = ($1->value/$3->value);
	ErrorType7($1,$3);
	printf("%d  t%d := %c%d / %c%d\n",_totalLine,_totalPlace,$1->_vt,$1->_place,$3->_vt,$3->_place);
        _totalLine = _totalLine + 1;
        $$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace + 1;
	}

        |LP Exp RP{$$=newast("Exp",3,$1,$2,$3);
	$$->type = $2->type;
	$$->_vt = $2->_vt;
	$$->_place = $2->_place;
	}
        |NOT Exp {$$=newast("Exp",2,$1,$2);
	$$->type = $2->type;
        printf("%d  t%d := ! %c%d\n",_totalLine,_totalPlace,$2->_vt,$2->_place);
        _totalLine = _totalLine + 1;
	$$->_vt = 't';
	$$->_place = _totalPlace;
	_totalPlace = _totalPlace + 1;
	}

        |ID LP Args RP {$$=newast("Exp",4,$1,$2,$3,$4);//Error type 2 
	$$->type = $1->type;
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
	strcpy($$->id,$1->content);
	$$->type=typevar($1);
	$$->_vt = 'v';
	}
        |INTEGER {$$=newast("Exp",1,$1);
	$$->type = $1->type;
	printf("%d  t%d := #%f\n",_totalLine,_totalPlace,$1->value);
	$$->_vt = 't';
	$$->_place = _totalPlace;
	_totalPlace = _totalPlace +1;
	_totalLine = _totalLine +1;
	} //int
        |FLOAT{$$=newast("Exp",1,$1);
	$$->type = $1->type;
	printf("%d  t%d := #%f\n",_totalLine,_totalPlace,$1->value);
	$$->_vt = 't';
        $$->_place = _totalPlace;
        _totalPlace = _totalPlace +1;
        _totalLine = _totalLine +1;
	} //float
        ;
Args:Exp COMMA Args {$$=newast("Args",3,$1,$2,$3);rpnum+=1;} //formal para
        |Exp {$$=newast("Args",1,$1);rpnum+=1;} //formal para
        ;
%%

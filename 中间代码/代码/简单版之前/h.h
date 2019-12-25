/*
*Name:h.h
*Author:Wangqianyun
*Created on:2016-11-24
*Function:gramer tree& var table& function table& struct table& error judgement
*/
/*from l.l*/
extern int yylineno;//line number
extern char* yytext;//word
void yyerror(char *s);//deal with error 

/*grammer tree*/
struct ast
{
    int line; //line
    char* name;//name of token
    int tag;//1:var 2:function 3:constant 4:array 5:struct
    struct ast* l;//left children
    struct ast* r;//right children
    char* content;//grammer (int i;i is an ID,ID's content is i)
    char* type;//type of this grammer
    float value;//int float 's value

    int i;
    float f;
    char id[30];
    int t;

    int ptag;
};

int used[100];
int newtemp();
void emit(struct ast* tp);

/*var table*/
struct var
{
    char* name;
    char* type;
    struct var *next;
}*varhead,*vartail;

/*func table*/
struct func
{
    int tag;//0:undefined 1:defined
    char* name;
    char* type;
    char* rtype;
    int pnum;//formal parameter number
    struct func *next;
}*funchead,*functail;
int rpnum;//actual parameter number

/*array table*/
struct array
{
    char* name;
    char* type;
    struct array *next;
}*arrayhead,*arraytail;

/*struc table*/
struct struc
{
    char* name;
    char* type;
    struct struc *next;
    struct ast* structContent;
}*struchead,*structail;

/*=====ast========================*/
/*create*/
struct ast *newast(char* name,int num,...);

/*is defined?*/
void eval(struct ast*,int level);

/*=================var table==============*/
/*create*/
void newvar(int num,...);

/*is defined? yes:1 no:0*/
int  exitvar(struct ast*tp);

/*return type*/
char* typevar(struct ast*tp);

/*=================func table==============*/
/*create*/
void newfunc(int num,...);

/*is defined? yes:1 no:0*/
int extitfunc(struct ast*tp);

/*return type*/
char* typefunc(struct ast*tp);

/*return formal parameter number*/
int pnumfunc(struct ast*tp);

/*=================array table==============*/
/*create*/
void newarray(int num,...);

/*is defined? yes:1 no:0*/
int extitarray(struct ast*tp);

/*return type*/
char* typearray(struct ast*tp);

/*=================struc table==============*/
/*create*/
void newstruc(int num,...);

int  exitstruc(struct ast* tp);

void get_args_member(struct ast* root, struct ast* structContent);

/*is defined? yes:1 no:0*/
int extitstruc(struct ast*tp);


/*=================error==============*/

// Undefined variable
void ErrorType1(struct ast* root);

//Undefined function 
void ErrorType210(struct ast* root);

//Redefined variable 
void ErrorType3(struct ast* root);

//Redefined function 
void ErrorType4(struct ast* root);

//Type mismatched for assignment.
void ErrorType5(struct ast* root1, struct ast* root2);

//The left-hand side of an assignmen must be variable.
void ErrorType6(struct ast* root);

//Type mismatched at for oprands.
void ErrorType7(struct ast* root1, struct ast* root2);

//Type mismatched for return.
void ErrorType8();

//check args number
void ErrorType9(struct ast* def);

//use variable as array
void ErrorType10(struct ast* root);

//use variable as fuction
void ErrorType11(struct ast* root);

//not use integer when accessing an array 
void ErrorType12(struct ast* root);

//use '.' in a non-struct
void ErrorType13(struct ast* root);

//access undefined range of a struct
void ErrorType14(struct ast* root, struct ast* use);

//redefined the range of a struct
void ErrorType15(struct ast* root);

//redefined the name of a struct
void ErrorType16(struct ast* root);

//Redefined struct
void ErrorType17(struct ast* root);


/*
*Name:c.c
*Author:Wangqianyun
*Created on:2016-11-24
*Function:realize h.h
*/
# include<stdio.h>
# include<stdlib.h>
# include<stdarg.h>
# include<string.h>
# include"h.h"
/**
int newtemp()
{
    int i=0;
    for(i=0; i<100; ++i)
    {
        if(used[i]==0)
        {
            used[i]=i+1;
            return i;
        }
    }
}

void emit(struct ast* tp)
{
    if(tp->ptag == 1)
        printf("%d",tp->i);
    else if(tp->ptag==2)
        printf("%2f",tp->f);
    else if(tp->ptag==3)
        printf("%s",tp->id);
    else
        printf("t%d",tp->t);
}
**/
int i;
struct ast *newast(char* name,int num,...)
{
    va_list valist; 
    struct ast *a=(struct ast*)malloc(sizeof(struct ast));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    if(!a)
    {
        yyerror("out of space");
        exit(0);
    }
    a->name=name;
    va_start(valist,num);

    if(num>0)
    {
        temp=va_arg(valist, struct ast*);
        a->l=temp;
        a->line=temp->line;
        if(num==1)
        {
            a->content=temp->content;
            a->tag=temp->tag;
            //a->type=temp->type;
            //a->value=temp->value;
        }
        else
        {
            for(i=0; i<num-1; ++i)
            {
                temp->r=va_arg(valist,struct ast*);
                temp=temp->r;
            }
        }
    }
    else 
    {
        int t=va_arg(valist, int);
        a->line=t;
        if(!strcmp(a->name,"INTEGER"))
        {
            a->type="int";
            a->value=atof(yytext);
        }
        else if(!strcmp(a->name,"FLOAT"))
        {
            a->type="float";
            a->value=atof(yytext);
        }
        else
        {
            char* s;
            s=(char*)malloc(sizeof(char* )*40);
            strcpy(s,yytext);
            a->content=s;
        }
    }
    return a;
}
void eval(struct ast *a,int level)
{
    if(a!=NULL)
    {
        for(i=0; i<level; ++i)
            printf("  ");
        if(a->line!=-1) 
        {
            printf("%s ",a->name);
            if((!strcmp(a->name,"ID"))||(!strcmp(a->name,"TYPE")))printf(":%s ",a->content);
            else if(!strcmp(a->name,"INTEGER"))printf(":%f",a->value);
            else if(!strcmp(a->name,"FLOAT"))printf(":%f",a->value);
            else
                printf("(%d)",a->line);
        }
        printf("\n");
        eval(a->l,level+1);
        eval(a->r,level);
    }
}
/*====var================*/
void newvar(int num,...)
{
    va_list valist; 
    struct var *a=(struct var*)malloc(sizeof(struct var));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    temp=va_arg(valist, struct ast*);
    a->type=temp->content;
    temp=va_arg(valist, struct ast*);
    a->name=temp->content;
    vartail->next=a;
    vartail=a;
}

int  exitvar(struct ast* tp)
{
    struct var* p=(struct var*)malloc(sizeof(struct var*));
    p=varhead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;   
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}

char* typevar(struct ast*tp)
{
    struct var* p=(struct var*)malloc(sizeof(struct var*));
    p=varhead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;
        p=p->next;
    }
}
/*====func================*/
void newfunc(int num,...)
{
    va_list valist;
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    switch(num)
    {
    case 1:
        functail->pnum+=1;
        break;
    case 2:
        temp=va_arg(valist, struct ast*);
        functail->name=temp->content;
        break;
    case 3:
        temp=va_arg(valist, struct ast*);
        functail->rtype=temp->type;
        break;
    default:
        rpnum=0;
        temp=va_arg(valist, struct ast*);
        if(functail->rtype!=NULL)
        {
            if(strcmp(temp->content,functail->rtype))
		printf("Error type 8 at Line %d:Type mismatched for return.\n",yylineno);
        }
        functail->type=temp->type;
        functail->tag=1;
        struct func *a=(struct func*)malloc(sizeof(struct func));
        functail->next=a;
        functail=a;
        break;
    }
}

int  exitfunc(struct ast* tp)
{
    int flag=0;
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL&&p->name!=NULL&&p->tag==1)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;
            return 1;
        }
        p=p->next;
    }
    if(!flag)
        return 0;
}
char* typefunc(struct ast*tp)
{
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;
        p=p->next;
    }
}

int pnumfunc(struct ast*tp)
{
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->pnum;
        p=p->next;
    }
}

/*====array================*/
void newarray(int num,...)
{
    va_list valist;
    struct array *a=(struct array*)malloc(sizeof(struct array));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    temp=va_arg(valist, struct ast*);
    a->type=temp->content;
    temp=va_arg(valist, struct ast*);
    a->name=temp->content;
    arraytail->next=a;
    arraytail=a;
}

int  exitarray(struct ast* tp)
{
    struct array* p=(struct array*)malloc(sizeof(struct array*));
    p=arrayhead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;   
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}

char* typearray(struct ast* tp)
{
    struct array* p=(struct array*)malloc(sizeof(struct array*));
    p=arrayhead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;
        p=p->next;
    }
}
/*====struc================*/
void newstruc(int num,...)
{
    	va_list valist;
   	struct struc *a=(struct struc*)malloc(sizeof(struct struc));
   	struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
	va_start(valist,num);
	temp=va_arg(valist, struct ast*);
	a->name=temp->content;
	a->structContent=(struct ast*)malloc(sizeof(struct ast));
	a->structContent->content = "";
	a->structContent->r = NULL;
	get_args_member(temp->r->r, a->structContent);	
	structail->next = a;
	structail = a;
}


void get_args_member(struct ast* root, struct ast* structContent)
{
	struct ast* current;
	if(root->l != NULL)
	{
		current = root->l;
		while(current != NULL)
		{
			if(!strcmp(current->name,"ID") || !strcmp(current->name,"INT") || !strcmp(current->name,"FLOAT"))
			{
				while(structContent->r != NULL) {
					structContent = structContent->r;
				}
	structContent->r = (struct ast*)malloc(sizeof(struct ast));
	structContent->r->content = current->content;	
	structContent->r->r = NULL;	
			}			
			get_args_member(current, structContent);
			current = current->r; 	
		}
	}
}

int  exitstruc(struct ast* tp)
{
    struct struc* p=(struct struc*)malloc(sizeof(struct struc*));
    p=struchead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;   
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}


/*=================error==============*/

// Undefined variable
void ErrorType1(struct ast* root) {
	if(!exitvar(root)&&!exitarray(root)&&!exitstruc(root)&&!exitfunc(root))
            printf("Error type 1 at Line %d:undefined variable %s\n ",yylineno,root->content);
}

//Undefined function 
void ErrorType210(struct ast* root) {
	if(!strcmp(root->r->name, "LB")) {
		if(exitvar(root)) 
			printf("Error type 10 at Line %d:'%s'is not an array.\n ",yylineno,root->content);
	}
	else if(!strcmp(root->r->name, "LP")) {
		if(!exitfunc(root))
			printf("Error type 2 at Line %d:undefined Function %s\n ",yylineno,root->content);
	}
}

//Redefined variable 
void ErrorType3(struct ast* root) {
	if(exitvar(root)||exitarray(root))
		printf("Error type 3 at Line %d:Redefined Variable '%s'\n",yylineno,root->content);
}

//Redefined function 
void ErrorType4(struct ast* root) {
	if(exitfunc(root))
		printf("Error type 4 at Line %d:Redefined Function '%s'\n",yylineno,root->content);
}

//Type mismatched for assignment.
void ErrorType5(struct ast* root1, struct ast* root2) {	 
	if(strcmp(root1->type, root2->type))
		printf("Error type 5 at Line %d:Type mismatched for assignment.\n ",yylineno);
}

//The left-hand side of an assignmen must be variable.
void ErrorType6(struct ast* root) {
	if(!exitvar(root))
		printf("Error type 6 at Line %d:The left-hand side of an assignmen must be variable.\n ",yylineno);
}

//Type mismatched at for oprands.
void ErrorType7(struct ast* root1, struct ast* root2) {
	if(strcmp(root1->type,root2->type))
		printf("Error type 7 at Line %d:Type mismatched for operand.\n ",yylineno);

}

//Type mismatched for return.
void ErrorType8()
{	
	//mentioned before;
}

//check args number
void ErrorType9(struct ast* def) {
	if(pnumfunc(def) != rpnum)
		printf("Error type 9 at Line %d:Function '%s' parameter use error.\n", yylineno, def->content);
}

//use variable as array
void ErrorType10(struct ast* root) {
}

//use variable as fuction
void ErrorType11(struct ast* root) {
	if(!exitfunc(root))
		printf("Error type 11 at Line %d:%s is not a function.\n",yylineno,root->content);
}

//not use integer when accessing an array 
void ErrorType12(struct ast* root) {
	if(strcmp(root->type,"int"))
		printf("Error type 12 at Line %d:%.1f is not a integer.\n",yylineno,root->value);
}

//use '.' in a non-struct
void ErrorType13(struct ast* root) {
	if(!exitstruc(root))
		printf("Error type 13 at Line %d:Illegal use of '.'.\n",yylineno);
}



//access undefined range of a struct
void ErrorType14(struct ast* root, struct ast* use) {
	struct struc* p=(struct struc*)malloc(sizeof(struct struc*));
    	p=struchead->next;
    	while(strcmp(p->name,root->content))
    	{
        	p=p->next;
    	}
	int tag = 0;
	struct ast* current = p->structContent;
	while(current != NULL) {
		if(!strcmp(current->content,use->content)) {
			tag = 1;
			break;
		}
		current = current->r;
	}
	if(!tag) 
		printf("Error type 14 at Line %d:Undefined '%s' in struct %s.\n",yylineno, use->content, root->content);
}

//redefined the range of a struct
void ErrorType15(struct ast* root) {
}

//redefined the name of a struct
void ErrorType16(struct ast* root) {
        if(exitstruc(root))
		printf("Error type 16 at Line %d:Duplicated name '%s'\n",yylineno,root->content);
}

//Redefined struct
void ErrorType17(struct ast* root) {
        if(!exitstruc(root)) 
		printf("Error type 17 at Line %d:undefined structure '%s'\n",yylineno,root->content);
}

void yyerror(char*s) //deal with error
{
/**
    va_list ap;
    va_start(ap,s);

    fprintf(stderr,"%d:error:",yylineno);//error line number
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
**/
}
int main()
{
    varhead=(struct var*)malloc(sizeof(struct var));
    vartail=varhead;

    funchead=(struct func*)malloc(sizeof(struct func));
    functail=(struct func*)malloc(sizeof(struct func));
    funchead->next=functail;
    functail->pnum=0;

    arrayhead=(struct array*)malloc(sizeof(struct array));
    arraytail=arrayhead;

    struchead=(struct struc*)malloc(sizeof(struct struc));
    structail=struchead;

    return yyparse();
}

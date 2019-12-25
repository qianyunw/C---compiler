#ifndef lab2_h
#define lab2_h
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

struct Node {
char *type;  
char *value;
unsigned line; 
struct Node *firstChild; 
struct Node *nextSibling;
};
struct Node *newNode(char *type, char *val, unsigned ln, unsigned count, ...);
void space(unsigned depth);
void print(struct Node* root, unsigned depth);
#endif

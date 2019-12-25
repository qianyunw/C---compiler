#include "node.h"

struct Node *newNode(char *type, char *val, unsigned ln, unsigned count, ...) 
{
    va_list args;
    va_start(args, count);
    char *Value = NULL;
    if (val) {
        Value = malloc(strlen(val));
        strcpy(Value, val);
    }
    struct Node *root = malloc(sizeof(struct Node));
    root->type = type;
    root->value = Value;
    root->line = ln;
    root->nextSibling = NULL;
    if (count) {
        struct Node * current = root->firstChild = va_arg(args, struct Node*);
        int i = 1;
        for(i = 1; i < count; ++i){
            current = current->nextSibling = va_arg(args, struct Node*);
        }
        current->nextSibling = NULL;
    } else {
        root->firstChild = NULL;
    }
    if(root->firstChild != NULL) {
        root->line = root->firstChild->line;
    }
    va_end (args);
    return root;
}
void space(unsigned depth) {
    while (depth--) {
        printf("  ");
    }
}

void print(struct Node* root, unsigned depth) {
    space(depth);
    if (root->value){
        printf("%s: %s\n", root->type, root->value);
    } else {
        if(root->firstChild == NULL /*&& root->nextSibling ==NULL*/)
        {
           printf("%s\n", root->type);
        }
        else
        {
            printf("%s (%d)\n", root->type, root->line);
        }
    }
    struct Node *current = root->firstChild;
    while (current) {
       print(current, depth + 1);
       current = current->nextSibling;
    }
}

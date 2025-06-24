#include "ast.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

ASTNode* create_literal_node(char *type, int int_val, float float_val, char *str) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_LITERAL;
    node->data_type = strdup(type);
    node->left = node->right = node->extra = NULL;
    if (strcmp(type, "int") == 0)
        node->value.int_val = int_val;
    else if (strcmp(type, "float") == 0)
        node->value.float_val = float_val;
    else
        node->value.str_val = strdup(str);
    return node;
}

ASTNode* create_identifier_node(char *name) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_IDENTIFIER;
    node->identifier = strdup(name);
    node->left = node->right = node->extra = NULL;
    return node;
}

ASTNode* create_binary_op_node(char *op, ASTNode *left, ASTNode *right) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_BINARY_OP;
    node->identifier = strdup(op);
    node->left = left;
    node->right = right;
    node->extra = NULL;
    return node;
}

ASTNode* create_assignment_node(char *id, ASTNode *expr) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_ASSIGN;
    node->identifier = strdup(id);
    node->left = create_identifier_node(id);
    node->right = expr;
    node->extra = NULL;
    return node;
}

ASTNode* create_declaration_node(char *type, char *id, ASTNode *init) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_DECL;
    node->data_type = strdup(type);
    node->identifier = strdup(id);
    node->left = init;
    node->right = node->extra = NULL;
    return node;
}

ASTNode* create_if_node(ASTNode *cond, ASTNode *then_branch, ASTNode *else_branch) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_IF;
    node->left = cond;
    node->right = then_branch;
    node->extra = else_branch;
    return node;
}

ASTNode* create_func_call_node(char *name, ASTNode *args) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = NODE_TYPE_FUNC_CALL;
    node->identifier = strdup(name);
    node->left = args;
    node->right = node->extra = NULL;
    return node;
}

void print_ast(ASTNode *node, int level) {
    if (!node) return;

    for (int i = 0; i < level; i++) printf("    ");  // simple indent
    printf("- ");

    switch (node->type) {
        case NODE_TYPE_LITERAL:
            if (strcmp(node->data_type, "int") == 0)
                printf("Literal (int): %d\n", node->value.int_val);
            else if (strcmp(node->data_type, "float") == 0)
                printf("Literal (float): %f\n", node->value.float_val);
            else if (strcmp(node->data_type, "char") == 0)
                printf("Literal (char): '%c'\n", node->value.char_val);
            else if (strcmp(node->data_type, "string") == 0)
                printf("Literal (string): \"%s\"\n", node->value.str_val);
            break;

        case NODE_TYPE_IDENTIFIER:
            printf("Identifier: %s\n", node->identifier);
            break;

        case NODE_TYPE_BINARY_OP:
            printf("BinaryOp: %s\n", node->identifier);
            print_ast(node->left, level + 1);
            print_ast(node->right, level + 1);
            break;

        case NODE_TYPE_ASSIGN:
            printf("Assign: %s\n", node->identifier);
            print_ast(node->right, level + 1);
            break;

        case NODE_TYPE_DECLARATION:
            printf("Declaration: %s %s\n", node->data_type, node->identifier);
            break;

        case NODE_TYPE_FUNC_CALL:
            printf("FuncCall: %s\n", node->identifier);
            print_ast(node->left, level + 1);
            break;

        default:
            printf("Unknown AST Node\n");
    }
}
void type_check(ASTNode *node) {
    if (!node) return;

    // Assignment mismatch
    if (node->type == NODE_TYPE_ASSIGN) {
        if (node->left && node->right && node->left->data_type && node->right->data_type) {
            if (strcmp(node->left->data_type, node->right->data_type) != 0) {
                fprintf(stderr,
                    "Semantic Error: Type mismatch in assignment to '%s' (expected %s, got %s)\n",
                    node->identifier ? node->identifier : "unknown",
                    node->left->data_type,
                    node->right->data_type);
            }
        }
    }

    // Division by zero
    if (node->type == NODE_TYPE_BINARY_OP && node->identifier && strcmp(node->identifier, "/") == 0) {
        if (node->right && node->right->type == NODE_TYPE_LITERAL && node->right->data_type &&
            strcmp(node->right->data_type, "int") == 0 && node->right->value.int_val == 0) {
            fprintf(stderr, "Semantic Error: Division by zero.\n");
        }
    }

    // Recursive check
    type_check(node->left);
    type_check(node->right);
    type_check(node->extra);
}
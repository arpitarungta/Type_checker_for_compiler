#ifndef AST_H
#define AST_H

#define INT_VAL(node) ((node)->value.int_val)
#define FLOAT_VAL(node) ((node)->value.float_val)
#define STR_VAL(node) ((node)->value.str_val)

typedef enum {
    NODE_TYPE_DECL, NODE_TYPE_ASSIGN, NODE_TYPE_BINARY_OP, NODE_TYPE_LITERAL, NODE_TYPE_IDENTIFIER,
    NODE_TYPE_IF, NODE_TYPE_WHILE, NODE_TYPE_FOR, NODE_TYPE_SWITCH, NODE_TYPE_CASE,
    NODE_TYPE_BREAK, NODE_TYPE_CONTINUE, NODE_TYPE_RETURN, NODE_TYPE_FUNC_DEF,
    NODE_TYPE_FUNC_CALL, NODE_TYPE_ARRAY_DECL, NODE_TYPE_ARRAY_ACCESS, NODE_TYPE_DECLARATION
} NodeType;

typedef struct ASTNode {
    NodeType type;
    char *data_type;
    char *identifier;
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *extra; // for else-branch, function args, etc.
    union {
        int int_val;
        float float_val;
        char char_val;
        char *str_val;
    } value;
} ASTNode;

ASTNode* create_literal_node(char *type, int int_val, float float_val, char *str);
ASTNode* create_identifier_node(char *name);
ASTNode* create_binary_op_node(char *op, ASTNode *left, ASTNode *right);
ASTNode* create_assignment_node(char *id, ASTNode *expr);
ASTNode* create_declaration_node(char *type, char *id, ASTNode *init);
ASTNode* create_if_node(ASTNode *cond, ASTNode *then_branch, ASTNode *else_branch);
ASTNode* create_func_call_node(char *name, ASTNode *args);
void print_ast(ASTNode *node, int level);
void type_check(ASTNode *node);

#endif
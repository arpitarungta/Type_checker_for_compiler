%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylineno;
ASTNode *root;
int yylex(void);
void yyerror(const char *s);

int current_scope = 0;
int semantic_error_found = 0;

typedef enum { SYM_VAR, SYM_FUNC } SymbolKind;

typedef struct Symbol {
    char *name;
    char *type;
    SymbolKind kind;
    int initialized;
    union {
        int int_val;
        float float_val;
        char char_val;
    } value;
    int scope_level;
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;

void enter_scope() { current_scope++; }
void exit_scope()  { current_scope--; }

void insert_symbol(const char *name, const char *type, SymbolKind kind) {
    Symbol *sym = malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->type = strdup(type);
    sym->kind = kind;
    sym->initialized = 0;
    sym->scope_level = current_scope;
    sym->next = symbol_table;
    symbol_table = sym;
}

Symbol* get_symbol(const char *name) {
    Symbol *cur = symbol_table;
    while (cur) {
        if (strcmp(cur->name, name) == 0 && cur->scope_level <= current_scope) return cur;
        cur = cur->next;
    }
    return NULL;
}

void mark_initialized(const char *name) {
    Symbol *sym = get_symbol(name);
    if (sym) sym->initialized = 1;
}

void print_symbol_table() {
    printf("\nSymbol Table:\n");
    printf("---------------------------------------------------------------\n");
    printf("| %-15s | %-10s | %-8s | %-4s |\n", "Name", "Type", "Kind", "Scope");
    printf("---------------------------------------------------------------\n");
    Symbol *cur = symbol_table;
    while (cur) {
        printf("| %-15s | %-10s | %-8s | %-4d |\n",
               cur->name,
               cur->type,
               cur->kind == SYM_VAR ? "var" : "func",
               cur->scope_level);
        cur = cur->next;
    }
    printf("---------------------------------------------------------------\n");
}
%}

%union {
    int intval;
    float floatval;
    char *str;
    struct ASTNode *node;
}

%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR
%token GOTO IF INT LONG REGISTER RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF
%token UNION UNSIGNED VOID VOLATILE WHILE STRING

%token <str> IDENTIFIER DEC_CONSTANT FLOAT_CONSTANT STRING_LITERAL HEX_CONSTANT OCT_CONSTANT CHAR_LITERAL

%token EQ NEQ LE GE AND OR SHL SHR INC DEC
%token PLUS MINUS STAR FW_SLASH MOD
%token LT GT ASSIGN BITAND BITOR BITXOR BITNOT NOT

%token DELIMITER COMMA OPEN_PAR CLOSE_PAR OPEN_BRACE CLOSE_BRACE OPEN_BRACKET CLOSE_BRACKET

%left PLUS MINUS
%left STAR FW_SLASH
%right UMINUS

%type <node> program stmt stmt_list block expr arg_list
%type <str> type

%%

program:
    stmt_list { root = $1; }
    ;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { $$ = create_binary_op_node(";", $1, $2); }
    ;

stmt:
    type IDENTIFIER ASSIGN expr DELIMITER {
        if (get_symbol($2)) {
            fprintf(stderr, "Semantic Error: Variable '%s' redeclared\n", $2);
            semantic_error_found = 1;
        }
        $$ = create_assignment_node($2, $4);
        $$->left = create_declaration_node($1, $2, NULL);
        $$->right->data_type = $4->data_type;
        $$->left->data_type = strdup($1);
        if (strcmp($1, $4->data_type) != 0) {
            fprintf(stderr, "Semantic Error: Type mismatch in assignment to '%s' (declared as %s, assigned %s)\n",
            $2, $1, $4->data_type);
            semantic_error_found = 1;
        }
        insert_symbol($2, $1, SYM_VAR);
        mark_initialized($2);
    }
    | IDENTIFIER ASSIGN expr DELIMITER {
        Symbol *sym = get_symbol($1);
        if (!sym) {
            fprintf(stderr, "Semantic Error: '%s' not declared\n", $1);
            semantic_error_found = 1;
        }
        $$ = create_assignment_node($1, $3);
        $$->left = create_identifier_node($1);
        $$->left->data_type = sym ? strdup(sym->type) : strdup("unknown");
        $$->right->data_type = $3->data_type;
        mark_initialized($1);
    }
    | type IDENTIFIER DELIMITER {
        if (get_symbol($2)) {
            fprintf(stderr, "Semantic Error: Variable '%s' redeclared\n", $2);
            semantic_error_found = 1;
        }
        $$ = create_declaration_node($1, $2, NULL);
        insert_symbol($2, $1, SYM_VAR);
    }
    | RETURN expr DELIMITER {
        $$ = create_binary_op_node("return", $2, NULL);
    }
    | IF OPEN_PAR expr CLOSE_PAR stmt {
        $$ = create_binary_op_node("if", $3, $5);
    }
    | IF OPEN_PAR expr CLOSE_PAR stmt ELSE stmt {
        ASTNode *if_node = create_binary_op_node("if", $3, $5);
        $$ = create_binary_op_node("else", if_node, $7);
    }
    | WHILE OPEN_PAR expr CLOSE_PAR stmt {
        $$ = create_binary_op_node("while", $3, $5);
    }
    | type IDENTIFIER OPEN_PAR CLOSE_PAR block {
        insert_symbol($2, $1, SYM_FUNC);
        $$ = create_binary_op_node("function", create_identifier_node($2), $5);
    }
    | expr DELIMITER { $$ = $1;
    }
    | block { $$ = $1; }
    ;

block:
    OPEN_BRACE { enter_scope(); } stmt_list CLOSE_BRACE { exit_scope(); $$ = $3; }
    ;

type:
    INT { $$ = strdup("int"); }
    | FLOAT { $$ = strdup("float"); }
    | CHAR { $$ = strdup("char"); }
    | STRING { $$ = strdup("string"); }
    ;

expr:
    expr PLUS expr { $$ = create_binary_op_node("+", $1, $3); $$->data_type = $1->data_type; }
    | expr MINUS expr { $$ = create_binary_op_node("-", $1, $3); $$->data_type = $1->data_type; }
    | expr STAR expr { $$ = create_binary_op_node("*", $1, $3); $$->data_type = $1->data_type; }
    | expr FW_SLASH expr {
        $$ = create_binary_op_node("/", $1, $3);
        if (strcmp($3->data_type, "int") == 0 && $3->type == NODE_TYPE_LITERAL && $3->value.int_val == 0) {
            fprintf(stderr, "Semantic Error: Division by zero at line %d\n", yylineno);
        }
        $$->data_type = $1->data_type;
    }
    | MINUS expr %prec UMINUS {
        $$ = create_binary_op_node("UMINUS", $2, NULL);
        $$->data_type = $2->data_type;
    }
    | expr GT expr { $$ = create_binary_op_node(">", $1, $3); $$->data_type = strdup("int"); }
    | expr LT expr { $$ = create_binary_op_node("<", $1, $3); $$->data_type = strdup("int"); }
    | expr EQ expr { $$ = create_binary_op_node("==", $1, $3); $$->data_type = strdup("int"); }
    | expr NEQ expr { $$ = create_binary_op_node("!=", $1, $3); $$->data_type = strdup("int"); }
    | expr GE expr { $$ = create_binary_op_node(">=", $1, $3); $$->data_type = strdup("int"); }
    | expr LE expr { $$ = create_binary_op_node("<=", $1, $3); $$->data_type = strdup("int"); }
    | DEC_CONSTANT { $$ = create_literal_node("int", atoi($1), 0, NULL); $$->data_type = strdup("int"); }
    | FLOAT_CONSTANT { $$ = create_literal_node("float", 0, atof($1), NULL); $$->data_type = strdup("float"); }
    | STRING_LITERAL { $$ = create_literal_node("string", 0, 0, $1); $$->data_type = strdup("string"); }
    | CHAR_LITERAL { $$ = create_literal_node("char", (int)$1[1], 0, NULL); $$->data_type = strdup("char"); }
    | IDENTIFIER {
        $$ = create_identifier_node($1);
        Symbol *sym = get_symbol($1);
        $$->data_type = sym ? strdup(sym->type) : strdup("unknown");
    }
    | IDENTIFIER OPEN_PAR arg_list CLOSE_PAR {
        $$ = create_func_call_node($1, $3);
    }
    ;

arg_list:
    expr COMMA arg_list { $$ = create_binary_op_node(",", $1, $3); }
    | expr { $$ = $1; }
    | /* empty */ { $$ = NULL; }
    ;

%%

int main() {
    insert_symbol("printf", "int", SYM_FUNC);
    yyparse();
    printf("\nGenerated AST:\n");
    print_ast(root, 0);
    printf("\nSemantic Analysis:\n");
    type_check(root);
    if (semantic_error_found) {
        printf("Semantic Errors were found during analysis.\n");
    }else{
        printf("No semantic Errors were found during analysis.\n");
    }
    printf("Semantic analysis completed.\n");
    print_symbol_table();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

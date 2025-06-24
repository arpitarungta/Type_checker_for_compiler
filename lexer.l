%{
#include "ast.h"     
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
int yylineno = 1;
void yyerror(const char *s);
%}

DIGIT           [0-9]
LETTER          [a-zA-Z_]
IDENTIFIER      {LETTER}({LETTER}|{DIGIT})*
HEX_CONSTANT    0[xX][0-9a-fA-F]+
OCT_CONSTANT    0[0-7]+
DEC_CONSTANT    [1-9][0-9]*|0
FLOAT_CONSTANT  ([0-9]\.[0-9]+([eE][-+]?[0-9]+)?)|([0-9]+\.[0-9]([eE][-+]?[0-9]+)?)

STRING_LITERAL  \"([^\\\"]|\\.)*\"
CHAR_LITERAL    \'([^\\\']|\\.)\'

WHITESPACE      [ \t\r]+

%%

"auto"          { return AUTO; }
"break"         { return BREAK; }
"case"          { return CASE; }
"char"          { return CHAR; }
"const"         { return CONST; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"do"            { return DO; }
"double"        { return DOUBLE; }
"else"          { return ELSE; }
"enum"          { return ENUM; }
"extern"        { return EXTERN; }
"float"         { return FLOAT; }
"for"           { return FOR; }
"goto"          { return GOTO; }
"if"            { return IF; }
"int"           { return INT; }
"long"          { return LONG; }
"register"      { return REGISTER; }
"return"        { return RETURN; }
"short"         { return SHORT; }
"signed"        { return SIGNED; }
"sizeof"        { return SIZEOF; }
"static"        { return STATIC; }
"struct"        { return STRUCT; }
"switch"        { return SWITCH; }
"typedef"       { return TYPEDEF; }
"union"         { return UNION; }
"unsigned"      { return UNSIGNED; }
"void"          { return VOID; }
"volatile"      { return VOLATILE; }
"while"         { return WHILE; }
"string"        { return STRING; }
"#include"[^\n]*     { /* Ignore preprocessor includes */ }

{IDENTIFIER}    { yylval.str = strdup(yytext); return IDENTIFIER; }
{HEX_CONSTANT}  { yylval.str = strdup(yytext); return HEX_CONSTANT; }
{OCT_CONSTANT}  { yylval.str = strdup(yytext); return OCT_CONSTANT; }
{DEC_CONSTANT}  { yylval.str = strdup(yytext); return DEC_CONSTANT; }
{FLOAT_CONSTANT} { yylval.str = strdup(yytext); return FLOAT_CONSTANT; }

{STRING_LITERAL} { yylval.str = strdup(yytext); return STRING_LITERAL; }
{CHAR_LITERAL}  { yylval.str = strdup(yytext); return CHAR_LITERAL; }

"//".*          { /* single line comment - ignore */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* multi-line comment - ignore */ }

"#".*           { /* preprocessor directive - ignore */ }

"=="            { return EQ; }
"!="            { return NEQ; }
"<="            { return LE; }
">="            { return GE; }
"&&"            { return AND; }
"||"            { return OR; }
"<<"            { return SHL; }
">>"            { return SHR; }
"++"            { return INC; }
"--"            { return DEC; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return STAR; }
"/"             { return FW_SLASH; }
"%"             { return MOD; }

"<"             { return LT; }
">"             { return GT; }
"="             { return ASSIGN; }
"&"             { return BITAND; }
"|"             { return BITOR; }
"^"             { return BITXOR; }
"~"             { return BITNOT; }
"!"             { return NOT; }

";"             { return DELIMITER; }
","             { return COMMA; }
"("             { return OPEN_PAR; }
")"             { return CLOSE_PAR; }
"{"             { return OPEN_BRACE; }
"}"             { return CLOSE_BRACE; }
"["             { return OPEN_BRACKET; }
"]"             { return CLOSE_BRACKET; }

{WHITESPACE}    { /* ignore whitespace */ }
\n              { yylineno++; }

.               { fprintf(stderr, "Unknown character '%s' at line %d\n", yytext, yylineno); }

%%

int yywrap() { return 1; }
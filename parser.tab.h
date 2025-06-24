
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     AUTO = 258,
     BREAK = 259,
     CASE = 260,
     CHAR = 261,
     CONST = 262,
     CONTINUE = 263,
     DEFAULT = 264,
     DO = 265,
     DOUBLE = 266,
     ELSE = 267,
     ENUM = 268,
     EXTERN = 269,
     FLOAT = 270,
     FOR = 271,
     GOTO = 272,
     IF = 273,
     INT = 274,
     LONG = 275,
     REGISTER = 276,
     RETURN = 277,
     SHORT = 278,
     SIGNED = 279,
     SIZEOF = 280,
     STATIC = 281,
     STRUCT = 282,
     SWITCH = 283,
     TYPEDEF = 284,
     UNION = 285,
     UNSIGNED = 286,
     VOID = 287,
     VOLATILE = 288,
     WHILE = 289,
     STRING = 290,
     IDENTIFIER = 291,
     DEC_CONSTANT = 292,
     FLOAT_CONSTANT = 293,
     STRING_LITERAL = 294,
     HEX_CONSTANT = 295,
     OCT_CONSTANT = 296,
     CHAR_LITERAL = 297,
     EQ = 298,
     NEQ = 299,
     LE = 300,
     GE = 301,
     AND = 302,
     OR = 303,
     SHL = 304,
     SHR = 305,
     INC = 306,
     DEC = 307,
     PLUS = 308,
     MINUS = 309,
     STAR = 310,
     FW_SLASH = 311,
     MOD = 312,
     LT = 313,
     GT = 314,
     ASSIGN = 315,
     BITAND = 316,
     BITOR = 317,
     BITXOR = 318,
     BITNOT = 319,
     NOT = 320,
     DELIMITER = 321,
     COMMA = 322,
     OPEN_PAR = 323,
     CLOSE_PAR = 324,
     OPEN_BRACE = 325,
     CLOSE_BRACE = 326,
     OPEN_BRACKET = 327,
     CLOSE_BRACKET = 328,
     UMINUS = 329
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 79 "parser.y"

    int intval;
    float floatval;
    char *str;
    struct ASTNode *node;



/* Line 1676 of yacc.c  */
#line 135 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;



%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int lnum = 1;
%}

%x MULTI_LINE_COMMENT_BODY
%x SINGLE_LINE_COMMENT_BODY

ESCAPE_SEQUENCE         "\\\'"|"\\\""|"\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"

identifier              [A-Za-z_][A-Za-z0-9_]*

DIGIT                   [0-9]
DIGIT_SEQUENCE          {DIGIT}+
NONZERO_DIGIT           [1-9]
integer_constant        {NONZERO_DIGIT}{DIGIT}*|"0"

EXPONENT_PART           [eE]([+-]?){DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT     {DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}\.
floating_constant       {FRACTIONAL_CONSTANT}({EXPONENT_PART}?)|{DIGIT_SEQUENCE}{EXPONENT_PART}

ENUMERATION_CONSTANT    {identifier}

C_CHAR                  [^\'\n\\]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE         {C_CHAR}+
character_constant      \'{C_CHAR_SEQUENCE}\'

S_CHAR                  [^\"\n\\]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE         {S_CHAR}+
string_Literal         \"({S_CHAR_SEQUENCE}?)\"

WHITESPACE              [ \t]
NEWLINE                 \n

%%

"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHAR; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"enum"                          { return ENUM; }
"extern"                        { return EXTERN; }
"float"                         { return FLOAT; }
"for"                           { return FOR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INT; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"struct"                        { return STRUCT; }
"switch"                        { return SWITCH; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return _BOOL; }
"_Complex"                      { return _COMPLEX; }
"_Imaginary"                    { return _IMAGINARY; }

{identifier}                    { yylval.id = strdup(yytext); return identifier; }
{integer_constant}              { yylval.integer_val = atoi(yytext); return integer_constant; }
{floating_constant}             { yylval.float_val = atof(yytext); return floating_constant; }
{character_constant}            { yylval.id = strdup(yytext); return character_constant; }
{string_Literal}                { yylval.id = strdup(yytext); return string_Literal; }

"["                             { return Left_Square_Bracket; }
"++"                            { return Increment; }
"/"                             { return Slash; }
"?"                             { return Question_Mark; }
"="                             { return Assignment; }
","                             { return Comma; }
"]"                             { return Right_Square_Bracket; }
"("                             { return Left_Paranthesis; }
"{"                             { return Left_Curly_Bracket; }
"}"                             { return Right_Curly_Bracket; }
"."                             { return Dot; }
"->"                            { return Arrow; }
"*"                             { return Asterisk; }
"+"                             { return Plus; }
"-"                             { return Minus; }
"~"                             { return Tilde; }
"!"                             { return Exclamation; }
"%"                             { return Modulo; }
"<<"                            { return Left_Shift; }
">>"                            { return Right_Shift; }
"<"                             { return Less_Than; }
">"                             { return Greater_Than; }
"<="                            { return Less_Than_Equal; }
">="                            { return Greater_Than_Equal; }
":"                             { return Colon; }
";"                             { return Semi_Colon; }
"..."                           { return Ellipsis; }
"*="                            { return Asterisk_Assignment; }
"/="                            { return Slash_Assignment; }
"%="                            { return Modulo_Assignment; }
"+="                            { return Plus_Assignment; }
"-="                            { return Minus_Assignment; }
"<<="                           { return Left_Shift_Assignment; }
"--"                            { return Decrement; }
")"                             { return Right_Paranthesis; }
"&"                             { return Bitwise_And; }
"=="                            { return Equals; }
"^"                             { return Bitwise_Xor; }
"|"                             { return Bitwise_Or; }
"&&"                            { return Logical_And; }
"||"                            { return Logical_Or; }
">>="                           { return Right_Shift_Assignment; }
"!="                            { return Not_Equals; }
"&="                            { return Bitwise_And_Assignment; }
"|="                            { return Bitwise_Or_Assignment; }
"^="                            { return Bitwise_Xor_Assignment; }

"/*"                            { BEGIN(MULTI_LINE_COMMENT_BODY); }
<MULTI_LINE_COMMENT_BODY>"*/"   { BEGIN(INITIAL); }
<MULTI_LINE_COMMENT_BODY>.      { }
<MULTI_LINE_COMMENT_BODY>"\n"   { lnum++; printf("\n.......................On Line No. %d.......................\n\n", lnum); }

"//"                            { BEGIN(SINGLE_LINE_COMMENT_BODY); }
<SINGLE_LINE_COMMENT_BODY>"\n"  { BEGIN(INITIAL); lnum++; printf("\n.......................On Line No. %d.......................\n\n", lnum); }
<SINGLE_LINE_COMMENT_BODY>.     { }

{WHITESPACE}                    { }
{NEWLINE}                       { lnum++; printf("\n.......................On Line No. %d.......................\n\n", lnum); }
.                               { printf("ERROR [Line %d] : Invalid token %s\n", lnum, yytext); return INVALID_TOKEN; }

%%

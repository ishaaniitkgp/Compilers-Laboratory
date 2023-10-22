%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int lineNumber = 1;
%}

%x MULTI_LINE_COMMENT_BODY
%x SINGLE_LINE_COMMENT_BODY

ESCAPE_SEQUENCE         "\\\'"|"\\\""|"\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"

Identifier              [A-Za-z_][A-Za-z0-9_]*

DIGIT                   [0-9]
DIGIT_SEQUENCE          {DIGIT}+
NONZERO_DIGIT           [1-9]
Constant_Integer_Type        {NONZERO_DIGIT}{DIGIT}*|"0"

EXPONENT_PART           [eE]([+-]?){DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT     {DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}\.
Constant_Float_Type       {FRACTIONAL_CONSTANT}({EXPONENT_PART}?)|{DIGIT_SEQUENCE}{EXPONENT_PART}

ENUMERATION_CONSTANT    {Identifier}

C_CHAR                  [^\'\n\\]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE         {C_CHAR}+
Constant_Character_Type      \'{C_CHAR_SEQUENCE}\'

S_CHAR                  [^\"\n\\]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE         {S_CHAR}+
String_Literal         \"({S_CHAR_SEQUENCE}?)\"

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
"typedef"                       { return TYPEDEF; }
"union"                         { return UNION; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return _BOOL; }
"_Complex"                      { return _COMPLEX; }
"_Imaginary"                    { return _IMAGINARY; }

{Identifier}                    { yylval.identifierVal = strdup(yytext); return Identifier; }
{Constant_Integer_Type}              { yylval.intVal = atoi(yytext); return Constant_Integer_Type; }
{Constant_Float_Type}             { yylval.floatVal = atof(yytext); return Constant_Float_Type; }
{Constant_Character_Type}            { yylval.charVal = strdup(yytext); return Constant_Character_Type; }
{String_Literal}                { yylval.stringVal = strdup(yytext); return String_Literal; }

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
"^="                            { return Bitwise_Xor_Assignemt; }

"/*"                            { BEGIN(MULTI_LINE_COMMENT_BODY); }
<MULTI_LINE_COMMENT_BODY>"*/"   { BEGIN(INITIAL); }
<MULTI_LINE_COMMENT_BODY>.      { }
<MULTI_LINE_COMMENT_BODY>"\n"   { lineNumber++; printf("\n.......................On Line No. %d.......................\n\n", lineNumber); }

"//"                            { BEGIN(SINGLE_LINE_COMMENT_BODY); }
<SINGLE_LINE_COMMENT_BODY>"\n"  { BEGIN(INITIAL); lineNumber++; printf("\n.......................On Line No. %d.......................\n\n", lineNumber); }
<SINGLE_LINE_COMMENT_BODY>.     { }

{WHITESPACE}                    { }
{NEWLINE}                       { lineNumber++; printf("\n.......................On Line No. %d.......................\n\n", lineNumber); }
.                               { printf("ERROR [Line %d] : Invalid token %s\n", lineNumber, yytext); return INVALID_TOKEN; }

%%

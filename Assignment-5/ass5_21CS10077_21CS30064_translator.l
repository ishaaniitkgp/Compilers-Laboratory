%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ass5_17CS10007_17CS10005_translator.h"
    #include "y.tab.h"
    extern void yyerror(char*);
    void comment();
    int lnum = 1;
%}

%option noyywrap
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

"auto"                          {yylval.id=strdup("auto"); return AUTO; }
"break"                         {yylval.id=strdup("break"); return BREAK; }
"case"                          {yylval.id=strdup("case"); return CASE; }
"char"                          {yylval.id=strdup("char"); return CHAR; }
"const"                         {yylval.id=strdup("const"); return CONST; }
"continue"                      {yylval.id=strdup("continue"); return CONTINUE; }
"default"                       {yylval.id=strdup("default"); return DEFAULT; }
"do"                            {yylval.id=strdup("do"); return DO; }
"double"                        {yylval.id=strdup("double"); return DOUBLE; }
"else"                          {yylval.id=strdup("else"); return ELSE; }
"enum"                          {yylval.id=strdup("enum"); return ENUM; }
"extern"                        {yylval.id=strdup("extern"); return EXTERN; }
"float"                         {yylval.id=strdup("float"); return FLOAT; }
"for"                           {yylval.id=strdup("for"); return FOR; }
"goto"                          {yylval.id=strdup("goto"); return GOTO; }
"if"                            {yylval.id=strdup("if"); return IF; }
"inline"                        {yylval.id=strdup("inline"); return INLINE; }
"int"                           {yylval.id=strdup("int"); return INT; }
"long"                          {yylval.id=strdup("long"); return LONG; }
"register"                      {yylval.id=strdup("register"); return REGISTER; }
"restrict"                      {yylval.id=strdup("restrict"); return RESTRICT; }
"return"                        {yylval.id=strdup("return"); return RETURN; }
"short"                         {yylval.id=strdup("short"); return SHORT; }
"signed"                        {yylval.id=strdup("signed"); return SIGNED; }
"sizeof"                        {yylval.id=strdup("sizeof"); return SIZEOF; }
"static"                        {yylval.id=strdup("static"); return STATIC; }
"struct"                        {yylval.id=strdup("struct"); return STRUCT; }
"switch"                        {yylval.id=strdup("switch"); return SWITCH; }
"typedef"	                    {yylval.id=strdup("typedef"); return TYPEDEF;}
"union"		                    {yylval.id=strdup("union"); return UNION;}
"unsigned"                      {yylval.id=strdup("unsigned"); return UNSIGNED; }
"void"                          {yylval.id=strdup("void"); return VOID; }
"volatile"                      {yylval.id=strdup("volatile"); return VOLATILE; }
"while"                         {yylval.id=strdup("while"); return WHILE; }
"_Bool"                         {yylval.id=strdup("_bool"); return _BOOL; }
"_Complex"                      {yylval.id=strdup("_complex"); return _COMPLEX; }
"_Imaginary"                    { yylval.id=strdup("_imaginary");return _IMAGINARY; }

{identifier}                    {yylval.symnode=new SymbolNode;yylval.symnode->name=string(yytext); return identifier; }
{integer_constant}              { yylval.integer_val = atoi(yytext); return integer_constant; }
{floating_constant}             {yylval.float_val = atof(yytext); return floating_constant; }
{character_constant}            { yylval.id = strdup(yytext); return character_constant; }
{string_Literal}                { yylval.id = strdup(yytext); return string_Literal; }

"["                             {yylval.id=strdup("[");  return Left_Square_Bracket; }
"++"                            {yylval.id=strdup("++"); return Increment; }
"/"                             {yylval.id=strdup("/"); return Slash; }
"?"                             {yylval.id=strdup("?"); return Question_Mark; }
"="                             {yylval.id=strdup("="); return Assignment; }
","                             {yylval.id=strdup(","); return Comma; }
"]"                             {yylval.id=strdup("]"); return Right_Square_Bracket; }
"("                             {yylval.id=strdup("("); return Left_Paranthesis; }
"{"                             {yylval.id=strdup("{"); return Left_Curly_Bracket; }
"}"                             {yylval.id=strdup("}"); return Right_Curly_Bracket; }
"."                             {yylval.id=strdup("."); return Dot; }
"->"                            {yylval.id=strdup("->"); return Arrow; }
"*"                             {yylval.id=strdup("*"); return Asterisk; }
"+"                             {yylval.id=strdup("+"); return Plus; }
"-"                             {yylval.id=strdup("-"); return Minus; }
"~"                             {yylval.id=strdup("~"); return Tilde; }
"!"                             {yylval.id=strdup("!"); return Exclamation; }
"%"                             {yylval.id=strdup("%"); return Modulo; }
"<<"                            {yylval.id=strdup("<<"); return Left_Shift; }
">>"                            {yylval.id=strdup(">>"); return Right_Shift; }
"<"                             {yylval.id=strdup("<"); return Less_Than; }
">"                             {yylval.id=strdup(">"); return Greater_Than; }
"<="                            {yylval.id=strdup("<="); return Less_Than_Equal; }
">="                            {yylval.id=strdup(">="); return Greater_Than_Equal; }
":"                             {yylval.id=strdup(":"); return Colon; }
";"                             {yylval.id=strdup(";"); return Semi_Colon; }
"..."                           {yylval.id=strdup("..."); return Ellipsis; }
"*="                            {yylval.id=strdup("*="); return Asterisk_Assignment; }
"/="                            {yylval.id=strdup("/="); return Slash_Assignment; }
"%="                            {yylval.id=strdup("%="); return Modulo_Assignment; }
"+="                            {yylval.id=strdup("+="); return Plus_Assignment; }
"-="                            {yylval.id=strdup("-="); return Minus_Assignment; }
"<<="                           {yylval.id=strdup("<<="); return Left_Shift_Assignment; }
"--"                            {yylval.id=strdup("--"); return Decrement; }
")"                             {yylval.id=strdup(")"); return Right_Paranthesis; }
"&"                             {yylval.id=strdup("&"); return Bitwise_And; }
"=="                            {yylval.id=strdup("=="); return Equals; }
"^"                             {yylval.id=strdup("^"); return Bitwise_Xor; }
"|"                             {yylval.id=strdup("|"); return Bitwise_Or; }
"&&"                            {yylval.id=strdup("&&"); return Logical_And; }
"||"                            {yylval.id=strdup("||"); return Logical_Or; }
">>="                           {yylval.id=strdup(">>="); return Right_Shift_Assignment; }
"!="                            {yylval.id=strdup("!="); return Not_Equals; }
"&="                            {yylval.id=strdup("&="); return Bitwise_And_Assignment; }
"|="                            {yylval.id=strdup("|="); return Bitwise_Or_Assignment; }
"^="                            {yylval.id=strdup("^="); return Bitwise_Xor_Assignment; }

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

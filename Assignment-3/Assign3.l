%{ /*C Declarations and Definitions*/
#include<stdio.h>
#define keyword         1
#define identifier      2
#define constant        3
#define string_literal  4 
#define punctuator      5
#define comment         6
#define comment_error   7
#define escape_sequence 8
%}

/* Regular Expression Definitions*/
keyword        "auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"_Bool"|"continue"|"if"|"static"|"_Complex"|"default"|"inline"|"struct"|"_Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"
identifier {identifier_nondigit}({identifier_nondigit}|{digit})*
identifier_nondigit [a-zA-Z_]
digit [0-9]
constant  {integer_constant}|{floating_constant}|{enumeration_constant}|{character_constant}
integer_constant  {nonzero_digit}{digit}*
nonzero_digit  [1-9] 
floating_constant ({fractional_constant}{exponent_part}?)|([0-9]+{exponent_part})
fractional_constant (([0-9]+)?\.[0-9]+)|(([0-9]+)\.)
exponent_part  ([eE][-+]?[0-9]+)
sign  "+"|"-"
digit_sequence  [0-9]+
enumeration_constant  {identifier}
character_constant  '{c_char_sequence}'
c_char_sequence ({c_char})+
c_char [^'\\\n]|{escape_sequence}
escape_sequence  "\'"|"\""|"\?"|"\\"|"\a"|"\b"|"\f"|"\n"|"\r"|"\t"|"\v"
string_literal  \"{s_char_sequence}?\"
s_char_sequence {s_char}+
s_char [^\"\\\n]|{escape_sequence}
punctuator  "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
whitespace  [ \t\n\v\f]


/* Definitions of Rules & Actions */
%%
{keyword}                                 {return keyword;}
{identifier}                              {return identifier;}
{constant}                                {return constant;}
{string_literal}                          {return string_literal;}
{punctuator}                              {return punctuator;}
{whitespace}                              {/* Ignore Whitespace */}

"/*"[^"*/"]*"*/"                          {return comment;}
"/*"[^"*/""//"]*("//")*[^"*/""//"]*"*/"   {return comment;}                  
"//".*                                    {return comment;}	
"/*"[^"*/""//"]*                          {return comment_error;}	   
{escape_sequence}                         {return escape_sequence;}		   
%%

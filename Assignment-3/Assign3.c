#include<stdio.h>
extern char* yytext;
main(){

int token;
while(token=yylex()){
	switch(token){
		case keyword:
  			printf("keyword-> %s, token(%d)\n", yytext, token);
  			break;

		case identifier: 
			printf("identifier-> %s, token(%d)\n", yytext, token); 
			break;

		case constant: 
			printf("constant-> %s, token(%d)\n", yytext, token); 
			break;

		case string_literal: 
			printf("string-literal-> %s, token(%d)\n", yytext, token); 
			break;

		case punctuator: 
			printf("punctuator-> %s, token(%d)\n", yytext, token); 
			break;

		case comment: 
			printf("comment\n"); 
			break;

		case comment_error: 
			printf("Comment error\n"); 
			break;

	        case escape_sequence:
    		        printf("escape sequence-> %s, token(%d)\n", yytext, token);
  			break; 
	
		default: 
			printf("punctuator-> %s, token(%d)\n", yytext, token); 
			break;
	
	}

}
}

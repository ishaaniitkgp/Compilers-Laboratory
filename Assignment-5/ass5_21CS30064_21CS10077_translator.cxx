/*
Name:- Vinayak Gupta
Roll:- 21CS10077

Name:- Ishaan Sinha
Roll No:- 21CS30064

Compilers Assignment 5
*/

#include "ass5_21CS10077_21CS30064_translator.h"
#include "y.tab.h"


void emit(string result,opcodeType op,string arg1,string arg2){
	qArray[nextinstr].op=op;
    qArray[nextinstr].result=result;
	qArray[nextinstr].arg1=arg1;
	qArray[nextinstr].arg2=arg2;
	
	nextinstr++;
}

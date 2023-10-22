#include "myl.h"

int main(){
	char *s;
	s="Enter the value of integer: ";
	printStr(s);
	int n;
	if(readInt(&n)==ERR){
		printStr("Invalid input entered\n");
		return 0;
	}
	s="The entered integer is: ";
	printStr(s);
	printInt(n);
	printStr("\n");
	s="Enter the value of floating point number: ";
	printStr(s);
	float f;
	if(readFlt(&f)==ERR){
		printStr("Invalid input entered\n");
		return 0;
	}
	s="The entered floating point value is: ";
	printStr(s);
	printFlt(f);
	printStr("\n");
	
	return 0;

}

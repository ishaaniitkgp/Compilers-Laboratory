
#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <stack>
#define max_size 100

extern FILE* yyin;
extern FILE* yyout;
extern int yylex();
extern int yyparse();
extern char* yytext;


typedef enum{        
	plus,
	minus,	
	div,
	mul,
	uminus,
	copy_assignment,
	increment,
	decrement,
	negation,
	nt,
	rem,
	leftshift,
	rightshift,
	lessthan,
	greaterthan,
	lessthanequal,
	greaterthanequal,
	isequal,
	notequal,
	bitwisexor,
	bitwiseor,
	bitwiseand,
	question_mark,
	colon,
	assignment,
	logicalor,
	logicaland,
	_goto,
	func,
	param,
	_return,
	array,
}opcodeType;

struct SymbolNode;
struct SymbolTable;
struct list;


typedef struct value{			// flag=0 =>void
	int intval;					// flag=1 => char
	float floatval;				// flag=2 => int 					
	char c;					    // flag=3 => float	
	void* ptr;			   		// flag=4 => function			
	int flag;				  	// flag=5 => void*
}value; 


typedef struct SymbolNode{ 			// Entry to symbol table 
	char* name;					// Variable name
	char* type;					// variable type 
	value init_val; 					// value of variable
	int size,offset;				// size of variable and its offset
	struct SymbolTable *nested_table;			// nested symbol table (functions) 
	struct list *truelist, *falselist;
	struct list* arglist; 		// To the list of array indices in array type with pointer level at the beginning of the list
}SymbolNode;

typedef struct SymbolTable{ 				// symbol table
	int count;						// no of entries to the SymTab 
	SymbolNode symbol[max_size]; 			// entry to synbol table
}SymbolTable;

typedef struct list{
	int index;
	struct list* next;
}List;

typedef struct IdList{ 			
	SymbolNode* id;
	struct IdList* next;
}IdList;

typedef struct ParameterList{      
	char* type;
	char* name;
	struct ParameterList* next;
}ParameterList;

typedef struct quad{
	opcodeType op;
	char* arg1,arg2,result;
}quad;

extern quad qArray[256];       
extern int num_of_temp;				// num_of_temp= number of temporaries
extern int next_instruction; 			// Index of next instruction
extern SymbolTable* currentTable;      
extern SymbolTable* globalTable;

SymbolTable* newTable();
SymbolNode* lookup(SymbolTable*,char*);
SymbolNode* gentemp(SymbolTable*);
void update(SymbolTable*,SymbolNode*,char*);
void printSymbolTable(SymbolTable);
void emit(char*, opcodeType, char* , char* );
void printquad(quad);
List* makelist(int);
List* merge(List*, List*);
void backpatch(List*, int);
void typecheck(SymbolNode*, SymbolNode*);
SymbolNode* convert(char* ,SymbolNode*);
IdList* makelist(SymbolNode*);
IdList* merge(IdList*, IdList*);
ParameterList* makelist(char*, char*);
ParameterList* merge(ParameterList*,ParameterList*);
void convInt2Bool(SymbolNode*);


#endif
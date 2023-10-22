
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


typedef struct value{			        // flag=0 => void
	int intval;				// flag=1 => char
	float floatval;				// flag=2 => int 					
	char c;					// flag=3 => float	
	void* ptr;			   	// flag=4 => function			
	int flag;				// flag=5 => void*
}value; 


typedef struct SymbolNode{ 			// Entry to Symbol Table 
	string name;					// Name of Variable
	string type;					// Type of Variable 
	value init_val; 				// Value of variable
	int size,offset;				// Size of variable and its Offset
	struct SymbolTable *nested_table;	        // Nested Symbol Table (functions) 
	struct list *truelist, *falselist;
	struct list* arglist; 		// To the list of array indices in array type with pointer level at the beginning of the list
}SymbolNode;

typedef struct SymbolTable{ 			// Symbol Table
	int count;					// Number of entries to the Symbol Table 
	SymbolNode symbol[max_size]; 			// entry to synbol table
}SymbolTable;

typedef struct list{                            // Linked List of indices
	int index;
	struct list* next;
}List;

typedef struct IdList{ 			        // Linked List of IDs
	SymbolNode* id;
	struct IdList* next;
}IdList;

typedef struct ParameterList{      
	string type;
	string name;
	struct ParameterList* next;
}ParameterList;

typedef struct quad{
	opcodeType op;
	string arg1,arg2,result;
}quad;

extern quad qArray[256];       
extern int num_of_temp;				// num_of_temp= number of temporaries
extern int next_instruction; 			// Index of next instruction
extern SymbolTable* currentTable;      
extern SymbolTable* globalTable;

SymbolTable* newTable();
SymbolNode* lookup(SymbolTable*,string);
SymbolNode* gentemp(SymbolTable*);
void update(SymbolTable*,SymbolNode*,string);
void printSymbolTable(SymbolTable);
void emit(string, opcodeType, string c="" , string s="" );
void printquad(quad);
List* makelist(int);
List* merge(List*, List*);
void backpatch(List*, int);
void typecheck(SymbolNode*, SymbolNode*);
SymbolNode* convert(string ,SymbolNode*);
IdList* makelist(SymbolNode*);
IdList* merge(IdList*, IdList*);
ParameterList* makelist(string, string);
ParameterList* merge(ParameterList*,ParameterList*);
void convInt2Bool(SymbolNode*);


#endif

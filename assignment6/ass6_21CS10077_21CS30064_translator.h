/*
Group Members: Ishaan Sinha (21CS30064) and Vinayak Gupta (21CS10077)
Assignment-6
*/

#ifndef __TRANSLATION_H
#define __TRANSLATION_H

// including header files needed
#include <iostream>
#include <list>
#include <map>
#include <string>
#include <vector>

using namespace std;

extern char* yytext;
extern int yyparse();

// defining constants for type sizes
#define size_of_char 1
#define size_of_int 4
#define size_of_float 8
#define size_of_ptr 4

//sizes are defined as constants as hardcoded values make the program machine-dependent
//these values can be changed according to the machine it is being executed on

//Class Declarations
class symbol;
class quad;
class label;
class SymbolType;
class SymbolTable;
class quadArray;

struct expression;
struct statement;
struct Array;

extern symbol* current_Symbol;
extern SymbolTable* current_Table;
extern SymbolTable* global_Table;
extern quadArray qArray;

//CLASS DEFINITIONS

//CLASS SYMBOL
class symbol {
   public:
    std::string name;    // name of the symbol
    SymbolType* type;       // type of the symbol
    string val;          // initial value
    string cat;          // category (global, local, parameter)
    int size;            // size of the symbol
    int offset;          // offset of the symbol in ST
    SymbolTable* nestedST;  // ptr to nested symbol table

    //CONSTRUCTOR
    symbol(string name_, string type_ = "INT",
           SymbolType* ptr = NULL,
           int width = 0);
    symbol* update(SymbolType* ts);
};

class label {
   public:
    string name;
    int addr;
    std::list<int> nextList;
    label(string name_, int addr_ = -1);
};

//Class of Quad
class quad {
   public:
    // res = arg1 op arg2
    std::string res;
    std::string arg1;
    std::string op;
    std::string arg2;

    // function to print the current quad
    void print();

    // Constructors for quad initialization
    quad(std::string res, std::string arg1, std::string op = "=", std::string arg2 = "");
};

//Class of Symbol Type

class SymbolType {
   public:
    std::string type;  // string to store symbol type
    SymbolType* ptr;      // pointer to elements in case of complex symbol type such as array
    int width;         // width if arrType

    //CONSTRUCTOR
    SymbolType(std::string type, SymbolType* ptr = NULL, int width = 1);
};

//CLASS QUAD ARRAY

class quadArray {
   public:
    // vector to store all quads in code
    std::vector<quad> array;
    // member function to print all the quads
    void print();
};

//CLASS SymbolTable
class SymbolTable {
   public:
    std::string name;         // name of the symbol table
    int count;                // counter for temp variables
    std::list<symbol> table;  // list of symbols in the table
    SymbolTable* parent;         // ptr to parent symbol table

    //activation record map
    map<string, int> AR;

    //member functions
    SymbolTable(std::string name_ = "NULL");
    ~SymbolTable() {}

    void update();                         // update the symbol table
    void print();                          // print the symbol table
    symbol* lookup(std::string symbName);  // lookup a symbol in the symbol table and return prt to it
};

struct statement {
    // list to store statements for dangling exits
    std::list<int> nextList;
};

struct expression {
    // string to store type
    std::string type;
    // pointer to the entry in symbol table
    symbol* loc;
    // next list for statement expressions
    std::list<int> nextList;
    // false list for boolean expressions
    std::list<int> falseList;
    // true list for boolean expressions
    std::list<int> trueList;
};

// emit function used by the parser in overloaded state
void emit(string op, string res, string arg1 = "", string arg2 = "");
void emit(string op, string res, int arg1, string arg2 = "");
void emit(string op, string res, float arg1, string arg2 = "");

//GENTEMP FUNCTION
symbol* gentemp(SymbolType* T, string initVal = "");

// inserting target label into group of quads i.e. list<int> L
void backpatch(list<int> L, int i);
// making a new list with only the integer address passed as parameter
list<int> makelist(int i);
// function to merge the 2 lists L1 and L2 passed as parameters
list<int> merge(list<int>& L1, list<int>& L2);

struct Array {
    // string to store type of array [pointers , elements]
    string artype;
    // symbol type of generated subarray stored
    // important for when multidimensional array in encountered
    SymbolType* type;
    // pointer to store location of array
    symbol* loc;
    // pointer to symbol table entry
    symbol* Sarr;
};

// LIST RELATED FUNCTIONS

// BOOLEAN RELATED FUNCTIONS

// function for conversion of boolean expression to int
expression* convertBool2Int(expression*);
// function for conversion of integer expression to int
expression* convertInt2Bool(expression*);

// overloaded function to check if the symbol type is same for 2 symbols
bool typecheck(symbol*& c1, symbol*& c2);
bool typecheck(SymbolType* s1, SymbolType* s2);

// function to get the size of the symbol
int Sizeoftype(SymbolType*);

// function to get the type of the symbol
string GetType(SymbolType*);

// returns the number of the next instruction
int nextInstruction();

// global function for the conversion of symbol to the type stored in string
symbol* convert(symbol*, string);

// changing table passed as paramater to a new symbol table
void changecurrentTable(SymbolTable*);
label* searchlabel(string name);

#endif  // __TRANSLATION_H

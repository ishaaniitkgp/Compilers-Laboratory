/*
Group Members: Ishaan Sinha (21CS30064) and Vinayak Gupta (21CS10077)
Assignment-6
*/

// including our translator header file
#include "ass6_21CS10077_21CS30064_translator.h"

// including built-in libraries
#include <bits/stdc++.h>
using namespace std;

// Global Variables which are getting imported from the translator header file

// Pointer to current symbol
symbol* current_Symbol;
// Current Symbol table for the code
SymbolTable* current_Table;
// global Symbol Table
SymbolTable* global_Table;
// array of quads for the ones in the code
quadArray qArray;
string type_of_variable;

// Implementing symbol class functions

//constructor
symbol::symbol(string name_, string type_,
               SymbolType* ptr, int width) : name(name_),
                                          nestedST(NULL),
                                          offset(0),
                                          val(""),
                                          cat("") {
    this->type = new SymbolType(type_, ptr, width);
    this->size = Sizeoftype(this->type);
}

// update function
symbol* symbol::update(SymbolType* ptr) {
    this->type = ptr;
    this->size = Sizeoftype(ptr);
    return this;
}

SymbolType::SymbolType(string type_, SymbolType* ptr_, int width_) {
    this->type = type_;
    this->ptr = ptr_;
    this->width = width_;
}

label::label(string name_, int addr_) : name(name_), addr(addr_) {}

SymbolTable::SymbolTable(string name_) : name(name_), count(0) {
    this->parent = NULL;
}

//lookup function (A method to lookup an id)
symbol* SymbolTable::lookup(string name_) {
    symbol* s = NULL;
    for (auto it = this->table.begin(); it != this->table.end(); it++) {
        if (it->name == name_)
            return &(*it);
    }
    s = new symbol(name_);
    s->cat = "local";
    this->table.push_back(*s);
    return &(this->table.back());
}

//gentemp function (to generate temporary)
symbol* gentemp(SymbolType* T, string Init_val) {
    string temp = "t" + to_string(current_Table->count++);
    symbol* s = new symbol(temp);
    s->type = T;
    s->size = Sizeoftype(T);
    s->val = Init_val;
    s->cat = "temp";
    current_Table->table.push_back(*s);
    return &current_Table->table.back();
}

//update function (A method to update different fields of an existing entry)
void SymbolTable::update() {
    int offset = 0;
    std::vector<SymbolTable*> Pointers_to_table;
    for (auto it = this->table.begin(); it != this->table.end(); it++) {
        it->offset = offset;
        offset += it->size;
        if (it->nestedST != NULL)
            Pointers_to_table.push_back(it->nestedST);
    }
    for (auto it = Pointers_to_table.begin(); it != Pointers_to_table.end(); it++)
        (*it)->update();
}

//Function to print Symbol Table
void SymbolTable::print() {
    std::cout << setw(120) << setfill('-') << "-" << endl;
    std::cout << std::endl;
    cout << "Table-Name: " << this->name << "   ";
    cout << "Parent Table-Name: " << (this->parent == NULL ? "NULL" : this->parent->name) << endl;
    cout << "Name"
         << "\t"
         << "Type"
         << "\t"
         << "Category"
         << "\t"
         << "Initial Value"
         << "\t"
         << "Size"
         << "\t"
         << "Offset"
         << "\t"
         << "Nested Table" << endl;
    vector<SymbolTable*> Pointers_to_table;
    for (auto it = this->table.begin(); it != this->table.end(); it++) {
        cout << it->name
             << "\t"
             << GetType(it->type)
             << "\t"
             << it->cat
             << "\t"
             << it->val
             << "\t"
             << it->size
             << "\t"
             << it->offset
             << "\t"
             << (it->nestedST == NULL ? "null" : it->nestedST->name)
             << endl;
        if (it->nestedST != NULL)
            Pointers_to_table.push_back(it->nestedST);
    }
    std::cout << setw(120) << setfill('-') << "-" << endl;
    for (auto it = Pointers_to_table.begin(); it != Pointers_to_table.end(); it++)
        (*it)->print();
}

//An overloaded static method to add a newly generated quad in quadarray
void emit(string op, string res, string arg1, string arg2) {
    quad* q = new quad(res, arg1, op, arg2);
    qArray.array.push_back(*q);
}

void emit(string op, string res, int arg1, string arg2) {
    string arg1_ = to_string(arg1);
    quad* q = new quad(res, arg1_, op, arg2);
    qArray.array.push_back(*q);
}

void emit(string op, string res, float arg1, string arg2) {
    string arg1_ = to_string(arg1);
    quad* q = new quad(res, arg1_, op, arg2);
    qArray.array.push_back(*q);
}

quad::quad(string res_, string arg1_,
           string op_, string arg2_) : res(res_),
                                       arg1(arg1_),
                                       op(op_),
                                       arg2(arg2_) {}

//A method to print the quad
void quad::print() {

    //SHIFT OPERATORS          

    if (op == "LEFTOP")
        std::cout << res << " = " << arg1 << " << " << arg2;
    else if (op == "RIGHTOP")
        std::cout << res << " = " << arg1 << " >> " << arg2;
    else if (op == "EQUAL")
        std::cout << res << " = " << arg1;

    //BINARY OPERATORS

    else if (op == "ADD")
        std::cout << res << " = " << arg1 << " + " << arg2;
    else if (op == "SUB")
        std::cout << res << " = " << arg1 << " - " << arg2;
    else if (op == "MULT")
        std::cout << res << " = " << arg1 << " *" << arg2;
    else if (op == "DIVIDE")
        std::cout << res << " = " << arg1 << " / " << arg2;
    else if (op == "MODOP")
        std::cout << res << " = " << arg1 << " % " << arg2;
    else if (op == "XOR")
        std::cout << res << " = " << arg1 << " ^ " << arg2;
    else if (op == "INOR")
        std::cout << res << " = " << arg1 << " | " << arg2;
    else if (op == "BAND")
        std::cout << res << " = " << arg1 << " &" << arg2;
    
    //UNARY OPERATORS

    else if (op == "ADDRESS")
        std::cout << res << " = &" << arg1;
    else if (op == "PTRR")
        std::cout << res << " = *" << arg1;
    else if (op == "PTRL")
        std::cout << "*" << res << " = " << arg1;
    else if (op == "UMINUS")
        std::cout << res << " = -" << arg1;
    else if (op == "BNOT")
        std::cout << res << " = ~" << arg1;
    else if (op == "LNOT")
        std::cout << res << " = !" << arg1;

    //RELATIONAL OPERATORS

    else if (op == "EQOP")
        std::cout << "if " << arg1 << " == " << arg2 << " goto " << res;
    else if (op == "NEOP")
        std::cout << "if " << arg1 << " != " << arg2 << " goto " << res;
    else if (op == "LT")
        std::cout << "if " << arg1 << "<" << arg2 << " goto " << res;
    else if (op == "GT")
        std::cout << "if " << arg1 << " > " << arg2 << " goto " << res;
    else if (op == "GE")
        std::cout << "if " << arg1 << " >= " << arg2 << " goto " << res;
    else if (op == "LE")
        std::cout << "if " << arg1 << " <= " << arg2 << " goto " << res;
    else if (op == "GOTOOP")
        std::cout << "goto " << res;

    //OTHER OPERATORS 

    else if (op == "ARRR")
        std::cout << res << " = " << arg1 << "[" << arg2 << "]";
    else if (op == "ARRL")
        std::cout << res << "[" << arg1 << "]" << " = " << arg2;
    else if (op == "RETURN")
        std::cout << "ret " << res;
    else if (op == "PARAM")
        std::cout << "param " << res;
    else if (op == "CALL")
        std::cout << res << " = "
                  << "call " << arg1 << ", " << arg2;
    else if (op == "FUNC")
        std::cout << res << ": ";
    else if (op == "FUNCEND")
        std::cout << "";
    else
        std::cout << op;
    std::cout << endl;
}

//A method to print the quad array in a suitable format
void quadArray::print() {
    for (int i = 0; i < 40; i++) std::cout << "__";
    cout << "THREE ADDRESS CODE(TAC)" << endl;
    for (int i = 0; i < 40; i++) std::cout << "__";
    int i = 0;
    for (auto it = this->array.begin(); it != this->array.end(); it++, i++) {
        if (it->op == "FUNC") {
            cout << "\n";
            it->print();
            cout << "\n";
        } else if (it->op == "FUNCEND") {
        } else {
            cout << i << ":   ";
            it->print();
        }
    }
    for (int i = 0; i < 40; i++) std::cout << "__";  // End of printing of the TAC
    std::cout << std::endl;
}

label* searchlabel(string name) {
    return NULL;
}

//A global function to create a new list containing only i
list<int> makelist(int i) {
    list<int> L;
    L.push_back(i);
    return L;
}

//A global function to concatenate two lists
list<int> merge(list<int>& L1, list<int>& L2) {
    L1.merge(L2);
    return L1;
}

//A global function to insert i as the target label for each of the quad’s on the list pointed to by p
void backpatch(list<int> L, int i) {
    string s = to_string(i);
    for (auto it = L.begin(); it != L.end(); it++) {
        qArray.array[*it].res = s;
    }
}

int nextInstruction() {
    return qArray.array.size();
}

//Functionality to check and compare the types of E1 & E2
bool typecheck(symbol*& t1, symbol*& t2) {
    SymbolType* t1_ = t1->type;
    SymbolType* t2_ = t2->type;
    if (typecheck(t1_, t2_))
        return true;
    else if (t1 = convert(t1, t2_->type))
        return true;
    else if (t2 = convert(t2, t1_->type))
        return true;
    return false;
}

bool typecheck(SymbolType* t1, SymbolType* t2) {
    if (t1 == NULL && t2 == NULL)
        return true;
    else if (t1 == NULL || t2 == NULL || t1->type != t2->type)
        return false;
    else
        return typecheck(t1->ptr, t2->ptr);
}

//Change current symbol table pointer 
void changecurrentTable(SymbolTable* Table) {
    current_Table = Table;
}

symbol* convert(symbol* s, string type) {
    symbol* temp = gentemp(new SymbolType(type));
    if (s->type->type == "FLOAT") {
        if (type == "INT") {
            emit("EQUAL", temp->name, "float2int(" + s->name + ")");
            return temp;
        } else if (type == "CHAR") {
            emit("EQUAL", temp->name, "float2char(" + s->name + ")");
            return temp;
        }
        return s;
    } else if (s->type->type == "INT") {
        if (type == "FLOAT") {
            emit("EQUAL", temp->name, "int2float(" + s->name + ")");
            return temp;
        } else if (type == "CHAR") {
            emit("EQUAL", temp->name, "int2char(" + s->name + ")");
            return temp;
        }
        return s;
    } else if (s->type->type == "CHAR") {
        if (type == "FLOAT") {
            emit("EQUAL", temp->name, "char2float(" + s->name + ")");
            return temp;
        } else if (type == "INT") {
            emit("EQUAL", temp->name, "char2int(" + s->name + ")");
            return temp;
        }
        return s;
    }
    return s;
}

int Sizeoftype(SymbolType* T) {
    if (T->type == "INT")
        return size_of_int;
    else if (T->type == "FLOAT")
        return size_of_float;
    else if (T->type == "CHAR")
        return size_of_char;
    else if (T->type == "PTR")
        return size_of_ptr;
    else if (T->type == "ARR")
        return T->width * Sizeoftype(T->ptr);
    else
        return 0;
}

string GetType(SymbolType* T) {
    if (T == NULL)
        return "null";
    if (T->type == "VOID")
        return "void";
    else if (T->type == "INT")
        return "int";
    else if (T->type == "FLOAT")
        return "float";
    else if (T->type == "CHAR")
        return "char";
    else if (T->type == "PTR")
        return "ptr(" + GetType(T->ptr) + ")";
    else if (T->type == "ARR") {
        return "arr(" + to_string(T->width) + "," + GetType(T->ptr) + ")";
    } else if (T->type == "FUNC")
        return "func";
    else if (T->type == "block")
        return "block";
    else
        return "undefined type";
}

expression* convertInt2Bool(expression* e) {
    if (e->type != "BOOL") {
        e->falseList = makelist(nextInstruction());
        emit("EQUAL", e->loc->name, "0");
        e->trueList = makelist(nextInstruction());
        emit("GOTOOP", "");
    }
    return e;
}

expression* convertBool2Int(expression* e) {
    if (e->type == "BOOL") {
        e->loc = gentemp(new SymbolType("INT"));
        backpatch(e->trueList, nextInstruction());
        emit("EQUAL", e->loc->name, "true");
        int p = nextInstruction() + 1;
        string temp = to_string(p);
        emit("GOTOOP", temp);
        backpatch(e->falseList, nextInstruction());
        emit("EQUAL", e->loc->name, "false");
    }
    return e;
}
%{

#include <bits/stdc++.h>
#include <sstream>
#include "ass6_21CS10077_21CS30064_translator.h"

extern int yylex();
void yyerror(string s);

extern string type_of_variable;
vector <string> List_of_string;
using namespace std;
%}

%union {
    	 
    int intVal;		 
	float floatVal;	 
    int number_of_parameters;	 
	char unaryOp;	 
    char* charVal;	 
    int instrNum;
    expression* exp;  
    statement* stmt;  
    SymbolType* symType;  
    symbol* sym;     
    Array* arr;		 
}


%token <sym> IDENTIFIER 		 		//IDENTIFIER is a token of type symbol
%token <intVal> INTEGER_CONSTANT			
%token <floatVal> FLOATING_CONSTANT			
%token <charVal> CHARACTER_CONSTANT				
%token <charVal> STRING_LITERAL 	


%token INCREMENT
%token DECREMENT
%token BITWISEAND
%token STAR
%token PLUS
%token MINUS
%token NOT
%token EXCLAMATION
%token DIVIDE
%token PERCENTAGE
%token LEFTSHIFT
%token RIGHTSHIFT
%token LESSTHAN
%token GREATERTHAN
%token LESSEQUAL
%token GREATEREQUAL
%token EQUAL
%token NOTEQUAL
%token XOR
%token BITWISEOR
%token AND
%token OR
%token QUESTIONMARK
%token COLON
%token SEMICOLON
%token ELLIPSIS
%token DOT
%token ARROW
%token ASSIGN
%token MULTIPLYEQUAL
%token DIVIDEEQUAL
%token MODULOEQUAL
%token PLUSEQUAL
%token MINUSEQUAL
%token SHIFTLEFTEQUAL
%token SHIFTRIGHTEQUAL
%token ANDEQUAL
%token XOREQUAL
%token OREQUAL
%token COMMA
%token HASH


%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO 
%token ELSE ENUM EXTERN REGISTER FLOAT FOR GOTO IF INLINE 
%token LONG RESTRICT RETURN SHORT  SIGNED SIZEOF STATIC STRUCT SWITCH
%token INT DOUBLE TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE BOOL COMPLEX IMAGINARY


%start translation_unit


%right "then" ELSE         // dangling else resolved

 
%type <unaryOp> unary_operator

 
%type <number_of_parameters> argument_expression_list

%type <exp> 
    expression
	primary_expression
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	and_expression
	exclusive_or_expression
	inclusive_or_expression
	logical_and_expression
	logical_or_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <stmt> statement
    compound_statement
	selection_statement
	iteration_statement
	labeled_statement
	jump_statement
	block_item
	block_item_list

%type <symType> pointer

%type <sym> constant initializer direct_declarator init_declarator declarator

%type <arr> postfix_expression unary_expression cast_expression

 
%type <instrNum> M
%type <stmt> N

%%
primary_expression: IDENTIFIER
	{
	    $$=new expression();                                                   
	    $$->loc=$1;
	    $$->type="NONBOOL";
	}
	| constant
	{
		$$ = new expression();
		$$->loc = $1;
	}
	| STRING_LITERAL        					    
	{                                                                           
		$$=new expression();
		$$->loc=gentemp(new SymbolType("PTR"),$1);
		$$->loc->type->ptr=new SymbolType("CHAR");

	 List_of_string.push_back($1);
		string tmp = to_string List_of_string.size()-1);
		emit("EQUALSTR", $$->loc->name, tmp);
		
	}
	| '(' expression ')'
	{                                                                           
		$$=$2;
	}
	;

constant:
	INTEGER_CONSTANT
	{
		$$ = gentemp(new SymbolType("INT"),to_string($1));
		emit("EQUAL", $$->name, $1);
	}
	| FLOATING_CONSTANT        	  					   
	{                                                                          
		$$ = gentemp(new SymbolType("FLOAT"), to_string($1));
		emit("EQUAL",$$->name, $1);
	}
	| CHARACTER_CONSTANT       	  			
	{                                                                          
		$$ = gentemp(new SymbolType("CHAR"),$1);
		emit("EQUALCHAR", $$->name, string($1));
	}
	;


M : %empty
    {
        $$ = nextInstruction();
    }
    ;
N:  %empty
    {
        $$ = new statement();
        $$->nextList = makelist(nextInstruction());
        emit("GOTOOP","");
    }
    ;
changetable: %empty
    {                                                          
		if(current_symbol->nestedST == NULL) 
		{
			changecurrentTable(new SymbolTable(""));	                                            
		}
		else 
		{
			changecurrentTable(current_symbol->nestedST);						                
			emit("FUNC", current_Table->name);
		}
    }
    ;

postfix_expression: primary_expression      				        
	{
		$$ = new Array();	
		$$->Sarr = $1->loc;	
		$$->type = $1->loc->type;	
		$$->loc = $$->Sarr;
	}
	| postfix_expression '[' expression ']'
	{ 	
		
		$$ = new Array();
		$$->Sarr = $1->loc;
		$$->type = $1->type->ptr;
		$$->loc = gentemp(new SymbolType("INT")); 
		$$->artype = "ARR";    	                          
		
		if($1->artype == "ARR") {			                                
			symbol* t = gentemp(new SymbolType("INT"));
			int p = Sizeoftype($$->type);
			string str = to_string(p);
			emit("MULT", t->name, $3->loc->name, str);
			emit("ADD", $$->loc->name, $1->loc->name, t->name);
		} else {   
			int p = Sizeoftype($$->type);	
			string str = to_string(p);
			emit("MULT", $$->loc->name, $3->loc->name, str);
		}
	}
	| postfix_expression '(' ')' {}
	| postfix_expression '(' argument_expression_list ')'       
	{ 
		$$ = new Array();	
		$$->Sarr = gentemp($1->type);
		string str = to_string($3);
		emit("CALL", $$->Sarr->name, $1->Sarr->name, str);
	}
	| postfix_expression DOT IDENTIFIER {  }
	| postfix_expression ARROW IDENTIFIER  {  }
	| postfix_expression INCREMENT                // ++
	{ 
		$$ = new Array();	
		$$->Sarr = gentemp($1->Sarr->type);
		emit("EQUAL", $$->Sarr->name, $1->Sarr->name);
		emit("ADD", $1->Sarr->name, $1->Sarr->name, "1"); // increment $1 by 1
	}
	| postfix_expression DECREMENT                 
	{
		$$ = new Array();	
		$$->Sarr = gentemp($1->Sarr->type);
		emit("EQUAL", $$->Sarr->name, $1->Sarr->name);
		emit("SUB", $1->Sarr->name, $1->Sarr->name, "1");	
	}
	| '(' type_name ')' '{' initializer_list '}'
	{
		$$ = new Array();
		$$->Sarr = gentemp(new SymbolType("INT"));
		$$->loc = gentemp(new SymbolType("INT"));
	}
	| '(' type_name ')' '{' initializer_list COMMA '}' 
	{
		$$ = new Array();
		$$->Sarr = gentemp(new SymbolType("INT"));
		$$->loc = gentemp(new SymbolType("INT"));
	}
	;

argument_expression_list: 
	assignment_expression    
	{
		$$ = 1;                                       
		emit("PARAM", $1->loc->name);	
	}
	| argument_expression_list COMMA assignment_expression     
	{
		$$= $1 + 1;                                   
		emit("PARAM", $3->loc->name);
	}
	;

unary_expression:
	postfix_expression 
	{ 
		$$ = $1; /*Equate $$ and $1*/
	} 					  
	| INCREMENT unary_expression                           
	{  		 
		emit("ADD", $2->Sarr->name, $2->Sarr->name, "1");		
		$$ = $2;
	}
	| DECREMENT unary_expression                           
	{
		emit("SUB", $2->Sarr->name, $2->Sarr->name, "1");
		$$ = $2;
	}
	| unary_operator cast_expression                       
	{   
		$$ = new Array();
		switch($1)
		{	  
			case '&':                                                   
				$$->Sarr = gentemp(new SymbolType("PTR"));
				$$->Sarr->type->ptr=$2->Sarr->type; 
				emit("ADDRESS", $$->Sarr->name, $2->Sarr->name);
				break;

			case '*':                                                    
				$$->artype = "PTR";
				$$->loc = gentemp($2->Sarr->type->ptr);
				$$->Sarr = $2->Sarr;
				emit("PTRR", $$->loc->name, $2->Sarr->name);
				break;

			case '+':  
				$$ = $2;
				break;                  
			
			case '-':				    
				$$->Sarr = gentemp(new SymbolType($2->Sarr->type->type));
				emit("UMINUS", $$->Sarr->name, $2->Sarr->name);
				break;
			
			case '~':                    
				$$->Sarr = gentemp(new SymbolType($2->Sarr->type->type));
				emit("BNOT", $$->Sarr->name, $2->Sarr->name);
				break;
			
			case '!':				 
				$$->Sarr = gentemp(new SymbolType($2->Sarr->type->type));
				emit("LNOT", $$->Sarr->name, $2->Sarr->name);
				break;
				
			default:
				break;
			
		}
	}
	| SIZEOF unary_expression  {  }
	| SIZEOF '(' type_name ')'   {  }
	;

unary_operator: BITWISEAND { $$ = '&'; }       
	| STAR { $$ = '*'; }
	| PLUS { $$ = '+'; }
	| MINUS { $$ = '-'; }
	| NOT { $$ = '~'; } 
	| EXCLAMATION { $$ = '!'; }
	;

cast_expression: unary_expression  { $$=$1; }                        
	| '(' type_name ')' cast_expression           
	{ 
		$$ = $4;           
	}
	;

multiplicative_expression: cast_expression  
	{
		$$ = new expression();              
		if($1->artype == "ARR") 			    
		{
			$$->loc = gentemp($1->loc->type);	
			emit("ARRR", $$->loc->name, $1->Sarr->name, $1->loc->name);      
		}
		else if($1->artype == "PTR")          
		{ 
			$$->loc = $1->loc;        	    
		}
		else
		{
			$$->loc = $1->Sarr;
		}
	}
	| multiplicative_expression STAR cast_expression           
	{ 
		 
		if(!typecheck($1->loc, $3->Sarr))         
			cout<<"Type Error in Program"<< endl;	 
		else 								 		 
		{
			$$ = new expression();	
			$$->loc = gentemp(new SymbolType($1->loc->type->type));
			emit("MULT", $$->loc->name, $1->loc->name, $3->Sarr->name);
		}
	}
	| multiplicative_expression DIVIDE cast_expression      
	{
		 
		if(!typecheck($1->loc, $3->Sarr)){ 
			cout << "Type Error in Program"<< endl;
		}
		else   
		{
			$$ = new expression();
			$$->loc = gentemp(new SymbolType($1->loc->type->type));
			emit("DIVIDE", $$->loc->name, $1->loc->name, $3->Sarr->name);
		}
	}
	| multiplicative_expression PERCENTAGE cast_expression     
	{
		
		if(!typecheck($1->loc, $3->Sarr)) 
			cout << "Type Error in Program"<< endl;		
		else 		 
		{ 
			$$ = new expression();
			$$->loc = gentemp(new SymbolType($1->loc->type->type));
			emit("MODOP", $$->loc->name, $1->loc->name, $3->Sarr->name);	
		}
	}
	;

additive_expression: multiplicative_expression   { $$=$1; }             
	| additive_expression PLUS multiplicative_expression       
	{
		
		if(!typecheck($1->loc, $3->loc))
			cout << "Type Error in Program"<< endl;
		else    	 
		{
			$$ = new expression();	
			$$->loc = gentemp(new SymbolType($1->loc->type->type));
			emit("ADD", $$->loc->name, $1->loc->name, $3->loc->name);
		}
	}
	| additive_expression MINUS multiplicative_expression     
	{
		
		if(!typecheck($1->loc, $3->loc))
			cout << "Type Error in Program"<< endl;		
		else         
		{	
			$$ = new expression();	
			$$->loc = gentemp(new SymbolType($1->loc->type->type));
			emit("SUB", $$->loc->name, $1->loc->name, $3->loc->name);
		}
	}
	;

shift_expression: additive_expression   { $$=$1; }               
	| shift_expression LEFTSHIFT additive_expression   
	{ 
		if(!($3->loc->type->type == "INT"))
			cout << "Type Error in Program"<< endl; 		
		else             
		{		
			$$ = new expression();		
			$$->loc = gentemp(new SymbolType("INT"));
			emit("LEFTOP", $$->loc->name, $1->loc->name, $3->loc->name);		
		}
	}
	| shift_expression RIGHTSHIFT additive_expression
	{ 	
		if(!($3->loc->type->type == "INT"))
			cout << "Type Error in Program"<< endl; 		
		else  		 
		{			
			$$ = new expression();	
			$$->loc = gentemp(new SymbolType("INT"));
			emit("RIGHTOP", $$->loc->name, $1->loc->name, $3->loc->name);			
		}
	}
	;

relational_expression: shift_expression   { $$=$1; }               
	| relational_expression LESSTHAN shift_expression
	{
		if(!typecheck($1->loc, $3->loc)) 
			cout << "Type Error in Program";
		else 
		{       
			$$ = new expression();
			$$->type = "BOOL";                          
			$$->trueList = makelist(nextInstruction());      
			$$->falseList = makelist(nextInstruction()+1);
			emit("LT", "", $1->loc->name, $3->loc->name);      
			emit("GOTOOP", "");	 
		}
	}
	| relational_expression GREATERTHAN shift_expression          
	{
		 
		if(!typecheck($1->loc, $3->loc)) 
			cout <<  "Type Error in Program";
		else 
		{	
			$$ = new expression();		
			$$->type = "BOOL";
			$$->trueList = makelist(nextInstruction());
			$$->falseList = makelist(nextInstruction()+1);
			emit("GT", "", $1->loc->name, $3->loc->name);
			emit("GOTOOP", "");
		}	
	}
	| relational_expression LESSEQUAL shift_expression			  
	{
		if(!typecheck($1->loc, $3->loc)) 
			cout << "Type Error in Program"<< endl;
		else 
		{			
			$$ = new expression();		
			$$->type = "BOOL";
			$$->trueList = makelist(nextInstruction());
			$$->falseList = makelist(nextInstruction()+1);
			emit("LE", "", $1->loc->name, $3->loc->name);
			emit("GOTOOP", "");
		}		
	}
	| relational_expression GREATEREQUAL shift_expression 			  
	{
		if(!typecheck($1->loc, $3->loc))
		{
			cout << "Type Error in Program"<< endl;
		}
		else 
		{	
			$$ = new expression();	
			$$->type = "BOOL";
			$$->trueList = makelist(nextInstruction());
			$$->falseList = makelist(nextInstruction()+1);
			emit("GE", "", $1->loc->name, $3->loc->name);
			emit("GOTOOP", "");
		}
	}
	;

equality_expression: relational_expression  { $$=$1; }						 
	| equality_expression EQUAL relational_expression 
	{
		if(!typecheck($1->loc, $3->loc))                 
			cout << "Type Error in Program"<< endl;
		else 
		{
			convertBool2Int($1);                   
			convertBool2Int($3);
			$$ = new expression();
			$$->type = "BOOL";
			$$->trueList = makelist(nextInstruction());             
			$$->falseList = makelist(nextInstruction()+1); 
			emit("EQOP", "", $1->loc->name, $3->loc->name);       
			emit("GOTOOP", "");				 
		}
	}
	| equality_expression NOTEQUAL relational_expression    
	{
		if(!typecheck($1->loc, $3->loc)) 
			cout << "Type Error in Program"<< endl;
		else 
		{			
			convertBool2Int($1);
			convertBool2Int($3);
			$$ = new expression();                  
			$$->type = "BOOL";
			$$->trueList = makelist(nextInstruction());
			$$->falseList = makelist(nextInstruction()+1);
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit("GOTOOP", "");
		}
	}
	;

and_expression: equality_expression  { $$=$1; }						 
	| and_expression BITWISEAND equality_expression 
	{
		if(!typecheck($1->loc, $3->loc))          
			cout << "Type Error in Program"<< endl;
		else 
		{              
			convertBool2Int($1);                              
			convertBool2Int($3);			
			$$ = new expression();
			$$->type = "NONBOOL";
			$$->loc = gentemp(new SymbolType("INT"));
			emit("BAND", $$->loc->name, $1->loc->name, $3->loc->name);       
		}
	}
	;

exclusive_or_expression: and_expression  { $$=$1; }				 
	| exclusive_or_expression XOR and_expression    
	{
		if(!typecheck($1->loc, $3->loc))     
			cout << "Type Error in Program"<< endl;
		else 
		{
			convertBool2Int($1);
			convertBool2Int($3);
			$$ = new expression();
			$$->type = "NONBOOL";
			$$->loc = gentemp(new SymbolType("INT"));
			emit("XOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
	}
	;

inclusive_or_expression: exclusive_or_expression { $$=$1; }			 
	| inclusive_or_expression BITWISEOR exclusive_or_expression          
	{ 
		if(!typecheck($1->loc, $3->loc))    
		    cout << "Type Error in Program";
		else 
		{
			convertBool2Int($1);		
			convertBool2Int($3);
			$$ = new expression();
			$$->type = "NONBOOL";
			$$->loc = gentemp(new SymbolType("INT"));
			emit("INOR", $$->loc->name, $1->loc->name, $3->loc->name);
		} 
	}
	;

logical_and_expression: inclusive_or_expression  { $$=$1; }				 
	| logical_and_expression N AND M inclusive_or_expression       
	{ 
		convertInt2Bool($5);
		backpatch($2->nextList, nextInstruction());
		convertInt2Bool($1);                                   
		$$ = new expression();                                  
		$$->type = "BOOL";
		backpatch($1->trueList, $4);                            
		$$->trueList = $5->trueList;                            
		$$->falseList = merge($1->falseList, $5->falseList);    
	}
	;

logical_or_expression: logical_and_expression   { $$=$1; }				 
	| logical_or_expression N OR M logical_and_expression         
	{ 
		convertInt2Bool($5);
		backpatch($2->nextList, nextInstruction());
		convertInt2Bool($1);			  
		$$ = new expression();			  
		$$->type = "BOOL";
		backpatch($1->falseList, $4);		 
		$$->trueList = merge($1->trueList, $5->trueList);		 
		$$->falseList = $5->falseList;		 	 
	}
	;

conditional_expression: logical_or_expression {$$=$1;}        
	| logical_or_expression N QUESTIONMARK M expression N COLON M conditional_expression 
	{
		 
		$$->loc = gentemp($5->loc->type);        
		$$->loc->update($5->loc->type);
		emit("EQUAL", $$->loc->name, $9->loc->name);       
		list<int> l = makelist(nextInstruction());         
		emit("GOTOOP", "");               
		
		backpatch($6->nextList, nextInstruction());         
		emit("EQUAL", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextInstruction());          
		l = merge(l, m);						 
		emit("GOTOOP", "");

		backpatch($2->nextList, nextInstruction());    
		convertInt2Bool($1);                    
		backpatch($1->trueList, $4);            
		backpatch($1->falseList, $8);           
		backpatch(l, nextInstruction());
	}
	;

assignment_expression: conditional_expression {$$=$1;}          
	| unary_expression assignment_operator assignment_expression 
	{
		if($1->artype=="ARR")           
		{
			$3->loc = convert($3->loc, $1->type->type);
			emit("ARRL", $1->Sarr->name, $1->loc->name, $3->loc->name);	
		}
		else if($1->artype=="PTR")      
		{
			emit("PTRL", $1->Sarr->name, $3->loc->name);	
		}
		else                               
		{
			$3->loc = convert($3->loc, $1->Sarr->type->type);
			emit("EQUAL", $1->Sarr->name, $3->loc->name);
		}
		$$ = $3;
	}
	;


assignment_operator: ASSIGN   {  }
	| MULTIPLYEQUAL    {  }
	| DIVIDEEQUAL    {  }
	| MODULOEQUAL    {  }
	| PLUSEQUAL    {  }
	| MINUSEQUAL    {  }
	| SHIFTLEFTEQUAL    {  }
	| SHIFTRIGHTEQUAL    {  }
	| ANDEQUAL    {  }
	| XOREQUAL    {  }
	| OREQUAL    { }
	;

expression: assignment_expression {  $$=$1;  }
	| expression COMMA assignment_expression {   }
	;

constant_expression: conditional_expression {   }
	;

declaration: declaration_specifiers init_declarator_list SEMICOLON {	}
	| declaration_specifiers SEMICOLON {  	}
	;

declaration_specifiers: storage_class_specifier declaration_specifiers {	}
	| storage_class_specifier {	}
	| type_specifier declaration_specifiers {	}
	| type_specifier {	}
	| type_qualifier declaration_specifiers {	}
	| type_qualifier {	}
	| function_specifier declaration_specifiers {	}
	| function_specifier {	}
	;

init_declarator_list: init_declarator {	}
	| init_declarator_list COMMA init_declarator {	}
	;

init_declarator: declarator { $$ = $1; }
	| declarator ASSIGN initializer 
	{
		if($3->val != "") 
			$1->val=$3->val;         
		emit("EQUAL", $1->name, $3->name);	
	}
	;

storage_class_specifier: EXTERN  {}
	| AUTO {}
	| REGISTER {}
	| STATIC  {}
	;

type_specifier: VOID   { type_of_variable="VOID"; }            
	| CHAR   { type_of_variable
="CHAR"; }
	| SHORT  { }
	| INT   { type_of_variable
="INT"; }
	| LONG   {  }
	| FLOAT   { type_of_variable
="FLOAT"; }
	| DOUBLE   { }
	| SIGNED   {  }
	| UNSIGNED   { }
	| BOOL   {  }
	| COMPLEX   {  }
	| IMAGINARY   {  }
	| enum_specifier   {  }
	;

specifier_qualifier_list: type_specifier specifier_qualifier_list_opt   {  }
	| type_qualifier specifier_qualifier_list_opt  {  }
	;

specifier_qualifier_list_opt: %empty {  }
	| specifier_qualifier_list  {}
	;

enum_specifier: ENUM identifier_opt '{' enumerator_list '}'   {  }
	| ENUM identifier_opt '{' enumerator_list COMMA '}'   {  }
	| ENUM IDENTIFIER {}
	;

identifier_opt: %empty {}
	| IDENTIFIER   {}
	;

enumerator_list: enumerator   {}
	| enumerator_list COMMA enumerator   {}
	;	

enumerator: IDENTIFIER   {}
	| IDENTIFIER ASSIGN constant_expression {}
	;

type_qualifier: CONST {}
	| RESTRICT {}
	| VOLATILE {}
	;

function_specifier: INLINE {}
	;

declarator: pointer direct_declarator 
	{
		SymbolType *t = $1;
		while(t->ptr != NULL)
			t = t->ptr;            
		t->ptr = $2->type;                 
		$$ = $2->update($1);                   
	}
	| direct_declarator {   }
	;

direct_declarator: IDENTIFIER                  
	{
		$$ = $1->update(new SymbolType(type_of_variable
	));
		current_symbol = $$;	
	}
	| '(' declarator ')' { $$ = $2; }         
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {}
	| direct_declarator '[' type_qualifier_list ']' {}
	| direct_declarator '[' assignment_expression ']'
	{
		SymbolType *t = $1->type;
		SymbolType *prev = NULL;
		while(t->type == "ARR") 
		{
			prev = t;	
			t = t->ptr;       
		}
		if(prev==NULL) 
		{
			int temp = atoi($3->loc->val.c_str());       
			SymbolType* s = new SymbolType("ARR", $1->type, temp);         
			$$ = $1->update(s);    
		}
		else 
		{
			prev->ptr =  new SymbolType("ARR", t, atoi($3->loc->val.c_str()));      
			$$ = $1->update($1->type);
		}
	}
	| direct_declarator '[' ']'
	{
		SymbolType *t = $1->type;
		SymbolType *prev = NULL;
		while(t->type == "ARR") 
		{
			prev = t;	
			t = t->ptr;          
		}
		if(prev==NULL) 
		{
			SymbolType* s = new SymbolType("ARR", $1->type, 0);     
			$$ = $1->update(s);
		}
		else 
		{
			prev->ptr =  new SymbolType("ARR", t, 0);
			$$ = $1->update($1->type);
		}
	}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'{	}
	| direct_declarator '[' STATIC assignment_expression ']'{	}
	| direct_declarator '[' type_qualifier_list STAR ']'{	}
	| direct_declarator '[' STAR ']'{	}
	| direct_declarator '(' changetable parameter_type_list ')' 
	{
		current_Table->name = $1->name;	
		if($1->type->type !="VOID") 
		{
			symbol *s = current_Table->lookup("return");          
			s->update($1->type);		
		}
		$1->nestedST = current_Table;
		$1->cat = "function";
		current_Table->parent = global_Table;
		changecurrentTable(global_Table);				 
		current_symbol = $$;
	}
	| direct_declarator '(' identifier_list ')' {	}
	| direct_declarator '(' changetable ')' 
	{  
		current_Table->name = $1->name;
		if($1->type->type != "VOID") 
		{	
			symbol *s = current_Table->lookup("return");
			s->update($1->type);
		}
		$1->nestedST=current_Table;
		$1->cat = "function";

		current_Table->parent = global_Table;
		changecurrentTable(global_Table);				 
		current_symbol = $$;
	}
	;

type_qualifier_list_opt: %empty {}
	| type_qualifier_list {}
	;

pointer: STAR type_qualifier_list_opt   
	{ 
		$$ = new SymbolType("PTR");    
	}         
	| STAR type_qualifier_list_opt pointer 
	{ 
		$$ = new SymbolType("PTR",$3);
	}
	;

type_qualifier_list: type_qualifier   {  }
	| type_qualifier_list type_qualifier   {  }
	;

parameter_type_list: parameter_list   {  }
	| parameter_list COMMA ELLIPSIS   {  }
	;

parameter_list: parameter_declaration   {  }
	| parameter_list COMMA parameter_declaration    {  }
	;

parameter_declaration: declaration_specifiers declarator   
	{
        $2->cat = "param";
	}
	| declaration_specifiers    {  }
	;

identifier_list: IDENTIFIER	{  }		  
	| identifier_list COMMA IDENTIFIER   {  }
	;

type_name: specifier_qualifier_list   {  }
	;

initializer: assignment_expression   { $$=$1->loc; }     
	| '{' initializer_list '}'  {  }
	| '{' initializer_list COMMA '}'  {  }
	;

initializer_list: designation_opt initializer  {  }
	| initializer_list COMMA designation_opt initializer   {  }
	;

designation_opt: %empty {}
	| designation   {}
	;

designation: designator_list ASSIGN   {  }
	;

designator_list: designator    {  }
	| designator_list designator   {  }
	;

designator: '[' constant_expression ']'  {  }
	| DOT IDENTIFIER {  }
	;

/*****************STATEMENTS************/

statement   : labeled_statement  {  }
	        | compound_statement { $$=$1; }
	        | expression_statement   
	        { 
		        $$=new statement();             
		        $$->nextList=$1->nextList; 
	        }
	        | selection_statement   { $$=$1; }
	        | iteration_statement   { $$=$1; }
	        | jump_statement   { $$=$1; }
	        ;

labeled_statement   : IDENTIFIER COLON M statement   
                    {  
                        $$ = new statement();
					}
                    | CASE constant_expression COLON statement   { $$ = new statement(); }
                    | DEFAULT COLON statement   
					{
					   $$ = new statement();
					}
                    ;

compound_statement: '{' block_item_list '}'   
	{ 
		$$ = $2;
	}
	| '{'  '}'
	{ 
		$$ = new statement();
	}
	;

block_item_list: block_item   { $$=$1; }			 
	| block_item_list M block_item    
	{ 
		$$=$3;
		backpatch($1->nextList,$2);      
	}
	;

block_item: declaration   { $$=new statement(); }           
	| statement   { $$=$1; }				 
	;

expression_statement: expression SEMICOLON {$$=$1;}			 
	| SEMICOLON {$$ = new expression();}       
	;

selection_statement: IF '(' expression N ')' M statement N %prec "then"       
	{
		backpatch($4->nextList, nextInstruction());         
		convertInt2Bool($3);          
		$$ = new statement();         
		backpatch($3->trueList, $6);         
		list<int> temp = merge($3->falseList, $7->nextList);    
		$$->nextList = merge($8->nextList, temp);
	}
	| IF '(' expression N ')' M statement N ELSE M statement    
	{
		backpatch($4->nextList, nextInstruction());		 
		convertInt2Bool($3);         
		$$ = new statement();        
		backpatch($3->trueList, $6);     
		backpatch($3->falseList, $10);
		list<int> temp = merge($7->nextList, $8->nextList);        
		$$->nextList = merge($11->nextList,temp);	
	}
	| SWITCH '(' expression ')' statement {	}        
	;

iteration_statement: WHILE M '(' expression ')' M statement      
	{	
		$$ = new statement();     
		convertInt2Bool($4);      
		backpatch($7->nextList, $2);	 
		backpatch($4->trueList, $6);	 
		$$->nextList = $4->falseList;    
		 
		string str=to_string($2);		
		emit("GOTOOP",str);	
	}
	| DO M statement M WHILE '(' expression ')' SEMICOLON       
	{
		$$ = new statement();      
		convertInt2Bool($7);       
		backpatch($7->trueList, $2);						 
		backpatch($3->nextList, $4);						 
		$$->nextList = $7->falseList;                        
	}
	| FOR '(' expression_statement M expression_statement  ')' M statement      
	{
		$$ = new statement();		  
		convertInt2Bool($5);   
		backpatch($5->trueList, $7);	 
		backpatch($8->nextList, $4);	 

		string str=to_string($4);

		emit("GOTOOP", str);				 
		$$->nextList = $5->falseList;	 
	}
	| FOR '(' expression_statement M expression_statement M expression N ')' M statement      
	{
		$$ = new statement();		  
		convertInt2Bool($5);   
		backpatch($5->trueList, $10);	 
		backpatch($8->nextList, $4);	 
		backpatch($11->nextList, $6);

		string str=to_string($6);
		emit("GOTOOP", str);				 
		$$->nextList = $5->falseList;	 
	}
	;

jump_statement: GOTO IDENTIFIER SEMICOLON { $$ = new statement(); }           
	| CONTINUE SEMICOLON { $$ = new statement(); }			  
	| BREAK SEMICOLON { $$ = new statement(); }
	| RETURN expression SEMICOLON               
	{
		$$ = new statement();	
		emit("RETURN", $2->loc->name);                
	}
	| RETURN SEMICOLON 
	{
		$$ = new statement();	
		emit("RETURN", "");                          
	}
	;

/*EXTERNAL DEFINITIONS*/

translation_unit: external_declaration { }
	| translation_unit external_declaration { } 
	;

external_declaration: function_definition {  }
	| declaration   {  }
	;
	                      
function_definition: declaration_specifiers declarator declaration_list changetable compound_statement {}
    | declaration_specifiers declarator changetable compound_statement 
	{
		emit("FUNCEND", current_Table->name);
		current_Table->parent = global_Table;
		changecurrentTable(global_Table);
	}  
	;

declaration_list: declaration   {  }
	| declaration_list declaration    {  }
	;				   										  				   
%%

void yyerror(string s){
    cout << "Error: " << s << endl;
}

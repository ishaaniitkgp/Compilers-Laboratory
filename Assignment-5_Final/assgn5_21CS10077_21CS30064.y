%{
    #include <stdio.h>
    #include "ass5_21CS10077_21CS30064_translator.h"
    SymbolTable* globalTable;
    SymbolTable* currentTable;
    quad qArray[256];
    int num_of_temp=0;
    int next_instruction=0;
    string data_type;
    int data_size=0;
    extern int yylex();
    extern int lnum;
    void yyerror(char *);
%}

%union {
    int integer_val;
    float float_val;
    char *id;
    opcodeType op;
	SymbolNode *symbolnode;  
	SymbolTable* symtab;
	List* LIST;
	IdList* idlist;
	ParameterList* paramlist;
}


%token <id> AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE 
INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID 
VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY

%token<symbolnode> identifier
%token<integer_val> integer_constant
%token<float_val> floating_constant
%token<id> character_constant
%token<id> string_Literal

%token <id> Left_Square_Bracket
%token <id> Increment
%token <id> Slash
%token <id> Question_Mark
%token <id> Assignment
%token <id> Comma
%token <id> Right_Square_Bracket
%token <id> Left_Paranthesis
%token <id> Left_Curly_Bracket
%token <id> Right_Curly_Bracket
%token <id> Dot
%token <id> Arrow
%token <id> Asterisk
%token <id> Plus
%token <id> Minus
%token <id> Tilde
%token <id> Exclamation
%token <id> Modulo
%token <id> Left_Shift
%token <id> Right_Shift
%token <id> Less_Than
%token <id> Greater_Than
%token <id> Less_Than_Equal
%token <id> Greater_Than_Equal
%token <id> Colon
%token <id> Semi_Colon
%token <id> Ellipsis
%token <id> Asterisk_Assignment
%token <id> Slash_Assignment
%token <id> Modulo_Assignment
%token <id> Plus_Assignment
%token <id> Minus_Assignment
%token <id> Left_Shift_Assignment
%token <id> Decrement
%token <id> Right_Paranthesis
%token <id> Bitwise_And
%token <id> Equals
%token <id> Bitwise_Xor
%token <id> Bitwise_Or
%token <id> Logical_And
%token <id> Logical_Or
%token <id> Right_Shift_Assignment
%token <id> Not_Equals
%token <id> Bitwise_And_Assignment
%token <id> Bitwise_Or_Assignment
%token <id> Bitwise_Xor_Assignment


%token INVALID_TOKEN

%nonassoc Right_Paranthesis
%nonassoc ELSE

// datatypes for non terminals

%type <symbolnode> primary_expression postfix_expression unary_expression cast_expression additive_expression multiplicative_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression
inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression
expression constant_expression

%type <paramlist> argument_expression_list      
%type <op> unary_operator assignment_operator


%type <id> declaration_specifiers type_specifier specifier_qualifier_list type_name  // store "int" and "float" in symbolTable 


// List of identifiers in SymbolTable

%type <idlist> declaration init_declarator_list init_declarator declarator direct_declarator parameter_type_list
parameter_list parameter_declaration identifier_list initialiser initialiser_list designation designator_list 
 designator

%type <symbolnode> storage_class_specifier enum_specifier enumerator_list enumerator type_qualifier function_specifier
type_qualifier_list

%type <LIST> pointer	// linked list pointer level






// List of index of quads

%type <LIST> statement labeled_statement compound_statement block_item_list block_item expression_statement
selection_statement iteration_statement jump_statement

%type <symbolnode> expression_opt1 expression_opt2	 	



%type <idlist> external_declaration function_definition declaration_list


// control statements 
%type <integer_val> M    // rule for obtaining nextinstr
%type <LIST> N 		// list of indices of quads


%type <symtab> X Y  // function declaration and execution


%start translation_unit


%%

primary_expression:
                    identifier {$$=lookup(currentTable,$1->name);}
                    | integer_constant
                    {
                        $$=gentemp(currentTable);
  	                    $$->init_val.flag=1;
  	                    $$->init_val.intval=$1;
  	                    update(currentTable,$$,"int");
  	                    char temp[20];
  	                    sprintf(temp,"%d",$$->init_val.intval);
  	                    emit($$->name,copy_assignment,temp);
                    }
                    | floating_constant 
                    {
                        $$=gentemp(currentTable);
  	                    $$->init_val.flag=2;
  	                    $$->init_val.floatval=$1;
  	                    update(currentTable,$$,"float");
  	                    char temp[12];
  	                    sprintf(temp,"%f",$$->init_val.floatval);
  	                    emit($$->name,copy_assignment,temp);
                    }
                    | character_constant
                    {
                        $$=gentemp(currentTable);
  	                    $$->init_val.flag=3;
  	                    $$->init_val.str=string($1);
  	                    update(currentTable,$$,"char");
  	                    emit($$->name,copy_assignment,$$->init_val.str);
                    }
                    | string_Literal 
                    {
                        $$=gentemp(currentTable);
  	                    $$->init_val.flag=3;
  	                    $$->init_val.str=$1;
  	                    update(currentTable,$$,"char");
  	                    emit($$->name,copy_assignment,$$->init_val.str);
                    }
                    | Left_Paranthesis expression Right_Paranthesis {$$=$2;}
                    ;

postfix_expression:
                    primary_expression {$$=$1;}
                    | postfix_expression Left_Square_Bracket expression Right_Square_Bracket 
                    {
                        SymbolNode* temp=gentemp(currentTable);
	                    update(currentTable,temp,"int");
	                    char arg2[20];
	                    sprintf(arg2,"%d",$1->size / $1->arglist->index);
	                    sprintf(arg2,"%d",$1->size / $1->arglist->index);
	                    emit(temp->name,mul,$3->name,arg2);
	                    $$=gentemp(currentTable);
	                    emit($$->name,array,$1->name,temp->name);
	                    $$->init_val=$1->init_val;
	                    $$->size=$1->size / $1->arglist->index;
	                    $$->type=$1->type;
	                    $$->arglist=$1->arglist->next; 
                    }
                    | postfix_expression Left_Paranthesis Right_Paranthesis 
                    {
	                    $$=gentemp(currentTable); 
	                    emit($$->name,func,$1->name,"0");
                    }
                    | postfix_expression Left_Paranthesis argument_expression_list Right_Paranthesis 
                    {
                        ParameterList* temp=$3;
	                    int length=0;
	                    while(temp!=NULL){
	                    	emit(temp->name,param);
	                    	temp=temp->next;
	                    	length++;
	                    }
	                    char strg[20];
	                    sprintf(strg,"%d",length);
	                    if($1->type=="void")
	                    	emit("", func,$1->name,strg);
	                    else{
	                    	$$=gentemp(currentTable);
	                    	emit($$->name,func,$1->name,strg);  
	                    }	
                    }
                    | postfix_expression Dot identifier {}
                    | postfix_expression Arrow identifier {}
                    | postfix_expression Increment 
                    { 
                            $$=gentemp(currentTable);
                            emit($$->name,copy_assignment,$1->name);
                            $$->init_val.intval=$1->init_val.intval;
                            $$->init_val.flag=1;
                            update(currentTable,$$,$1->type);
                            emit($1->name,PLUS,$1->name,"1"); 
                    }
                    | postfix_expression Decrement 
                    { 
                            $$=gentemp(currentTable);
                            emit($$->name,copy_assignment,$1->name);
                            $$->init_val.intval=$1->init_val.intval;
                            $$->init_val.flag=1;
                            update(currentTable,$$,$1->type);
                            emit($1->name,MINUS,$1->name,"1"); 
                    }
                    | Left_Paranthesis type_name Right_Paranthesis Left_Curly_Bracket initialiser_list Right_Curly_Bracket {}
                    | Left_Paranthesis type_name Right_Paranthesis Left_Curly_Bracket initialiser_list Comma Right_Curly_Bracket {}
                    ;

/*argument_expression_list_opt:
                                argument_expression_list { printf(" argument_expression_list_opt -> argument_expression_list\n"); }
                                | { printf(" argument_expression_list_opt -> epsilon\n"); }
                                ;
*/
argument_expression_list:
                    assignment_expression { $$=makelist($1->name,$1->type); }
                    | argument_expression_list Comma assignment_expression { $$=merge($1,makelist($3->name,$3->type)); }
                    ;

unary_expression:
                    postfix_expression { $$=$1; }
                    | Increment unary_expression 
                    { 
                            emit($2->name,PLUS,$2->name,"1");
                            $$=$2;
                    }
                    | Decrement unary_expression 
                    { 
                            emit($2->name,MINUS,$2->name,"1");
                            $$=$2;
                    }
                    | unary_operator cast_expression 
                    { 
                            switch($1){
		                case(PLUS):
			           $$=gentemp(currentTable);
			           emit($$->name,$1,$2->name);
			           update(currentTable,$$,$2->type);
			           $$->init_val.flag=$2->init_val.flag;
			
			           break;
		
		                case(MINUS):
			           $$=gentemp(currentTable);
			           emit($$->name,$1,$2->name);
			           update(currentTable,$$,$2->type);
			           $$->init_val.flag=$2->init_val.flag;
			           break;
		
		                case(mul):
			           $$=gentemp(currentTable);
			           emit($$->name,$1,$2->name);
			           $$->arglist=$2->arglist->next;
			           if($2->type=="int"){
				      update(currentTable,$$,"int");
				      $$->init_val.flag=1;
			           }
			           else if($2->type=="float"){
				      update(currentTable,$$,"float");
				      $$->init_val.flag=2;
			           }
			           else if($2->type=="char"){
				      update(currentTable,$$,"char");
				      $$->init_val.flag=3;
			           }
			           break;

		                case(Negation):
			           if($2->init_val.flag==1){
				      $$=gentemp(currentTable);
				      update(currentTable,$$,$2->type);
				      $$->init_val.flag=$2->init_val.flag;
				      emit($$->name,$1,$2->name);
			           }
			           else
				      cout<<"Invalid operand type"<<endl;
			              break;
		
		                case(bitwiseand):
			           $$=gentemp(currentTable);
			           emit($$->name,$1,$2->name);
			           $$->arglist=makelist(0);
			           $$->arglist->next=$2->arglist;
			           $$->init_val.flag=5;
			           if($2->type=="int"){
				      update(currentTable,$$,"int");
			           }
			           else if($2->type=="float"){
				      update(currentTable,$$,"float");
			           }
			           else if($2->type=="char"){
				      update(currentTable,$$,"char");
			           }
			           break;
		
		               case(nt):
			           if($2->init_val.flag==1){
				      $$=gentemp(currentTable);
				      emit($$->name,$1,$2->name);
				      update(currentTable,$$,$2->type);
				      $$->init_val.flag=$2->init_val.flag;
			           }
			           else
				      cout<<"Invalid operand type"<<endl;
			           break;
	                   }
                    }
                    | SIZEOF unary_expression {}
                    | SIZEOF Left_Paranthesis type_name Right_Paranthesis {}
                    ;

unary_operator:
                Bitwise_And { $$=bitwiseand; }
                | Asterisk { $$=mul; }
                | Plus { $$=PLUS; }
                | Minus { $$=MINUS; }
                | Tilde { $$=Negation; }
                | Exclamation { $$=nt; }
                ;

cast_expression:
                unary_expression { $$=$1; }
                | Left_Paranthesis type_name Right_Paranthesis cast_expression 
                {
                      $$=gentemp(currentTable); 
	              $$=$4; $$->type=$2; 
	              typecheck($$,$4);
                }
                ;

multiplicative_expression:
                            cast_expression { $$=$1; }
                            | multiplicative_expression Asterisk cast_expression 
                            { 
                                 $$=gentemp(currentTable);
	                         if($1->type==$3->type){
	                        	if($1->type=="int"){
    		                            $$->init_val.flag=1;
    		                            update(currentTable,$$,"int");
    	                                }
                                 	else if($1->type=="float"){
    		                            $$->init_val.flag=2;
    		                            update(currentTable,$$,"float");
                                 	}
                                 }
                                 else if($1->type=="int" && $3->type=="float"){
                                 	$$->init_val.flag=2;
    	                                update(currentTable,$$,"float");
                                 }
                                 else{
    	                                $$->init_val.flag=2;
    	                                update(currentTable,$$,"float");
                                 }
                                 emit($$->name,mul,$1->name,$3->name);
                            }
                            | multiplicative_expression Slash cast_expression 
                            {
                                $$=gentemp(currentTable);
	                            if($1->type==$3->type){
	                            	if($1->type=="int"){
                                		$$->init_val.flag=1;
                                		update(currentTable,$$,"int");
                                	}
                                	else if($1->type=="float"){
                                		$$->init_val.flag=2;
                                		update(currentTable,$$,"float");
                                	}
                                }
                                else if($1->type=="int" && $3->type=="float"){
                                	$$->init_val.flag=2;
                                	update(currentTable,$$,"float");
                                }
                                else{
                                	$$->init_val.flag=2;
                                	update(currentTable,$$,"float");
                                }
	                            emit($$->name,DIV,$1->name,$3->name);
                            }
                            | multiplicative_expression Modulo cast_expression 
                            {
                                if($1->type=="int"){
    	                            $$=gentemp(currentTable);
    	                            $$->init_val.flag=1;
    	                            update(currentTable,$$,$1->type);
    	                            emit($$->name,rem,$1->name,$3->name);
                                }
                                else
    	                        cout<<"Invalid operand"<<endl; 
                            }
                            ;

additive_expression:
                    multiplicative_expression { $$=$1; }
                    | additive_expression Plus multiplicative_expression 
                    {
                        $$=gentemp(currentTable);
	                    if($1->type==$3->type){
	                    	if($1->type=="int"){
                        		$$->init_val.flag=1;
                        		update(currentTable,$$,"int");
                        	}
                        	else if($1->type=="float"){
                        		$$->init_val.flag=2;
                        		update(currentTable,$$,"float");
                        	}
                        }
                        else if($1->type=="int" && $3->type=="float"){
                        	$$->init_val.flag=2;
                        	update(currentTable,$$,"float");
                        }
                        else{
                        	$$->init_val.flag=2;
                        	update(currentTable,$$,"float");
                        }
	                    emit($$->name,PLUS,$1->name,$3->name);
                    }
                    | additive_expression Minus multiplicative_expression 
                    {
                        
	                    $$=gentemp(currentTable);
	                    if($1->type==$3->type){
	                    	if($1->type=="int"){
                        		$$->init_val.flag=1;
                        		update(currentTable,$$,"int");
                        	}
                        	else if($1->type=="float"){
                        		$$->init_val.flag=2;
                        		update(currentTable,$$,"float");
                        	}
                        }
                        else if($1->type=="int" && $3->type=="float"){
                        	$$->init_val.flag=2;
                        	update(currentTable,$$,"float");
                        }
                        else{
                        	$$->init_val.flag=2;
                        	update(currentTable,$$,"float");
                        }
	                    emit($$->name,MINUS,$1->name,$3->name);
                    }
                    ;

shift_expression:
                    additive_expression { $$=$1; }
                    | shift_expression Left_Shift additive_expression 
                    {
                        if($1->type=="int"){
    	                    $$=gentemp(currentTable);
    	                    $$->init_val.flag=1;
    	                    update(currentTable,$$,$1->type);
    	                    emit($$->name,leftshift,$1->name,$3->name);
                        }
                        else
    	                    cout<<"Invalid operand"<<endl;
                    }
                    | shift_expression Right_Shift additive_expression 
                    {
                        if($1->type=="int"){
    	                    $$=gentemp(currentTable);
    	                    $$->init_val.flag=1;
    	                    update(currentTable,$$,$1->type);
    	                    emit($$->name,rightshift,$1->name,$3->name);
                        }
                        else
                        	cout<<"Invalid operand"<<endl; 
                    }
                    ;

relational_expression:
                        shift_expression { $$=$1; }
                        | relational_expression Less_Than shift_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        $$->truelist=makelist(next_instruction);
	                        $$->falselist=makelist(next_instruction+1);
	                        emit("",lessthan,$1->name,$3->name);
	                        emit("",_goto);
                        }
                        | relational_expression Greater_Than shift_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        $$->truelist=makelist(next_instruction);
	                        $$->falselist=makelist(next_instruction+1);
	                        emit("",greaterthan,$1->name,$3->name);
	                        emit("",_goto); 
                        }
                        | relational_expression Less_Than_Equal shift_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        $$->truelist=makelist(next_instruction);
	                        $$->falselist=makelist(next_instruction+1);
	                        emit("",lessthanequal,$1->name,$3->name);
	                        emit("",_goto);
                        }
                        | relational_expression Greater_Than_Equal shift_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        $$->truelist=makelist(next_instruction);
	                        $$->falselist=makelist(next_instruction+1);
	                        emit("",greaterthanequal,$1->name,$3->name);
	                        emit("",_goto);
                        }
                        ;

equality_expression:
                    relational_expression { $$=$1; }
                    | equality_expression Equals relational_expression 
                    {
                        $$=new SymbolNode;
	                    $$->type="bool";
	                    $$->truelist=makelist(next_instruction);
	                    $$->falselist=makelist(next_instruction+1);
	                    emit("",isequal,$1->name,$3->name);
	                    emit("",_goto);
                    }
                    | equality_expression Not_Equals relational_expression 
                    {
                        $$=new SymbolNode;
	                    $$->type="bool";
	                    $$->truelist=makelist(next_instruction);
	                    $$->falselist=makelist(next_instruction+1);
	                    emit("",notequal,$1->name,$3->name);
	                    emit("",_goto); 
                    }
                    ;

AND_expression:
                equality_expression { $$=$1; }
                | AND_expression Bitwise_And equality_expression 
                {
                    if($1->type=="int"){
    	                $$=gentemp(currentTable);
    	                $$->init_val.intval=$1->init_val.intval & $3->init_val.intval;
    	                $$->init_val.flag=1;
    	                update(currentTable,$$,$1->type);
    	                emit($$->name,bitwiseand,$1->name,$3->name);
                    }
                    else
                    	cout<<"Invalid operand"<<endl; 
                }
                ;

exclusive_OR_expression:
                        AND_expression { $$=$1; }
                        | exclusive_OR_expression Bitwise_Xor AND_expression 
                        {
                            if($1->type=="int"){
    	                        $$=gentemp(currentTable);
    	                        $$->init_val.intval=$1->init_val.intval ^ $3->init_val.intval;
    	                        $$->init_val.flag=1;
    	                        update(currentTable,$$,$1->type);
    	                        emit($$->name,bitwisexor,$1->name,$3->name);
                            }
                            else
                            	cout<<"Invalid operand"<<endl; 
                        }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression { $$=$1; }
                        | inclusive_OR_expression Bitwise_Or exclusive_OR_expression 
                        {
                            if($1->type=="int"){
    	                        $$=gentemp(currentTable);
    	                        $$->init_val.intval=$1->init_val.intval | $3->init_val.intval;
    	                        $$->init_val.flag=1;
    	                        update(currentTable,$$,$1->type);
    	                        emit($$->name,bitwiseor,$1->name,$3->name);
                            }
                            else
                            	cout<<"Invalid operand"<<endl; 
                        }
                        ;

logical_AND_expression:
                        inclusive_OR_expression { $$=$1;}
                        | logical_AND_expression Logical_And M inclusive_OR_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        backpatch($1->truelist,$3);
	                        $$->truelist=$4->truelist;
	                        $$->falselist=merge($1->falselist,$4->falselist); 
                        }
                        ;

logical_OR_expression:
                        logical_AND_expression { $$=$1; }
                        | logical_OR_expression Logical_Or M logical_AND_expression 
                        {
                            $$=new SymbolNode;
	                        $$->type="bool";
	                        backpatch($1->falselist,$3);
	                        $$->truelist=merge($1->truelist,$4->truelist);
	                        $$->falselist=$4->falselist;
                        }
                        ;

conditional_expression:
                        logical_OR_expression { $$=$1; }
                        | logical_OR_expression Question_Mark M expression N Colon M conditional_expression 
                        { 
                            $$=gentemp(currentTable);
	                        update(currentTable,$$,$4->type);
	                        emit($$->name,copy_assignment,$8->name);  
	                        List* I=makelist(next_instruction);
	                        emit("",_goto);
	                        backpatch($5,next_instruction);
	                        emit($$->name,copy_assignment,$4->name);
	                        I=merge(I,makelist(next_instruction));
	                        convInt2Bool($1);                
	                        backpatch($1->truelist,$3);
	                        backpatch($1->falselist,$7);
	                        backpatch(I,next_instruction);
                        }
                        ;

assignment_expression:
                        conditional_expression { $$=$1; }
                        | unary_expression assignment_operator assignment_expression 
                        {
                            typecheck($1,$3);
	                        emit($1->name,copy_assignment,$3->name);
                        }
                        ;

assignment_operator:
                    Assignment { $$=assignment; }
                    | Asterisk_Assignment {}
                    | Slash_Assignment {}
                    | Modulo_Assignment {}
                    | Plus_Assignment {}
                    | Minus_Assignment {}
                    | Left_Shift_Assignment {}
                    | Right_Shift_Assignment {}
                    | Bitwise_And_Assignment {}
                    | Bitwise_Xor_Assignment {}
                    | Bitwise_Or_Assignment {}
                    ;

expression:
            assignment_expression {$$=$1; }
            | expression Comma assignment_expression {}
            ;

constant_expression:
                    conditional_expression {$$=$1; }
                    ;


declaration:
            declaration_specifiers Semi_Colon {}
            | declaration_specifiers init_declarator_list Semi_Colon {$$=$2; }
            ;

/*init_declarator_list_opt:
                            init_declarator_list { printf(" init_declarator_list_opt -> init_declarator_list\n"); }
                            | { printf(" init_declarator_list_opt -> epsilon\n"); }
                            ;
*/
declaration_specifiers:
                        storage_class_specifier {}
                        | storage_class_specifier declaration_specifiers {}
                        | type_specifier {}
                        | type_specifier declaration_specifiers {}
                        | type_qualifier {}
                        | type_qualifier declaration_specifiers {}
                        | function_specifier {}
                        | function_specifier declaration_specifiers {}
                        ;

/*declaration_specifiers_opt:
                            declaration_specifiers { printf(" declaration_specifiers_opt -> declaration_specifiers\n"); }
                            | { printf(" declaration_specifiers_opt -> epsilon \n"); }
                            ;
*/
init_declarator_list:
                        init_declarator {$$=$1; }
                        | init_declarator_list Comma init_declarator {$$=merge($1,$3); }
                        ;

init_declarator:
                declarator {$$=$1; }
                | declarator Assignment initialiser 
                {
                    IdList* idtemp=$1;
	                while(idtemp->next != NULL)
	                	idtemp=idtemp->next; 					
	                idtemp->Id->init_val=$3->Id->init_val;
	                emit(idtemp->Id->name,copy_assignment,$3->Id->name);
	                $$=$1; 
                }
                ;

storage_class_specifier:
                        EXTERN {}
                        | STATIC {}
                        | AUTO {}
                        | REGISTER {}
                        ;

type_specifier:
                VOID 
                { 
                    data_type="void"; 
	                data_size=0; 
                }
                | CHAR 
                { 
                    data_type="char"; 
	                data_size=1; 
                }
                | SHORT {}
                | INT 
                { 
                    data_type="int"; 
	                data_size=4;
                }
                | LONG {}
                | FLOAT 
                {
                    data_type="float"; 
	                data_size=4;
                }
                | DOUBLE {}
                | SIGNED {}
                | UNSIGNED {}
                | _BOOL {}
                | _COMPLEX {}
                | _IMAGINARY {}
                | enum_specifier {}
                ;

specifier_qualifier_list:
                            type_specifier { $$=$1; }
                            | type_specifier specifier_qualifier_list {}
                            | type_qualifier {}
                            | type_qualifier specifier_qualifier_list {}
                            ;

/*specifier_qualifier_list_opt:
                                specifier_qualifier_list { printf(" specifier_qualifier_list_opt -> specifier_qualifier_list\n"); }
                                | { printf(" specifier_qualifier_list_opt -> epsilon\n"); }
                                ;
*/
enum_specifier:
                ENUM Left_Curly_Bracket enumerator_list Right_Curly_Bracket {}
                | ENUM identifier Left_Curly_Bracket enumerator_list Right_Curly_Bracket {}
                | ENUM Left_Curly_Bracket enumerator_list Comma Right_Curly_Bracket {}
                | ENUM identifier Left_Curly_Bracket enumerator_list Comma Right_Curly_Bracket {}
                | ENUM identifier {}
                ;

/*identifier_opt:
                identifier { printf(" identifier_opt -> enum identifier : %s\n", $1); }
                | { printf(" identifier_opt -> epsilon\n"); }
                ;
*/
enumerator_list:
                enumerator {}
                | enumerator_list Comma enumerator {}
                ;

enumerator:
            identifier {}
            | identifier Assignment constant_expression {}
            ;

type_qualifier:
                CONST {}
                | RESTRICT {}
                | VOLATILE {}
                ;

function_specifier:
                    INLINE {}
                    ;

declarator:
            direct_declarator {}
            | pointer direct_declarator {}
            ;

/*pointer_opt:
            pointer { printf(" pointer_opt -> pointer\n"); }
            | { printf(" pointer_opt -> epsilon\n"); }
            ;
*/
direct_declarator:
                    identifier 
                    { 
                        $1=lookup(currentTable,$1->name);
	                    $1->type=data_type;
	                    $1->size=data_size;
	                    $$=makelist($1); 
                    }
                    | Left_Paranthesis declarator Right_Paranthesis {}
                    | direct_declarator Left_Square_Bracket assignment_expression Right_Square_Bracket 
                    {
                        List* node=new List;
	                    $1->Id->size = $1->Id->size * $3->init_val.intval;
	                    node->index=$3->init_val.intval;
	                    if($1->Id->arglist==NULL)
	                    	$1->Id->arglist=node;
	                    else{
	                    	List* temp=$1->Id->arglist;
	                    	while(temp->next!=NULL)
	                    		temp=temp->next;
	                    	temp->next=node;
	                    }
	                    $$=$1; 
                    }
                    | direct_declarator Left_Square_Bracket type_qualifier_list assignment_expression Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket type_qualifier_list Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket STATIC type_qualifier_list assignment_expression Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket STATIC assignment_expression Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket type_qualifier_list STATIC assignment_expression Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket Asterisk Right_Square_Bracket {}
                    | direct_declarator Left_Square_Bracket type_qualifier_list Asterisk Right_Square_Bracket {}
                    | direct_declarator Left_Paranthesis X parameter_type_list Right_Paranthesis 
                    {
                        
	                    SymbolNode* ST=lookup(globalTable,$1->Id->name);
	                    ST->nested_table=$3;
	                    $1->Id->size=0;
	                    $$=$1; 
                    }
                    | direct_declarator Left_Paranthesis X Right_Paranthesis 
                    {
                        SymbolNode* ST=lookup(globalTable,$1->Id->name);
	                    ST->nested_table=$3;
	                    $1->Id->size=0;
	                    $$=$1;
                    }
                    | direct_declarator Left_Paranthesis X identifier_list Right_Paranthesis 
                    {
                        SymbolNode* ST=lookup(globalTable,$1->Id->name);
	                    ST->nested_table=$3;
	                    $1->Id->size=0;
	                    $$=$1;
                    }
                    ;

/*type_qualifier_list_opt:
                        type_qualifier_list { printf(" type_qualifier_list_opt -> type_qualifier_list\n"); }
                        | { printf(" type_qualifier_list_opt -> epsilon\n"); }
                        ;
*/
/*assignment_expression_opt:
                            assignment_expression { printf(" assignment_expression_opt -> assignment_expression\n"); }
                            | { printf(" assignment_expression_opt -> epsilon\n"); }
                            ;
*/
/*identifier_list_opt:
                    identifier_list { printf(" identifier_list_opt -> identifier_list\n"); }
                    | { printf(" identifier_list_opt -> epsilon\n"); }
                    ;
*/
pointer:
        Asterisk 
        {
            data_size=4;
	        $$=new List;
	        $$->index=0;
        }
        | Asterisk type_qualifier_list {}
        | Asterisk pointer
        {
            $2->next=new List;
	        $2->next->index=0;
	        $$=$2;
        }
        | Asterisk type_qualifier_list pointer {}
        ;

type_qualifier_list:
                    type_qualifier {}
                    | type_qualifier_list type_qualifier {}
                    ;

parameter_type_list:
                    parameter_list {$$=$1;}
                    | parameter_list Comma Ellipsis {}
                    ;

parameter_list:
                parameter_declaration {$$=$1;}
                | parameter_list Comma parameter_declaration 
                {
                    merge($1,$3);
	                $$=$1; 
                }
                ;

parameter_declaration:
                        declaration_specifiers declarator {$$=$2; }
                        | declaration_specifiers {}
                        ;

identifier_list:
                identifier 
                {
                    $1=lookup(currentTable,$1->name);
	                $1->type=data_type;
	                $1->size=data_size;
	                $$=makelist($1);
                }
                | identifier_list Comma identifier 
                {
                    $3=lookup(currentTable,$3->name);
	                $3->type=data_type;
	                $3->size=data_size;
	                merge($1,makelist($3));
	                $$=$1;
                }
                ;

type_name:
            specifier_qualifier_list { $$=$1; }
            ;

initialiser:
            assignment_expression { $$=makelist($1); }
            | Left_Curly_Bracket initialiser_list Right_Curly_Bracket {}
            | Left_Curly_Bracket initialiser_list Comma Right_Curly_Bracket {}
            ;

initialiser_list:
                    initialiser {}
                    | designation initialiser {}
                    | initialiser_list Comma initialiser {}
                    | initialiser_list Comma designation initialiser {}
                    ;

/*designation_opt:
                designation { printf(" designation_opt -> designation\n"); }
                | { printf(" designation_opt -> epsilon\n"); }
                ;
*/
designation:
            designator_list Assignment {}
            ;

designator_list:
                designator {}
                | designator_list designator {}
                ;

designator:
            Left_Square_Bracket constant_expression Right_Square_Bracket {}
            | Dot identifier {}
            ;


statement:
            labeled_statement {}
            | compound_statement {  $$=$1; }
            | expression_statement { $$=$1; }
            | selection_statement {$$=$1; }
            | iteration_statement { $$=$1; }
            | jump_statement { $$=$1; }
            ;

labeled_statement:
                    identifier Colon statement {}
                    | CASE constant_expression Colon statement {}
                    | DEFAULT Colon statement {}
                    ;

compound_statement:
                    Left_Curly_Bracket  Right_Curly_Bracket {$$=NULL;}
                    | Left_Curly_Bracket block_item_list Right_Curly_Bracket {$$=$2;}
                    ;

/*block_item_list_opt:
                    block_item_list { printf(" block_item_list_opt -> block_item_list\n"); }
                    | { printf(" block_item_list_opt -> epsilon\n"); }
                    ;
*/
block_item_list:
                block_item { $$=$1; }
                | block_item_list M block_item {$$=$3; }
                ;

block_item:
            M declaration { $$=makelist($1); }
            | statement { $$=$1; }
            ;

expression_statement:
                        expression Semi_Colon {$$=NULL;}
                        | Semi_Colon {$$=NULL;}
                        ;

M : {$$=next_instruction;};

N : 
{
	$$=makelist(next_instruction);
	emit("",_goto);
}
;

expression_opt1:
                expression { $$=$1; }
                | { $$=new SymbolNode; }
                ;

expression_opt2: 			

                {
                	$$=new SymbolNode;
                	$$->truelist=makelist(next_instruction);
                	emit("",_goto);
                } 
                | expression   
                {
                	if($1->type!="bool")
                		convInt2Bool($1);
                	$$=$1;
                }
                ;

selection_statement:
                    IF Left_Paranthesis expression_opt2 Right_Paranthesis M statement N ELSE M statement
                    {
                        backpatch($3->truelist,$5);
	                    backpatch($3->falselist,$9);
	                    $$=merge(merge($6,$7),$10);
	                    backpatch($7,next_instruction); 
                    }
                    | IF Left_Paranthesis expression_opt2 Right_Paranthesis M statement 
                    { 
                        backpatch($3->truelist,$5);
	                    $$=merge($3->falselist,$6);
	                    backpatch($3->falselist,next_instruction);  
                    }
                    | SWITCH Left_Paranthesis expression Right_Paranthesis statement {}
                    ;

iteration_statement:
                    WHILE M Left_Paranthesis expression_opt2 Right_Paranthesis M statement 
                    {
                        backpatch($7,$2);
	                    backpatch($4->truelist,$6);
	                    $$=$4->falselist;
	                    char str[20];
	                    sprintf(str,"%d",$2);
	                    emit(str,_goto);
	                    backpatch($4->falselist,next_instruction);  
                    }
                    | DO M statement M WHILE Left_Paranthesis expression_opt2 Right_Paranthesis Semi_Colon 
                    { 
                        backpatch($7->truelist,$2);
	                    backpatch($7->falselist,next_instruction);
	                    $$=$7->falselist; 
                    }
                    | FOR Left_Paranthesis expression_opt1 Semi_Colon M expression_opt2 Semi_Colon M expression_opt1 N Right_Paranthesis M statement 
                    { 
                        backpatch($6->truelist,$12);
	                    backpatch($10,$5);
	                    backpatch($13,$8);
	                    char str[20];
	                    sprintf(str,"%d",$8);
	                    emit(str,_goto);
	                    $$=$6->falselist;
	                    backpatch($6->falselist,next_instruction); 
                    }
                    | FOR Left_Paranthesis declaration expression Semi_Colon expression Right_Paranthesis statement {}
                    | FOR Left_Paranthesis declaration expression Semi_Colon Right_Paranthesis statement {}
                    | FOR Left_Paranthesis declaration Semi_Colon expression Right_Paranthesis statement {}
                    | FOR Left_Paranthesis declaration Semi_Colon Right_Paranthesis statement {}
                    ;

jump_statement:
                GOTO identifier Semi_Colon {}
                | CONTINUE Semi_Colon {}
                | BREAK Semi_Colon {}
                | RETURN expression Semi_Colon {emit($2->name,_return);}
                | RETURN Semi_Colon {emit("",_return);}
                ;


translation_unit:
                    external_declaration {}
                    | translation_unit external_declaration {}
                    ;

external_declaration:
                        function_definition {$$=$1;}
                        | declaration Y {}
                        ;

function_definition:
                    declaration_specifiers declarator declaration_list compound_statement Y {$$=$2;}
                    | declaration_specifiers declarator compound_statement Y {$$=$2;}
                    ;

/*declaration_list_opt:
                        declaration_list { printf(" declaration_list_opt => declaration_list\n"); }
                        | { printf(" declaration_list_opt -> epsilon\n"); }
                        ;
*/
declaration_list:
                    declaration {$$=$1;}
                    | declaration_list declaration 
                    {
                        merge($1,$2); 
	                    $$=$1;
                    }
                    ;

X :	
{
	$$=newTable();
	currentTable=$$;
	data_size=0;
}
;

Y : {currentTable=globalTable;};


%%

void yyerror(char* s) {
    printf("ERROR [Line %d] : %s\n", lnum, s);
}

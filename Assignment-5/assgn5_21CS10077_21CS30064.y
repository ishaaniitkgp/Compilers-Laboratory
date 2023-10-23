%{
    #include <stdio.h>
    #include "ass5_21CS10077_21CS30064_translator.h"
    SymbolTable* globalTable;
    SymbolTable* currentTable;
    quad qArray[256];
    int num_of_temp=0;
    int next_instruction=0;
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
	List* list;
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

%type <list> pointer	// linked list pointer level






// List of index of quads

%type <list> statement labeled_statement compound_statement block_item_list block_item expression_statement
selection_statement iteration_statement jump_statement

%type <symbolnode> expression_opt 	



%type <idlist> external_declaration function_definition declaration_list


// control statements 
%type <integer_val> M    // rule for obtaining nextinstr
%type <list> N 		// list of indices of quads


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
	                    	emit(temp->name,PARAM);
	                    	temp=temp->next;
	                    	length++;
	                    }
	                    char strg[20];
	                    sprintf(strg,"%d",length);
	                    if($1->type=="void")
	                    	emit("",FUNC,$1->name,strg);
	                    else{
	                    	$$=gentemp(currentTab);
	                    	emit($$->name,FUNC,$1->name,strg);  
	                    }	
                    }
                    | postfix_expression Dot identifier {printf(" postfix_expression -> postfix_expression . identifier : %s\n", $3);}
                    | postfix_expression Arrow identifier {printf(" postfix_expression -> postfix_expression -> identifier :  %s\n", $3); }
                    | postfix_expression Increment { printf(" postfix_expression -> postfix_expression ++\n"); }
                    | postfix_expression Decrement { printf(" postfix_expression -> postfix_expression --\n"); }
                    | Left_Paranthesis type_name Right_Paranthesis Left_Curly_Bracket initialiser_list Right_Curly_Bracket { printf(" postfix_expression -> ( type_name ) { initialiser_list }\n"); }
                    | Left_Paranthesis type_name Right_Paranthesis Left_Curly_Bracket initialiser_list Comma Right_Curly_Bracket { printf(" postfix_expression -> ( type_name ) { initialiser_list , }\n"); }
                    ;

/*argument_expression_list_opt:
                                argument_expression_list { printf(" argument_expression_list_opt -> argument_expression_list\n"); }
                                | { printf(" argument_expression_list_opt -> epsilon\n"); }
                                ;
*/
argument_expression_list:
                            assignment_expression { printf(" argument_expression_list -> assignment_expression\n"); }
                            | argument_expression_list Comma assignment_expression { printf(" argument_expression_list -> argument_expression_list , assignment_expression\n"); }
                            ;

unary_expression:
                    postfix_expression { printf(" unary_expression -> postfix_expression\n"); }
                    | Increment unary_expression { printf(" unary_expression -> ++ unary_expression\n"); }
                    | Decrement unary_expression { printf(" unary_expression -> -- unary_expression\n"); }
                    | unary_operator cast_expression { printf(" unary_expression -> unary_operator cast_expression\n"); }
                    | SIZEOF unary_expression { printf(" unary_expression -> sizeof unary_expression\n"); }
                    | SIZEOF Left_Paranthesis type_name Right_Paranthesis { printf(" unary_expression -> sizeof ( type_name )\n"); }
                    ;

unary_operator:
                Bitwise_And { printf(" unary_operator -> &\n"); }
                | Asterisk { printf(" unary_operator -> *\n"); }
                | Plus { printf(" unary_operator -> +\n"); }
                | Minus { printf(" unary_operator -> -\n"); }
                | Tilde { printf(" unary_operator -> ~\n"); }
                | Exclamation { printf(" unary_operator -> !\n"); }
                ;

cast_expression:
                unary_expression { printf(" cast_expression -> unary_expression\n"); }
                | Left_Paranthesis type_name Right_Paranthesis cast_expression { printf(" cast_expression -> ( type_name ) cast_expression\n"); }
                ;

multiplicative_expression:
                            cast_expression { printf(" multiplicative_expression -> cast_expression\n"); }
                            | multiplicative_expression Asterisk cast_expression { printf(" multiplicative_expression -> multiplicative_expression * cast_expression\n"); }
                            | multiplicative_expression Slash cast_expression { printf(" multiplicative_expression -> multiplicative_expression / cast_expression\n"); }
                            | multiplicative_expression Modulo cast_expression { printf(" multiplicative_expression -> multiplicative_expression %% cast_expression\n"); }
                            ;

additive_expression:
                    multiplicative_expression { printf(" additive_expression -> multiplicative_expression\n"); }
                    | additive_expression Plus multiplicative_expression { printf(" additive_expression -> additive_expression + multiplicative_expression\n"); }
                    | additive_expression Minus multiplicative_expression { printf(" additive_expression -> additive_expression - multiplicative_expression\n"); }
                    ;

shift_expression:
                    additive_expression { printf(" shift_expression -> additive_expression\n"); }
                    | shift_expression Left_Shift additive_expression { printf(" shift_expression -> shift_expression << additive_expression\n"); }
                    | shift_expression Right_Shift additive_expression { printf(" shift_expression -> shift_expression >> additive_expression\n"); }
                    ;

relational_expression:
                        shift_expression { printf(" relational_expression -> shift_expression\n"); }
                        | relational_expression Less_Than shift_expression { printf(" relational_expression -> relational_expression < shift_expression\n"); }
                        | relational_expression Greater_Than shift_expression { printf(" relational_expression -> relational_expression > shift_expression\n"); }
                        | relational_expression Less_Than_Equal shift_expression { printf(" relational_expression -> relational_expression <= shift_expression\n"); }
                        | relational_expression Greater_Than_Equal shift_expression { printf(" relational_expression -> relational_expression >= shift_expression\n"); }
                        ;

equality_expression:
                    relational_expression { printf(" equality_expression -> relational_expression\n"); }
                    | equality_expression Equals relational_expression { printf(" equality_expression -> equality_expression == relational_expression\n"); }
                    | equality_expression Not_Equals relational_expression { printf(" equality_expression -> equality_expression != relational_expression\n"); }
                    ;

AND_expression:
                equality_expression { printf(" AND_expression -> equality_expression\n"); }
                | AND_expression Bitwise_And equality_expression { printf(" AND_expression -> AND_expression & equality_expression\n"); }
                ;

exclusive_OR_expression:
                        AND_expression { printf(" exclusive_OR_expression -> AND_expression\n"); }
                        | exclusive_OR_expression Bitwise_Xor AND_expression { printf(" exclusive_OR_expression -> exclusive_OR_expression ^ AND_expression\n"); }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression { printf(" inclusive_OR_expression -> exclusive_OR_expression\n"); }
                        | inclusive_OR_expression Bitwise_Or exclusive_OR_expression { printf(" inclusive_OR_expression -> inclusive_OR_expression | exclusive_OR_expression\n"); }
                        ;

logical_AND_expression:
                        inclusive_OR_expression { printf(" logical_AND_expression -> inclusive_OR_expression\n"); }
                        | logical_AND_expression Logical_And inclusive_OR_expression { printf(" logical_AND_expression -> logical_AND_expression && inclusive_OR_expression\n"); }
                        ;

logical_OR_expression:
                        logical_AND_expression { printf(" logical_OR_expression -> logical_AND_expression"); }
                        | logical_OR_expression Logical_Or logical_AND_expression { printf(" logical_OR_expression -> logical_OR_expression || logical_AND_expression"); }
                        ;

conditional_expression:
                        logical_OR_expression { printf(" conditional_expression -> logical_OR_expression\n"); }
                        | logical_OR_expression Question_Mark expression Colon conditional_expression { printf(" conditional_expression -> logical_OR_expression ? expression : conditional_expression\n"); }
                        ;

assignment_expression:
                        conditional_expression { printf(" assignment_expression -> conditional_expression\n"); }
                        | unary_expression assignment_operator assignment_expression { printf(" assignment_expression -> unary_expression assignment_operator assignment_expression\n"); }
                        ;

assignment_operator:
                    Assignment { printf(" assignment_operator -> =\n"); }
                    | Asterisk_Assignment { printf(" assignment_operator -> *=\n"); }
                    | Slash_Assignment { printf(" assignment_operator -> /=\n"); }
                    | Modulo_Assignment { printf(" assignment_operator -> %%=\n"); }
                    | Plus_Assignment { printf(" assignment_operator -> +=\n"); }
                    | Minus_Assignment { printf(" assignment_operator -> -=\n"); }
                    | Left_Shift_Assignment { printf(" assignment_operator -> <<=\n"); }
                    | Right_Shift_Assignment { printf(" assignment_operator -> >>=\n"); }
                    | Bitwise_And_Assignment { printf(" assignment_operator -> &=\n"); }
                    | Bitwise_Xor_Assignment { printf(" assignment_operator -> ^=\n"); }
                    | Bitwise_Or_Assignment { printf(" assignment_operator -> |=\n"); }
                    ;

expression:
            assignment_expression { printf(" expression -> assignment_expression\n"); }
            | expression Comma assignment_expression { printf(" expression -> expression , assignment_expression\n"); }
            ;

constant_expression:
                    conditional_expression { printf(" constant_expression -> conditional_expression\n"); }
                    ;


declaration:
            declaration_specifiers init_declarator_list_opt Semi_Colon { printf(" declaration -> declaration_specifiers init_declarator_list_opt ;\n"); }
            ;

init_declarator_list_opt:
                            init_declarator_list { printf(" init_declarator_list_opt -> init_declarator_list\n"); }
                            | { printf(" init_declarator_list_opt -> epsilon\n"); }
                            ;

declaration_specifiers:
                        storage_class_specifier declaration_specifiers_opt { printf(" declaration_specifiers -> storage_class_specifier declaration_specifiers_opt\n"); }
                        | type_specifier declaration_specifiers_opt { printf(" declaration_specifiers -> type_specifier declaration_specifiers_opt\n"); }
                        | type_qualifier declaration_specifiers_opt { printf(" declaration_specifiers -> type_qualifier declaration_specifiers_opt\n"); }
                        | function_specifier declaration_specifiers_opt { printf(" declaration_specifiers -> function_specifier declaration_specifiers_opt\n"); }
                        ;

declaration_specifiers_opt:
                            declaration_specifiers { printf(" declaration_specifiers_opt -> declaration_specifiers\n"); }
                            | { printf(" declaration_specifiers_opt -> epsilon \n"); }
                            ;

init_declarator_list:
                        init_declarator { printf(" init_declarator_list -> init_declarator\n"); }
                        | init_declarator_list Comma init_declarator { printf(" init_declarator_list -> init_declarator_list , init_declarator\n"); }
                        ;

init_declarator:
                declarator { printf(" init_declarator -> declarator\n"); }
                | declarator Assignment initialiser { printf(" init_declarator -> declarator = initialiser\n"); }
                ;

storage_class_specifier:
                        EXTERN { printf(" storage_class_specifier -> extern\n"); }
                        | STATIC { printf(" storage_class_specifier -> static\n"); }
                        | AUTO { printf(" storage_class_specifier -> auto\n"); }
                        | REGISTER { printf(" storage_class_specifier -> register\n"); }
                        ;

type_specifier:
                VOID { printf(" type_specifier -> void\n"); }
                | CHAR { printf(" type_specifier -> char\n"); }
                | SHORT { printf(" type_specifier -> short\n"); }
                | INT { printf(" type_specifier -> int\n"); }
                | LONG { printf(" type_specifier -> long\n"); }
                | FLOAT { printf(" type_specifier -> float\n"); }
                | DOUBLE { printf(" type_specifier -> double\n"); }
                | SIGNED { printf(" type_specifier -> signed\n"); }
                | UNSIGNED { printf(" type_specifier -> unsigned\n"); }
                | _BOOL { printf(" type_specifier -> _Bool\n"); }
                | _COMPLEX { printf(" type_specifier -> _Complex\n"); }
                | _IMAGINARY { printf(" type_specifier -> _Imaginary\n"); }
                | enum_specifier { printf(" type_specifier -> enum_specifier\n"); }
                ;

specifier_qualifier_list:
                            type_specifier specifier_qualifier_list_opt { printf(" specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt\n"); }
                            | type_qualifier specifier_qualifier_list_opt { printf(" specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt\n"); }
                            ;

specifier_qualifier_list_opt:
                                specifier_qualifier_list { printf(" specifier_qualifier_list_opt -> specifier_qualifier_list\n"); }
                                | { printf(" specifier_qualifier_list_opt -> epsilon\n"); }
                                ;

enum_specifier:
                ENUM identifier_opt Left_Curly_Bracket enumerator_list Right_Curly_Bracket { printf(" enum_specifier -> enum identifier_opt { enumerator_list }\n"); }
                | ENUM identifier_opt Left_Curly_Bracket enumerator_list Comma Right_Curly_Bracket { printf(" enum_specifier -> enum identifier_opt { enumerator_list , }\n"); }
                | ENUM identifier { printf(" enum_specifier -> enum identifier : %s\n", $2); }
                ;

identifier_opt:
                identifier { printf(" identifier_opt -> enum identifier : %s\n", $1); }
                | { printf(" identifier_opt -> epsilon\n"); }
                ;

enumerator_list:
                enumerator { printf(" enumerator_list -> enumerator\n"); }
                | enumerator_list Comma enumerator { printf(" enumerator_list -> enumerator_list , enumerator\n"); }
                ;

enumerator:
            identifier { printf(" enumerator -> ENUMERATION_CONSTANT : %s\n", $1); }
            | identifier Assignment constant_expression { printf(" enumerator -> ENUMERATION_CONSTANT = constant_expression : %s\n", $1); }
            ;

type_qualifier:
                CONST { printf(" type_qualifier -> const\n"); }
                | RESTRICT { printf(" type_qualifier -> restrict\n"); }
                | VOLATILE { printf(" type_qualifier -> volatile\n"); }
                ;

function_specifier:
                    INLINE { printf(" function_specifier -> inline\n"); }
                    ;

declarator:
            pointer_opt direct_declarator { printf(" declarator -> pointer_opt direct_declarator\n"); }
            ;

pointer_opt:
            pointer { printf(" pointer_opt -> pointer\n"); }
            | { printf(" pointer_opt -> epsilon\n"); }
            ;

direct_declarator:
                    identifier { printf(" direct_declarator -> identifier : %s\n", $1); }
                    | Left_Paranthesis declarator Right_Paranthesis { printf(" direct_declarator -> ( declarator )\n"); }
                    | direct_declarator Left_Square_Bracket type_qualifier_list_opt assignment_expression_opt Right_Square_Bracket { printf(" direct_declarator -> direct_declarator [ type_qualifier_list_opt assignment_expression_opt ]\n"); }
                    | direct_declarator Left_Square_Bracket STATIC type_qualifier_list_opt assignment_expression Right_Square_Bracket { printf(" direct_declarator -> direct_declarator [ static type_qualifier_list_opt assignment_expression ]\n"); }
                    | direct_declarator Left_Square_Bracket type_qualifier_list STATIC assignment_expression Right_Square_Bracket { printf(" direct_declarator -> direct_declarator [ type_qualifier_list static assignment_expression ]\n"); }
                    | direct_declarator Left_Square_Bracket type_qualifier_list_opt Asterisk Right_Square_Bracket { printf(" direct_declarator -> direct_declarator [ type_qualifier_list_opt * ]\n"); }
                    | direct_declarator Left_Paranthesis parameter_type_list Right_Paranthesis { printf(" direct_declarator -> direct_declarator ( parameter_type_list )\n"); }
                    | direct_declarator Left_Paranthesis identifier_list_opt Right_Paranthesis { printf(" direct_declarator => direct_declarator ( identifier_list_opt )\n"); }
                    ;

type_qualifier_list_opt:
                        type_qualifier_list { printf(" type_qualifier_list_opt -> type_qualifier_list\n"); }
                        | { printf(" type_qualifier_list_opt -> epsilon\n"); }
                        ;

assignment_expression_opt:
                            assignment_expression { printf(" assignment_expression_opt -> assignment_expression\n"); }
                            | { printf(" assignment_expression_opt -> epsilon\n"); }
                            ;

identifier_list_opt:
                    identifier_list { printf(" identifier_list_opt -> identifier_list\n"); }
                    | { printf(" identifier_list_opt -> epsilon\n"); }
                    ;

pointer:
        Asterisk type_qualifier_list_opt { printf(" pointer -> * type_qualifier_list_opt\n"); }
        | Asterisk type_qualifier_list_opt pointer { printf(" pointer -> * type_qualifier_list_opt pointer\n"); }
        ;

type_qualifier_list:
                    type_qualifier { printf(" type_qualifier_list -> type_qualifier\n"); }
                    | type_qualifier_list type_qualifier { printf(" type_qualifier_list -> type_qualifier_list type_qualifier\n"); }
                    ;

parameter_type_list:
                    parameter_list { printf(" parameter_type_list -> parameter_list\n"); }
                    | parameter_list Comma Ellipsis { printf(" parameter_type_list => parameter_list , ...\n"); }
                    ;

parameter_list:
                parameter_declaration { printf(" parameter_list -> parameter_declaration\n"); }
                | parameter_list Comma parameter_declaration { printf(" parameter_list => parameter_list , parameter_declaration\n"); }
                ;

parameter_declaration:
                        declaration_specifiers declarator { printf(" parameter_declaration -> declaration_specifiers declarator\n"); }
                        | declaration_specifiers { printf(" parameter_declaration -> declaration_specifiers\n"); }
                        ;

identifier_list:
                identifier { printf(" identifier_list -> identifier: %s\n", $1); }
                | identifier_list Comma identifier { printf(" identifier_list => identifier_list , identifier %s\n", $3); }
                ;

type_name:
            specifier_qualifier_list { printf(" type_name -> specifier_qualifier_list\n"); }
            ;

initialiser:
            assignment_expression { printf(" initialiser -> assignment_expression\n"); }
            | Left_Curly_Bracket initialiser_list Right_Curly_Bracket { printf(" initialiser -> { initialiser_list }\n"); }
            | Left_Curly_Bracket initialiser_list Comma Right_Curly_Bracket { printf(" initialiser -> { initialiser_list , }\n"); }
            ;

initialiser_list:
                    designation_opt initialiser { printf(" initialiser_list -> designation_opt initialiser\n"); }
                    | initialiser_list Comma designation_opt initialiser { printf(" initialiser_list -> initialiser_list , designation_opt initialiser\n"); }
                    ;

designation_opt:
                designation { printf(" designation_opt -> designation\n"); }
                | { printf(" designation_opt -> epsilon\n"); }
                ;

designation:
            designator_list Assignment { printf(" designation => designator_list =\n"); }
            ;

designator_list:
                designator { printf(" designator_list -> designator\n"); }
                | designator_list designator { printf(" designator_list -> designator_list designator\n"); }
                ;

designator:
            Left_Square_Bracket constant_expression Right_Square_Bracket { printf(" designator -> [ constant_expression ]\n"); }
            | Dot identifier { printf(" designator -> . identifier: %s\n", $2); }
            ;


statement:
            labeled_statement { printf(" statement -> labeled_statement\n"); }
            | compound_statement { printf(" statement -> compound_statement\n"); }
            | expression_statement { printf(" statement -> expression_statement\n"); }
            | selection_statement { printf(" statement -> selection_statement\n"); }
            | iteration_statement { printf(" statement -> iteration_statement\n"); }
            | jump_statement { printf(" statement -> jump_statement\n"); }
            ;

labeled_statement:
                    identifier Colon statement { printf(" labeled_statement -> identifier : statement : %s\n", $1); }
                    | CASE constant_expression Colon statement { printf(" labeled_statement -> case constant_expression : statement\n"); }
                    | DEFAULT Colon statement { printf(" labeled_statement -> default : statement\n"); }
                    ;

compound_statement:
                    Left_Curly_Bracket block_item_list_opt Right_Curly_Bracket { printf(" compound_statement -> { block_item_list_opt }\n"); }
                    ;

block_item_list_opt:
                    block_item_list { printf(" block_item_list_opt -> block_item_list\n"); }
                    | { printf(" block_item_list_opt -> epsilon\n"); }
                    ;

block_item_list:
                block_item { printf(" block_item_list -> block_item\n"); }
                | block_item_list block_item { printf(" block_item_list -> block_item_list block_item\n"); }
                ;

block_item:
            declaration { printf(" block_item -> declaration\n"); }
            | statement { printf(" block_item -> statement\n"); }
            ;

expression_statement:
                        expression_opt Semi_Colon { printf(" expression_statement -> expression_opt ;\n"); }
                        ;

expression_opt:
                expression { printf(" designator -> [ constant_expression ]\n"); }
                | { printf(" expression_opt -> epsilon\n"); }
                ;

selection_statement:
                    IF Left_Paranthesis expression Right_Paranthesis statement { printf(" selection_statement -> if ( expression ) statement\n"); }
                    | IF Left_Paranthesis expression Right_Paranthesis statement ELSE statement { printf(" selection_statement -> if ( expression ) statement else statement\n"); }
                    | SWITCH Left_Paranthesis expression Right_Paranthesis statement { printf(" selection_statement => switch ( expression ) statement\n"); }
                    ;

iteration_statement:
                    WHILE Left_Paranthesis expression Right_Paranthesis statement { printf(" iteration_statement -> while ( expression ) statement\n"); }
                    | DO statement WHILE Left_Paranthesis expression Right_Paranthesis Semi_Colon { printf(" iteration_statement -> do statement while ( expression ) ;\n"); }
                    | FOR Left_Paranthesis expression_opt Semi_Colon expression_opt Semi_Colon expression_opt Right_Paranthesis statement { printf(" iteration_statement -> for ( expression_opt ; expression_opt ; expression_opt ) statement\n"); }
                    | FOR Left_Paranthesis declaration expression_opt Semi_Colon expression_opt Right_Paranthesis statement { printf(" iteration_statement -> for ( declaration expression_opt ; expression_opt ) statement\n"); }
                    ;

jump_statement:
                GOTO identifier Semi_Colon { printf(" jump_statement -> goto identifier ; : %s\n", $2); }
                | CONTINUE Semi_Colon { printf(" jump_statement -> continue ;\n"); }
                | BREAK Semi_Colon { printf(" jump_statement -> break ;\n"); }
                | RETURN expression_opt Semi_Colon { printf(" jump_statement -> return expression_opt ;\n"); }
                ;


translation_unit:
                    external_declaration { printf(" translation_unit -> external_declaration\n"); }
                    | translation_unit external_declaration { printf(" translation_unit -> translation_unit external_declaration\n"); }
                    ;

external_declaration:
                        function_definition { printf(" external_declaration -> function_definition\n"); }
                        | declaration { printf(" external_declaration -> declaration\n"); }
                        ;

function_definition:
                    declaration_specifiers declarator declaration_list_opt compound_statement { printf(" function_definition => declaration_specifiers declarator declaration_list_opt compound_statement\n"); }
                    ;

declaration_list_opt:
                        declaration_list { printf(" declaration_list_opt => declaration_list\n"); }
                        | { printf(" declaration_list_opt -> epsilon\n"); }
                        ;

declaration_list:
                    declaration { printf(" declaration_list -> declaration\n"); }
                    | declaration_list declaration { printf(" declaration_list -> declaration_list declaration\n"); }
                    ;



%%

void yyerror(char* s) {
    printf("ERROR [Line %d] : %s\n", lnum, s);
}

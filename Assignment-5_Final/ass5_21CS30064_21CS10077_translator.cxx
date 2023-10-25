/*
Name:- Vinayak Gupta
Roll:- 21CS10077

Name:- Ishaan Sinha
Roll No:- 21CS30064

Compilers Assignment 5
*/

#include "ass5_21CS10077_21CS30064_translator.h"
#include "y.tab.h"

SymbolTable* newTable(){
	return new SymbolTable;
}

SymbolNode* lookup(SymbolTable* symtab,string name){
	int i=0;
	//for(i=0;i<st->count;i++)
    while(i!=symtab->count){
		if(symtab->symbol[i].name==name)
			return &(symtab->symbol[i]);
        i++;    
    }        

    i=0;

	//for(i=0;i<globalTable->count;i++)
    while(i!=globalTable->count){
		if(globalTable->symbol[i].name==name)
			return &(globalTable->symbol[i]);
        i++;
    }        

	symtab->symbol[symtab->count].name=name;
	symtab->count = symtab->count + 1;
    int j= symtab->count-1;
	return &(symtab->symbol[j]);
}

SymbolNode* gentemp(SymbolTable* symtab){
	char temp[20];                               // temporary name
    sprintf(temp,"t%02d",num_of_temp++);         // generate temporary name
	return lookup(symtab,temp);                  // add temporary to symbol table
}

void update(SymbolTable* symtab,SymbolNode* sp,string type){
	if(type!=""){
		sp->type=type;
		if(sp->arglist!=NULL){
			if(sp->arglist->index==0)
				sp->size=4;	
		}
		else if(type=="int")
			sp->size=4;
		else if(type=="float")
			sp->size=4;
		else if(type=="char") 
			sp->size=1;
		else if(type=="void")
			sp->size=0;
		else if(type=="function")
			sp->size=0;
	}
}

void printSymbolTable(){
	int i,j=0;
	SymbolTable sp;
	printf("%5s %50s %15s %5s %7s %15s\n\n","NAME","TYPE","INITIAL VALUE","SIZE","OFFSET","NESTED TABLE");
	printf("GlobalTable\n");
	while(j!=globalTable->count){
		if(globalTable->symbol[j].arglist==NULL)
			printf("%5s %50s %15s %5d %7d %15p\n",globalTable->symbol[j].name.c_str(),globalTable->symbol[j].type.c_str(),"NULL",globalTable->symbol[j].size,globalTable->symbol[j].offset,globalTable->symbol[j].nested_table);
		else{
			string str,str_end=globalTable->symbol[j].type;
			List* temp=globalTable->symbol[j].arglist;
			while(temp!=NULL){
				if(temp->index==0)
					str+="ptr(";
				else{
					char t[20];
					sprintf(t,"%d",temp->index);
					str+="array("+string(t)+",";
				}
				str_end+=")";
				temp=temp->next;
			}
			str+=str_end;
			printf("%5s %50s %15s %5d %7d %15p\n",globalTable->symbol[j].name.c_str(),str.c_str(),"NULL",globalTable->symbol[j].size,globalTable->symbol[j].offset,globalTable->symbol[j].nested_table);
		}
        j++;
	}

    j=0;

	while(j!=globalTable->count){
		if(globalTable->symbol[j].nested_table==NULL)
			continue;
		printf("\n%s Function\n",globalTable->symbol[j].name.c_str());
		sp=*(globalTable->symbol[j].nested_table);
		int offset=0;
		for(i=0;i<sp.count;i++){
			sp.symbol[i].offset=offset;
			offset+=sp.symbol[i].size;
			printf("%5s ",sp.symbol[i].name.c_str());
			string str,str_end=sp.symbol[i].type;
			if(sp.symbol[i].arglist!=NULL){
				List* temp=sp.symbol[i].arglist;
				while(temp!=NULL){
					if(temp->index==0)
						str+="ptr(";
					else{
						char t[20];
						sprintf(t,"%d",temp->index);
						str+="array("+string(t)+",";
					}
					str_end+=")";
					temp=temp->next;
				}
				str+=str_end;
				printf("%50s",str.c_str());
				if(sp.symbol[i].arglist->index==0)
					printf("%17p",sp.symbol[i].init_val.ptr);
				else if(sp.symbol[i].type=="int")
					printf("%17d",sp.symbol[i].init_val.intval);
				else if(sp.symbol[i].type=="float")
					printf("%17lf",sp.symbol[i].init_val.floatval);
				else
					printf("%17s",sp.symbol[i].init_val.str.c_str());
			}
			else if(sp.symbol[i].type=="int")
				printf("%50s %15d ","int",sp.symbol[i].init_val.intval);
			else if(sp.symbol[i].type=="float")
				printf("%50s %15f ","float",sp.symbol[i].init_val.floatval);
			else 
				printf("%50s %15s ","char",sp.symbol[i].init_val.str.c_str());

			printf("%5d %7d ",sp.symbol[i].size,sp.symbol[i].offset);
			if(sp.symbol[i].nested_table==NULL)
				printf("%15s ","null");
			else
				printf("%15p ",sp.symbol[i].nested_table);
 			printf("\n");
 		}
        j++;
 	}
 }


void emit(string result,opcodeType op,string arg1,string arg2){
	qArray[next_instruction].op=op;
        qArray[next_instruction].result=result;
	qArray[next_instruction].arg1=arg1;
	qArray[next_instruction].arg2=arg2;
	
	next_instruction++;
}


void printquad(){
	int i;
	printf("quads\n");
	for(i=0;i<next_instruction;i++){
		printf("%2d  ",i);
		string op;
		switch(qArray[i].op){
			case(PLUS):
				op="+";
				break;
			case(MINUS):
				op="-";
				break;
            case(DIV):
				op="/";
				break;
			case(mul):
				op="*";
				break;
			case(uminus):
				op="-";
				break;
			case(copy_assignment):
				op="";
				break;
			case(increment):
				op="++";
				break;
			case(decrement):
				op="--";
				break;
                        case(nt):
				op="!";
				break;
			case(Negation):
				op="~";
				break;
			case(rem):
				op="%";
				break;
			case(leftshift):
				op="<<";
				break;
			case(rightshift):
				op=">>";
				break;
			case(lessthan):
				op="<";
				break;
			case(greaterthan):
				op=">";
				break;
			case(lessthanequal):	
				op="<=";
				break;
			case(greaterthanequal):
				op=">=";
				break;
			case(isequal):
				op="==";
				break;
			case(notequal):
				op="!=";
				break;
			case(bitwisexor):
				op="^";
				break;
			case(bitwiseor):
				op="|";
				break;
			case(bitwiseand):
				op="&";
				break;
			case(question_mark):
				op="?";
				break;
			case(colon):
				op=":";
				break;
			case(assignment):
				op="";
				break;
			case(logicalor):
				op="||";
				break;
			case(logicaland):
				op="&&";
				break;
			case(_goto):
				op="goto";
				break;
			case(func):
				op="call";
				break;
			case(param):
				op="param";
				break;
			case(_return):
				op="return";
				break;
			case(array):
				op="array";
				break;
		}

		if((op == "+" || op == "-" || op == "*" || op == "~" || op == "!" || op == "&") && (qArray[i].arg2 == ""))
			printf("%5s  =	%2s %3s\n",qArray[i].result.c_str(),op.c_str(),qArray[i].arg1.c_str());
		
		else if(op == "<" || op == ">" || op == "<="  || op == ">=" || op == "==" || op == "!=")
			printf("%5s %5s %2s %3s %10s %3s\n","if",qArray[i].arg1.c_str(),op.c_str(),qArray[i].arg2.c_str(),"goto ",qArray[i].result.c_str());
		
		else if(op == "goto" || op == "param" || op == "return")
			printf("%5s %3s\n",op.c_str(),qArray[i].result.c_str());
		
		else if(op == "call"){
			if(qArray[i].result == "")
				printf("%5s %5s,%5s\n",op.c_str(),qArray[i].arg1.c_str(),qArray[i].arg2.c_str());
			else
				printf("%5s 	=	 %5s %5s,%5s\n",qArray[i].result.c_str(),op.c_str(),qArray[i].arg1.c_str(),qArray[i].arg2.c_str());
		}
		else if(op == "array")
			printf("%5s 	=	 %5s[%2s]\n",qArray[i].result.c_str(),qArray[i].arg1.c_str(),qArray[i].arg2.c_str());
		else
			printf("%5s 	=	 %5s %5s %5s\n",qArray[i].result.c_str(),qArray[i].arg1.c_str(),op.c_str(),qArray[i].arg2.c_str());
	}
}

list* makelist(int index){
	list* templist=new list;
	templist->index=index;
	return templist;
}

list* merge(list* l1,list* l2){
	if(l1==NULL)
		return l2;
	if(l2==NULL)
		return l1;
	list *temp=l1;
	while(temp->next!=NULL)
		temp=temp->next;
	temp->next=l2;
	return l1;
}

void backpatch(list *p, int index){
	char str[20];
	sprintf(str,"%d",index);
	while(p!=NULL){
		qArray[p->index].result=string(str);
		p=p->next;
	}
}

void typecheck(SymbolNode *s1,SymbolNode* s2){
	if(s1->type == s2->type)
		s1->init_val = s2->init_val;
	else if(s1->type == "int"){
			s1->init_val.intval = s2->init_val.floatval;
			s1->init_val.flag = 1;
	}
	else if(s2->type == "float"){
		s1->init_val.floatval = s2->init_val.intval;
		s2->init_val.flag = 2;
	}
}


IdList* makelist(SymbolNode* sp){
	IdList* templist = new IdList;
	templist->Id = sp;
	return templist;
}

IdList* merge(IdList* l1,IdList* l2){
	if(l1==NULL)
		return l2;
	if(l2==NULL)
		return l1;
	IdList *temp=l1;
	while(temp->next!=NULL)
		temp=temp->next;
	temp->next=l2;
	return l1;
}

ParameterList* makelist(string name,string type){
	ParameterList* templist=new ParameterList;
	templist->name=name;
	templist->type=type;
	return templist;
}

ParameterList* merge(ParameterList* l1,ParameterList* l2){
	if(l1==NULL)
		return l2;
	if(l2==NULL)
		return l1;
	ParameterList *temp=l1;
	while(temp->next!=NULL)
		temp=temp->next;
	temp->next=l2;
	return l1;
}


void convInt2Bool(SymbolNode* sp){
	if(sp->type!="bool"){
		sp->type=="bool";
		sp->falselist=makelist(next_instruction);
		emit("",isequal,sp->name,"0");
		sp->truelist=makelist(next_instruction);
		emit("",_goto);
	}
}

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
			case(plus):
				op="+";
				break;
			case(minus):
				op="-";
				break;
            case(div):
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
			case(negation):
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
			case(xor):
				op="^";
				break;
			case(bitor):
				op="|";
				break;
			case(bitand):
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
		s1->value = s2->value;
	else if(s1->type == "int"){
			s1->value.ival = s2->value.dval;
			s1->value.flag = 1;
	}
	else if(s2->type == "double"){
		s1->value.dval = s2->value.ival;
		s2->value.flag = 2;
	}
}


IdList* makelist(SymbolNode* sp){
	IdList* templist = new IdList;
	templist->id = sp;
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

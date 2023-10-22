#include "myl.h"
#define Sys_Read 0
#define Stdin_Fileno 0


int printStr(char *s)
{
    int char_count;      //integer variable which will be equal to length of the string(including whitespaces and \0)
    
    for(char_count = 0; s[char_count] != '\0'; char_count++);
    
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t" 
        // making the  syscall
        "syscall \n\t"
        :
        :"S"(s), "d"(char_count)
    );
    return char_count;
}

int printInt(int n)
{
    char buff[20],zero='0';
    int i=0,j,bytes,k;
    if(n==0)
        buff[i++]=zero;
    else{
        if(n<0){
             buff[i++]='-';
             n=-n;
        }
       
    while(n){
        int dig=n%10;
        buff[i++]= (char)(zero + dig);
        n/=10;
    }
    if(buff[0]=='-')j=1;
    else j=0;
    k=i-1;
    while(j<k){
        char temp=buff[j];
        buff[j++]=buff[k];
        buff[k--]=temp;
    }
    }
    
    
    bytes=i;
  __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );
    return bytes;
}

int readInt(int *n){
	char buff[100];            //buff array which will act as buffer array and it will store the digits of integer passed as argument 
	int num_of_char,i,num,flag=0;
	
	
       asm volatile("syscall" /* Make the syscall. */
      : "=a" (num_of_char) 
      : "0" (Sys_Read), "D" (Stdin_Fileno), "S" (buff), "d" (sizeof(buff))
      : "rcx", "r11", "memory", "cc");

	
	buff[--num_of_char]= '\0';     //setting the end of buff array as '\0'
	
	//Finding the last non-space character in the input
	i=num_of_char-1;
	while(i>=0 && buff[i--]==' ');
	buff[i+2]='\0';    //after finding out the last non-space character i will be equal to the index of 2nd last non-space character so that's why i+2 has been done
	num_of_char=i+2;   // finally num_of_char updated
	
	//Finding the first non-space character in the input
	i=0;
	while(buff[i++]==' ');
	
	//checking for a negative sign and updating the flag
	if(buff[--i]=='-')
	{
	   i++;
	   flag=1;
	}
	
	//Reading the integer value from the input
	if(buff[i]>='0' && buff[i]<='9')
	{
	    num= buff[i]-'0';
	    i++;
	}
	
	else 
	    return ERR;
        
        while(i<num_of_char)                              //now running the loop to obtain the numerical value of integer whose digits are stored in buff array
        {
            if(!(buff[i]>='0' && buff[i]<='9'))
                 return ERR;
                 
            num = num*10 + buff[i]-'0';  
            i++;   
        } 

        //Applying the negative sign if required and storing the result in *n  (if flag=1 then the number is -ve)
        if(flag)
           num=-num;
           
        *n=num;
        
        return OK;   
}

int readFlt(float *f){
        char buff[100];
        int number_of_char,i,intval=0,flag=0,is_point_read=0;  //is_point_read is an integer variable which is set to 0 initially and will remain 0 until decimal point is read, once a decimal point is read the value of is_point_read is changed to 1
        float factor=0.1,decval=0,finalval; //decval will store the decimal part of floating type number getting read and intval will store the integer part and finalval will be equal to the sum of both

        
       asm volatile("syscall" /* Make the syscall. */
      : "=a" (number_of_char) 
      : "0" (Sys_Read), "D" (Stdin_Fileno), "S" (buff), "d" (sizeof(buff))
      : "rcx", "r11", "memory", "cc");

	
	buff[--number_of_char]= '\0';		//setting the end of buff array as '\0'
	i=number_of_char-1;
	
	//Finding the last non-space character in the input
	i=number_of_char-1;
	while(i>=0 && buff[i--]==' ');
	buff[i+2]='\0';			//after finding out the last non-space character i will be equal to the index of 2nd last non-space character so that's why i+2 has been done
	number_of_char=i+2;
        
        //Finding the first non-space character in the input
	i=0;
	while(buff[i++]==' ');
	
	//checking for a negative sign and updating the flag
	if(buff[--i]=='-')
	{
	   i++;
	   flag=1;		//flag=1 signifies that the floating value getting scanned is -ve
	}
	
	//Reading the integer value from the input
	if(buff[i]>='0' && buff[i]<='9')
	{
	    intval= buff[i]-'0';
	    i++;
	}
	
	//Reading . of the decimal number
	else if(buff[i]=='.'){
	is_point_read=1;
	i++;
	}
	
	else return ERR;

	while(i<number_of_char){
	    
	    if(is_point_read==0){
	        if(buff[i]>='0' && buff[i]<='9'){
	            intval=intval*10+(buff[i]-'0');         //reading the integer part of the floating point value passed as argument and updating intval variable accordingly
	        }
	        else if(buff[i]=='.'){
	            is_point_read=1;
	        }
	        else return ERR;
	    }
	    else{
	        //if again a decimal point is read, i.e. error
	        if(buff[i]=='.'){
	            return ERR;
	        }
	        else if(buff[i]>='0' && buff[i]<='9'){
	            decval=decval + factor*(buff[i]-'0');      //now reading the floating part of the floating point value passed as argument and updating intval variable accordingly
	            factor*=0.1;
	        }
	        else return ERR;
	    }
	    i++;
	}
	
	finalval=intval+decval;               
	if(flag) finalval=-finalval;
	*f = finalval;
	return OK;
}

int printFlt(float f){
	if(f==0){
		printStr("0.000000");
		int bytes=8;
		return bytes;
	}
	int intpart,i=0,j,k,l=1; 
	float floatpart;
	intpart=(int)f;            //typecasted and saved
	floatpart=f-intpart;
	char buff[100],zero='0';    //buff array will store the floating point value to be printed in form of characters
	if(f<0)buff[i++]='-';     //checking for sign
	
	if(intpart<0) intpart=(-1)*intpart;
	 while(intpart){
        int dig=intpart%10;
        buff[i++]= (char)(zero + dig);
        intpart/=10;
        }
        if(buff[0]=='-')j=1;          //j is used as flag it is 1 if f<0 else 0 
        else j=0;
        k=i-1;
        while(j<k){
          char temp=buff[j];
          buff[j++]=buff[k];
          buff[k--]=temp;
        }
	if(floatpart<0) floatpart=(-1)*floatpart;
	buff[i++]='.';
	for(l=1;l<=6;l++){
	    floatpart=floatpart*10;
	    intpart=(int)floatpart;         //typecasted
	    buff[i++]=intpart+zero;
	    floatpart=floatpart-intpart;
	}
	
	
	int bytes=i;
	 __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
        );
	
	return bytes;
}

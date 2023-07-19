#include "myl.h"
#define Sys_Read 0
#define Stdin_Fileno 0


int printStr(char *s)
{
    int char_count;
    
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
	char buff[100];
	int num_of_char,i,num,flag=0;
	
	
       asm volatile("syscall" /* Make the syscall. */
      : "=a" (num_of_char) 
      : "0" (Sys_Read), "D" (Stdin_Fileno), "S" (buff), "d" (sizeof(buff))
      : "rcx", "r11", "memory", "cc");

	
	buff[--num_of_char]= '\0';
	
	//Finding the last non-space character in the input
	i=num_of_char-1;
	while(i>=0 && buff[i--]==' ');
	buff[i+2]='\0';
	num_of_char=i+2;
	
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
        
        while(i<num_of_char)
        {
            if(!(buff[i]>='0' && buff[i]<='9'))
                 return ERR;
                 
            num = num*10 + buff[i]-'0';  
            i++;   
        } 

        //Applying the negative sign if required and storing the result in *n  
        if(flag)
           num=-num;
           
        *n=num;
        
        return OK;   
}

int readFlt(float *f){
        char buff[100];
        int number_of_char,i,intval=0,flag=0,is_point_read=0;  //is_point_read is an integer variable which is set to 0 initially and will remain 0 until decimal point is read, once a decimal point is read the value of is_point_read is changed to 1
        float factor=0.1,decval=0,finalval;

        
       asm volatile("syscall" /* Make the syscall. */
      : "=a" (number_of_char) 
      : "0" (Sys_Read), "D" (Stdin_Fileno), "S" (buff), "d" (sizeof(buff))
      : "rcx", "r11", "memory", "cc");

	
	buff[--number_of_char]= '\0';
	i=number_of_char-1;
	
	//Finding the last non-space character in the input
	i=number_of_char-1;
	while(i>=0 && buff[i--]==' ');
	buff[i+2]='\0';
	number_of_char=i+2;
        
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
	            intval=intval*10+(buff[i]-'0');
	        }
	        else if(buff[i]=='.'){
	            is_point_read=1;
	        }
	        else return ERR;
	    }
	    else{
	        //again a decimal point is read, i.e. error
	        if(buff[i]=='.'){
	            return ERR;
	        }
	        else if(buff[i]>='0' && buff[i]<='9'){
	            decval=decval + factor*(buff[i]-'0');
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
	int intpart,i=0,j,k,l=1; 
	float floatpart;
	intpart=(int)f;
	floatpart=f-intpart;
	char buff[20],zero='0';
	if(f<0)buff[i++]='-';  
	
	if(intpart<0) intpart=(-1)*intpart;
	 while(intpart){
        int dig=intpart%10;
        buff[i++]= (char)(zero + dig);
        intpart/=10;
        }
        if(buff[0]=='-')j=1;
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
	    intpart=(int)floatpart;
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

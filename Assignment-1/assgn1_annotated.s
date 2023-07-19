	.file	"assgn1.c"                                 #source file name
	.text                                                    
	.section	.rodata                            #read-only data section
	.align 8                                           #align with 8-byte boundary
.LC0:                                                      #Label of f-string 1st printf
	.string	"Enter the string (all lowrer case): "
.LC1:                                                      #Label of f-string scanf
	.string	"%s"
.LC2:                                                      #Label of f-string 2nd printf
	.string	"Length of the string: %d\n"
	.align 8                                           #align with 8-byte boundary
.LC3:
	.string	"The string in descending order: %s\n"
	.text                                              #Code starts
	.globl	main                                       #main is a global name
	.type	main, @function                            #main is a function
main:                                                      #main: starts
.LFB0:
	.cfi_startproc                                     #Call Frame Information
	endbr64                                            #End Branch 64-bit
	pushq	%rbp                                       #Save old base pointer                      
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                                 #rbp <-- rsp set new stack base pointer
	.cfi_def_cfa_register 6
	subq	$80, %rsp                                  #Create space for local array and variables
	movq	%fs:40, %rax                               #It moves the 64-bit value located at the memory address %fs:40 in the FS segment into the %rax register
	movq	%rax, -8(%rbp)                             #M[rbp-8]<-- 64-bit value stored in %rax
	xorl	%eax, %eax                                 #The value of %eax register is set to zero using the XOR operation
	leaq	.LC0(%rip), %rax     #Load the first f-string into %rax and .LC0 would be calculated relative to the value in %rip which represents the current location pointer
	movq	%rax, %rdi                                 #rdi <-- rax
	movl	$0, %eax                                   #eax=0
	call	printf@PLT                                 # Calls the printf function to print the 1st printf statement(which is in .LC0)
	leaq	-64(%rbp), %rax                            
	movq	%rax, %rsi                                 #rsi <-- rax
	leaq	.LC1(%rip), %rax                           # Load address to store parameter
	movq	%rax, %rdi                                 #rdi <-- rax
	movl	$0, %eax                                   #eax=0
	call	__isoc99_scanf@PLT                         #get the input of string
	leaq	-64(%rbp), %rax                            #copy address of string str into rax
	movq	%rax, %rdi                                 #rdi <-- rax, prepare function passing arguments
	call	length                                     #function to take input as string str          
	movl	%eax, -68(%rbp)                            #storing the value of i stored in eax to M[rbp-68] , i.e. M[rbp-68] <-- eax
	movl	-68(%rbp), %eax                            #retrieving back the value of i in eax for further use
	movl	%eax, %esi                                 #esi <-- eax
	leaq	.LC2(%rip), %rax                           #Load address of string of 2nd printf 
	movq	%rax, %rdi                                 #rdi=rax
	movl	$0, %eax                                   #eax=0
	call	printf@PLT                                 #calls the printf function of 2nd printf statement(which is in .LC2) and prints length of string
	leaq	-32(%rbp), %rdx                            #load effective address, rdx <-- M[rbp-32] 
	movl	-68(%rbp), %ecx                            #ecx <-- len
	leaq	-64(%rbp), %rax                            #load effective address, rax <-- M[rbp-64]
	movl	%ecx, %esi                                 #esi --> len 
	movq	%rax, %rdi                                 #rdi --> stores the address of str
	call	sort                                       #call the sort function and passing str,len and dest as its parameter
	leaq	-32(%rbp), %rax                            #rax stores dest array 
	movq	%rax, %rsi                                 #rsi = rax
	leaq	.LC3(%rip), %rax                           #Load address of string of 3rd printf
	movq	%rax, %rdi                                 #rdi=rax
	movl	$0, %eax                                   #eax=0
	call	printf@PLT                                 #calls the printf function of 3rd printf statement(which is in .LC3) and prints the elements of array dest stored in %rsi
	movl	$0, %eax                                   #eax=0
	movq	-8(%rbp), %rdx                             
	subq	%fs:40, %rdx
	je	.L3                                        #if %rdx - %fs:40 =0 , jump to .L3
	call	__stack_chk_fail@PLT
.L3:
	leave                                 #clear the stack
	.cfi_def_cfa 7, 8
	ret                                   #return
	.cfi_endproc                          #end the program
.LFE0:
	.size	main, .-main
	.globl	length                        #length is a global name
	.type	length, @function             #length is a function
length:                                       #length starts
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp                          #save old base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                    #temporary stack pointer
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)               #prepare function arguments
	movl	$0, -4(%rbp)                  #M[rbp-4] <-- 0 , i=0
	jmp	.L5                           #jump to .L5
.L6:
	addl	$1, -4(%rbp)                  #i=i+1
.L5:
	movl	-4(%rbp), %eax                #eax <-- M[rbp-4] , eax=i
	movslq	%eax, %rdx                    #move sign-extended version of eax to rdx
	movq	-24(%rbp), %rax               #rax stores the address of string passed as argument        
	addq	%rdx, %rax                    #rax <-- rdx + rax
	movzbl	(%rax), %eax                  #move the value stored in rax by zero extending it to 32-bit to eax
	testb	%al, %al                      #test the lower 8-bits of eax
	jne	.L6                           #jump to .L6 if al not equal to zero (basically if str[i]!=0)
	movl	-4(%rbp), %eax                #eax <-- M[rbp-4] , eax=i
	popq	%rbp                          #pop rbp, old base pointer
	.cfi_def_cfa 7, 8
	ret                                   #return i
	.cfi_endproc
.LFE1:
	.size	length, .-length
	.globl	sort                          #sort is a global name
	.type	sort, @function               #sort is a function
sort:                                         #sort starts
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp                          #save old base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                    #temporary stack pointer
	.cfi_def_cfa_register 6
	subq	$48, %rsp                     #Create space for local array and variables
	movq	%rdi, -24(%rbp)               #stores the address of string str passed as argument in M[rbp-24]
	movl	%esi, -28(%rbp)               #stores the len (passed as argument in esi) in M[rbp-28] 
	movq	%rdx, -40(%rbp)               #stores the address of string array dest in M[rbp-40]
	movl	$0, -8(%rbp)                  #M[rbp-8] <-- 0, i=0      
	jmp	.L9                           #jump to .L9
.L13:
	movl	$0, -4(%rbp)                  #M[rbp-4] <-- 0 , j=0
	jmp	.L10                          #jump to .L10
.L12:
	movl	-8(%rbp), %eax                #eax <-- M[rbp-8] , eax=i
	movslq	%eax, %rdx                    #move sign-extended value(which was stored in eax) to rdx
	movq	-24(%rbp), %rax               #rax <-- M[rbp-24] , rax stores the address of string str        
	addq	%rdx, %rax                    #rax <-- rax + rdx, rax stores the address of str[i]{str + i = str[i]}
	movzbl	(%rax), %edx                  #move value stored in rax by zero-extending it to 32-bits to edx
	movl	-4(%rbp), %eax                #eax=j
	movslq	%eax, %rcx                    #move the sign-extended value(which was stored in eax) to rax
	movq	-24(%rbp), %rax               #rax <-- M[rbp-24] , rax stores the address of string str  
	addq	%rcx, %rax                    #rax <-- rax + rcx, rax stores the address of str[j]{str + j = str[j]}
	movzbl	(%rax), %eax                  #move value stored in rax by zero-extending it to 32-bits to eax
	cmpb	%al, %dl                      #compare lower 8-bit value stored in eax(%al) with lower 8-bit value in edx(%dl), i.e. comparing str[i] and str[j]
	jge	.L11                          #if %dl>%al then jump to .L11 i.e. if str[i]>str[j]
	movl	-8(%rbp), %eax                #eax <-- M[rbp-8] , eax = i
	movslq	%eax, %rdx                    #move the sign-extended value(which is stored in eax) in rdx
	movq	-24(%rbp), %rax               #rax <-- M[rbp-24] , rax stores the address of string str
	addq	%rdx, %rax                    #rax <-- rax + rdx , rax stores the address of str[i] {str + i =str[i]}
	movzbl	(%rax), %eax                  #move value stored in rax by zero-extending it to 32-bits to eax 
	movb	%al, -9(%rbp)                 #moves the 8-bit value from %al into the memory location at an offset of -9 bytes from %rbp
	movl	-4(%rbp), %eax                #eax <-- M[rbp-4] , eax = j
	movslq	%eax, %rdx                    #move the sign-extended value(which is stored in eax) in rdx
	movq	-24(%rbp), %rax               #rax <-- M[rbp-24] , rax stores the address of string str 
	addq	%rdx, %rax                    #rax <-- rax + rdx , rax stores the address of str[j] {str + j =str[j]}
	movl	-8(%rbp), %edx                #edx <-- M[rbp-8] , edx = j
	movslq	%edx, %rcx                    #move the sign-extended value(which is stored in edx) in rcx
	movq	-24(%rbp), %rdx               #rdx <-- M[rbp-24] , rdx stores the address of string str       
	addq	%rcx, %rdx                    #rdx <-- rdx + rcx , rdx stores the address of str[i]{str + i =str[i]}
	movzbl	(%rax), %eax                  #move value stored in rax by zero-extending it to 32-bits to eax   
	movb	%al, (%rdx)                   #moves the 8-bit value from %al to %rdx, str[i]=str[j]
	movl	-4(%rbp), %eax                #eax <-- M[rbp-4] , eax = j             
	movslq	%eax, %rdx                    #move the sign-extended value(which is stored in eax) in rdx
	movq	-24(%rbp), %rax               #rax <-- M[rbp-24] , rax stores the address of string str
	addq	%rax, %rdx                    #rdx <-- rax + rdx , rdx stores the address of str[j] {str + j =str[j]}              
	movzbl	-9(%rbp), %eax                #reverse of step movzbl %eax, -9(%rbp)
	movb	%al, (%rdx)                   #str[j]=temp {where temp =str[i] before str[i]=str[j] assignment operation}
.L11:
	addl	$1, -4(%rbp)               #M[rbp-4] <-- M[rbp-4] + 1 , j = j+1
.L10:
	movl	-4(%rbp), %eax             #eax <-- M[rbp-4], eax=j
	cmpl	-28(%rbp), %eax            #compares eax with M[rbp-28], i.e. j with len
	jl	.L12                       #if eax < M[rbp-28] i.e. j < len then jump to .L12
	addl	$1, -8(%rbp)               #M[rbp-8] <-- M[rbp-8] + 1, i = i+1
.L9:
	movl	-8(%rbp), %eax             #eax <-- M[rbp-8] , eax=i
	cmpl	-28(%rbp), %eax            #compares eax with M[rbp-28], i.e. i with len  
	jl	.L13                       #if eax < M[rbp-28] i.e. i < len then jump to .L13
	movq	-40(%rbp), %rdx            #rdx <-- M[rbp-40], rdx stores the address of string dest (preparing for passing arguments)
	movl	-28(%rbp), %ecx            #ecx <-- M[rbp-28], ecx stores len (preparing for passing arguments)
	movq	-24(%rbp), %rax            #rax <-- M[rbp-24], rax stores the address of string str (preparing for passing arguments)
	movl	%ecx, %esi                 #esi <-- ecx
	movq	%rax, %rdi                 #rdi <-- rax
	call	reverse                    #call reverse function while passing str, len and dest as arguments 
	nop                                #no operation
	leave                              #clear stack
	.cfi_def_cfa 7, 8
	ret                                #return
	.cfi_endproc
.LFE2:
	.size	sort, .-sort
	.globl	reverse                    #reverse is a global name
	.type	reverse, @function         #reverse is a function
reverse:                                   #reverse starts
.LFB3:
	.cfi_startproc
	endbr64
	pushq	%rbp                      #save old base pointer 
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp                #temporary stack pointer
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)           #rdi stores address of string str
	movl	%esi, -28(%rbp)           #esi stores len   
	movq	%rdx, -40(%rbp)           #rdx stores address of string dest
	movl	$0, -8(%rbp)              #M[rbp-8] <-- 0, i=0
	jmp	.L15                      #jump to .L15
.L20:
	movl	-28(%rbp), %eax           #eax=len
	subl	-8(%rbp), %eax            #eax=len-i (eax <-- eax - M[rbp-8])
	subl	$1, %eax                  #eax=eax-1=len-i-1
	movl	%eax, -4(%rbp)            #M[rbp-4]=eax=len-i-1   
	nop                               #no operation
	movl	-28(%rbp), %eax           #eax=len
	movl	%eax, %edx                #edx=eax=len
	shrl	$31, %edx                 #shifts the value in edx to the right by 31 bits and store in edx, performed to check whether len is positive or negative
	addl	%edx, %eax                #eax <-- eax + edx 
	sarl	%eax                      #Shifts eax to the right by 1 and preserves the sign bit, basically division by 2, i.e. eax=len/2
	cmpl	%eax, -4(%rbp)            #compares len/2 with len-i-1   
	jl	.L18                      #if len-i-1 < len/2
	movl	-8(%rbp), %eax            #eax=i
	cmpl	-4(%rbp), %eax            #compares len-i-1 and len/2
	je	.L23                      #if len-i-1 = len/2 jump to .L23
	movl	-8(%rbp), %eax            #eax=i
	movslq	%eax, %rdx                #move the sign-extended value(which was stored in eax) to rdx
	movq	-24(%rbp), %rax           #rax stores the address of str
	addq	%rdx, %rax                #rax <-- rax + rdx
	movzbl	(%rax), %eax              #move zero-extended to 32-bit value(which is stored in rax) to eax
	movb	%al, -9(%rbp)             #moves the 8-bit value from %al into the memory location at an offset of -9 bytes from %rbp 
	movl	-4(%rbp), %eax            #eax=len-i-1
	movslq	%eax, %rdx                #move the sign-extended value(which was stored in eax) to rdx
	movq	-24(%rbp), %rax           #rax <-- M[rbp-24], rax stores the address of str
	addq	%rdx, %rax                #rax <-- rax + rdx, rax stores the address of str[len-i-1]
	movl	-8(%rbp), %edx            #edx=i     
	movslq	%edx, %rcx                #move the sign-extended value(which was stored in edx) to rcx
	movq	-24(%rbp), %rdx           #rdx stores the address of str
	addq	%rcx, %rdx                #rdx <-- rdx + rcx, rdx stores the address of str[i] 
	movzbl	(%rax), %eax              #move zero-extended to 32-bit value(which is stored in rax) to eax, eax=str[len-i-1]
	movb	%al, (%rdx)               #moves the lower 8-bit value in %al to %rdx, str[i]=str[len-i-1]
	movl	-4(%rbp), %eax            #eax=len-i-1
	movslq	%eax, %rdx                #move the sign-extended value(which was stored in eax) to rdx
	movq	-24(%rbp), %rax           #rax stores the address of str
	addq	%rax, %rdx                #rdx <-- rax+rdx, rdx stores the address of str[len-i-1]
	movzbl	-9(%rbp), %eax            #reverse of movb	%al, -9(%rbp)
	movb	%al, (%rdx)               #str[len-i-1]=temp {where temp is original value of str[i]}
	jmp	.L18                      #jump to .L18
.L23:
	nop                                  #no operation
.L18:
	addl	$1, -8(%rbp)                 #i=i+1
.L15:
	movl	-28(%rbp), %eax              #eax <-- M[rbp-28], eax=len
	movl	%eax, %edx                   #edx <-- eax, edx=len          
	shrl	$31, %edx                    #shifts the value in edx to the right by 31 bits and store in edx, this step effectively moves the sign bit to all bits in %edx. This is likely                                                                       
                                             #done to check if the value in %edx (which is a copy of len) is negative or positive.
	addl	%edx, %eax                   #eax <-- eax + edx
	sarl	%eax                         #Shifts eax to the right by 1 and preserves the sign bit, basically division by 2
	cmpl	%eax, -8(%rbp)               #compares %eax and M[rbp-8], basically compares len/2 and i
	jl	.L20                         #jumps to .L20 if i<len/2
	movl	$0, -8(%rbp)                 #i=0
	jmp	.L21                         #jump to .L21
.L22:
	movl	-8(%rbp), %eax               #eax=i
	movslq	%eax, %rdx                   #move the sign-extended value(which was stored in eax) to rdx
	movq	-24(%rbp), %rax              #rax <-- M[rbp-24], rax stores the address of str
	addq	%rdx, %rax                   #rax <-- rax + rdx, rax stores the address of str[i]{str + i = str[i]}
	movl	-8(%rbp), %edx               #edx <-- M[rbp-8], edx=i 
	movslq	%edx, %rcx                   #move the sign-extended value(which was stored in edx) to rcx
	movq	-40(%rbp), %rdx              #rdx <-- M[rbp-40], rdx stores the address of dest
	addq	%rcx, %rdx                   #rdx <-- rdx + rcx, rdx stores the address of dest[i] { dest + i= dest[i]}
	movzbl	(%rax), %eax                 #move zero-extended to 32-bit value(which is stored in rax) to eax
	movb	%al, (%rdx)                  #move lower 8-bit value stored in %al to rdx, i.e. dest[i]=str[i]
	addl	$1, -8(%rbp)                 #i=i+1
.L21:
	movl	-8(%rbp), %eax                     #eax=i 
	cmpl	-28(%rbp), %eax                    #compare len & i
	jl	.L22                               #jump to .L22 if i<len
	nop                                        #no operation
	nop                                        #no operation
	popq	%rbp                               #pop rbp, old base pointer
	.cfi_def_cfa 7, 8
	ret                                        #return
	.cfi_endproc                               #end the program
.LFE3:
	.size	reverse, .-reverse
	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04.1) 11.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:

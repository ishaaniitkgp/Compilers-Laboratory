a.out: lex.yy.o y.tab.o ass5_21CS30064_21CS10077_translator.o
	g++ ass5_21CS30064_21CS10077_translator.o lex.yy.o y.tab.o -lfl
	./a.out > ass5_21CS10077_21CS30064_ans1.out < ass5_21CS10077_21CS30064_test1.c 
	./a.out > ass5_21CS10077_21CS30064_ans2.out < ass5_21CS10077_21CS30064_test2.c
	./a.out > ass5_21CS10077_21CS30064_ans3.out < ass5_21CS10077_21CS30064_test3.c
	./a.out > ass5_21CS10077_21CS30064_ans4.out < ass5_21CS10077_21CS30064_test4.c
	./a.out > ass5_21CS10077_21CS30064_ans5.out < ass5_21CS10077_21CS30064_test5.c
lex.yy.o: lex.yy.c y.tab.o
	g++ -c lex.yy.c
y.tab.o: y.tab.c
	g++ -c y.tab.c
y.tab.c: assgn5_21CS10077_21CS30064.y 
	yacc -dtv assgn5_21CS10077_21CS30064.y
lex.yy.c: assgn5_21CS30064_21CS10077.l 
	flex assgn5_21CS30064_21CS10077.l
ass5_21CS30064_21CS10077_translator.o: ass5_21CS30064_21CS10077_translator.cxx ass5_21CS10077_21CS30064_translator.h
	g++ -c ass5_21CS30064_21CS10077_translator.cxx
clean:
	rm lex.yy.o y.tab.o ass5_21CS30064_21CS10077_translator.o y.tab.c lex.yy.c a.out y.tab.h y.output ass5_21CS10077_21CS30064_ans1.out ass5_21CS10077_21CS30064_ans2.out ass5_21CS10077_21CS30064_ans3.out ass5_21CS10077_21CS30064_ans4.out ass5_21CS10077_21CS30064_ans5.out

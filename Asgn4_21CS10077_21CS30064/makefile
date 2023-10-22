assgn4_21CS30064_21CS10077.txt: a.out assgn4_21CS30064_21CS10077_test.c
	./a.out < assgn4_21CS30064_21CS10077_test.c > assgn4_21CS30064_21CS10077.txt

a.out: lex.yy.o y.tab.o assgn4_21CS10077_21CS30064_main.o
	gcc lex.yy.o y.tab.o assgn4_21CS10077_21CS30064_main.o -lfl

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

assgn4_21CS10077_21CS30064_main.o: assgn4_21CS10077_21CS30064_main.c
	gcc -c assgn4_21CS10077_21CS30064_main.c

lex.yy.c: asgn4_21CS10077_21CS30064.l y.tab.h
	flex asgn4_21CS10077_21CS30064.l

y.tab.c: asgn4_21CS30064_21CS10077.y
	yacc -dtv asgn4_21CS30064_21CS10077.y -W

y.tab.h: asgn4_21CS30064_21CS10077.y
	yacc -dtv asgn4_21CS30064_21CS10077.y -W

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o assgn4_21CS10077_21CS30064_main.o y.output a.out assgn4_21CS30064_21CS10077.txt

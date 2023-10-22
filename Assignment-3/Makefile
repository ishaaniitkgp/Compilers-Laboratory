test: a.out Assign3test.c
	./a.out <Assign3test.c

a.out: lex.yy.c
	cc lex.yy.c -lfl

lex.yy.c: Assign3_21CS30064_21CS10077.l Assign3_21CS10077_21CS30064.c
	flex Assign3_21CS30064_21CS10077.l Assign3_21CS10077_21CS30064.c


clean:
	rm a.out lex.yy.c

		

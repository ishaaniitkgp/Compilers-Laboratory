a.out: main.o libass2_21CS30064.a
	gcc main.o -L. -lass2_21CS30064
main.o: main.c myl.h
	gcc -Wall -c main.c
libass2_21CS30064.a: ass2_21CS30064.o
	ar rcs libass2_21CS30064.a ass2_21CS30064.o
ass2_21CS30064.o: ass2_21CS30064.c myl.h
	gcc -Wall -c ass2_21CS30064.c
clean:
	rm a.out main.o libass2_21CS30064.a ass2_21CS30064.o

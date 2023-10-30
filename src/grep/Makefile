FLAGS = -Wall -Werror -Wextra

all: s21_grep

s21_grep: grep.o
	gcc $(FLAGS) *.o  -o s21_grep

grep.o: grep_s21.c
	gcc $(FLAGS) -c grep_s21.c -o s21_grep.o

rebuild:
	make clean
	make s21_grep

test:
	bash grep_test.sh

clean:
	rm -rf *.o
	rm -rf s21_grep 
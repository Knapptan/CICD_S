FLAGS = -Wall -Werror -Wextra

all: s21_cat

s21_cat: cat.o
	gcc $(FLAGS) *.o  -o s21_cat

cat.o: cat_s21.c
	gcc $(FLAGS) -c cat_s21.c -o s21_cat.o

rebuild:
	make clean
	make s21_cat

test:
	bash cat_test.sh

clean:
	rm -rf *.o
	rm -rf s21_cat 
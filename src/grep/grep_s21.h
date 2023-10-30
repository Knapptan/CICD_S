#include <getopt.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SIZE 1024
const char *error =
    "usage: grep [-e:ivclnhs] [-A num] [-B num] "
    "[-C[num]]\n\t[-e pattern] [-f file] [--binary-files=value] "
    "[--color=when]\n\t[--context[=num]] [--directories=action] [--label] "
    "--line-buffered]\n\t[--null] [pattern] [file ...]\n";

typedef struct {
  int e;
  int i;
  int v;
  int c;
  int l;
  int n;
  int h;
  int s;
  int f;
  int o;
  int file_name_flag;
  int check;
  int error_value;
  char pattern[4 * SIZE];
  char file_name[SIZE];
} Flags;

typedef struct {
  int count_n;
  int count_c;
  int file_print;
  int c_print;
  int l_print;
  char buff[SIZE];
} Logics;

int grep_read_flags(int argc, char *argv[], Flags *flags);
void file_open_whith_reg(Flags *flags, char *file, char *pattern);
void print_flag_o(char *buff, Flags flags);
int work_whith_args(char *argv[], int argc, Flags flags);
void search(regex_t *regex, Flags flags);
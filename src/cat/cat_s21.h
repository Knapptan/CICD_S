#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define SIZE 4096

typedef struct {
  int number_non_blank_b;     // b
  int mark_end_e;             // e
  int number_all_n;           // n
  int squeeze_s;              // s
  int tab_t;                  // t
  int print_non_printable_v;  // v
  int ssss;                   // kostil
} Flags;

int no_arg_cat(int fd);
Flags cat_read_flags(int argc, char *argv[]);
void out_print(char *file_name, Flags flag);
void files_output(int argc, char **argv, Flags flag, int optind);
int is_file(char *file_name);
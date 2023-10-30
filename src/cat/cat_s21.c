#include "cat_s21.h"

int main(int argc, char *argv[]) {
  if (argc == 1)
    no_arg_cat(STDIN_FILENO);
  else if (argc > 1) {
    Flags flags = cat_read_flags(argc, argv);
    files_output(argc, argv, flags, optind);
  } else
    printf("please try: cat [OPTION] [FILE]...");
  return 0;
}

int no_arg_cat(int fd) {
  char buffer[SIZE];
  int bytes_read;
  bytes_read = read(fd, buffer, SIZE);
  if (bytes_read == -1) return -1;
  while (bytes_read > 0) {
    printf("%.*s", bytes_read, buffer);
    bytes_read = read(fd, buffer, SIZE);
  }
  return 0;
}

Flags cat_read_flags(int argc, char *argv[]) {
  Flags flags = {0, 0, 0, 0, 0, 0, 0};
  const struct option long_options[] = {
      {"number-nonblank", no_argument, &flags.number_non_blank_b, 1},
      {"number", no_argument, &flags.number_all_n, 1},
      {"squeeze-blank", no_argument, &flags.squeeze_s, 1},
      {"school21", no_argument, &flags.ssss, 1},
      {NULL, 0, NULL, 0}};

  int current_flag = getopt_long(argc, argv, "+bevEnstT", long_options, NULL);
  while (current_flag != -1) {
    switch (current_flag) {
      case 'b':
        flags.number_non_blank_b = 1;
        break;
      case 'e':
        flags.mark_end_e = 1;
        flags.print_non_printable_v = 1;
        break;
      case 'v':
        flags.print_non_printable_v = 1;
        break;
      case 'E':
        flags.mark_end_e = 1;
        break;
      case 'n':
        flags.number_all_n = 1;
        break;
      case 's':
        flags.squeeze_s = 1;
        break;
      case 't':
        flags.print_non_printable_v = 1;
        flags.tab_t = 1;
        break;
      case 'T':
        flags.tab_t = 1;
    }
    current_flag = getopt_long(argc, argv, "+bevEnstT", long_options, NULL);
  }

  if ((flags.number_all_n == 1) && (flags.number_non_blank_b == 1)) {
    flags.number_all_n = 0;
  }
  return flags;
}

void out_print(char *file_name, Flags flag) {
  FILE *fp = NULL;
  fp = fopen(file_name, "r");
  int counter = 0, empy_line = 0, prev_empy = 0;
  char ch = fgetc(fp);
  char prev_ch = '\n';
  while (ch != EOF) {
    // check if line is empty
    if (ch == '\n' && prev_ch == '\n') {
      empy_line = 1;
    } else {
      empy_line = 0;
    }
    if (!(flag.squeeze_s && prev_empy && empy_line)) {
      // enumerate
      if (prev_ch == '\n') {
        if (flag.number_all_n || (flag.number_non_blank_b && !empy_line)) {
          printf("%6d\t", ++counter);
        }
      }
      // control chars
      if (flag.mark_end_e && ch == '\n') {
        printf("$\n");
      } else if (flag.tab_t && ch == '\t') {
        printf("^I");
      } else if (flag.print_non_printable_v && ch < 32 && ch != '\n' &&
                 ch != '\t') {
        printf("^%c", ch + 64);
      } else if (flag.print_non_printable_v && ch == 127) {
        printf("^?");
      } else {
        printf("%c", ch);
      }
    }
    prev_ch = ch;
    prev_empy = empy_line;
    ch = fgetc(fp);
  }
  fclose(fp);
}

void files_output(int argc, char **argv, Flags flag, int optind) {
  for (int i = optind; i < argc; i++) {
    if (is_file(argv[i])) {
      out_print(argv[i], flag);
    } else {
      fprintf(stderr, "cat: %s No such file or directory\n", argv[i]);
    }
  }
}

int is_file(char *file_name) {
  int res = 0;
  FILE *fp = NULL;
  fp = fopen(file_name, "r");
  if (fp != NULL) {
    res = 1;
    fclose(fp);
  }
  return res;
}
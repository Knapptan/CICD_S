#define _GNU_SOURCE
#include "grep_s21.h"

int main(int argc, char *argv[]) {
  Flags flags = {0};
  if (!grep_read_flags(argc, argv, &flags))
    work_whith_args(argv, argc, flags);
  else
    fprintf(stderr, "%s", error);
  return 0;
}

int grep_read_flags(int argc, char *argv[], Flags *flags) {
  char buff[SIZE] = {0};
  if (argc > 2) {
    int current_flag = getopt(argc, argv, "e:ivclnhsf:o");
    while (current_flag != -1) {
      switch (current_flag) {
        case 'e':
          if (!flags->e && !flags->f) {
            flags->e = 1;
            strcat(flags->pattern, optarg);
          } else if (!flags->e && flags->f) {
            flags->e = 1;
            strcat(flags->pattern, "|\0");
            strcat(flags->pattern, optarg);
          } else {
            strcat(flags->pattern, "|\0");
            strcat(flags->pattern, optarg);
          }
          break;
        case 'i':
          flags->i = 1;
          break;
        case 'v':
          flags->v = 1;
          flags->o = 0;
          break;
        case 'c':
          flags->c = 1;
          break;
        case 'l':
          flags->l = 1;
          break;
        case 'n':
          flags->n = 1;
          break;
        case 'h':
          flags->h = 1;
          break;
        case 's':
          flags->s = 1;
          break;
        case 'f':
          file_open_whith_reg(flags, optarg, buff);
          if (!flags->f && !flags->e) {
            flags->f = 1;
            strcat(flags->pattern, buff);
          } else if (!flags->f && flags->e) {
            flags->f = 1;
            strcat(flags->pattern, "|\0");
            strcat(flags->pattern, buff);
          } else {
            strcat(flags->pattern, "|\0");
            strcat(flags->pattern, buff);
          }
          break;
        case 'o':
          if (flags->v == 0) flags->o = 1;
          break;
        default: {
          flags->check = 1;
          flags->error_value = optopt;
          break;
        }
      }
      current_flag = getopt(argc, argv, "+e:ivclnhsf:o");
    }
  } else {
    flags->check = 1;
  }
  return flags->check;
}

void file_open_whith_reg(Flags *flags, char *file, char *pattern) {
  FILE *fp = fopen(file, "r");
  if (fp == 0) {
    if (!flags->s) {
      fprintf(stderr, "grep: %s: No such file or directory\n", file);
    }
  } else {
    char symbol_string = '\0';
    char buffer_string[2] = {'\0'};
    char file_buffer[SIZE] = {'\0'};
    while ((symbol_string = getc(fp)) != EOF) {
      buffer_string[0] = symbol_string;
      if (buffer_string[0] == '\n') {
        buffer_string[0] = '|';
      }
      strcat(file_buffer, buffer_string);
    }
    strcat(pattern, file_buffer);
  }
  fclose(fp);
}

void print_flag_o(char *buff, Flags flags) {
  int len = strlen(flags.pattern);
  while (*buff) {
    char *res = NULL;
    if (!flags.i) res = strstr(buff, flags.pattern);
    if (flags.i) res = strcasestr(buff, flags.pattern);

    if (res == buff) {
      for (int i = 0; i < len; i++) {
        printf("%c", res[i]);
      }
      printf("\n");
      buff += len;  // move pointer to next position
    } else {
      buff++;  // move pointer to the next charcter
    }
  }
}

int work_whith_args(char *argv[], int argc, Flags flags) {
  int file_string_num = optind;
  regex_t regex;

  // printf("%s", flags.pattern);

  if (!flags.e && !flags.f) {
    file_string_num++;
    strcat(flags.pattern, argv[optind]);
    regcomp(&regex, flags.pattern, 0);
  }
  if (flags.o || flags.f || flags.e)
    regcomp(&regex, flags.pattern, REG_EXTENDED);
  if (flags.i) regcomp(&regex, flags.pattern, REG_ICASE);
  // printf("num of fiele:%d\n", argc - file_string_num);
  if (argc - file_string_num > 1) flags.file_name_flag += 1;

  for (int i = file_string_num; i < argc; i++) {
    // printf("%s\n", flags.pattern);
    sprintf(flags.file_name, "%s", argv[i]);
    search(&regex, flags);
  }

  regfree(&regex);
  return 0;
}

void search(regex_t *regex, Flags flags) {
  FILE *fp = NULL;
  Logics logics = {0};
  fp = fopen(flags.file_name, "r");
  int res_search;

  if (fp == NULL) {
    flags.check = 1;
    if (!flags.s) {
      fprintf(stderr, "grep: %s: No such file or directory\n", flags.file_name);
    }
  } else {
    while (fgets(logics.buff, SIZE, fp) != NULL && !flags.check) {
      logics.count_n++;

      res_search = regexec(regex, logics.buff, 0, NULL, 0);

      if (flags.v && !flags.o) {  // V flag regex !
        res_search = !res_search;
      }

      if (!res_search) {
        logics.count_c++;

        if (flags.file_name_flag && !flags.h && !flags.l &&
            !flags.c) {  // H flag!
          printf("%s:", flags.file_name);
          logics.file_print++;
        }

        if (flags.file_name_flag && !flags.h && !flags.l && flags.c &&
            !logics.file_print) {  // H flag! //logics.file_print
          printf("%s:", flags.file_name);
          logics.file_print++;
        }

        if (flags.l && !flags.c && !logics.l_print) {  // L flag!
          printf("%s\n", flags.file_name);
          logics.l_print++;
        }

        if (flags.n && !flags.c && !flags.l) {  // N flag!
          printf("%d:", logics.count_n);
        }

        if (!flags.c && flags.o && !flags.l) {  // O flag!
          print_flag_o(logics.buff, flags);
        }

        if (!flags.c && !flags.l && !flags.o) {
          printf("%s", logics.buff);
          if (logics.buff[strlen(logics.buff) - 1] != '\n') printf("\n");
        }
      }
    }

    if (flags.file_name_flag && !logics.file_print && !flags.l && flags.c &&
        !flags.h) {  // H C flag!
      printf("%s:", flags.file_name);
      logics.file_print++;
    }
    if (!logics.c_print && flags.c) {  // C flag!
      printf("%d\n", logics.count_c);
      logics.c_print = 1;
    }
  }
  if (fp != NULL) fclose(fp);
}
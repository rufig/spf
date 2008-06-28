/*
 * $Id$
 * 
 * Common words to generate forth code with system-specific numeric constants
 */

#include <stdio.h>
#include <stddef.h>
#include <time.h>
#include <string.h>

#include <gnu/libc-version.h>
#include <sys/utsname.h>

/*
 * Define a constant. STATE-smart if SPF_SRC is defined
 */
void a_const(const char* name, int value, const char* comment)
{
  printf("\\ %s\n", comment);
#if defined(SPF_SRC)
    printf(": SYS_%s 0x%X STATE @ IF LIT, THEN ; IMMEDIATE\n", name, value);
#else
    printf("0x%X CONSTANT %s\n", value, name);
#endif
}

#define CONST(name,value) a_const(#name,value,#value);
#define DEFINE(name) a_const(#name,name,#name);
#define COMMENT(str) printf("\\ %s\n", str);
#define COMMENT_VALUE(val) printf("\\ %s = %u\n", #val, val);

#define ENSURE(p) if (!(p)) { fprintf(stderr,"failed : %s\n", #p); return 0; }

#define CELL 4

void print_header()
{
  char buf[2048];
  struct utsname name;
  uname(&name);
  time_t t = time(NULL);

  snprintf(buf,sizeof(buf),"%s %s  GNU libc %s %s",name.sysname,name.release,gnu_get_libc_version(),gnu_get_libc_release());
  COMMENT(buf);
  char* strtime = asctime(gmtime(&t));
  char* p = strchr(strtime,'\n');
  if (p) *p = ' ';
  snprintf(buf,sizeof(buf),"Generated on %sUTC",strtime);
  COMMENT(buf);

  printf("\n");
}

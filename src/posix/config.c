/*
 * $Id$
 * 
 * Generate forth code with system-specific numeric constants
 */

#include <stdio.h>
#include <stddef.h>
#include <time.h>

#include <gnu/libc-version.h>
#include <sys/utsname.h>

#define __USE_GNU
#include <ucontext.h>

/* ucontext.h defines these (at least for glibc)
#ifndef REG_EDI
#define REG_EDI 4
#define REG_EIP 14
#define REG_ESP 7
#define REG_EAX 11
#define REG_EBP 6
#endif
*/

/*
 * Define a STATE-smart constant
 */
void a_const(const char* name, int value, const char* comment)
{
  printf("\\ %s\n", comment);
  printf(": SYS_%s 0x%X STATE @ IF LIT, THEN ; IMMEDIATE\n", name, value);
}

#define CONST(name,value) a_const(#name,value,#value);
#define DEFINE(name) a_const(#name,name,#name);
#define COMMENT(str) printf("\\ %s\n", str);
#define COMMENT_VALUE(val) printf("\\ %s = %u\n", #val, val);
#define ENSURE(p) if (!(p)) { fprintf(stderr,"failed : %s\n", #p); return 0; }

#define CELL 4

/*
 * These conditions are implicitly assumed in SPF code, so let's verify
 */
int test()
{
  ENSURE(sizeof(int) == CELL)
  ENSURE(sizeof(void*) == CELL)
  ENSURE(offsetof(struct sigaction,sa_sigaction) == 0)
  ENSURE(offsetof(struct sigaction,sa_mask) == CELL)
  ENSURE(offsetof(struct sigaction,sa_flags) == sizeof(sigset_t) + CELL)
  ENSURE(offsetof(struct sigaction,sa_restorer) - offsetof(struct sigaction, sa_flags) == CELL)
  ENSURE(sizeof(struct sigaction) == 3*CELL + sizeof(sigset_t))
  return 1;
}

int main()
{
  if (!test())
  {
    return 1;
  }

  char buf[2048];
  struct utsname name;
  uname(&name);
  time_t t = time(NULL);

  snprintf(buf,sizeof(buf),"%s %s  GNU libc %s %s",name.sysname,name.release,gnu_get_libc_version(),gnu_get_libc_release());
  COMMENT(buf);
  snprintf(buf,sizeof(buf),"Generated on %s",ctime(&t));
  COMMENT(buf);

  COMMENT_VALUE( REG_EDI )
  CONST( CONTEXT_EDI, offsetof(ucontext_t,uc_mcontext.gregs) + REG_EDI*sizeof(greg_t) )
  COMMENT_VALUE( REG_EIP )
  CONST( CONTEXT_EIP, offsetof(ucontext_t,uc_mcontext.gregs) + REG_EIP*sizeof(greg_t) )
  COMMENT_VALUE( REG_ESP )
  CONST( CONTEXT_ESP, offsetof(ucontext_t,uc_mcontext.gregs) + REG_ESP*sizeof(greg_t) )
  COMMENT_VALUE( REG_EAX )
  CONST( CONTEXT_EAX, offsetof(ucontext_t,uc_mcontext.gregs) + REG_EAX*sizeof(greg_t) )
  COMMENT_VALUE( REG_EBP )
  CONST( CONTEXT_EBP, offsetof(ucontext_t,uc_mcontext.gregs) + REG_EBP*sizeof(greg_t) )
  DEFINE( SA_RESTART )
  DEFINE( SA_SIGINFO )
  DEFINE( SA_NODEFER )
  CONST( SIZEOF_SIGSET, sizeof(sigset_t) )
  DEFINE( SIGILL )
  DEFINE( SIGSEGV )
  DEFINE( SIGBUS )
  DEFINE( SIGFPE )
  CONST( SIGINFO_CODE, offsetof(siginfo_t,si_code))
  DEFINE( FPE_INTDIV )
  DEFINE( FPE_INTOVF )
  DEFINE( FPE_FLTDIV )
  DEFINE( FPE_FLTOVF )
  DEFINE( FPE_FLTUND )
  DEFINE( FPE_FLTRES )
  DEFINE( FPE_FLTINV )

  return 0;
}


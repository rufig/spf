/*
 * $Id$
 * 
 * Generate forth code with system-specific numeric constants
 */

#include <stdio.h>
#include <stddef.h>

/* #define __USE_GNU */
#include <ucontext.h>

#ifndef REG_EDI
#define REG_EDI 4
#endif

/*
 * Define a STATE-smart constant
 */
void a_const(const char* name, int value, const char* comment)
{
  printf("\\ %s\n", (comment));
  printf(": SYS_%s 0x%X STATE @ IF LIT, THEN ; IMMEDIATE\n", (name), (value));
}

#define CONST(name,value) a_const(#name,value,#value)
#define DEFINE(name) a_const(#name,name,#name)
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
}

int main()
{
  if (!test())
  {
    return 1;
  }

  CONST( CONTEXT_EDI, offsetof(ucontext_t,uc_mcontext.gregs) + REG_EDI*sizeof(greg_t) );
  DEFINE( SA_RESTART );
  DEFINE( SA_SIGINFO );
  DEFINE( SA_NODEFER );
  CONST( SIZEOF_SIGSET, sizeof(sigset_t) );
  DEFINE( SIGILL );
  DEFINE( SIGSEGV );
  DEFINE( SIGBUS );
  DEFINE( SIGFPE );

  return 0;
}


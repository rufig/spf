/*
 * $Id$
 * 
 * Generate forth code with system-specific numeric constants
 */

#include "config.h"

#define __USE_GNU
#include <ucontext.h>

#define __USE_LARGEFILE64
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

// dlopen
#include <dlfcn.h>

/* (glibc)
#ifndef REG_EDI
#define REG_EDI 4
#define REG_EIP 14
#define REG_ESP 7
#define REG_EAX 11
#define REG_EBP 6
#endif
*/

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
  ENSURE(sizeof(mode_t) == CELL)
  return 1;
}

int main()
{
  if (!test())
  {
    return 1;
  }

  print_header();

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
  DEFINE( SIGINT )
  CONST( SIGINFO_CODE, offsetof(siginfo_t,si_code))
  DEFINE( FPE_INTDIV )
  DEFINE( FPE_INTOVF )
  DEFINE( FPE_FLTDIV )
  DEFINE( FPE_FLTOVF )
  DEFINE( FPE_FLTUND )
  DEFINE( FPE_FLTRES )
  DEFINE( FPE_FLTINV )
  CONST( STAT_ST_MODE, offsetof(struct stat,st_mode))
  DEFINE( S_IFREG)
  DEFINE( S_IFMT)
  DEFINE( S_IFDIR)
  DEFINE( _STAT_VER)
  CONST( STAT64_ST_SIZE, offsetof(struct stat64,st_size))
  DEFINE( O_CREAT)
  DEFINE( O_TRUNC)
  DEFINE( O_RDONLY)
  DEFINE( O_WRONLY)
  DEFINE( O_RDWR)
  DEFINE( SEEK_SET)
  DEFINE( SEEK_CUR)
  DEFINE( SEEK_END)
  DEFINE( RTLD_GLOBAL)
  DEFINE( RTLD_LAZY)

  return 0;
}


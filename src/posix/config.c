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
#include <signal.h>

// dlopen
#include <dlfcn.h>

// mmap
#include <sys/mman.h>
  // e.g. https://github.com/openbsd/src/blob/master/sys/sys/mman.h

// limits
#include <limits.h>  // to obtain PAGESIZE
  // e.g. https://pubs.opengroup.org/onlinepubs/7908799/xsh/limits.h.html
#ifndef PAGESIZE
  #include <unistd.h>
  #ifdef _SC_PAGE_SIZE
    // https://man7.org/linux/man-pages/man2/mprotect.2.html#EXAMPLES
    #define PAGESIZE sysconf(_SC_PAGE_SIZE)
  #else
    #define PAGESIZE 4096
  #endif
#endif


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
  ENSURE(PAGESIZE != -1)
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
#if defined _STAT_VER
  DEFINE( _STAT_VER)
  /*
    In some versions of glibc (since 2.33) the macro "_STAT_VER" is not available.
    In the same time, the "stat" family functions that don't require "_STAT_VER" argument are exported.
    So, they can be used instead of the former functions if "_STAT_VER" is not available.

    -- see also
      -- glibc: Remove stat wrapper functions, move them to exported symbols
        -- https://sourceware.org/git/?p=glibc.git;a=commitdiff;h=8ed005daf0
        -- https://github.com/bminor/glibc/commit/8ed005daf0ab03e142500324a34087ce179ae78e
      -- glibc 2.33 compatibility issue
        -- https://www.google.com/search?q=%22error+_STAT_VER+undeclared%22
        -- https://salsa.debian.org/clint/fakeroot/-/merge_requests/10/diffs
  */
#endif
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


  // mmap
  DEFINE( PAGESIZE) // NB: it can be a call to sysconf
  DEFINE( PROT_READ)
  DEFINE( PROT_WRITE)
  DEFINE( PROT_EXEC)
  DEFINE( MAP_SHARED)
  CONST( MAP_FAILED, (long)MAP_FAILED)

  return 0;
}


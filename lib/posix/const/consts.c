/*
 * $Id$
 */

#define _BSD_SOURCE 

/* use config.h from SPF src */
#include "../../../src/posix/config.h"

#include <sys/types.h>
#include <dirent.h>
#include <termios.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include <sys/socket.h>
#include <linux/in.h>
#include <sys/syscall.h>

int test()
{
  ENSURE( CELL == sizeof(tcflag_t))
  ENSURE( 1 == sizeof(cc_t))
  return 1;
}

void define_consts()
{
  // readdir
  CONST( SIZEOF_INO_T, sizeof(ino_t))
  CONST( OFFSETOF_D_TYPE, offsetof(struct dirent,d_type))
  CONST( SIZEOF_DIRENT, sizeof(struct dirent))
  CONST( OFFSETOF_D_NAME, offsetof(struct dirent,d_name))
  DEFINE( DT_UNKNOWN)
  DEFINE( DT_REG)
  DEFINE( DT_DIR)
  DEFINE( DT_FIFO)
  DEFINE( DT_SOCK)
  DEFINE( DT_CHR)
  DEFINE( DT_BLK)

  // termios
  CONST( SIZEOF_TERMIOS, sizeof(struct termios))
  CONST( OFFSETOF_C_IFLAG, offsetof(struct termios, c_iflag))
  CONST( OFFSETOF_C_LFLAG, offsetof(struct termios, c_lflag))
  CONST( OFFSETOF_C_CC, offsetof(struct termios, c_cc))
  CONST( TE_ICANON, ICANON)
  CONST( TE_ECHO, ECHO)
  CONST( TE_IXON, IXON)
  CONST( TE_IXOFF, IXOFF)
  CONST( TE_IXANY, IXANY)
  CONST( TE_INLCR, INLCR)
  CONST( TE_ICRNL, ICRNL)
  CONST( TE_VTIME, VTIME)
  CONST( TE_VMIN, VMIN)

  // mmap
  DEFINE( PROT_READ)
  DEFINE( PROT_WRITE)
  DEFINE( MAP_SHARED)
  CONST( MAP_FAILED, (int)MAP_FAILED)

  // open
  DEFINE( O_CREAT)
  DEFINE( O_TRUNC)
  DEFINE( O_RDONLY)
  DEFINE( O_WRONLY)
  DEFINE( O_RDWR)
  DEFINE( O_SYNC)
  DEFINE( O_NONBLOCK)
  DEFINE( O_EXCL)

  // pthread_mutex_t
  CONST( SIZEOF_PTHREAD_MUTEX_T, sizeof(pthread_mutex_t))
  CONST( SIZEOF_PTHREAD_MUTEXATTR_T, sizeof(pthread_mutexattr_t))
  DEFINE( PTHREAD_MUTEX_TIMED_NP) // non-portable
  DEFINE( PTHREAD_MUTEX_RECURSIVE_NP) // non-portable
  DEFINE( PTHREAD_MUTEX_ERRORCHECK_NP) // non-portable

  // socket
  DEFINE( SOCK_STREAM)
  DEFINE( PF_INET)
  DEFINE( AF_INET)
  DEFINE( IPPROTO_TCP)

  CONST( SIZEOF_SOCKADDR_IN, sizeof(struct sockaddr_in))
  CONST( OFFSETOF_SIN_PORT, offsetof(struct sockaddr_in, sin_port))
  CONST( OFFSETOF_SIN_ADDR, offsetof(struct sockaddr_in, sin_addr))
  CONST( OFFSETOF_SIN_FAMILY, offsetof(struct sockaddr_in, sin_family))

  // lockf
  DEFINE( F_LOCK)
  DEFINE( F_TLOCK)
  DEFINE( F_TEST)
  DEFINE( F_ULOCK)

  // syscall numbers
  DEFINE( SYS_gettid) // linux-specific
}

int main()
{
  if (!test())
  {
    return 1;
  }

  print_header();

  define_consts();

  return 0;
}


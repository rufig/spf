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
  DEFINE( ICANON)
  DEFINE( ECHO)
  DEFINE( IXON)
  DEFINE( IXOFF)
  DEFINE( IXANY)
  DEFINE( INLCR)
  DEFINE( ICRNL)
  DEFINE( VTIME)
  DEFINE( VMIN)

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


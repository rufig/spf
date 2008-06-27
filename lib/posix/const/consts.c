/*
 * $Id$
 */

#define _BSD_SOURCE 

#include "../../../src/posix/config.h"

#include <sys/types.h>
#include <dirent.h>
#include <termios.h>

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


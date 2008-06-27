/*
 * $Id$
 */

#define _BSD_SOURCE 

#include "../../../src/posix/config.h"

#include <sys/types.h>
#include <dirent.h>

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
}

int main()
{
  print_header();

  define_consts();

  return 0;
}


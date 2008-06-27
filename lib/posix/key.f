\ $Id$
\  
\ http://www.opengroup.org/pubs/online/7908799/xbd/termios.html

REQUIRE ADD-CONST-VOC lib/ext/const.f
REQUIRE NSYM: lib/include/facil.f

S" lib/posix/const/linux.const" ADD-CONST-VOC

2 NSYM: tcgetattr
3 NSYM: tcsetattr

MODULE: termios

\ not thread-safe but who will call KEY from different threads?
CREATE tios SIZEOF_TERMIOS ALLOT
CREATE otios SIZEOF_TERMIOS ALLOT

: c_lflag OFFSETOF_C_LFLAG + ;
: c_iflag OFFSETOF_C_IFLAG + ;
: c_cc OFFSETOF_C_CC + ;

: prepare-terminal ( -- )
  H-STDIN tios tcgetattr 0 <> ABORT" tcgetattr failed"
  tios otios SIZEOF_TERMIOS MOVE \ save
  tios c_lflag @ 
    [ ICANON ECHO OR INVERT ] LITERAL AND 
  tios c_lflag !

  \ not sure why it is needed
  \ copied from gforth-0.6.2/engine/io.c
  tios c_iflag @
    [ IXON IXOFF OR IXANY OR ICRNL OR INLCR OR INVERT ] LITERAL AND
  tios c_iflag !
  tios c_cc VMIN + 1 SWAP B!
  tios c_cc VTIME + 0 SWAP B!

  H-STDIN 0 tios tcsetattr 0 <> ABORT" tcsetattr failed" ;

: restore-terminal ( -- )
  H-STDIN 0 otios tcsetattr 0 <> ABORT" restoring termios failed" ;

: KEY-TERMIOS ( -- c )
  prepare-terminal
  0 SP@ 1 H-STDIN READ-FILE DROP DROP
  restore-terminal ;

' KEY-TERMIOS TO KEY  

;MODULE

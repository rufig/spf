\ $Id$

REQUIRE NSYM: lib/include/facil.f

\ http://www.opengroup.org/pubs/online/7908799/xbd/termios.html

2 NSYM: tcgetattr
3 NSYM: tcsetattr

MODULE: termios

\ /usr/src/linux-headers-2.6.22-2/include/asm-i386/termbits.h
\ 
\ #define NCCS 19
\ struct termios {
\ 	tcflag_t c_iflag;		/* input mode flags */
\ 	tcflag_t c_oflag;		/* output mode flags */
\ 	tcflag_t c_cflag;		/* control mode flags */
\ 	tcflag_t c_lflag;		/* local mode flags */
\ 	cc_t c_line;			/* line discipline */
\ 	cc_t c_cc[NCCS];		/* control characters */
\ };

0
CELL -- c_iflag
CELL -- c_oflag
CELL -- c_cflag
CELL -- c_lflag
   1 -- c_line
  19 -- c_cc
CONSTANT /termios

CREATE tios /termios ALLOT 20 ALLOT \ termios can be larger on some systems...
CREATE otios /termios ALLOT 20 ALLOT

2 CONSTANT ICANON
8 CONSTANT ECHO
1024 CONSTANT IXON
2048 CONSTANT IXANY
4096 CONSTANT IXOFF
64 CONSTANT INLCR
256 CONSTANT ICRNL
5 CONSTANT VTIME
6 CONSTANT VMIN

: prepare-terminal ( -- )
  H-STDIN tios tcgetattr 0 <> ABORT" tcgetattr failed"
  tios otios /termios MOVE \ save
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

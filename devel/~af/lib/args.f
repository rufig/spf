\ $Id$
\ Приведение строки аргументов к C-виду - число аргументов + массив аргументов

: NextArg ( -- c-addr u )
  SkipDelimiters
  GetChar DROP
  [CHAR] " = IF >IN 1+! [CHAR] " PARSE  ELSE  NextWord  THEN
;
: ArgC ( -- n )
  >IN @ >R  0 >IN !
  0 BEGIN NextArg NIP WHILE 1+ REPEAT
  R> >IN !
;
: ArgV ( n -- addr )
  HERE DUP ROT
  DUP 1+ CELLS ALLOT
  0 DO
    HERE OVER ! CELL+
    NextArg HERE SWAP DUP ALLOT MOVE 0 C,
  LOOP
  0!
;
: ParseArgs ( -- argc argv )  ArgC DUP  ArgV ;
: args ( addr u -- argc argv )  ['] ParseArgs EVALUATE-WITH ;

\ GetCommandLineA ASCIIZ> args

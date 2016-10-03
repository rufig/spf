\ $Id$
\ 
\ Ansifying SPF file i/o
\ 
\ By default spf kernel FILE words expect file names 
\ to end with zero byte and ignore the length param.
\ This extension redefines those words to get rid of that 
\ limitation
\ (If the file name is zero-ended it is used "as is", else
\ it is copied to additional buffer PFILENAME and zero byte 
\ is appended)
\
\ Just include this lib

MODULE: ANSI-FILE

USER-VALUE PFILENAME
USER-VALUE #FILENAME

\ : INIT \ не надо, т.к. USER переменные всегда ноль при стартапе
\   0 TO PFILENAME
\   0 TO #FILENAME ;

: ALLOCFILENAME ( n -- )
   DUP #FILENAME < IF DROP EXIT THEN \ no need to realloc - enough memory
   PFILENAME ?DUP IF FREE THROW THEN
   DUP TO #FILENAME
   ALLOCATE THROW TO PFILENAME ;

: COPYFILENAME ( c-addr u -- )
   DUP 32 + ALLOCFILENAME \ allocate space for file-name (with extra space)
   PFILENAME SWAP CMOVE ;

: ?Z ( addr u -- ? ) + C@ 0= ;

: >ZFILENAME ( c-addr u -- zaddr u )
  2DUP ?Z IF EXIT THEN \ do nothing if it is an asciiz string already
  2DUP COPYFILENAME \ copy name to internal buffer
  NIP PFILENAME SWAP 2DUP + 0 SWAP C! ; \ append zero to the end

EXPORT

WARNING @
WARNING 0!

: CREATE-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
  >R >ZFILENAME R> CREATE-FILE ;

: CREATE-FILE-SHARED ( c-addr u fam -- fileid ior )
  >R >ZFILENAME R> CREATE-FILE-SHARED ;

: OPEN-FILE-SHARED ( c-addr u fam -- fileid ior )
  >R >ZFILENAME R> OPEN-FILE-SHARED ;

: DELETE-FILE ( c-addr u -- ior ) \ 94 FILE
  >ZFILENAME DELETE-FILE ;

: OPEN-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
  >R >ZFILENAME R> OPEN-FILE ;

: FILE-EXIST ( c-addr u -- ? ) >ZFILENAME FILE-EXIST ;
: FILE-EXISTS ( c-addr u -- ? ) >ZFILENAME FILE-EXISTS ;

: INCLUDED ( i*x c-addr u -- j*x ) >ZFILENAME INCLUDED ;

WARNING !

;MODULE

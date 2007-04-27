\ fileio.fo           Words to help with ASCII File I/O 

\ This is an ANS Forth program requiring:
\        1. The FLOAT wordset
\        2. The FLOATING EXT word F**
\        3. The STRING word CMOVE
\        4. the conditional compilation words in the
\             PROGRAMMING-TOOLS word set

\ Note: the FLOATING point words are conditionally compiled in
\ so that they can easily be turned off if they are not needed

\ Words to convert counted strings to numbers
\ atol ( addr count -- d )                ASCII to long
\ atoi ( addr count -- n )                ASCII to int
\ atof ( addr count -- ) ( F: -- x )      ASCII to float

\ Word to read a whitespace delimited token from a file
\ get-token ( addr fileid -- addr count )

\ Words to read whitespace delimited numbers from a file
\ get-int   ( fileid -- n )                read single int
\ get-long  ( fileid -- d )                read double int
\ get-float ( fileid -- ) ( F: -- x )      read a float

\ Words to convert numbers to counted strings
\ These require the address of a conversion buffer to be given,
\ all but ftoa can convert into PAD if desired.
\ utoa  ( addr u -- addr count )              unsigned int to ASCII
\ itoa  ( addr n -- addr count )              int to ASCII
\ ltoa  ( addr d -- addr count )              long to ASCII
\ ultoa ( addr ud -- addr count )             unsigned long to ASCII
\ ftoa  ( addr  -- addr count ) ( F: x -- )   float to ASCII


\ Words to write tokens and numbers to a file (no padding)
\ write-float requires the address of a conversion buffer,
\ it must not be PAD.
\ write-token ( addr count fileid -- )
\ write-int   ( n fileid -- )
\ write-uint  ( u fileid -- )
\ write-long  ( d fileid -- )
\ write-ulong ( ud fileid -- )
\ write-float ( bufr fileid -- ) ( F: x -- )

\  (c) Copyright 1995 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.

\ $Author$
\ $Workfile:   fileio.fth  $
\ $Revision$
\ $Date$

 
\ CR .( FILEIO $Revision$ $Date$   EFC )

\ ===================================================================

\ set this to FALSE if no FLOAT words
TRUE CONSTANT HAS_FLOATS?

\ ===================================================================

0 VALUE eol-handler            \ possible user callback
                               \ invoked when and EOL is encountered

: iswhite?  ( c -- t/f )       \ return a true for whitespace chars
        DUP

        \ call eol-handler callback if LF and handler is set
	DUP 10 = eol-handler AND IF eol-handler EXECUTE THEN
    
        14 < OVER 8 > AND
        SWAP 32 = OR

;


\ skip to first non-whitespace, stores it at addr
\                               n = -1 if file read error or EOF
\                               n = count of whitespace skipped (0 if none)
: skipwhite ( addr fileid -- addr fileid n )

        OVER
        0
        BEGIN
          OVER 
          1 4 PICK READ-FILE
          \ check for file read error
          IF 2DROP DROP -1 EXIT THEN

          \ check to see if there were no more chars
          0= IF 2DROP -1 EXIT THEN

          \ DROP
          OVER
          C@ iswhite?
        WHILE
          1+
        REPEAT

        SWAP DROP
	
	
;

\ get whitespace delimited token, stores it at addr
\                               n = -1 if file read error
\                               n = count of token chars if OK
: get-token ( addr fileid -- addr count )

         skipwhite

         0 < IF
                DROP 0
         ELSE
          OVER 1 BEGIN
                   2DUP + 1 4 PICK READ-FILE

                   \ check for file read error
                   IF 2DROP 2DROP -1 EXIT THEN

                   DROP
                   2DUP + C@ iswhite? 0=
           WHILE
             1+
           REPEAT

           SWAP OVER + BL SWAP C!       \ pad with a space at the end

           SWAP DROP
        THEN
;


: write-token ( addr u fileid -- )
	WRITE-FILE
        ABORT" File write error "
;

\ counted string to double int
: atol ( addr count -- d )
     >R
     0. ROT
     R>
     
     >NUMBER
     2DROP
;

\ counted string to single int
: atoi ( addr count -- n )

    atol DROP
;



: move-chars ( dest src count -- dest count )
    >R OVER R@ CMOVE R>
;

: ultoa ( addr ud -- addr count )    \ unsigned long to counted string
    <#  #S #>
    move-chars
;

: utoa ( addr u -- addr count )      \ unsigned int to counted string
    S>D ultoa
;

: ltoa ( addr d -- addr count )      \ (signed) long to counted string
    DUP >R DABS
    <# #S R> SIGN #>
    move-chars
;

: itoa ( addr n -- addr count )       \ (signed) int to counted string
   DUP >R ABS S>D
   <# #S R> SIGN #>
   move-chars
;

HAS_FLOATS? [IF]

\ counted string to float
: atof ( addr count -- ) ( F: -- x )

          >FLOAT 0= ABORT" NAN "
;


: FUNDER  FSWAP FOVER ;                             ( F: x y -- y x y)

: F**2    FDUP F* ;

: F**N   1.0E0   FSWAP       ( n -- ) ( F: x -- x**n )
         BEGIN   DUP  0>  WHILE
                 DUP  1 AND   IF FUNDER  F*  FSWAP THEN F**2
                 2/
         REPEAT  FDROP  DROP   ;

: FSPLIT   ( f - [f] f-[f] )  FDUP FLOOR FDUP FROT FROT F- ;


\ WARNING!! Do NOT use PAD as the conversion buffer address!

: ftoa ( addr -- addr u ) ( F: x -- )

      FDUP F0= IF FDROP S" 0.0" SWAP 2 PICK 2 PICK CMOVE EXIT THEN

      \ if negative, put '-' in buffer and bump pointer
      FDUP F0< IF TRUE SWAP [CHAR] - OVER C! 1+ ELSE FALSE SWAP THEN
      FABS

      FSPLIT FSWAP   FLOOR F>D LTOA

      OVER OVER + [CHAR] . SWAP C! 1+

      \ put zero characters in the buffer, for leading zero fills
      OVER OVER + PRECISION [CHAR] 0 FILL

      \ set count to include fractional part
      PRECISION +
      OVER OVER +
      
      FABS PRECISION 10.0E0 F**N F* PAD F>D ULTOA

      \ now move the faction into the character buffer
      ROT OVER - SWAP CMOVE

      \ if it was negative the pointer needs to back up one
      ROT IF
            SWAP 1-         \ back up pointer
	    SWAP 1+         \ increase char count
	  THEN

;

: get-float ( fileid -- ) ( F: -- x )
	PAD SWAP get-token
        DUP 0< ABORT" File read error "
        atof
;


: write-float ( bufr fileid -- ) ( F: x -- )
       >R
       ftoa
       R>
       write-token
;

[THEN]

: get-int ( fileid -- n )
	PAD SWAP get-token
        DUP 0< ABORT" File read error "
        atoi
;

: get-long ( fileid -- d )
	PAD SWAP get-token
        DUP 0< ABORT" File read error "
        atol
;



: write-int  ( n fileid -- )
        >R PAD SWAP
        itoa R>
        write-token
;

: write-uint  ( u fileid -- )
        >R PAD SWAP
        utoa R>
        write-token
;

: write-long  ( d fileid -- )
        >R PAD ROT ROT
        ltoa R>
        write-token
;

: write-ulong  ( ud fileid -- )
        >R PAD ROT ROT
        ultoa R>
        write-token
;

REQUIRE /STRING lib/include/string.f 
REQUIRE { ~ac/lib/locals.f
REQUIRE PLACE ~nn/lib/string.f
REQUIRE <TIB  ~nn/lib/tib.f
REQUIRE ZPLACE ~nn/lib/az.f
REQUIRE DEBUG? ~nn/lib/qdebug.f
REQUIRE GETENV ~nn/lib/env.f

: PAD1 PAD 257 + ;
: PAD2 PAD 514 + ;


16  CONSTANT SUBST-NUM-BUFS
256 CONSTANT INIT-SUBST-LEN


USER-CREATE SUBST-BUFS  SUBST-NUM-BUFS CELLS USER-ALLOT

USER SUBST-LEN
USER SUBST-BUF-LEN

USER-VALUE #SUBST
USER-VALUE SUBST-BUF
USER-CREATE SUBST-SRC 2 CELLS USER-ALLOT


: <SUBST ( a u -- )
    R>
    SUBST-SRC 2@ 2>R    SUBST-BUF >R 
    SUBST-BUF-LEN @ >R  SUBST-LEN @ >R
    >R
    SUBST-SRC 2!
    #SUBST ABS SUBST-NUM-BUFS MOD TO #SUBST
    #SUBST CELLS SUBST-BUFS + TO SUBST-BUF
    SUBST-BUF @ ?DUP IF FREE DROP THEN
    INIT-SUBST-LEN SUBST-BUF-LEN !
    INIT-SUBST-LEN ALLOCATE THROW SUBST-BUF !
    SUBST-BUF @ 0!
    SUBST-LEN 0!
    STATE 0!
    #SUBST 1+ TO #SUBST
;
: SUBST> ( -- a u)
    SUBST-BUF @ ( ASCIIZ>) SUBST-LEN @
    R>
    R> SUBST-LEN !   R>  SUBST-BUF-LEN !
    R> TO SUBST-BUF  2R> SUBST-SRC 2! 
    >R
;

: ZMOVE ( a u a1 -- )  2DUP 2>R SWAP MOVE 2R> + 0 SWAP C! ;
: SUBST+  { a u \ newbuf -- }
\    [ DEBUG? ] [IF] ." SUBST+: " a u TYPE CR [THEN]    
    u SUBST-BUF-LEN @ SUBST-LEN @ - 1+ >
    IF  SUBST-BUF-LEN @ u + 256 + DUP SUBST-BUF-LEN !
        ALLOCATE THROW TO newbuf
        SUBST-BUF @ SUBST-LEN @ newbuf ZMOVE
        SUBST-BUF @ FREE THROW
        newbuf SUBST-BUF !
    THEN
    a u SUBST-BUF @ SUBST-LEN @ + ZMOVE
    u SUBST-LEN +!
;

: SUBST-ERROR ." Error macro variable substitution:" CR ;

0 [IF]
: ENV1 { a u \ az buf -- a1 u1 }
\    DEBUG?  IF ." ENV1: " a . u . a u TYPE CR THEN
    a u S>ZALLOC TO az
    255 ALLOCATE THROW TO buf
    255 buf az GetEnvironmentVariableA ?DUP 0= 
    IF buf FREE THROW az FREE THROW
        S" " EXIT THEN
    DUP 255 > 
    IF buf FREE THROW 
       DUP ALLOCATE THROW TO buf 
       buf az GetEnvironmentVariableA
    THEN
    az FREE THROW
    buf SWAP
;
[THEN]

: EVAL-SUBST ( a u -- a1 u1)
\  2DUP
  DUP >R S>ZALLOC DUP R> 
\  DEBUG?  IF ." DEPTH=" DEPTH . ." Subst inp: " 2DUP ." <" TYPE ." >" CR THEN
  <SUBST
  SUBST-SRC 2@ <TIB 
  BEGIN
                        \  ." 1:" TIB >IN @ + #TIB @ >IN @ - TYPE CR
      [CHAR] % PARSE    \  ." 2:" 2DUP TYPE CR
      SUBST+
      [CHAR] % PARSE DUP \  ." 3:" .S CR
  WHILE
     >IN @ >R SP@ >R
\        ." <" 2DUP TYPE ." >" CR
     2DUP ['] EVALUATE CATCH   \   ." 4:" .S CR
     IF 
        \ ERROR
        2DROP RDROP R> 
        TIB> SUBST-SRC 2@ <TIB >IN !
        2DUP GETENV THROW ?DUP 
        IF 2DUP SUBST+ DROP FREE THROW
        ELSE DROP 
          SUBST-ERROR 2DUP TYPE CR
        THEN
     ELSE
         SP@ R@ ( sp) SWAP - DUP 2 CELLS =
         IF \ вставляем строку
            DROP RDROP SUBST+
         ELSE
         1 CELLS =
         IF \ вставляем число
             RDROP DUP >R ABS S>D <# #S R> SIGN #>
             SUBST+
         ELSE \ ошибка либо больше либо меньше в стеке данных
             R> SP!
             SUBST-ERROR
             SUBST-SRC 2@ TYPE CR
         THEN THEN
         RDROP
     THEN
     2DROP
  REPEAT
  2DROP
  TIB>
  SUBST>
\  DEBUG? IF ." DEPTH=" DEPTH . ." Subst out: " 2DUP ." <" TYPE ." >" CR THEN

  ROT FREE DROP
\ ." --<" 2SWAP TYPE ." >--" CR 
;



0 [IF] -- Old version
: EVAL-SUBST ( a u -- a1 u1)
\    ORDER
  DEBUG?  IF ." Subst inp: " 2DUP TYPE CR THEN
  <SUBST
  SUBST-SRC 2@ <TIB 
  BEGIN
                        \  ." 1:" TIB >IN @ + #TIB @ >IN @ - TYPE CR
      [CHAR] % PARSE    \  ." 2:" 2DUP TYPE CR
      SUBST+
      [CHAR] % PARSE DUP \  ." 3:" .S CR
  WHILE
    2DUP ENV1 ?DUP
    IF 2DUP SUBST+ DROP FREE THROW 2DROP
    ELSE DROP
        >IN @ >R SP@ >R
\        ." <" 2DUP TYPE ." >" CR
        2DUP ['] EVALUATE CATCH   \   ." 4:" .S CR
        IF 2DROP RDROP R> 
           TIB> SUBST-SRC 2@ <TIB >IN !
           SUBST-ERROR 2DUP TYPE CR
        ELSE
            SP@ R@ ( sp) SWAP - DUP 2 CELLS =
            IF \ вставляем строку
               DROP RDROP SUBST+
            ELSE
            1 CELLS =
            IF \ вставляем число
                RDROP DUP >R ABS S>D <# #S R> SIGN #>
                SUBST+
            ELSE \ ошибка либо больше либо меньше в стеке данных
                R> SP!
                SUBST-ERROR
                SUBST-SRC 2@ TYPE CR
            THEN THEN
            RDROP
        THEN
        2DROP
     THEN
  REPEAT
  2DROP
  TIB>
  SUBST>

  DEBUG? IF ." Subst out: " 2DUP TYPE CR THEN
\  SUBST-BUF 100 DUMP CR
;
[THEN]


\ : STR@ ( a -- a1 u ) ASCIIZ> EVAL-SUBST ;
: S! ( a u a1 -- ) >R S>ZALLOC R> ! ;
: FILE ( addr u -- addr1 u1 )
  S>SZ OVER >R
  0 0 <SUBST
  R/O OPEN-FILE-SHARED IF DROP S" " EXIT THEN  >R
  R@ FILE-SIZE THROW D>S DUP ALLOCATE THROW  ( # a -- )
  DUP ROT R@ READ-FILE THROW
  2DUP SUBST+ DROP
  R> CLOSE-FILE THROW
  FREE THROW 
  SUBST>
  R> FREE THROW
;

: FILE: BL SKIP 1 PARSE ['] FILE CATCH IF 2DROP S" " THEN ;

CREATE <CRLFCRLF> 13 C, 10 C, 13 C, 10 C,
CREATE <CRLF> 13 C, 10 C,

: CRLF <CRLF> 2 ;
: 2CRLF <CRLFCRLF> 4 ;
: crlf CRLF ;

CREATE QUOT 1 C, CHAR " C, 0 C, 
: QUOTE QUOT COUNT ;
: PERCENT S" %" ;
\ Версия прохода по дереву каталогов
\ по следующему алгоритму (на выбор):
\ 1. В глубину
\  а) обработка каталогов по маске *.*
\  б) обработка файлов (начиная с самого глубокого) по заданной маске
\ 2. В ширину
\  а) обработка файлов по заданной маске
\  б) обработка каталогов по маске *.*

REQUIRE { lib/ext/locals.f
REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE FIND-FIRST-FILE ~nn/lib/find.f
REQUIRE FT>DATE ~nn/lib/time.f
\ REQUIRE AddNode ~nn/lib/list.f
\ REQUIRE ALLOCATE9x ~nn/lib/alloc95.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE WC-COMPARE ~nn/lib/wcmatch.f
REQUIRE FILENAME-FRACT ~nn/lib/file/fract.f
REQUIRE [NONAME ~nn/lib/noname.f


USER-VALUE FF-BUF
USER       FF-RECURSIVE?
USER       FF-TODEPTH?
USER       FF-FILESONLY?
USER       FF-EXIT?
USER       FF-CUT?
USER       FF-SKIPERRORS?
USER       FF-ERROR-XT

: FF-EXIT FF-EXIT? ON RDROP ;
: FF-CUT FF-CUT? ON RDROP ;

0
1 CELLS  -- ffBaseLen
1 CELLS  -- ffCurLen
1 CELLS  -- ffFlags
1 CELLS  -- ffXT
1 CELLS  -- ffXT-ERR
1 CELLS  -- ffLevel
1 CELLS  -- ffLastErr
MAX_PATH -- ffMask
MAX_PATH -- ffPath
CONSTANT /FF-BUF

1 CONSTANT FF-RECURSIVE
2 CONSTANT FF-TODEPTH
4 CONSTANT FF-FILESONLY
8 CONSTANT FF-SKIPERRORS

: *.* S" *.*" ;

: ffFitMask?  ( a u -- ?)
    FF-BUF ffMask ASCIIZ> 2DUP *.* COMPARE 0= IF 2DROP S" *" THEN
\    2DUP TYPE SPACE 2OVER TYPE
    WC-COMPARE \ SPACE DUP . CR
;

: FF? FF-BUF ffFlags @ AND 0<> ;

: FF-SET { mask val -- }
    FF-BUF ffFlags @
    val
    IF mask OR
    ELSE mask -1 XOR AND THEN
    FF-BUF ffFlags !
;

: FOUND-FILENAME FF-BUF ffPath FF-BUF ffCurLen @ + 1+ ASCIIZ> ;
: FOUND-FULLPATH  ( -- a u )  FF-BUF ffPath ASCIIZ> ;
: FOUND-RELPATH ( -- a u )   FF-BUF ffPath FF-BUF ffBaseLen @ + 1+ ASCIIZ> ;
: FOUND-SIZE ( -- d) FF-SIZE ;
: FOUND-LEVEL FF-BUF ffLevel @ ;

: CREATION-DATE ( -- u) FF-CREATION-TIME FT>DATE ;
: ACCESS-DATE FF-ACCESS-TIME FT>DATE ;
: WRITE-DATE FF-WRITE-TIME FT>DATE ;

0 [IF]
: FF-FRACT { a u \ asep -- }
    a u + u IF 1- THEN
    BEGIN  DUP a <> OVER C@ IS-/OR\? 0= AND  WHILE 1- REPEAT
    TO asep
    asep a =
    IF S" "  a u
    ELSE
        a asep a - u OVER - 1- asep 1+ SWAP
    THEN
\    2DUP TYPE CR
    FF-BUF ffMask ZPLACE
\    2DUP TYPE CR
    ?DUP 0= IF DROP S" ." THEN

    DUP FF-BUF ffBaseLen !
    DUP FF-BUF ffCurLen !

    FF-BUF ffPath ZPLACE
;
[THEN]

: FF-FRACT ( a u -- )
    FILENAME-FRACT
    FF-BUF ffMask ZPLACE
    DUP FF-BUF ffBaseLen !
    DUP FF-BUF ffCurLen !
    FF-BUF ffPath ZPLACE
;

: FF-ADD1 ( a u -- )
    FF-BUF ffPath FF-BUF ffCurLen @ +
    DUP S" \" ROT ZPLACE 1+ ZPLACE ;    \ "

: FF-ERR ( ior -- )
     DUP FF-BUF ffLastErr !
\    FF-SKIPERRORS FF?
\    IF
        FF-BUF ffXT-ERR @ ?DUP
        IF EXECUTE ELSE THROW THEN
\    ELSE THROW THEN
;

: ?FIND-NEXT-FILE  ( -- a t= | -- f)
    ['] FIND-NEXT-FILE CATCH ?DUP
    IF FF-ERR FALSE THEN
;
: ?FIND-FIRST-FILE ( a -- a1 t= | -- f)
    ['] FIND-FIRST-FILE CATCH ?DUP
    IF FF-ERR DROP FALSE THEN
;

: FF-BEG ( a u -- ? )
    FF-ADD1 FF-BUF ffPath ?FIND-FIRST-FILE
    BEGIN  WHILE
        ASCIIZ> ( 2DUP TYPE CR) FF-ADD1
        FOUND-FILENAME S" ." COMPARE 0=
        FOUND-FILENAME S" .." COMPARE 0= OR 0=
\        IS-DIR? 0= IF FOUND-FILENAME FF-BUF ffMask ASCIIZ> WC-COMPARE AND THEN
        IF TRUE EXIT THEN
        ?FIND-NEXT-FILE
    REPEAT
    FALSE
;

: FF-NEXT ( -- ?)
    ?FIND-NEXT-FILE
    IF
        ASCIIZ> ( 2DUP TYPE CR) FF-ADD1
        TRUE
    ELSE FALSE THEN
;

: FF-END   FIND-CLOSE ;

VECT FF-PASS

: FF-PASS-DIRs
    FF-EXIT? @ IF EXIT THEN
    *.* FF-BEG
    BEGIN WHILE
        IS-DIR?
        IF
            FF-FILESONLY FF? 0=
            IF
                FOUND-FILENAME ffFitMask?
                IF FF-BUF ffXT @ EXECUTE THEN
            THEN
            FF-RECURSIVE FF? FF-EXIT? @ 0= AND FF-CUT? @ 0= AND
            IF
                FF-BUF ffCurLen @ >R
                FF-BUF ffLevel 1+!
                FOUND-FULLPATH FF-BUF ffCurLen ! DROP
                FF-PASS
                -1 FF-BUF ffLevel +!
                R> FF-BUF ffCurLen !
            THEN
            FF-CUT? OFF
        THEN
        FF-EXIT? @ IF FALSE ELSE FF-NEXT THEN
    REPEAT
    FF-END
;

: FF-PASS-FILEs
    FF-EXIT? @ IF EXIT THEN
    FF-BUF ffMask ASCIIZ> FF-BEG
    BEGIN WHILE
        IS-DIR? 0=
        IF FOUND-FILENAME ffFitMask? IF FF-BUF ffXT @ EXECUTE THEN THEN
        FF-EXIT? @ IF FALSE ELSE FF-NEXT THEN
    REPEAT
    FF-END
;


:NONAME
    __FFB >R  __FFH >R
    FF-TODEPTH FF?
    IF
        FF-PASS-DIRs   FF-PASS-FILEs
    ELSE
        FF-PASS-FILEs FF-BUF ffLastErr @ 0= IF FF-PASS-DIRs THEN
        FF-BUF ffLastErr 0!
    THEN
    R> TO __FFH  R> TO __FFB
; TO FF-PASS

: RECURSIVE  FF-RECURSIVE? ON ;
: ~RECURSIVE FF-RECURSIVE? OFF ;
: TODEPTH    FF-TODEPTH? ON ;
: SKIPERRORS  FF-SKIPERRORS? ON ;
: ~SKIPERRORS  FF-SKIPERRORS? OFF ;
: FILESONLY  FF-FILESONLY? ON ;

: (FOR-FILES) ( a u xt -- )
    FF-BUF >R
    /FF-BUF ALLOCATE THROW TO FF-BUF
    FF-BUF ffXT !
    FF-RECURSIVE FF-RECURSIVE? @ FF-SET      ~RECURSIVE
    FF-TODEPTH   FF-TODEPTH?   @ FF-SET      FF-TODEPTH? OFF
    FF-FILESONLY  FF-FILESONLY? @ FF-SET     FF-FILESONLY? OFF
    FF-SKIPERRORS FF-SKIPERRORS? @ FF-SET    FF-SKIPERRORS? OFF
    FF-ERROR-XT @ FF-BUF ffXT-ERR ! FF-ERROR-XT OFF
    FF-EXIT? OFF
    FF-CUT? OFF


\    FF-BUF ffFlags @ HEX . CR DECIMAL

    FF-FRACT

    0 FF-BUF ffLevel !

    FF-PASS

    FF-EXIT? OFF

    FF-BUF FREE THROW
    R> TO FF-BUF
;

: FOR-FILES \ compile: ( -- )
            \ execute: ( a u --)
    POSTPONE [NONAME
; IMMEDIATE

: ;FOR-FILES
    POSTPONE NONAME]
    POSTPONE (FOR-FILES)
; IMMEDIATE

REQUIRE <EOF> ~nn/lib/eof.f
REQUIRE [NONAME ~nn/lib/noname.f
REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE DEBUG? ~nn/lib/qdebug.f

REQUIRE EVAL-SUBST ~nn/lib/subst1.f

REQUIRE TEMP-MEMORY ~nn/lib/memory/tempalloc.f

\ REQUIRE GLOBAL ~nn/lib/globalloc.f

\ WINAPI: re_start regexp.dll
\ WINAPI: re_next regexp.dll
\ WINAPI: re_stop regexp.dll

WINAPI: SetLastError KERNEL32.DLL
WINAPI: GetModuleHandleA KERNEL32.DLL
WINAPI: FreeLibrary KERNEL32.DLL

\ : THROW1 ( ... # -- )  OVER IF ." ERROR THROW # " . CR ELSE DROP THEN THROW ;
: re_dll S" regexp.dll" DROP ;
: re_hdll re_dll GetModuleHandleA ;
: re_load re_hdll 0= IF re_dll LoadLibraryA ERR THROW THEN ;
: re_free ( re_dll GetModuleHandleA ?DUP IF FreeLibrary DROP THEN) ;
: re_api \ a u -- ?
    DROP re_dll GetModuleHandleA ?DUP
    IF GetProcAddress ?DUP
        IF API-CALL ELSE GetLastError THROW THEN
    ELSE GetLastError THROW THEN  ;

: re_start S" re_start" re_api ;
: re_stop  S" re_stop"  re_api ;
: re_next  S" re_next"  re_api ;

USER RE-H
USER RE-XT
: RE RE-H @ ;

0
1  CELLS -- re_re
16 CELLS -- re_s
16 CELLS -- re_e
1  CELLS -- re_cnt
1  CELLS -- re_last_res
1  CELLS -- re_text
1  CELLS -- re_pat
1  CELLS -- re_last_beg
CONSTANT /RE

: RE-RES? ( ? -- ? ) DUP IF DROP RE re_e @ RE re_s @ - 0<> THEN ;

: RE-START ( text u1 re u2 -- ?)
    RE
    IF
        RE re_pat @ FREE DROP
        RE re_text @ FREE DROP
        RE /RE ERASE
    ELSE
        /RE ALLOCATE THROW RE-H !
    THEN
    S>ZALLOC RE re_pat !
    S>ZALLOC RE re_text !
    re_load
    RE re_start ( RE-RES?) ;

: RE-NEXT ( -- ?) RE re_next RE-RES? ;
: RE-STOP ( -- ?)
     RE DUP IF re_stop THEN
\    DUP >R re_stop
\    R@ re_pat @ FREE THROW
\    R@ re_text @ FREE THROW
\    R> FREE THROW
\    re_free
;

: $RE ( # -- a u )
\    ." $RE: " DUP . RE re_cnt @ . RE re_last_res @ .
    DUP RE re_cnt @ <
    OVER CELLS RE re_s + @  ( DUP .) 0< 0= AND
    IF
        CELLS >R
        RE re_s R@ + @
        RE re_text @ OVER + RE re_last_beg @ +
        RE re_e R> + @ ( DUP .) ROT - ( DUP .)
    ELSE DROP S" " THEN
\    CR
;

: $RE: CREATE C, DOES> C@ $RE ;

0 $RE: $0          1 $RE: $1            2 $RE: $2          3 $RE: $3
4 $RE: $4          5 $RE: $5            6 $RE: $6          7 $RE: $7
8 $RE: $8          9 $RE: $9            10 $RE: $10        11 $RE: $11
12 $RE: $12        13 $RE: $13          14 $RE: $14        15 $RE: $15

: RE-SAVE R> RE-H @ >R RE-XT @ >R >R RE-H 0! ;
: RE-REST R> R> RE-XT ! R> RE-H ! >R ;

: RE-MATCH ( a-text u-text a-re u-re -- ?)
\    [ DEBUG? ] [IF] ." RE: '" 2OVER TYPE ." '~'" 2DUP TYPE ." '=" [THEN]
    RE-START RE-STOP DROP
\    [ DEBUG? ] [IF] DUP . CR [THEN]
;

: RE-MATCH$ ( # a-text u-text a-re u-re -- a u ?)
   RE-START IF $RE EVAL-SUBST TRUE ELSE S" " FALSE THEN
   RE-STOP DROP
;

: (RE-ALL) ( a-text u-text a-re u-re xt -- )
    RE >R RE-XT @ >R
    RE-XT !
    RE-H 0! RE-START
    IF
        BEGIN
            RE-XT @ CATCH
            IF
                TRUE
            ELSE
                RE-NEXT 0=
            THEN
        UNTIL
    THEN
    RE-STOP DROP
    R> RE-XT ! R> RE-H !
;

: RE-ALL POSTPONE [NONAME ; IMMEDIATE
: ;RE-ALL POSTPONE NONAME] POSTPONE (RE-ALL) ; IMMEDIATE

CREATE <RE-CHARS> C" /\^${}()[].|+*?" ",
: QUOTE-RE { a u \ buf len -- a1 u1 }
    u 2* CELL+ TEMP-ALLOC TO buf
    0 TO len
    a u OVER + SWAP
    ?DO I C@ SP@ 1 <RE-CHARS> COUNT 2SWAP SEARCH NIP NIP
        IF [CHAR] \ buf len + C! AT len 1+! THEN
        buf len + C! AT len 1+!
    LOOP
    buf len 2DUP + 0 SWAP C!
;
\EOF

: TEST1
    S" xxxxhttp://xx.yy.com/zz/yy/aa.zipcbcbcbcftp://xx.yy.com/zz/yy/aa.rareieruiywuywi"
    S" /(http)|(ftp):\/\/[^ ]+?\.(zip)|(rar)|(gz)|(bz2)|(tar)/"
    RE-ALL
        $0 TYPE
        ."       press any key ..." KEY DROP CR
    ;RE-ALL
;

\ TEST1

: TEST2
    S" xxxxhttp://xx.yy.com/zz/yy/aa.zipcbcbcbcftp://xx.yy.com/zz/yy/aa.rareieruiywuywi"
    S" /(http)|(ftp):\/\/[^ ]+?\.(zip)|(rar)|(gz)|(bz2)|(tar)/"
    RE-MATCH
    IF $0 TYPE CR $1 TYPE CR $3 TYPE CR THEN
;

TEST2

\EOF
: TEST2 ( text u re u -- )
    RE-ALL
       $0 TYPE CR .S
    ;RE-ALL
;

: T1
    S" xxxxhttp://xx.yy.com/zz/yy/aa.zipcbcbcbcftp://xx.yy.com/zz/yy/aa.rareieruiywuywi"
    S" /(http)|(ftp):\/\/.+?\.(zip)|(rar)|(gz)|(bz2)|(tar)/"
    TEST2
;
T1
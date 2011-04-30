\ Часто требующиеся определения, asciiz-строки
\ Версия 1.10
\ Ю. Жиловец, http://www.forth.org.ru/~yz

REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE =OF ~yz/lib/mycase.f

CREATE "" 0 ,
: ==  CONSTANT ;
: VAR ( -- ) 0 VALUE ;
: UVAR ( -- ) USER-VALUE ;
: PRESS  NIP ;
: NOT  INVERT ;
: -! ( n a --) SWAP NEGATE SWAP +! ;
: CELL+!  CELL SWAP +! ;
: CELL-!  CELL SWAP -! ;
: CELLS+  CELLS + ;
: CELLS@  CELLS+ @ ;
: CELLS!  CELLS+ ! ;
: CELL" ( ->") [CHAR] " PARSE DROP @ STATE @ IF [COMPILE] LITERAL THEN ; IMMEDIATE
: LOWORD  [ 0x0F C, 0xBF C, 0xC0 C, ] ; \ movsx eax,ax
: HIWORD ( n--n)  16 RSHIFT LOWORD ;

\ : ON  ( a--) TRUE SWAP ! ;
\ : OFF ( a--) 0! ;
REQUIRE OFF lib/ext/onoff.f

[UNDEFINED] ? [IF]
: ?  @ . ;
[THEN]

: 1-!  -1 SWAP +! ;
: c: POSTPONE [CHAR] ; IMMEDIATE

: ZLEN ( z -- #) DUP
  BEGIN DUP C@ WHILE 1+ REPEAT 
  SWAP - ;

[UNDEFINED] CZMOVE [IF]
: CZMOVE ( a # z --) 2DUP + >R SWAP CMOVE R> 0 SWAP C! ;
[THEN]
: ZMOVE ( z a --) OVER ZLEN 1+ CMOVE ;

: s.  SP@ S0 @ CELL - 2DUP - 
  DUP 4 = IF DROP 2DROP ." Stack is empty" CR EXIT THEN 
  4 > IF 2DROP ." Stack is underflowed" CR EXIT THEN
  DO I @ . CELL NEGATE +LOOP CR ;

: .ASCIIZ ( z--) ASCIIZ> TYPE ;
: Z>NUMBER ( z--n true / false) 
  0 0 ROT ASCIIZ> >NUMBER PRESS IF 2DROP FALSE ELSE D>S TRUE THEN ;

VARIABLE toadr  VARIABLE fromadr VARIABLE counter

: common-char ( --c/-1) counter @ 1 <
  IF -1 ELSE counter 1-! fromadr @ C@ fromadr 1+! THEN ;
: unchar  counter 1+! fromadr 1-! ;
: c> ( c--) toadr @ C!  toadr 1+! ;

: escape ( c--c ) CASE 
  -1 OF 0 ENDOF
  c: n OF 10 ENDOF
  c: r OF 13 ENDOF
  c: t OF 9 ENDOF
  c: q OF c: " ENDOF
  c: ' OF c: " ENDOF
  DUP c: 0 c: 9 1+ WITHIN IF
    c: 0 -
    BEGIN ( n) common-char DUP c: 0 c: 9 1+ WITHIN WHILE
      ( n c) c: 0 - SWAP 10 * +
    REPEAT -1 <> IF unchar THEN
  THEN
  END-CASE ;

: ESC-CZMOVE ( a # to --)
  toadr ! counter ! fromadr !
  BEGIN 
    common-char CASE 
    -1 OF 0 ENDOF
    c: \ OF common-char escape ENDOF
    END-CASE
  DUP c> 0= UNTIL ;

: ALITERAL  R> DUP ASCIIZ> + 1+ >R ;

: " ( -->") c: " PARSE ( a #)
  STATE @ IF
   POSTPONE ALITERAL
       HERE DUP >R ESC-CZMOVE R> ZLEN 1+ ALLOT 
  ELSE
       PAD 512 + ESC-CZMOVE PAD 512 +
  THEN
; IMMEDIATE

: Z" [COMPILE] " ; IMMEDIATE

: ASCIIZ ( z -- ; ->bl) 
  CREATE HERE ( z here) OVER ZLEN 1+ DUP >R CMOVE R> ALLOT ;

: .H  BASE @ HEX SWAP ." 0x" U. BASE ! ;

\ углубляет стек на n значений. Требуется для процедур с параметрами, 
\ описываемыми через WNDPROC
: PARAMS ( n --) CELLS S0 +! ;

\ ------------------------------------

: GETMEM ( # -- a) ALLOCATE THROW ;
: FREEMEM ( a -- ) FREE THROW ;

WINAPI: FormatMessageA   KERNEL32.DLL

: dll-error ( -- n) GetLastError ;
: error-text ( err -- a)
  \ выделенный буфер подлежит освобождению
 >R 512 DUP GETMEM ( 512 a) DUP >R SWAP 0 SWAP R> 0 R> 0 0x1000 ( format_message_from_system)
 FormatMessageA DROP
;
: .ansiz ( z -- ) ASCIIZ> ANSI>OEM TYPE ;
: .err ( err# --) DUP .H 
  error-text DUP .ansiz FREEMEM ;
: .lerr dll-error .err ;

WINAPI: MultiByteToWideChar   KERNEL32.DLL
WINAPI: WideCharToMultiByte   KERNEL32.DLL

: >unicode ( z a -- )
  SWAP DUP >R ZLEN 1+ 2* SWAP -1 R> 0 0 MultiByteToWideChar DROP ; 
: >unicodebuf ( z -- a) \ записывает строку в выделенный буфер и возвращает
 \ его адрес. Буфер подлежит освобождению
  DUP >R ZLEN 1+ 2* DUP GETMEM ( # a) SWAP OVER  
  -1 R> 0 0 MultiByteToWideChar DROP ;

: unicode> ( a z --)
  SWAP >R >R 0 0 256 R> -1 R> 0 0 WideCharToMultiByte DROP ;

: unicode>buf ( a -- z) \ записывает строку в выделенный буфер и возвращает
 \ его адрес. Буфер подлежит освобождению
  >R 
  0 0 0 0 -1 R@ 0 0 WideCharToMultiByte ( получили длину строки)
  1+ DUP GETMEM ( # a) SWAP OVER 0 0 2SWAP 
  -1 R> 0 0 WideCharToMultiByte DROP ;

: .unicode ( a -- ) unicode>buf DUP .ansiz FREEMEM ;

: CZGETMEM ( a n -- a) DUP 1+ GETMEM DUP >R CZMOVE R> ;
: ZGETMEM ( z -- a) ASCIIZ> CZGETMEM ;

WINAPI: lstrcmp KERNEL32.DLL
WINAPI: lstrcat KERNEL32.DLL

: ZCOMPARE ( z1 z2 -- n) lstrcmp ;
: ZAPPEND ( z1 z2 -- ) SWAP lstrcat DROP ;
: 0APPEND ( z -- ) ASCIIZ> + 1+ 0 SWAP C! ;

: SAPPEND ( a1 n1 a2 n2 -- ) DUP >R 2OVER + SWAP CMOVE R> + ;

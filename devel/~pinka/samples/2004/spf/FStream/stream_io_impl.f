\ $Id$
\ Work in spf3, spf4
\ Потоковая версия файлового ввода-вывода.

( Файловый ввод-вывод.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

\ портабельный устройство-независимый уровень  (layer)
\ работы с потоками чтения (c) ~day 07.Feb.2001

\ Перенос в из spf4 7 билд в либу и добавление буферизации
\ на запись - май 2002 ~af

\ Подправил с целью увеличения прозрачности,
\ 20.Jan.2004 Tue 21:54   ~ruv
( Модуль переопределяет все необходимые слова работы с файлами.

  Ограничения:
    - программа не должна полагать, что fileid == WinKernel Handle
)

REQUIRE [UNDEFINED]    lib\include\tools.f
REQUIRE PAllocSupport  devel\~af\lib\pallocate.f

[UNDEFINED] FlushFileBuffers                        [IF]
WINAPI: FlushFileBuffers              KERNEL32.DLL  [THEN]


WARNING @ 

MODULE: FStreamSupport

0
CELL -- .shandle
CELL -- .srbuf
CELL -- .srbsize
CELL -- .srpos
CELL -- .sr#tib
CELL -- .sreadxt
CELL -- .swbuf
CELL -- .swbsize
CELL -- .swpos
CELL -- .swritext
CONSTANT /STREAM

512 VALUE STREAM-RBUF
512 VALUE STREAM-WBUF

ALSO PAllocSupport

: HANDLE>STREAM ( h -- s )
  /STREAM DUP ALLOCATE THROW DUP >R
  SWAP ERASE
  R@ .shandle !
  STREAM-RBUF DUP ALLOCATE THROW R@ .srbuf !
  R@ .srbsize !
  R>
;
: HANDLE>STREAM-WITH ( h xt -- s )
  SWAP HANDLE>STREAM
  SWAP OVER .sreadxt !
;
: STREAM>WSTREAM ( s -- )
  STREAM-WBUF 2DUP SWAP .swbsize !
  ALLOCATE THROW SWAP .swbuf !
;
: STREAM>WSTREAM-WITH ( s xt -- )
  OVER .swritext !
  STREAM>WSTREAM
;
: REFILL-STREAM ( s -- u ior )
\ Обновить буфер
  DUP >R
  DUP .srbuf @
  SWAP .srbsize @
  R@ .shandle @
  R@ .sreadxt @ EXECUTE OVER
  R@ .sr#tib !
  R> .srpos 0!
;
: STREAM-HANDLE ( s -- h )
  @
;
: CLEAR-RBUF ( s -- )
  DUP .sr#tib @ SWAP .srpos !
;
: FlushWBuffer ( s -- ior )
  DUP >R .swpos @ ?DUP IF
    R@ .swbuf @ SWAP R@ STREAM-HANDLE WRITE-FILE
    R> .swpos 0!
  ELSE
    RDROP 0
  THEN
;
: CLOSE-STREAM ( s -- ior )
  DUP .swritext @ IF
    DUP FlushWBuffer OVER .swbuf @ FREE THROW
  ELSE 0 THEN
  SWAP
  DUP .srbuf @ FREE THROW
  FREE THROW
;

: FILE>STREAM ( h -- s )  ['] READ-FILE  HANDLE>STREAM-WITH ;

: FILE>RWSTREAM ( h -- s )
  FILE>STREAM
  DUP ['] WRITE-FILE  STREAM>WSTREAM-WITH
;
PREVIOUS \ for PAllocSupport

EXPORT

FALSE WARNING !

: CLOSE-FILE ( s -- ior ) \ 94 FILE
  DUP STREAM-HANDLE
  SWAP CLOSE-STREAM ?DUP IF NIP
  ELSE
    CLOSE-FILE
  THEN
;
: CREATE-FILE ( c-addr u fam -- s ior ) \ 94 FILE
  CREATE-FILE
  DUP 0= IF SWAP FILE>STREAM SWAP THEN
;
: CREATE-FILE-SHARED ( c-addr u fam -- s ior )
  CREATE-FILE-SHARED
  DUP 0= IF SWAP FILE>STREAM SWAP THEN
;
: OPEN-FILE ( c-addr u fam -- s ior ) \ 94 FILE
  OPEN-FILE
  DUP 0= IF SWAP FILE>STREAM SWAP THEN
;
: OPEN-FILE-SHARED ( c-addr u fam -- s ior )
  OPEN-FILE-SHARED
  DUP 0= IF SWAP FILE>STREAM SWAP THEN
;
: FILE-POSITION ( s -- ud ior ) \ 94 FILE
  DUP .srpos @ S>D
  ROT STREAM-HANDLE
  FILE-POSITION
  >R D+ R>
;
: REPOSITION-FILE ( ud s -- ior ) \ 94 FILE
  DUP CLEAR-RBUF
  STREAM-HANDLE REPOSITION-FILE
;
: FILE-SIZE ( s -- ud ior ) \ 94 FILE
  STREAM-HANDLE FILE-SIZE
;
: RESIZE-FILE ( ud s -- ior ) \ 94 FILE
  STREAM-HANDLE RESIZE-FILE
;

DEFINITIONS

USER-VALUE _s
USER-VALUE _buf
USER-VALUE _pos
USER-VALUE _#tib

EXPORT

: READ-FILE ( c-addr u1 s -- u2 ior ) \ 94 FILE
  DUP >R
  .sr#tib @ DUP TO _#tib
  R@ .srpos @ DUP TO _pos
  =
  IF \ буфер пуст
    R@ REFILL-STREAM ?DUP IF >R NIP NIP R> RDROP EXIT THEN
    0 TO _pos
    DUP TO _#tib
    0= IF 2DROP RDROP 0 0 EXIT THEN
  THEN
  \ копируем все что есть в буфере
  2DUP SWAP R@ .srbuf @ _pos + SWAP ROT _#tib _pos - MIN DUP >R MOVE
  DUP R@ > \ запросили больше?
  IF
    R@ - SWAP R@ + SWAP \ учли уже записаное
    CELL RP+@ ( s) DUP .shandle @ SWAP .sreadxt @ EXECUTE
    SWAP R> + SWAP _#tib R> .srpos !
  ELSE
    2DROP 2R> SWAP OVER SWAP .srpos +! 0
  THEN 
;
: READ-LINE ( c-addr u1 s -- u2 flag ior ) \ 94 FILE
   TO _s 2>R
   _s .srbuf @ TO _buf
   _s .sr#tib @ DUP TO _#tib
   _s .srpos @ DUP TO _pos 
   =
   IF \ буфер кончился
     _s REFILL-STREAM ?DUP IF 0 SWAP RDROP RDROP EXIT THEN
      \ прочитали 0
     0 TO _pos
     DUP TO _#tib
     0= IF 0. 0 RDROP RDROP EXIT THEN
   THEN
   _buf _pos + DUP
   _#tib _pos -
   LT 1+ 1 SEARCH
   IF
     DROP OVER - R> MIN >R
     2R@ MOVE
     \ на случай если запрашивали символов меньше чем длина строки
     R@ _buf _pos + R@ + C@ 10 = IF 1+ THEN _s .srpos +!
     2R> SWAP OVER + 1- C@ 13 = IF 1- THEN -1 0
   ELSE \ нет LF
     \ копируем все что нужно
     2DROP R@ SWAP CELL RP+@ ( addr) _#tib _pos - R@ MIN DUP >R MOVE
     _#tib _pos - 1+ <  ( _#tib _pos - u > )
     IF \ если можно - больше чем нужно, либо в самый раз
        R> DUP _s .srpos +!
        RDROP RDROP -1 0 EXIT
     THEN
     _#tib _s .srpos !
     R@ 8 RP+@ ( addr) OVER +
     CELL RP+@ ( u) ROT - _s RECURSE
     \ Суммируем результат рекурсии
     ROT R> + ROT DROP -1 ( что-то возвратили) ROT RDROP RDROP
   THEN
;
: WRITE-FILE ( c-addr u s -- ior ) \ 94 FILE
  DUP .swritext @ IF
    DUP >R DUP .swbsize @ SWAP .swpos @ - OVER <
    IF R@ FlushWBuffer ?DUP
      IF RDROP NIP NIP
      ELSE
        R@ .swbsize @ OVER <
        IF R> STREAM-HANDLE WRITE-FILE
        ELSE
          R@ .swbuf @
          SWAP DUP R> .swpos !
          MOVE 0
        THEN
      THEN
    ELSE
      R@ .swbuf @ R@ .swpos @ +
      SWAP DUP R> .swpos +!
      MOVE 0
    THEN
  ELSE
    STREAM-HANDLE WRITE-FILE
  THEN
;
: WRITE-LINE ( c-addr u s -- ior ) \ 94 FILE
  DUP >R WRITE-FILE ?DUP IF RDROP EXIT THEN
  LT LTL @ R> WRITE-FILE
;
: FLUSH-FILE ( s -- ior ) \ 94 FILE EXT
  DUP FlushWBuffer ?DUP IF
    NIP
  ELSE
    STREAM-HANDLE FlushFileBuffers ERR
  THEN
;

;MODULE

WARNING !

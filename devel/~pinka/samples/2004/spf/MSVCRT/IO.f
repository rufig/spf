\ 19.Jan.2004   Ruv
\ $Id$

( Расширение SPF
    Быстрое подключение файлов за счет использования
    функций MSVCRT.DLL 

  Переопределяет все необходимые слова работы с файлами,
  первоначальный вариант доступен через словарь OLD-IO

  Ограничения:
    - программа не должна полагать, что SOURCE-ID == WinKernel Handle
    - к значению, возвращаемому SOURCE-ID
      можно применять только новые файловые функции SPF
)
\ Заменяет значение вектора (INCLUDED)
\ Детали в словаре MsvcrtIO-Support

\ some from  ~ac\lib\win\file\stream.f 

REQUIRE CAPI: lib\win\api-call\capi.f 

VOCABULARY OLD-IO   ALSO OLD-IO   FORTH-WORDLIST @  CONTEXT @ ! PREVIOUS

WARNING @  WARNING 0!
MODULE: MsvcrtIO-Support

2 CAPI: fopen   MSVCRT.DLL
1 CAPI: fclose  MSVCRT.DLL
1 CAPI: ferror  MSVCRT.DLL
4 CAPI: fread   MSVCRT.DLL
4 CAPI: fwrite  MSVCRT.DLL
3 CAPI: fgets   MSVCRT.DLL
2 CAPI: fputs   MSVCRT.DLL
1 CAPI: ftell   MSVCRT.DLL
3 CAPI: fseek   MSVCRT.DLL
1 CAPI: fflush  MSVCRT.DLL
1 CAPI: _fileno MSVCRT.DLL

\ 1 CAPI: rewind  MSVCRT.DLL

0 CONSTANT  SEEK_SET \ seek to an absolute position
1 CONSTANT  SEEK_CUR \ seek relative to current position
2 CONSTANT  SEEK_END \ seek relative to end of file

: chop ( addr -- u )
  ASCIIZ> 2DUP + 1- C@ 10 = IF LTL @ - THEN NIP
;

EXPORT

: R/O S" rbS" DROP ;
: W/O S" r+b" DROP ;
: R/W S" r+b" DROP ;

: OPEN-FILE ( addr u mode -- file ior )
  NIP SWAP fopen  DUP 0=
;
: CLOSE-FILE ( file -- ior )
  fclose
;
: CREATE-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
  DROP S" w+b" DROP OPEN-FILE
;
' CREATE-FILE ->VECT CREATE-FILE-SHARED ( c-addr u fam -- fileid ior )
' OPEN-FILE   ->VECT OPEN-FILE-SHARED   ( c-addr u fam -- fileid ior )

: READ-FILE ( c-addr u1 fileid -- u2 ior ) \ 94 FILE
  SWAP ROT ( fileid u1 c-addr ) 1 SWAP
  fread DUP 0=
;
: READ-LINE ( addr u file -- u2 flag ior )
  SWAP ROT fgets  ( res )
  DUP IF chop TRUE 0 EXIT THEN
  DROP 0 FALSE 0
  \ 0 0 id ferror 
  \ 0 0 -1
;
: WRITE-FILE ( c-addr u fileid -- ior ) \ 94 FILE
  SWAP DUP >R ROT ( fileid u1 c-addr ) 1 SWAP
  fwrite R> <>
;
: WRITE-LINE ( c-addr u fileid -- ior ) \ 94 FILE
\  NIP SWAP fputs ( stream str -- int )  -1 <>
  DUP >R WRITE-FILE DUP IF EXIT THEN DROP
  LT LTL @ R> WRITE-FILE
;
: FLUSH-FILE ( fileid -- ior ) \ 94 FILE EXT
  fflush
;
: FILE-POSITION ( fileid -- ud ior ) \ 94 FILE
  ftell 0   OVER -1 =
;
: REPOSITION-FILE ( ud fileid -- ior ) \ 94 FILE
  NIP  \ d -> s
  SEEK_SET -ROT fseek ( orig offset stream -- 0 | -1 )
;
: FILE-SIZE ( fileid -- ud ior ) \ 94 FILE
  DUP
  FILE-POSITION THROW 2>R  >R \ текущая позиция
  SEEK_END 0 R@ fseek DROP    \ на конец
  R@ FILE-POSITION  ( ud ior ) \ позиция=размер
  R> 2R> ROT  REPOSITION-FILE DROP \ восстановление позиции
;
: RESIZE-FILE ( ud fileid -- ior ) \ 94 FILE
  2DROP -1
;

\ ================================================
\ подключение файлов через новые функции

: RECEIVE-WITH  ( i*x source xt -- j*x ior )
  ['] READ-LINE SWAP RECEIVE-WITH-XT
;
: INCLUDE-FILE ( i*x fileid -- j*x ) \ 94 FILE
  BLK 0!  DUP >R  
  ['] TranslateFlow RECEIVE-WITH
  R> CLOSE-FILE THROW
  THROW
;
: (INCLUDED2) ( i*x a u -- j*x )
  R/O OPEN-FILE-SHARED THROW
  INCLUDE-FILE
;
' (INCLUDED2) TO (INCLUDED)


;MODULE
WARNING !

\ ALSO MsvcrtIO-Support
\ test
\ S" test.txt" R/W OPEN-FILE . DUP . VALUE h

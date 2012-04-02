\ Вынесено из ~ac/lib/win/com/com.f ради UTF8>,
\ который в этом варианте более всеядный, чем реализация в ICONV

WINAPI: MultiByteToWideChar   KERNEL32.DLL
WINAPI: WideCharToMultiByte   KERNEL32.DLL

   65001 CONSTANT CP_UTF8

USER UnicodeBuf
VARIABLE COM-DEBUG \ TRUE COM-DEBUG !

: >UNICODE ( addr u -- addr2 u2 )
  DUP 2* CELL+ ALLOCATE DROP UnicodeBuf !
  DUP 0= IF 2DROP UnicodeBuf @ 0 EXIT THEN
  2DUP 2>R
  SWAP >R
  DUP 2* CELL+ UnicodeBuf @ ROT R> 0 ( flags) 0 ( CP_ACP)
  MultiByteToWideChar
  DUP 0= IF DROP 2R> >R UnicodeBuf @ R@ MOVE UnicodeBuf @ R> EXIT
         ELSE 2R> 2DROP THEN
  UnicodeBuf @ 
  SWAP 2* 
  2DUP + 0 SWAP W!
;
: UNICODE> ( addr u -- addr2 u2 )
\ на входе - длина в байтах, а WideCharToMultiByte хочет к-во символов
  DUP 0= IF 2DROP CELL ALLOCATE THROW DUP UnicodeBuf ! 0 EXIT THEN
  2DUP 2>R
  2 /
  1+ \ 0 в конце тоже считаем, т.к. он есть в результ.строке
  >R >R 0 0 R> R>
  DUP CELL+ ALLOCATE DROP UnicodeBuf ! \ 0 0 addr len
  SWAP >R                        \ 0 0 len
  DUP CELL+ UnicodeBuf @         \ 0 0 len len+4 mem
  ROT ( можно поствить DROP -1 для авторасчета длины) 
  R>                             \ 0 0 len+4 mem len addr
  0 ( flags) 0 ( CP_ACP)
  WideCharToMultiByte
  DUP 0= IF DROP 2R> >R UnicodeBuf @ R@ MOVE UnicodeBuf @ R> EXIT
         ELSE 2R> 2DROP THEN
  UnicodeBuf @ 
  SWAP 1-
;
: UTF8>UNICODE ( addr u -- addr2 u2 )
  DUP 2* CELL+ ALLOCATE DROP UnicodeBuf !
  DUP 0= IF 2DROP UnicodeBuf @ 0 EXIT THEN
  2DUP 2>R
  SWAP >R
  DUP 2* CELL+ UnicodeBuf @ ROT R> 0 ( flags) CP_UTF8
  MultiByteToWideChar
  DUP 0= IF DROP 2R> >R UnicodeBuf @ R@ MOVE UnicodeBuf @ R> EXIT
         ELSE 2R> 2DROP THEN
  UnicodeBuf @ 
  SWAP 2* 
  2DUP + 0 SWAP W!
;
: UNICODE>UTF8 ( addr u -- addr2 u2 )
\ на входе - длина в байтах, а WideCharToMultiByte хочет к-во символов
  DUP 0= IF 2DROP CELL ALLOCATE THROW DUP UnicodeBuf ! 0 EXIT THEN
  2DUP 2>R
  2 /
  1+ \ 0 в конце тоже считаем, т.к. он есть в результ.строке
  >R >R 0 0 R> R>
  2* DUP CELL+ ALLOCATE DROP UnicodeBuf ! \ 0 0 addr len
  SWAP >R                        \ 0 0 len
  DUP CELL+ UnicodeBuf @         \ 0 0 len len+4 mem
  ROT 2 / ( можно поствить DROP -1 для авторасчета длины) 
  R>                             \ 0 0 len+4 mem len addr
  0 ( flags) CP_UTF8
  WideCharToMultiByte
  DUP 0= IF DROP 2R> >R UnicodeBuf @ R@ MOVE UnicodeBuf @ R> EXIT
         ELSE 2R> 2DROP THEN
  UnicodeBuf @ 
  SWAP 1-
;
: >UTF8  ( addr u -- addr2 u2 )
  >UNICODE OVER >R UNICODE>UTF8 R> FREE THROW
;
: UTF8> ( addr u -- addr2 u2 )
  UTF8>UNICODE UNICODE>
;

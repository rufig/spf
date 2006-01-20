\ Быстрое описание процедур из стандартных динамических библиотек Windows
\ Ю. Жиловец, 2001
REQUIRE " ~yz/lib/common.f

MODULE: API

" KERNEL32.DLL" ASCIIZ kernel32
" USER32.DLL"   ASCIIZ user32
" GDI32.DLL"    ASCIIZ gdi32

VARIABLE k32
VARIABLE u32
VARIABLE g32

: get-handle ( z adr -- ) OVER LoadLibraryA
  ?DUP IF SWAP ! DROP ELSE .ASCIIZ -1 ABORT" Библиотека не найдена" THEN ;

kernel32 k32 get-handle
user32   u32 get-handle
gdi32    g32 get-handle

VARIABLE WINAP

: api ( adr z "function" -- ) 
 CREATE , , DOES>
 >R
 >IN @ HEADER >IN !
  ['] _WINAPI-CODE COMPILE,
  HERE WINAP !
  0 , \ address of winproc
  R@ @ , \ address of library name
  0 , \ address of function name
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  THEN
  HERE WINAP @ 2 CELLS + !
  HERE >R
  NextWord HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  R> R> CELL+ @ @ GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
;

EXPORT

k32 kernel32  api KERNEL32:
u32 user32    api USER32:
g32 gdi32     api GDI32:

;MODULE


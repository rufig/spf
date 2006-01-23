\ Работа с буфером обмена. Не так то это просто... было.

REQUIRE ADD-CONST-VOC ~day\wincons\wc.f
REQUIRE { ~ac\lib\locals.f

WINAPI: EmptyClipboard  USER32.DLL
WINAPI: OpenClipboard   USER32.DLL
WINAPI: SetClipboardData USER32.DLL
WINAPI: GetClipboardData USER32.DLL
WINAPI: CloseClipboard  USER32.DLL
WINAPI: GlobalAlloc     KERNEL32.DLL
WINAPI: GlobalFree      KERNEL32.DLL
WINAPI: GlobalLock      KERNEL32.DLL
WINAPI: GlobalUnlock    KERNEL32.DLL

: GLOBAL-ALLOC ( u -- h ior)
     GMEM_MOVEABLE GMEM_DDESHARE OR GlobalAlloc
     DUP 0= IF -300 ELSE 0 THEN
;

: GLOBAL-FREE ( addr -- ior)
     GlobalFree IF GetLastError ELSE 0 THEN
;

\ Перед использованием этой памяти используйте GlobalLock
\ После - GlobalUnlock
: GLOBAL-COPY { addr u \ h p -- h}
     u 1+ GLOBAL-ALLOC THROW -> h
     h GlobalLock -> p
     addr p u CMOVE
     0 p u + C!
     h GlobalUnlock DROP
     h
;
      
: StringToCB ( addr u)
\ Копировать строку в буфер обмена
   0 OpenClipboard DROP
   EmptyClipboard DROP
   GLOBAL-COPY
   CF_TEXT
   SetClipboardData DROP
   CloseClipboard DROP
;

\ c-addr потом уничтожить через FREE!!!
: CBString ( -- c-addr u)
   0 OpenClipboard DROP
   CF_TEXT
   GetClipboardData DUP
   GlobalLock ASCIIZ> DUP >R HEAP-COPY
   SWAP GlobalUnlock DROP
   R>
;

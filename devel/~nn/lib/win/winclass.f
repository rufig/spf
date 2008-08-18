REQUIRE [IF]         LIB\INCLUDE\TOOLS.F
REQUIRE CLASS:            ~nn/class/class.f
\ REQUIRE RegisterClassExA  ~nn/lib/win/wfunc.f

C" HINST" FIND NIP 0= [IF] IMAGE-BASE CONSTANT HINST [THEN]

VECT WIN-GATE

CLASS: WinClass

 RECORD: WNDCLASSEX
     var cbSize
     var style
     var lpfnWndProc
     var cbClsExtra
     var cbWndExtra
     var hInstance
     var hIcon
     var hCursor
     var hbrBackground
     var lpszMenuName
     var lpszClassName
     var hIconSm

 ;RECORD /WNDCLASSEX

     var vRegAlready

CONSTR: init
\    own :init
    /WNDCLASSEX cbSize !
    CS_DBLCLKS CS_HREDRAW OR CS_VREDRAW OR CS_OWNDC OR style !
    S" spfwinclass" DROP lpszClassName !
    HINST hInstance !
    ( COLOR_WINDOW)  COLOR_BTNFACE  ( COLOR_BACKGROUND) GetSysColorBrush hbrBackground !
    ['] WIN-GATE lpfnWndProc !

;

M: pre
    1 HINST LoadIconA ?DUP 0=
    IF
        S" icon32" DROP HINST LoadIconA
    THEN
    hIcon !
\     1 HINST LoadIconA DUP . CR  hIcon !
\    2 HINST LoadIconA  => hIconSm
    IDC_ARROW 0 LoadCursorA  hCursor !
;

M: Register ( -- id )
\  ." vRegAlready=" vRegAlready @ . CR
\    0 SetLastError DROP
   vRegAlready @ 0=
   IF
     pre
\     GetLastError . CR
     WNDCLASSEX
     RegisterClassExA ( .S CR) DUP vRegAlready !
     0= IF GetLastError THROW THEN
   THEN
   vRegAlready @ IF lpszClassName @ ELSE 0 THEN
\    vRegAlready @
\     lpszClassName @ ASCIIZ> TYPE CR
\     ." Register=" DUP . CR
;

M: Unregister
   vRegAlready @ ?DUP
   IF
     HINST SWAP UnregisterClassA DROP
     vRegAlready 0!
   THEN
;

DESTR: free  Unregister ;

;CLASS

WinClass OBJECT: DefWinClass

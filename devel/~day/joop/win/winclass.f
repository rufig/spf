REQUIRE Object            ~day\joop\oop.f
REQUIRE WFUNC  ~day\joop\win\wfunc.f


pvar: <style
pvar: <lpszClassName
pvar: <lpfnWndProc
pvar: <hbrBackground
VECT WIN-GATE

CLASS: WinClass <SUPER Object

 RECORD: WNDCLASSEX
  
     CELL VAR     cbSize
     CELL VAR     style
     CELL VAR     lpfnWndProc
     CELL VAR     cbClsExtra
     CELL VAR     cbWndExtra
     CELL VAR     hInstance
     CELL VAR     hIcon
     CELL VAR     hCursor
     CELL VAR     hbrBackground
     CELL VAR     lpszMenuName
     CELL VAR     lpszClassName
     CELL VAR     hIconSm
     
 /REC

     CELL VAR     vRegAlready    

: :init
    own :init
    size: WNDCLASSEX cbSize !
    CS_DBLCLKS CS_HREDRAW OR CS_VREDRAW OR CS_OWNDC OR style !
    S" Forth class" DROP lpszClassName !
    HINST hInstance !
    COLOR_WINDOW  hbrBackground !
    ['] WIN-GATE lpfnWndProc !
;             

: :pre
    1 HINST LoadIconA  hIcon !
\    2 HINST LoadIconA  -> hIconSm
    IDC_ARROW 0 LoadCursorA  hCursor !
;

: :register ( -- id )
   vRegAlready @ 0=
   IF
     own :pre
     WNDCLASSEX
     RegisterClassExA DUP vRegAlready !
     0= IF TRUE ABORT" #Class has not been registered!" THEN
   THEN
\   vRegAlready @   !!!! ‘„…‘œ ˆŒŸ Š‹€‘‘€!!!!! ¨§¬¥­¨« ­  \ Šã«¨ª
   lpszClassName @
;

: :unregister
   vRegAlready @ ?DUP
   IF
     HINST SWAP UnregisterClassA DROP
     vRegAlready 0!
   THEN
;

: :free
    own :unregister
    own :free
;
  
;CLASS

<< :register
<< :unregister

WinClass :newLit VALUE DefWinClass
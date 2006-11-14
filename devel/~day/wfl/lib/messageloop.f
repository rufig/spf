
0 VALUE TRACE-WINMESSAGES

CLASS CMessageIdleLoop
;CLASS

CLASS CMessageFilter

: do ( lpar wpar msg hwnd -- )
;

;CLASS

CLASS CWinMessage

OBJ-SIZE
    0 DEFS addr
    VAR hwnd
    VAR message
    VAR wParam
    VAR lParam
    VAR time
    VAR point

OBJ-SIZE SWAP - 
CONSTANT /MSG

: toString ( -- addr u )
     BASE @ >R HEX
     <# hwnd @ S>D #S S"  window 0x" HOLDS 2DROP
        lParam @ S>D #S S"  lParam 0x" HOLDS 2DROP
        wParam @ S>D #S S"  wParam 0x" HOLDS 2DROP
        message @ S>D #S S" message 0x" HOLDS 
     #>
     R> BASE !
;


: ! ( lpar wpar msg hwnd )
    hwnd !
    message !
    wParam !
    lParam !
;

: @ ( -- lpar wpar msg hwnd )
    lParam @
    wParam @
    message @
    hwnd @
;

: copy ! @ ;

;CLASS

CLASS CMessageLoop

     CWinMessage OBJ msg

: pretranslateMessage ( -- f )
    FALSE \ not translated
;

: idleLoop
;

: run ( -- retcode )
  BEGIN
    idleLoop
    0 0 0 msg addr GetMessageA
  WHILE
    pretranslateMessage 0=
    IF
       TRACE-WINMESSAGES 
       IF
          msg toString TYPE CR
       THEN

       msg addr DUP
       TranslateMessage DROP
       DispatchMessageA DROP
    THEN
  REPEAT
  msg wParam @
;

;CLASS
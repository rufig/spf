
REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDS ~day\hype3\hype3.f
NEEDS ~day\wincons\wc.f
NEEDS ~day\hype3\locals.f
NEEDS ~day\wfl\lib\wfunc.f
NEEDS ~day\lib\macros.f

NEEDS ~profit\lib\logic.f

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

0x100 CONSTANT  WM_KEYFIRST
0x108 CONSTANT  WM_KEYLAST

WM_USER 117 + CONSTANT PSM_ISDIALOGMESSAGE

CLASS CMessageLoop

     CWinMessage OBJ msg

\ process keyboard for modeless dialogs and property sheets
 \ a bit hackish
: pretranslateMessage ( -- f )
    || D: activeWnd ||
    GetActiveWindow activeWnd !

    GWL_EXSTYLE activeWnd @ GetWindowLongA
    WS_EX_CONTROLPARENT AND
    IF
       msg addr 0 PSM_ISDIALOGMESSAGE activeWnd @ SendMessageA
       IF TRUE EXIT THEN

       msg message @ DUP WM_KEYFIRST >=
       SWAP WM_KEYLAST <= AND \ for speed
       IF
          \ translate dialog key
          msg addr activeWnd @ IsDialogMessage
       ELSE FALSE \ not translated
       THEN
    ELSE FALSE
    THEN
;

: idleLoop
;

: run ( -- retcode )
  BEGIN
    idleLoop
    0 0 0 msg addr GetMessageA
  WHILE
    TRACE-WINMESSAGES 
    IF
       msg toString TYPE CR
    THEN

    pretranslateMessage 0=
    IF
       msg addr DUP
       TranslateMessage DROP
       DispatchMessageA DROP
    THEN
  REPEAT
  msg wParam @
;

;CLASS
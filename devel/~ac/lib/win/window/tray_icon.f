\ ƒревн€€ библиотека работы с иконками в трее, написанна€ больше 10 лет
\ назад дл€ "агентов" Eserv'а (pop3recv/smtpsend). «десь адаптируетс€ дл€
\ работы с браузерным окном. ≈динственна€ причина, по которой нельз€
\ использовать там notify_icon.f без этой обертки - то что windows извещени€
\ от иконки шлет не через SendMessage/PostMessage окна, а напр€мую в оконную
\ процедуру. ј в browser.f таковой нет, используетс€ штатна€. "—убклассить"
\ ради такой мелочи т€желое окно AtlAxWin наверное не стоит. “ем более что
\ иконка в трее нужна одна на приложение, а не на каждое браузерное окно.
\ ¬ общем, тут отдельное примитивное окошко субкласс listbox'а от агентов
\ Eserv'а - самое то. ќтрежем Eserv'оспецифические части, получитс€ библиотека.

\ «апуск по "hwnd StartAgentThread".  онтекстное меню задаетс€ словарем
\ CONT-MENU-VOC, а иконки дл€ него - vGetIconFilename.

\ ToListBox - от экранного лога агентов Eserv. “ут не нужно, но вдруг 
\ пригодитс€ в том же качестве :)

REQUIRE TrayIconCreate ~ac/lib/win/window/notify_icon.f
REQUIRE ListBoxAddItem ~ac/lib/win/window/listbox.f
REQUIRE MenuFromVocImg ~ac/lib/win/window/menuitem.f

30000 VALUE LimitListbox

VARIABLE SendQuit
VARIABLE ImmExit

VARIABLE vaWND

VOCABULARY CONT-MENU

ALSO CONT-MENU DEFINITIONS
: ¬ыход
  TRUE ImmExit !
  TrayIconDelete 
  SendQuit @ 0=
  IF
    BYE
  THEN
;
GET-CURRENT
PREVIOUS DEFINITIONS

VALUE CONT-MENU-VOC

CREATE POINT 0 , 0 ,

1997 VALUE AgentIconID

0 VALUE AgentWindowVisible
0 VALUE AgentTipText
HERE C" Agent" ", 0 C, TO AgentTipText

VARIABLE AGENT-WND
VARIABLE vaEnableWindow TRUE vaEnableWindow !

: ContextMenu ( wnd -- )
  || wnd || (( wnd ))
  POINT GetCursorPos DROP
  POINT @ POINT CELL+ @
  wnd CONT-MENU-VOC MenuFromVocImg
;

\ собственно обработка событий мыши:

: (AGENT-WND-PROC1) ( lparam wparam msg wnd -- lresult )
  || lparam wparam msg wnd || (( lparam wparam msg wnd ))
  msg AgentIconID =
  IF
    lparam WM_LBUTTONDOWN =
    IF AgentWindowVisible
       IF vaWND @ WindowDisable vaWND @ WindowMinimize vaWND @ WindowHide
       ELSE vaWND @ WindowShow  vaWND @ WindowRestore 
            vaWND @ WindowEnable vaWND @ WindowToForeground
       THEN
       AgentWindowVisible 0= TO AgentWindowVisible
    THEN
    lparam WM_RBUTTONUP =
    IF wnd ContextMenu THEN
  THEN 

  msg WM_RBUTTONUP =
  IF wnd ContextMenu THEN

  lparam wparam msg wnd   wnd WindowOrigProc
;
: (AGENT-WND-PROC)
  ['] (AGENT-WND-PROC1) CATCH IF 2DROP 2DROP TRUE THEN
;
' (AGENT-WND-PROC) WNDPROC: AGENT-WND-PROC

: AgentTitle ( addr u -- )
  2DUP AgentIconID AGENT-WND @ TrayIconModifyText
  DROP AGENT-WND @ ?DUP IF SetWindowTextA THEN DROP
;
HERE C" ico\mail10.ico" ", 0 ,
VALUE AgentIconFilename
: AGENT
  || w ||
  S" LISTBOX" WS_VSCROLL WS_HSCROLL OR \ WS_THICKFRAME OR WS_BORDER OR WS_SYSMENU OR
  WS_DISABLED OR WS_MINIMIZE OR WS_OVERLAPPEDWINDOW OR
  0 Window -> w
  vaWND @ 0= IF w vaWND ! THEN \ если не задано, каким окном управл€ть, будем самим собой
  w AGENT-WND !
  AgentTipText COUNT AgentTitle
  ['] AGENT-WND-PROC w WindowSubclass
  1 LoadIconResource16
  IF
    AgentTipText COUNT 1 AgentIconID w TrayIconCreateFromResource
  ELSE
    AgentTipText COUNT AgentIconFilename COUNT AgentIconID w TrayIconCreate
  THEN
  w MessageLoop
  0 TO AgentWindowVisible
  TrayIconDelete
;
: RestoreIcon
  1 LoadIconResource16
  IF
    1 TrayIconUpdateFromResource
  ELSE
    AgentIconFilename COUNT TrayIconModifyIcon
  THEN
;
: ToListbox1 ( addr u -- )
  vaEnableWindow @ 0= IF 2DROP EXIT THEN
  || i ||
  AGENT-WND @ ListboxAddItem -> i
  i LimitListbox > 
  IF 0 AGENT-WND @ ListboxDeleteItem 
  ELSE
     AGENT-WND @ ListboxGetSel LB_ERR =
     IF i AGENT-WND @ ListboxScrollTo THEN
  THEN
;
: (ToListbox)
  BEGIN
    10 PARSE DUP
  WHILE
    2DUP + 1- C@ IsDelimiter IF 1- THEN
    ToListbox1
  REPEAT 2DROP
;
: ToListbox ( addr u -- )
  ['] (ToListbox) EVALUATE-WITH
;
: (AGENT-THREAD) ( hwnd -- X )
  vaWND !
  BEGIN
   ['] AGENT CATCH DROP
  AGAIN
;
' (AGENT-THREAD) TASK: AGENT-THREAD

: -dw
  FALSE vaEnableWindow !
;
: -ln
  0 0 BL WORD COUNT >NUMBER 2DROP D>S TO LimitListbox
;
: StartAgentThread ( hwnd -- )
\ hwnd - какое окно вместо listbox'а будем переключать иконкой
  AGENT-THREAD START DROP
;

\EOF
0 StartAgentThread

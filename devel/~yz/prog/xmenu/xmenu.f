REQUIRE "   ~yz/lib/common.f

" XMENU 1.13" ASCIIZ program-name
" xmenu.cfg" ASCIIZ filename

REQUIRE msg         ~yz/lib/msg.f
DIS-OPT
REQUIRE (*          ~yz/lib/wincons.f
SET-OPT
REQUIRE {           ~ac/lib/locals.f  \ }
REQUIRE PMconnect   ~yz/lib/pagemaker.f
REQUIRE small-hash  ~yz/lib/hash.f
REQUIRE RESOURCES:  ~yz/lib/resources.f
REQUIRE <(          ~yz/lib/format.f
\ REQUIRE TraceON     lib/ext/debug/tracer.f

\ -----------------------------------------------------

: my-error ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP -2 = IF DROP 
                ER-A @ ER-U @ PAD CZMOVE PAD err
           THEN
  >R <( R> DUP " Ошибка #~N (0x~06H)" )> err
;
: error ( z--) err BYE ;
: ?error ( ? z --) SWAP IF error ELSE DROP THEN ;

: err-dialog ( z -- )
  { \ [ 256 ] buf }
  buf ZMOVE
  <( ERR-FILE ERR-LINE# ERR-IN# buf ERR-LINE
  " ~S: ~N, ~N~/~Z~/~S" 
  )> err
  CURFILE @ ?DUP IF FREE DROP CURFILE 0! THEN
;

\ ---------------------------------------------------

16 == icon-size
2 == icon-left
3 == icon-right
3 == icon-top
2 == icon-bottom

0
CELL -- :hwnd
CELL -- :message
CELL -- :wParam
CELL -- :lParam
CELL -- :time
CELL -- :pt
CONSTANT #message

\ win-структура для регистрации класса окна - WNDCLASS
0
CELL -- :Style
CELL -- :WndProc
CELL -- :ClsExtra
CELL -- :WndExtra
CELL -- :Instance
CELL -- :Icon
CELL -- :Cursor
CELL -- :Background
CELL -- :MenuName
CELL -- :ClassName
CONSTANT #window-class

IMAGE-BASE == instance
0x401 ( wm_user+1) == fromtray

WINAPI: DefWindowProcA     USER32.DLL
WINAPI: GetMessageA        USER32.DLL
WINAPI: TranslateMessage   USER32.DLL
WINAPI: DispatchMessageA   USER32.DLL
WINAPI: LoadIconA          USER32.DLL
WINAPI: PostQuitMessage    USER32.DLL
WINAPI: RegisterClassA     USER32.DLL
WINAPI: CreateWindowExA    USER32.DLL

0 USER-VALUE hwnd
0 USER-VALUE message
0 USER-VALUE wparam
0 USER-VALUE lparam
0 USER-VALUE hparam

0 VALUE secret-window
0 VALUE iconlist

0 VALUE right-menu
0 VALUE left-menu
0 VALUE current-menu

0 VALUE commands
0 VALUE macros
0 VALUE keywords

CREATE MSG #message ALLOT

0
CELL -- :nsize
CELL -- :nhwnd
CELL -- :niconid
CELL -- :nflags
CELL -- :ncallback
CELL -- :nicon
64   -- :ntip
CONSTANT #notify

WINAPI: Shell_NotifyIconA  SHELL32.DLL

WINAPI: GetCursorPos     USER32.DLL
WINAPI: DestroyMenu      USER32.DLL
WINAPI: CreatePopupMenu  USER32.DLL
WINAPI: TrackPopupMenu   USER32.DLL
WINAPI: AppendMenuA      USER32.DLL
WINAPI: SetForegroundWindow USER32.DLL

CREATE save-wl     8 CELLS ALLOT
CREATE save-macros 8 CELLS ALLOT

: create-wordlist
  TEMP-WORDLIST TO commands
  TEMP-WORDLIST TO macros
  ( сохраним чистые словари. Мне очень стыдно за непортабельный код, но
    уничтожить через free-wordlist старый словарь нельзя, потому что он был
    создан в другом потоке, а forget почему-то не предусмотрен)
  commands CELL- save-wl 8 CELLS CMOVE
  macros   CELL- save-macros 8 CELLS CMOVE ;

0
CELL -- :micon        \ иконка пункта меню
CELL -- :mheight      \ высота строки (высчитывается при обработке wm_measureitem)
CELL -- :mstr         \ начало строки
== #micon

: new-mitem ( z icon -- a)
  OVER ZLEN 1+ 2 CELLS+ MGETMEM ( z icon a )
  DUP >R ! R@ 2 CELLS+ ZMOVE
  R> ;

100 == first-menu-id
0 VALUE menu-id

: next-menu-id
  menu-id 1+ TO menu-id ;

: cursor-pos ( -- x y)
  { \ [ 8 ] point }
  point GetCursorPos DROP  point @ point CELL+ @ ;

: menuappend ( cont id flags menu -- )
  AppendMenuA 0= " Не могу добавить пункт меню" ?error ;

: append-line ( menu -- )
  >R 0 0 W: mf_separator R> menuappend ;

: append ( z id menu -- )
  >R W: mf_string R> menuappend ;

: icon-append ( z icon id menu -- )
  >R >R new-mitem R> W: mf_ownerdraw R> menuappend ;

: append-menu ( z what-menu menu -- )
  >R W: mf_popup R> menuappend ;

: icon-append-menu ( z icon what-menu menu -- )
  >R >R new-mitem R> (* mf_popup mf_ownerdraw *) R> menuappend ;

VARIABLE stack-pointer

: do-command ( command# -- )
  S>D <# # # # #> commands SEARCH-WORDLIST
  IF
    ( xt) >R 
    SP@ stack-pointer ! 
    R> EXECUTE 
    stack-pointer @ SP!
  THEN
;

: remove-from-tray
  { \ [ 88 ] data }
  88 data :nsize !
  secret-window data :nhwnd !
  0 data :nflags !
  data 2 ( nim_delete) Shell_NotifyIconA
  0= " Не могу удалить иконку из системной панели" ?error
;

\ -----------------------------------
: backward ( z c -- z1 )
  >R
  BEGIN
    DUP C@ R@ <>
  WHILE
    1-
  REPEAT RDROP ;

\ -----------------------------------

258 == MAX_PATH

CREATE start-dir MAX_PATH ALLOT

CREATE item-name 128 ALLOT  item-name 0!
VARIABLE item-icon  item-icon 0!

WINAPI: WinExec      KERNEL32.DLL
WINAPI: SetCurrentDirectoryA  KERNEL32.DLL
WINAPI: GetCurrentDirectoryA  KERNEL32.DLL

: only-dir ( z -- )
  ASCIIZ> 1-
  BEGIN
    ( a n) DUP -1 <>
  WHILE
    2DUP + C@ c: \ = IF + 0 SWAP C! EXIT THEN
    1-
  REPEAT 2DROP
;

\ перейти в каталог, в котором хранится указанный файл
: chdir { z \ [ MAX_PATH ] buf -- }
  z PARSE...
  PeekChar c: " = IF c: " ELSE BL THEN WORD COUNT buf CZMOVE
  ...PARSE
  buf only-dir
  buf SetCurrentDirectoryA DROP ;

: run-program ( z -- ?)
  DUP chdir
  1 SWAP WinExec 32 < ;

: run-script ( zprog zstr -- )
  DUP chdir
  2>R <( 2R@ " ~Z ~Z" )> 1 SWAP WinExec
  32 < IF
    <( 2R@ DROP " Не могу запустить~/~Z" )> err
  THEN
  RDROP RDROP
;

: winexec
  DOES> DUP >R run-program IF <( R@ " Не могу запустить~/~Z" )> err THEN
  RDROP ;

: append-to-current-menu
  item-icon @ IF
    item-name item-icon @ menu-id current-menu icon-append
  ELSE
    item-name menu-id current-menu append
  THEN
  next-menu-id  item-name 0! ;

\ ---------------------------------------
: land-str ( a n -- ) HERE OVER ALLOT ( from # to) CZMOVE ;

: macro ( z -- z/0)
  ASCIIZ> macros SEARCH-WORDLIST DUP IF DROP EXECUTE THEN
;

: expand 
  BEGIN
    c: [ PARSE land-str
    c: ] PARSE DUP 0= IF 2DROP EXIT THEN
    2DUP macros SEARCH-WORDLIST IF
      EXECUTE ASCIIZ> land-str
      2DROP
    ELSE
      2>R <( 2R> " Макрос не найден: ~'~S~'" )> err-dialog
    THEN
  AGAIN
;

: macro-expand-here ( a n -- )
  SPARSE...
  expand  0 C,
  ...PARSE
;

: save-string
  1 PARSE macro-expand-here ;

\ -----------------------------------
WINAPI: LoadImageA             USER32.DLL
WINAPI: ExtractIconExA         SHELL32.DLL
WINAPI: ExtractAssociatedIconA SHELL32.DLL

: extract-small-icon { fn \ small -- }
  1 ^ small 0 0 fn ExtractIconExA 1 = IF small ELSE 0 THEN ;

: get-extracted-icon { fn \ space-adr -- icon }
  fn ASCIIZ> S"  " SEARCH PRESS IF
    DUP TO space-adr
    0 SWAP C!
  ELSE
    DROP
  THEN
  fn ASCIIZ> iconlist HASH@N 0= IF
     ( иконки еще нет)
     fn extract-small-icon DUP fn ASCIIZ> ROT iconlist HASH!N
  THEN
  space-adr ?DUP IF BL SWAP C! THEN
;

: associated-icon { fn \ [ 255 ] fb icon# -- icon }
  fn fb ZMOVE
  ^ icon# fb IMAGE-BASE ExtractAssociatedIconA ;

: get-associated-icon { fn \ [ 30 ] ext -- icon }
  fn ASCIIZ> S" ." SEARCH PRESS IF
    1+ ext ZMOVE
    ext ASCIIZ> iconlist HASH@N 0= IF
      ( иконки еще нет)
      fn associated-icon DUP ext ASCIIZ> ROT iconlist HASH!N
    THEN
  THEN ;

: get-icon { a n \ [ 128 ] buf -- icon }
  n 0= IF 0 EXIT THEN
  a n buf CZMOVE
  a n iconlist HASH@N 0= IF
     ( иконки еще нет)
     W: lr_loadfromfile icon-size DUP W: image_icon buf instance
     LoadImageA DUP a n ROT iconlist HASH!N
     DUP 0= IF <( a n " Иконка не найдена: ~'~S~'" )> err THEN
  THEN ;

: get-header ( -- a n icon )
  c: | PARSE -TRAILING
  1 PARSE get-icon ;

\ -----------------------------------

: scriptexec DOES> DUP @ SWAP CELL+ run-script ;

: compile-script ( zscript -- )
  menu-id S>D <# # # # #> CREATED
  ,
  HERE save-string item-icon @ IF 
    DROP 
  ELSE 
    get-associated-icon item-icon !
  THEN
  scriptexec
  ( добавим пункт меню)
  append-to-current-menu
;

: does-script DOES> compile-script ;

\ -----------------------------------

WORDLIST TO keywords

GET-CURRENT
keywords SET-CURRENT

: >> ( ->eol)
  get-header item-icon ! item-name CZMOVE ;

: ---
  current-menu append-line ;

: \  ( ->eol) 1 PARSE 2DROP ;

: СКРИПТ ( ->bl; ->eol)
  GET-CURRENT keywords SET-CURRENT
  CREATE save-string does-script
  SET-CURRENT
;

: ЗАПУСТИТЬ ( ->eol)
  menu-id S>D <# # # # #> CREATED
  HERE save-string item-icon @ IF 
    DROP 
  ELSE 
    get-extracted-icon item-icon !
  THEN
  winexec
  ( добавим пункт меню)
  append-to-current-menu ;

: МЕНЮ ( ->eol; --  zmenu-name icon parent-menu "menu" )
  get-header ( a n icon) >R CZGETMEM R>
  current-menu
  CreatePopupMenu TO current-menu 
  CELL" MENU"
;

: КОНЕЦ-МЕНЮ ( zmenu-name icon parent-menu "menu" -- )
  CELL" MENU" <> IF -1000 THROW THEN
  SWAP >R 2DUP R> ?DUP
  IF
    SWAP current-menu SWAP icon-append-menu
  ELSE
    current-menu SWAP append-menu
  THEN
  TO current-menu  FREEMEM
  ( в этом месте неплохо бы взять current-menu, сохранить его где-нибудь с 
    целью последующего уничтожения при выгрузке программы, но лень.
    Сколько оно там займет памяти?)
;

: ФОРТ:
  menu-id S>D <# # # # #> SHEADER
  ALSO FORTH
  ]
  append-to-current-menu
;

: ФОРТ;
  RET, [COMPILE] [
  PREVIOUS
; IMMEDIATE

: МАКРО ( ->bl; ->eol)
  GET-CURRENT
  macros SET-CURRENT
  CREATE save-string
  SET-CURRENT
;

: РАСШИРЕНИЯ:
  GET-CURRENT
  FORTH-WORDLIST SET-CURRENT
  ALSO FORTH
;

: РАСШИРЕНИЯ;
  SET-CURRENT
  PREVIOUS
;

SET-CURRENT

: prepare-all
  iconlist ?DUP IF del-hash THEN
  small-hash TO iconlist
  start-dir SetCurrentDirectoryA DROP
  left-menu DestroyMenu DROP
  CreatePopupMenu ?DUP 0= IF " Не могу создать меню" error THEN TO left-menu
  first-menu-id TO menu-id
  ( очистим словарь)
  save-wl commands CELL- 8 CELLS CMOVE
  save-macros macros CELL- 8 CELLS CMOVE
  FORTH DEFINITIONS
  WARNING 0!
;

: read-my-file
  { \ depth -- }
  prepare-all
  GET-CURRENT
  GET-ORDER
  commands SET-CURRENT
  keywords 1 SET-ORDER
  DEPTH TO depth
  left-menu TO current-menu
  filename DUP ZLEN ['] INCLUDED CATCH
  ?DUP IF
    CASE
      2 3 <OF< <( filename " Файл ~'~Z~' не найден" )> err EXIT ENDOF
      -2003 OF " Неизвестное ключевое слово"  ENDOF
      0xC0000005 OF " Нарушение общей защиты" ENDOF
      -1000 OF " КОНЕЦ-МЕНЮ без МЕНЮ" ENDOF
    >R <( R> " Ошибка ~N" )>
    END-CASE
    err-dialog EXIT
  THEN
  DEPTH depth <> IF " Ошибка в файле меню" err EXIT THEN
  SET-ORDER
  SET-CURRENT
;

\ ----------------------------------------

WINAPI: MessageBoxIndirectA USER32.DLL

: about
  { \ [ 40 ] params -- }
  40 params !
  secret-window params CELL+ !
  instance params 2 CELLS + !
  " Меню для быстрого вызова программ.\n\n(c) 2002 Ю. Жиловец, http://www.forth.org.ru/~yz\nМышку нарисовала Н. Рымарь."
  params 3 CELLS + !
  program-name params 4 CELLS + !
  (* mb_ok mb_usericon *) params 5 CELLS + !
  1 params 6 CELLS + !
  params 7 CELLS + 0!
  params 8 CELLS + 0!
  params 9 CELLS + 0!
  params MessageBoxIndirectA DROP
;

WINAPI: PostMessageA  USER32.DLL

: x-menu
  secret-window SetForegroundWindow DROP
  0 secret-window 0 cursor-pos SWAP (* tpm_leftbutton tpm_rightalign tpm_returncmd *)
  left-menu TrackPopupMenu
  0 0 W: wm_null secret-window PostMessageA DROP
  DUP first-menu-id menu-id WITHIN IF do-command ELSE DROP THEN ;

: context-menu
  secret-window SetForegroundWindow DROP
  0 secret-window 0 cursor-pos SWAP (* tpm_leftbutton tpm_leftalign tpm_returncmd *)
  right-menu TrackPopupMenu
  0 0 W: wm_null secret-window PostMessageA DROP
  CASE
    1 OF read-my-file ENDOF
    2 OF about ENDOF
    3 OF ( выход)
       remove-from-tray
       right-menu DestroyMenu DROP
       left-menu DestroyMenu DROP
       0 PostQuitMessage DROP
    ENDOF
   DROP END-CASE
;

0 VALUE mouse16
0 VALUE bmouse16
0 VALUE reload-icon
0 VALUE exit-icon

: make-right-menu
  CreatePopupMenu ?DUP 0= IF " Не могу создать меню" error THEN TO right-menu
  " Перечитать файл" reload-icon 1 right-menu icon-append
  " О программе..."  mouse16     2 right-menu icon-append
  " Выход"           exit-icon   3 right-menu icon-append ;

: load-icons
  2 instance LoadIconA TO mouse16
  3 instance LoadIconA TO bmouse16
  4 instance LoadIconA TO reload-icon
  5 instance LoadIconA TO exit-icon ;

: change-icon ( icon -- )
  { \ [ 88 ] data }
  88 data :nsize !
  secret-window data :nhwnd !
  0x2 ( есть иконка) data :nflags !
  data :nicon !
  data 1 ( nim_modify) Shell_NotifyIconA
  0= " Не могу изменить иконку" ?error
;

: mouse-blink
  ( заставляет мышку мигнуть)
  bmouse16 change-icon
  500 Sleep DROP
  mouse16 change-icon ;

WINAPI: GetTextExtentPoint32A GDI32.DLL
WINAPI: GetDC                 USER32.DLL
WINAPI: ReleaseDC             USER32.DLL

: text-width { z window \ dc [ 2 CELLS ] size -- tx ty }
  window GetDC TO dc
  size z ASCIIZ> SWAP dc GetTextExtentPoint32A DROP
  dc window ReleaseDC DROP
  size @ size 1 CELLS@ ;

WINAPI: DrawIconEx	USER32.DLL
WINAPI: TextOutA	GDI32.DLL
WINAPI: GetTextColor    GDI32.DLL
WINAPI: SetTextColor    GDI32.DLL
WINAPI: GetBkColor      GDI32.DLL
WINAPI: SetBkColor	GDI32.DLL
WINAPI: FillRect	USER32.DLL
WINAPI: GetSysColor	USER32.DLL

: draw-menu-item { \ data dc state rx ry rw rh textcolor backcolor -- }
  lparam 4 CELLS@ 0xFF AND TO state
  lparam 6 CELLS@ TO dc
  lparam 7 CELLS@ TO rx
  lparam 8 CELLS@ TO ry
  lparam 9 CELLS@ rx - TO rw
  lparam 10 CELLS@ ry - TO rh
  lparam 11 CELLS@ TO data
  state W: ods_selected = IF
    \ рисуем выделенный пункт
    W: color_highlight 1+ lparam 7 CELLS+ dc FillRect DROP
    dc GetTextColor TO textcolor
    W: color_highlighttext GetSysColor dc SetTextColor DROP
    dc GetBkColor TO backcolor
    W: color_highlight GetSysColor dc SetBkColor DROP
  ELSE
    W: color_menu 1+ lparam 7 CELLS+ dc FillRect DROP
  THEN
  \ рисуем иконку
  W: di_normal 0 0 icon-size DUP data :micon @
  icon-top ry + icon-left rx + dc DrawIconEx DROP
  \ пишем строку
  data :mstr ASCIIZ> SWAP
  icon-size data :mheight @ - 2/ icon-top + ry + 1+
  icon-left icon-size icon-right + + rx +
  dc TextOutA DROP
  state W: ods_selected = IF
    \ приводим в порядок контекст устройства
    textcolor dc SetTextColor DROP
    backcolor dc SetBkColor DROP
  THEN ;

:NONAME
  ( lparam wparam msg hwnd) 
  TO hwnd  TO message  TO wparam  TO lparam
  message CASE

  fromtray OF
    lparam CASE
      W: wm_lbuttondown OF
          x-menu
      ENDOF
      W: wm_rbuttondown OF
        context-menu
      ENDOF
    DROP END-CASE  
    0
  ENDOF

  W: wm_command OF
     wparam LOWORD CASE
     10 OF
       mouse-blink
     ENDOF
     DROP END-CASE ( все остальное не обрабатываем)
     0
  ENDOF

  W: wm_measureitem OF
    lparam 5 CELLS@ :mstr hwnd text-width ( tx ty)
    DUP lparam 5 CELLS@ :mheight !
    icon-size icon-top icon-bottom + + MAX
    SWAP icon-size icon-left icon-right + + MAX SWAP
    lparam 4 CELLS!
    lparam 3 CELLS!
    TRUE
  ENDOF

  W: wm_drawitem OF
     draw-menu-item
     TRUE
  ENDOF

  DROP lparam wparam message hwnd DefWindowProcA
  END-CASE
; WNDPROC: process-hidden-window

: MessageLoop
  BEGIN
    0 0 0 MSG GetMessageA
  WHILE
    MSG TranslateMessage DROP
    MSG DispatchMessageA DROP
  REPEAT
;

: create-hidden-window
  \ готовим класс к регистрации
  HERE :Style 0!
  ['] process-hidden-window HERE :WndProc !
  HERE :ClsExtra 0!
  HERE :WndExtra 0!
  instance HERE :Instance !
  1 instance LoadIconA HERE :Icon !
  HERE :Cursor 0!
  1 HERE :Background !
  HERE :MenuName 0!
  " XMENU" HERE :ClassName !
  HERE RegisterClassA 0= " Не могу зарегистрировать класс окна" ?error
  \ создаем окно
  0 instance 0 0 W: cw_usedefault DUP DUP DUP W: ws_disabled
  " XMENU" DUP W: ws_ex_toolwindow
  CreateWindowExA ?DUP 0= " Не могу создать секретное окно" ?error
  TO secret-window
;

: hide-into-tray
  88 HERE :nsize !
  secret-window HERE :nhwnd !
  0x7 ( есть все) HERE :nflags !
  fromtray HERE :ncallback !
  mouse16 HERE :nicon !
  " Секретное меню" HERE :ntip ZMOVE
  HERE 0 ( nim_add) Shell_NotifyIconA
  0= " Не могу добавить иконку в системную панель" ?error
;

: RUN
  ['] my-error TO ERROR
\  STARTLOG
  start-dir MAX_PATH GetCurrentDirectoryA DROP
  create-hidden-window
  load-icons
  make-right-menu
  hide-into-tray
  create-wordlist
  read-my-file
  MessageLoop
  BYE ;

REMOVE-ALL-CONSTANTS

0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
 TRUE TO ?GUI
' RUN MAINX !
RESOURCES: xmenu.fres
S" xmenu.exe" SAVE  
BYE

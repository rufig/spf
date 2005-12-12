REQUIRE "   ~yz/lib/common.f

" XMENU 1.30" ASCIIZ program-name
" xmenu.cfg"  ASCIIZ filename
" Секретное меню" ASCIIZ secret-menu-tooltip

REQUIRE msg            ~yz/lib/msg.f
REQUIRE (*             ~yz/lib/wincons.f
REQUIRE {              lib/ext/locals.f
REQUIRE init->>        ~yz/lib/data.f
REQUIRE SPARSE...      ~yz/lib/parse.f
REQUIRE small-hash     ~yz/lib/hash.f
REQUIRE RESOURCES:     ~yz/lib/resources.f
REQUIRE <(             ~yz/lib/format.f
REQUIRE (:	       ~yz/lib/inline.f
REQUIRE create-channel ~yz/lib/channel.f
REQUIRE PROC:          ~yz/lib/proc.f
REQUIRE RECORD:        ~yz/lib/record.f

\ -----------------------------------------------------

: my-error ( ERR-NUM -> ) \ показать расшифровку ошибки
  ." err"  DUP -2 = IF DROP 
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

: include-file { filename-a filename-# \ depth -- ?}
  DEPTH TO depth
  filename-a filename-# ['] INCLUDED CATCH
  ?DUP IF
    PRESS PRESS \ уничтожаем остатки от INCLUDED
    CASE
      2 3 <OF< <( filename-a filename-# " Файл ~'~S~' не найден" )> err 0 EXIT ENDOF
      -2003 OF " Неизвестное ключевое слово"  ENDOF
      0xC0000005 OF " Нарушение общей защиты" ENDOF
      -1000 OF " КОНЕЦ-МЕНЮ без МЕНЮ" ENDOF
    >R <( R> " Ошибка ~N" )>
    END-CASE
    err-dialog 0 EXIT
  THEN
  DEPTH depth <> 
;

\ ---------------------------------------------------

16 == icon-size
2 == icon-left
4 == icon-right
3 == icon-top
2 == icon-bottom
40 == max-filename-size
40 == #exticons

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
WINAPI: DestroyWindow      USER32.DLL

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
0 VALUE rcommands

0 VALUE dyn-submenus
0 VALUE dyn-items

0 VALUE current-icon
0 VALUE std-tooltip
0 VALUE std-icon

0 VALUE taskbar-created

CREATE MSG #message ALLOT

RECORD: #notify
  DWORD    :nSize
  HWND     :nHwnd 
  UINT     :nID 
  UINT     :nFlags
  UINT     :nCallback
  HICON    :nIcon
  64 TCHAR :nTip
RECORD;

#notify RECORDEX: #notifyex
  64 TCHAR  :nTip2           \ огрызок от нового поля
  DWORD     :nState
  DWORD     :nStateMask
  256 TCHAR :nInfo
  UINT      :nTimeout
  64 TCHAR  :nInfoTitle
  DWORD     :nInfoFlags
RECORDEX;

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

\ Запись об отрисовываемом пункте статического меню

0
CELL -- :micon        \ иконка пункта меню
CELL -- :mheight      \ высота строки (высчитывается при обработке wm_measureitem)
CELL -- :mstr         \ адрес начала строки
CELL -- :mstable      \ не подлежит уничтожению через destroy-menu
== #micon

\ Запись о подменю динамического меню

#micon
CELL -- :mfilled	\ меню уже заполнено
CELL -- :mfilter	\ фильтр подменю
CELL -- :mpath		\ путь, соответствующий этому подменю
CELL -- :mpath2		\ второй путь 
CELL -- :mdynid		\ подменю: hmenu, пункт: id
== #mdynsubmenu

\ Запись о подпункте динамического меню
\ Такая же, как и о подменю, но различается смысл некоторых полей

: :mparent  :mfilled ;  \ подменю-владелец

: new-mitem ( z icon -- a)
  OVER ZLEN 1+ #micon + MGETMEM ( z icon a )
  DUP >R :micon ! 
  R@ #micon + ZMOVE
  R@ #micon + R@ :mstr !
  R> ;

100 == first-menu-id
0 VALUE menu-id
1000 == first-dyn-id
0 VALUE dyn-id

1 == id-reload
2 == id-about
3 == id-exit

: next-menu-id
  menu-id 1+ TO menu-id ;

: next-dyn-id
  dyn-id 1+ TO dyn-id ;

: cursor-pos ( -- x y)
  { \ [ 8 ] point }
  point GetCursorPos DROP  point @ point CELL+ @ ;

: menuappend ( cont id flags menu -- )
  AppendMenuA 0= " Не могу добавить пункт меню" ?error ;

: append-line ( menu -- )
  >R 0 0 W: mf_separator R> menuappend ;

: append ( z id menu -- )
  >R W: mf_string R> menuappend ;

: append-with-icon ( param id menu -- )
  W: mf_ownerdraw SWAP menuappend ;

: icon-append ( z icon id menu -- )
  2SWAP new-mitem -ROT append-with-icon ;

: append-menu ( z what-menu menu -- )
  >R W: mf_popup R> menuappend ;

: append-menu-with-icon ( param what-menu menu -- )
  (* mf_popup mf_ownerdraw *) SWAP menuappend ;

: icon-append-menu ( z icon what-menu menu -- )
  2SWAP new-mitem -ROT append-menu-with-icon ;

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

\ -----------------------------------
\ Список именованных иконок

VAR named-icons

: new-named-icon-s ( hicon a # -- ) 
  ROT named-icons HASH!N ;

: new-named-icon ( hicon z -- )
  ASCIIZ> new-named-icon-s ;  

: named-icon-from-res ( n z -- )
  >R instance LoadIconA R> new-named-icon ;

: icon-by-name ( z -- hicon/0)
  ASCIIZ> named-icons HASH@N DUP IF DROP THEN
;

: create-named-icons ( -- )
  small-hash TO named-icons
  2 " mouse"     named-icon-from-res
  3 " bl-mouse"  named-icon-from-res
  4 " reload"    named-icon-from-res
  5 " exit"      named-icon-from-res
  6 " programs"  named-icon-from-res
  7 " documents" named-icon-from-res
  " mouse" icon-by-name TO std-icon
  secret-menu-tooltip TO std-tooltip
;

WINAPI: DestroyIcon      USER32.DLL

: del-named-icons ( -- )
  (: ( akey nkey hicon -- )
    DestroyIcon DROP
    2DROP
  ;) named-icons all-hash
  named-icons del-hash
;

\ -----------------------------------
\ Обход и уничтожение меню со всеми внутренностями

WINAPI: GetMenuItemInfoA USER32.DLL
WINAPI: GetMenuItemCount USER32.DLL
WINAPI: RemoveMenu       USER32.DLL

: traverse-menu { hmenu xt \ [ 11 CELLS ] iteminfo -- }
  \ xt ( iteminfo -- )
  hmenu GetMenuItemCount DUP -1 = IF DROP EXIT THEN
  0 ?DO
    11 CELLS iteminfo !
    (* miim_data miim_type miim_submenu *) iteminfo 1 CELLS!
    iteminfo TRUE ( by position) I hmenu GetMenuItemInfoA DROP
    iteminfo xt EXECUTE
  LOOP
;

\ itemifo
\ 0	UINT    cbSize;  
\ 1	UINT    fMask; 
\ 2	UINT    fType;		Тип подъэлемента
\ 3	UINT    fState; 
\ 4	UINT    wID; 
\ 5	HMENU   hSubMenu;       Подменю (если есть)
\ 6	HBITMAP hbmpChecked; 
\ 7	HBITMAP hbmpUnchecked; 
\ 8	DWORD   dwItemData;     Наши данные
\ 9	LPTSTR  dwTypeData; 
\ 10	UINT    cch; 

VECT clean-submenu

: del-icon-from-micon ( micon-rec -- )
  :micon @ DestroyIcon DROP ;

PROC: delete-ownerdraw-data ( iteminfo -- ?)
  DUP 5 CELLS@ ?DUP IF
    clean-submenu 
  THEN
  DUP 2 CELLS@ W: mft_ownerdraw AND IF
    8 CELLS@  DUP del-icon-from-micon
    DUP :mstable @ 0= IF MFREEMEM ELSE DROP THEN
  ELSE
    DROP
  THEN
PROC;

:NONAME ( hmenu -- )
  delete-ownerdraw-data traverse-menu
; TO clean-submenu 

: destroy-menu ( hmenu -- )
  DUP clean-submenu DestroyMenu DROP
;

PROC: del-icon-from-record ( akey nkey micon -- ) 
  del-icon-from-micon 2DROP
PROC;

: del-hash-and-icons ( hash -- )
  del-icon-from-record OVER all-hash del-hash
;

: clear-hash-and-icons ( hash -- )
  del-icon-from-record OVER all-hash clear-hash
;

\ -----------------------------------
\ Системный лоток

: change-icon-in-tray ( icon -- )
  { \ [ #notify ] data }
  DUP TO current-icon
  #notify => data :nSize
  secret-window => data :nHwnd
  0x2 ( есть иконка) => data :nFlags
  => data :nIcon
  data 1 ( nim_modify) Shell_NotifyIconA
  0= " Не могу изменить иконку" ?error
;

: new-icon ( hicon ms -- )
  current-icon ROT change-icon-in-tray
  SWAP ?DUP IF 
    Sleep DROP
    change-icon-in-tray
  ELSE
    DROP
  THEN
;

: animate-icon ( block -- )
  current-icon >R
  DO
    I @ icon-by-name change-icon-in-tray
    I CELL- @ Sleep DROP
  2 CELLS NEGATE +LOOP
  remove-stack-block
  R> change-icon-in-tray
;

: change-tooltip-in-tray ( z -- )
  { \ [ #notify ] data }
  #notify => data :nSize
  secret-window => data :nHwnd
  0x4 ( есть подсказка) => data :nFlags
  data :nTip ZMOVE
  data 1 ( nim_modify) Shell_NotifyIconA
  0= " Не могу изменить подсказку" ?error
;

: popup-info { ztitle zinfo ms \ [ #notifyex ] data -- }
  #notifyex data => :nSize
  secret-window => data :nHwnd
  0x10 ( вызвать информацию) => data :nFlags
  ztitle data :nInfoTitle ZMOVE
  zinfo data :nInfo ZMOVE
  ms => data :nTimeout
  0 ( niif_none) => data :nInfoFlags
  data 1 ( nim_modify) Shell_NotifyIconA
  0= " Не могу вывести информацию" ?error
;

: hide-into-tray
  #notify => HERE :nSize
  secret-window => HERE :nHwnd
  0x7 ( есть все) => HERE :nFlags
  fromtray => HERE :nCallback
  2 instance LoadIconA DUP TO current-icon => HERE :nIcon 
  secret-menu-tooltip HERE :nTip ZMOVE
  HERE 0 ( nim_add) Shell_NotifyIconA
  0= " Не могу добавить иконку в системную панель" ?error
;


: remove-from-tray
  { \ [ #notify ] data }
  #notify => data :nSize
  secret-window => data :nHwnd
  0 => data :nFlags
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
0 VALUE filter
VARIABLE item-icon  item-icon 0!

WINAPI: ShellExecuteExA       SHELL32.DLL
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

: run-program-in-dir { dir prog args \ [ 15 CELLS ] shexinfo ih -- ?}
  shexinfo init->>
  15 CELLS >>
  0x1000C0 >>  \ see_mask_connectnetdrv see_mask_nocloseprocess 
  0 >>	       \ hwnd
  0 >>	       \ open
  prog >>
  args >>
  dir >>
  W: sw_shownormal >> \ winflag
  ^ ih >>      \ place for Insthandle
  shexinfo ShellExecuteExA DROP ;

: run-program ( prog args -- )
  { \ [ MAX_PATH ] dir -- ?}
  OVER dir ZMOVE  dir only-dir
  dir -ROT run-program-in-dir 
;

: run-script { prog args \ [ MAX_PATH ] dir }
  args dir ZMOVE  dir only-dir
  dir prog args run-program-in-dir
;

: winexec DOES> DUP @ SWAP CELL+ @ run-program ;

: append-to-current-menu
  item-icon @ IF
    item-name item-icon @ menu-id current-menu icon-append
  ELSE
    item-name menu-id current-menu append
  THEN
  next-menu-id  item-name 0! ;

\ ---------------------------------------
\ Динамические меню

: n>s ( n -- a #) 
  S>D <# 0 HOLD #S #> ;

: s>n ( a # -- n)
  0. 2SWAP >NUMBER 2DROP DROP
;

: submenu-dir ( hmenu -- z)
  n>s dyn-submenus HASH@R :mpath @ ;

: do-dynitem ( n -- )
  n>s dyn-items HASH@R ?DUP IF
    DUP :mparent @ submenu-dir
    SWAP :mpath @ 0 run-program-in-dir
  THEN
;

: (new-dynitem) ( str path adr -- adr )
  >R
  R@ :mpath !
  R@ :mstr !
  R>
;

: new-dynsubmenu ( str path hmenu -- a )
  #mdynsubmenu SWAP n>s dyn-submenus HASH!R (new-dynitem) ;

: (lenlen) ( z1 z2 -- n) ZLEN SWAP ZLEN + 2+ #mdynsubmenu + ;

: (new-dynitem-with-strings) ( str path adr -- adr)
  >R 
  DUP R@ #mdynsubmenu + DUP >R ZMOVE
  R> R@ :mpath !
  ZLEN 1+ R@ #mdynsubmenu + + DUP >R ZMOVE
  R> R@ :mstr !
  R> ;

: new-dynsubmenu-with-strings ( str path hmenu -- adr )
  >R 2DUP (lenlen) R> n>s dyn-submenus HASH!R (new-dynitem-with-strings) ;

: new-dynitem-with-strings ( str path id -- adr)
  >R 2DUP (lenlen) R> n>s dyn-items HASH!R (new-dynitem-with-strings) ;

\ ---------------------------------------
VARIABLE sptr

: land-str ( a n -- ) >R sptr @ R@ CMOVE R> sptr +! ;

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

: macro-expand-to ( what what# to -- )
  sptr !
  SPARSE...
  expand
  0 sptr @ C!
  sptr 1+!
  ...PARSE
;

: macro-expand-here ( a # -- )
  HERE DUP >R macro-expand-to 
  sptr @ R> - ALLOT ;

: save-string
  BL SKIP 1 PARSE macro-expand-here ;

: ?next ( "name" или name<BL> -- a # / 0)
  PeekChar c: " = IF c: " ELSE BL THEN WORD
  DUP C@ 0= IF DROP 0 EXIT THEN
  COUNT OVER C@ c: " = IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть)
;

: parse-name-and-args
  HERE >R 0 , 0 , \ адреса начала имени и аргументов
  BL SKIP 
  ?next ?DUP IF HERE R@ ! macro-expand-here THEN
  BL SKIP
  1 PARSE ?DUP IF HERE R@ CELL+ ! macro-expand-here ELSE DROP THEN
  RDROP
;

\ -----------------------------------
WINAPI: LoadImageA             USER32.DLL
WINAPI: ExtractIconExA         SHELL32.DLL
WINAPI: ExtractAssociatedIconA SHELL32.DLL
WINAPI: SHGetFileInfoA	       SHELL32.DLL

: extract-small-icon { fn \ small -- icon/0 }
  1 ^ small 0 0 fn ExtractIconExA 1 = IF small ELSE 0 THEN ;

352 == #shfileinfo

: file-info-icon { fn \ [ #shfileinfo ] shfileinfo -- icon/0 }
  0x101 ( shgfi_icon | hgfi_smallicon) #shfileinfo shfileinfo 0 fn SHGetFileInfoA
  IF shfileinfo @ ELSE 0 THEN 
;

: associated-icon { fn \ [ 255 ] fb icon# -- icon/0 }
  fn fb ZMOVE
  ^ icon# fb IMAGE-BASE ExtractAssociatedIconA ;

: ?associated-icon ( fn -- 0)
  DUP file-info-icon ?DUP IF PRESS EXIT THEN
  associated-icon ;

: ?associated-icon-from-a# { a # \ [ MAX_PATH ] s -- 0}
  a # s CZMOVE  s ?associated-icon
;

: file-small-icon ( fn -- 0)
  DUP extract-small-icon ?DUP IF PRESS EXIT THEN
  ?associated-icon ;

: get-associated-icon { fn \ [ 30 ] ext -- icon }
  fn ASCIIZ> S" ." SEARCH PRESS IF
    1+ ext ZMOVE
    ext ASCIIZ> iconlist HASH@N 0= IF
      ( иконки еще нет)
      fn ?associated-icon DUP ext ASCIIZ> ROT iconlist HASH!N
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

: make-directory ( a # -- dynitem )
  HERE 
  item-name DUP HERE ZMOVE ZLEN 1+ ALLOT
  HERE   
  2SWAP macro-expand-here
  \ уберем "\", если есть
  HERE 2- C@ c: \ = IF 0 HERE 2- C! THEN
  CreatePopupMenu DUP >R new-dynsubmenu R> SWAP >R
  R@ :mdynid !
  TRUE  R@ :mstable !
  FALSE R@ :mfilled !
  filter R@ :mfilter !
  ( добавим пункт подменю)
  R@ DUP R> :mdynid @ current-menu append-menu-with-icon
  item-name 0!
  0 TO filter
;

: switch-to-forth ( -- wid)
  GET-CURRENT
  FORTH-WORDLIST SET-CURRENT
  ALSO FORTH
;

: switch-back ( wid -- )
  SET-CURRENT
  PREVIOUS
;

: may-change-menu? ( -- ?)
  current-menu left-menu = current-menu right-menu = OR
  DUP 0= IF 
    " Нельзя переключать меню в середине подменю" err
  THEN
;

VAR memorized-icon
CREATE std-tooltip-text 61 ALLOT

\ -----------------------------------
\ Команды

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
  HERE parse-name-and-args
  item-icon @ IF 
    DROP 
  ELSE 
    2 CELLS+ file-small-icon item-icon !
  THEN
  winexec
  ( добавим пункт меню)
  append-to-current-menu ;

: ФИЛЬТР ( ->bl)
  HERE TO filter
  BL PARSE macro-expand-here 
;

: КАТАЛОГ ( ->eol) 
  BL SKIP 1 PARSE 2DUP make-directory >R
  item-icon @ ?DUP 0= IF ?associated-icon-from-a# ELSE PRESS PRESS THEN
  R> :micon !
;

: ПАПКА 
  [ ALSO keywords CONTEXT ! ]
  КАТАЛОГ 
  [ PREVIOUS ] ;

: МОИ-ДОКУМЕНТЫ ( -- )
 S" [Мои документы]" make-directory
 item-icon @ ?DUP 0= IF " documents" icon-by-name THEN SWAP :micon !
;

: ПРОГРАММЫ ( -- )
  HERE S" [Общие программы]" macro-expand-here
  S" [Программы]" make-directory
  item-icon @ ?DUP 0= IF " programs" icon-by-name THEN
  OVER :micon !
  :mpath2 !
;

: ПРОГРАММА ( ->eol; -- )
  BL SKIP 1 PARSE
  2>R HERE
  <( 2R@ " [Общие программы]\\~S" )> ASCIIZ> macro-expand-here
  <( 2R> " [Программы]\\~S" )> ASCIIZ> make-directory
  item-icon @ ?DUP 0= IF " programs" icon-by-name THEN
  OVER :micon ! :mpath2 !
;

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
  TO current-menu FREEMEM
;

: ФОРТ:
  menu-id S>D <# # # # #> SHEADER
  ALSO FORTH
  ]
  append-to-current-menu
;

: ФОРТ;
  RET, [COMPILE] [ \ ]
  PREVIOUS
; IMMEDIATE

: МАКРО ( ->bl; ->eol)
  GET-CURRENT
  macros SET-CURRENT
  CREATE save-string
  SET-CURRENT
;

: РАСШИРЕНИЯ:
  switch-to-forth
;

: РАСШИРЕНИЯ;
  switch-back
; 

: ДОБАВИТЬ ( ->eol; -- )
  { \ [ 100 ] buf }
  switch-to-forth
  BL SKIP 1 PARSE buf CZMOVE
  buf ASCIIZ> include-file DROP
  switch-back
;

: ИКОНКА ( ->eol)
  1 PARSE get-icon 0 new-icon
;

: ПОДСКАЗКА ( ->eol)
  1 PARSE std-tooltip-text CZMOVE
  std-tooltip-text TO std-tooltip
;

: ЛЕВОЕ-МЕНЮ
  may-change-menu? 0= IF EXIT THEN
  left-menu TO current-menu
;

: ПРАВОЕ-МЕНЮ
  may-change-menu? 0= IF EXIT THEN
  right-menu TO current-menu
;

: ПРАВОЕ-МЕНЮ-ПО-ЛЕВОМУ
  right-menu destroy-menu
  left-menu TO right-menu
;

: ПУНКТ-ПЕРЕЧИТАТЬ 
  " Перечитать настройки" " reload" icon-by-name id-reload current-menu icon-append ;

: ПУНКТ-О-ПРОГРАММЕ
  " О программе..." " mouse" icon-by-name id-about current-menu icon-append ;

: ПУНКТ-ВЫХОД
  " Выход" " exit" icon-by-name  id-exit current-menu icon-append ;

: ЗАПОМНИТЬ ( ->bl/"; -- )
  BL SKIP ?next DUP 0= IF DROP " Пропущено имя файла в команде \'ЗАПОМНИТЬ\'" error THEN
  get-icon TO memorized-icon
;

: КАК ( ->bl/"; --)
  memorized-icon 0= " Пропущена команда \'ЗАПОМНИТЬ\'" ?error 
  BL SKIP ?next ?DUP 0= IF DROP " В команде \'КАК\' отсутствует имя для иконки" error THEN
  memorized-icon -ROT new-named-icon-s
;

SET-CURRENT

\ -----------------------------------
\ Удаленные команды

VAR ch

USER-VALUE str-pool
USER-VALUE str-pool-ptr

WORDLIST TO rcommands

GET-CURRENT
rcommands SET-CURRENT

: " ( ->"; -- z) 
  c: " PARSE str-pool-ptr ESC-CZMOVE
  str-pool-ptr DUP ASCIIZ> + 1+ TO str-pool-ptr ;

: new-icon-by-handle ( hicon ms -- ) new-icon ;
: new-icon ( zicon ms -- ) >R icon-by-name R> new-icon ;
: new-tooltip  change-tooltip-in-tray ;
: make-mouse-blink  " bl-mouse" icon-by-name 500 new-icon ;
: msgbox ( ztitle ztext -- ) msgbox ;
: popup-info ( ztitle ztext ms -- ) popup-info ;
: (( ( -- ) (( ;
: )) ( ... -- block ) )) ;
: animate-icon ( block -- ) animate-icon ;

SET-CURRENT

: execute-rcommand ( a # -- ) 2>R
  str-pool TO str-pool-ptr
  GET-ORDER
  rcommands 1 SET-ORDER
  2R> ['] EVALUATE CATCH IF 2DROP THEN
  SET-ORDER
;

:NONAME { \ [ 100 ] buf }
  800 GETMEM TO str-pool
  BEGIN
    buf ch read-channel execute-rcommand
  AGAIN
; TASK: listen-channel

: open-remote-channel
  init-channels
  " XMENU" create-channel TO ch
  ch 0= IF " Не могу создать канал" msg EXIT THEN
  0 listen-channel START DROP
;

\ -----------------------------------

PROC: del-menuitems ( iteminfo -- ?)
  5 CELLS@ ( submenu) ?DUP IF DestroyMenu DROP THEN 
PROC;

PROC: del-submenu ( key-a key# dynsubmenu -- ?)
  >R 2DROP
  R@ :mstable @ IF
    \ здесь ничего нет
    R@ :mfilled 0!
    R> :mdynid @ DUP del-menuitems traverse-menu
    \ удаляем все пункты из этого меню
    >R
    BEGIN
      W: mf_byposition 0 R@ RemoveMenu
    WHILE
    REPEAT RDROP
    FALSE \ оставить запись
  ELSE
    R> del-icon-from-micon
    TRUE \ удалить эту запись
  THEN 
PROC;

: free-all-dynitems 
  0 TO dyn-id
  del-submenu dyn-submenus del-some-records
  dyn-items clear-hash-and-icons
;

WINAPI: RegOpenKeyA      ADVAPI32.DLL
WINAPI: RegCloseKey      ADVAPI32.DLL
WINAPI: RegQueryValueExA ADVAPI32.DLL

0x80000001 == HKEY_CURRENT_USER
0x80000002 == HKEY_LOCAL_MACHINE

: save-key-value { keyroot value \ hkey valtype size -- }
  ^ hkey " Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
  keyroot RegOpenKeyA DROP
  200 TO size
  ^ size HERE ^ valtype 0 value hkey RegQueryValueExA DROP
  hkey RegCloseKey DROP
  size ALLOT
;

: add-std-macros
  GET-CURRENT
  macros SET-CURRENT
  S" Программы" CREATED
  HKEY_CURRENT_USER ( ) " Programs" save-key-value
  S" Общие программы" CREATED
  HKEY_LOCAL_MACHINE " Common Programs" save-key-value
  S" Мои документы" CREATED
  HKEY_CURRENT_USER ( ) " Personal" save-key-value
  SET-CURRENT
;

: clean-all
  left-menu IF 
    left-menu destroy-menu right-menu destroy-menu 
    iconlist del-hash
    dyn-submenus del-hash-and-icons
    ( очистим словари)
    save-wl commands CELL- 8 CELLS CMOVE
    save-macros macros CELL- 8 CELLS CMOVE
    del-named-icons
    0 TO memorized-icon
  THEN
;

: prepare-all
  clean-all
  small-hash TO iconlist
  small-hash TO dyn-submenus
  small-hash TO dyn-items
  create-named-icons
  start-dir SetCurrentDirectoryA DROP
  CreatePopupMenu ?DUP 0= IF " Не могу создать меню" error THEN TO left-menu
  CreatePopupMenu ?DUP 0= IF " Не могу создать меню" error THEN TO right-menu
  first-menu-id TO menu-id
  \ добавим определение макросов "Мои документы" и "Главное меню"
  add-std-macros
  FORTH DEFINITIONS
  WARNING 0!
;

: read-my-file ( z -- )
  ASCIIZ> 2DUP FILE-EXIST IF 
    include-file
    IF " Ошибка в файле меню" err THEN
  ELSE
    2DROP
  THEN
;

ALSO keywords CONTEXT !

: ?right-menu
  right-menu GetMenuItemCount 0= IF
    ПРАВОЕ-МЕНЮ
    ПУНКТ-ПЕРЕЧИТАТЬ
    ПУНКТ-О-ПРОГРАММЕ
    ПУНКТ-ВЫХОД
  THEN
;

PREVIOUS

WINAPI: GetUserNameA  ADVAPI32.DLL

: read-my-files { \ [ 100 ] user # -- }
  prepare-all
  GET-CURRENT
  GET-ORDER
  commands SET-CURRENT
  keywords 1 SET-ORDER
  left-menu TO current-menu
  filename read-my-file
  90 TO #
  ^ # user GetUserNameA DROP
  user " .cfg" ZAPPEND  user read-my-file
  SET-ORDER
  SET-CURRENT
  ?right-menu
;

\ ----------------------------------------

WINAPI: MessageBoxIndirectA USER32.DLL

: about
  { \ [ 40 ] params -- }
  40 params !
  secret-window params CELL+ !
  instance params 2 CELLS + !
  " Меню для быстрого вызова программ.\n\nЮ. Жиловец, 2004\nhttp://www.forth.org.ru/~yz/xmenu.html\nМышку нарисовала Н. Рымарь."
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

: call-menu { menu \ cmd -- } 
  secret-window SetForegroundWindow DROP
  0 secret-window 0 cursor-pos SWAP 
  (* tpm_leftbutton tpm_rightalign tpm_returncmd *) menu 
  TrackPopupMenu DUP TO cmd
  0 0 W: wm_null secret-window PostMessageA DROP
  CASE
    id-reload OF read-my-files ENDOF
    id-about  OF about ENDOF
    id-exit   OF ( выход)
       0 PostQuitMessage DROP
    ENDOF
    first-menu-id menu-id  <OF< cmd do-command ENDOF
    first-dyn-id  dyn-id   <OF< cmd do-dynitem ENDOF
  DROP 
  END-CASE 
  free-all-dynitems
;

\ ------------------------------------------

WINAPI: GetTextExtentPoint32A GDI32.DLL
WINAPI: GetDC                 USER32.DLL
WINAPI: ReleaseDC             USER32.DLL

: text-width { z window \ dc [ 2 CELLS ] size -- tx ty }
  window GetDC TO dc
  size z ASCIIZ> SWAP dc GetTextExtentPoint32A DROP
  dc window ReleaseDC DROP
  size @ size 1 CELLS@ ;

0 VALUE max-text-width

WINAPI: DrawIconEx	USER32.DLL
WINAPI: DrawTextA	USER32.DLL
WINAPI: GetTextColor    GDI32.DLL
WINAPI: SetTextColor    GDI32.DLL
WINAPI: GetBkColor      GDI32.DLL
WINAPI: SetBkColor	GDI32.DLL
WINAPI: FillRect	USER32.DLL
WINAPI: GetSysColor	USER32.DLL

: draw-menu-item { \ data dc state rx ry rw rh rect textcolor backcolor -- }
  lparam 4 CELLS@ 0xFF AND TO state
  lparam 6 CELLS@ TO dc
  lparam 7 CELLS+ TO rect
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
   icon-left icon-size + icon-right + rect +!
   rw 10 100 */ rect 2 CELLS+ -!
\  icon-size data :mheight @ - 2/ icon-top + ry + 1+
\   rx +
\  dc TextOutA DROP
  (* dt_end_ellipsis dt_noprefix dt_vcenter dt_singleline *) 
  rect data :mstr @ ASCIIZ> SWAP dc DrawTextA DROP
  state W: ods_selected = IF
    \ приводим в порядок контекст устройства
    textcolor dc SetTextColor DROP
    backcolor dc SetBkColor DROP
  THEN ;

\ ---------------------------------------
\ Список файлов и каталогов

WINAPI: SendMessageA   USER32.DLL
WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL

0
CELL     -- :sAttr
2 CELLS  -- :sCreateTime
2 CELLS  -- :sAccessTime
2 CELLS  -- :sWriteTime
CELL     -- :sSizeHigh
CELL     -- :sSizeLow
CELL     -- :sRes1
CELL     -- :sRes2
MAX_PATH -- :sName
16       -- :sShortName
== #find-data

: is-dir? ( fd -- ?)  :sAttr @ 0x10 AND ;

: create-listbox ( -- hwin)
  0 IMAGE-BASE 0 secret-window 0 0 0 0 W: lbs_sort "" " ListBox" 0
  CreateWindowExA 
;

: delete-listbox ( hwin -- ) DestroyWindow DROP ;

: add-to-listbox ( param lb -- )
  >R DUP :mstr @ 0 W: lb_addstring R@ SendMessageA
  W: lb_setitemdata R> SendMessageA DROP ;

: not-in-list? ( z list -- ?)
  >R -1 W: lb_findstringexact R> SendMessageA W: lb_err =
;

WINAPI: lstrcmpi KERNEL32.DLL

: -trail { z zp \ z# zp# -- }
  z ZLEN TO z#  zp ZLEN TO zp#
  z# zp# < IF EXIT THEN
  z z# + zp# - zp lstrcmpi 0= IF 0 z z# + zp# - C! THEN
;

: traverse-directory
  { parent-menu parent-data directory filelist dirlist mask \ h [ #find-data ] fd icon full-path -- }
  fd <( directory mask " ~Z\\~Z" )> FindFirstFileA TO h 
  h -1 = IF EXIT THEN
  BEGIN
    fd :sName C@ c: . <> IF
      <( directory fd :sName " ~Z\\~Z" )>
      DUP TO full-path file-small-icon TO icon
      fd is-dir? IF
        \ такой записи в списке еще нет?
        fd :sName dirlist not-in-list? IF
          fd :sName full-path CreatePopupMenu DUP >R 
          new-dynsubmenu-with-strings R> SWAP >R
          R@ :mdynid !
          FALSE R@ :mstable !
          FALSE R@ :mfilled !
          icon  R@ :micon !
          parent-data :mfilter @ R@ :mfilter !
          R> dirlist add-to-listbox
        THEN
      ELSE
          \ расширение .lnk выкидываем, чтобы не портило вид
        fd :sName " .lnk" -trail
        fd :sName dirlist not-in-list? IF
        \ такой записи в списке еще нет?
          fd :sName full-path dyn-id
          new-dynitem-with-strings >R
          icon  R@ :micon !
          parent-menu R@ :mparent !
          dyn-id R@ :mdynid !
          R> filelist add-to-listbox
          next-dyn-id
        THEN
      THEN
    THEN
    fd h FindNextFileA
  0= UNTIL 
  h FindClose DROP
;

: traverse-directory-with-filters 
  { parent parent-data dir flist dlist filters \ [ MAX_PATH ] filter -- }
  filters PARSE...
  BEGIN
    c: ; PARSE ?DUP
  WHILE
    filter CZMOVE
    parent parent-data dir flist dlist filter traverse-directory
  REPEAT DROP
  ...PARSE
;

: traverse-list { param xt list -- }
  \ xt ( list-item param -- )
  0 0 W: lb_getcount list SendMessageA 0 ?DO
    0 I W: lb_getitemdata list SendMessageA
    param xt EXECUTE
  LOOP ;

: ?filter ( z -- ?) ?DUP 0= IF " *.*" THEN ;

: fill-dynsubmenu
  { hmenu \ submenu flist dlist -- }
  hmenu n>s dyn-submenus HASH@R TO submenu
  \ наше меню?
  submenu 0= IF EXIT THEN
  \ может быть, уже заполнено?
  submenu :mfilled @ IF EXIT THEN
  create-listbox TO flist
  create-listbox TO dlist
  dyn-id 0= IF first-dyn-id TO dyn-id THEN
  hmenu submenu DUP :mpath @
  flist dlist  submenu :mfilter @ ?filter
  traverse-directory-with-filters
  submenu :mpath2 @ IF
    hmenu submenu DUP :mpath2 @
    flist dlist  submenu :mfilter @ ?filter
    traverse-directory-with-filters
  THEN
  \ Перебираем список и заносим в подменю
  \ сначала каталоги
  hmenu (: >R DUP :mdynid @ R> append-menu-with-icon ;) dlist traverse-list
  \ потом файлы
  hmenu (: >R DUP :mdynid @ R> append-with-icon ;) flist traverse-list
  TRUE submenu :mfilled !
  flist delete-listbox
  dlist delete-listbox
;

\ ---------------------------------------
\ Обработчик сообщений

:NONAME
  ( lparam wparam msg hwnd) 
  TO hwnd  TO message  TO wparam  TO lparam
  message CASE

  fromtray OF
    lparam CASE
      W: wm_lbuttondown OF
         left-menu call-menu
      ENDOF
      W: wm_rbuttondown OF
         right-menu call-menu
      ENDOF
    DROP END-CASE  
    0
  ENDOF

  W: wm_measureitem OF
    max-text-width 0= IF 
      " k" hwnd text-width DROP max-filename-size * TO max-text-width
    THEN
    lparam 5 CELLS@ :mstr @ hwnd text-width ( tx ty)
    DUP lparam 5 CELLS@ :mheight !
    icon-size icon-top icon-bottom + + MAX
    SWAP max-text-width MIN  icon-size + icon-left + icon-right +
    \ Windows почему-то добавляет к возвращенной величине еще
    \ где-то 50% непонятно на что и менюшки получаются слишком широкие.
    \ Обманем ее, немного ужав наши требования
    90 100 */ lparam 3 CELLS!
    lparam 4 CELLS!
    TRUE
  ENDOF

  W: wm_drawitem OF
     draw-menu-item
     TRUE
  ENDOF

  W: wm_initmenupopup OF
     wparam fill-dynsubmenu
     0
  ENDOF

  \ Бобик сдох, в смысле Explorer упал и запущен заново
  taskbar-created OF
    hide-into-tray
    0 
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

\ ----------------------------------------

WINAPI: RegisterWindowMessageA USER32.DLL

: RUN
  ['] my-error TO ERROR
\  STARTLOG
  start-dir MAX_PATH GetCurrentDirectoryA DROP
  " TaskbarCreated" RegisterWindowMessageA TO taskbar-created
  create-hidden-window
  create-wordlist
  open-remote-channel
  hide-into-tray
  read-my-files
  MessageLoop
  remove-from-tray
  ch delete-channel
\ все остальное уничтожит сама система
  BYE ;

REMOVE-ALL-CONSTANTS

0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
TRUE TO ?GUI
' RUN MAINX !
RESOURCES: xmenu.fres
S" xmenu.exe" SAVE  
BYE

\ $Id$
\ Andrey Filatkin, af@forth.org.ru

\ WIN console ver 0.6.10
\ For spf3, spf4

\ Based on -
\ CE console ver 0.012 ...
\ 1001bytes, APR-2000
\ and
\ GUI console ver 0.4 ...
\ DAY, Jan-2001

REQUIRE {            ~af\lib\locals.f 
REQUIRE USES         ~af\lib\api-func.f
REQUIRE GetIniString ~af\lib\ini.f
REQUIRE FStream      ~af\lib\stream_io.f
REQUIRE WINCONST     ~af\lib\const.f
REQUIRE SaveTlsIndex ~af\lib\QuickWNDPROC.f
REQUIRE STRUCT:      lib\ext\struct.f
REQUIRE WAIT         wait.f
REQUIRE CASE-INS     lib\ext\caseins.f
CASE-INS OFF
S" adds.f"           INCLUDED
REQUIRE AddToRFL     ~af\lib\rfl.f
REQUIRE STR@         ~ac\lib\str2.f
REQUIRE CASE         lib\ext\case.f
S" debug.f"          INCLUDED

DECIMAL

VECT RunScript

MODULE: GUI-CONSOLE

S" spf4wc.h.f"   INCLUDED  \ constants & data
S" lru.f"        INCLUDED  \ буфер history (last recently used)

: LOWORD ( lpar -- loword ) 0x0FFFF AND ;
: HIWORD ( lpar -- hiword ) 0x10 RSHIFT ;

: SendToCl ( lParam wParam Msg -- u )  clhwnd SendMessage ;
: SendToClVoid  SendToCl DROP ;

: SendToEd ( lParam wParam Msg -- u )  edhwnd SendMessage ;
: SendToEdVoid  SendToEd DROP ;

: SendToTB ( lParam wParam Msg -- u )  TBhwnd SendMessage ;
: SendToTBVoid  SendToTB DROP ;

: GETLINECOUNT ( -- n ) \ возвращает число строк в консоли
  0 0 EM_GETLINECOUNT SendToCl
;
: LastLineIndex ( -- n)
  0  GETLINECOUNT 1-  EM_LINEINDEX SendToCl
;
: CurrentLine ( -- n) \ возвращает номер текущей строки
  0 -1 EM_LINEFROMCHAR SendToCl
;
: CursorHome
  LastLineIndex *promptbuf + DUP EM_SETSEL SendToClVoid
;

\ Console Output
: FlushJetBuf
  JetOut IF
    GETLINECOUNT MAXLIN > IF
        clhwnd LockWindowUpdate DROP
        0          64 EM_LINEINDEX  SendToCl
                    0 EM_SETSEL     SendToClVoid
        0           0 WM_CLEAR      SendToClVoid
        0xFFFE 0xFFFE EM_SETSEL     SendToClVoid
        MAXLIN      0 EM_LINESCROLL SendToClVoid
        NULL LockWindowUpdate DROP
    THEN
    *JetBuf 0 > IF
        0 JetBuf *JetBuf + C!
        JetBuf 0 EM_REPLACESEL SendToClVoid
        0 TO *JetBuf
    THEN
  THEN
;
: charout ( c --)
  JetBuf *JetBuf + C!
  *JetBuf 1+ DUP TO *JetBuf
  OBSIZE 0x10 - >
  IF  \ Buffer Full
     FlushJetBuf
  THEN
;

: charout1 ( c -- )  1 SWAP WM_CHAR SendToClVoid ;

: concr ( c -- )   FlushJetBuf charout1 ;

TRUE VALUE EnableEmit
: EMIT-ON TRUE TO EnableEmit ;
: EMIT-OFF FALSE TO EnableEmit ;

: conemit ( c --)
  EnableEmit IF
    DUP CASE 
      0xA OF DROP ENDOF
      0xD OF concr ENDOF
      JetOut IF charout ELSE charout1 THEN
    ENDCASE
  ELSE
    DROP
  THEN
;
: TYPE-GUI ( addr u -- )
  ANSI><OEM
  2DUP TO-LOG
  H-STDOUT 0 >
  IF  \ Если пишем в файл например...
    WRITE-FILE THROW
  ELSE
    OVER + SWAP
    ?DO
      I C@ conemit
    LOOP
\  FlushJetBuf
  THEN
;

: KEY-GUI ( -- u )
  FlushJetBuf
  LastKey ?DUP IF
  ELSE
    TRUE TO keywait
    KEY_EVENT_GUI ResetEvent DROP
    KEY_EVENT_GUI INFINITE WAIT THROW DROP
    LastKey
    FALSE TO keywait
  THEN
  0 TO LastKey
;

: KEY?-GUI ( -- f )
  LastKey IF TRUE ELSE FALSE THEN
;
' KEY?-GUI ' KEY? REPLACE-WORD

: LastLineChange ( addr -- )
  \ Заменяет последнюю строку текстом - промпт+строка addr 
   ASCIIZ> 1+ promptbuf *promptbuf + SWAP CMOVE
   LastLineIndex DUP
   0 SWAP       EM_LINELENGTH  SendToCl
   OVER + SWAP  EM_SETSEL      SendToClVoid
   promptbuf 0  EM_REPLACESEL  SendToClVoid
;
: GetPrompt \ кладет содержимое последней строки в буфер - промпт
  \ Если строка пустая - выдает стандартный промпт
   C/L promptbuf W!
   promptbuf  GETLINECOUNT 1-  EM_GETLINE SendToCl DUP TO *promptbuf
   0= IF
     prompt> COUNT 2DUP TYPE DUP TO *promptbuf
     promptbuf SWAP MOVE
     FlushJetBuf
   THEN
;

: (VK_RETURN)
  interactive IF
    tib LastLineChange
    tib >in AddToLru
    CON_BUFFER_PREPARED SET-EVENT THROW
  THEN
;

: (VK_RETURN2)
  interactive IF
    EMIT-OFF
    CON_BUFFER_PREPARED SET-EVENT THROW
  THEN
;

: TOtib ( addr u -- )
  DUP TO >in
  tib SWAP CMOVE
  LT @ tib >in + !
;

: VOC-NAME> ( wid -- s ) \ имя списка слов, если он именован
  DUP FORTH-WORDLIST = IF
    DROP " FORTH"
  ELSE
    DUP CELL+ @ DUP IF NIP COUNT " {s}" ELSE DROP " <NONAME>:{n}" THEN
  THEN
;
: SetMenuStatus { idMenu idButton status -- }
  status IF 1 MFS_CHECKED ELSE 0 MFS_UNCHECKED THEN
  MenuItemInfo MENUITEMINFO::fState !
  MenuItemInfo FALSE idButton idMenu SetMenuItemInfo DROP
  idButton TB_CHECKBUTTON SendToTBVoid
;
\ обновляет отображение меню, тулбара и статусбара
: RefreshMenus { \ st curtls -- }
  \ вывод информации в статусбар
  \ берем данные из хипа главного потока
  TlsIndex@ TO curtls
  MainTlsIndex TlsIndex!
  GET-ORDER GET-CURRENT BASE @
  curtls TlsIndex!

  " BASE:{n}  Current:" TO st
  VOC-NAME> st S+
  "   Context:" st S+
  0 ?DO VOC-NAME> st S+ "  " st S+ LOOP
  st STR@ DROP 0 SB_SETTEXT SBhwnd SendMessage DROP
  st STRFREE

  \ обновление переключателей
  {{ MENUITEMINFO
    MenuItemInfo  /SIZE ERASE
    /SIZE         MenuItemInfo cbSize !
    MIIM_STATE    MenuItemInfo fMask !
  }}

  hOptionsMenu cmdCASEINS CASE-INS  @ SetMenuStatus
  hOptionsMenu cmdLOG     H-STDLOG    SetMenuStatus
  hDebugMenu   cmdDBG     DBG-RTime @ SetMenuStatus

  \ обновление debug-меню
  {{ MENUITEMINFO
    Nesting @ 0<> DBG-RTime @ AND IF
      MFS_ENABLED  MenuItemInfo fState !
      1
    ELSE
      MFS_DISABLED MenuItemInfo fState !
      0
    THEN
  }}
  DUP cmdGO   TB_ENABLEBUTTON SendToTBVoid
  DUP cmdSTEP TB_ENABLEBUTTON SendToTBVoid
  DUP cmdOVER TB_ENABLEBUTTON SendToTBVoid
      cmdOUT  TB_ENABLEBUTTON SendToTBVoid
  MenuItemInfo FALSE cmdGO   hDebugMenu SetMenuItemInfo DROP
  MenuItemInfo FALSE cmdSTEP hDebugMenu SetMenuItemInfo DROP
  MenuItemInfo FALSE cmdOVER hDebugMenu SetMenuItemInfo DROP
  MenuItemInfo FALSE cmdOUT  hDebugMenu SetMenuItemInfo DROP
;
\ Console Input
: conaccept
  EnableEmit IF
    FlushJetBuf
    GetPrompt
  ELSE
    EMIT-ON
  THEN
  RefreshMenus
  TRUE TO interactive
  CON_BUFFER_PREPARED ResetEvent DROP
  CON_BUFFER_PREPARED INFINITE WAIT THROW DROP
  >in MIN DUP tib
  2DUP SWAP TO-LOG LT LTL @ TO-LOG
  2SWAP CMOVE
  FALSE TO interactive
  0 TO LastKey
;
: OpenFile ( -- addr u t | f)
  strFile 3 + 260 ERASE
  open_dlg GetOpenFileNameA
  IF
    open_dlg OPENFILENAME::lpstrInitialDir 0!

    strFile DUP DUP ASCIIZ>
    2DUP 3 - SWAP 3 + SWAP AddToRFL
    +
    [CHAR] " OVER C! 1+
    BL OVER C! 1+ >R
    S" INCLUDED" R@ SWAP CMOVE
    R> 8 + SWAP -
    TRUE
  ELSE
    FALSE
  THEN
;
: SaveScript { \ SizeEd Content fid -- }
  \ получаем содержимое окна Script
  0 0 WM_GETTEXTLENGTH SendToEd 1+ DUP TO SizeEd
  ALLOCATE THROW DUP TO Content
  SizeEd WM_GETTEXT SendToEdVoid
  \ открываем файл
  S" spf4wc-script.f" +ModuleDirName W/O CREATE-FILE THROW TO fid
  \ записываем код в файл
  Content SizeEd 1- fid WRITE-FILE THROW
  \ закрываем файл и буфер
  Content FREE THROW
  fid CLOSE-FILE THROW
;
: LoadScript { \ SizeEd Content fid -- }
  S" spf4wc-script.f" +ModuleDirName R/O OPEN-FILE 0= IF
    DUP TO fid
    FILE-SIZE THROW DROP ?DUP IF
      1+ DUP TO SizeEd
      ALLOCATE THROW DUP TO Content
      SizeEd 1- fid READ-FILE 2DROP
      Content 0 WM_SETTEXT SendToEdVoid
      Content FREE THROW
    THEN
    fid CLOSE-FILE THROW
  THEN
;
:NONAME { \ SizeEd Content EdFile fid [ 260 ] TempPath [ 260 ] TempFile -- }
  SaveScript
  \ получаем содержимое окна Script
  0 0 WM_GETTEXTLENGTH SendToEd 1+ DUP TO SizeEd
  ALLOCATE THROW DUP TO Content
  SizeEd WM_GETTEXT SendToEdVoid
  \ создаем временный файл
  TempPath 260 GetTempPath DROP
  TempFile 0 S" spf" DROP TempPath GetTempFileName DROP
  TempFile ASCIIZ> " {s}" TO EdFile
  \ открываем временный файл
  EdFile STR@ W/O OPEN-FILE THROW TO fid
  \ записываем код в файл
  Content SizeEd 1- fid WRITE-FILE THROW
  \ закрываем файл и буфер
  Content FREE THROW
  fid CLOSE-FILE THROW
  \ выполняем код
  EdFile STR@ INCLUDED
  \ подчищаем
  EdFile STR@ DELETE-FILE THROW
  EdFile STRFREE
;
TO RunScript

: W>S DUP 0x8000 AND IF 0x10000 - THEN ;

: ReSize { \ cury [ RECT::/SIZE ] Rect -- }
  \ перерисовываем тулбар
  0 0 TB_AUTOSIZE SendToTBVoid

  \ узнаем высоту тулбара
  Rect 0 TB_GETITEMRECT SendToTBVoid
  Rect RECT::bottom @ 5 + TO tb_height

  \ узнаем высоту статусбара
  Rect SBhwnd GetWindowRect DROP
  Rect RECT::bottom @  Rect RECT::top @  -  TO sb_height

  \ вычисляем высоту дочерних окон
  Myhwnd_height tb_height - split_height - sb_height -
  DUP SplitRatio 100 */ TO cl_height
  cl_height - TO ed_height

  \ обновляем дочерние окна
  tb_height TO cury
  0 cl_height    Myhwnd_width cury  0 clhwnd    MoveWindow DROP
  cury cl_height + TO cury
  0 split_height Myhwnd_width cury  0 splithwnd MoveWindow DROP
  cury split_height + TO cury
  0 ed_height    Myhwnd_width cury  0 edhwnd    MoveWindow DROP
  cury ed_height + TO cury
  0 sb_height    Myhwnd_width cury  0 SBhwnd    MoveWindow DROP

  FALSE 0 Myhwnd InvalidateRect DROP
  Myhwnd UpdateWindow DROP
;
\ рисует перемещаемый горизонтальный сплиттер
\ y - dragY, x - от 0 до Myhwnd_width-1
: DrawSplitter { \ hdc }
  Myhwnd GetDC TO hdc
  R2_NOTXORPEN hdc SetROP2
  0 dragY 0 hdc MoveToEx DROP
  dragY  Myhwnd_width 1-  hdc LineTo DROP
  hdc SetROP2 DROP
  hdc Myhwnd ReleaseDC DROP
;

: BYE-BYE  0 0 WM_DESTROY Myhwnd SendMessage DROP ;


: ClearFavoritesMenu
  hFavoritesMenu GetMenuItemCount 2 ?DO
    MF_BYPOSITION 2 hFavoritesMenu DeleteMenu DROP
  LOOP
;
: FillFavoritesMenu { \ LastFavorit -- }
  1024 ALLOCATE THROW >R
  Spf4wcIni sFavorites R@ 1024 EnumSectionKeys
  IF
    cmdFavorites TO LastFavorit
    R@
    BEGIN
      DUP C@
    WHILE
      DUP
      LastFavorit 1+ DUP TO LastFavorit
      MF_STRING hFavoritesMenu AppendMenu DROP
      ASCIIZ> + 1+
    REPEAT
    DROP
  THEN
  R> FREE THROW
;
: EXECUTEFavorite ( IDItem -- )
  {{ MENUITEMINFO
    MenuItemInfo  /SIZE ERASE
    /SIZE         MenuItemInfo cbSize !
    MIIM_TYPE     MenuItemInfo fMask !
    MFT_STRING    MenuItemInfo fType !
    tib           MenuItemInfo dwTypeData !
    C/L           MenuItemInfo cch !
  }}
  MenuItemInfo FALSE ROT hFavoritesMenu GetMenuItemInfo
  IF
    Spf4wcIni sFavorites tib S" " DROP GetIniString
    ASCIIZ> TOtib (VK_RETURN2)
  THEN
;
: RefreshFavorites
  ClearFavoritesMenu
  FillFavoritesMenu
;

: RR
  R0 @ RP@ - CELL / 2+ 1 DO 
    R0 @ I CELLS - STACK-ADDR. DROP
  LOOP
;

: DbgStep  S" " TOtib (VK_RETURN) ;
: DbgOver  SLIP DbgStep ;
: DbgOut   OUT  DbgStep ;
: DbgGo  -DEBUG DbgStep ;

\ обработка WM_COMMAND
: DoCommand ( wnd_id -- )
  DUP cmdInclude [ cmdFavorites 100 + ] LITERAL WITHIN IF
    DUP cmdFavorites > IF
      EXECUTEFavorite RefreshMenus
    ELSE
      DUP cmdRFL [ cmdRFL 9 + ] LITERAL WITHIN IF
        RFLClick? IF
          " S{''} {s}{''} INCLUDED" DUP >R STR@ TOtib (VK_RETURN)
          R> STRFREE
        THEN
      ELSE
        CASE
          cmdInclude    OF OpenFile IF TOtib (VK_RETURN) THEN ENDOF
          cmdDbgInclude OF OpenFile IF 
                         POSTPONE [DBG EVALUATE POSTPONE DBG] S" " TOtib (VK_RETURN)
                        THEN ENDOF
          cmdRunScript  OF clhwnd SetFocus DROP
                         S" RunScript" TOtib (VK_RETURN)
                        ENDOF
          cmdBYE        OF BYE-BYE   ENDOF
          cmdCUT        OF 0 0 WM_CUT   CurFocus SendMessage DROP ENDOF
          cmdCOPY       OF 0 0 WM_COPY  CurFocus SendMessage DROP ENDOF
          cmdPASTE      OF 0 0 WM_PASTE CurFocus SendMessage DROP ENDOF
          cmdLOG        OF H-STDLOG IF ENDLOG ELSE STARTLOG THEN ENDOF
          cmdCASEINS    OF CASE-INS DUP @ IF OFF ELSE ON THEN ENDOF
          cmdDBG        OF DBG-RTime @ IF -DEBUG ELSE +DEBUG THEN ENDOF
          cmdGO         OF DbgGo   ENDOF
          cmdSTEP       OF DbgStep ENDOF
          cmdOVER       OF DbgOver ENDOF
          cmdOUT        OF DbgOut  ENDOF
          cmdDotS       OF S" DEPTH .SN" TOtib (VK_RETURN) ENDOF
          cmdDotR       OF S" GUI-CONSOLE::RR" TOtib (VK_RETURN) ENDOF
          cmdRefreshFavorites OF RefreshFavorites ENDOF
          cmdHELP       OF S" REQUIRE HELP lib\ext\help.f" TOtib (VK_RETURN) ENDOF
        ENDCASE
      THEN
    THEN
    RefreshMenus
  ELSE
    DROP
  THEN
;

: SaveIni { \ t1 [ RECT::/SIZE ] Rect -- }
  Spf4wcIni sOptions 2>R
  {{ RECT
    Rect Myhwnd GetWindowRect DROP
    2R@ sWindowX
    Rect left   @ TO t1 t1 SetIniInt
    2R@ sWindowWidth
    Rect right  @ t1 -     SetIniInt
    2R@ sWindowY
    Rect top    @ TO t1 t1 SetIniInt
    2R@ sWindowHeight
    Rect bottom @ t1 -     SetIniInt
    2R@ sCaseIns    CASE-INS @ SetIniInt
    2R@ sSplitRatio SplitRatio SetIniInt
    2R> sLog        H-STDLOG 0 <> SetIniInt
  }}
;


:NONAME   { lpar wpar msg hwnd -- }
 msg CASE

   WM_CHAR OF
     keywait IF
       wpar TO LastKey
       KEY_EVENT_GUI SET-EVENT THROW
       0 FALSE
     ELSE
       interactive IF
         wpar CASE
           VK_ESCAPE OF
             S" " DROP LastLineChange
             CursorHome
             0 FALSE
           ENDOF

           VK_BACK OF
             NULL NULL EM_GETSEL SendToCl DUP >R
                LOWORD LastLineIndex *promptbuf + 1+ <
             R> HIWORD LastLineIndex 1- >
             AND IF 0 FALSE
             ELSE TRUE
             THEN
           ENDOF

           NULL NULL EM_GETSEL SendToCl DUP >R
              LOWORD LastLineIndex *promptbuf + <
           R> HIWORD LastLineIndex 1- >
           AND IF CursorHome 0 FALSE
           ELSE TRUE
           THEN
         ENDCASE
       ELSE
         TRUE
       THEN
     THEN
   ENDOF

   WM_KEYDOWN OF
     keywait IF
       0 FALSE
     ELSE
       interactive IF
         wpar CASE
           VK_UP OF
             VK_SHIFT GetKeyState 0x80 AND 0= IF \ если не нажат Shift
               UpLru DROP LastLineChange
               0 FALSE
             ELSE
               TRUE
             THEN
           ENDOF

           VK_DOWN OF 
             VK_SHIFT GetKeyState 0x80 AND 0= IF
               DownLru DROP LastLineChange
               0 FALSE
             ELSE
               TRUE
             THEN
           ENDOF

           VK_RETURN OF   \ Enter
             CurrentLine DUP >R \ текущюю линию
             C/L tib W!
             tib SWAP EM_GETLINE SendToCl TO >in \ в tib
             \ если последняя строка, то удалим из tib'а промпт
             R> GETLINECOUNT 1- =   *promptbuf >in > 0=  AND IF 
               tib *promptbuf +  tib  >in *promptbuf -  DUP TO >in  MOVE
             THEN
             0 tib >in + C!
             (VK_RETURN)
             0 FALSE
           ENDOF
         
           VK_DELETE OF
             *promptbuf 0<> IF
               NULL NULL EM_GETSEL SendToCl DUP >R
                  LOWORD LastLineIndex *promptbuf + <
               R> HIWORD LastLineIndex 3 - >
               AND IF 0 FALSE
               ELSE TRUE
               THEN
             ELSE TRUE
             THEN
           ENDOF

           VK_HOME OF
             VK_SHIFT GetKeyState 0x80 AND 0= IF
               CurrentLine  GETLINECOUNT 1-
               = IF CursorHome 0 FALSE
               ELSE TRUE
               THEN
             ELSE TRUE
             THEN
           ENDOF

           VK_LEFT OF
             VK_SHIFT GetKeyState 0x80 AND 0= IF
               NULL NULL EM_GETSEL SendToCl DUP >R
                  LOWORD LastLineIndex *promptbuf + 1+ <
               R> HIWORD LastLineIndex 1- >
               AND IF CursorHome 0 FALSE
               ELSE TRUE
               THEN
             ELSE TRUE
             THEN
           ENDOF

           VK_RIGHT OF
             VK_SHIFT GetKeyState 0x80 AND 0= IF
               NULL NULL EM_GETSEL SendToCl DUP >R
                  LOWORD LastLineIndex *promptbuf + <
               R> HIWORD LastLineIndex 3 - >
               AND IF CursorHome 0 FALSE
               ELSE TRUE
               THEN
             ELSE TRUE
             THEN
           ENDOF

           TRUE
         ENDCASE
       ELSE
         wpar TO LastKey
         0 FALSE
       THEN
     THEN
   ENDOF

   WM_LBUTTONDOWN OF
     \ если щелкнули мышью на промпте, то надо установить
     \ курсор в конец промпта
     lpar 0 EM_CHARFROMPOS SendToCl LOWORD
     LastLineIndex DUP *promptbuf + WITHIN IF
       CursorHome
       0 FALSE
     ELSE
       TRUE
     THEN
   ENDOF

   WM_CLEAR OF
     0 FALSE
   ENDOF

   WM_CUT OF
     0 FALSE
   ENDOF

   WM_SETFOCUS OF
     hwnd TO CurFocus
     TRUE
   ENDOF

   TRUE
 ENDCASE

 IF
   lpar wpar msg hwnd ClWndProc CallWindowProc
 THEN
;
QUICK_WNDPROC MyClWndProc
 
:NONAME   { lpar wpar msg hwnd -- }
  msg WM_SETFOCUS = IF
    hwnd TO CurFocus
  THEN

  lpar wpar msg hwnd EdWndProc CallWindowProc
;
QUICK_WNDPROC MyEdWndProc

: WMLBUTTONDOWN { hwnd wy \ [ RECT::/SIZE ] rect [ POINT::/SIZE ] point }
  \ захватываем мышь
  hwnd SetCapture DROP
  \ задаем границы, за которые мышь не может выйти
  point POINT::x-point 0!
  point POINT::y-point 0!
  point Myhwnd ClientToScreen DROP
  point POINT::x-point @
  DUP rect RECT::left !
  Myhwnd_width 1+ + rect RECT::right !
  point POINT::y-point @ DUP
  DUP tb_height + rect RECT::top !
  Myhwnd_height 1+ + sb_height - rect RECT::bottom !
  rect ClipCursor DROP
  \ расчитываем начальное смещение
  point POINT::y-point 0!
  point hwnd ClientToScreen DROP
  point POINT::y-point @
  SWAP - split_height 2 / + TO dragStart
  \ рисуем перемещаемый сплиттер
  dragStart wy + TO dragY
  DrawSplitter
;

:NONAME   { lparam wparam msg hwnd -- }
  msg CASE
    WM_LBUTTONDOWN OF \ начало перетаскивания сплиттера
      hwnd lparam HIWORD W>S WMLBUTTONDOWN
      0
    ENDOF
    WM_LBUTTONUP OF \ конец перетаскивания сплиттера
      \ отпускаем мышь
      ReleaseCapture DROP
      \ вычисляем новое положение сплиттера
      dragStart lparam HIWORD W>S + tb_height -
      100
      Myhwnd_height tb_height - split_height - sb_height -
      */
      0 MAX 100 MIN TO SplitRatio
      \ обновляем окно
      ReSize
      0
    ENDOF
    WM_MOUSEMOVE OF \ перетаскивание сплиттера
      wparam MK_LBUTTON AND IF
        DrawSplitter
        dragStart lparam HIWORD W>S + TO dragY
        DrawSplitter
      THEN
      0
    ENDOF
    WM_CAPTURECHANGED OF \ окно потеряло фокус или был ReleaseCapture
      DrawSplitter
      0 ClipCursor DROP
      0
    ENDOF
      lparam wparam msg hwnd SplitWndProc CallWindowProc
      SWAP
  ENDCASE
;
QUICK_WNDPROC MySplitWndProc

:NONAME   { lpar wpar msg hwnd -- }
  msg WM_NOTIFY = IF
    lpar NMHDR::code @ TTN_NEEDTEXTA OVER = SWAP TTN_NEEDTEXTW = OR
    IF
      lpar NMHDR::idFrom @ 200 + lpar TOOLTIPTEXTA::lpszText !
    THEN
    0
  ELSE
    lpar wpar msg hwnd TBWndProc CallWindowProc
  THEN
;
QUICK_WNDPROC MyTBWndProc

:NONAME    { lpar wpar msg hwnd \ hdc -- }
  msg CASE

  WM_COMMAND OF
    wpar LOWORD DoCommand
    0
  ENDOF

  WM_CREATE OF

    InitCommonControls DROP

    TBButtonSize 20 20 20 20 18 TBBUTTONS
    IDB_BITMAP1
    HINST
    13
    ToolBarID
    WS_CHILD WS_VISIBLE OR TBSTYLE_TOOLTIPS OR TBSTYLE_FLAT OR
     WS_CLIPSIBLINGS OR CCS_TOP OR
    hwnd
    CreateToolbarEx TO TBhwnd

    MyTBWndProc GWL_WNDPROC TBhwnd SetWindowLong TO TBWndProc

    SBID hwnd NULL
    WS_CHILD WS_VISIBLE OR SBARS_SIZEGRIP OR CCS_BOTTOM OR WS_CLIPSIBLINGS OR
    CreateStatusWindow TO SBhwnd

    0 HINST ClID hwnd 0 0 0 0
    WS_CHILD WS_VISIBLE OR WS_VSCROLL OR ES_AUTOHSCROLL OR
    WS_HSCROLL OR  ES_MULTILINE OR
    0 S" EDIT" DROP WS_EX_CLIENTEDGE  CreateWindowEx TO clhwnd

    MyClWndProc GWL_WNDPROC clhwnd SetWindowLong TO ClWndProc

    0 HINST EdID hwnd 0 0 0 0
    WS_CHILD WS_VISIBLE OR WS_VSCROLL OR ES_AUTOHSCROLL OR
    WS_HSCROLL OR  ES_MULTILINE OR
    0 S" EDIT" DROP WS_EX_CLIENTEDGE  CreateWindowEx TO edhwnd

    MyEdWndProc GWL_WNDPROC edhwnd SetWindowLong TO EdWndProc

    LoadScript

    WNDCLASS::/SIZE  ALLOCATE THROW TO cwin
    cwin S" STATIC" DROP HINST GetClassInfo DROP
    {{ WNDCLASS
      cwin lpfnWndProc @ TO SplitWndProc
      MySplitWndProc           cwin lpfnWndProc   !
      HINST                    cwin hInstance     !
      IDC_SIZENS 0 LoadCursor  cwin hCursor       !
      S" Splitter" DROP        cwin lpszClassName !
    }}
    cwin  RegisterClass DROP

    0 HINST SplitID hwnd 0 0 0 0
    WS_CHILD WS_VISIBLE OR SS_NOTIFY OR
    cwin WNDCLASS::lpszClassName @ DUP 0  CreateWindowEx TO splithwnd
    cwin FREE THROW

    hwnd GetDC TO hdc
    logfont CreateFontIndirect TO hFont
    1 hFont WM_SETFONT SendToClVoid
    1 hFont WM_SETFONT SendToEdVoid
    hdc hwnd ReleaseDC DROP

    clhwnd TO CurFocus

    Spf4wcIni sOptions
    2DUP sCaseIns     0 GetIniInt CASE-INS SWAP IF ON ELSE OFF THEN
    2DUP sLog         0 GetIniInt IF STARTLOG THEN
         sSplitRatio 75 GetIniInt 0 MAX 100 MIN TO SplitRatio

    MainMenu popstr 2 CELLS + !

    cmdRFL TO IdFirstRFL
    9 TO MaxCountRFL
    5 TO RFLBefore
    hFileMenu TO hRFLMenu
    Spf4wcIni S" RecentFiles" DROP CreateRFL
    RefreshMenu

    0
  ENDOF

  WM_SIZE OF
    lpar LOWORD TO Myhwnd_width
    lpar HIWORD TO Myhwnd_height
    ReSize
    0
  ENDOF

  WM_SETFOCUS OF
    CurFocus SetFocus DROP
    0
  ENDOF

  WM_MENUSELECT OF
    0 >R popstr
    wpar HIWORD DUP MF_POPUP AND SWAP MF_SYSMENU AND 0= AND IF
      lpar MainMenu = IF
        2 CELLS +
        RDROP MainMenu >R
      THEN
    THEN
    SBhwnd HINST R> lpar wpar WM_MENUSELECT MenuHelp DROP
    0
  ENDOF

  WM_DESTROY OF
    SaveIni
    SaveScript
    hFont DeleteObject DROP
    FreeRFL
    0 PostQuitMessage DROP
    0
  ENDOF

    \ default
    lpar wpar msg hwnd DefWindowProc

    \ need for swap with case parameter
    \ and defwinproc parameter
    SWAP
  ENDCASE
;
QUICK_WNDPROC ConsoleWndProc

: MessageLoop
  BEGIN
    0 0 NULL MSG1 GetMessageA
  WHILE
    MSG1 hAccel Myhwnd TranslateAccelerator
    0= IF
      MSG1 TranslateMessage DROP
      MSG1 DispatchMessageA DROP
    THEN
  REPEAT
;


EXPORT


: CON-MAIN
  ModuleName 2DUP + 3 - >R S" ini" R> SWAP MOVE  HEAP-COPY TO Spf4wcIni
  MSG::/SIZE       ALLOCATE THROW TO MSG1
  WNDCLASS::/SIZE  ALLOCATE THROW TO CONS_
  OBSIZE           ALLOCATE THROW TO JetBuf
  C/L              ALLOCATE THROW TO tib
  C/L              ALLOCATE THROW TO promptbuf
  LruLen LruNum *  ALLOCATE THROW TO LruBuf
  MENUITEMINFO::/SIZE  ALLOCATE THROW TO MenuItemInfo

  {{ LOGFONT
    /SIZE   ALLOCATE THROW TO logfont
    RUSSIAN_CHARSET          logfont lfCharSet C!
    FF_MODERN FIXED_PITCH OR logfont lfPitchAndFamily C!
    Spf4wcIni sOptions
    2DUP S" FontName" DROP S" Courier" DROP GetIniString
    ASCIIZ>                  logfont lfFaceName  SWAP MOVE
    S" FontSize" DROP -14 GetIniInt
                             logfont lfHeight !
  }}

 \ fill the class structure
  {{ WNDCLASS
    CS_HREDRAW CS_VREDRAW OR    CONS_ style         !
    ConsoleWndProc              CONS_ lpfnWndProc   !
    0                           CONS_ cbClsExtra    !
    0                           CONS_ cbWndExtra    !
    HINST                       CONS_ hInstance     !
    1 HINST LoadIcon            CONS_ hIcon         !
    IDC_ARROW 0 LoadCursor      CONS_ hCursor       !
    0                           CONS_ hbrBackground !
    0                           CONS_ lpszMenuName  !
    S" SP-FORTH 4.0 win console ver 0.6.10" DROP CONS_ lpszClassName !
  }}
  CONS_  RegisterClass DROP

  IDM_MENU1 HINST LoadMenu TO MainMenu
  0 MainMenu GetSubMenu TO hFileMenu
  2 MainMenu GetSubMenu TO hDebugMenu
  3 MainMenu GetSubMenu TO hFavoritesMenu
  4 MainMenu GetSubMenu TO hOptionsMenu
  FillFavoritesMenu

  0                             \ pointer to window-creation data
  HINST                         \ handle to application instance
  MainMenu                      \ handle to menu, or child-window identifier
  NULL                          \ handle to parent or owner window
  Spf4wcIni sOptions 2>R
  2R@ sWindowHeight 480 GetIniInt \ window height
  2R@ sWindowWidth  640 GetIniInt \ window width
  2R@ sWindowY 60 GetIniInt       \ vertical position
  2R> sWindowX 80 GetIniInt       \ horizontal position
  WS_CAPTION  WS_SYSMENU OR  WS_SIZEBOX OR WS_MINIMIZEBOX OR
  WS_MAXIMIZEBOX OR WS_OVERLAPPED OR \ style
  CONS_ WNDCLASS::lpszClassName @    \ address of window name
  DUP                                \ address of registered class name
  0                                  \ extended window style

  CreateWindowEx TO Myhwnd

  CONS_ FREE THROW

  {{ OPENFILENAME
    /SIZE   ALLOCATE THROW TO open_dlg
    263     ALLOCATE THROW TO strFile
    [CHAR] S strFile C! [CHAR] " strFile 1+ C! BL strFile 2+ C!
    ModuleDirName DUP 1+ ALLOCATE THROW DUP TO strInitialDir SWAP CMOVE

            /SIZE open_dlg lStructSize !
           Myhwnd open_dlg hwndOwner !
        strFilter open_dlg lpstrFilter !
                1 open_dlg nFilterIndex !
      strFile 3 + open_dlg lpstrFile !
              260 open_dlg nMaxFile !
    strInitialDir open_dlg lpstrInitialDir !
    OFN_FILEMUSTEXIST OFN_HIDEREADONLY OR open_dlg Flags !
  }}

  TITLE
  ACCELERATORS_1 HINST LoadAccelerators TO hAccel
  S" lib\win\winconst\windows.const" WINCONST::ADD-CONST-VOC

  SW_SHOW Myhwnd ShowWindow DROP
  Myhwnd UpdateWindow DROP

  START_EVENT SET-EVENT THROW

  MessageLoop

  WINCONST::REMOVE-ALL-CONSTANTS
  Spf4wcIni FREE THROW

  BYE
;

' CON-MAIN TASK: Thread1

: CONSOLE
  TlsIndex@ TO MainTlsIndex
  ['] TYPE-GUI  TO TYPE
  ['] KEY-GUI   TO KEY
  ['] conaccept TO ACCEPT
  ['] OEM>ANSI  TO ANSI><OEM
  CREATE-AUTOEVENT THROW TO KEY_EVENT_GUI
  CREATE-AUTOEVENT THROW TO START_EVENT
  CREATE-AUTOEVENT THROW TO CON_BUFFER_PREPARED

  0 TO JetBuf
  0 TO *JetBuf
  START_EVENT ResetEvent DROP
  0 Thread1 START DROP
  START_EVENT INFINITE WAIT THROW DROP
;

PREVIOUS
CONSTS FREE-WORDLIST

;MODULE

FALSE WARNING !
: BYE
  GUI-CONSOLE::Myhwnd 0<> IF
    GUI-CONSOLE::BYE-BYE
  ELSE
    BYE
  THEN
;
TRUE WARNING !
WINCONST::REMOVE-ALL-CONSTANTS

TRUE TO ?GUI
' CONSOLE MAINX !

S" spf4wc.exe" S" spf4wc.fres " devel\~af\lib\save.f

BYE

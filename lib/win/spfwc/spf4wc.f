\ WIN console ver 0.4
\ Andrey Filatkin
\ Last modified - 18 April 2001
\ Based on -
\ CE console ver 0.012 ...
\ 1001bytes, APR-2000
\ and
\ GUI console ver 0.4 ...
\ DAY, Jan-2001

\ Реакция на клавиатуру:
\ Up-arrow - курсор прыгает на последнюю строку консоли, ее содержимое
\ заменяется на предыдущюю строку из буфера последних введенных команд;
\ Down-arrow - курсор прыгает на последнюю строку консоли, ее содержимое
\ заменяется на следующюю строку из буфера последних введенных команд;
\ Если нажат Shift - up и down работают как в обычном редакторе;
\ Esc - последняя строка очищается:
\ Enter - текущая строка передается accept'у.

REQUIRE WINCONST lib\win\const.f
REQUIRE WAIT     wait.f
REQUIRE {        lib\ext\locals.f 
REQUIRE CASE     lib\ext\case.f

VARIABLE MAINX-WC

MODULE: GUI-CONSOLE \ -------------------------------------------

S" spf4wc.h.f"        INCLUDED  \ Windows constants & data

DECIMAL
 TRUE VALUE JetOut
 0 VALUE EdWndProc
 0 VALUE edhwnd
 0 VALUE Myhwnd
 0 VALUE MainMenu
 0 VALUE JetBuf
 0 VALUE *JetBuf
 0 VALUE hFont
-14 VALUE console_font_height
 0  VALUE console_font_width  \ 0-proportional to console_font_height
 0x64 CONSTANT OBSIZE
0x100 CONSTANT MAXLIN
 0 VALUE tib
 0 VALUE >in
 0 VALUE KEY_EVENT_GUI       \ event на KEY
 0 VALUE START_EVENT         \ event на запуск форт системы
 0 VALUE CON_BUFFER_PREPARED \ event на ACCEPT
 0 VALUE LastKey
 0 VALUE logfont
 0 VALUE MSG1
 0 VALUE CONS_
 0 VALUE params
 0 VALUE open_dlg
 0 VALUE szFile
 CREATE lpstrFilter
        S" *.f (Forth files)" HERE SWAP DUP ALLOT MOVE 0 C,
        S" *.f" HERE SWAP DUP ALLOT MOVE
        0 C, 0 C,
 0 VALUE lpstrInitialDir

  0 VALUE LruBuf              \ буфер history (last recently used)
  8 VALUE LruNum              \ число запоминаемых сообщений lru
255 VALUE LruLen              \ размер одной строки буфера lru
  0 VALUE CurrFromLru


: LruAddr ( n -- addr )
  LruLen * LruBuf +
;

: NextLru
  CurrFromLru
  LruNum 1- = IF 0 TO CurrFromLru
           ELSE CurrFromLru 1+ TO CurrFromLru
           THEN
;
: PrevLru
  CurrFromLru
  0  =     IF LruNum 1- TO CurrFromLru
           ELSE CurrFromLru 1- TO CurrFromLru
           THEN
;

: AddToLru ( addr u )
\ Most recently used
  DUP 0= IF 2DROP EXIT THEN
  CurrFromLru
  LruAddr 2DUP C!
  1+ 2DUP 2>R
  SWAP CMOVE
  2R> + 0 SWAP C!
  NextLru
;

: UpLru ( -- addr u )
   PrevLru
   CurrFromLru
   LruAddr COUNT
;

: DownLru ( -- addr u )
   NextLru
   CurrFromLru
   LruAddr COUNT
;

: LruList
  LruNum 0
  DO
     I LruAddr ?DUP IF COUNT TYPE CR THEN
  LOOP
;


: LOWORD ( lpar -- loword ) 0x0FFFF AND ;
: HIWORD ( lpar -- hiword ) 0x10000 /  ;

: SendToEd
  0 0 ROT edhwnd SendMessageA DROP
;

\ Console Output
: FlushJetBuf
 JetOut IF
   0 0 EM_GETLINECOUNT edhwnd SendMessageA
   MAXLIN > IF
        edhwnd LockWindowUpdate DROP
        0          64 EM_LINEINDEX  edhwnd SendMessageA
                    0 EM_SETSEL     edhwnd SendMessageA DROP
        0           0 WM_CLEAR      edhwnd SendMessageA DROP
        0xFFFE 0xFFFE EM_SETSEL     edhwnd SendMessageA DROP
        MAXLIN      0 EM_LINESCROLL edhwnd SendMessageA DROP
        0 LockWindowUpdate DROP
   THEN
   *JetBuf 0 > IF
        0 JetBuf *JetBuf + C!
        JetBuf 0 EM_REPLACESEL edhwnd SendMessageA DROP
        0 TO *JetBuf
   THEN
 THEN
;

: charout
      JetBuf *JetBuf + C!
      *JetBuf 1+ DUP TO *JetBuf
      OBSIZE 0x10 - >
      IF  \ Buffer Full
         FlushJetBuf
      THEN
;

: charout1
   1 SWAP WM_CHAR edhwnd SendMessageA DROP
;

: concr
   FlushJetBuf charout1
;

: conemit
  DUP CASE 
    0xA OF DROP ENDOF
    0xD OF concr ENDOF
    JetOut IF charout ELSE charout1 THEN
  ENDCASE
;

: TYPE-GUI ( addr u -- )
    H-STDOUT 0 >
    IF TYPE1 EXIT THEN \ Если пишем в файл например...
    2DUP TO-LOG
    ANSI><OEM
    OVER + SWAP
    ?DO
      I C@ conemit
    LOOP
\    FlushJetBuf
;

: KEY-GUI ( -- u )
    FlushJetBuf
    KEY_EVENT_GUI ResetEvent DROP
    KEY_EVENT_GUI INFINITE WAIT THROW DROP
    LastKey
;

\ Console Input
: conaccept
   FlushJetBuf
   CON_BUFFER_PREPARED ResetEvent DROP
   CON_BUFFER_PREPARED INFINITE WAIT THROW DROP
   >in MIN DUP tib 2SWAP CMOVE
;

: LastLineChange ( addr -- )
   0    0 EM_GETLINECOUNT edhwnd SendMessageA 1-
   0 SWAP EM_LINEINDEX    edhwnd SendMessageA DUP
   0 SWAP EM_LINELENGTH   edhwnd SendMessageA
   OVER + SWAP EM_SETSEL  edhwnd SendMessageA DROP
       0  EM_REPLACESEL   edhwnd SendMessageA DROP
;

: (VK_RETURN)
  tib LastLineChange
  tib >in AddToLru
  CON_BUFFER_PREPARED SET-EVENT THROW
;

: TOtib ( addr u -- )
  DUP TO >in
  tib SWAP CMOVE
  LT @ tib >in + !
;

: OpenFile
  szFile 3 + 260 ERASE
  open_dlg GetOpenFileNameA
  IF
    0 open_dlg .lpstrInitialDir !

    szFile DUP DUP ASCIIZ> +
    [CHAR] " OVER C! 1+
    BL OVER C! 1+ >R
    S" INCLUDED" R@ SWAP CMOVE
    R> 8 + SWAP -
    TOtib
    (VK_RETURN)
  THEN
;

: DoCommand
    CASE
      cmdBYE      OF BYE      ENDOF
      cmdOPEN     OF OpenFile ENDOF
      cmdCUT      OF WM_CUT   SendToEd ENDOF
      cmdCOPY     OF WM_COPY  SendToEd ENDOF
      cmdPASTE    OF WM_PASTE SendToEd ENDOF
      cmdHELP     OF S" REQUIRE HELP lib\ext\help.f"
                    TOtib
                    (VK_RETURN)
                  ENDOF
    ENDCASE
;

\ *\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\***
\ **\\\\\ оконная функция \\\\\\\\\\\\\**
\ ***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

:NONAME   { lpar wpar msg hwnd -- }

 msg CASE
   WM_KEYDOWN OF

      wpar CASE
        VK_UP OF
          VK_SHIFT GetKeyState 0x80 AND 0= IF \ если не нажат Shift
            UpLru DROP LastLineChange
            VK_DOWN -> wpar
          THEN
        ENDOF

        VK_DOWN OF 
          VK_SHIFT GetKeyState 0x80 AND 0= IF
            DownLru DROP LastLineChange
          THEN
        ENDOF

        VK_RETURN OF   \ Enter
          0x200 tib W!
          0 -1 EM_LINEFROMCHAR edhwnd SendMessageA \ текущюю линию
          tib SWAP  EM_GETLINE edhwnd SendMessageA TO >in \ в tib
          0 tib >in + C!
          (VK_RETURN)
        ENDOF
      
      ENDCASE

   ENDOF

   WM_CHAR OF
      wpar VK_ESCAPE = IF
        S" " DROP LastLineChange
      THEN
      wpar TO LastKey
      KEY_EVENT_GUI SET-EVENT THROW
   ENDOF
 ENDCASE

 lpar wpar msg hwnd EdWndProc CallWindowProcA
;

WNDPROC: MyEdWndProc

:NONAME    { lpar wpar msg hwnd \ hdc -- }

   msg CASE

   WM_CREATE OF

      0
      HINST
      1
      hwnd
      0 0 0 0
      WS_CHILD WS_VISIBLE OR WS_VSCROLL OR ES_AUTOHSCROLL OR \ WS_BORDER OR
      WS_HSCROLL OR  ES_MULTILINE OR
      0
      S" EDIT" DROP
      0
      CreateWindowExA TO edhwnd
      SW_SHOW edhwnd ShowWindow DROP
      edhwnd UpdateWindow DROP

      ['] MyEdWndProc
      GWL_WNDPROC
      edhwnd
      SetWindowLongA
      TO EdWndProc

      hwnd GetDC -> hdc
      logfont CreateFontIndirectA TO hFont
      1 hFont WM_SETFONT edhwnd SendMessageA DROP
      hdc hwnd ReleaseDC DROP
      0
   ENDOF \ 1

   WM_SIZE OF
       1
       lpar HIWORD
       lpar LOWORD
       0 0
       edhwnd
       MoveWindow DROP
    \   Myhwnd UpdateWindow  DROP
      0
   ENDOF    \ 2

   WM_SETFOCUS OF
      edhwnd SetFocus DROP
      0
   ENDOF   \ 3

(   WM_PAINT  OF
    edhwnd UpdateWindow  DROP
    0
   ENDOF)

   WM_COMMAND  OF
      wpar DoCommand
      0
   ENDOF

   WM_DESTROY OF
      hFont DeleteObject  DROP
      0 PostQuitMessage DROP
      0
   ENDOF

     \ default
     lpar wpar msg hwnd DefWindowProcA

     \ need for swap with case parameter
     \ and defwinproc parameter
     SWAP
 ENDCASE
;

WNDPROC: ConsoleWndProc

: MessageLoop
  BEGIN
    0 0 0 MSG1 GetMessageA
  WHILE
    MSG1 TranslateMessage DROP
    MSG1 DispatchMessageA DROP
  REPEAT
;

: CreateMainMenu ( -- hmenu )
  CreatePopupMenu >R
  S" &Included"     DROP cmdOPEN     MF_STRING R@ AppendMenuA DROP
                     0 0             MF_SEPARATOR R@ AppendMenuA DROP
  S" &BYE"          DROP cmdBYE      MF_STRING R@ AppendMenuA DROP
  S" &File" DROP R> MF_POPUP CreateMenu DUP    >R AppendMenuA DROP

  CreatePopupMenu >R
  S" C&ut"          DROP cmdCUT      MF_STRING R@ AppendMenuA DROP
  S" &Copy"         DROP cmdCOPY     MF_STRING R@ AppendMenuA DROP
  S" &Paste"        DROP cmdPASTE    MF_STRING R@ AppendMenuA DROP
  S" &Edit" DROP R> MF_POPUP R@ AppendMenuA DROP

  CreatePopupMenu >R
  S" &REQUIRE HELP" DROP cmdHELP     MF_STRING R@ AppendMenuA DROP
  S" &Help" DROP R> MF_POPUP R@ AppendMenuA DROP
  R>
;

EXPORT \ ---------------------------------------

: 0ALLOCATE ( u -- addr ior )
   DUP >R ALLOCATE 
   OVER ?DUP IF R@ ERASE THEN
   RDROP
;

: CON-MAIN

  /MSG        0ALLOCATE THROW TO MSG1
  /WNDCLASS   0ALLOCATE THROW TO CONS_
  OBSIZE      0ALLOCATE THROW TO JetBuf
  512         0ALLOCATE THROW TO tib
  LruLen LruNum * 0ALLOCATE THROW TO LruBuf

  /LOGFONT    0ALLOCATE THROW TO logfont
  RUSSIAN_CHARSET     logfont lfCharSet C!
  console_font_height logfont lfHeight !
\  console_font_width  logfont lfWidth  C!
  FF_MODERN FIXED_PITCH OR logfont lfPitchAndFamily C!
  S" Courier" logfont lfFaceName  SWAP CMOVE

  CreateMainMenu TO MainMenu
  MainMenu 0= ABORT" #Can't Create Menu!"

 \ fill the class structure
  CS_HREDRAW CS_VREDRAW OR    CONS_ .style         !
  ['] ConsoleWndProc          CONS_ .lpfnWndProc   !
  0                           CONS_ .cbClsExtra    !
  0                           CONS_ .cbWndExtra    !
  HINST                       CONS_ .hInstance     !
  1 HINST LoadIconA           CONS_ .hIcon         !
  IDC_ARROW 0 LoadCursorA     CONS_ .hCursor       !
  WHITE_BRUSH GetStockObject  CONS_ .hbrBackground !
  0                           CONS_ .lpszMenuName  !
  S" SP-FORTH 4.0 win console ver 0.4" DROP CONS_ .lpszClassName !

  CONS_  RegisterClassA 
  0= ABORT" #Class was not registered!"

  0                             \ pointer to window-creation data
  HINST                         \ handle to application instance
  MainMenu                      \ handle to menu, or child-window identifier
  0                             \ handle to parent or owner window
  400 640                       \ window height, width
  90 90                         \ vertical, horizontal position
  WS_CAPTION  WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR
  WS_MAXIMIZEBOX OR WS_OVERLAPPED OR \ style
                                \ address of window name
  CONS_  .lpszClassName  @  DUP \ address of registered class name
\  0                             \ extended window style
  WS_EX_CLIENTEDGE

  CreateWindowExA
  DUP 0= ABORT" Window not created..."
  TO Myhwnd

  CONS_ FREE THROW

  /OPENFILENAME 0ALLOCATE THROW TO open_dlg
  263           0ALLOCATE THROW TO szFile
  [CHAR] S szFile C! [CHAR] " szFile 1+ C! BL szFile 2+ C!
  ModuleDirName DUP 1+ 0ALLOCATE THROW DUP TO lpstrInitialDir SWAP CMOVE

  /OPENFILENAME open_dlg .lStructSize !
         Myhwnd open_dlg .hwndOwner !
    lpstrFilter open_dlg .lpstrFilter !
              1 open_dlg .nFilterIndex !
     szFile 3 + open_dlg .lpstrFile !
            260 open_dlg .nMaxFile !
lpstrInitialDir open_dlg .lpstrInitialDir !
  OFN_FILEMUSTEXIST OFN_HIDEREADONLY OR open_dlg .Flags !

  SW_SHOW Myhwnd ShowWindow DROP
  Myhwnd UpdateWindow DROP

  TITLE

  START_EVENT SET-EVENT THROW

  MAINX-WC @ ?DUP IF ERR-EXIT THEN

  MessageLoop BYE
;

' CON-MAIN TASK: Thread1

: CONSOLE
 0 -11 SetStdHandle DROP  \ Windows GUI приложение почему-то запускает как
 0 TO H-STDOUT            \ консоль. Соответственно стандартные хэндлы ставит.
 ['] TYPE-GUI  TO TYPE
 ['] KEY-GUI   TO KEY
 ['] conaccept TO ACCEPT
 ['] OEM>ANSI  TO ANSI><OEM
 CREATE-AUTOEVENT THROW TO KEY_EVENT_GUI
 CREATE-AUTOEVENT THROW TO START_EVENT
 CREATE-AUTOEVENT THROW TO CON_BUFFER_PREPARED
 /PARAMS 0ALLOCATE THROW TO params

 0 TO JetBuf
 0 TO *JetBuf
 0 TO CurrFromLru
 START_EVENT ResetEvent DROP
 params Thread1 START  params par.tid !
 START_EVENT INFINITE WAIT THROW DROP
;

;MODULE \ ---------------------------


 TRUE TO ?GUI
 ' CONSOLE MAINX !
 S" spf4wc.exe"  SAVE
 BYE

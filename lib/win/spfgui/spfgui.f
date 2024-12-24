\ .( GUI console ver 0.4 ... )
\ 1001bytes, APR-2000
\ DAY, Jan-2001

REQUIRE {        lib\ext\locals.f
REQUIRE WINCONST lib\win\const.f
REQUIRE CASE     lib\include\control-case.f
REQUIRE /MSG     lib\win\spfgui\dtyps.f

IMAGE-BASE CONSTANT HINST  \ Instance �������� ����������


: CREATE-AUTOEVENT ( -- handle ior )
\ ������� ������ event
  0 0 0 0 CreateEventA DUP
  0= IF GetLastError ELSE 0 THEN
;
: SET-EVENT ( handle -- ior )
\ ����������� ������  event
  SetEvent 0= IF GetLastError ELSE 0 THEN
;

: WAIT ( handle timeout -- flag ior )
\ ���������� ������, ���� ������ ���������� ������ �������
\ (���� �� ����������� ��� ����� ��� ���������� ��.������)
\ � ����� ����� ����� �������
  SWAP WaitForSingleObject DUP WAIT_FAILED =
  IF GetLastError ELSE DUP WAIT_OBJECT_0 = SWAP WAIT_ABANDONED = OR 0 THEN
;

MODULE: GUI-CONSOLE \ -------------------------------------------

     0 VALUE TYPE-MESSAGE        \ Windows message ���� ��� TYPE ������
     0 VALUE ACCEPT-MESSAGE      \ ��������� ��� ��������� �������
     0 VALUE TYPE-A              \ ����� ���� ������
     0 VALUE TYPE-U              \ �� �����
     0 VALUE KEY_EVENT_GUI       \ event �� KEY
     0 VALUE START_EVENT         \ event �� ������ ���� �������
    00 VALUE CON_BUFFER_PREPARED \ event �� ACCEPT
    00 VALUE tib                 \ ���.����� ��� ACCEPT
    00 VALUE >in                 \ ������ ����� ������
     8 CONSTANT TAB-VAL          \ �������� ���������
     0 VALUE Myhwnd   \ hwnd �������� ���� ����������

   255 VALUE bSize               \ ������ ����� ������ � ������ ������
    0  VALUE LruBuf              \ ����� history (last recently used)
     8 VALUE LruNum              \ ����� ������������ ��������� lru
   255 VALUE LruLen              \ ������ ����� ������ ������ lru
   100 VALUE cxClient            \ ���������� client ������� ����
   100 VALUE cyClient
    80 VALUE cxBuffer            \ ������� ������������� ������ (������)
    24 VALUE cyBuffer
     0 VALUE cxChar              \ ������/������ �������
     0 VALUE cyChar
     0 VALUE pBuffer             \ ����� ������
     0 VALUE xCaret              \ ������� ������� x ������� � ������ ������
     0 VALUE yCaret              \ ���������� ��� y

VARIABLE  CurrFromLru

: OBJECT  ( �����  -- ���.��� )
  HERE \ len here
  OVER \ len here len
  ALLOT \ len here
  DUP ROT  ERASE CONSTANT ;


 /MSG        OBJECT MSG1
 /TEXTMETRIC OBJECT tm
 /winclass   OBJECT ����_
 /PS         OBJECT ps
 /PARAMS     OBJECT params

: LruAddr ( n -- addr )
  LruLen * LruBuf +
;

: NextLru
  CurrFromLru @
  LruNum = IF CurrFromLru 0!
           ELSE CurrFromLru 1+!
           THEN
;
: PrevLru
  CurrFromLru @
  0  =     IF LruNum CurrFromLru !
           ELSE -1 CurrFromLru +!
           THEN
;

: AddToLru ( addr u )
\ Most recently used
  DUP 0= IF 2DROP EXIT THEN
  CurrFromLru @
  LruAddr 2DUP C!
  1+ 2DUP 2>R
  SWAP CMOVE
  2R> + 0 SWAP C!
  NextLru
;

: UpLru ( -- addr u )
   PrevLru
   CurrFromLru @
   LruAddr COUNT
;

: LruList
  LruNum 0
  DO
     I LruAddr ?DUP IF COUNT TYPE CR THEN
  LOOP
;

: DownLru ( -- addr u )
   NextLru
   CurrFromLru @
   LruAddr COUNT
;

\ access to heap allocated 2d array pBuffer
: BUFFER ( y x -- addr )
    SWAP cxBuffer * + pBuffer + ;

: LOWORD ( lpar -- loword ) 0xFFFF AND ;
: HIWORD ( lpar -- hiword ) 16 RSHIFT ;

\ *\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\***
\ **\\\\\ ������� ������� \\\\\\\\\\\\\**
\ ***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
0 VALUE lpar
0 VALUE wpar
0 VALUE msg
0 VALUE hwnd
0 VALUE hdc

: OutCurrentLine ( hwnd -- )
      DUP >R GetDC TO  hdc
      \ ��� �� ����� ��������...
      0x4DCD5C 0x2000000 OR hdc SetTextColor DROP
      0 hdc SetBkColor DROP
      SYSTEM_FIXED_FONT GetStockObject  hdc SelectObject  DROP
      cxBuffer xCaret -  yCaret xCaret BUFFER
      yCaret cyChar *  xCaret cxChar * hdc  TextOutA DROP
      cxBuffer yCaret 0 BUFFER yCaret cyChar * 0 hdc TextOutA DROP
      RDROP
;

: IncX ( n -- )
     xCaret + DUP
     0 MAX
     cxBuffer >
     IF
        cxBuffer - TO xCaret
        yCaret 1+ DUP TO yCaret
        cyBuffer = IF 0 TO yCaret THEN
     ELSE TO xCaret
     THEN
;
: SetCaretPos1
      yCaret cyChar * xCaret cxChar * SetCaretPos DROP
;

: OneCharOut { char hwnd -- }
    char
      CASE

        0x08 OF  \ backspace
           xCaret 1- 0 MAX TO xCaret
           yCaret xCaret BUFFER
           DUP 1+ SWAP cxBuffer xCaret - CMOVE
        ENDOF

        0x09 OF  \ tab
        \ ��������� �� ������� TAB-VAL
        xCaret TAB-VAL MOD
        IF
          xCaret TAB-VAL 1- +
          TAB-VAL / TAB-VAL * DUP xCaret - SWAP
        ELSE
          TAB-VAL xCaret TAB-VAL +
        THEN
        xCaret
              ?DO
                BL yCaret I BUFFER C!
              LOOP
              IncX
        ENDOF

        0x0A OF
        ENDOF

        0x0D OF  \ line feed
            0 TO xCaret
            yCaret 1+ TO yCaret
            yCaret cyBuffer >
            IF
               cyBuffer  TO yCaret
               1 0 BUFFER
               0 0 BUFFER
               cxBuffer 1+ cyBuffer 1+ * CMOVE
               cyBuffer 0 BUFFER cxBuffer BL FILL
\               hwnd UpdateWindow DROP
               0 0 cyChar -1 * 0 hwnd ScrollWindow DROP
\               hwnd UpdateWindow DROP
            THEN
        ENDOF

        0x1B OF \  escape
             pBuffer bSize DUP * BL FILL
             0 TO xCaret 0 TO  yCaret
             FALSE 0 hwnd InvalidateRect DROP
        ENDOF

        \ default: character codes
         char 0= IF BL TO char THEN

         yCaret xCaret BUFFER DUP 1+ cxBuffer xCaret - 0 SWAP
         ?DO
           OVER I + C@
           OVER I + C!
         -1 +LOOP 2DROP

         char yCaret xCaret  BUFFER C!
         1 IncX
      ENDCASE
         SetCaretPos1
         hwnd OutCurrentLine
;

:NONAME     ( lpar wpar msg hwnd \ hdc -- )

 TO hwnd TO msg TO wpar TO lpar

   msg CASE

   WM_CREATE OF
      hwnd GetDC TO hdc
      0x4DCD5C 0x2000000 OR hdc SetTextColor DROP
      0 hdc SetBkColor DROP
      SYSTEM_FIXED_FONT GetStockObject  hdc SelectObject  DROP
      tm hdc GetTextMetricsA DROP
      tm tmAveCharWidth @ TO cxChar
      tm tmHeight       @ TO cyChar
      hdc hwnd ReleaseDC DROP
      cxChar cxBuffer 1+ * TO cxClient
      cyChar cyBuffer 1+ * TO cyClient
      0
   ENDOF \ 1

   WM_SIZE OF
    \ obtain window size in pixels
    \   lpar LOWORD TO cxClient
    \   lpar HIWORD TO cyClient
    \ calculate window size in characters
    \   cxClient cxChar / 1 MAX TO cxBuffer
    \   cyClient cyChar / 1- 1 MAX TO cyBuffer
    \ set caret to upper left corner

\     0 TO xCaret
\     0 TO yCaret
     GetFocus hwnd  = IF
          yCaret cyChar *  xCaret cxChar * SetCaretPos DROP
     THEN
     0
   ENDOF    \ 2

   WM_KEYDOWN OF
      wpar CASE
        VK_DELETE OF
           cxBuffer 1- xCaret   \
           DO   yCaret I 1+ BUFFER C@ yCaret I BUFFER C!  LOOP
           BL   yCaret cxBuffer 1- BUFFER C!
           hwnd OutCurrentLine
        ENDOF
        VK_HOME OF
              0 TO xCaret
              SetCaretPos1
        ENDOF

        VK_LEFT OF
              xCaret 1- 0 MAX TO xCaret
              SetCaretPos1
        ENDOF

        VK_RIGHT OF
              xCaret 1+ cxBuffer 1- MIN TO xCaret
              SetCaretPos1
        ENDOF

        VK_END OF
              yCaret 0 BUFFER cxBuffer -TRAILING
              TO xCaret DROP
              SetCaretPos1  
        ENDOF

        VK_UP OF
              yCaret 0 BUFFER cxBuffer BL FILL
              UpLru DUP TO xCaret yCaret 0 BUFFER SWAP CMOVE
              hwnd OutCurrentLine
              SetCaretPos1
        ENDOF

        VK_DOWN OF 
              yCaret 0 BUFFER cxBuffer BL FILL
              DownLru DUP TO xCaret yCaret 0 BUFFER SWAP CMOVE
              hwnd OutCurrentLine
              SetCaretPos1
        ENDOF

        VK_RETURN OF   \ Enter
             yCaret  0 BUFFER tib  xCaret CMOVE
             xCaret TO >in
             tib >in AddToLru
             hwnd HideCaret DROP
             CON_BUFFER_PREPARED SET-EVENT THROW
        ENDOF

        VK_CANCEL OF
             BYE
        ENDOF
                
        [CHAR] C OF
             VK_CONTROL GetKeyState 15 RSHIFT
             IF BYE THEN
        ENDOF
        
     ENDCASE

     0
   ENDOF  \ 5

   WM_CHAR OF

      lpar LOWORD 0
      DO
        wpar hwnd OneCharOut
        KEY_EVENT_GUI SetEvent DROP
      LOOP
      0 
   ENDOF

   TYPE-MESSAGE OF
       TYPE-A TYPE-U
       OVER + SWAP
       ?DO
          I C@ Myhwnd OneCharOut
       LOOP
       0
   ENDOF

   ACCEPT-MESSAGE OF
       hwnd ShowCaret DROP
       0
   ENDOF

   WM_SETFOCUS OF
   \ create and show the caret
      cyChar cxChar 0 hwnd CreateCaret DROP
      yCaret cyChar *  xCaret cxChar * SetCaretPos DROP
      hwnd ShowCaret DROP
      0
   ENDOF   \ 3

   WM_KILLFOCUS OF
   \ hide and destroy the caret
      hwnd HideCaret DROP
      DestroyCaret DROP
      0
   ENDOF   \ 4

   WM_PAINT  OF
     ps hwnd BeginPaint TO  hdc
\     SYSTEM_FIXED_FONT  GetStockObject hdc SelectObject DROP
     cyBuffer 1+ 0 DO
      cxBuffer I 0 BUFFER I cyChar * 0 hdc TextOutA DROP
     LOOP
     ps hwnd EndPaint DROP
     0
   ENDOF

   WM_DESTROY OF
      0 PostQuitMessage
      BYE
   ENDOF
     \ �� ����������
     lpar wpar msg hwnd DefWindowProcA  SWAP
 ENDCASE
;

WNDPROC: ConsoleWndProc

DECIMAL

: MessageLoop
  BEGIN
    0 0 0 MSG1 GetMessageA
  WHILE

    MSG1 TranslateMessage DROP
    MSG1 DispatchMessageA DROP

  REPEAT
;

: ACCEPT-GUI ( addr u1 -- u2 )
    0 0 ACCEPT-MESSAGE Myhwnd SendMessageA DROP
    CON_BUFFER_PREPARED ResetEvent DROP
    CON_BUFFER_PREPARED INFINITE WAIT THROW DROP
    >in MIN TUCK tib SWAP ROT SWAP CMOVE  
;

: TYPE-GUI ( addr u -- )
    H-STDOUT 0 >
    IF TYPE1 EXIT THEN \ ���� ����� � ���� ��������...
    H-STDLOG IF 2DUP TO-LOG THEN
    ANSI><OEM
\ � ����� �������� � �������� ��������� ������ �� ���� �� ������,
\ ��� ������� ����, ������� �� �������� �������� �������� �����������
\ ������ (TYPE) � ���������� �������� ���� ��������� TYPE-MESSAGE
    TO TYPE-U
    TO TYPE-A
    0 0 TYPE-MESSAGE Myhwnd SendMessageA DROP
;

: KEY-GUI ( -- u )
    KEY_EVENT_GUI ResetEvent DROP
    KEY_EVENT_GUI INFINITE WAIT THROW DROP
    yCaret xCaret 1- BUFFER C@
;


EXPORT \ ---------------------------------------


: CE-CON-MAIN
  C/L 2+ ALLOCATE THROW TO tib
  LruLen LruNum *  ALLOCATE THROW TO LruBuf
  bSize DUP *  ALLOCATE THROW TO pBuffer
  pBuffer bSize DUP * BL FILL
  CurrFromLru 0!
  S" TYPE-MESSAGE" DROP RegisterWindowMessageA TO TYPE-MESSAGE
  S" ACCEPT-MESSAGE" DROP RegisterWindowMessageA TO ACCEPT-MESSAGE
 \ ���������� ���������
  /winclass                   ����_ ����.������_������ !
  CS_HREDRAW CS_VREDRAW OR
  CS_OWNDC OR  
                              ����_ ����.�����         !
  [']  ConsoleWndProc         ����_ ����.���������     !
  0                           ����_ ����.�����+        !
  0                           ����_ ����.����+         !
  HINST                       ����_ ����.���������     !
  1 HINST LoadIconA           ����_ ����.����          !
  IDC_ARROW 0 LoadCursorA     ����_ ����.������        !
  BLACK_BRUSH GetStockObject  ����_ ����.���           !
  0                           ����_ ����.����          !
  S" SP-FORTH 4.0 GUI console ver. 0.5" DROP       ����_ ����.���           !
  1 HINST  LoadIconA          ����_ ����.����+         !

  ����_  RegisterClassExA  0= ABORT" #Class was not registered!"

  0                             \ ��������� ��������
  HINST                         \ ��������� ���������� ���������
  0                             \ ��������� ����
  0                             \ ��������� ������������� ����
  0 0                           \ window height, width
  0 0                       \ vertical, horizontal position
  WS_CAPTION  WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR
  WS_MAXIMIZEBOX OR  WS_POPUP OR
  \ WS_VISIBLE OR      \ style
                                \ address of window name
  ����_     ����.���  @  DUP    \ address of registered class name
  0                             \ extended window style

  CreateWindowExA
  DUP 0= ABORT" Window not created..."
  TO Myhwnd

  SM_CYMINIMIZED     GetSystemMetrics
  \ SM_CYBORDER        GetSystemMetrics
  cyClient + 3 + TO cyClient
  0 cyClient cxClient 100 100 hwnd MoveWindow DROP

  Myhwnd UpdateWindow  DROP
  5 Myhwnd ShowWindow  DROP        \ ������� ���� �� �����
  TITLE
  ." Use ESC to clear the window, Ctrl-c or Ctrl-break to exit" CR 
  START_EVENT SET-EVENT
  MessageLoop                      \ ����� � ���� ��������� ���������
;

' CE-CON-MAIN TASK: Thread1

: CECONSOLE
       ['] TYPE-GUI   TO TYPE
       ['] ACCEPT-GUI TO ACCEPT
       ['] KEY-GUI    TO KEY
       ['] OEM>ANSI   TO ANSI><OEM
       CREATE-AUTOEVENT THROW TO CON_BUFFER_PREPARED
       CREATE-AUTOEVENT THROW TO KEY_EVENT_GUI
       CREATE-AUTOEVENT THROW TO START_EVENT
       0 TO SOURCE-ID
       START_EVENT ResetEvent DROP
       params Thread1 START  params par.tid !
       START_EVENT INFINITE WAIT THROW DROP
       OPTIONS ['] SPF-INI ERR-EXIT
       QUIT
;

;MODULE \ ---------------------------

   TRUE TO ?GUI
     ' CECONSOLE MAINX !
         S" spf4gui.exe"  SAVE
     BYE

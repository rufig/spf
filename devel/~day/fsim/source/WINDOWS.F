ALSO FORTH DEFINITIONS PREVIOUS
\ ������ � ������
\ S" font.f" INCLUDED

DECIMAL
WINAPI: UnregisterClassA    USER32.DLL
WINAPI: RegisterClassExA   USER32.DLL
WINAPI: CreateWindowExA  USER32.DLL
WINAPI: SetWindowTextA   USER32.DLL
WINAPI: UpdateWindow     USER32.DLL
WINAPI: BeginPaint       USER32.DLL
WINAPI: EndPaint         USER32.DLL
WINAPI: GetClassNameA    USER32.DLL
WINAPI: TextOutA         GDI32.DLL
WINAPI: SetPixel         GDI32.DLL
WINAPI: DefWindowProcA   USER32.DLL
WINAPI: LoadIconA        USER32.DLL
WINAPI: DrawIcon         USER32.DLL
WINAPI: ShowWindow       USER32.DLL
WINAPI: GetMessageA      USER32.DLL
WINAPI: DispatchMessageA USER32.DLL
WINAPI: TranslateMessage USER32.DLL
WINAPI: PostQuitMessage  USER32.DLL
WINAPI: MoveToEx         GDI32.DLL
WINAPI: LineTo           GDI32.DLL
WINAPI: SelectObject     GDI32.DLL
WINAPI: GetStockObject   GDI32.DLL
WINAPI: SetBkColor       GDI32.DLL
WINAPI: GetSysColor      USER32.DLL
WINAPI: LoadCursorA       USER32.DLL
WINAPI: CreateSolidBrush GDI32.DLL

0   VALUE ��������
600 VALUE wnd.x
400 VALUE wnd.y
100 VALUE wnd.cx
100 VALUE wnd.cy

\ ----------------------------------------------------------------- ���������

HEX
IMAGE-BASE CONSTANT HINST  \ Instance �������� ����������
       0 CONSTANT HCON   \ hwnd �������� ���� ����������
       4 CONSTANT CELL
       2 CONSTANT CS_HREDRAW
       1 CONSTANT CS_VREDRAW
       8 CONSTANT CS_DBLCLKS
      20 CONSTANT CS_OWNDC
 8000000 CONSTANT CW_USEDEFAULT
 00000800 CONSTANT CS_SAVEBITS
  CF0000 CONSTANT WS_OVERLAPPEDWINDOW
10000000 CONSTANT WS_VISIBLE
80000000 CONSTANT WS_POPUP
    6004 CONSTANT WS_95
    7F00 CONSTANT IDI_APPLICATION
    7F04 CONSTANT IDI_ASTERISK
    7F03 CONSTANT IDI_EXCLAMATION
    7F01 CONSTANT IDI_HAND
    7F02 CONSTANT IDI_QUESTION
      0F CONSTANT WM_PAINT
       5 CONSTANT COLOR_WINDOW
00000002 CONSTANT WM_DESTROY
00000001 CONSTANT WM_CREATE
0000000B CONSTANT ANSI_FIXED_FONT
0000000C CONSTANT ANSI_VAR_FONT
00000011 CONSTANT COLOR_GRAYTEXT
00007F00 CONSTANT IDC_ARROW
00000005 CONSTANT WM_SIZE
       
DECIMAL

0
CELL -- MSG.hwnd
CELL -- MSG.message
CELL -- MSG.wParam
CELL -- MSG.lParam
CELL -- MSG.time
CELL -- MSG.pt
CONSTANT /MSG


\ win-��������� ��� ����������� ������ ���� - WNDCLASS
0
CELL -- WNDCLASS.cbSize
CELL -- WNDCLASS.style
CELL -- WNDCLASS.lpfnWndProc
CELL -- WNDCLASS.cbClsExtra
CELL -- WNDCLASS.cbWndExtra
CELL -- WNDCLASS.hInstance
CELL -- WNDCLASS.hIcon
CELL -- WNDCLASS.hCursor
CELL -- WNDCLASS.hbrBackground
CELL -- WNDCLASS.lpszMenuName
CELL -- WNDCLASS.lpszClassName
CELL -- WNDCLASS.hIconSm
CONSTANT /WNDCLASS

: SetWindowText- ( addr u hwnd -- )
  ROT ROT OVER + ( hwnd addr addrend )
  >R R@ @ 0 R@ ! >R
  SWAP SetWindowTextA DROP
  R> R> !
;
: TextOut- ( addr u x y DC -- )
  >R SWAP 2>R SWAP 2R> R> TextOutA DROP
;
\ --------------------------- ��������� ��������� ---------------------

0 VALUE hdc
-1 VALUE �����
0 VALUE MyFont

VECT  ���������
' SetPixel TO ���������

: ��������������� ['] LineTo TO ��������� FALSE TO ����� ;
: ��������������� ['] SetPixel TO ��������� TRUE TO ����� ;

: MoveTo ( hdc x y -- )
   >R 0 ROT ROT R>
   SWAP ROT 
   MoveToEx DROP
;

0 VALUE ����
: ��������������
   hdc Xmin ���� MoveTo
;

: �������������� ( -- )
     ��������������
     ���������� 0
     DO
       ����� IF 0 THEN  \ color
       0 I �������� ������������ ������Y F>DS    \ y
       I DS>F ����������� F* ������X F>DS                       \ x
       hdc                                       \ hdc
       ��������� DROP
     LOOP
;


0 VALUE ��������
3 VALUE �����������

: �����������X
    .E ������Y F--DS TO ����
    hdc Xmin F--DS  MoveTo
    F>DS           \ y
    Xmax           \ x
    hdc
    LineTo DROP
;

: �����������Y
    hdc Xmin Ymin MoveTo
    Ymax 
    Xmin 
    hdc   LineTo DROP
;
: �����������
   �����������X
   �����������Y
;


: ��������X ( -- F: r )
    ��������������� ��������������� F- 
    ����������X 1- DS>F F/ 
;

: ��������Y ( -- F: r )
    ������������� ������������ F- 
    ����������Y 1- DS>F F/
;
: �������������X ( x l -- )
     2DUP 
     ���� SWAP -
     hdc ROT ROT MoveTo
     ���� +
     SWAP hdc LineTo DROP
;
: �������������Y ( y l -- )
     2DUP 
     Xmin SWAP -
     hdc ROT ROT SWAP MoveTo
     Xmin +
     hdc LineTo DROP
;

S" ~day\fsim\source\Cs.f" INCLUDED

0 VALUE Size
0 VALUE Size1

: #M
   ���������������� 0 
   DO  #  LOOP
;

: ����������������� ( F: r D: n -- )
  ���������������� 0 >
  IF
     ���������������� F10X
     F* F>DS DUP ABS 0 <# #M  [CHAR] . HOLD #> Size A>cs
     DUP 0<  >R
     ���������������� F10X
     F>DS / ABS 0 <#  #S R> SIGN #> Size1 A>cs
     Size Size1 cs+!
  ELSE
     
  THEN      
;
: ��������������Y ( F: r D: n -- )
     �����������������
     Size1 COUNT ROT
     Xmin 40 -
     SWAP 6 -       \ x y
     hdc
     TextOut- 
;
: ��������������X ( F: r D: n -- )
     �����������������
     Size1 COUNT ROT 8 -
     ���� 5 +
     hdc
     TextOut- 
;
: �������������X
     ��������X
     ����������X 0 
     DO
       FDUP I DS>F F*
       ��������������� F+ FDUP
       ������X F>DS DUP �����������
       �������������X
       ��������������X
     LOOP
     FDROP
;
: �������������Y
     ��������Y
     ����������Y 0 
     DO
       FDUP I DS>F F* 
       ������������  F+ FDUP
       ������Y F>DS DUP �����������
       �������������Y
       ��������������Y
     LOOP
     FDROP
;

: �������������
     �������������X
     �������������Y
;

: ���������������
    S" ���������� �������:"  30 5 hdc 
    TextOut-
    LengthDescr
    IF
      Descr LengthDescr 150 5 hdc
      TextOut-
    THEN
;
    

: ���������������
    wnd.y 37 - TO Ymax
    wnd.x 40 - TO Xmax
    50 TO Xmin
    Ymax 10 -  TO Ymax
    35 TO Ymin
;

:NONAME { lpar wpar msg hwnd -- }
   msg WM_PAINT =
   IF
     HERE
     hwnd BeginPaint TO hdc
     MyFont hdc SelectObject DROP
     0xFFFFFF
     hdc SetBkColor DROP
     �����������
     ���������������
     ��������������
     �������������
     HERE hwnd EndPaint DROP 0
     EXIT
   THEN
   msg WM_SIZE =
   IF
     lpar
     DUP 16 RSHIFT TO wnd.y
     [ HEX ] 0000FFFF AND [ DECIMAL ]
     TO wnd.x
     ���������������
     0 EXIT
   THEN
   msg WM_DESTROY =
   IF
     0 PostQuitMessage
     BYE
   THEN
   lpar wpar msg hwnd DefWindowProcA
;

WNDPROC: MyWndProc
\ ---------------------------------------------------------------------

CREATE MSG1 28 ALLOT

: MessageLoop
  BEGIN
    0 0 0 MSG1 GetMessageA
  WHILE
    MSG1 TranslateMessage DROP
    MSG1 DispatchMessageA DROP
  REPEAT
;

: RegisterClass- ( class-id -- )
  RegisterClassExA 0= IF TRUE ABORT" ����� �� ��������������!" THEN
;

: CreateWindow- ( class-id -- hwnd )
   >R
   0                   \ address of window create data
   HINST               \ handle of application instance
   0                   \ handle of menu, or child-window identifier
   HCON                \ handle of parent or owner window
   wnd.y \ CW_USEDEFAULT       \ window height   
   wnd.x \ CW_USEDEFAULT       \ window width    
   wnd.cy \ CW_USEDEFAULT       \ vertical position of window
   wnd.cx \ CW_USEDEFAULT       \ horizontal position of window
   WS_VISIBLE WS_OVERLAPPEDWINDOW OR WS_POPUP OR
   0
   R>
   0                                                
   CreateWindowExA DUP 0= ABORT" ���� �� ���������!"
;

HERE DUP /WNDCLASS ALLOT /WNDCLASS ERASE VALUE MyWndClass

: InitClass ( s-addr u addr -- )

  >R  \ ��������� �� ��������� ��� ����������� ������ � Windows
  /WNDCLASS R@ WNDCLASS.cbSize !
  CS_HREDRAW CS_VREDRAW OR 
                             R@ WNDCLASS.style         !
  ['] MyWndProc              R@ WNDCLASS.lpfnWndProc   !
  0                          R@ WNDCLASS.cbClsExtra    !
  0                          R@ WNDCLASS.cbWndExtra    !
  HINST                      R@ WNDCLASS.hInstance     !
  0 0 LoadIconA              R@ WNDCLASS.hIcon         !
  IDC_ARROW 0 LoadCursorA    R@ WNDCLASS.hCursor       !
  0xFFFFFF CreateSolidBrush
                             R@ WNDCLASS.hbrBackground !
  0                          R@ WNDCLASS.lpszMenuName  !
  DROP                       R> WNDCLASS.lpszClassName !
;


: ����������� ( id -- )
  S" DefForthClass" MyWndClass InitClass
  TO ��������
  10 0csCreate TO Size
  10 0csCreate TO Size1
  ANSI_VAR_FONT GetStockObject TO MyFont
  MyWndClass RegisterClass-
  MyWndClass WNDCLASS.lpszClassName @ CreateWindow- >R

  S" ForthSim 0.27. Yakimov Dmitry. Tula State University" R@ SetWindowText-
  R@ UpdateWindow DROP
  5 R> ShowWindow DROP  MessageLoop
  S" DefForthClass" DROP UnregisterClassA
  BYE
;

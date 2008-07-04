\ Альтернативный ATLному способу встраивания браузера (см. browser.f).
\ Использует (вместо atl.dll) маленькую cwebpage.dll by Jeff Glatt
\ См. http://www.codeproject.com/KB/COM/cwebpage.aspx

\ TAB (который у Джефа тоже НЕ работает, как почти у всех :)
\ здесь укрощен тем же способом, что в browser.f, но в другом месте -
\ в стиле Rene Nyffenegger'а.

REQUIRE Window    ~ac/lib/win/window/window.f
REQUIRE {         lib/ext/locals.f
REQUIRE InitAccel ~ac/lib/win/window/accel.f
REQUIRE ComInit   ~ac/lib/win/com/com.f
REQUIRE IID_IOleInPlaceActiveObject ~ac/lib/win/com/ibrowser.f 

WINAPI: DefWindowProcA  USER32.DLL
WINAPI: GetClientRect   USER32.DLL
WINAPI: FillRect        USER32.DLL
WINAPI: PostQuitMessage USER32.DLL

\ функция для превращения системных цветов в RGB может использоваться
\ для автоматической генерации "системной" CSS для браузера
WINAPI: GetSysColor    USER32.DLL

WINAPI: EmbedBrowserObject   cwebpage.dll
WINAPI: UnEmbedBrowserObject cwebpage.dll
WINAPI: ResizeBrowser        cwebpage.dll
WINAPI: DisplayHTMLStr       cwebpage.dll
WINAPI: DisplayHTMLPage      cwebpage.dll
WINAPI: GetWebPtrs           cwebpage.dll

\ ========== код из 96/wnd/dlgtempl.txt (в 98м стал частью Eserv/2) ======

VARIABLE DlgMessageList

: M: ( "WM_..." -- )
  \ определить обработчик сообщения
  HERE
  DlgMessageList @ ,
  ' EXECUTE ,
  HERE 0 , :NONAME SWAP !
  DlgMessageList !
;
: C:
  BASE @ >R HEX
  ' EXECUTE 0 <# #S [CHAR] c HOLD BL HOLD [CHAR] : HOLD #>
  EVALUATE
  R> BASE !
;
: FindMessageToken ( uint=msg -- xt TRUE | FALSE )
  \ найти обработчик сообщения
  { msg }
  DlgMessageList @
  BEGIN
    DUP
  WHILE
    DUP CELL+ @ msg = IF CELL+ CELL+ @ TRUE EXIT THEN
    @
  REPEAT
;

: (DlgWndProc)     ( lparam wparam uint hwnd -- flag )
  \ функция окна диалога

\  vServerIdleWait

  || lparam wparam uint hwnd t sp || (( lparam wparam uint hwnd ))
\  LogMsg @ IF uint . THEN
\  SP@ S0 !
\  hwnd TO Диалог
\  hwnd TO TI-WND
\  DLG-TLS @ TlsIndex!
  uint FindMessageToken
  IF -> t lparam wparam hwnd SP@ -> sp t ['] EXECUTE CATCH DROP sp SP@ - -8 = IF 1 THEN
     ( если обработчик не оставил элементов на стеке, кладем за него "обработано" )
  ELSE
     lparam wparam uint hwnd DefWindowProcA
  THEN
\  vServerRelease
;
\ =========================================================== /96

\ цвета
#define COLOR_WINDOW            5
#define COLOR_APPWORKSPACE      12
#define COLOR_HIGHLIGHT         13

\ от Window
#define WM_GETMINMAXINFO                0x0024 \ первое сообщение окна
#define WM_NCCREATE                     0x0081 \ второе, должно вернуть true, lparam=wcl
#define WM_NCCALCSIZE                   0x0083 \ далее в порядке поступления
#define WM_CREATE                       0x0001

\ от WindowShow
#define WM_SHOWWINDOW                   0x0018
#define WM_WINDOWPOSCHANGING            0x0046 \ два раза, одинаковые
#define WM_ACTIVATEAPP                  0x001C
#define WM_NCACTIVATE                   0x0086
#define WM_ACTIVATE                     0x0006
#define WM_IME_SETCONTEXT               0x0281
#define WM_SETFOCUS                     0x0007
#define WM_NCPAINT                      0x0085
#define WM_ERASEBKGND                   0x0014
#define WM_WINDOWPOSCHANGED             0x0047
#define WM_GETTEXT                      0x000D
#define WM_GETICON                      0x007F \ три раза - 2,0,1
#define WM_SIZE                         0x0005
#define WM_MOVE                         0x0003

\ в MessageLoop (только новые)
\ MSG:0 0 31F 100ACA =0 ???
\ #define WM_KEYDOWN                      0x0100
#define WM_KEYUP                        0x0101
#define WM_CHAR                         0x0102
#define WM_PAINT                        0x000F

\ движение мыши
#define WM_SETCURSOR                    0x0020
#define WM_NCHITTEST                    0x0084
#define WM_MOUSEMOVE                    0x0200
#define WM_NCMOUSEMOVE                  0x00A0
#define WM_NCMOUSELEAVE                 0x02A2
#define WM_IME_NOTIFY                   0x0282
#define WM_KILLFOCUS                    0x0008

\ закрытие окна
#define WM_CAPTURECHANGED               0x0215
#define WM_SYSCOMMAND                   0x0112
\ уже есть #define WM_CLOSE                        0x0010
\ 0x0090 ?
#define WM_DESTROY                      0x0002

\ ---------- обработчики ---------
\ M: WM_NCCREATE ( lparam wparam hwnd -- true )
\    DROP 2DROP TRUE
\ ;
M: WM_ERASEBKGND { lparam wparam hwnd \ [ 4 CELLS ] rect -- true }
   rect hwnd GetClientRect DROP
\   COLOR_HIGHLIGHT 1+
   COLOR_APPWORKSPACE 1+ ( brush)
   rect wparam FillRect DROP
   TRUE
;
M: WM_CREATE ( lparam wparam hwnd -- false )
   NIP NIP EmbedBrowserObject DROP 0
;
M: WM_SIZE ( lparam wparam hwnd -- false )
   NIP SWAP DUP 16 RSHIFT SWAP 0xFFFF AND ROT
   ResizeBrowser DROP 0
;
M: WM_DESTROY ( lparam wparam hwnd -- true )
   NIP NIP UnEmbedBrowserObject DROP
   0 PostQuitMessage DROP
   TRUE
;
M: WM_KEYDOWN { lparam wparam hwnd \ iWebBrowser2 iHTMLDocument2 oleip msg -- true }
   wparam VK_TAB = \ обрабатываем только tab/shift+tab, т.к. только они не работают,
                   \ а остальные сработают вторично, если пустим их в ::TranslateAccelerator
   IF
   \ Утверждается, что этот хак с TAB'ом описан здесь:
   \ http://www.microsoft.com/0499/faq/faq0499.asp
   \ но этот URL MS удалили, приходится списывать у других :)
   ^ iHTMLDocument2 ^ iWebBrowser2 hwnd GetWebPtrs 0= iWebBrowser2 0 <> AND
   IF \ ."  interf:" iHTMLDocument2 . iWebBrowser2 .
      ^ oleip IID_IOleInPlaceActiveObject iWebBrowser2 ::QueryInterface 0= oleip 0 <> AND
      IF
        10 CELLS ALLOCATE THROW -> msg
        hwnd msg !
        WM_KEYDOWN msg CELL+ !
        wparam msg CELL+ CELL+ !
        lparam msg CELL+ CELL+ CELL+ !
        msg oleip ::TranslateAccelerator DROP
        msg FREE THROW
      THEN
   ELSE ( ."  ierr") THEN
   THEN
   TRUE
;
:NONAME { lparam wparam uint hwnd -- x }
  lparam wparam uint hwnd
  (DlgWndProc)
; WNDPROC: AC-WND-PROC

WINAPI: RegisterClassExA USER32.DLL

0
CELL -- wcl.cbSize
CELL -- wcl.style
CELL -- wcl.lpfnWndProc
CELL -- wcl.cbClsExtra
CELL -- wcl.cbWndExtra
CELL -- wcl.hInstance
CELL -- wcl.hIcon
CELL -- wcl.hCursor
CELL -- wcl.hbrBackground
CELL -- wcl.lpszMenuName
CELL -- wcl.lpszClassName
CELL -- wcl.hIconSm
CONSTANT /WCL

: RegisterClass ( wndproc -- class_atom )
  /WCL ALLOCATE THROW >R
  /WCL R@ wcl.cbSize !
       R@ wcl.lpfnWndProc ! 
  0x00400000 R@ wcl.hInstance !
  S" AcLibWindowForthClass" DROP R@ wcl.lpszClassName !
  R> RegisterClassExA
;

: AllMessageLoop { wnd \ mem haccel bro -- }
  InitAccel -> haccel
  haccel 0= ABORT" CreateAcceleratorTable() error"
  /MSG ALLOCATE THROW -> mem
  BEGIN
    0 0 0 mem GetMessageA 0 >
  WHILE
    DEBUG @ IF mem CELL+ @ WM_SYSTIMER <> IF mem 16 DUMP CR THEN THEN
    0 -> bro
    mem @ wnd <> IF mem @ -> bro THEN \ если получатель сообшения не главное окно, то это встроенный браузер

    mem haccel mem @ TranslateAcceleratorA 0=
    IF
      mem CELL+ @ 0x100 0x108 WITHIN bro AND
      IF \ из браузера скопировать родителю, иначе не cработает хак
         \ c акселераторами браузера, см. хак в обработчике WM_KEYDOWN
         mem 3 CELLS + @ mem 2 CELLS + @ mem 1 CELLS + @
         wnd PostMessageA DROP \ SendMessage не помогает
      THEN

      mem TranslateMessage DROP \ превращение keydown в char
      mem DispatchMessageA DROP
    ELSE ( ." accel ") THEN
  REPEAT
  mem FREE THROW
;

: TEST { \ h -- }

  ['] AC-WND-PROC RegisterClass 0 WS_OVERLAPPEDWINDOW 0 Window -> h

  S" http://127.0.0.1:89/index.html" DROP h DisplayHTMLPage 0=
  IF
    h WindowShow
    h AllMessageLoop
  THEN
  h WindowDelete
  BYE
;
TEST

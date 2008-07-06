\ Простейший способ получить полноценный встроенный IE
\ под контролем своего приложения.
\ Основные слова ( urla urlu ) Browser и BrowserThread.
\ Либо NewBrowserWindow+AtlMainLoop. См. примеры в конце.

\ Окончательная победа над клавишей TAB:
\ см.ниже IOleInPlaceActiveObject::TranslateAccelerator
   \ Утверждается, что этот хак с TAB'ом описан здесь:
   \ http://www.microsoft.com/0499/faq/faq0499.asp
   \ но этот URL MS удалили, приходится списывать у других :)
   \ Я только приспособил его к AtlAx.
\ Предлагается к подключению внутрь ~day/wfl.

REQUIRE {                lib/ext/locals.f
REQUIRE Window           ~ac/lib/win/window/window.f
REQUIRE WindowTransp     ~ac/lib/win/window/decor.f
REQUIRE LoadIcon         ~ac/lib/win/window/image.f 
REQUIRE IID_IWebBrowser2 ~ac/lib/win/com/ibrowser.f 
REQUIRE NSTR             ~ac/lib/win/com/variant.f 

\ только для BrowserThread:
REQUIRE STR@             ~ac/lib/str5.f

WINAPI: AtlAxWinInit ATL.dll
WINAPI: AtlAxGetControl ATL.dll

VARIABLE BrTransp \ если не ноль, то задает уровень прозрачности браузеров

: TranslateBrowserAccelerator { mem iWebBrowser2 \ oleip -- flag }
  \ сначала проверим, не является ли клавиша браузерным акселератором
  mem CELL+ @ WM_KEYDOWN =
  IF
    ^ oleip IID_IOleInPlaceActiveObject iWebBrowser2 ::QueryInterface 0= oleip 0 <> AND
    IF
      mem oleip ::TranslateAccelerator \ возвращает 1 для wm_char'ных
                                       \ событий, которые нужно обрабатывать дальше
    ELSE TRUE THEN
  ELSE TRUE THEN
     \ 1, если не акселератор
     \ -1 или если не удалось проверить или вообще не клавиша
     \ т.е. здесь = true, если нужно обработать в обычном порядке
  0= \ инвертируем флаг для имитации TranslateAcceleratorA
;

: WindowGetMessage { mem wnd -- flag }
\ детектируем необходимость завершения цикла MessageLoop
\ без собственной WndProc
  wnd IsWindow
  IF
    0 0 0 mem GetMessageA 0 >
    mem CELL+ @ WM_CLOSE <> AND
    mem CELL+ @ WM_QUIT <> AND
  ELSE FALSE THEN
  DUP IF DEBUG @ IF mem CELL+ @ WM_SYSTIMER <> IF mem 16 DUMP CR THEN THEN THEN
;
: AtlMessageLoop  { wnd iWebBrowser2 \ mem -- }

\ Этот обработчик рассчитан на ОДНО браузерное окно,
\ com-интерфейс которого и хэндл контейнерного окна переданы в качестве 
\ параметров. Но вычитывает он всю очередь потока (0 в GetMessage), т.к.
\ иначе не отображаются дочерние окна - собственно браузер.
\ Если нужно несколько браузерных окон - см. BrowserThread
\ либо AtlMainLoop ниже.

  /MSG ALLOCATE THROW -> mem
  BEGIN
    mem wnd WindowGetMessage
  WHILE
    mem iWebBrowser2 TranslateBrowserAccelerator 0=
    IF
      \ тут можно проверить своим TranslateAccelerator, если есть свои окна
      mem TranslateMessage DROP
      mem DispatchMessageA DROP
    THEN
  REPEAT
  mem FREE THROW
;
: Navigate { addr u bro -- res }
  S" " NSTR   \ headers
  0 VT_ARRAY VT_UI1 OR NVAR \ post data
  S" " NSTR    \ target frame name
  0 VT_I4 NVAR \ flags

  addr u NSTR bro ::Navigate2
;
VARIABLE AtlInitCnt

: BrowserSetIcon1 { addr u h -- }
\ можно в зависимости от урла выбирать иконку, но в stub'е не используется
  1 LoadIconResource16 GCL_HICON h SetClassLongA DROP
;
VECT vBrowserSetIcon ' BrowserSetIcon1 TO vBrowserSetIcon

: BrowserSetTitle1 { addr u h -- }
  addr u
  " SP-Forth: embedded browser ({s})" STR@ DROP h SetWindowTextA DROP
;
VECT vBrowserSetTitle ' BrowserSetTitle1 TO vBrowserSetTitle

: BrowserSetMenu1 { addr u h -- }
;
VECT vBrowserSetMenu ' BrowserSetMenu1 TO vBrowserSetMenu

: BrowserWindow { addr u style parent_hwnd -- hwnd }
\ создать окно браузера и загрузить URL addr u в него.
  AtlInitCnt @ 0= IF AtlAxWinInit 0= IF 0x200A EXIT THEN AtlInitCnt 1+! THEN
  0 0 0 parent_hwnd 0 CW_USEDEFAULT 0 CW_USEDEFAULT style addr S" AtlAxWin" DROP 0
  CreateWindowExA
  DUP addr u ROT vBrowserSetTitle
  DUP addr u ROT vBrowserSetIcon
  DUP addr u ROT vBrowserSetMenu
  BrTransp @ ?DUP IF OVER WindowTransp THEN
;
: BrowserInterface { hwnd \ iu bro -- iwebbrowser2 ior }
  ^ iu hwnd AtlAxGetControl DUP 0=
  IF
    DROP
    ^ bro IID_IWebBrowser2 iu ::QueryInterface DUP 0=
    IF
      bro SWAP
    ELSE ." Can't get browser" DUP . 0 SWAP THEN
  ELSE ." AtlAxGetControl error" DUP . 0 SWAP THEN
;
: Browser { addr u \ h bro -- ior }

  addr u WS_OVERLAPPEDWINDOW 0 BrowserWindow -> h
  h 0= IF 0x200B EXIT THEN

\ PAD bro ::get_AddressBar .
  h BrowserInterface ?DUP IF NIP EXIT THEN -> bro
  h WindowShow
  h bro AtlMessageLoop 0
  h WindowDelete
;
: AtlMainLoop  { hwnd \ mem -- }
\ Этот обработчик подходит в качестве главного оконного цикла.
\ Может обслуживать сразу несколько браузерных окон в одном потоке,
\ находя их контроллеры среди предков.
\ Хэндл "главного окна" hwnd, нужен только для того чтобы узнать,
\ когда можно завершаться...

  /MSG ALLOCATE THROW -> mem
  BEGIN
    hwnd IsWindow
    IF
      0 0 0 mem GetMessageA 0 >
    ELSE FALSE THEN
  WHILE
    mem CELL+ @ WM_KEYDOWN =
    IF
      mem @ GA_ROOT OVER GetAncestor BrowserInterface ( i ior )
      IF DROP TRUE
      ELSE mem SWAP TranslateBrowserAccelerator 0= THEN
    ELSE TRUE THEN

    IF
      mem TranslateMessage DROP
      mem DispatchMessageA DROP
    THEN
  REPEAT
  mem FREE THROW
;

: NewBrowserWindow { addr u \ h -- h }
\ Cоздать браузерное окно c урлом addr u и вернуть его хэндл
\ для дальнейшей обработки. 
\ После создания всех окон можно запустить цикл AtlMainLoop.
  addr u WS_OVERLAPPEDWINDOW 0 BrowserWindow
  DUP WindowShow
;
:NONAME ( url -- ior )
  STR@ ['] Browser CATCH ?DUP IF NIP NIP THEN
; TASK: (BrowserThread)

: BrowserThread ( addr u -- )
\ Запуск браузера в отдельном потоке.
  >STR (BrowserThread) START DROP
;
:NONAME ( url -- ior )
  STR@ ['] Browser CATCH ?DUP IF NIP NIP THEN
  BYE
; TASK: (BrowserMainThread)

: BrowserMainThread ( addr u -- )
\ Запуск браузера в отдельном потоке.
\ При закрытии его окна программа завершится.
  >STR (BrowserMainThread) START DROP
;

\EOF
\ Эти окна не отвлекают основной поток, работают сами по себе.
S" http://127.0.0.1:89/index.html" BrowserThread
S" http://127.0.0.1:89/email/" BrowserThread

\EOF
\ Пример обработки нескольких взаимоподчиненных браузерных окон одним циклом.
: TEST1 { \ h }
  S" http://127.0.0.1:89/index.html" NewBrowserWindow -> h
  S" http://127.0.0.1:89/email/" 0 h BrowserWindow WindowShow
  S" http://127.0.0.1:89/chat/" WS_OVERLAPPEDWINDOW h BrowserWindow WindowShow
  h AtlMainLoop
  ." done"
; TEST1

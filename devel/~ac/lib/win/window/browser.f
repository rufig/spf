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

\ + 07.07.2008 еще раз обработка событий.

REQUIRE {                lib/ext/locals.f
REQUIRE Window           ~ac/lib/win/window/window.f
REQUIRE WindowTransp     ~ac/lib/win/window/decor.f
REQUIRE LoadIcon         ~ac/lib/win/window/image.f 
REQUIRE IID_IWebBrowser2 ~ac/lib/win/com/ibrowser.f 
REQUIRE NSTR             ~ac/lib/win/com/variant.f 
REQUIRE EnumConnectionPoints ~ac/lib/win/com/events.f 
REQUIRE IID_IWebBrowserEvents2 ~ac/lib/win/com/browser_events.f 
REQUIRE IID_IHTMLDocument3 ~ac/lib/win/com/ihtmldocument.f 

\ только для BrowserThread:
REQUIRE STR@             ~ac/lib/str5.f

WINAPI: AtlAxWinInit     ATL.dll
WINAPI: AtlAxGetControl  ATL.dll

VARIABLE BrTransp \ если не ноль, то задает уровень прозрачности браузеров
VARIABLE BrEventsHandler \ если не ноль, то при встраивании браузера подключаем
                         \ обработчик его событий (только в по-поточных Browser)
SPF.IWebBrowserEvents2 BrEventsHandler !

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
  DUP IF DEBUG @ 
         IF mem CELL+ @ WM_SYSTIMER <>
            mem CELL+ @ WM_TIMER <> AND
            IF mem 16 DUMP CR THEN
         THEN
      THEN
;

VECT vPreprocessMessage ( msg -- flag )
\ Возможность "отнять" у окна браузера некоторые события
\ или обработать/транслировать по-своему, до основного обработчика.
\ Если возвращает TRUE, то сообщение считается обработанным и далее не пускается.

VECT vContextMenu ( msg -- ) ' DROP TO vContextMenu

: PreprocessMessage1 ( msg -- flag )
  DUP CELL+ @ WM_RBUTTONUP =
  IF vContextMenu TRUE
  ELSE DROP FALSE THEN
;
' PreprocessMessage1 TO vPreprocessMessage

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
    mem vPreprocessMessage 0=
    IF
      mem iWebBrowser2 TranslateBrowserAccelerator 0=
      IF
        \ тут можно проверить своим TranslateAccelerator, если есть свои окна
        mem TranslateMessage DROP
        mem DispatchMessageA DROP
      THEN
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
  " {s} -- SP-Forth embedded browser" STR@ DROP h SetWindowTextA DROP
;
VECT vBrowserSetTitle ' BrowserSetTitle1 TO vBrowserSetTitle

: BrowserSetMenu1 { addr u h -- }
;
VECT vBrowserSetMenu ' BrowserSetMenu1 TO vBrowserSetMenu

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
USER uBrowserInterface \ для случая "одно окно на поток" здесь копия из объекта
USER uBrowserWindow

/COM_OBJ \ указатель на VTABLE нашего обработчика WebBrowserEvents2, и др.служ.
CELL -- b.BrowserThread
CELL -- b.BrowserWindow
CELL -- b.BrowserInterface
CELL -- b.BrowserMainDocument \ IDispatch, у которого можно спросить IHTMLDocument,2,3
CELL -- b.HtmlDoc2
CELL -- b.HtmlDoc3
\ остальное можно спросить у браузера
CONSTANT /BROWSER

: BrowserWindow { addr u style parent_hwnd \ h bro b -- hwnd }
\ создать окно браузера и загрузить URL addr u в него.
  AtlInitCnt @ 0= IF AtlAxWinInit 0= IF 0x200A EXIT THEN AtlInitCnt 1+! THEN
  0 0 0 parent_hwnd 0 CW_USEDEFAULT 0 CW_USEDEFAULT style addr S" AtlAxWin" DROP 0
  CreateWindowExA -> h
  h 0= IF EXIT THEN

  addr u h vBrowserSetTitle
  addr u h vBrowserSetIcon
  addr u h vBrowserSetMenu
  BrTransp @ ?DUP IF h WindowTransp THEN

  h uBrowserWindow !

\ PAD bro ::get_AddressBar .
  h BrowserInterface ?DUP IF NIP THROW THEN -> bro
  bro uBrowserInterface !

  BrEventsHandler @ ?DUP
  IF /BROWSER SWAP NewComObj -> b \ в обработчиках событий надо как-то окна отличать...
     TlsIndex@ b b.BrowserThread !
     h         b b.BrowserWindow !
     bro       b b.BrowserInterface !
     b IID_IWebBrowserEvents2 bro ConnectInterface \ поэтому создаем отдельные объекты
  THEN
  h
;

: Browser { addr u \ h -- ior }

  addr u WS_OVERLAPPEDWINDOW 0 BrowserWindow -> h
  h 0= IF 0x200B EXIT THEN

  h WindowShow
  h uBrowserInterface @ AtlMessageLoop 0
  h WindowDelete
  0
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

\ Переопределим некоторые обработчики событий от браузера:


GET-CURRENT SPF.IWebBrowserEvents2 SpfClassWid SET-CURRENT

ID: DISPID_DOCUMENTCOMPLETE 259 { urla urlu bro \ obj tls doc doc2 doc3 -- }
    \ =onload
    ." @DocumentComplete! doc=" bro . \ IWebBrowser2 загруженного фрейма
    uOID @ -> obj
    TlsIndex@ -> tls
    obj b.BrowserThread @ TlsIndex!
    bro uBrowserInterface @ = 
    IF \ если документ содержит фреймы, то его DocumentComplete наступает уже после загрузки фреймов
       ^ doc bro ::get_Document DROP \ результат зависит от версии браузера
       doc . CR
       doc obj b.BrowserMainDocument !
       ^ doc3 IID_IHTMLDocument3 doc ::QueryInterface 0= doc3 0 <> AND
       IF doc3 obj b.HtmlDoc3 !
\ пример:
\         ^ elcol S" TITLE" >BSTR doc3 ::getElementsByTagName . elcol . CR
       THEN

       ^ doc2 IID_IHTMLDocument2 doc ::QueryInterface 0= doc2 0 <> AND
       IF doc2 obj b.HtmlDoc2 ! THEN

\       ^ disp IID_DispHTMLDocument doc ::QueryInterface 0= disp 0 <> AND
\       IF ." ---" THEN

       doc2 IF
\ примеры, каждое действие двумя способами:
\         uCRes doc2 ::get_title THROW uCRes @ UASCIIZ> UNICODE> TYPE CR
\         S" title" doc2 CP@ TYPE CR
\         S" New TITLE" >BSTR doc2 ::put_title THROW
\         S" New TITLE" >VBSTR 1 S" title" doc2 CP!
\         S" <H1>TEST</H1>" >SARR doc2 ::write ." wr=" .
\         S" <H1>TEST</H1>" >VBSTR 1 S" write" doc2 CNEXEC .

\ и вперемешку:
\          doc S" title" doc2 CP@
\          " {s} (документ doc={n})" STR@ >BSTR doc2 ::put_title THROW
       THEN
    THEN
    urla urlu TYPE CR
    tls TlsIndex!
;
ID: DISPID_STATUSTEXTCHANGE   102 ( addr u -- )
    ." @StatusTextChange:" TYPE CR
;
ID: DISPID_TITLECHANGE    113  ( addr u -- )
    \ sent when the document title changes
   ." @Title:" 2DUP TYPE CR
    uOID @ b.BrowserWindow @ ?DUP IF vBrowserSetTitle ELSE 2DROP THEN
;
SET-CURRENT

\EOF
\ Эти окна не отвлекают основной поток, работают сами по себе.
\ TRUE COM-DEBUG !
S" http://127.0.0.1:89/index.html" BrowserThread
S" http://127.0.0.1:89/email/" BrowserThread

\EOF
\ Пример обработки нескольких взаимоподчиненных браузерных окон одним циклом.
\ Одно главное окно и два полупрозрачных подчиненных "модальных" перед ним.
: TEST1 { \ h }
  S" http://127.0.0.1:89/index.html" NewBrowserWindow -> h
  128 BrTransp !
  S" http://127.0.0.1:89/email/" 0 h BrowserWindow
     DUP 500 400 ROT WindowSize DUP 90 90 ROT WindowRC WindowShow
  S" http://127.0.0.1:89/chat/" WS_OVERLAPPEDWINDOW h BrowserWindow
     DUP 300 300 ROT WindowSize WindowShow
  h AtlMainLoop
  ." done"
; TEST1

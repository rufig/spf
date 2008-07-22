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

\ + 18.07.2008 по умолчанию подключаемся к клавиатурным и мышиным событиям
\   основной страницы; обработчик ищет слова onkeypress onclick onactivate 
\   ondeactivate onfocusout onhelp onmouseover onmouseout при возникновении
\   соответствующих событий и передает им объект с интерфейсом IHTMLEventObj

\ + 19.07.2008 все-таки добавил subclassing ['] BR-WND-PROC h WindowSubclass
\   т.к. Windows НЕ ставит сообщения WM_CLOSE в очередь, а шлет их напрямую
\   оконной процедуре. А без WM_CLOSE невозможно перехватить/предотвратить/
\   модифицировать закрытие окна (обычно требуется в чат-клиентах).

REQUIRE {                lib/ext/locals.f
REQUIRE COMPARE-U        ~ac/lib/string/compare-u.f
REQUIRE Window           ~ac/lib/win/window/window.f
REQUIRE WindowTransp     ~ac/lib/win/window/decor.f
REQUIRE LoadIcon         ~ac/lib/win/window/image.f 
REQUIRE IID_IWebBrowser2 ~ac/lib/win/com/ibrowser.f 
REQUIRE NSTR             ~ac/lib/win/com/variant.f 
REQUIRE EnumConnectionPoints ~ac/lib/win/com/events.f 
REQUIRE IID_IWebBrowserEvents2 ~ac/lib/win/com/browser_events.f 
REQUIRE IID_IHTMLDocument3 ~ac/lib/win/com/ihtmldocument.f 
REQUIRE IID_IHTMLElementCollection ~ac/lib/win/com/ihtmlelement.f 

\ только для BrowserThread:
REQUIRE STR@             ~ac/lib/str5.f

WINAPI: AtlAxWinInit     ATL.dll
WINAPI: AtlAxGetControl  ATL.dll

VARIABLE BrTransp \ если не ноль, то задает уровень прозрачности браузеров
VARIABLE BrEventsHandler \ если не ноль, то при встраивании браузера подключаем
                         \ обработчик его событий (только в по-поточных Browser)
SPF.IWebBrowserEvents2 BrEventsHandler !
VARIABLE BrCreateHidden \ если не ноль, то окно создается невидимым

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
\ +19.07.2008: собственную WndProc BR-WND-PROC пришлось таки добавить
  wnd IsWindow
  IF
    0 0 0 mem GetMessageA 0 >
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
CELL -- b.HtmlWin2
\ остальное можно спросить у браузера
CONSTANT /BROWSER

VECT vOnClose :NONAME DROP FALSE ; TO vOnClose

: MinimizeOnClose ( wnd -- )
\ при ' MinimizeOnClose TO vOnClose попытка закрытия окна приведет
\ к его сворачиванию (минимизации)
  >R 0 SC_MINIMIZE WM_SYSCOMMAND R> PostMessageA DROP
;

: (BR-WND-PROC1) { lparam wparam msg wnd -- lresult }
  msg WM_NCDESTROY = IF 0 EXIT THEN \ упадет при закрытии, если не обработать

  msg WM_CLOSE = IF wnd vOnClose IF FALSE EXIT THEN THEN

  lparam wparam msg wnd   wnd WindowOrigProc
;
: (BR-WND-PROC)
  ['] (BR-WND-PROC1) CATCH IF 2DROP 2DROP TRUE THEN
;
' (BR-WND-PROC) WNDPROC: BR-WND-PROC

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
  ['] BR-WND-PROC h WindowSubclass

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

  BrCreateHidden @ 0= IF h WindowShow THEN
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
  BrCreateHidden @ 0= IF DUP WindowShow THEN
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

\ вызывается при завершении загрузки основного документа
\ для выполнения произвольной дополнительной обработки
\ oid здесь - указатель на структуру /BROWSER (выше), т.е. экземпляр класса SPF.IWebBrowserEvents2
VECT vOnDocumentComplete ( urla urlu obj -- )
:NONAME DROP 2DROP ; TO vOnDocumentComplete

\ Переопределим некоторые обработчики событий от браузера:

GET-CURRENT SPF.IWebBrowserEvents2 SpfClassWid SET-CURRENT

ID: DISPID_DOCUMENTCOMPLETE 259 { urla urlu bro \ obj tls doc doc2 doc3 win2 elcol el b boo -- }
    \ =onload
    COM-DEBUG @ IF ." @DocumentComplete! doc=" bro . THEN \ IWebBrowser2 загруженного фрейма
    uOID @ -> obj
    TlsIndex@ -> tls
    obj b.BrowserThread @ TlsIndex!
    bro uBrowserInterface @ = 
    IF \ если документ содержит фреймы, то его DocumentComplete наступает уже после загрузки фреймов
       ^ doc bro ::get_Document DROP \ результат зависит от версии браузера
\       doc . CR
       doc obj b.BrowserMainDocument !
       ^ doc3 IID_IHTMLDocument3 doc ::QueryInterface 0= doc3 0 <> AND
       IF doc3 obj b.HtmlDoc3 !
\ примеры:
\         ^ elcol S" DIV" >BSTR doc3 ::getElementsByTagName . elcol . CR
\         ^ len elcol ::get_length . ." len=" len . CR

\ вызываем ::item тремя способами
\         ^ el  0 0 0 VT_I4  0 S" login-form" >BSTR 0 VT_BSTR
\         elcol ::item . el . 
\         3 VT_I4 1 S" item" elcol CNEXEC -> el
\         S" login-form" >VBSTR 1 S" item" elcol CNEXEC -> el
\         el IF
\            ^ el IID_IHTMLElement el ::QueryInterface THROW \ т.к. item возвращает что-то другое
\            S" innerText" el CP@ TYPE CR

\ подключаемся к событиям  выбранного элемента
\            obj VT_DISPATCH 1 S" onkeypress" el CP!
\            0 obj 0 VT_DISPATCH el ::put_onkeypress THROW
\            THEN
\ или всего документа (http://msdn.microsoft.com/en-us/library/ms533051(VS.85).aspx)
            ^ boo obj S" onkeypress" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onclick" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onactivate" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" ondeactivate" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onfocusout" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onhelp" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onmouseover" >BSTR doc3 ::attachEvent THROW
            ^ boo obj S" onmouseout" >BSTR doc3 ::attachEvent THROW

\            ^ boo obj S" onblur" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" oncontextmenu" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" oncopy" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" ondrop" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onerror" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onfocus" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onmouseenter" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onmouseleave" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onsubmit" >BSTR doc3 ::attachEvent THROW \ не приходит
\            ^ boo obj S" onunload" >BSTR doc3 ::attachEvent THROW \ не приходит
       THEN

       ^ doc2 IID_IHTMLDocument2 doc ::QueryInterface 0= doc2 0 <> AND
       IF doc2 obj b.HtmlDoc2 !
          ^ win2 doc2 ::get_parentWindow DROP
          win2 obj b.HtmlWin2 !
       THEN

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
       urla urlu obj vOnDocumentComplete
    THEN
    COM-DEBUG @ IF urla urlu TYPE CR THEN
    tls TlsIndex!
;
ID: DISPID_STATUSTEXTCHANGE   102 ( addr u -- )
    COM-DEBUG @ IF ." @StatusTextChange:" TYPE CR ELSE 2DROP THEN
;
ID: DISPID_TITLECHANGE    113  ( addr u -- )
    \ sent when the document title changes
    COM-DEBUG @ IF ." @Title:" 2DUP TYPE CR THEN
    uOID @ b.BrowserWindow @ ?DUP IF vBrowserSetTitle ELSE 2DROP THEN
;
ID: BR_EVENT 0 ( -- ) { \ e el }
    S" event" uOID @ b.HtmlWin2 @ CP@ -> e
    COM-DEBUG @ IF 
      S" type" e CP@ 
      ." EVENT=" TYPE SPACE
      S" keyCode" e CP@ ." keyCode=" .
      S" srcElement" e CP@ -> el
      ." srcElement=" el .
      S" tagName" el CP@ TYPE SPACE S" id" el CP@ TYPE SPACE S" className" el CP@ TYPE CR
\      S" innerHTML" el CP@ TYPE CR
    THEN
    S" type" e CP@ SFIND IF e SWAP EXECUTE ELSE 2DROP THEN
;
SET-CURRENT

\ полезные утилиты

: GetSiteShortcutIcon { obj \ doc3 elcol len el -- icona iconu }
\ получить url иконки сайта; 
\ возвращает тот url, который в <link rel='shortcut icon'...>,
\ т.е. может быть не полным url'ом
  obj b.HtmlDoc3 @ -> doc3
  ^ elcol S" LINK" >BSTR doc3 ::getElementsByTagName THROW
  ^ len elcol ::get_length THROW
  S" /favicon.ico"
  len 0 ?DO
         ^ el  0 I 0 VT_I4  0 I 0 VT_I4
         elcol ::item THROW
         S" rel" el CP@ S" shortcut icon" COMPARE-U 0=
         IF S" href" el CP@ 2SWAP 2DROP LEAVE
         THEN
  LOOP
;
: GetSiteIconUrl { urla urlu obj -- urla1 urlu1 }
\ получить полный URL иконки fаvicon.ico
  obj GetSiteShortcutIcon
  S" http://" SEARCH 0=
  IF
    OVER C@ [CHAR] / =
    IF S" domain" obj b.HtmlDoc2 @ CP@ " http://{s}{s}"
    ELSE \ относительный путь
      urla urlu CUT-PATH " {s}{s}"
    THEN STR@
  THEN
;
WINAPI: URLDownloadToCacheFileA URLMON.DLL

: LoadFile { addr u \ mem -- filea fileu ior }
\ Удобнее curl'ового GET-FILE тем, что пишет сразу во временный файл,
\ который можно использовать в LoadIcon.
\ И не нужно отдельно заботиться о прокси.
  1000 ALLOCATE THROW -> mem
  0 0 1000 mem addr 0 URLDownloadToCacheFileA ?DUP 
  IF S" " ROT mem FREE THROW EXIT THEN
  mem ASCIIZ> 0
;
: SetIconOnDocumentComplete { urla urlu obj \ fa fu -- }
  urla urlu obj GetSiteIconUrl

  LoadFile 0=
  IF 2DUP -> fu -> fa LoadIcon
     GCL_HICON obj b.BrowserWindow @ SetClassLongA DROP
\     S" title" obj b.HtmlDoc2 @ CP@
\     fa fu AgentIconID IconData hWnd @ TrayIconModify
  ELSE 2DROP THEN
;

\EOF
\ Эти окна не отвлекают основной поток, работают сами по себе.
\ TRUE COM-DEBUG !

' MinimizeOnClose TO vOnClose
' SetIconOnDocumentComplete TO vOnDocumentComplete

: keypress { e -- } \ см. BR_EVENT выше
  S" keyCode" e CP@ ." keyCode=" .
  S" title" uOID @ b.HtmlDoc2 @ CP@ TYPE CR
;
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

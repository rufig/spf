\ Работа с консолью

WINAPI: WriteConsoleOutputCharacterA kernel32.dll

REQUIRE CursorPos@ ~micro/lib/windows/mouse.f
REQUIRE GetDesktopWindow ~micro/lib/windows/window.f
REQUIRE .R lib/include/core-ext.f

: ANIM:
\ ANIM: <name> <символы>
\ создаёт мультик <name>, состоящий из кадров-символов <символы>
\ Используется: SetAnim <name>
\ <name> ( -- addr u )
  CREATE
    0 PARSE
    DUP ,
    HERE
    SWAP
    DUP ALLOT
    MOVE
  DOES>
    DUP @
    SWAP CELL+
    SWAP
;

VECT ANIM ( -- addr u )
\ текущий мультик
VARIABLE NANIM
\ № текущего кадра

: SetAnim
\ SetAnim <name> инициализирует мультик <name>
  ' TO ANIM
  NANIM 0!
;

: ToRange ( size n1 -- n2 )
\ нормализует адресацию n1 в строке с длиной size.
\ 4 3 ToRange \ 3
\ 4 4 ToRange \ 0
\ 4 5 ToRange \ 0
  DUP ROT
  < AND
;

: GetAnimSymbol ( -- с )
\ выдаёт очередной символ текущего мультика
  ANIM SWAP
  NANIM @ + C@ >R
  NANIM @ 1+ ToRange NANIM !
  R>
;

CREATE StatusLine 80 ALLOT
\ строка статуса

: ClearStatusLine
\ очистить строку статуса
  StatusLine 80 BL FILL
;

: PutAnim
\ записать очередной символ мультика в первый символ строки статуса
  GetAnimSymbol StatusLine C!
;

: PutMouseCoord
\ записать координаты мыши в строку статуса
  BASE @
    CursorPos@
    DECIMAL
    S>D <# #S #> StatusLine 2 + SWAP MOVE
    S>D <# #S #> StatusLine 6 + SWAP MOVE
  BASE !
;

: FillStatusLine
\ заполнить строку статуса
  ClearStatusLine
  PutAnim
  PutMouseCoord
;

: ShowStatusLine
\ отобразить строку статуса
  FillStatusLine
    0 SP@
    0
    80
    StatusLine
    H-STDOUT
  WriteConsoleOutputCharacterA
  2DROP
;

\ Следующие слова предназначены для работы с Оконным Навигатором

VARIABLE CurrentWindow
\ хэндл текущего окна

20 VALUE Lines
\ число непрерывно выводимых строк.
\ точнее, это число CR-ов, выполняемых без остановки
VARIABLE LinesLeft
\ число строк, который ещё будут выведены без остановки

: CR
\ новый CR, с запросом на продолжение вывода
  CR
  LinesLeft @ 1- DUP LinesLeft !
  0< IF
    Lines LinesLeft !
    ." -- more -- space-abort" CR KEY BL = ABORT" Aborted"
  THEN
;

: ShowWindowInfo ( hwnd -- )
\ показать информацию об окне
  DUP ." hwnd=" 4 .R
  DUP GetWindowOwner ." ; owner=" 4 .R
  DUP WindowRect@
  ." ; coord=(" 4 .R ." ," 4 .R ." ;" 4 .R ." ," 4 .R ." )" CR
  DUP GetWindowText ."            text='" ANSI>OEM TYPE ." '" CR
      GetWindowClass ."           class='" ANSI>OEM TYPE ." '" CR
;

: cw
\ показать информацию о текущем окне
  CurrentWindow @ ShowWindowInfo CR
;

: MyOk
\ новый OK (в SPF выполняется перед запросом новой строки с консоли)
  CR
  ." Current window: "
  cw
  Lines LinesLeft !
;

: childs
\ вывод списка дочерних окон текущего окна
  CurrentWindow @
  GetWindowChild
  DUP IF
    BEGIN
      DUP ShowWindowInfo CR
      GetWindowNext ?DUP
    0= UNTIL
  ELSE
    ." no childs"
  THEN
  CR
;

: nc ( hwnd -- )
\ задание текущего окна
  CurrentWindow !
;

: ..
\ перемещение к окну-владельцу текущего
  CurrentWindow @ GetWindowOwner CurrentWindow !
;

\ default config =================================

ANIM: ANIM1  ░▒▓█▓▒░
ANIM: ANIM2 ·∙O∙
SetAnim ANIM1
20 TO Lines

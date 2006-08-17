WARNING 0!
WINAPI: ReadConsoleA kernel32.dll
WINAPI: GetConsoleMode kernel32.dll
WINAPI: SetConsoleMode kernel32.dll
WINAPI: GetConsoleScreenBufferInfo KERNEL32.DLL
WINAPI: SetConsoleCursorPosition KERNEL32.DLL
WINAPI: GetConsoleCursorInfo KERNEL32.DLL
WINAPI: SetConsoleCursorInfo KERNEL32.DLL

REQUIRE CASE LIB\EXT\CASE.F
S" ~MICRO\LIB\KEY\KEYS.F" INCLUDED
\ REQUIRE VK_END ~MICRO\LIB\CONST\VK_.F
REQUIRE WINCONST lib/win/const.f

: COORD ( x y -- COORD )
  65536 * +
;

: GotoXY ( x y -- )
\ установка координаты курсора в консоли.
  COORD H-STDOUT SetConsoleCursorPosition ERR THROW
;

CREATE CONSOLE_SCREEN_BUFFER_INFO 22 ALLOT

: WhereXY ( -- x y )
\ определение координаты курсора
  CONSOLE_SCREEN_BUFFER_INFO H-STDOUT GetConsoleScreenBufferInfo DROP
  CONSOLE_SCREEN_BUFFER_INFO 4 + DUP W@ SWAP 2+ W@ ;

CREATE CONSOLE_CURSOR_INFO 8 ALLOT

: HideCursor
\ Спрятать курсор
  CONSOLE_CURSOR_INFO H-STDIN STREAM-FILE GetConsoleCursorInfo DROP
  0 CONSOLE_CURSOR_INFO 4 + !
  CONSOLE_CURSOR_INFO H-STDIN STREAM-FILE SetConsoleCursorInfo DROP
;

: ShowCursor
\ Показать курсор
  CONSOLE_CURSOR_INFO H-STDIN STREAM-FILE GetConsoleCursorInfo DROP
  1 CONSOLE_CURSOR_INFO 4 + !
  CONSOLE_CURSOR_INFO H-STDIN STREAM-FILE SetConsoleCursorInfo DROP
;

: PICK 1+ 4 * SP@ + @ ;

: PrintedChar
  31 >
;

: BEEP 7 EMIT ;

: ACCEPTPosCursor ( sx sy addr u len x )
  5 PICK OVER + 5 PICK GotoXY
;

: ACCEPTShowString
  HideCursor
  5 PICK 5 PICK GotoXY
  3 PICK 2 PICK TYPE
  ShowCursor
;

: ACCEPTShowStringFull ( sx sy addr u len x -- sx sy addr u len x )
\ отображение строки. За строкой добавляются пробелы до максимальной длины
\ строки (u)
  HideCursor
  5 PICK 5 PICK GotoXY
  3 PICK 2 PICK TYPE
  2 PICK 2 PICK - SPACES
  ACCEPTPosCursor
  ShowCursor
;

: ACCEPTInsChar ( addr u len x ch -- addr u len+1 x+1 | addr u len x )
\ Вставка символа
  3 PICK 3 PICK <> IF
    4 PICK 2 PICK + DUP 1+ ( addr u len x ch addr+x addr+x+1 )
    4 PICK 4 PICK - MOVE
    4 PICK 2 PICK + C! ( addr u len x )
    1+ SWAP 1+ SWAP
    ACCEPTShowString ACCEPTPosCursor
  ELSE
    DROP
    BEEP
  THEN
;

: ACCEPTBackspace ( addr u len x -- addr u len-1 x-1 | addr u len x )
\ Обработка Backspase
  DUP IF
    3 PICK 1 PICK + DUP 1- ( addr u len x addr+x addr+x-1 )
    3 PICK 3 PICK - MOVE
    1- SWAP 1- SWAP
    ACCEPTShowString SPACE ACCEPTPosCursor
  ELSE
    BEEP
  THEN
;

: ACCEPTLeft ( sx sy addr u len x )
\ пермещение курсора влево
  DUP IF 1- ACCEPTPosCursor ELSE BEEP THEN
;

: ACCEPTRight ( sx sy addr u len x )
\ пермещение курсора вправо
  DUP 2 PICK <> IF 1+ ACCEPTPosCursor ELSE BEEP THEN
;

: ACCEPTDel
\ Обработка клавиши Delete
  DUP 2 PICK <> IF 1+ ACCEPTBackspace ELSE BEEP THEN
;

: ACCEPTEsc
\ очистка строки
  2DROP 0 0 ACCEPTShowStringFull
;

\ Определение history. Простой буфер со строками фиксированной максимальной длиной
80 CONSTANT ACCEPTHStrLen   \ Максимальная длина строки в history. в неё входит
\ один байт для длины строки. Не может быть больше 256
50 CONSTANT ACCEPTHStrings  \ Число строк в history
\ CREATE ACCEPTHistory ACCEPTHStrLen ACCEPTHStrings * ALLOT
0 VALUE ACCEPTHistory
VARIABLE ACCEPTHEnd \ № последней строки
VARIABLE ACCEPTHCur \ № текущей просматриваемой строки

: ACCEPT>H ( addr u -- )
\ кладём строку в history. если её длина больше максимально дозволенной,
\ она укорачивается. строка кладётся в строку №0 в history, остальные
\ сдвигаются вниз, последняя теряется.
  ACCEPTHEnd @ -1 = 0= IF          
    ACCEPTHistory DUP
    ACCEPTHEnd @ 1+ ACCEPTHStrings 1- MIN
    ACCEPTHStrLen * SWAP ACCEPTHStrLen + SWAP
    MOVE
  THEN
  ACCEPTHStrLen 1- MIN DUP
  ACCEPTHistory C!
  ACCEPTHistory 1+ SWAP MOVE
  ACCEPTHEnd @ 1+ ACCEPTHStrings 1- MIN ACCEPTHEnd !
;

: ACCEPTH> ( addr u1 n -- u2 )
\ берём строку №n в addr. если длина взятой строки больше u1, то она обрубается
\ до u1. возвращается длина взятой строки.
  ACCEPTHStrLen * ACCEPTHistory +   ( addr u1 haddr )
  DUP C@ ROT MIN                    ( addr haddr u2 )
  DUP 2SWAP ( u2 u2 addr haddr )
  1+
  SWAP ROT ( u2 haddr addr u2 )
  MOVE
;

: ACCEPTUp ( sx sy addr u len x )
\ обработка клавиши Up
  ACCEPTHCur @ DUP ACCEPTHEnd @ < IF
    1+ ACCEPTHCur !
    2OVER ACCEPTHCur @ ACCEPTH> NIP NIP DUP
    ACCEPTShowStringFull
  ELSE
    DROP
  THEN
;

: ACCEPTDown
\ обработка клавиши Down
  ACCEPTHCur @ DUP 0 > IF
    1- ACCEPTHCur !
    2OVER ACCEPTHCur @ ACCEPTH> NIP NIP DUP
    ACCEPTShowStringFull
  ELSE
    DROP
  THEN
;

VECT ACCEPTUnknownEvent ( sx sy addr u len x u -- sx sy addr u len x enter )
\ Вызывается, если событие консоли не опознано ACCEPT-ом.
\ u - результат EKEY-а
: ACCEPTUnknownEvent1
  DROP 0
;

WINAPI: WaitForSingleObject KERNEL32.DLL

: ACCEPT1 ( addr u -- u )
\ Чтение строки с клавиатуры, возвращается число введённых символов
\ Числа в стеке: sx, sy - координаты начала строки
\ addr, u - адрес и максимальная (заданная) длина строки
\ len - текущая длина строки
\ x - положение курсора
\ enter - =1, если нажат Enter
\ Не комментирую, так как вроде и так всё прозрачно.
\ !!! Строка не должна уходить за край экрана.
  79 MIN
  -1 ACCEPTHCur !
  WhereXY 2SWAP ( sx sy addr u )
  0 0 ( sx sy addr u len x )
  BEGIN
    \ BEGIN EKEY? UNTIL
    -1 -10 GetStdHandle WaitForSingleObject DROP
    EKEY EKEY>CHAR
    IF
      DUP PrintedChar IF
        ACCEPTInsChar 0
      ELSE
        CASE ( sx sy addr u len x )
          VK_BACK OF ACCEPTBackspace 0 ENDOF
          VK_RETURN OF 1 ENDOF
          VK_ESCAPE OF ACCEPTEsc 0 ENDOF
         ( 7 OF 0 ENDOF )     \ если эти комментарии убрать, то можно будет
         ( 9 OF 0 ENDOF )     \ вставлять в строку символы с кодами <32
         ( ACCEPTInsChar )    \ как Ctrl+<a..z>
          DROP                \ тогда это надо закомментарить
          0 0
        ENDCASE
      THEN
    ELSE
      DUP
      KEYFLAG_KEY_EVENT KEYFLAG_KEY_DOWN OR
      DUP ROT AND =
      IF
        255 AND
        CASE ( sx sy addr u len x )
          VK_RIGHT OF ACCEPTRight ENDOF
          VK_LEFT OF ACCEPTLeft ENDOF
          VK_HOME OF DROP 0 ACCEPTPosCursor ENDOF
          VK_END OF DROP DUP ACCEPTPosCursor ENDOF
          VK_DELETE OF ACCEPTDel ENDOF
          VK_UP OF ACCEPTUp ENDOF
          VK_DOWN OF ACCEPTDown ENDOF
        ENDCASE
        0
      ELSE
        ACCEPTUnknownEvent
      THEN
    THEN ( sx sy addr u len x enter )
  UNTIL
  DROP SWAP DROP
  2DUP ACCEPT>H
  >R DROP 2DROP
  CR
  R>
;

: ACCEPTInit
  ACCEPTHStrLen ACCEPTHStrings * ALLOCATE THROW TO ACCEPTHistory
  -1 ACCEPTHEnd !
  -1 ACCEPTHCur !
  ['] ACCEPTUnknownEvent1 TO ACCEPTUnknownEvent
  ['] ACCEPT1 TO ACCEPT
  ACCEPT
;

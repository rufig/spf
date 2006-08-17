REQUIRE CONST ~micro/lib/const/const.f
REQUIRE WINCONST lib/win/const.f

: SETMOD
\ Установка режима консоли
  H-STDIN STREAM-FILE SetConsoleMode ERR ABORT" Wrong console mode."
;

WINAPI: PeekConsoleInputA KERNEL32.DLL
WINAPI: ReadConsoleA kernel32.dll

: PeekCon
\ Читать событие из буфера консоли и оставить его в буфере
  NumberOfRecordsRead 1 INPUT_RECORD H-STDIN STREAM-FILE PeekConsoleInputA ERR THROW
;

: ReadCon
\ Читать событие из буфера консоли и удалить его из буфера
  NumberOfRecordsRead 1 INPUT_RECORD H-STDIN STREAM-FILE ReadConsoleInputA ERR THROW
;

: ~ DUP 2* SWAP ;
: ` DUP ;
256
CONST Флаги событий консоли (зависит от реализации)
  KEYFLAG_KEY_EVENT ~
  KEYFLAG_MOUSE_EVENT ~
  KEYFLAG_MOUSE_LBUTTON `
  KEYFLAG_KEY_DOWN ~
  KEYFLAG_MOUSE_RBUTTON `
  KEYFLAG_CHAR_KEY ~
  KEYFLAG_MOUSE_MOVE ~
  KEYFLAG_MOUSE_DBLCLICK ~
; DROP

: ~ OVER + ;
INPUT_RECORD
CONST Поля и их значения в структуре INPUT_RECORD
  EventType 0 ~
    MOUSE_EVENT 2
    KEY_EVENT 1
  KKeyDown 4 ~
  MMouseX 4 ~
  MMouseY 6 ~
  KRepeatCount 8 ~
  MButtonState 8 ~
    LBUTTON 1
    RBUTTON 2
  KVirtualKeyCode 10 ~
  KVirtualScanCode 12 ~
  MControlKeyState 12 ~
    RIGHT_ALT_PRESSED 0x01
    LEFT_ALT_PRESSED 0x02
    RIGHT_CTRL_PRESSED 0x04
    LEFT_CTRL_PRESSED 0x08
    CAPSLOCK_ON 0x80
    ENHANCED_KEY 0x100
    NUMLOCK_ON 0x20
    SCROLLLOCK_ON 0x40
    SHIFT_PRESSED 0x10
  KAsciiCode 14 ~
  KControlKeyState 16 ~
  MEventFlag 16 ~
    MOUSE_MOVED 1
    DOUBLE_CLICK 2
; DROP

: EKEY? ( -- flag ) \ 93 FACILITY EXT
\ Проверка наличия событий консоли
  0 SP@ H-STDIN STREAM-FILE 
\ В прошлой версии результат заносился в переменную. ЗАЧЕМ? Он же больше не
\ используется. Пусть идёт сразу в стек!
  GetNumberOfConsoleInputEvents ERR THROW
  0<>
;

VARIABLE KEY_RECORD_ASCII
\ ASCII-код символьной клавиши. Заполняется EKEY, а при необходимости
\ извлекается. Необходимо, так как EKEY удаляет событие.

: EKEY ( -- u )
\ Чтение события консоли. Отличия от имевшейся версии: возможность получения
\ наиболее полной информации о событии, корректное чтение символьных клавиш,
\ в том числе при переключении языка.
\ Возвращает виртуальный код клавиши (константы vk_*) и флаги KEYFLAG_*
  0 KEY_RECORD_ASCII !
  EKEY? IF
    PeekCon
\ Смотрим консоль
    EventType W@ KEY_EVENT = IF
\ Если клавиатурное событие
      KVirtualKeyCode W@
      KEYFLAG_KEY_EVENT OR
      KKeyDown W@ IF
        KEYFLAG_KEY_DOWN OR
      THEN
      KAsciiCode W@ IF
        KEYFLAG_CHAR_KEY OR
        DUP KEYFLAG_KEY_DOWN AND IF
\ Если это символьная клавиша, и произошло нажатие, то процесс усложняется:
\ её можно прочитать через функцию ReadConsole - тогда символ возвратится
\ в нужном регистре и языке. Специально для этого выше использовалось
\ PeekCon вместо ReadCon.
          17 SETMOD
\ Устанавливаем режим, при котором вводимый символ будет возвращён сразу,
\ а не после нажатия <ENTER>.
          0 NumberOfRecordsRead 1 KEY_RECORD_ASCII H-STDIN STREAM-FILE 
          ReadConsoleA DROP
\ Запоминаем в KEY_RECORD_ASCII, так как сейчас нам нужен только скан-код.
          23 SETMOD
\ Восстанавливаем режим консоли.
        ELSE
          ReadCon
\ Всё, событие более не нужно.
        THEN
      ELSE
\ Ещё одна исключительная ситуация - <ESC> не распознаётся как символьная
\ клавиша. Анализируем vk-код.
        ReadCon
        DUP 0xFF AND 0x1B = IF
          KEYFLAG_CHAR_KEY OR
          DUP KEYFLAG_KEY_DOWN AND IF
\ Если это vk-код <ESC> и нажатие, то устанавливаем флаг символьной клавиши
            0x1B KEY_RECORD_ASCII !
\ И запоминаем.
          THEN
        THEN
      THEN
    ELSE
\ Если событие не клавиатурное
      ReadCon
      EventType W@ MOUSE_EVENT = IF
\ Может от мыши?
        KEYFLAG_MOUSE_EVENT
        MEventFlag W@ MOUSE_MOVED AND IF
          KEYFLAG_MOUSE_MOVE OR
        THEN
        MEventFlag W@ DOUBLE_CLICK AND IF
          KEYFLAG_MOUSE_DBLCLICK OR
        THEN
        MButtonState W@ LBUTTON AND IF
          KEYFLAG_MOUSE_LBUTTON OR
        THEN
        MButtonState W@ RBUTTON AND IF
          KEYFLAG_MOUSE_RBUTTON OR
        THEN
\ Если так, то ставим соответствующие флаги
      ELSE
        0
\ Иначе - ничего не произошло.
      THEN
    THEN
  ELSE
    0
  THEN
;

: EKEY>CHAR ( u -- u 0 | c -1 )
\ Если vk-код u соответствует нажатой символьной клавише, то вернуть её ASCII
\ код и true, иначе код и false
  KEY_RECORD_ASCII @ DUP IF
    NIP -1
  THEN
;

VARIABLE KEY?_WAS 0 KEY?_WAS !
\ Был вызван KEY? до KEY. Необходимо для того, чтобы KEY более не вызывал KEY?.
VARIABLE KEY?_FLAG
\ Результат вызова KEY?.

: KEY? ( -- f )
  EKEY EKEY>CHAR NIP
  -1 KEY?_WAS !
  DUP KEY?_FLAG !
;

: KEY ( -- c )
  KEY?_WAS @ 0= IF
    BEGIN KEY? 0 KEY?_WAS ! UNTIL
  THEN
  KEY_RECORD_ASCII W@
;
\ Внимание!!! EKEY не совсем стандартное. Оно удаляет событие. Благодаря
\ этому можно сделать так:
\ BEGIN DO_SOMETHING KEY? UNTIL KEY

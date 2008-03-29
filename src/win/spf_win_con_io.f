\ $Id$

( Консольный ввод-вывод.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
  Изменения - Ruvim Pinka ноябрь 1999
)

: EKEY? ( -- flag ) \ 93 FACILITY EXT
\ Если клавиатурное событие доступно, вернуть "истина". Иначе "ложь".
\ Событие должно быть возвращено следующим выполнением EKEY.
\ После того как EKEY? возвратило значение "истина", следующие выполнения
\ EKEY? до выполнения KEY, KEY? или EKEY также возвращают "истину",
\ относящуюся к тому же событию.
  0 >R RP@ H-STDIN GetNumberOfConsoleInputEvents DROP R>
;

CREATE INPUT_RECORD ( /INPUT_RECORD) 20 2 * CHARS ALLOT

: ControlKeysMask ( -- u )
\ вернуть маску управляющих клавиш для последнего клавиатурного события.
    [ INPUT_RECORD ( Event dwControlKeyState ) 16 + ] LITERAL @
;

1 CONSTANT KEY_EVENT

: EKEY ( -- u ) \ 93 FACILITY EXT
\ Принять одно клавиатурное событие u. Кодирование клавиатурных событий
\ зависит от реализации.
\ В данной реализации 
\ byte  value
\    0  AsciiChar
\    2  ScanCod
\    3  KeyDownFlag
  0 >R RP@ 2 INPUT_RECORD H-STDIN \ 1 заменен на 2 (30.12.2001 ~boa)
  ReadConsoleInputA DROP RDROP
  INPUT_RECORD ( EventType ) W@  KEY_EVENT <> IF 0 EXIT THEN
  [ INPUT_RECORD ( Event AsciiChar       ) 14 + ] LITERAL W@
  [ INPUT_RECORD ( Event wVirtualScanCode) 12 + ] LITERAL W@  16 LSHIFT OR
  [ INPUT_RECORD ( Event bKeyDown        ) 04 + ] LITERAL C@  24 LSHIFT OR
;

HEX
: EKEY>CHAR ( u -- u false | char true ) \ 93 FACILITY EXT
\ Если клавиатурное событие u соответствует символу - вернуть символ и
\ "истину". Иначе u и "ложь".
  DUP    FF000000 AND  0=   IF FALSE    EXIT THEN
  DUP    000000FF AND  DUP IF NIP TRUE EXIT THEN DROP
  FALSE
;

: EKEY>SCAN ( u -- scan flag )
\ вернуть скан-код клавиши, соответствующей клавиатурному событию u
\ flag=true - клавиша нажата. flag=false - отпущена.
  DUP  10 RSHIFT  000000FF AND
  SWAP FF000000 AND 0<>
;
DECIMAL

VARIABLE PENDING-CHAR \ клавиатура одна -> переменная глобальная, не USER

: KEY? ( -- flag ) \ 94 FACILITY
\ Если символ доступен, вернуть "истину". Иначе "ложь". Если несимвольное
\ клавиатурное событие доступно, оно отбрасывается и больше недоступно.
\ Символ будет возвращен следующим выполнением KEY.
\ После того как KEY? возвратило значение "истина", следующие выполнения
\ KEY? до выполнения KEY или EKEY также возвращают "истину" без отбрасывания
\ клавиатурных событий.
  PENDING-CHAR @ 0 > IF TRUE EXIT THEN
  BEGIN
    EKEY?
  WHILE
    EKEY  EKEY>CHAR
    IF PENDING-CHAR !
       TRUE EXIT
    THEN
    DROP
  REPEAT FALSE
;

VECT KEY

: KEY1 ( -- char ) \ 94
\ Принять один символ char. Клавиатурные события, не соответствующие
\ символам, отбрасываются и более не доступны.
\ Могут быть приняты все стандартные символы. Символы, принимаемые по KEY,
\ не отображаются на дисплее.
\ Программы, требующие возможность получения управляющих символов,
\ зависят от окружения.
  PENDING-CHAR @ 0 >
  IF PENDING-CHAR @ -1 PENDING-CHAR ! EXIT THEN
  BEGIN
    EKEY  EKEY>CHAR 0=
  WHILE
    DROP
  REPEAT
;
' KEY1 ' KEY TC-VECT!

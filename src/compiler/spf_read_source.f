( Чтение строки исходного текста из входного потока: консоли или файла.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия: Сентябрь 1999
)

USER-VALUE SOURCE-ID ( -- 0|-1 ) \ 94 CORE EXT
\ Идентифицирует входной поток:
\ -1 - строка (через EVALUATE)
\  0 - пользовательское входное устройство
USER-VALUE SOURCE-ID-XT \ если не равен нулю, то содержит заполняющее
\ слово для REFILL

VECT <PRE>
USER CURSTR \ номер строки


FALSE VALUE ?GUI
FALSE VALUE ?CONSOLE

: CONSOLE-HANDLES
\  0 TO SOURCE-ID
  -10 GetStdHandle TO H-STDIN 
  -11 GetStdHandle TO H-STDOUT
  -12 GetStdHandle TO H-STDERR

  \ ~day На случай печати в GUI приложении запущеным из под Explorer  
  ?GUI
  IF
    H-STDOUT 65537 = IF -1 TO H-STDOUT THEN \ Invalid handle
  THEN
;


VECT REFILL ( -- flag )

: TAKEN-TIB ( u flag -- flag )
  IF CURSTR 1+!  TIB SWAP SOURCE!  <PRE> -1  ELSE DROP 0  THEN
;
: REFILL-STDIN ( -- flag ) \  from user input
  SOURCE-ID -1 = IF FALSE EXIT THEN ( evaluate string )
  TIB C/L ['] ACCEPT CATCH
  \ -1002=конец файла или pipe
  \ остальные ошибки - ошибки чтения
  DUP -1002 = IF DROP 2DROP 0 0 ELSE THROW -1 THEN
  TAKEN-TIB
;
' REFILL-STDIN (TO) REFILL ( -- flag ) \ 94 CORE EXT
\ Попытаться заполнить входной буфер из входного потока, вернуть
\ флаг "истина", если успешно.
\ Когда входным потоком является пользовательское входное устройство,
\ попытаться принять ввод в терминальный входной буфер. Если успешно,
\ сделать результат входным буфером, установить >IN в ноль и возвратить
\ "истину". Прием строки, не содержащей символов, считается успешным.
\ Если ввод с текущего входного устройства недоступен - возвратить "ложь".
\ Когда входным потоком является строка от EVALUATE, возвратить "ложь"
\ и не выполнять других действий.

( Исправления на тот случай, когда консоль не файл, и читать её
  следует через ACCEPT [который может быть не файловым]
  24.04.2000 А.Ч.
)

\ ------------------------

: FREFILL ( h -- flag )
  TIB C/L ROT READ-LINE THROW TAKEN-TIB
;
: REFILL-FILE ( -- flag ) \ 94 FILE EXT
  SOURCE-ID DUP 0 > IF ( included text )
  FREFILL  EXIT     THEN
  DROP REFILL-STDIN
;
' REFILL-FILE (TO) REFILL ( -- flag ) \ 94 FILE EXT
\ Расширить семантику выполнения CORE EXT REFILL следующим:
\ Когда входной поток - текстовый файл, попытаться прочесть следующую
\ строку из текстового входного файла. Если успешно, сделать результат
\ входным буфером, установить >IN в ноль и вернуть "истину".
\ Иначе вернуть "ложь".


: REFILL-SOURCE ( -- flag )
  SOURCE-ID-XT  IF
  SOURCE-ID 0 > IF
   TIB C/L SOURCE-ID SOURCE-ID-XT EXECUTE THROW
   TAKEN-TIB  EXIT
  THEN THEN
  REFILL-FILE
;
' REFILL-SOURCE (TO) REFILL ( -- flag ) \ SPF EXT
\ Расширить семантику выполнения FILE EXT REFILL следующим:
\ Если  SOURCE-ID-XT возвращает не ноль, то, считая это 
\ значение xt-ом для слова, подобного READ-LINE,
\ попытаться прочитать им строку из SOURCE-ID.
\  Если успешно, сделать результат входным буфером,
\  установить >IN в ноль и вернуть "истину".
\  Иначе вернуть "ложь".

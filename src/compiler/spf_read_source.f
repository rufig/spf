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
USER (BASEPATH) \ it contains a cstring for the current base path, or 0


: SOURCE-FILE-PATH ( -- sd.path )
  \ The path to the nearest ancestor-or-self source that is a file, or an empty string
  CURFILE @ DUP IF ASCIIZ> ELSE 0 THEN
\ NB: The synonym `SOURCE-NAME` (the old name) for this word was removed.
\ Given words like `NAME>` and `FIND-NAME`, where "NAME" stands for "nt" (a name token, a single-cell id),
\ `SOURCE-NAME` is an unfortunate name for this word.
;
: SOURCE-FILE-LN ( -- u.linenumber|0 )
  \ The line number in the nearest ancestor-or-self source that is a file, or 0
  CURSTR @
;

: SOURCE-PATH ( -- sd.path )
  \ If the input source is a file, this file is accessible by the path (file name)
  \ in the character string sd.path
  \ TODO: sd.path must be either an absolute path or a full IRI/URI/URL.
  SOURCE-ID 0=    IF S" about:input-stdin" EXIT THEN
  SOURCE-ID -1 =  IF S" about:input-string" EXIT THEN
  SOURCE-FILE-PATH
;

: SOURCE-LN ( -- u.linenumber|0 )
  SOURCE-ID -1 = IF 0 EXIT THEN \ It is not yet supported in evaluated strings and blocks
  SOURCE-FILE-LN
;

: SOURCE-BASEPATH ( -- sd.path )
  \ TODO: sd.path must be either an absolute path or a full IRI/URI/URL.
  \ A path resolved against sd.path must be suitable for `INCLUDED`.
  \ See: https://www.rfc-editor.org/rfc/rfc3986.html#section-5.1
  \ See: https://www.rfc-editor.org/rfc/rfc3986.html#section-5.2
  \ - The initial basepath of an input source that is:
  \   - a user input device (maybe from `quit`),
  \   - an evaluated string,
  \   - a block,
  \   is equal to the basepath of the nearest ancestor source that is a file, if it exists,
  \   otherwise it is an IRI or absolute path (ending with '/') to the current working directory.
  \ - The initial basepath of an input source that is a file is the path that was passed to `INCLUDED`,
  \   expanded to an absolute path or IRI. This base path must identify the file uniquely.
  (BASEPATH) @ DUP IF COUNT EXIT THEN DROP
  SOURCE-FILE-PATH DUP IF EXIT THEN 2DROP
  0 0 \ TODO: instead of an empty string, it must fall back to the path
  \ of the current working directory (which must end with '/').
;


FALSE VALUE ?GUI
FALSE VALUE ?CONSOLE

TARGET-POSIX [IF]
: CONSOLE-HANDLES ;
[ELSE]
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
[THEN]

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
' REFILL-STDIN ' REFILL TC-VECT!   ( -- flag ) \ 94 CORE EXT
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
' REFILL-FILE ' REFILL TC-VECT!   ( -- flag ) \ 94 FILE EXT
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
' REFILL-SOURCE ' REFILL TC-VECT!   ( -- flag ) \ SPF EXT
\ Расширить семантику выполнения FILE EXT REFILL следующим:
\ Если  SOURCE-ID-XT возвращает не ноль, то, считая это
\ значение xt-ом для слова, подобного READ-LINE,
\ попытаться прочитать им строку из SOURCE-ID.
\  Если успешно, сделать результат входным буфером,
\  установить >IN в ноль и вернуть "истину".
\  Иначе вернуть "ложь".

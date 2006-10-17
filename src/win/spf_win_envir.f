
: (ENVIR?) ( addr u -- false | i*x true )
   BEGIN
     REFILL
   WHILE
     2DUP PARSE-NAME COMPARE
     0= IF 2DROP INTERPRET TRUE EXIT THEN
   REPEAT 2DROP FALSE
;

: ENVIRONMENT? ( c-addr u -- false | i*x true ) \ 94
\ c-addr и u - адрес и длина строки, содержащей ключевое слово
\ для запроса атрибутов присутствующего окружения.
\ Если системе запрашиваемые атрибуты неизвестны, возвращается флаг
\ "ложь", иначе "истина" и i*x - запрашиваемые атрибуты определенного
\ в таблице запросов типа.
  1000 SYSTEM-PAD 2OVER DROP GetEnvironmentVariableA
  DUP IF NIP NIP SYSTEM-PAD SWAP TRUE EXIT THEN DROP
  \ расширение spf370: если в windows environment есть
  \ запрашиваемая строка, то возвращаем её - c-addr u true

  SFIND IF EXECUTE TRUE EXIT THEN

  S" ENVIR.SPF" +ModuleDirName

  R/O OPEN-FILE-SHARED 0=
  IF  DUP >R  
      ['] (ENVIR?) RECEIVE-WITH  IF 0 THEN
      R> CLOSE-FILE THROW 
  ELSE 
    2DROP DROP 0 THEN
;

0 CONSTANT FORTH_ERROR

: (DECODE-ERROR) ( n -- c-addr u )
  STATE @ >R STATE 0!
  BEGIN
    REFILL
  WHILE ( n )
    PARSE-NAME ['] ?SLITERAL CATCH
    IF 2DROP DROP S" Error while error decoding!" R> STATE ! EXIT THEN
    OVER = IF ( n )
      DROP >IN 0! [CHAR] \ PARSE
      TUCK SYSTEM-PAD SWAP MOVE
      SYSTEM-PAD SWAP   R> STATE ! EXIT
    THEN
  REPEAT ( n ) 0
  <# SOURCE SWAP 1+ SWAP 1- HOLDS #S #> \ Unknown error
  R> STATE !
;

: DECODE-ERROR ( n u -- c-addr u )
\ Возвратить строку, содержащую расшифровку кода
\ ошибки n при условии u.
\ Scattered Colon.
  ... DROP
  S" SPF.ERR" +ModuleDirName
  R/O OPEN-FILE-SHARED
  IF DROP DUP >R ABS 0 <# #S R> SIGN S" ERROR #" HOLDS #>
     TUCK SYSTEM-PAD SWAP MOVE SYSTEM-PAD SWAP
  ELSE
    DUP >R
    ['] (DECODE-ERROR) RECEIVE-WITH DROP
    R> CLOSE-FILE THROW
    2DUP -TRAILING + 0 SWAP C!
  THEN
;

: ERROR2 ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP 0= IF DROP EXIT THEN
  DUP -2 = IF   DROP LAST-WORD
                ER-A @ ER-U @ TYPE
           ELSE
  LAST-WORD  
  BASE @ >R DECIMAL
  FORTH_ERROR DECODE-ERROR TYPE
  R> BASE !
  CURFILE @ ?DUP IF FREE THROW  CURFILE 0! THEN
           THEN CR
;

: LIB-ERROR1 ( addr_winapi_structure )
    CELL+ @ ASCIIZ> 
    <# HOLDS S" Forth: Can't load a library " HOLDS 0. #>
    DUP ER-U !
    SYSTEM-PAD SWAP MOVE
    SYSTEM-PAD ER-A ! -2 THROW
;


: LIB-PROC1 ( addr_winapi_structure )
    DUP
    CELL+ @ ASCIIZ> ROT
    CELL+ CELL+ @ ASCIIZ> 2SWAP
    <# HOLDS S"  in a library " HOLDS HOLDS
       S" Forth: Can't find a proc " HOLDS 0. #>
    DUP ER-U !
    SYSTEM-PAD SWAP MOVE
    SYSTEM-PAD ER-A ! -2 THROW
;

: ANSI>OEM ( addr u -- addr u )
  DUP NUMERIC-OUTPUT-LENGTH > 
  IF
    S" Buffer overrun in ANSI>OEM" ER-U !
    ER-A ! -2 THROW
  THEN
  DUP ROT ( u u addr )
  SYSTEM-PAD SWAP CharToOemBuffA DROP
  SYSTEM-PAD SWAP
;

: OEM>ANSI ( addr u -- addr u )
  DUP NUMERIC-OUTPUT-LENGTH > 
  IF
    S" Buffer overrun in OEM>ANSI" ER-U !
    ER-A ! -2 THROW
  THEN

  DUP ROT ( u u addr )
  SYSTEM-PAD SWAP OemToCharBuffA DROP
  SYSTEM-PAD SWAP
;

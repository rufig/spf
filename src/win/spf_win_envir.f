
: (ENVIR?) ( addr u -- false | i*x true )
   BEGIN
     REFILL
   WHILE
     2DUP NextWord COMPARE
     0= IF 2DROP INTERPRET TRUE EXIT THEN
   REPEAT 2DROP FALSE
;

: ENVIRONMENT? ( c-addr u -- false | i*x true ) \ 94
\ c-addr и u - адрес и длина строки, содержащей ключевое слово
\ для запроса атрибутов присутствующего окружения.
\ Если системе запрашиваемые атрибуты неизвестны, возвращается флаг
\ "ложь", иначе "истина" и i*x - запрашиваемые атрибуты определенного
\ в таблице запросов типа.
  1000 PAD 2OVER DROP GetEnvironmentVariableA
  DUP IF NIP NIP PAD SWAP TRUE EXIT THEN DROP
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
  WHILE
    NextWord ['] ?SLITERAL CATCH
    IF DROP S" Error while error decoding!" -1
    ELSE OVER = DUP IF 2DROP >IN 0! [CHAR] \ PARSE
                       TUCK PAD SWAP MOVE
                       PAD SWAP -1
                    THEN
    THEN IF R> STATE ! EXIT THEN
  REPEAT DROP R> STATE !
  SOURCE TUCK PAD SWAP QCMOVE \ Unknown error
  PAD SWAP
;

: DECODE-ERROR ( n u -- c-addr u )
\ Возвратить строку, содержащую расшифровку кода
\ ошибки n при условии u. Использует PAD!
\ Scattered Colon.
  ... DROP
  S" SPF.ERR" +ModuleDirName
  R/O OPEN-FILE-SHARED
  IF DROP DUP >R ABS 0 <# #S R> SIGN S" ERROR #" HOLDS #>
     TUCK PAD SWAP MOVE PAD SWAP
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
  LAST-WORD  DECIMAL 
  FORTH_ERROR DECODE-ERROR TYPE
  CURFILE @ ?DUP IF FREE THROW  CURFILE 0! THEN
           THEN CR
;

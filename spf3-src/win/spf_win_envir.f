: ENVIRONMENT? ( c-addr u -- false | i*x true ) \ 94
\ c-addr и u - адрес и длина строки, содержащей ключевое слово
\ для запроса атрибутов присутствующего окружения.
\ Если системе запрашиваемые атрибуты неизвестны, возвращается флаг
\ "ложь", иначе "истина" и i*x - запрашиваемые атрибуты определенного
\ в таблице запросов типа.
  1000 PAD 2OVER DROP GetEnvironmentVariableA
  ?DUP IF NIP NIP PAD SWAP TRUE EXIT THEN
  \ расширение spf370: если в windows environment есть
  \ запрашиваемая строка, то возвращаем её - c-addr u true

  SFIND IF EXECUTE TRUE EXIT THEN
  TIB >R #TIB @ >R >IN @ >R SOURCE-ID >R CURSTR @ >R
  2>R
  C/L 2+ ALLOCATE THROW TO TIB

  S" ENVIR.SPF" +ModuleDirName

  R/O OPEN-FILE-SHARED 0=
  IF
  TO SOURCE-ID
  BEGIN
    REFILL
    IF   2R@ NextWord COMPARE 0=
         IF INTERPRET TRUE  TRUE
         ELSE         FALSE THEN
    ELSE FALSE TRUE THEN
  UNTIL
  TIB FREE THROW
  SOURCE-ID CLOSE-FILE THROW 
  ELSE DROP 0 THEN
  2R> 2DROP
  R> CURSTR ! R> TO SOURCE-ID
  R> >IN ! R> #TIB ! R> TO TIB
;

: ERROR2 ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP 0= IF DROP EXIT THEN
  H-STDERR TO H-STDOUT
  DUP -2 = IF   DROP LAST-WORD
                ER-A @ ER-U @ TYPE CR EXIT
           THEN
  LAST-WORD  DECIMAL [COMPILE] [

  S" SPF.ERR" +ModuleDirName
  R/O OPEN-FILE

  IF DROP ." ERROR #" . EXIT THEN
  SOURCE-ID >R CURSTR @ >R
     TO SOURCE-ID
     >R
     BEGIN
       REFILL 0= #TIB @ 0= OR
       NextWord ['] ?SLITERAL CATCH
       IF 2DROP -1 R@ . ELSE R@ = THEN OR
     UNTIL
\  [CHAR] \ PARSE TYPE ."  ERR# " R> .
  >IN 0! [CHAR] \ PARSE TYPE RDROP
  SOURCE-ID CLOSE-FILE THROW
  R> CURSTR ! R> TO SOURCE-ID
\  CURFILE @ ?DUP IF CR ASCIIZ> 80 MIN TYPE ." :" CURSTR @ . CR THEN
\  CR
\ ;
  CURFILE @ ?DUP IF
      CR ASCIIZ> 80 MIN TYPE ." :" CURSTR @ . CR
      CURFILE @ FREE THROW  CURFILE 0!
  THEN CR
;

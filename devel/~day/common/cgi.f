: PRINT-FILE ( addr u -- )
  { \ a len f }
  R/O OPEN-FILE THROW -> f
  f FILE-SIZE THROW DROP -> len
  len ALLOCATE THROW -> a
  a len f READ-FILE THROW a SWAP
  TYPE
  f CLOSE-FILE THROW
  a FREE THROW
;  

\ размер облаcти addr должен быть не менее 256

: GET-QUERY ( addr -- u )
   POST? @
   IF 256 ACCEPT
   ELSE
      S" QUERY_STRING" ENVIRONMENT? 0= ABORT" Require CGI application!"
      DUP >R ROT SWAP CMOVE R>
   THEN
;

USER Count

\ Пишет в PAD расшифрованную строку как строку со счетчиком
\ Понимает незашифрованный текст наряду с зашифрованным

: CONVERT% ( addr u -- addr2 u2 )
    BASE @ >R HEX Count 0!
    0 ROT ROT
    OVER + SWAP
    ?DO
       Count @ 0=
       IF
         I C@ [CHAR] % =
         IF
           0. I 1+ 2 >NUMBER
           2DROP D>S
           OVER 1+ PAD + C!
           1+ 2 Count !
         ELSE
           1+ DUP PAD +
           I C@ SWAP C!
         THEN
      ELSE
        -1 Count +!   
      THEN
    LOOP
    PAD 2DUP C! 1+
    SWAP R> BASE !
;

0 VALUE QUERY-LEN

CREATE QUERY-BUF 256 ALLOT

\ формирует запрос в QUERY-BUF

: FORM-QUERY
    QUERY-LEN 0=
    IF  
        QUERY-BUF GET-QUERY TO QUERY-LEN
        QUERY-BUF QUERY-LEN OVER + SWAP
        DO
          I C@ [CHAR] + =
          IF BL I C! THEN
        LOOP
    THEN    
    
;

: SKIP-LEFT { c addr u \ count -- addr2 u2 }
   BEGIN
     addr count + C@ c =
     count u < AND
   WHILE
     count 1+ -> count
   REPEAT
   addr count + u count -
;

: PROCESS-QUERY ( -- )
  FORM-QUERY
  QUERY-BUF QUERY-LEN
  TIB >R #TIB @ >R >IN @ >R
  #TIB ! TO TIB >IN 0!  
  BEGIN
    [CHAR] ? SKIP
    [CHAR] = PARSE
    SFIND
  WHILE
    [CHAR] & PARSE CONVERT% ROT EXECUTE
  REPEAT
  2DROP
  R> >IN ! R> #TIB ! R> TO TIB  
;


\ Если не нашли, то u2=0
: GET-VALUE ( c-addr u -- c-addr2 u2 )
  FORM-QUERY
  QUERY-BUF QUERY-LEN
  TIB >R #TIB @ >R >IN @ >R
  #TIB ! TO TIB >IN 0!  
  BEGIN
    [CHAR] ? SKIP
    2DUP
    [CHAR] = PARSE DUP 0= >R
    COMPARE 0= R> OR INVERT
  WHILE
    [CHAR] & PARSE 2DROP
  REPEAT
  2DROP
  [CHAR] & PARSE 
  R> >IN ! R> #TIB ! R> TO TIB  
  CONVERT%
  BL ROT ROT SKIP-LEFT
;

\ Форт парсер html

: PARSE%
  BEGIN
    BEGIN
      NextWord DUP
    WHILE
      2DUP S" %%" COMPARE
      0= IF 2DROP EXIT THEN
      SFIND 
      IF
         EXECUTE
      ELSE
         S" NOTFOUND" SFIND
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
      THEN
    REPEAT 2DROP
    REFILL 0=
  UNTIL 
;

        : <html>  ( -- )
                ." Content-Type: text/html" CR CR
                BEGIN                                    
                        BEGIN
                                NextWord DUP
                        WHILE                                
                                2DUP  S" </html>"  COMPARE 
                                0= IF                             
                                        TYPE
                                        EXIT
                                   THEN                              
                                2DUP  S" </HTML>"  COMPARE 
                                0= IF                             
                                        TYPE
                                        EXIT
                                   THEN                              
                                2DUP  S" %%"  COMPARE 
                                0= IF                               
                                       2DROP PARSE%
                                   ELSE
                                        TYPE BL EMIT
                                   THEN
                        REPEAT  2DROP 
                        CR
                REFILL 0=  UNTIL                          
        ;  IMMEDIATE

: <HTML>  [COMPILE] <html>
; IMMEDIATE


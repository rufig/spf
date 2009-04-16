( ѕроста€ библиотека дл€ преобразовани€ строки параметров
  в набор форт-слов. Ќапример, выполнение
  S" error_code=10060&from=http://10.1.1.11/" GetParamsFromString
  приведет к тому, что в текущем временном словаре по€в€тс€ слова
  error_code и from, которые при выполнении будут возвращать
  строку addr u со значением этого параметра.
)

\ Ѕывший acWEB\conf\http\plugins\fs\get_url_params.f 

REQUIRE {             ~ac/lib/locals.f
REQUIRE "             ~ac/lib/str5.f

USER SkipConvert%
VECT vCONVERT%pre  ' NOOP TO vCONVERT%pre
VECT vCONVERT%post ' NOOP TO vCONVERT%post

: CONVERT { a u c1 c2 -- }
  u 0 ?DO a I + C@ c1 = IF c2 a I + C! THEN LOOP
;

: CONVERT% ( a1 u1 -- a2 u2 )
  \ декодирование urlкодировани€ - например параметров QUERY_STRING и POST.

  vCONVERT%pre

  SkipConvert% @ IF EXIT THEN
  { a u \ a2 u2 i -- a2 u2 }

  a u [CHAR] + BL CONVERT
\  a u [CHAR] & 1  CONVERT
\  a u [CHAR] = BL CONVERT
  u ALLOCATE THROW -> a2
  0 -> u2  0 -> i  HEX
  BEGIN
    i u U<
  WHILE
    a i + C@ DUP [CHAR] % =
    IF DROP 0 0 a i + CHAR+ 2 >NUMBER 2DROP D>S i 2+ -> i THEN
    a2 u2 + C!
    i 1+ -> i
    u2 1+ -> u2
  REPEAT DECIMAL
  a2 u2

  vCONVERT%post

;

\ VOCABULARY PARAMS
\ в отличие от FS, здесь будет временный безым€нный словарь

: STR@DOES
  DOES>  @ STR@ (") STR@
;
: 'STR@DOES
  DOES>  @ STR@
;
: STR-LIT { \ s }
  "" -> s 1 PARSE CONVERT% s STR! s
;
: STRING:
\  CREATE 
\  NextWord CONVERT% CREATED
  [CHAR] = PARSE CONVERT% CREATED
  STR-LIT ,
  'STR@DOES  ( кавычка поставлена 01.01.2002 ~ac :)
;
: Name:Value
\  2DUP [CHAR] = BL CONVERT
  ['] STRING: EVALUATE-WITH
;
: AllocParams
\  GET-CURRENT ALSO PARAMS DEFINITIONS
\  уже установлено на входе
  BEGIN
    1 PARSE DUP
  WHILE
    Name:Value
  REPEAT 2DROP
\  PREVIOUS SET-CURRENT
;
: GetParamsFromString ( addr u -- )
  2DUP [CHAR] & 1  CONVERT
  ( CONVERT%) ['] AllocParams EVALUATE-WITH
;
: Get;ParamsFromString ( addr u -- )
  2DUP [CHAR] ; 1 CONVERT
  ['] AllocParams EVALUATE-WITH
;
: ForEachParam { xt -- }
\  ALSO PARAMS 
\  уже установлено на входе
  CONTEXT @ @
  BEGIN
    DUP
  WHILE
    DUP DUP COUNT ROT
        NAME> EXECUTE xt EXECUTE
    CDR
  REPEAT DROP
\  PREVIOUS
;
: DumpParam { na nu va vu -- }
  na nu TYPE ." =="
  [CHAR] " EMIT va vu TYPE [CHAR] " EMIT CR CR
;
: DumpParams
  ['] DumpParam ForEachParam
;
USER uSParams

: isBinary ( addr u -- flag )
  0 ?DO DUP I + C@ DUP BL < SWAP 9 <> AND IF UNLOOP EXIT THEN LOOP
  DROP FALSE
;
: ShowParam ( na nu va vu -- )
  2DUP isBinary IF NIP " [binary data, len={n}]" STR@ THEN
  2SWAP " <tr><td>{s}</td><td>{s}</td></tr>{CRLF}"
  uSParams @ S+
;
: ShowParams ( -- addr u )
  S" <table border='1'>" uSParams S!
  ['] ShowParam ForEachParam
  S" </table>" uSParams @ STR+
  uSParams @ STR@
;
: IsSet ( addr u -- flag )
  ( ALSO PARAMS) CONTEXT @ ( PREVIOUS) SEARCH-WORDLIST
  IF DROP TRUE ELSE FALSE THEN
;
: SetParam ( va vu pa pu -- )
\  GET-CURRENT >R ALSO PARAMS DEFINITIONS
\  уже установлено на входе
  2DUP CONTEXT @ SEARCH-WORDLIST
  IF NIP NIP >BODY S!
  ELSE
    GET-CURRENT >R
      CONTEXT @ IS-TEMP-WORDLIST IF CONTEXT @ ELSE ALSO TEMP-WORDLIST THEN DUP SET-CURRENT CONTEXT !
      " {s}={s}" STR@ Name:Value
    R> SET-CURRENT
  THEN
\  PREVIOUS R> SET-CURRENT
;

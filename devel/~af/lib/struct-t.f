\ Andrey Filatkin, af@forth.org.ru
\ ќбъ€вление структур, содержащих элементы - функции.
\ —лова дл€ доступа к пол€м структуры создаютс€ во временном словаре.

: TVOC ( -- ) \ name
  TEMP-WORDLIST
  CREATE
  LATEST-NAME NAME>CSTRING OVER VOC-NAME!  ,
  DOES> @ CONTEXT !
;
: (f:) ( obj offset -- )
  OVER @ + @ API-CALL
;
: (f...:) ( obj cells offset -- )
  SWAP >R
  (f:)
  R> 0 DO NIP LOOP
;

: STRUCT: ( "name" -- old-current )
  TVOC
  GET-CURRENT
  ALSO LATEST-NAME-XT EXECUTE DEFINITIONS
  0
;
: ;STRUCT ( old-current -- )
  S" /SIZE" ['] CONSTANT EVALUATE-WITH
  SET-CURRENT PREVIOUS
;
: --
  CREATE OVER , IMMEDIATE +
  DOES> @
  STATE @ IF LIT, POSTPONE + ELSE + THEN
;
: f: ( offset "new-name" -- offset+cell )
  CREATE DUP , IMMEDIATE CELL+
  DOES> @
  STATE @ IF LIT, POSTPONE (f:) ELSE (f:) THEN
;
: f...: ( offset "new-name" -- offset+cell )
  CREATE DUP , IMMEDIATE CELL+
  DOES> @
  STATE @ IF LIT, POSTPONE (f...:) ELSE (f...:) THEN
;

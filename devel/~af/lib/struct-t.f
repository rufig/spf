\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Объявление структур, содержащих элементы - функции.
\ Слова для доступа к полям структуры создаются во временном словаре.

: TVOC ( -- ) \ name
  TEMP-WORDLIST
  CREATE
  LATEST OVER CELL+ ( VOC-NAME ) !  ,
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
  ALSO LATEST NAME> EXECUTE DEFINITIONS
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

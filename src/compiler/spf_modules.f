\ $Id$

(  Working with forth modules
   Copyright [C] 2000 D.Yakimov day@forth.org.ru
)

: MODULE: ( "name" -- old-current )
\ start a forth module
\ Если такой модуль уже существует, продолжить компиляцию в него
  TAKE-LEXEME FIND-NAME? IF NAME> ( xt.voc )
  ELSE ['] VOCABULARY EVALUATE-WITH LATEST-NAME>XT ( xt.voc )
  THEN XTVOC>WID  GET-CURRENT SWAP PUSH-ORDER  DEFINITIONS
;

: EXPORT ( old-current -- old-current )
\ export some module definitions
  DUP SET-CURRENT
;

: ;MODULE ( old-current -- )
\ finish the module
   SET-CURRENT PREVIOUS
;

: {{ ( "name" -- )
\ Кладет в ORDER wordlist, к-ый даст "name"
\ или vocabulary если "name" - vocabulary
        DEPTH >R
        TAKE-NAME>XT  ALSO  EXECUTE
        DEPTH R> <>             IF      \ wid on the stack?
             SET-ORDER-TOP      THEN
; IMMEDIATE

: }}
   PREVIOUS
; IMMEDIATE
\ $Id$

(  Working with forth modules
   Copyright [C] 2000 D.Yakimov day@forth.org.ru
)

: MODULE: ( "name" -- old-current )
\ start a forth module
\ Если такой модуль уже существует, продолжить компиляцию в него
  >IN @ 
  ['] ' CATCH
  IF >IN ! VOCABULARY LATEST-NAME-XT ELSE NIP THEN
  GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS ;

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
        ALSO ' EXECUTE
        DEPTH R> <>             IF      \ wid on the stack?
             CONTEXT !          THEN
; IMMEDIATE

: }}
   PREVIOUS
; IMMEDIATE
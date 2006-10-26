(  Working with forth modules
   Copyright [C] 2000 D.Yakimov day@forth.org.ru
)

: MODULE: ( "name" -- old-current )
\ Start a forth module
\ If "name" is already defined: 
\ check whether it is a vocabulary and continue compiling new words in this voc
\ else THROW error
   PARSE-NAME 
   2DUP CONTEXT @ SEARCH-WORDLIST-NFA
   IF
     NIP NIP
     DUP ?VOC 0= IF DROP -2011 THROW THEN  \ "unknown voc"
   ELSE
     ['] VOCABULARY EVALUATE-WITH
     LATEST 
   THEN
   NAME> 
   \ START-MODULE
   GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS
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
\  ладет в ORDER wordlist, к-ый даст "name"
\ или vocabulary если "name" - vocabulary
        DEPTH >R
        ALSO ' EXECUTE
        DEPTH R> <>             IF      \ wid on the stack?
             CONTEXT !          THEN
; IMMEDIATE

: }}
   PREVIOUS
; IMMEDIATE
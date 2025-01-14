\ $Id$

(  Working with forth modules
   Copyright [C] 2000 D.Yakimov day@forth.org.ru
)

: MODULE: ( "name" -- old-current )
\ start a forth module
\ ���� ����� ������ ��� ����������, ���������� ���������� � ����
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
\ ������ � ORDER wordlist, �-�� ���� "name"
\ ��� vocabulary ���� "name" - vocabulary
        DEPTH >R
        ALSO ' EXECUTE
        DEPTH R> <>             IF      \ wid on the stack?
             SET-ORDER-TOP      THEN
; IMMEDIATE

: }}
   PREVIOUS
; IMMEDIATE
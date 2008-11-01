\ $Id$
\ 
\ Input line with editing via readline

USE libreadline.so.5

REQUIRE STR ~ac/lib/str5.f

: /PAD 1024 1- ;
: STR>PAD ( s -- a u )
  DUP STR@ /PAD MIN >R PAD R@ CMOVE
  STRFREE
  PAD R> 2DUP + 0 SWAP C! ;

: history-filename 
  S" HOME" ENVIRONMENT? IF " {s}/.history.spf" STR>PAD ELSE S" .history.spf" THEN
  DROP ;

: start-readline-history 
   (()) using_history DROP 
   (( history-filename )) read_history DROP ;

: save-readline-history
   (( history-filename )) write_history DROP ;

..: AT-PROCESS-STARTING start-readline-history ;..
start-readline-history

..: AT-PROCESS-FINISHING save-readline-history ;..

: ACCEPT-READLINE ( c-addr +n1 -- +n2 ) \ 94
  (( 0 )) readline >R
  R@ 0 = IF RDROP -1002 THROW THEN
  (( R@ )) add_history DROP
  R@ ASCIIZ> 2SWAP ROT MIN >R R@ MOVE R>
  (( R> )) free DROP

\  TUCK TO-LOG
\  EOLN TO-LOG \ Если ввод с user-device записать cr в лог, то есть нажали Enter
;

' ACCEPT-READLINE TO ACCEPT

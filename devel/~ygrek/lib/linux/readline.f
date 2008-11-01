\ $Id$
\ 
\ Input line with editing via readline

USE libreadline.so.5

: start-readline-history (()) using_history DROP ;

..: AT-PROCESS-STARTING start-readline-history ;..
start-readline-history

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

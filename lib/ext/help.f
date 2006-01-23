\ Справка к сп-форту. После подключения наберите HELP

REQUIRE [IF] lib\include\tools.f

USER HelpWord-A
USER HelpWord-U
USER ?HelpFound
USER ?HelpGroup
USER HelpCounter
USER ?Topic

: ***g: 0 PARSE 2DROP ;

: Omit***
    BEGIN
       TIB 4 S" *** " COMPARE
       DUP 0= IF REFILL ELSE 0 THEN 0= OR
    UNTIL
;

: While*** ( f -- )
  BEGIN
    REFILL DUP 0= IF SOURCE 0 FILL THEN
  WHILE
    ?HelpGroup @ IF Omit*** FALSE ?HelpGroup ! THEN
    TIB 3 S" ***" COMPARE 0= IF DROP EXIT THEN
    DUP IF CR SOURCE TYPE
              HelpCounter @
              15 > IF HelpCounter 0! CR ." more?" KEY
                      DUP [CHAR] q =
                      OVER [CHAR] Q = OR
                      SWAP 27 = OR IF -1 THROW THEN 
                   THEN
           HelpCounter 1+!
        THEN
  REPEAT R> 2DROP
;

: *** 
   NextWord HelpWord-A @ HelpWord-U @
   COMPARE 0= DUP
   IF   TRUE ?HelpFound !
        TRUE ?HelpGroup !
   THEN
   While***
;

: TO-UPPER ( addr u -- addr u )
  2DUP
  OVER + SWAP
  ?DO
    I C@ DUP [CHAR] A 1- >
    OVER [CHAR] z 1+ < AND
    IF
      [ CHAR A CHAR a XOR INVERT ] LITERAL AND
      I C!
    ELSE DROP
    THEN
   LOOP
;

: (HELP) ( "name" -- )
   ?HelpFound 0!
   HelpCounter 0! 
   NextWord TUCK HEAP-COPY HelpWord-A !
   HelpWord-U !
   S" help.fhlp" +ModuleDirName
   ['] INCLUDE-PROBE CATCH IF DROP THEN DROP
   ?HelpFound @ 0=
   IF \ Попробуем capital letters
     HelpWord-A @ HelpWord-U @ TO-UPPER
     NIP HelpWord-U !
     S" help.fhlp" +ModuleDirName
     ['] INCLUDE-PROBE CATCH IF DROP THEN DROP
   THEN POSTPONE \
   HelpWord-A @ FREE THROW
   ?HelpFound @ 0= IF ." В справке не найдено..." CR THEN
;

: HELP  ?Topic 0! (HELP) ;
: help HELP ;
: TOPIC TRUE ?Topic ! (HELP) ;
: topic TOPIC ;


: CLR
\ Очистить экран
  50 0 DO CR LOOP 
;

.( Type HELP for help) CR
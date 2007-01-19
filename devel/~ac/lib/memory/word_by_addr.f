REQUIRE JMP           ~ac/lib/tools/jmp.f 

: VOCLIST.
     VOC-LIST @
     BEGIN
       DUP
     WHILE
       DUP CELL+ ." [" DUP . ." ]" VOC-NAME. ." +"
       @
     REPEAT DROP CR
;

USER WBW-NFA
USER WBW-OFFS

: WordByAddrWl ( addr wid -- nfa offs )
  -1 1 RSHIFT WBW-OFFS !
  WBW-NFA 0!
  DUP ?FORTH IF @
  BEGIN
    DUP
  WHILE
    2DUP - DUP 0 > 
        IF WBW-OFFS @ OVER > 
           IF WBW-OFFS ! DUP WBW-NFA !
           ELSE DROP THEN
        ELSE DROP THEN
    CDR
  REPEAT THEN 2DROP
  WBW-NFA @ WBW-OFFS @
;

USER WB-NFA
USER WB-OFFS

: WordByAddrNew ( addr -- c-addr u )
  \ найти слово, телу которого принадлежит данный адрес
  (DP) @ OVER >
  IF 
     -1 1 RSHIFT WB-OFFS !
     WB-NFA 0!
     VOC-LIST @
     BEGIN
       DUP
     WHILE
       2DUP ( addr voc addr voc )
       CELL+ WordByAddrWl ( addr voc nfa offs )
             WB-OFFS @ OVER > ( addr voc nfa offs f )
             IF WB-OFFS ! WB-NFA !
             ELSE 2DROP THEN
       @
     REPEAT 2DROP
     WB-NFA @ ?DUP IF COUNT ELSE S" <not found>" THEN
  ELSE DROP S" <not in the image>" THEN
;
' WordByAddrNew ' WordByAddr JMP

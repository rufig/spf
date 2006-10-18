

\ –аспечатать список словарей.
: VOCS
        VOC-LIST
        BEGIN @ DUP WHILE
                DUP CELL+ VOC-NAME.
                DUP 3 CELLS + @ \ wid предка
                ?DUP IF ."  defined in "  VOC-NAME.
                     ELSE ."  is the main vocabulary"
                     THEN CR
        REPEAT
        DROP
;

0x200 VALUE MAX-WORD-SIZE

\ Opposite to CDR, might be slow!
: NextNFA ( nfa1 -- nfa2 | 0 )
    NEAR_NFA SWAP >R
    BEGIN
      1+ NEAR_NFA ( nfa addr )
      OVER 0 >
      ROT R@ <> AND
      OVER R@ - MAX-WORD-SIZE > OR
    UNTIL

    DUP R> - MAX-WORD-SIZE >
    IF DROP 0
    ELSE  NEAR_NFA DROP
    THEN
;

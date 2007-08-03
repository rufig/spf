REQUIRE $! ~mak\place.f 

CREATE WDS_PAT  0x101 ALLOT

: NLST ( A -> )
  @
  >OUT 0! CR W-CNT 0!
  BEGIN
    DUP KEY? 0= AND
  WHILE
    DUP COUNT WDS_PAT COUNT SEARCH NIP NIP 
    IF W-CNT 1+! 
       DUP C@ >OUT @ + 74 >
       IF CR >OUT 0! THEN
       DUP ID.
       DUP C@ >OUT +!
       15 >OUT @ 15 MOD - DUP >OUT +! SPACES
    THEN
    CDR
  REPEAT DROP KEY? IF KEY DROP THEN
  CR CR ." Words: " W-CNT @ U. CR
;

: $WDS 
        WDS_PAT $!
        VOC-LIST
        BEGIN @ DUP WHILE
                DUP CELL+ VOC-NAME.
                DUP 3 CELLS + @ \ wid предка
                ?DUP IF ."  defined in "  VOC-NAME.
                     ELSE ."  is the main vocabulary"
                     THEN CR
		DUP CELL+ NLST
        REPEAT
        DROP
;

: WDS 
  PARSE-NAME $WDS ;

\EOF

WDS +

16384 CONSTANT InBufSize

USER InBufLen
USER-VALUE InBuf
USER InBufPos

: read-char                             ( file -- char 0 | -1 )
        InBufPos @ InBufLen @ <
        IF
          DROP
          InBufPos DUP @ InBuf + C@
          SWAP 1+! 0
        ELSE
          InBuf InBufSize ROT READ-FILE THROW ?DUP
          IF
            InBufLen ! 
            1 InBufPos ! 
            InBuf C@ 0
          ELSE
            -1
          THEN
        THEN
;


(
: test { \ file -- }
  S" rnd.f" R/O OPEN-FILE THROW -> file
  InBufSize ALLOCATE THROW TO InBuf
  
  BEGIN
    file read-char DUP INVERT
    IF SWAP EMIT THEN
  UNTIL 
  file CLOSE-FILE THROW
  InBuf FREE THROW
;


test
)
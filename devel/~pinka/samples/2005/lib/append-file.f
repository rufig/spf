\ 09.Dec.2004
\ $Id$

: 9REPOSITION-FILE ( fileid -- ior )
\ Reposition the file identified by fileid to end of file.
\ see also  ~pinka\lib\FileExt.f # TOEND-FILE
  DUP >R   FILE-SIZE  ( fileid -- ud ior ) 
  ?DUP IF R> DROP NIP NIP EXIT THEN
  R> REPOSITION-FILE  ( ud fileid -- ior ) 
;
: ATTACH ( a u a-file u-file -- )
  2DUP FILE-EXIST 0= IF
    2DUP W/O CREATE-FILE THROW
    CLOSE-FILE THROW
  THEN
  W/O OPEN-FILE-SHARED THROW >R
  R@ 9REPOSITION-FILE ?DUP 0= IF R@ WRITE-FILE THEN
  R> CLOSE-FILE SWAP THROW THROW
;
: ATTACH-LINE ( a u a-file u-file -- )
  2DUP 2>R ATTACH
  LT LTL @ 2R> ATTACH
;
: ATTACH-CATCH ( a u a-file u-file -- ior )
  ['] ATTACH CATCH
  DUP IF NIP NIP NIP NIP THEN
;
: ATTACH-LINE-CATCH ( a u a-file u-file -- ior )
  ['] ATTACH-LINE CATCH
  DUP IF NIP NIP NIP NIP THEN
;

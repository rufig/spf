REQUIRE WTHROW lib/win/winerr.f

: FileSize ( h -- s )
  0 SWAP GetFileSize
  DUP -1 = ABORT" Error in FileSize."
;

: BytesToTrunc ( h s -- b )
  SWAP FileSize SWAP -
;

: ReadFileToHeap ( h u -- addr u )
  DUP ALLOCATE THROW DUP >R
  SWAP ROT
  READ-FILE THROW
  R>
  SWAP
;

: ReadFileFrom ( h b -- addr u )
  2DUP
  S>D ROT
  REPOSITION-FILE THROW
  OVER FileSize SWAP -
  ReadFileToHeap
;

: WriteFileFromHeap ( addr u h -- )
  WRITE-FILE THROW
;

: TruncFileByHandle ( h s -- )
  OVER SWAP
  BytesToTrunc DUP 0 > IF ( h b )
    OVER >R
    ReadFileFrom
    OVER SWAP
    0. R@ REPOSITION-FILE THROW
    R@ WriteFileFromHeap
    R> SetEndOfFile WTHROW DROP
    FREE THROW
  ELSE
    2DROP
  THEN
;

: TruncFile ( s addr u -- )
  R/W OPEN-FILE THROW
  DUP ROT
  TruncFileByHandle
  CLOSE-FILE THROW
;

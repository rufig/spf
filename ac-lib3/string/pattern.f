: EvalPattern ( addr u h -- )
  { a u hd \ t tl i o h }
  >IN @ -> i #TIB @ -> tl TIB -> t H-STDOUT -> o
  512 ALLOCATE THROW TO TIB 510 TO C/L
  a u 2DUP TYPE R/O OPEN-FILE THROW -> h
  hd TO H-STDOUT
  BEGIN
    TIB C/L h READ-LINE THROW
  WHILE
    #TIB ! >IN 0!
    BEGIN
      [CHAR] % PARSE TYPE
      [CHAR] % PARSE DUP
    WHILE
      ['] EVALUATE CATCH DROP TYPE
    REPEAT
    2DROP CR
  REPEAT
  DROP
  h CLOSE-FILE THROW
  hd CLOSE-FILE THROW
  TIB FREE THROW
  o TO H-STDOUT i >IN ! tl #TIB ! t TO TIB
;

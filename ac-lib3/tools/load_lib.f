: LoadInitLibrary ( addr u -- h ior )
  2DUP 2>R
  DROP LoadLibraryA DUP 0=
  IF DROP 2R> 2DROP GetLastError EXIT THEN
  WINAPLINK @
  BEGIN
    DUP
  WHILE
    DUP CELL- CELL- @ ASCIIZ> 2R@ COMPARE 0=
        IF
           OVER >R DUP CELL- @ R> GetProcAddress DUP 0=
           IF DROP 2DROP 2R> 2DROP GetLastError EXIT THEN
           OVER CELL- CELL- CELL- !
        THEN
    @
  REPEAT
  2R> 2DROP
;

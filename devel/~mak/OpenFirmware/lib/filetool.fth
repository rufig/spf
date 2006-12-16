REQUIRE [IF] ~mak/CompIF.f

\ Some convenience words for dealing with files.


\ linefeed constant newline

\ Handy file descriptor variables
VARIABLE IFD
VARIABLE OFD

: $READ-OPEN  ( name$ -- )
   2DUP R/O OPEN-FILE  IF      ( name$ x )
      DROP  ." Can't open " TYPE ."  for reading." CR ABORT
   THEN                        ( name$ fd )
   IFD !                       ( name$ )
   2DROP
;
: READING  ( "filename" -- )  PARSE-NAME $READ-OPEN  ;

: $WRITE-OPEN  ( name$ -- )
   2DUP R/W OPEN-FILE  IF      ( name x )
      DROP  ." Can't open " TYPE ."  for writing." CR ABORT
   THEN                        ( name$ fd )
   OFD !                       ( name$ )
   2DROP
;
: $NEW-FILE  ( name$ -- )
   2DUP R/W CREATE-FILE  IF    ( name$ x )
      DROP  ." Can't create " TYPE  CR ABORT
   THEN                        ( name$ fd )
   OFD !                       ( name$ )
   2DROP
;
: WRITING  ( "filename" -- )
  PARSE-NAME $NEW-FILE  ;

0 [IF]
: $APPEND-OPEN  ( name$ -- )
   2DUP R/W OPEN-FILE  IF                               ( name$ ior )
      \ We have to make the file
      DROP $NEW-FILE                                    ( )
   ELSE  \ The file already exists, so seek to the end  ( name$ fd )
      OFD !  2DROP                                      ( )
      0 OFD @ FSEEK-FROM-END                            ( )
   THEN
;
: APPENDING  ( "filename" -- )  SAFE-PARSE-WORD $APPEND-OPEN  ;
[THEN]
: $FILE-EXISTS?  ( name$ -- flag ) \ True if the named file already exists
   R/O OPEN-FILE  IF  DROP FALSE  ELSE  CLOSE-FILE DROP TRUE  THEN
;
0 [IF]
: $FILE,  ( adr len -- )
   R/O ( BIN OR )  OPEN-FILE  ABORT" Can't open file"  IFD !

   HERE   IFD @ FSIZE DUP ALLOT                    ( adr len )
   2DUP   IFD @ FGETS  OVER <> ABORT" Short read"  ( adr len )
   IFD @ FCLOSE                                    ( adr len )
   NOTE-STRING  2DROP   \ Mark as a sequence of bytes
;
[THEN]

\ Backwards compatibility ...

: READ-OPEN     ( name-pstr -- )  COUNT $READ-OPEN    ;
: WRITE-OPEN    ( name-pstr -- )  COUNT $WRITE-OPEN   ;
: NEW-FILE      ( name-pstr -- )  COUNT $NEW-FILE     ;
\ : APPEND-OPEN   ( name-pstr -- )  COUNT $APPEND-OPEN  ;
\EOF
: FILE-EXISTS?  ( name-pstr -- flag ) \ True if the named file already exists
   READ FOPEN  ( fd )   DUP   IF  FCLOSE TRUE  THEN
;

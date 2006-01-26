REQUIRE GET-FILE-LASTWRITETIME ~ac/lib/win/file/filetime.f 

: FILE-INTERNALDATE ( h -- addr u )
  >R <<# Zone# BL HOLD
  R> GET-FILE-LASTWRITETIME >R 2>R
  SWAP ROT Time# BL HOLD
  2R> R> #N [CHAR] - HOLD
  DateM>S HOLDS [CHAR] - HOLD #N## #>
;
: FILENAME-INTERNALDATE ( addr u -- addr2 u2 ) \ локальное время с указанием смещения
  R/O OPEN-FILE
  IF DROP S" 23-Jun-2000 23:06:00 +0200"
  ELSE DUP FILE-INTERNALDATE ROT CLOSE-FILE THROW THEN  
;
: FILE-UDATE ( h -- addr u )
  >R <<# \ Zone# BL HOLD
  R> GET-FILE-LASTWRITETIME >R 2>R
  SWAP ROT Time# BL HOLD
  2R> R> ROT #N## [CHAR] - HOLD
  SWAP #N## [CHAR] - HOLD #N #>
;
: FILENAME-UDATE ( addr u -- addr2 u2 ) \ локальное время
  R/O OPEN-FILE
  IF DROP S" 2000-06-23 23:06:00"
  ELSE DUP FILE-UDATE ROT CLOSE-FILE THROW THEN  
;

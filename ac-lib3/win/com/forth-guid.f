REQUIRE ComInit ~ac/lib/win/com/com.f

: ComCreateForthGUID
  PAD ComCreateGUID . PAD 16 DUMP
  S" ForthGUID.bin" R/W CREATE-FILE THROW >R
  PAD 16 R@ WRITE-FILE THROW
  R> CLOSE-FILE THROW
  PAD CLSID>String . ( guid_text)
  S" ForthGUID.txt" R/W CREATE-FILE THROW >R
  ( guid_text) R@ WRITE-FILE THROW
  R> CLOSE-FILE THROW
;
: ComGetForthGUID ( addr -- )
  S" ForthGUID.bin" R/O OPEN-FILE
  IF DROP S" C:\SPF\~AC\LIB\win\com\samples\ForthGUID.bin" R/O OPEN-FILE THROW THEN
  >R
  16 R@ READ-FILE THROW DROP
  R> CLOSE-FILE THROW
;

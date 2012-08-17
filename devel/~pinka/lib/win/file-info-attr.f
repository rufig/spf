\ Determining file attributes

REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f  \ to access fields via Q@ and T@

REQUIRE FOR-FILE1-PROPS ~ac/lib/win/file/fileprop.f
REQUIRE LAMBDA{         ~pinka/lib/lambda.f


\ http://msdn.microsoft.com/en-us/library/gg258117.aspx
0x1 CONSTANT FILE_ATTRIBUTE_READONLY
0x2 CONSTANT FILE_ATTRIBUTE_HIDDEN
0x4 CONSTANT FILE_ATTRIBUTE_SYSTEM


: FILENAME-ATTRIBUTES ( d-txt-filename -- flags )
  0 -ROT \ 0 if the file is not exists
  LAMBDA{ ( 0 addr u data -- flag )
    >R 2DROP DROP
    R> dwFileAttributes T@
  } FOR-FILE1-PROPS
;

: FILENAME-SYSTEM ( d-txt-filename -- flag )
  FILENAME-ATTRIBUTES FILE_ATTRIBUTE_SYSTEM AND 0<>
;
: FILENAME-HIDDEN ( d-txt-filename -- flag )
  FILENAME-ATTRIBUTES FILE_ATTRIBUTE_HIDDEN AND 0<>
;

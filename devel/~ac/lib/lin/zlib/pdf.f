\ zipû גוחהו...

REQUIRE zlib_uncompress ~ac/lib/lin/zlib/zlib.f 
REQUIRE STR@            ~ac/lib/str5.f
REQUIRE SBetween        ~ac/lib/string/between.f 

S" SEAforth-24A_Data_Sheet.pdf" FILE " FlateDecode>>stream{CRLF}" STR@ " {CRLF}endstream" STR@ SBetween 
2DUP . . 2DUP 80 MIN DUMP CR zlib_uncompress 2DUP . . CR 300 MIN TYPE

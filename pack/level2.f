REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f 
REQUIRE /STRING                 lib/include/string.f
REQUIRE 2CONSTANT               lib/include/double.f 
REQUIRE NOT                     ~profit/lib/logic.f

REQUIRE SPLIT                   ~pinka/samples/2005/lib/split.f
REQUIRE SPLIT-WHITE-FORCE       ~pinka/samples/2005/lib/split-white.f
REQUIRE COMPARE-U               ~ac/lib/string/compare-u.f      \ ASCII only
REQUIRE UPPERCASE               ~ac/lib/string/uppercase.f      \ ASCII only

REQUIRE LAMBDA{                 ~pinka/lib/lambda.f
REQUIRE {                       lib/ext/locals.f

REQUIRE STRUCT:                 lib/ext/struct.f

REQUIRE RENAME-FILE             ~pinka/lib/FileExt.f
REQUIRE RENAME-FILE-OVER        ~pinka/lib/FileExt2.f           \ WinNT-family only
REQUIRE ATTACH-LINE             ~pinka/samples/2005/lib/append-file.f 
REQUIRE LAY-PATH                ~pinka/samples/2005/lib/lay-path.f 

[UNDEFINED] lexicon.level2 [IF] TRUE CONSTANT lexicon.level2 [THEN]

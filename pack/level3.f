REQUIRE lexicon.level2          pack/level2.f

REQUIRE enqueueNOTFOUND         ~pinka/samples/2006/core/trans/nf-ext.f
REQUIRE HEAP-ID                 ~pinka/spf/mem.f

REQUIRE INCLUDED-WITH           ~pinka/lib/ext/include.f
REQUIRE Included                ~pinka/lib/ext/requ.f
REQUIRE TIME&DATE               lib/include/facil.f 

REQUIRE LIKE                    ~pinka/lib/like.f
REQUIRE HASH@                   ~pinka/lib/hash-table.f 
REQUIRE STR@                    ~ac/lib/str5.f
REQUIRE replace-str-            ~pinka/samples/2005/lib/replace-str.f

REQUIRE WDS                     ~mak/WDS.F      \ words by given part
REQUIRE .elapsed                ~af/lib/elapse.f
REQUIRE /TEST                   ~profit/lib/testing.f

[UNDEFINED] lexicon.level3 [IF] TRUE CONSTANT lexicon.level3 [THEN]

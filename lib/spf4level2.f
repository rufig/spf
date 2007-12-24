REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f 
REQUIRE /STRING                 lib/include/string.f
REQUIRE 2CONSTANT               lib/include/double.f 
REQUIRE TIME&DATE               lib/include/facil.f 
REQUIRE NOT                     ~profit/lib/logic.f
REQUIRE enqueueNOTFOUND         ~pinka/samples/2006/core/trans/nf-ext.f
REQUIRE HEAP-ID                 ~pinka/spf/mem.f
REQUIRE {                       lib/ext/locals.f 
REQUIRE LAMBDA{                 ~pinka/lib/lambda.f
REQUIRE .elapsed                ~af/lib/elapse.f
REQUIRE /TEST                   ~profit/lib/testing.f
REQUIRE WDS                     ~mak/WDS.F  \ list of words contains given part

\ REQUIRE CORE_OF_REFILL          ~pinka/spf/fix-refill.f \ patch for accept and refill
\ REQUIRE INCLUDED-WITH           ~pinka/lib/ext/include.f
\ REQUIRE Included                ~pinka/lib/ext/requ.f
\ REQUIRE F.                      lib/include/float2.f
\ REQUIRE TYPE>STR                ~ygrek/lib/typestr.f

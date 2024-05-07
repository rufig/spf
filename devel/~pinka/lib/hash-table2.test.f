
REQUIRE new-hash ~pinka/lib/hash-table2.f

REQUIRE AsQName ~pinka/spf/quoted-word.f

REQUIRE TESTCASES ~ygrek/lib/testcase.f


TESTCASES hash-table

50 new-hash VALUE h

(( h hash-count -> 0 ))

`aaa `A h HASH!
`bbb `B h HASH!
`ccc `C h HASH!

CR h :NONAME TYPE SPACE TYPE CR ; for-hash-txt

(( h hash-count -> 3 ))
(( `B h HASH@ `bbb EQUALS -> -1 ))

`B h -HASH
(( `B h HASH@ 0. D= -> -1 ))

(( h hash-count -> 2 ))
(( h hash-empty? -> 0 ))
(( h clear-hash -> ))
(( h hash-empty? -> -1 ))

END-TESTCASES

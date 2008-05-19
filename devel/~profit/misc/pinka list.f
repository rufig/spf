REQUIRE list+ ~pinka/lib/list.f
: list=> ( list --> value \ <-- ) R> SWAP List-ForEach ;

VARIABLE r


2 CELLS ALLOCATE THROW DUP . r list+
2 CELLS ALLOCATE THROW DUP . r list+

CR
:NONAME r list=> . ; EXECUTE
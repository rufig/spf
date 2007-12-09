\ REQUIRE MemReport ~day/lib/memreport.f

REQUIRE { ~ac/lib/str5.f

: r { a b -- } a b + " {#a}+{#b}={n}" STYPE ;
1 2 r
\ \EOF

: z ( addr u f -- ) IF S" rules!" ELSE S" sucks!" THEN
2SWAP
" Whatever you do, {s} {s}" STYPE ;

CR S" Forth" TRUE z
CR S" Basic" FALSE z


: r ( a b -- )
2DUP + -ROT SWAP ( a+b b a )
" {n}+{n}={n}" STYPE ;
CR 1 2 r

\ MemReport
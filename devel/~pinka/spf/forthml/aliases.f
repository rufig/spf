\ 17.Feb.2007

\ набор синонимов для избегания маскировки в xml

REQUIRE & ~pinka/spf/compiler/index.f

\ & ( c-addr u -- xt )

: aka ( olda oldu newa newu -- ) 2>R & 2R> ALIAS ;

`<>  `NEQ   aka
`=   `EQ    aka
`0<  `0LT   aka
`0<> `0NEQ  aka
`0=  `0EQ   aka
`U<  `ULT   aka
`U>  `UGT   aka

\EOF

`U<  `Ult   aka
`U>  `Ugt   aka

`>R  `gtR   aka
`R>  `Rgt   aka
`2>R `2gtR  aka
`2R> `2Rgt  aka

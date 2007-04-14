\ 17.Feb.2007

\ набор синонимов для избегания маскировки в xml

REQUIRE & ~pinka/spf/compiler/index.f

\ & ( c-addr u -- xt )

: aka ( olda oldu newa newu -- ) 2>R & 2R> ALIAS ;

`<>  `neq   aka
`=   `eq    aka
`0<  `0lt   aka
`0<> `0neq  aka
`0=  `0eq   aka
`U<  `Ult   aka
`U>  `Ugt   aka
`>R  `gtR   aka
`R>  `Rgt   aka
`2>R `2gtR  aka
`2R> `2Rgt  aka

`D>S     `DgtS      aka
`>NUMBER `gtNUMBER  aka

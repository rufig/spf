\ 17.Feb.2007

\ набор синонимов для избегания маскировки в xml

REQUIRE NAMING- ~pinka/spf/compiler/index.f

\ & ( c-addr u -- xt )

: aka ( olda oldu newa newu -- ) 2SWAP  &  NAMING  ;

`<>  `NEQ   aka
`<>  `NE    aka
`=   `EQ    aka
`0<  `0LT   aka
`0<> `0NEQ  aka
`0<> `0NE   aka
`0=  `0EQ   aka
`U<  `ULT   aka
`U>  `UGT   aka
`D0= `D0EQ  aka

: 0GT NEGATE 0LT ;


\ 28.Jun.2008
\ В XPath 2.0 используются: eq, ne, lt, le, gt, ge
\ -- http://www.w3.org/TR/xpath20/#id-value-comparisons

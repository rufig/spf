\ Long string
\ REQUIRE @+ ~nn/lib/tools.f

: XCOUNT DUP CELL+ SWAP @ ;

: XSLITERAL-CODE  R> XCOUNT 2DUP + CHAR+ >R ;

: XSLITERAL
  STATE @ IF
             ['] XSLITERAL-CODE COMPILE,
             DUP ,
             HERE SWAP DUP ALLOT MOVE 0 C,
          ELSE
             2DUP + 0 SWAP C!
          THEN
; IMMEDIATE

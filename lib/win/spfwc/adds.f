\ подключение дополнительных либ

S" lib\ext\spf-asm.f" INCLUDED
S" lib\ext\disasm.f"  INCLUDED
REQUIRE VOCS          lib\ext\vocs.f
REQUIRE F.            lib\include\float2.f
REQUIRE NextFrom     ~af\lib\4interp.f
REQUIRE (*           ~af\lib\comments.f
REQUIRE [[           ~yz\lib\automate.f

: SLITERAL2 \ замена стандартного SLITERAL -
\ в режиме интерпретации строка переносится в 
\ динамическую память. Так предсказуемей, но появляется утечка памяти.
  STATE @ IF
    ['] _SLITERAL-CODE COMPILE,
    DUP C,
    HERE SWAP DUP ALLOT MOVE 0 C,
  ELSE
    TUCK HEAP-COPY SWAP
  THEN
; IMMEDIATE
' SLITERAL2 ' SLITERAL REPLACE-WORD


FALSE WARNING !
MDSW: FOREACH FOREACH
MDSW; NEXT NEXT
TRUE WARNING !

: >_double ( -- d ; f: f -- )
\ берет число с вещественного стека и кладет его на стек параметров
\ в COM-совместимом виде
  FLOAT>DATA SWAP
;
: _double> ( d -- ; f: -- f )
  SWAP DATA>FLOAT
;

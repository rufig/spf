REQUIRE TIME&DATE lib/include/facil.f

CREATE ƒней¬ћес€це 31 C, 28 C, 31 C,  30 C, 31 C, 30 C,  31 C, 31 C, 30 C,  31 C, 30 C, 31 C,

: ƒнейƒоЌачалаћес€ца
  1- 0 MAX  0 SWAP 0 ?DO ƒней¬ћес€це I + C@ + LOOP
;
: ƒнейƒоЌачала√ода
  1900 - DUP 3 + 4 / SWAP 365 * +
;
: ?¬исокосный
  4 MOD 0=
;
: >ƒата ( день мес€ц год -- число )
  DUP ?¬исокосный IF 29 ELSE 28 THEN ƒней¬ћес€це 1+ C!
  ƒнейƒоЌачала√ода
  SWAP ƒнейƒоЌачалаћес€ца + +
  1+ \ дл€ совместимости с MS Access считаем даты с 30.12.1899
;
: ћес€цƒень
  1+
  12 0 DO
       ƒней¬ћес€це I + C@
       -
       DUP 0 > 0= IF ƒней¬ћес€це I + C@ + I 1+ UNLOOP EXIT THEN
       LOOP 0
;
: ƒата> ( число -- день мес€ц год )
  2- DUP
  100 36525 */ ( год-1900 )
  1900 + DUP >R
  DUP ?¬исокосный IF 29 ELSE 28 THEN ƒней¬ћес€це 1+ C!
  ƒнейƒоЌачала√ода -
  ћес€цƒень R>
;
: ƒата>S ( дата -- addr u )
  ƒата> S>D <# # # # # [CHAR] . HOLD
               >R + R> # # [CHAR] . HOLD
               >R + R> # # #>
;
: >ƒата:
  BL SKIP [CHAR] . WORD ?LITERAL [CHAR] . WORD ?LITERAL BL WORD ?LITERAL
  >ƒата
;
: “екуща€ƒата
  TIME&DATE >ƒата NIP NIP NIP
;
: ƒата.
  ƒата>S TYPE
;
: “екуща€ƒата.
  “екуща€ƒата ƒата.
;
: “екущее¬рем€.
  TIME&DATE 2DROP DROP
  0 <# [CHAR] : HOLD # # #> TYPE
  0 <# [CHAR] : HOLD # # #> TYPE
  0 <# # # #> TYPE
;
: >Date ( addr u -- date )
  TIB >R >IN @ >R #TIB @ >R
  #TIB ! >IN 0! TO TIB ['] >ƒата: CATCH
  R> #TIB ! R> >IN ! R> TO TIB
  THROW
;
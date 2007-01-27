\ timestamp â äàòó
\ è íàîáîğîò
\
\ NB - Ïîêà ÷òî íåêîğğåêòíî ğàáîòàåò (èç-çà âèñîêîñíûõ ãîäîâ).

REQUIRE d01011970 ~ac/lib/win/date/unixdate.f

: Num>Date ( n -- s m h d m1 y )
   60 /MOD \ ñåêóíäû
   60 /MOD \ ìèíóòû
   24 /MOD \ ÷àñû
   100 * 36525 /MOD
   >R
   100 / \ äíåé îò íà÷àëà ãîäà
   ÌåñÿöÄåíü \ äåíü ìåñÿö
   R> 1970 + \ ãîä
   ;

: Date>Num ( s m h d m1 y -- n )
  >Äàòà d01011970 - SecsPerDay * SWAP
  3600 * + SWAP 
  60 * + + ;

\ 1000000 Num>Date Date>Num .

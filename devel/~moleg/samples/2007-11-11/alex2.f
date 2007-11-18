( ÎÏÐÅÄÅËÈÒÅËÜÍÎÅ ÑËÎÂÎ ÄËß ÏÎËÓ×ÅÍÈß ÑÒÅÏÅÍÅÉ ×ÈÑËÀ ÄÂÀ )
: _2POWER
   CREATE ( n - )   1 DUP , SWAP  0 ?DO  2* DUP ,  LOOP  DROP
   DOES> ( n - 2^n )  SWAP CELLS + @ ;

( ÑÒÅÏÅÍÈ ÄÂÎÉÊÈ ÎÒ 2^0 ÄÎ 2^31 )
32 _2POWER  2POWER

( ïîëó÷åíèå ðåâåðñà ÷èñëà)
: REVCELL ( # - # )
   DUP IF  DEPTH >R
      32 0 ?DO  DUP 0< IF  I 2POWER SWAP  THEN  2*  LOOP  DROP
      DEPTH R> - 0 ?DO OR LOOP
   THEN ;

: revarr ( addr # -  )
   0 ?DO  DUP @  REVCELL OVER !  CELL+  LOOP  DROP ;

REQUIRE CountProfile ..\tester.f

1 VALUE N

S" samples\bench\queens.f" INCLUDED
S" samples\bench\bubble.f" INCLUDED

.( ----- queens: )
' test N NCountProfile CR
.( ----- bubble: )
' MAIN N NCountProfile CR

S" index.f" INCLUDED 
CR

s" samples\bench\queens.f" INCLUDED
s" samples\bench\bubble.f" INCLUDED

ONLY  
    .( ----- ZVM: queens: )
    ZOP:: ' test ZS>  N NCountProfile CR
    .( ----- ZVM: bubble: )
    ZOP:: ' MAIN ZS>  N NCountProfile CR
ZOP

\ 03.Sep.2004
\ queens:
\         1 |       12,933,441 |     12,933,441 | ProfilingXt
\         1 |      428,945,823 |    428,945,823 | ProfilingXt

( Итого, выполнением queens в некой VFM над SPF
  в  30 с лишним  раз медленней, чем в самом SPF.
  Выполнении bubble - в 20 раз медленней.

  VFM эта полностью хостится на SPF, сама реализует
  лишь стек параметров.
)

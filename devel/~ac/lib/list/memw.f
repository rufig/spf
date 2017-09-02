1001000 CONSTANT /MBL
0
CELL -- mb.Next
CELL -- mb.Offs
/MBL -- mb.Addr
CONSTANT /MB

VECT vMbFlush ' NOOP TO vMbFlush
USER MemwStep

: MEMW_ERR ( addr u -- )
  R>
     CR ." MEMW_ERR:(" R@ WordByAddr TYPE ." <-" R> R@ WordByAddr TYPE >R ." )="
  >R
  TYPE CR
;
USER MemwMB
USER MemwOffs
USER MemwSize

: (MEMW) ( addr u mb1 -- mb2 )
  
  1 MemwStep !
  2 MemwStep ! DUP 0= IF NIP NIP S" zero_mb" MEMW_ERR EXIT THEN \ не инициализировано
  3 MemwStep ! DUP 0x10000 < IF DUP . NIP NIP S" too_low_mb" MEMW_ERR EXIT THEN \ подозрительное значение указателя
  4 MemwStep ! OVER 0< IF NIP NIP S" negative_u" MEMW_ERR EXIT THEN \ подозрительное значение размера

  5 MemwStep ! OVER /MBL > IF OVER ." memw_size=" . NIP NIP S" will_overflow" MEMW_ERR EXIT THEN \ записываемая порция больше допустимого
  >R
  DUP R@ mb.Offs @ + /MB <
  IF 6 MemwStep ! R@ mb.Addr R@ mb.Offs @ + SWAP DUP R@ mb.Offs +! CMOVE R> EXIT THEN

  \ сюда доходим, если в текущий буфер не влазит, но записываемый размер меньше грануляции буферов, 
  \ т.е. надо выделить новый, и в него поместится,
  \ либо отправить текущий и использовать его заново

  7 MemwStep !
  R@ vMbFlush \ если возвращает 0, то можно использовать тот же буфер, иначе надо выделить новый и добавить в цепочку:
  IF
    8 MemwStep !
    S" will_alloc" MEMW_ERR
    \ добавляемся в очередь на реальный flush
    /MB ALLOCATE THROW DUP R> mb.Next ! >R
  THEN

  9 MemwStep ! 
    R@ mb.Addr               R@ MemwMB !
       R@ mb.Offs @          DUP MemwOffs !
         + SWAP              DUP MemwSize !
           DUP R@ mb.Offs +! CMOVE R>
  10 MemwStep !
;
: MEMW1 ( addr u mb1 -- mb2 )
  ['] (MEMW) CATCH ?DUP
  IF . S" <-MEMW_EXCEPTION" MEMW_ERR ." ST=" MemwStep @ . 
 MemwMB @ ." MB=" .
 MemwOffs @ ." Offs=" .
 MemwSize @ ." Size=" .

     CR NIP NIP EXIT
  THEN
;
: MEMW ( addr u mb1 -- mb2 )
  BEGIN
    OVER /MBL > \ записываемая порция больше допустимого? надо дробить на части
  WHILE
    SWAP /MBL - >R ( addr mb1 )
    OVER /MBL ( addr mb1 addr u1 )
    ROT MEMW1 ( addr mb2 )
    SWAP /MBL + SWAP R> SWAP ( addr u2 mb2 )
  REPEAT
  MEMW1 \ запись последней части
;
USER _MB
: MEMC, ( byte mb1 -- mb2 )
  SWAP _MB !
  _MB 1 ROT MEMW
;
: MEM, ( x mb1 -- mb2 )
  SWAP _MB !
  _MB 4 ROT MEMW
;

: M+ ( mb addr u -- mb )
  ROT MEMW
;
USER MB
USER MB1 \ вход в список буферов

: mW ( addr u -- )
  MB @ MEMW MB !
;
: mC, ( byte -- )
  MB @ MEMC, MB !
;
: m, ( x -- )
  MB @ MEM, MB !
;
: mFree ( -- )
  MB1 @
  BEGIN
    DUP
  WHILE
    DUP mb.Next @ SWAP FREE THROW
  REPEAT
  MB1 !
;
: mInit ( size -- )
  mFree
  DUP 0= IF DROP /MB THEN ALLOCATE THROW DUP MB ! MB1 !
;
: mFE ( xt -- )
  >R
  MB1 @
  BEGIN
    DUP
  WHILE
    DUP mb.Addr
    OVER mb.Offs @ R@ EXECUTE
    mb.Next @
  REPEAT DROP RDROP
;

\EOF

mInit

S" test1" mW
S" test2" mW
S" test3" mW
PAD 700 mW
PAD 700 mW

' TYPE mFE

\EOF

MB @
S" test1" M+
S" test2" M+
S" test3" M+

PAD 700 M+ DUP .

PAD 700 M+ DUP .


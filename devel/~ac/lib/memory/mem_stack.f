( "—тековое" управление пам€тью.
  ѕереопредел€ютс€ слова ALLOCATE, FREE и HEAP-COPY дл€ ведени€
  вторичного [после ќ—] списка выделенных в хипе блоков.

  »спользование:

  MARK_MEM 
  работа с хипом
  FREE_MEM

  MARK_MEM устанавливает "пометку" в хипе. 
  FREE_MEM удал€ет все неосвобожденные программой блоки вплоть 
  до последней по времени MARK_MEM. —ледующий FREE_MEM освободит
  до пометки предыдущего MARK_MEM, и т.д. ≈сли пометок не было,
  то FREE_MEM освобождает всю пам€ть, выделенную потоком с момента
  подключени€ библиотеки или с момента инициализации MEM_STACK_PTR
  [при старте потока, например]

  ѕри MEM_DEBUG ON выводитс€ трассировка использовани€ пам€ти.

)


USER MEM_STACK_PTR
VARIABLE MEM_DEBUG

: STACK_MEM ( addr -- )
  2 CELLS ALLOCATE THROW >R
  ( addr ) R@ CELL+ !
  MEM_STACK_PTR @ R@ !
  R> MEM_STACK_PTR !
;
: ALLOCATE ( size -- addr ior )
  ALLOCATE DUP IF EXIT THEN
  OVER STACK_MEM
  MEM_DEBUG @
  IF
   ." <m"  OVER .
\   ." (" R@ WordByAddr TYPE ." ):"
  THEN
;
: MS_FREE 
  MEM_DEBUG @
  IF
\   ." :(" R@ WordByAddr TYPE ." )"
   SPACE DUP . ." M!>" CR
  THEN
  FREE
;

: FREE ( addr -- ior )
  MEM_DEBUG @
  IF
\   ." :(" R@ WordByAddr TYPE ." )"
   SPACE DUP . ." m>" CR
  THEN
  >R
  MEM_STACK_PTR
  BEGIN
    DUP @ \ пераметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ R@ =
    IF R> FREE >R
       DUP @ DUP >R @ SWAP ! \ исключили из списка записью след.элемента
       R> FREE THROW
       R> EXIT
    THEN
    @
  REPEAT DROP RDROP
  301 \ элемент, который прос€т освободить, не был выделен
;
: HEAP-COPY ( addr u -- addr1 ) \ опеределим заново, т.к. может использоватьс€
\ скопировать строку в хип и вернуть еЄ адрес в хипе
  DUP 0< IF 8 THROW THEN
  DUP 1+ ALLOCATE THROW DUP >R
  SWAP DUP >R MOVE
  0 R> R@ + C! R>
;
: MARK_MEM ( -- )
  73 STACK_MEM
;
: FREE_MEM ( -- )
  MEM_STACK_PTR @
  BEGIN
    DUP
  WHILE
    DUP CELL+ @ 73 = \ достигли отметки?
    IF DUP @ MEM_STACK_PTR ! MS_FREE THROW EXIT THEN
    \ не достигли - освобождаем парочку и продолжаем
    DUP CELL+ @ MS_FREE THROW
    DUP @ SWAP MS_FREE THROW
  REPEAT \ освободили весь список, но не нашли отметку!
  MEM_STACK_PTR !
;

\ TRUE MEM_DEBUG !

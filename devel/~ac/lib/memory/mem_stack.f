( "Стековое" управление памятью.
  Переопределяются слова ALLOCATE, FREE и HEAP-COPY для ведения
  вторичного [после ОС] списка выделенных в хипе блоков.

  Использование:

  MARK_MEM 
  работа с хипом
  FREE_MEM

  MARK_MEM устанавливает "пометку" в хипе. 
  FREE_MEM удаляет все неосвобожденные программой блоки вплоть 
  до последней по времени MARK_MEM. Следующий FREE_MEM освободит
  до пометки предыдущего MARK_MEM, и т.д. Если пометок не было,
  то FREE_MEM освобождает всю память, выделенную потоком с момента
  подключения библиотеки или с момента инициализации MEM_STACK_PTR
  [при старте потока, например]

  При MEM_DEBUG ON выводится трассировка использования памяти.

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
   ." (" R@ WordByAddr TYPE ." ):"
  THEN
;
: MS_FREE 
  MEM_DEBUG @
  IF
   ." :(" R@ WordByAddr TYPE ." )"
   SPACE DUP . ." M!>" CR
  THEN
  FREE
;

: FREE ( addr -- ior )
  MEM_DEBUG @
  IF
   ." :(" R@ WordByAddr TYPE ." )"
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
  301 \ элемент, который просят освободить, не был выделен
;
: RESIZE ( a-addr1 u -- a-addr2 ior ) \ 94 MEMORY
  MEM_DEBUG @
  IF
   ." :RS(" R@ WordByAddr TYPE ." )"
   SPACE OVER . ." m>" CR
  THEN
  >R >R
  MEM_STACK_PTR
  BEGIN
    DUP @ \ пераметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ R@ =
    IF R> R> RESIZE 2>R
       DUP @ DUP >R @ SWAP ! \ исключили из списка записью след.элемента
       R> MS_FREE THROW
       2R> OVER STACK_MEM EXIT
    THEN
    @
  REPEAT DROP R> RDROP
  301 \ элемент, который просят освободить, не был выделен
;
: HEAP-COPY ( addr u -- addr1 ) \ опеределим заново, т.к. может использоваться
\ скопировать строку в хип и вернуть её адрес в хипе
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

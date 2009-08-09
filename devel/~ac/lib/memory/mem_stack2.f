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

WARNING @ WARNING 0!
: ALLOCATE ( u -- a-addr ior ) \ 94 MEMORY
\ Распределить u байт непрерывного пространства данных. Указатель пространства 
\ данных не изменяется этой операцией. Первоначальное содержимое выделенного 
\ участка памяти неопределено.
\ Если распределение успешно, a-addr - выровненный адрес начала распределенной 
\ области и ior ноль.
\ Если операция не прошла, a-addr не представляет правильный адрес и ior - 
\ зависящий от реализации код ввода-вывода.

\ SPF: ALLOCATE выделяет одну лишнюю ячейку перед областью данных
\ для "служебных целей" (например, хранения класса созданного объекта)
\ по умолчанию заполняется адресом тела процедуры, вызвавшей ALLOCATE

  CELL+ 8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapAlloc
  DUP IF 557 OVER ! CELL+ 0 ELSE -310 THEN
;

: FREE ( a-addr -- ior ) \ 94 MEMORY
\ Вернуть непрерывную область пространства данных, индицируемую a-addr, системе 
\ для дальнейшего распределения. a-addr должен индицировать область 
\ пространства данных, которая ранее была получена по ALLOCATE или RESIZE.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, ior ноль. Если операция не прошла, ior - зависящий от 
\ реализации код ввода-вывода.
  CELL- DUP @ 557 <> IF ." страшный баг" DROP 302 EXIT THEN
  DUP 0!
  0 THREAD-HEAP @ HeapFree ERR
;
: RESIZE ( a-addr1 u -- a-addr2 ior ) \ 94 MEMORY
\ Изменить распределение непрерывного пространства данных, начинающегося с 
\ адреса a-addr1, ранее распределенного по ALLOCATE или RESIZE, на u байт.
\ u может быть больше или меньше, чем текущий размер области.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, a-addr2 - выровненный адрес начала u байт 
\ распределенной памяти и ior ноль. a-addr2 может, но не должен, быть тем же 
\ самым, что и a-addr1. Если они неодинаковы, значения, содержащиеся в области 
\ a-addr1, копируются в a-addr2 в количестве минимального из размеров этих 
\ двух областей. Если они одинаковы, значения, содержащиеся в области, 
\ сохраняются до минимального из u или первоначального размера. Если a-addr2 не 
\ тот же, что и a-addr1, область памяти по a-addr1 возвращается системе 
\ согласно операции FREE.
\ Если операция не прошла, a-addr2 равен a-addr1, область памяти a-addr1 не 
\ изменяется, и ior - зависящий от реализации код ввода-вывода.
  CELL+ SWAP CELL- DUP @ 557 <> IF ." страшный баг" DROP 303 EXIT THEN
  DUP 0!
  8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapReAlloc
  DUP IF 557 OVER ! CELL+ 0 ELSE -320 THEN
;

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
   ." :(" R@ WordByAddr TYPE ." <-" R> R@ WordByAddr TYPE >R ." )"
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
WARNING !

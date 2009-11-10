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

  Вариант использования:

  : РаботаСХипом
    работа с хипом
  ;
  ...
  ['] РаботаСХипом DROP_MEM


  Внутри скобок MARK_MEM - FREE_MEM можно определить участок кода,
  выделяемая которым память не будет автоматически освобождена.
  Эта возможность применяется для манипуляции с долгоживущими структурами
  типа хэшей, которые сами следят за своей целостностью.

  DISABLE_MEM_LAYOFF
  создание долгоживущих блоков памяти
  DISABLE_MEM_LAYOFF

  Вариант использования:

  : РаботаСДолгоживущейПамятью
    работа с долгоживущей памятью
  ;
  ...
  ['] РаботаСДолгоживущейПамятью SAVE_MEM

)

USER _NO_STACK_MEM

\ код пометки для блока памяти
: _MEM_MARKER ( -- u ) _NO_STACK_MEM @ IF 558 ELSE 557 THEN ;

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
\  DUP IF 557 OVER ! CELL+ 0 ELSE -310 THEN
  DUP IF _MEM_MARKER OVER ! CELL+ 0 ELSE -310 THEN
;

: FREE ( a-addr -- ior ) \ 94 MEMORY
\ Вернуть непрерывную область пространства данных, индицируемую a-addr, системе 
\ для дальнейшего распределения. a-addr должен индицировать область 
\ пространства данных, которая ранее была получена по ALLOCATE или RESIZE.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, ior ноль. Если операция не прошла, ior - зависящий от 
\ реализации код ввода-вывода.
  CELL- DUP @ DUP 557 <> SWAP 558 <> AND IF ." страшный баг" DROP 302 EXIT THEN
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
\  CELL+ SWAP CELL- DUP @ 557 <> IF ." страшный баг" DROP 303 EXIT THEN
  CELL+ SWAP CELL- DUP @ DUP 557 <> SWAP 558 <> AND IF ." страшный баг" DROP 303 EXIT THEN
  DUP 0!
  8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapReAlloc
\  DUP IF 557 OVER ! CELL+ 0 ELSE -320 THEN
  DUP IF _MEM_MARKER OVER ! CELL+ 0 ELSE -320 THEN
;

USER MEM_STACK_PTR
USER MEM_STACK_SIZE
VARIABLE MEM_DEBUG

: STACK_MEM ( addr -- )
  3 CELLS ALLOCATE THROW >R
  ( addr ) R@ CELL+ !
  MEM_STACK_PTR @ R@ !
  R> MEM_STACK_PTR !
;
: ALLOCATE ( size -- addr ior )
  DUP MEM_STACK_SIZE +!
  DUP >R
  ALLOCATE DUP IF RDROP EXIT THEN
  OVER STACK_MEM
  R> MEM_STACK_PTR @ CELL+ CELL+ !
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
\  DUP CELL- @ 558 = IF FREE EXIT THEN \ было обработано UNSTACK'ом
  >R
  MEM_STACK_PTR
  BEGIN
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ R@ =
    IF R> FREE >R
       DUP @ CELL+ CELL+ @ MEM_STACK_SIZE @ SWAP - MEM_STACK_SIZE !
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
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ R@ =
    IF R>
       OVER @ CELL+ CELL+ @ \ старый размер
         R@ SWAP - MEM_STACK_SIZE +!
       R@ RESIZE
       ROT @ >R
       OVER R@ CELL+ !          \ новый адрес
       R> CELL+ CELL+ R> SWAP ! \ новый размер
       EXIT
    THEN
    @
  REPEAT DROP R> RDROP
  301 \ элемент, размер которого просят изменить, не был выделен
;
: UNSTACK ( addr -- ior ) \ убрать элемент addr из-под контроля MEM_STACK
\ в текущей реализации элемент остаётся под контролем, но не удаляется при массовой очистке
  MEM_DEBUG @
  IF
   ." :u(" R@ WordByAddr TYPE ." <-" R> R@ WordByAddr TYPE >R ." )u"
   SPACE DUP . ." m>" CR
  THEN
  >R
  MEM_STACK_PTR
  BEGIN
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ R@ =
    (	из списка тоже не исключаем, только меняем признак
    IF \ R> FREE >R \ освобождать addr не нужно, только исключаем из списка
       558 R> CELL- ! 0 >R

       DUP @ DUP >R @ SWAP ! \ исключили из списка записью след.элемента
       R> MS_FREE THROW
       R> EXIT
    THEN
    )
    IF 558 R> CELL- ! 0 EXIT THEN	\ поставить код исключения
    @
  REPEAT DROP RDROP
  304 \ элемент, который просят исключить, не был выделен
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
( переделано ниже - с учётом наличия неудаляемых элементов стека
: FREE_MEM 
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
)
: FREE_MEM ( -- )
  MEM_STACK_PTR
  BEGIN
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ DUP 73 =		\ достигли отметки?
    IF
      DROP DUP @ DUP >R @ SWAP !	\ исключили из списка записью след.элемента
      R> MS_FREE THROW			\ освободить контрольный блок
      EXIT				\ и завершить
    THEN
    DUP CELL- @ 557 =			\ этот блок удаляется?
    IF
      MS_FREE THROW			\ да - удалить
      DUP DUP @ DUP >R @ SWAP !		\ исключили из списка записью след.элемента
      R> MS_FREE THROW			\ освободить контрольный блок
    ELSE
      DROP @				\ нет - просто перейти к следующему блоку
    THEN
  REPEAT \ освободили весь список, но не нашли отметку!
  @ MEM_STACK_PTR !
;
: FREE_MEM_EXCEPT ( addr -- ) \ освободить всё кроме элемента, содержащего указанный адрес
  >R MEM_STACK_PTR
  BEGIN
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @ CELL+ @ DUP 73 =		\ достигли отметки?
    IF
      DROP DUP @ DUP >R @ SWAP !	\ исключили из списка записью след.элемента
      R> MS_FREE THROW			\ освободить контрольный блок
      RDROP
      EXIT				\ и завершить
    THEN
    DUP CELL- @ 557 =			\ этот блок удаляется?
    IF
      OVER @ DUP CELL+ @ SWAP CELL+ CELL+ @ ( 2DUP TYPE CR) OVER + R@ ROT ROT WITHIN
      IF DROP @
      ELSE
      MS_FREE THROW			\ да - удалить
      DUP DUP @ DUP >R @ SWAP !		\ исключили из списка записью след.элемента
      R> MS_FREE THROW			\ освободить контрольный блок
      THEN
    ELSE
      DROP @				\ нет - просто перейти к следующему блоку
    THEN
  REPEAT \ освободили весь список, но не нашли отметку!
  @ MEM_STACK_PTR !
  RDROP
;
: DUMP_MEM ( -- )
  MEM_STACK_PTR
  BEGIN
    DUP @ \ параметром цикла будет не адрес элемента, а указатель на адрес
  WHILE
    DUP @
        DUP CELL+ ." a=" @ .
            CELL+ CELL+ @ ." s=" . CR
    @
  REPEAT
  DROP
." DUMP_MEM_OK" CR
;

\ TRUE MEM_DEBUG !
WARNING !

\ управление разрешением на массовую очистку памяти
: ENABLE_MEM_LAYOFF _NO_STACK_MEM 0! ;
: DISABLE_MEM_LAYOFF TRUE _NO_STACK_MEM ! ;

\ слова-обёртки для более прозрачного переключения режимов зачистки
\ DROP_MEM - выполняет указанное xt с разрешением массовой очистки памяти и подчищает за ним выделенную динамическую память
: DROP_MEM ( xt -- )
  MARK_MEM				\ поставить маркер
  _NO_STACK_MEM DUP @ >R 0!		\ разрешить зачистку памяти
  CATCH					\ выполнить с перехватом ошибки
  R> _NO_STACK_MEM !			\ прежнее состояние флага
  FREE_MEM				\ зачистить выделенную память
  THROW					\ и вернуть ошибку
;

\ SAVE_MEM - выполняет указанное xt с запретом массовой очистки памяти
: SAVE_MEM ( xt -- )
  TRUE _NO_STACK_MEM DUP @ >R !		\ запретить зачистку памяти
  CATCH					\ выполнить с перехватом ошибки
  R> _NO_STACK_MEM !			\ прежнее состояние флага
  THROW					\ и вернуть ошибку
;

\EOF
1000 ALLOCATE THROW
MEM_STACK_PTR @ .
MARK_MEM MEM_STACK_PTR @ .
1000 ALLOCATE THROW DROP
1000 ALLOCATE THROW DROP
1000 ALLOCATE THROW  2000 RESIZE THROW
1000 ALLOCATE THROW DROP
1000 ALLOCATE THROW DROP
DUMP_MEM
MEM_STACK_PTR @ .
DUP 1000 + FREE_MEM_EXCEPT

DUMP_MEM
MEM_STACK_PTR @ .
1000 ALLOCATE THROW FREE THROW
MEM_STACK_PTR @ .
FREE THROW
MEM_STACK_PTR @ .
FREE THROW
MEM_STACK_PTR @ .
DUMP_MEM

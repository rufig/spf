\ 94 CORE EXT

REQUIRE CASE lib/include/control-case.f
\ NB: the words "CASE", "OF", "ENDOF", "ENDCASE" belong to the CORE EXT word set.


: .R ( n1 n2 -- ) \ 94 CORE EXT
\ Вывести на экран n1 выравненным вправо в поле шириной n2 символов.
\ Если число символов, необходимое для изображения n1, больше чем n2,
\ изображаются все цифры числа без ведущих пробелов в поле необходимой
\ ширины.
  >R DUP >R ABS
  S>D <# #S R> SIGN #>
  R> OVER - 0 MAX SPACES TYPE
;
: 0> ( n -- flag ) \ 94 CORE EXT
\ flag "истина" тогда и только тогда, когда n больше нуля
  0 >
;

: @+ ( a-addr1 -- a-addr2 x.value )  \ AKA `1@NEXT`, AKA `XCOUNT` (which is a bad name)
  DUP CELL+ SWAP @
;
: 2@+ ( a-addr1 -- a-addr2 xd.value ) \ AKA `2@NEXT`
  DUP CELL+ CELL+ SWAP 2@
;
: C@+ ( a-addr1 -- a-addr2 char.value ) \ AKA `C@NEXT`, AKA `COUNT`
  DUP CHAR+ SWAP C@
;

: MARKER ( "<spaces>name" -- ) \ 94 CORE EXT
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелами.
\ Создать определение с семантикой выполнения, описанной ниже.
\ name Выполнение: ( -- )
\ Восстановить распределение памяти словаря и указатели порядка поиска
\ к состоянию, которое они имели перед определением name. Убрать
\ определение name и все последующие определения. Не требуется
\ обязательно восстанавливать любые оставшиеся структуры, которые
\ могут быть связаны с удаленными определениями или освобожденным
\ пространством данных. Никакая другая контекстуальная информация,
\ как основание системы счисления, не изменяется.
  DESTINATION-STATIC INVERT ABORT" `MARKER` is not supported for a temporary storage"
  \ Note: it does not save/restore the state of temporary wordlists
  \ since there is no a list of such wordlists in the kernel.
  GET-CURRENT DUP WID>HEAD SWAP ( nt|0 wid.destination )
  HERE ( addr.here )
  CREATE
  DP ,
  VOC-LIST ,
  ( addr.here ) , \ original HERE
\  [C]HERE , [E]HERE ,
  VOC-LIST @ ,
  \ the search order
  GET-ORDER DUP , DUP 0 ?DO DUP ROLL , 1- LOOP DROP
  \ the state of each static wordlist
  VOC-LIST @ BEGIN DUP WHILE @+ ( wid a-addr.next|0 ) SWAP DUP WID>HEAD SWAP , , REPEAT ( 0 ) 0 , ,
  ( nt|0 wid.destination ) , , \ 2, \ the compilation word list wid and its state
  \ it must be restored last since its state from VOC-LIST (if any) is taken after creation of the marker child
  DOES>
  @+ DP <> ABORT" The current storage is not static (DP slot is different)"
  @+ VOC-LIST <> ABORT" The current storage is not static (VOC-LIST slot is different)"
  @+ DP !  \ restore HERE
\  DUP @ [C]DP ! CELL+
\  DUP @ [E]DP ! CELL+
  @+ VOC-LIST !  \ restore the list of wordlists
  @+ EMPTY-ORDER 0 ?DO @+ PUSH-ORDER LOOP \ restore the search order
  BEGIN 2@+ DUP WHILE ( a-addr.next nt|0 wid ) FIX-WID-HEAD REPEAT 2DROP
  2@+ DUP SET-CURRENT FIX-WID-HEAD
  DROP
;

: SAVE-INPUT ( -- xn ... x1 n )  \ 94 CORE EXT
\ x1 - xn описывают текущее состояние спецификаций входного потока для
\ последующего использования словом RESTORE-INPUT.
  SOURCE-ID 0>
  IF TIB #TIB @ 2DUP C/L 2 + ALLOCATE THROW DUP >R SWAP CMOVE
     R> TO TIB  >IN @
     SOURCE-ID FILE-POSITION THROW
     5
  ELSE BLK @ >IN @ 2 THEN
;
: RESTORE-INPUT ( xn ... x1 n -- flag ) \ 94 CORE EXT
\ Попытка восстановить спецификации входного потока к состоянию,
\ описанному x1 - xn. flag "истина", если спецификации входного
\ потока не могут быть восстановлены.
\ Неопределенная ситуация возникает, если входной поток,
\ представленный аргументами не тот же, что и текущий входной поток.
  SOURCE-ID 0>
  IF DUP 5 <> IF 0 ?DO DROP LOOP -1 EXIT THEN
     DROP SOURCE-ID REPOSITION-FILE ?DUP IF >R 2DROP DROP R> EXIT THEN
     >IN ! #TIB ! TO TIB FALSE
  ELSE DUP 2 <> IF 0 ?DO DROP LOOP -1 EXIT THEN
     DROP >IN ! BLK ! FALSE
  THEN
;
: U.R ( u n -- ) \ 94 CORE EXT
\ Вывести на экран u выравненным вправо в поле шириной n символов.
\ Если число символов, необходимое для изображения u, больше чем n,
\ изображаются все цифры числа без ведущих пробелов в поле необходимой
\ ширины.
  >R  U>D <# #S #>
  R> OVER - 0 MAX SPACES TYPE
;

: UNUSED ( -- u ) \ 94 CORE EXT
\ u - объем памяти, оставшейся в области, адресуемой HERE,
\ в байтах.
  DESTINATION-STATIC IF
    IMAGE-SIZE  HERE IMAGE-BASE -  -
    EXIT
  THEN
  TRUE ABORT" `UNUSED` is not supported for a temporary storage in the kernel"
;



: (INIT-REGION) ( a-addr.pointer -- )
  DUP CELL+ @  ALLOCATE THROW  SWAP !
;
: RESERVE-REGION ( u.size -- a-addr.pointer )
  ALIGN HERE >R 0 , ,  R@ (INIT-REGION)
  IMAGE-BASE IMAGE-SIZE OVER + R@ WITHIN IF \ a-addr.pointer is in the base image
    \ add allocation in the process starting actions for the saved binary (if any)
    ['] AT-PROCESS-STARTING UNSEAL-SCATTER
      R@ LIT, POSTPONE (INIT-REGION)
    RESEAL-SCATTER
  THEN R>
;
: REGION ( u "name" -- ) \ or BULK (?)
  RESERVE-REGION >R  :  R> LIT, POSTPONE @  POSTPONE ;
;
: BUFFER: ( u "name" -- ) REGION ; \ Forth-2012 CORE EXT, 6.2.0825
\ NB: different addresses may be returned by "name" on different runs
\ from a saved image, see:
\   https://forth-standard.org/standard/core/BUFFERColon#reply-706
\ An issue with the unsuitable name "BUFFER:" was disscussed at:
\   https://forth-standard.org/standard/core/BUFFERColon#contribution-69

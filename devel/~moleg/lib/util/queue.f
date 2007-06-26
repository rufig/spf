\ 21-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ неименованные очереди

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE ADDR     devel\~moleg\lib\util\addr.f
 REQUIRE MUTEX:   devel\~moleg\lib\mtask\mutex.f

  0 \ описатель циклического буфера
    CELL -- QueueBegin  \ адрес начала области, отведенной под очередь
    CELL -- QueueFirst  \ адрес извлекаемого значения из очереди
    CELL -- QueueLast   \ адрес для сохранения значения в очереди
    CELL -- QueueAccess \ монополизация доступа к очереди
  CONSTANT /queue

\ посчитать, сколько займет очередь в памяти
: QueueSize ( # --> u ) 1 + CELLS /queue + ;

\ инициализировать очередь
: ResetQueue ( queue --> )
             DUP QueueBegin A@ TUCK OVER QueueFirst A! QueueLast A! ;

\ расположить очередь длиной в # ячеек начиная с адреса addr
\ место должно быть выделено предварительно
: PlaceQueue ( # addr --> queue )
             >R 1 + CELLS R@ +
             R> OVER A!
             DUP ResetQueue ;

\ проверить пуста ли очередь (либо переполнена)
: CheckQueue ( queue --> flag ) DUP QueueFirst A@ SWAP QueueLast A@ = ;

\ увеличить указатель записи
: Shove ( queue --> )
        DUP QueueLast A@ CELL + 2DUP -
        IF ELSE DROP DUP QueueBegin A@ THEN SWAP QueueLast A! ;

\ увеличить указатель чтения
: Squeeze ( queue --> )
          DUP QueueFirst A@ CELL + 2DUP -
          IF ELSE DROP DUP QueueBegin A@ THEN SWAP QueueFirst A! ;

\ добавить значение в указанную очередь
\ исключение, если очередь заполнена
\ При возникновении исключения содержимое очереди теряется
: PutTo ( n queue --> )
        DUP QueueAccess WaitUnlock
        TUCK QueueLast A@ !
        DUP Shove
        DUP CheckQueue
            IF DUP ResetQueue QueueAccess UnlockMutex -1 THROW
        THEN QueueAccess UnlockMutex ;

\ извлечь значение из указанной очереди
\ исключение, если очередь пуста.
\ При возникновении исключения содержимое очереди теряется
: GetFrom ( queue --> n )
          DUP QueueAccess WaitUnlock
          DUP CheckQueue
              IF DUP ResetQueue QueueAccess UnlockMutex -1 THROW THEN
          DUP QueueFirst A@ @ SWAP DUP Squeeze QueueAccess UnlockMutex ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 3 HERE OVER QueueSize ALLOT
             PlaceQueue VALUE sample

       sample ' GetFrom CATCH 0= THROW DROP   \ переопустошение
       1 sample PutTo  2 sample PutTo  3 sample PutTo
       4 sample ' PutTo CATCH 0= THROW 2DROP  \ переполнение

       5 sample PutTo 6 sample PutTo 7 sample PutTo
       sample GetFrom 5 <> THROW
       sample GetFrom 6 <> THROW
       sample GetFrom 7 <> THROW

  S" passed" TYPE
}test

\EOF
     В принципе при переполении или переопустошении очереди нужно усыплять
процесс, но как потом его будить?

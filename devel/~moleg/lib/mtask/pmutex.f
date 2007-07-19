\ 21-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ мьютексы

 REQUIRE ?DEFINED   devel\~moleg\lib\util\ifdef.f
 REQUIRE B,         devel\~mOleg\lib\util\bytes.f
 REQUIRE ADDR       devel\~mOleg\lib\util\addr.f
 REQUIRE IFNOT      devel\~moleg\lib\util\ifnot.f
 REQUIRE AllotErase devel\~moleg\lib\util\useful.f
 REQUIRE STREAM[    devel\~moleg\lib\arrays\stream.f

\ пробуем удостовериться в том, что ресурс свободен
\ если свободен, устанавливаем флаг занятости, возвращаем TRUE
\ иначе FALSE
: ?LockMutex ( addr --> flag ) STREAM[ x8BD8C7C0FFFFFFFF8703F7D0 ] ;

\ освобождаем занимаемый ресурс
: UnlockMutex ( addr --> ) STREAM[ x33D287108B45008D6D04 ] ;

\ ждем освобождения ресурса, после чего его лочим за собой
: WaitUnlock ( addr --> )
             BEGIN DUP ?LockMutex WHILENOT
                   1 PAUSE    \ чтобы не расходовать квант времени до конца
             REPEAT DROP ;

 0
   CELL -- off_mutex \ хранит мьютекс
   ADDR -- off_ident \ хранит число однозначно идентифицирующее задачу
 CONSTANT /pmutex

\ освободить мьютекс только в случае, если он залочен текущим потоком
\ иначе ждем освобождения мьютекса
: free-mutex ( 'pmutex --> )
             >R BEGIN R@ ?LockMutex WHILENOT
                      R@ off_ident @ TlsIndex@ = WHILENOT
                  1 PAUSE  ." ."
              REPEAT
             THEN R> UnlockMutex ;

\ присвоить мьютекс и запомнить taskid застолбившей задачи
: lock-mutex ( 'pmutex --> ) DUP WaitUnlock  TlsIndex@ SWAP off_ident A! ;

\ по сути то же, что и MUTEX: только фиксирует еще и id потока
\ (то есть уникальное число для потока) используется вместе с free-mutex,
\ который освобождать умеет только мьютексы залоченные в собственном потоке
: PMUTEX: ( / name --> )
          CREATE /pmutex AllotErase
          ( 'cfa --> )
          DOES> DUP >R lock-mutex
                ['] EXECUTE CATCH
                    R> free-mutex
                THROW ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ VARIABLE res
         res ?LockMutex 0= THROW
         res ?LockMutex THROW
         res UnlockMutex
         res ?LockMutex 0= THROW
         res UnlockMutex
  S" passed" TYPE
}test

\EOF

0 VALUE t1
0 VALUE t2

: testa ."  aaaaaa> " t1 1+ TO t1 500 PAUSE ." <aaaaa "  ;
: testb ."  bbbbbb> " t2 1+ TO t2 300 PAUSE ." <bbbbb "  ;

PMUTEX: proba

: ttt BEGIN ['] testa proba t1 . t2 . CR 0  PAUSE AGAIN ;
: eee BEGIN ['] testb proba t1 . t2 . CR 0  PAUSE AGAIN ;

' ttt TASK: testt
testt START
eee



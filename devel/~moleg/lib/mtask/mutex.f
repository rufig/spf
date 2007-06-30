\ 21-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ мьютексы

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE B,        devel\~mOleg\lib\util\bytes.f

\ пробуем удостовериться в том, что ресурс свободен
\ если свободен, устанавливаем флаг занятости, возвращаем TRUE
\ иначе FALSE
: ?LockMutex ( addr --> flag )
             [ 0x8B B, 0xD8 B,       \ MOV addr , tos
               0xC7 B, 0xC0 B, -1 ,  \ MOV tos , # -1
               0x87 B, 0x03 B,       \ XCHG [addr] , tos
               0xF7 B, 0xD0 B,       \ NOT tos
             ] ;

\ освобождаем занимаемый ресурс
: UnlockMutex ( addr --> )
              [ 0x33 B, 0xD2 B,         \ XOR temp , temp
                0x87 B, 0x10 B,         \ XCHG [tos], temp
                0x8B B, 0x45 B, 0x00 B,
                0x8D B, 0x6D B, 0x04 B, \ dpop tos
              ] ;

\ ждем освобождения ресурса, после чего его лочим за собой
: WaitUnlock ( addr --> ) BEGIN DUP ?LockMutex UNTIL DROP ;

\ создать именованый мьютекс
\ при выполнении слова с именем name с параметром 'cfa можно быть
\ уверенным, что ресурс, связанный с мьютексом доступен монопольно.
: MUTEX: ( / name --> )
         CREATE 0 ,
         ( 'cfa --> )
         DOES> DUP >R WaitUnlock
               ['] EXECUTE CATCH   \ для того, чтобы unlock был выполнен
                   R> UnlockMutex
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

\EOF -- типа пример ---------------------------------------------------------

  MUTEX: sample

: test 100 0 DO I . 100 PAUSE LOOP ;

: testa ['] test sample ;

: testb CR ."  passed" CR ;


' testa TASK: proba

: zzzz  0 proba START        \ поток proba лочит за собой мьютекс sample
        200 PAUSE ." zzzzzz "

        ['] testb sample     \ до тех пор, пока sample залочен, testb
                             \ будет стоять в ожидании
        ;

zzzz

\EOF

при работе в многопоточном режиме бывает необходимо быть уверенным,
что к ресурсу имеется монопольный доступ.



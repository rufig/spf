\ 31-01-2007 ~mOleg ( mail to: mininoleg@yahoo.com )
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ компиляция только уникальных слов в словарь

\ добавить слово ?: со следующими свойствами - слово добавляется в текущий
\ словарь, только если нет с таким же именем в контексте.
\ !!! использовать с ядром версии не ниже 4.18 !!!
\ ver 1.2 - добавлена реакция на системную переменную WARNING.

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

VOCABULARY recoil \ все промежуточные слова сохраняем с собственный словарь
           ALSO recoil DEFINITIONS

        \ сохраненная позиция для отката и признак за одно
        USER unique-flag

        \ запомнили текущий sheader системы
        ' SHEADER BEHAVIOR ->VECT std-sheader

\ удалить последнее определенное слово из текущего списка
: unlink ( --> ) LATEST CDR GET-CURRENT ! ;

\ если последнее слово нужно отменить - отменяем его.
: ?cut ( --> )
       unique-flag @
       IF unlink
          unique-flag @ HERE - ALLOT
          unique-flag 0!
       THEN ;

\ создать новый заголовок, если необходимо, отменить старое слово
: (sHeader) ( asc # --> ) ?cut std-sheader ;

\ если слово уникально - вернуть 0 и адрес строки
\ иначе вернуть адрес для отката, и адрес пустой строки.
: ?namex ( / name --> here|0 asc # )
         NextWord SFIND
         IF DROP S" _" HERE  ELSE FALSE  THEN
         -ROT ;

ALSO FORTH DEFINITIONS \ отсюда слова идут в базовый словарь SPF

\ то же что и : только имя приходит на вершине стека данных
\ в виде строки со счетчиком. Пример:  S" name" S: код слова ;
?DEFINED S: : S: ( asc # --> ) SHEADER ] HIDE ;

\ добавить слово в текущий словарь, только если в контексте нет слова
\ с таким же именем.
: ?: ( --> )
     WARNING @ IF ?namex ELSE FALSE NextWord THEN
     S:   unique-flag ! ;

 ' (sHeader) TO SHEADER  \ теперь обрабатываем откаты

PREVIOUS PREVIOUS

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{  TRUE WARNING !
       ?: simple 871654 ; 871654 simple <> THROW
       ?: simple 672098 ; 871654 simple <> THROW
     FALSE WARNING !
       ?: simple 672098 ; 672098 simple <> THROW
  S" passed" TYPE
}test

\EOF -- тестовая секция -----------------------------------------------------

                           TRUE WARNING !
VOCABULARY testing
           ALSO testing DEFINITIONS

?: test ( --> ) ."  first test sample" CR ;
?: test ( --> ) ."  second test sample" CR ;
    CREATE sample
?: test ( --> ) ."  thrid test sample" CR ;
 : eotest ( --> )
          ." должно быть всего три слова в словаре: test, eotest и sample" CR
          WORDS
          ." должен быть выполнен первый test : "
          test
          ; eotest

                        PREVIOUS DEFINITIONS
CR CR
                              WARNING 0!

VOCABULARY testing
           ALSO testing DEFINITIONS

?: test ( --> ) ."  first test sample" CR ;
?: test ( --> ) ."  second test sample" CR ;
    CREATE sample
?: test ( --> ) ."  thrid test sample" CR ;
 : eotest ( --> )
          ." должны быть все пять слов в текущем словаре" CR
          WORDS
          ." должен быть выполнен третий test : "
          test
          ; eotest


\EOF
     Иногда нужен небольшой набор слов, которые могут быть в системе,
а могут и не быть, и подключать дополнительные файлы не хочется...

В таком случае поступаем следующим образом: подключаем данную либу 8),
все сомнительные слова начинаем не с : а с ?: и все!!!  Ж8)

Замечу, что слово начинающееся с :? собертся, но потом забудется 8)
если, конечно в системе уже есть слово с таким именем, а если нет
такого имени, то слово, соответственно, останется. Это значит, что
вы можете смело использовать всякие IMMEDIATE после ; !!!
Иногда так получится проще, чем использовать [UNDEFINED] или REQUIRE.

Да, слово забывается только, когда начинает определяться следующее.

Указанным выше поведением можно управлять с помощью системной переменной
WARNING - при установке этой переменной повторное определение слова
          запрещается, а при установленной в 0 переопределения происходят.

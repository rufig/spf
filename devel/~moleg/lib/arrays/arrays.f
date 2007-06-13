\ 10-04-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ работа с небольшими массивами в стеке данных.

 REQUIRE ?DEFINED   devel\~moleg\lib\util\ifdef.f
 REQUIRE FRAME      devel\~moleg\lib\util\stackadd.f

\ выделить на стеке место под массив без инициализации
: array ( # --> [array] # ) FRAME ;

\ получить адрес начала массива и его длинну
: get-array ( [array] # --> [array] # addr #bytes )
            >R SP@ R> SWAP OVER CELLS ;

\ выделить место под массив на стеке данных, заполнить пространство нулями
: 0array ( # --> [000] # ) array get-array ERASE ;

\ удалить массив вместе с содрежимым
: dismiss ( [array] # --> ) get-array + SP! ;

\ создать копию массива
: reply ( [array] # --> [array] # [array] # )
        get-array >R >R DUP array
        get-array DROP R> SWAP R>
        MOVE ;

\ объединить указанные массивы в один
: combine ( [arr] m [ay] n --> [array] m+n )
          get-array 2DUP + @ >R OVER CELL + SWAP CMOVE> R> + NIP ;

\ разбить один массив на два.
\ если n больше m будет создано два массива:
\ один нулевой длинны, второй полная копия оригинального.
: break ( [array] m n --> [arr] m-n [ay] n )
        OVER UMIN 2DUP - >R >R
        get-array DROP DUP CELL - R@ CELLS MOVE
        R> get-array + R> SWAP ! ;

\ копировать массив в память вместе со счетчиком
: move-to ( [array] # addr --> )
          >R get-array CELL + SWAP CELL - SWAP R> SWAP MOVE dismiss ;

\ копировать массив из памяти на стек данных
: get-from ( addr --> [array] # )
           DUP >R @ array get-array R> CELL + -ROT MOVE ;

\ прочесть элемент с указанным номером из массива
\ контроля выхода за предел массива не производится.
\ индексы начинаются с 0
: [i]@ ( [array] # i --> [array] # n ) 1 + PICK ;

\ сохранить значение n в массив array в элемент с индексом i
\ контроля выхода за предел массива не производится
\ индексы начинаются с 0
: [i]! ( [array] # n i --> [array] # ) 1 + CELLS 2>R SP@ R> + R> SWAP ! ;

\ вернуть FALSE если содержимое массивов или длина не равны
: cmparr ( [a1] # [a2] # --> flag )
         SP@ OVER 1 + CELLS 2DUP 2>R +
         2R> TUCK COMPARE 0= ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока только проверка подключения

  S" passed" TYPE
}test
\EOF -- тестовая секция ------------------------------------------------------

1 CHARS CONSTANT char

\ преобразовать строку в массив
: s>arr ( asc # --> [a s c] # )
        OVER + 2>R
        0 BEGIN 2R@ <> WHILE
                1 + R> char - DUP >R C@ SWAP
          REPEAT RDROP RDROP ;

\ распечатать содержимое массива как строку
: .array ( [arr] # --> ) 0 ?DO EMIT LOOP ;

\ это примеры работы:
CR S" sample text" s>arr .array
CR S" sample" s>arr S" text " s>arr combine .array
CR S" sample text" s>arr 7 break .array CR .array
CR S" sample " s>arr reply combine .array
CR S" sample text" s>arr 7 break dismiss .array
   S" sample text" s>arr HERE move-to HERE DUP @ CELLS DUMP
CR HERE get-from .array
CR S" sample" s>arr 51 3 [i]! 48 0 [i]! .array
CR mark 57 56 55 54 53 52 51 50 49 countto .array

\ 12-12-200 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ задачка с конкурса на форуме: http://fforum.winglion.ru/viewtopic.php?t=1068

 REQUIRE TILL devel\~moleg\lib\util\for-next.f

\ вернуть количество бит в стандартной €чейке
: bits/cell ( --> u ) 0 -1 BEGIN TUCK WHILE 1+ SWAP 2* REPEAT NIP ;

        0 VALUE buffer \ адрес места, где хранитс€ результирующий массив

\ выделение пам€ти под массив и его инициализаци€
bits/cell 4 / 1 SWAP LSHIFT CELLS CELL + ALLOCATE THROW DUP TO buffer 0!

\
: aCount ( addr --> addr # ) DUP CELL + SWAP @ ;

\ отправить значение в буфер
: ->buf ( u --> )
        buffer aCount + !
        CELL buffer +! ;

\ перевести значение счетчика u в следующую позицию, согласно маске um
: increment ( um u --> um u++ ) OVER INVERT OR 1 + OVER AND ;

\ найти все возможные комбинации бит внутри маски um
\ вернуть адрес и длину получившегос€ массива
: combs ( um --> addr # )
        0 buffer !
        0 BEGIN DUP ->buf      \ сохранить результат в буфер
                2DUP <> WHILE  \ пока не достигнут предел счета
                increment      \ увеличить значение счетчика
          REPEAT 2DROP
        buffer aCount ;

\EOF
: ~combs buffer DUP @ CELL / FOR CELL + DUP @ . SPACE TILL DROP ;
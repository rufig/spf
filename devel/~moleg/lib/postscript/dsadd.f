\ 20-06-2005 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ постскрипт-подобная работа со стеком для СПФ

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE Unit:    devel\~moleg\lib\struct\struct.f

Unit: psLikeMarkers

: CELL+! ( addr --> ) DUP @ CELL + SWAP ! ;
: CELL-! ( addr --> ) DUP @ CELL - SWAP ! ;

        20 CONSTANT #markers
           USER     M0    \ дно стека
           USER     MP    \ указатель

\ инициализируем стек маркеров
F: init ( --> )
        [ #markers CELLS ] LITERAL DUP
        ALLOCATE THROW DUP M0 ! + MP ! ;F

\ определяет сколько всего маркеров на стеке маркеров хранится
: Marks   ( --> n ) M0 @ MP @ - CELL / #markers + ;

\ прочитать значение последнего маркера
: m-@     ( --> n ) Marks IF MP @ @ ELSE -1 THROW THEN ;

\ извлечь последний маркер со стека маркеров на стек данных
: m-pop   ( --> n ) Marks IF m-@ MP CELL+! ELSE -1 THROW THEN ;

\ сохранить значение со стека данных на стек маркеров
: m-push  ( n --> )
          Marks #markers -
          IF MP DUP CELL-! @ !
            ELSE -1 THROW
          THEN ;
EndUnit

psLikeMarkers

: ClearToMark ( --> ) m-pop SP! ;
: DropMark    ( --> ) m-pop DROP ;
: AddMark     ( --> ) SP@ m-push ;
: CountToMark ( --> n ) SP@ m-@ SWAP - CELL / ;
: ClearMarks  ( --> ) M0 @ #markers CELLS + MP ! ;

init

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ AddMark 1 2 AddMark 3 4 5 CountToMark 3 <> THROW
      ClearToMark CountToMark 2 <> THROW
      2 <> THROW 1 <> THROW
  S" passed" TYPE
}test

\EOF
     иногда хочется использовать стек данных, как массив. Слова для
произвольного доступа к стеку данных имеются(ROLL, PICK), а вот для
управления большим количеством данных таких слов нет :(

  AddMark     - фиксирует глубину стека данных на данный момент времени
  DropMark    - удаляет последний маркер
  ClearToMark - удаляет верхние элементы со стека данных до значения
                сохраненного по AddMark
  CountToMark - определяет глубину стека данных от последнего сохраненного
                маркера.
  ClearMarks  - очистить стек маркеров.

В постскрипте маркеры хранятся на общем стеке данных. Возможно это
более удобный вариант, но мне кажется, что в форте лучше для маркеров
отвести отдельный стек. Соответственно, если будет возникать ситуация,
когда стек обнуляется, то придется удалять все маркеры, чтобы работа
с ними оставалась корректной.

Возможно со временем придет более удачная идея.



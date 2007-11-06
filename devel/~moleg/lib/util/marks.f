\ 05-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ пост-скрипт подобная работа со стеком. Маркеры.

 REQUIRE NewStack  devel\~mOleg\lib\util\stack.f

        USER-VALUE MARKERS  \ хранит указатель на стек маркеров

        0x10 CONSTANT #marks \ глубина стека маркеров

\ инициализация стека маркеров - необходимо выполнять один раз на поток
\ повторное выполнение приводит к обнулению всех ранее сохраненных маркеров
: init-markers ( --> )
               MARKERS DUP IF KillStack ELSE DROP THEN
               #marks NewStack TO MARKERS ;

\ запомнить текущий указатель стека данных в стеке маркеров
: MarkMoment ( --> ) SP@ MARKERS PushTo ;

\ проверить, есть ли изменения глубины стека с последнего сохраненного момента
: TestMoment ( --> flag ) SP@ MARKERS ReadTop = ;

\ узнать, сколько маркеров осталось на стеке маркеров
: Marks# ( --> # ) MARKERS StackDepth ;

\ проверить, является ли текущий маркер достоверным
: ValidMark ( --> flag ) Marks# DUP IF DROP SP@ MARKERS ReadTop > 0= THEN ;

\ возвратить состояние стека данных до уровня сохраненного по MarkMoment
\ последний сохраненный маркер автоматически удаляется
: ClearToMark ( xj --> )
              ValidMark IF MARKERS PopFrom SP!
                         ELSE -1 THROW
                        THEN ;

\ посчитать количество элементов на стеке данных, добавленных с момента
\ запомненного с помощью MarkMoment
: CountToMark ( --> n )
              ValidMark IF SP@ MARKERS ReadTop SWAP - CELL /
                         ELSE -1 THROW
                        THEN ;

\ удалить запомненное значение с вершины стека маркеров
: ForgetMark ( --> ) MARKERS PopFrom DROP ;

\ удалить все маркеры со стека маркеров
: ClearMarks ( --> ) 0 MARKERS MoveTo ;

\ прочесть все маркеры на стек данных
: AllMarks ( --> [ a b c .. z ] # ) MARKERS GetFrom ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ init-markers
      1 2 MarkMoment 3 4 5 ClearToMark 1 2 D= 0= THROW
      ValidMark THROW
      MarkMoment ValidMark 0= THROW
      1 2 3 4 CountToMark 4 <> THROW
      ClearToMark
  S" passed" TYPE
}test

\EOF это, во-первых, пример работы с библиотечкой ~mOleg\lib\util\stack.f ,
     а во-вторых, метод управления содержимым стека данных.







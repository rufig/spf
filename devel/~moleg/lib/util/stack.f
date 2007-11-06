\ 04-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ неименованные стеки

 REQUIRE ADDR     devel\~moleg\lib\util\addr.f
 REQUIRE FRAME    devel\~mOleg\lib\util\stackadd.f

 0 \ структура описывающая стек
   CELL -- StackTop    \ указатель на последний элемент стека
   CELL -- StackLimit  \ предельный размер стека
   CELL -- StackBottom \ указатель на начало стека
 CONSTANT /NStack

\ посчитать размер стека глубиной в u ячеек в байтах
: StackSize ( # --> u ) CELLS /NStack + ;

\ разметить память, начало которой определено addr под стек глубиной depth
: StackPlace ( depth addr --> stack )
             2DUP >R CELLS +
                  R> OVER StackBottom A!
             TUCK StackLimit !
             0 OVER StackTop ! ;

\ получить глубину указанного стека
: StackDepth ( stack --> n ) StackTop @ ;

\ получить адрес текущей вершины стека
: TopAddr ( stack --> addr ) DUP StackDepth CELLS - ;

\ проверить не выходит ли указатель стека за его пределы
: ?Balanced ( stack --> ) DUP TopAddr OVER StackBottom A@ ROT 1 + WITHIN ;

\ прочесть верхний элемент указанного стека
: ReadTop ( stack --> n ) TopAddr @ ;

\ переместить указатель вершины стека на указанное количество ячеек
: MoveTop ( stack u --> ) OVER StackTop +! ?Balanced 0= THROW ;

\ удалить верхнее значение с вершины указанного стека
: DropTop ( stack --> ) -1 MoveTop ;

\ извлечь число из указанного стека
: PopFrom ( stack --> n ) DUP ReadTop SWAP DropTop ;

\ сохранить число в указанный стек
: PushTo ( n stack --> ) DUP 1 MoveTop TopAddr ! ;

\ переместить указанное количество # элементов a,b,c,,x на стек stack
: CopyTo ( [ a b c .. x ] # stack --> [ a b c .. x ] # )
         2DUP StackTop ! DUP ?Balanced 0= THROW
         OVER >R
          TopAddr >R CELLS >R SP@ 2R> CMOVE
         R> ;

\ переместить указанное количество элементов со стека данных на указанный стек
: MoveTo ( [ a b c .. x ] # stack --> ) CopyTo nDROP ;

\ копировать все содержимого стека stack на вершину стека данных
: GetFrom ( stack --> a b c .. x # )
          DUP TopAddr SWAP StackDepth 2>R
          R@ FRAME >R SP@ R> SWAP
          2R> CELLS >R SWAP R> CMOVE ;

\ создать неименованный стек в хипе
: NewStack ( depth --> stack ) DUP StackSize ALLOCATE THROW StackPlace ;

\ освободить место, занимаемое стеком
: KillStack ( stack --> ) StackBottom A@ FREE THROW ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 5 NewStack DUP ?Balanced 0= THROW KillStack
      5 NewStack VALUE stack
      123 stack PushTo stack ?Balanced 0= THROW
      234 stack PushTo stack ?Balanced 0= THROW
      345 stack PushTo stack ?Balanced 0= THROW
      456 stack PushTo stack ?Balanced 0= THROW
      567 stack PushTo stack ?Balanced 0= THROW
      567 stack ' PushTo CATCH 0= THROW 2DROP
      stack -1 MoveTop
      567 stack ReadTop <> THROW
      567 stack PopFrom <> THROW
      456 stack PopFrom <> THROW
      stack StackDepth 3 <> THROW
      stack PopFrom DROP stack PopFrom DROP stack PopFrom DROP
      stack ?Balanced 0= THROW
      stack ' PopFrom CATCH 0= THROW DROP
  S" passed" TYPE
}test

\EOF
     Иногда бывает необходимо складировать данные на промежуточный стек.
При этом каждый раз такой стек приходится создавать под каждую новую задачу.
Это не всегда удобно, тем более, что задача достаточно типовая. Для того,
чтобы повторно не писать каждый раз определяющие стек слова и создана эта
либа. Пользоваться следует так:

Сначала создаем стек необходимой глубины:

 200 NewStack

в результате получается адрес стека ( --> saddr )

 дальше лучше сохранить адрес стека куда-нибудь, например

 TO stack  \ Понятно, что VALUE переменная stack уже должна быть создана

Ну и дальше просто работаем со стеком с помощью слов PushTo PopFrom ReadTop..

Если не хочется каждый раз "вспоминать" адрес стека можно создать
необходимый набор слов, не забыв о том, что стек таки перед использованием
надобно создать.

Понятно, что данный вид стеков будет более медленным, нежели базовые
стеки (данных и возвратов). Можно кое-что выиграть от переписывания данной
либы на ассемблере, но меня более волнует переносимость.

Да, стек растет вниз! То есть как обычный стек.

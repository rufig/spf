\ 25-06-2005    работа с консолью через ANSY терминал

 \ так выглядит ANSI ESCAPE последовательность
 CREATE esc 2 C, 0x1B C, CHAR [ C,

\ то же, что [CHAR] n HOLD
: hld" [COMPILE] [CHAR] POSTPONE HOLD ; IMMEDIATE

\ то же, что 0x1B HOLD [CHAR] [ HOLD
: ESC  [ esc COUNT ] 2LITERAL HOLDS ;

: PRINT COUNT TYPE ;

\ S" для сток, содержащих "
: S~ [CHAR] ~ PARSE [COMPILE] SLITERAL ; IMMEDIATE

: ESC: S~ CREATE NextWord S", DOES> esc PRINT~ EVALUATE ; IMMEDIATE

\ ---------------------------------------------------------------------------

\ escape последовательности без параметров
: esc-0 ESC: PRINT ;

esc-0 page 2J   \ очистить экарн, курсор в 0,0
esc-0 !csr s    \ запомнить положение курсора
esc-0 @csr u    \ восстановить сохраненное положение курсора
esc-0 clrl K    \ очистить от курсора до конца строки

\ ---------------------------------------------------------------------------

\ escape последовательности с одним параметром и '=' после esc
: esc-k ESC: <# COUNT HOLDS 0 # # # hld" = #> TYPE ;

esc-k mode h    \ выбор режима работы консоли
esc-k resm I    \ сброс режима работы консоли

\ у microsoft имеются такие режимы
0 CONSTANT 40*25bw
1 CONSTANT 40*25clr
2 CONSTANT 80*25bw
3 CONSTANT 80*25clr
4 CONSTANT 320*200clr
5 CONSTANT 320*200bw
6 CONSTANT 640*200bw

\ escape последовательности с одним параметром
: esc-1 ESC: <# COUNT HOLDS 0 # # # #> TYPE ;

esc-1 cuu A     \ курсор вверх на # строк
esc-1 cud B     \ курсор вниз на # строк
esc-1 cuf C     \ курсор вправо на # колонок
esc-1 cub D     \ курсор влево на # колонок

\ ---------------------------------------------------------------------------

\ последовательности с двумя параметрами
: esc-2 ESC: <# COUNT HOLDS 0 # # # hld" ; NIP # # # #> TYPE ;

esc-2 XY! H

\ ---------------------------------------------------------------------------

\ последовательности с одним фиксированным параметром
: esc-x ( n | name p --> )
        CREATE NextWord <# HOLDS 0 # # # ESC #> S",
        DOES> PRINT ;

7 esc-x invscr m
0 esc-x atroff m
1 esc-x boldon m
5 esc-x blink  m
8 esc-x concea m

0 CONSTANT black
1 CONSTANT red
2 CONSTANT green
3 CONSTANT yellow
4 CONSTANT blue
5 CONSTANT magenta
6 CONSTANT cyan
7 CONSTANT white

esc-1 setprm m

\ установить цвет
: color 30 + setprm 40 + setprm ;

\ ---------------------------------------------------------------------------

\ запрос координат курсора
esc-0 xy? 6n

\ преобразовать число
: >num ( asc # --> n  )
       0 0 2SWAP >NUMBER 2DROP DROP ;

\ является ли последовательность символов по addr ESCAPE последовательностью
: ?esc[ ( addr --> flag ) W@ esc 1+ W@ = ;

\ проверить наличие сервиса ANSY
: check-ANSI xy? REFILL
             IF CharAddr ?esc[ #TIB >IN !
              ELSE FALSE
             THEN ;

\ получить положение курсора
: XY@ xy? REFILL DROP 2 >IN +!
      [CHAR] ; PARSE >num
      [CHAR] R PARSE >num ;

\ получить размеры области отображения
: [XY] !csr 99 cuf 99 cud XY@ @csr ;

\ ---------------------------------------------------------------------------



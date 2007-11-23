\ 23-11-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ разбор строк с различного вида разделителями
\ аналогично xWord.f, но с чуточку более удобным интерфейсом

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE s"       devel\~moleg\lib\strings\string.f
 REQUIRE B@       devel\~moleg\lib\util\bytes.f

\ заполнить таблицу-список разделителей
: +delimiters ( asc # addr --> )
              >R SWAP
              BEGIN OVER WHILE
                    TRUE OVER B@ R@ + B!
                -1 0 D+
              REPEAT
              2DROP RDROP ;

\ создать список разделителей, например:
\ s" список ограничителей в строке\n\t\000" Delimiter: name
: Delimiter: ( asc # --> )
             CREATE HERE DUP 256 DUP ALLOT ERASE
             +delimiters
             ( --> addr )
             DOES> ;

\ выделить лексему, ограниченную одним из ограничителей,
\ созданных с помощью Delimiter:
: xWord ( delim --> ASC # )
        CharAddr >R
        BEGIN GetChar WHILE
              OVER + C@ 0= WHILE
              >IN 1+!
          REPEAT DUP
        THEN 2DROP
        R> CharAddr OVER - ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока просто тест на подключаемость.
  S" passed" TYPE
}test

\EOF пример использования:

\ создаем строку, в которой перечисляем ограничители
\ строка начинается словом s" (а не S"), завершается " (двойной кавычкой)
s"  \r\n\"[]:;\000" 2DUP DUMP Delimiter: proba

\ пример использования
: test BEGIN proba xWord DUP WHILE
             CR ." лексема: " TYPE
                8 SPACES ." разделитель: "
                PeekChar EMIT
                >IN 1+!
       REPEAT 2DROP CR ;

\ разбор строки с произвольными разделителями:
test as[asda"sd]dasdv;vkjjl:vlkj;l


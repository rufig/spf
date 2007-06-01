\ 11-07-2004 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ разбор строк с различного вида разделителями
\ в том числе, когда разделители должны исполняться

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

\ взять из строки число в шестнадцатиричном виде
: HCHAR ( addr # -> CHAR ) 0 0 2SWAP >NUMBER IF THROW THEN 2DROP ;

\ сохранить список разделителей на HERE вернуть длинну
: +delimiters ( addr --> # )
              BASE @ >R HEX
              >R
              BEGIN PeekChar 0x0A <> WHILE
                    NextWord DUP WHILE
                    HCHAR R@ + -1 SWAP C!
               REPEAT 2DROP
              THEN
              RDROP
              R> BASE ! ;

\ создать список разделителей
\ разделители пишутся в 16 виде, могут находиться только на одной строке
: Delimiter: ( | xC xC xC EOL --> )
             CREATE HERE DUP 256 DUP ALLOT ERASE +delimiters
             ( --> addr )
             DOES> ;

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

\EOF

Delimiter: proba 3A 3B 5B 5D

: test BEGIN proba xWord DUP WHILE
             CR ." лексема: " TYPE
                8 SPACES ." разделитель: "
                PeekChar EMIT
                >IN 1+!
       REPEAT 2DROP CR ;

test as[asdasd]dasdv;vkjjl:vlkj;l

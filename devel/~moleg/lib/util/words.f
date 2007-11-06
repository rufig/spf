\ 03-02-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ распечатка списка слов (альтернативный вариант)

 REQUIRE ROUND     devel\~moleg\lib\util\stackadd.f
 REQUIRE R+        devel\~moleg\lib\util\rstack.f
 REQUIRE BLANKS    devel\~moleg\lib\spf_print\pad.f

        \ кол-во отображенных в строке символов »
        USER-VALUE line# ( --> n )

        \ кол-во отображенных строк на экране
        USER lines ( --> n )

      25 CONSTANT block_ ( const - кол-во отображаемых за один раз строк )

\ если следующее слово выходит за пределы экрана выдать CRLF, увеличить
\ на 1 переменную lines »
: ?newline ( # --> )
           DUP line# + DUP 80 <
           IF NIP ELSE CR DROP lines 1+! THEN TO line# ;

\ если клавиша ESC нажата выдать флаг FALSE
: ?escape ( --> flag )
          lines @ block_ / IF 0 lines ! KEY 0x1B <> CR ELSE TRUE THEN ;

\ отобразить список слов в указанном словаре
: VLIST ( vid # --> u )
        \ очистить буфер клавиатуры. Почему-то без этого глюки.
        BEGIN KEY? WHILE ." ." KEY DROP REPEAT

         0 TO line#  0 lines ! >R

         0 >R \ инициализируем счетчик слов
         @
         BEGIN DUP WHILE  1 R+
               DUP COUNT 1 +
               <# 2DUP DUP 2R@ DROP ROUND OVER - BLANKS BLANK 1 - HOLDS #>
               DUP ?newline  ?escape WHILE
                   TYPE
            CDR
          REPEAT 2DROP
         THEN DROP 2R> NIP ;

FALSE WARNING !

\ отобразить список слова в указанном словаре
: NLIST ( vid --> )
        DUP ." in vocabulary " VOC-NAME. ."  words are: " CR
        0x0F VLIST CR ." total: " . ." words." CR ;

\ распечатать список слов из верхнего контекстного словаря
: WORDS ( --> ) GET-ORDER OVER NLIST  nDROP ;

TRUE WARNING !

\ распечатать все слова в контексте в порядке следования словарей
: ALLWORDS ( --> )
           GET-ORDER
           BEGIN DUP WHILE
                 SWAP NLIST
              1 - CR
           REPEAT DROP ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{
  S" passed" TYPE
}test

\EOF
в отличие от стандартного WORDS, не нужно ловить момент, чтобы посмотреть
содержимое списка слов. Кроме того, появилось новое слово VLIST , которое
умеет отображать список слов без лишних украшений.
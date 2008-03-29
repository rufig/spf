\ 02-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ Конструкция выбора CASE
\ с учетом возможной вложенности операторов CASE
\ с возможностью исполнения во время интерпретации

 REQUIRE WHILENOT    devel\~moleg\lib\util\ifnot.f
 REQUIRE COMPILE     devel\~moleg\lib\util\compile.f
 REQUIRE CS>         devel\~moleg\lib\util\csp.f
 REQUIRE controls    devel\~moleg\lib\util\run.f

\ начать описание выбора варианта
: CASE ( n --> )
       STATE @ IFNOT init: THEN 5 controls +!
       !CSP COMPILE DUP ; IMMEDIATE

\ в отличие от OF данный вариант не сам сравнивает число,
\ а лишь получает флаг. Сравнение производится перед uOF
\ см примеры в конце
: uOF ( flag --> )
      COMPILE OVER COMPILE SWAP [COMPILE] IF COMPILE 2DROP ; IMMEDIATE

\ если n = значению, переданному CASE выполнить код вплодь то ENDOF
\ иначе пропустить секцию
: OF ( n --> ) COMPILE = [COMPILE] uOF ; IMMEDIATE

\ завершить описание варианта, начатого OF или uOF
: ENDOF ( --> ) [COMPILE] ELSE ; IMMEDIATE

\ завершить конструкцию CASE
: ENDCASE ( n n --> )
          ?COMP -5 controls +!
          COMPILE NIP COMPILE NIP
          BEGIN ?CSP WHILE [COMPILE] THEN REPEAT CSDrop
          controls @ IFNOT [COMPILE] ;stop THEN ; IMMEDIATE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 3 CASE  0 OF 123456 ENDOF
              1 OF 092874 ENDOF
              2 = uOF 569871 ENDOF
              3 = uOF 576948 ENDOF
              4 OF 689299 ENDOF
              234234
         ENDCASE 576948 <> THROW

     : sample CASE  0 OF 123456 ENDOF
                    0 OF 092874 ENDOF
                    2 = uOF 569871 ENDOF
                    3 = uOF 576948 ENDOF
                    4 OF 689299 ENDOF
                   234234
              ENDCASE ;
     0 sample 123456 <> THROW
     1 sample 234234 <> THROW
     2 sample 569871 <> THROW

     \ проверка на вложенность
     2 CASE 2 OF 48570
                 CASE 48570 = uOF 0 ENDOF
                      -1
                 ENDCASE
              ENDOF
            -1
       ENDCASE THROW

  S" passed" TYPE
}test


\EOF
     У стандартной структуры CASE  OF ENDOF ENDCASE есть неприятная
особенность, которая заключается в том, что OF всегда сравнивает значение
на равенство с константой. В предлогаемой библиотечке эта неудобность
исправлена, и можно делать так:

  : sample CASE  1 = uOF ." понедельник " ENDOF
                 2   OF ." вторник "     ENDOF
                 3 = uOF ." среда "       ENDOF
                 5 < uOF ." четверг или пятница " ENDOF
                ." другой "
           ENDCASE ." недели день" CR ;

  2 sample
  4 sample

Кроме того совсем не обязательно создавать слово, если вам необходимо сделать
выбор всего один раз, да еще и во время компиляции кода. Поэтому сейчас можно
делать и так:

3 CASE 1 = uOF ." понедельник " ENDOF
       2 = uOF ." вторник "     ENDOF
       3 = uOF ." среда "       ENDOF
       5 < uOF ." четверг или пятница " ENDOF
               ." другой "
  ENDCASE

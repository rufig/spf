\ 31-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ преобразование строки согласно указанной маски

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE KEEPS    devel\~moleg\lib\spf_print\pad.f
 REQUIRE R+        devel\~moleg\lib\util\rstack.f
 REQUIRE SKIPn    devel\~moleg\lib\strings\stradd.f

\ ----------------------------------------------------------------------------

\ переместить строку во временное хранилище
: asc>temp ( asc # --> asc # ) TUCK char + PAD SWAP CMOVE PAD SWAP ;

\ подменить в строке src # все символы '#' на цифры числа u
\ результат положить во временный буфер адрес и длину результата вернуть
: partnum ( src # u --> res # )
          >R asc>temp
          R> 0 <# # # # # # # # # # # #>
          2OVER BEGIN DUP WHILE char -
                      2DUP + C@ [CHAR] # =
                      IF 2SWAP char - 2DUP + C@ >R
                         2SWAP 2DUP + R> SWAP C!
                      THEN
                REPEAT 2DROP 2DROP
          2DUP + 0 SWAP C! ;

\ пропустить все символы до разделительной точки включая точку
: skip-fld ( src # --> pos. )
           0 >R BEGIN R@ OVER <> WHILE
                      OVER R@ + C@ [CHAR] . <> WHILE
                   char R+
                  REPEAT
                THEN 2DROP R> ;

\ из строки src # взять все символы до символа '.' или до конца строки
: get-fld ( asc # --> pos ) OVER SWAP skip-fld TUCK KEEPS ;

\ варианты действия для символов подстановки
: onchar ( asc # pos char --> asc # pos )
         [CHAR] ? OVER = IF DROP OVER MIN >R OVER R@ +
                            C@ KEEP R> char + EXIT
                         THEN
         [CHAR] * OVER = IF DROP >R 2DUP get-fld R> + EXIT THEN
         [CHAR] . OVER = IF KEEP DROP 2DUP skip-fld char +  SKIPn 0 EXIT THEN
         KEEP char + ;

\ сначала разбираемся с символами * ? - # игнорируем
: onward ( src # masc # --> res # )
          OVER + SWAP  0 >R
         <| BEGIN 2DUP <> WHILE \ пока не конец маски
                  DUP char + SWAP C@ >R
                  2SWAP 2R> onchar >R 2SWAP
            REPEAT RDROP 2DROP 2DROP
          |> ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока просто тест на подключаемость.
  S" passed" TYPE
}test

\EOF -- тестовая секция -----------------------------------------------------

S" must be: ab2-01.pt6   ?= " TYPE S" ab#-##.pt#" 2016 partnum TYPE CR
S" must be: abcabc.de.n  ?= " TYPE S" abc.def" S" **.??.n" onward TYPE CR

\EOF
данная библиотечка предназначена для формирования строки по заданому шаблону.
Слово onward получает оригинальную строку и шаблон, согласно которому строку
преобразует следующим образом:
     если встречен символ '*' - то все содержимое строки от начала до первой
       точки (либо от точки до следующей точки) коприруется в результирующую
       строку;
     если встречен символ '?' - то символ из этой позиции (начиная с начала
       исходной строки или от предыдущей точки) копируется на место знака ?;
     если встречен символ '.' - то позиция начала исходной строки считается
       с символа, находящегося за точкой.
Что касается слова partnum , то оно заменяет в исходной строке все символы
'#' на символы числа, полученного из параметра n в текущей системе исчисления
в обратном порядке, то есть с конца строки:
  S" a#bcd#-e##" 1234 partnum TYPE должен выдать: a1bdc2-e34.




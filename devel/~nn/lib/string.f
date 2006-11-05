REQUIRE /STRING lib/include/string.f
REQUIRE PLACE ~mak/place.f
REQUIRE { ~ac/lib/locals.f


CREATE str1 256 ALLOT   S" First line" str1 PLACE
CREATE str2 256 ALLOT
CREATE str3 256 ALLOT
CREATE str4 256 ALLOT
: ?? COUNT TYPE CR ; 
  \ TYPE печатает строку (выводит в стандартный вывод, в кроне - в nncron.out)
  \ CR - переводит строку
  \ слово str1 при использовании кладет адрес строки на стек
  \ чтобы преобразовать этот адрес в адрес с длиной исп. слово COUNT
str1 ( a -- ) COUNT ( a+1 len --) TYPE CR
  \ строки хранятся в виде: N byte1 byte2 ... byteN
  \ это так называемые строки со счетчиком.
  \ Слово PLACE (не из стандартного набора, но в кроне есть) помещает строку в указанное место
S" Это первая строка" str1 PLACE
  \ +PLACE добавляет строку к указанной строке
S" , а это к ней добавка" str1 +PLACE
  \ /STRING укорачивает заданную строку (только в стеке)
str1 COUNT 4 /STRING TYPE CR
  \ результат будет такой: первая строка, а это к ней добавка
  
  \ StringLeft str2 str1 10
str1 COUNT 10 MIN str2 PLACE                        str2 ??
  \ а вот и слово
: StringLeft ( a1 u len -- a1 len) MIN ;
  \ применяется так:
str1 COUNT 10 StringLeft str2 PLACE                 str2 ??

  \ StringRight str2 str1 10
str1 COUNT DUP 10 - 0 MAX /STRING str2 PLACE        str2 ??
  \ определение
: StringRight ( a1 u len -- a2 len) OVER SWAP - 0 MAX /STRING ;
str1 COUNT 10 StringRight str2 PLACE                str2 ??

  \ StringMid str2 str1 5 12
str1 COUNT 5 /STRING 12 MIN str2 PLACE              str2 ??

: StringMid ( a1 u pos len -- ) >R /STRING R> MIN ;
str1 COUNT 5 12 StringMid str2 PLACE                str2 ??

  \ StringTrimLeft str2 str1 5
str1 COUNT 5 /STRING str2 PLACE                     str2 ??
  \ StringTrimRight str2 str1 5
str1 COUNT 5 - 0 MAX str2 PLACE                     str2 ??

  \ StringReplace str2 str1 str3 str4
  \ Это словечко посложнее, но не настолько чтобы форт не переварил.
  \ Правда написано оно будет с учетом указанных строк, т.е. не
  \ универсально.
: StringReplace ( -- )
  str2 0!
  str1 COUNT
  BEGIN OVER SWAP str3 COUNT SEARCH WHILE
    >R SWAP 2DUP - str2 +PLACE
    str4 COUNT str2 +PLACE
    R> str3 C@ /STRING
  REPEAT
  str2 +PLACE
  DROP
;

S" Это строка - не очень хороший образец. И не только образец." str1 PLACE
S" не " str3 PLACE
S" " str4 PLACE \ на пустую строку заменить
StringReplace str2 ??

 \ если воспользоваться локальными переменными, то можно сделать это слово и 
 \ универсальным
: StringReplace2 { a2 a1 u1 a3 u3 a4 u4 \ rest -- a2 u2 }
  a2 0!
  a1 u1
  BEGIN OVER SWAP a3 u3 SEARCH WHILE
    TO rest SWAP 2DUP - a2 +PLACE
    a4 u4 a2 +PLACE
    rest u3 /STRING
  REPEAT
  a2 +PLACE
  DROP
  a2 COUNT
;

str2 S" Это строка - не оч. хор. обр. И не только обр." S" не " S" " StringReplace2 TYPE CR

\ StringGetPos pos str1 str2
: StringGetPos { a1 u1 a2 u2 -- pos}
    a1 u1 a2 u2 SEARCH IF DROP a1 - 1+ ELSE 2DROP 0 THEN ;
\ позиции начинаются с 1. если подстрока не найдена - 0

S" 123456789" S" 567" StringGetPos . CR

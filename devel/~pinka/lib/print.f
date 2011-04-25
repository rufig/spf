\ Ruvim, 02.2000

REQUIRE [UNDEFINED] lib\include\tools.f

\ : U.R ( u n -- ) \ 94 CORE EXT
\ Вывести на экран u выравненным вправо в поле шириной n символов.
\ Если число символов, необходимое для изображения u, больше чем n,
\ изображаются все цифры числа без ведущих пробелов в поле необходимой
\ ширины.
\  >R  U>D <# #S #>
\  R> OVER - 0 MAX 0 ?DO [CHAR] 0 EMIT LOOP TYPE
\ ;

\ printed leading zeros instead spaces
[UNDEFINED] HOLDS [IF]
: HOLDS ( addr u -- ) \ from eserv src
  SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
;                 [THEN]

: U$R  ( u n -- a1 u1 )
  >R  U>D <# #S #>  ( a u )
  R> OVER - 0 MAX  ( a u n-u )
  SWAP OVER + >R   ( a n-u )
  SWAP OVER - DUP >R SWAP ( a+u-n n-u )
  BL FILL
  R> R>
;



CHAR , VALUE cSeparator

: expand$ ( c-addr u-len c --  c-addr u-len+1 )
\ расширить строку, сдвинув подстроку c-addr u-len вправо на один символ. 
\ записать в "дырку" символ  с
    >R 2DUP
    OVER 1+ SWAP   ( a u  a a1 u )
    CMOVE>  \ начиная со старших адресов к младшим.
    1+ OVER R> SWAP C!
;

: UD$RS ( d n -- a u ) \ with separators
\ Преобразовать d как беззнаковое, выравненным вправо в поле шириной n символов
\ разбивая по три разряда  символом "," .
\ Если число символов, необходимое для изображения u, больше чем n,
\ преобразовываются все цифры числа без ведущих пробелов в поле необходимой
\ ширины. 

  >R <# #S #>  ( S: c-addr u-len )  ( R: n )
  2DUP  >R  + 0   ( S: a a+l 0 ) ( R: n l )

\ ===  
  BEGIN ( a u ) \ идем справа налево
      -3 2 D+  ( a-3 u+3 )
      DUP R@  <
  WHILE ( a1 u1 )
      cSeparator expand$  RP@ 1+!
  REPEAT ( a2 u2 )  2DROP
\ ===  

  R> ( a l )
  R> OVER -  0 MAX ( a l  n-l )
  >R SWAP R@ -  DUP R@  BL FILL
  SWAP R> +

\ ===
;


: UD.RS ( d n -- ) \ with separators
\ Вывести d как беззнаковое, выравненным вправо в поле шириной n символов
\ разбивая по три разряда  символом "," .
\ Если число символов, необходимое для изображения u, больше чем n,
\ изображаются все цифры числа без ведущих пробелов в поле необходимой
\ ширины.
  UD$RS TYPE
;

: U.RS ( u n -- ) \  with separators
\ Вывести u как беззнаковое, выравненным вправо в поле шириной n символов
\ разбивая по три разряда символом "," .
\ Если число символов, необходимое для изображения u, больше чем n,
\ изображаются все цифры числа без ведущих пробелов в поле необходимой
\ ширины.
  >R  U>D R>  UD.RS
;

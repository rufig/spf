\ Раскодировка из UTF-8
\ См. http://ru.wikipedia.org/wiki/Unicode

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE <= ~profit/lib/logic.f
REQUIRE { lib/ext/locals.f
REQUIRE fetchByte ~profit/lib/fetchWrite.f

MODULE: utf8

BASE @  2 BASE !

: byte ( n -- n1 ) 11111111 AND ;

\ 8-й бит переносим на стек как лог. знач., и сдвигаем направо байт
: cutBit ( n -- n2 b ) \ b=true если ноль
DUP 1111111 < SWAP
2* byte SWAP ;

\ addr -- адрес переменной-бегунка которая указывает на UTF-8 последовательность,
\ с каждый запуском значение бегунка сдвигается на нек-ое кол-во байт
: utf8Next ( addr -- wchar ) >R
R@ fetchByte
cutBit IF ( 0xxxxxxx )
2/
       ELSE
2* byte \ должно быть 1, но не проверяем
cutBit IF ( 110xxxxx )
11 LSHIFT
R@ fetchByte 111111 AND +
       ELSE
cutBit IF ( 1110xxxx )
1000 LSHIFT
R@ fetchByte 111111 AND 110 LSHIFT +
R@ fetchByte 111111 AND +
       ELSE
cutBit IF ( 11110xxx )
1110 LSHIFT
R@ fetchByte 111111 AND 1100 LSHIFT +
R@ fetchByte 111111 AND 110 LSHIFT +
R@ fetchByte 111111 AND +
       ELSE
       THEN
       THEN
       THEN
       THEN
RDROP ;

BASE !

EXPORT


: utf8Next ( addr -- wchar ) utf8Next ;


: utf8Move ( addr -- addr wchar ) SP@ utf8Next ;


\ addr u -- UTF-8 последовательность
\ buf -- буфер, в который складываются символы в виде двубайтного Unicode
\ Так как мы не знаем до декодирования кол-ва символов в UTF-8 последовательности,
\ то для buf следует занимать u*2 байтов. После вычисления, получив end, буфер
\ можно сократить
: utf8Decode ( addr u buf -- end ) { \ limit [ CELL ] A [ CELL ] B -- }
B !  OVER A !
+ TO limit
BEGIN
A @ limit <= WHILE
A utf8Next B writeWord
REPEAT 
B @ 2 - ; \ end -- адрес введённого последнего символа



\ На входе: utf8 последовательность addr1 u1
\ На выходе: взятый из кучи отрезок строки addr2 u2 равный Unicode (16-битовому) представлению строки на входе
\ Внимание: размер взятой из кучи памяти всегда равен (u1*2)+2, хотя, как правило, она занимает меньше места.
\ +2 -- это для конечного нулевого 16-битного слова (чтобы выходная последовательность являлась Wide ASCIIZ-строкой)
\ Само собой, что убирать выходную строку из кучи за вас никто не будет.
: utf8>uni ( addr1 u1 -- addr2 u2 )
DUP 1+ 2* DUP ALLOCATE THROW TUCK + CELL- 0!
DUP >R utf8Decode R> TUCK - ;

;MODULE

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES utf8>uni test

\ simple ansi text

: uni CHAR C, 0 C, ;

HERE
uni f uni o uni o
HERE OVER - ( addr u )
S" foo" utf8>uni TEST-ARRAY


\ russian text

HERE
208 C, 159 C, 209 C, 128 C, 208 C, 184 C, 208 C, 178 C, 208 C, 181 C, 209 C,
130 C, 44 C, 32 C, 208 C, 186 C, 209 C, 131 C, 45 C, 208 C, 186 C, 209 C, 131 C,
33 C, 46 C, 46 C,
HERE OVER - ( addr u ) utf8>uni

HERE
31 C, 4 C, 64 C, 4 C, 56 C, 4 C, 50 C, 4 C, 53 C, 4 C, 66 C, 4 C, 44 C, 0 C, 32
C, 0 C, 58 C, 4 C, 67 C, 4 C, 45 C, 0 C, 58 C, 4 C, 67 C, 4 C, 33 C, 0 C, 46 C,
0 C, 46 C, 0 C,
HERE OVER -

TEST-ARRAY


\ kazakh text
HERE
208 C, 156 C, 208 C, 181 C, 208 C, 189 C, 32 C, 210 C, 155 C, 208 C, 176 C, 208
C, 183 C, 208 C, 176 C, 210 C, 155 C, 32 C, 210 C, 155 C, 209 C, 139 C, 208 C, 183 C,
208 C, 180 C, 208 C, 176 C, 209 C, 128 C, 209 C, 139 C, 208 C, 189 C, 208 C,
176 C, 208 C, 189 C, 32 C, 210 C, 155 C, 208 C, 176 C, 208 C, 185 C, 209 C, 128 C,
208 C, 176 C, 208 C, 189 C, 32 C, 210 C, 155 C, 208 C, 176 C, 208 C, 187 C,
208 C, 176 C, 208 C, 188 C,
HERE OVER - ( addr u ) utf8>uni

HERE
28 C, 4 C, 53 C, 4 C, 61 C, 4 C, 32 C, 0 C, 155 C, 4 C, 48 C, 4 C, 55 C, 4 C,
48 C, 4 C, 155 C, 4 C, 32 C, 0 C, 155 C, 4 C, 75 C, 4 C, 55 C, 4 C, 52 C, 4 C,
48 C, 4 C, 64 C, 4 C, 75 C, 4 C, 61 C, 4 C, 48 C, 4 C, 61 C, 4 C, 32 C, 0 C, 155 C,
4 C, 48 C, 4 C, 57 C, 4 C, 64 C, 4 C, 48 C, 4 C, 61 C, 4 C, 32 C, 0 C, 155 C,
4 C, 48 C, 4 C, 59 C, 4 C, 48 C, 4 C, 60 C, 4 C,
HERE OVER - 

TEST-ARRAY


\ chinese text
HERE
233 C, 157 C, 158 C, 230 C, 136 C, 152 C, 228 C, 184 C, 141 C, 229 C, 177 C, 136 C,
HERE OVER - ( addr u ) utf8>uni

HERE
94 C, 151 C, 24 C, 98 C, 13 C, 78 C, 72 C, 92 C,
HERE OVER - ( addr u )

TEST-ARRAY

END-TESTCASES

\EOF

\ lib\ext\disasm.f
\ SEE utf8Decode
\ SEE utf8Next
\ SEE utf8>uni
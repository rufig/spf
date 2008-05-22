S" ~pinka/lib/ext/requ.f" INCLUDED
REQUIRE { lib/ext/locals.f
REQUIRE (: ~yz/lib/inline.f
REQUIRE /STRING lib/include/string.f
REQUIRE ENUM ~nn/lib/enum.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE vector ~ygrek/lib/hype/array.f
REQUIRE || ~day/hype3/locals.f
REQUIRE CString ~day/hype3/lib/string.f
REQUIRE NUMBER ~ygrek/lib/parse.f
REQUIRE state-table ~profit/lib/chartable.f
REQUIRE ?EXIT ~mak/utils.f
REQUIRE >=  ~profit/lib/logic.f

0xC000008CL VALUE ARRAY_BOUNDS_EXCEEDED


\ ------ ошибка ------
CLASS error
CString OBJ s
init: SUPER name " #{s}" s ! ;
: AsString ( -- addr u ) s @ STR@ ;
;CLASS

\ ------ ошибка ввода €чейки ------
error SUBCLASS input ;CLASS

\ ------ ошибка переполнени€ ------
error SUBCLASS overflow ;CLASS

\ ------ ошибка приведени€ типов ------
error SUBCLASS typeCast ;CLASS

\ ------ ошибка делени€ на ноль ------
error SUBCLASS zeroDiv ;CLASS

\ ------ ошибка некорректного задани€ числа ------
error SUBCLASS number ;CLASS

\ ------ ошибка выхода за границу ------
error SUBCLASS bounds ;CLASS

bounds TO ARRAY_BOUNDS_EXCEEDED

\ ------ ошибка -- циклическа€ ссылка ------
error SUBCLASS cycle ;CLASS

\ ------ ошибка в формуле ------
error SUBCLASS formula ;CLASS

: overflow? ( d -- ) DABS 2147483647. D> IF overflow THROW THEN ;

: ?error ( obj^ err -- obj ) ?DUP IF NewObj OVER @ => errorObj! THEN ; \ <-- нехороший момент

\ ------ одномерный массив с методом добавлени€ значени€ в конец ------
\ и с итератором...
vector SUBCLASS vectorAdd
: :add ( x -- ) SUPER :resize1 SUPER :last ! ;
: :iter { xt -- } \ xt ( addr -- )
SUPER :start
SUPER :size 0 ?DO
DUP xt EXECUTE
SUPER :iterate
LOOP DROP ;
;CLASS

\ ------ двумерна€ таблица ------
vectorAdd SUBCLASS Table
VAR _width
VAR _height
: xy ( u v -- i ) _width @ * + ;
: :xy ( x y -- addr )
DUP _height @ >= IF ARRAY_BOUNDS_EXCEEDED THROW THEN
OVER _width @ >= IF ARRAY_BOUNDS_EXCEEDED THROW THEN
xy SUPER :nth ;
: :resize ( w h -- )
2DUP _height ! _width !
* SUPER :resize ;
;CLASS


\ ------ класс €чейки ------
CLASS SpreadCell
VAR sheet
VAR contents
CELL PROPERTY errorObj

vectorAdd OBJ brefsArr
\ массив обратных св€зей -- обратные св€зи есть у любых €чеек,
\ т.к. люба€ €чейка име€ возможность быть задействованной в 
\ формуле может вли€ть на результат вычислени€ формулы

: :addbrefsArr brefsArr :add ;

dispose: errorObj@ ?DUP IF FreeObj THEN ;

: fill-refs-in-expression ;
: fill-brefs-in-expression ;
: resolved@ TRUE ;

: :input ( addr u -- ) 2DROP ;
: AsString ( -- addr u ) S" " ;
: AsString1 ( -- addr u ) errorObj@ ?DUP 0= IF SUPER this THEN => AsString ;
: value ( -- value ) contents @ ;
: result@ ( -- result ) errorObj@ ?DUP IF => class THROW THEN value ;

: resolve-cell
(: @ -1 OVER => unresolvedLinksCount +! => resolve-cell ;) brefsArr :iter ;

: :fill-all-refs ;

\ CATCH не совместим с HYPE (пока?) -- поэтому заводим отдельные методы-ловушки
: :catch-input ( addr u -- x1 x2 error | 0 ) (: SUPER this => :input ;) CATCH ;
: :catch-fill-all-refs (  -- error | 0 ) (: SUPER this => :fill-all-refs ;) CATCH ;
: :catch-resolve-cell (: SUPER this => resolve-cell ;) CATCH ;
;CLASS

\ ------ пуста€ €чейка ------
SpreadCell SUBCLASS nullCell
;CLASS

SpreadCell SUBCLASS inputErrorCell
init: input NewObj SUPER errorObj! ;
;CLASS

\ ------ €чейка с числом ------
SpreadCell SUBCLASS numberCell
: :input ( addr u -- )
-TRAILING 0. 2SWAP >NUMBER NIP ( ... ud 0 | ... xd ~0 )
0<> IF number THROW THEN
2DUP overflow? D>S ( n ) SUPER contents ! ;
: AsString SUPER value S>D (D.) ;
;CLASS

\ ------ €чейка со строкой ------
SpreadCell SUBCLASS stringCell
: :input ( addr u -- ) 1 CHARS /STRING >STR SUPER contents ! ;
: calc-cell typeCast THROW ;
: AsString SUPER value STR@ ;
;CLASS

\ ------ €чейка с формулой ------
stringCell SUBCLASS formulaCell

vectorAdd OBJ refsArr \ массив пр€мых св€зей
VAR unresolvedLinksCount \ кол-во неразрешЄнных пр€мых св€зей
VAR resolved
: resolved@ resolved @ ;
VAR result \ результат вычислени€ формулы
: result@ result @ ;

: AsString result@ S>D (D.) ;

\ «аполнение массива пр€мых ссылок
MODULE: fill-refs
: cell_reference_occured ( row col -- ) 
SUPER sheet @ => :xy @ refsArr :add ;
Include expression.f
EXPORT
: fill-refs-in-expression ( -- )
SUPER value process-expression
refsArr :size unresolvedLinksCount ! ;
;MODULE

\ «апись зависимостей между €чейками (изменение значени€ какой €чейки вли€ет на результат какой формулы)
MODULE: fill-brefs-for-cell
: cell_reference_occured ( row col -- )
SUPER sheet @ => :xy @ SUPER this SWAP => :addbrefsArr  ;
Include expression.f
EXPORT
: fill-brefs-in-expression ( -- )
SUPER value process-expression ;
;MODULE

: :fill-all-refs fill-refs-in-expression fill-brefs-in-expression ;

\ ¬ычисление формулы в €чейке
MODULE: calc
256 state-table op-save ( char -- xt )
all: formula THROW ;
: add ( n1 n2 -- n1+n2 ) >R S>D R> S>D D+ 2DUP overflow? D>S ;
symbol: + ['] add ;
symbol: - (: NEGATE add ;) ;
symbol: * (: M* 2DUP overflow? D>S ;) ;
symbol: / (: DUP 0= IF zeroDiv THROW THEN / ;) ;

: op-execute ( n1 xt n2 -- xt[n1,n2] ) SWAP EXECUTE ;
: cell_reference_occured ( row col -- n ) SUPER sheet @ => :xy @ => result@ ;
: nonnegative_number_occured ( n -- ... ) ; \ <-- автомат не поглощает получаемые числа -- они идут в вычисление
: operation_occured ( char -- 'xt ) >R op-execute R> op-save ;
: error_occured ( -- ) formula THROW ;
Include expression.f
EXPORT
: calc-cell
['] NOOP SUPER value process-expression op-execute result ! ;
;MODULE

: :catch-calc-cell (  -- error | 0 ) (: SUPER this => calc-cell ;) CATCH ;

: resolve-cell
resolved@ NOT unresolvedLinksCount @ 0= AND IF
resolved ON
SUPER this => :catch-calc-cell ?DUP IF NewObj SUPER errorObj! THEN
SUPER resolve-cell THEN ;
;CLASS

\ ¬з€тие строки до разделител€-табул€тора (строго один и строго табул€тор! Ќикаких двух табул€торов дл€ пущей красоты и пробелов)
: tabParse ( -- addr-z u ) 9 PARSE 2DUP + 0 SWAP C! ;
\ asciiz-строка нужна дл€ того чтобы вз€тие первого символа в случае пустой строки 
\ выдавало ноль в (в методе input-table )

\ ------ класс листа ------
CLASS Spreadsheet
Table OBJ t

256 state-table choose-class ( char -- ta )
all: inputErrorCell ;
0 asc: nullCell ;
CHAR ' asc: stringCell ;
CHAR = asc: formulaCell ;
symbols: 0123456789 numberCell ;

: :xy ( col row -- addr ) t :xy ;

: input-table
REFILL DROP
tabParse NUMBER 0= ?EXIT
tabParse NUMBER 0= ?EXIT
SWAP ( cols rows ) t :resize

t _height @ 0 ?DO 
REFILL 0= ?EXIT
t _width @ 0 ?DO
tabParse OVER C@ ( addr u char ) choose-class
( addr u ta ) NewObj DUP >R => :catch-input ?DUP IF NIP NIP NewObj R@ => errorObj! THEN
SUPER this R@ => sheet !
R> I J t :xy !
LOOP LOOP ;

: print-spreadSheet
t _height @ 0 ?DO CR
t _width  @ 0 ?DO
I J t :xy @ => AsString1 TYPE 9 EMIT
LOOP LOOP ;

: fill-refs (: DUP @ => :catch-fill-all-refs ?error DROP ;) t :iter ;

: calc-formulas
(: DUP @ => :catch-resolve-cell ?error DROP ;) t :iter ;

: mark-errors (: DUP @ => resolved@ NOT IF cycle ?error THEN DROP ;) t :iter ;
: tiny-excel input-table fill-refs calc-formulas mark-errors print-spreadSheet ;
;CLASS



: ---------------tiny-excel---------------
|| Spreadsheet s || s tiny-excel ;

\ ' ---------------tiny-excel--------------- MAINX ! 0 TO SPF-INIT? FALSE TO ?GUI S" tinyexcel-oo.exe" SAVE BYE
\ \EOF
---------------tiny-excel---------------
7	4
12	=C2	3	'Sample
=A1+B1*C1/5	=A2*B1	=B3-C3	'Spread
'Test	=4-3	5	'Sheet
""	=A9	=1/0	=A5
=B5	=1+C6+1	=5A	=A1++A1
=1+	x	=A5	=A6+B6
=a1	=a3	=a4	=a5



---------------tiny-excel--------------- \ ќшибка ссылки на €чейку (выход за заданные границы)
4	2
1	=A5
'bubu	3
'bubu	3
'bubu	3

---------------tiny-excel--------------- \ ƒеление на ноль
1	2
=1/0

\ #zerodiv


---------------tiny-excel--------------- \ —лишком большое число при вводе
2	2
9999999999	10
=B1*B1	3

\ #overflow       10
\ 100     3
\ 12.2007
( Слово USERIZE-VECT берет текст как имя существующего глобального вектора,
создает USER-вектор с тем же именем, прописывает его в глобальный вектор,
а старое значение глобального прописывает в созданный вектор
и то же старое значение использует для по-поточной инициализации 
созданного вектора.
  Далее, задание иного значения вектору даст эффект локально для потока
и не дольше, чем на время жизни этого потока.
  Пример
    USERIZE-VECT TYPE
)

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE {  lib/locals.f

: USERIZED-VECT ( name-a name-u -- )
  { | o }
  2DUP SFIND 0= IF -321 THROW THEN  DUP BEHAVIOR   DUP TO o
  2SWAP ( xt-v xt-o  a u ) 2DUP 2DUP 2DUP
  " USER-VECT {s}  TO {s}
  ..: AT-THREAD-STARTING {#o} TO {s} ;.. 
  ' {s} SWAP BEHAVIOR! " 
  \ STYPE CR EXIT
  DUP >R STR@ EVALUATE R> STRFREE
;
\ неудобно, что у "..:" стек непрозрачный.

: USERIZE-VECT ( "name" -- )
  PARSE-NAME USERIZED-VECT
;


\EOF example

USERIZE-VECT TYPE
: TYPE2 S" T2: " TYPE1 TYPE1 ; \ тут нельзя вызывать TYPE, чтобы 
                                \ не сделать безусловной косвенной рекурсии
:NONAME 
  S" test 1 passed " TYPE CR
  ['] TYPE2 TO TYPE
  S" test 2 passed " TYPE CR
; TASK 0 SWAP START DROP
50 PAUSE S" test 3 passed" TYPE CR

\ В дочернем потоке вначале вывод обычный, 
\ а потом предварямый словом "T2:"
\ В родительском потоке вывод остается неизменным.

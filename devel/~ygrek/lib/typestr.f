\ $Id$
\
\ Перенаправление всего вывода слова в строку
\ В отличие от предыдущей либы эта ловит исключения

\ Пример
\ :NONAME 3 . ." test" 3 SPACES ." hello" ; TYPE>STR
\ даёт " 3 test   hello" 

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

MODULE: TYPE>STR-MODULE

0 VALUE this.str
0 VALUE this.heap \ thanks to ruvim (in callback the THREAD-HEAP is changed)

EXPORT

\ Весь консольный вывод xt будет сохранён в строку str
: TYPE>STR-CATCH { xt | old.type old.heap old.str -- str ior }

   \ save all values that we will modify
   ['] TYPE BEHAVIOR TO old.type
   this.str TO old.str
   this.heap TO old.heap

   \ modify
   "" TO this.str
   THREAD-HEAP @ TO this.heap

   LAMBDA{
     THREAD-HEAP @ >R
     this.heap THREAD-HEAP ! 
     this.str STR+ 
     R> THREAD-HEAP ! } TO TYPE

   \ execute with overloaded TYPE
   xt CATCH 

   \ return
   this.str SWAP ( str ior -- )

   \ restore modified values on exit
   old.type TO TYPE 
   old.heap TO this.heap
   old.str TO this.str ;

\ Сохранить весь консольный вывод
\ Игнорировать исключения - лог будет сохранён в строку
: TYPE>STR ( xt -- str ) TYPE>STR-CATCH DROP ;

;MODULE

\EOF

(
REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f

0 SGENRAND

: a 
    ." Hello" CR ." Count it - "
    1000 0 DO 10 GENRANDMAX 1 + SPACES 10 0 DO 32 GENRANDMAX 32 + EMIT LOOP LOOP ;

' a TYPE>STR STR@ CR TYPE CR
\ )

:NONAME 3 . ." test" 3 SPACES ." hello" ; TYPE>STR STR@ CR TYPE

\ test 
:NONAME
  CR
  10 0 DO I . LOOP
  LAMBDA{ CR ." second" } TYPE>STR
  LAMBDA{ CR ." first" } TYPE>STR STR@ TYPE
  STR@ TYPE
  CR
  0 10 DO I . -1 +LOOP ; TYPE>STR STR@ CR TYPE

CR .( >>> this should fail with exception and exception log in the output string)
:NONAME
  10 0 DO I . LOOP
  20 0 / DROP
  100 THROW
  ." Strange..."
; TYPE>STR CR STR@ DUP .( Str length : ) . CR TYPE

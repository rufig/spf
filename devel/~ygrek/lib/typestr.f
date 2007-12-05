\ $Id$
\
\ Перенаправление всего вывода слова в строку
\ TYPE>STR ( xt -- s )
\ Ловит исключения внутри xt, работает независимо в каждом потоке

\ Пример
\ :NONAME 3 . ." test" 3 SPACES ." hello" ; TYPE>STR
\ даёт " 3 test   hello"

\ в TYPE подсовывается попоточный USER-TYPE
\ см. обсуждение в http://www.nabble.com/IsDelimiter-t4856219.html
USER-VECT USER-TYPE
' TYPE1 TO USER-TYPE
..: AT-THREAD-STARTING ['] TYPE1 TO USER-TYPE ;..
' USER-TYPE TO TYPE

\ -------------------------------------------------

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: TYPE>STR-MODULE

USER-VALUE this.str
USER-VALUE this.heap \ thanks to ruvim (in callback the THREAD-HEAP is changed)

EXPORT

\ Весь консольный вывод xt будет сохранён в строку str
: TYPE>STR-CATCH { xt | old.type old.heap old.str -- str ior }

   \ save all values that we will modify
   ['] USER-TYPE BEHAVIOR USER+ @ TO old.type
   this.str TO old.str
   this.heap TO old.heap

   \ modify
   "" TO this.str
   THREAD-HEAP @ TO this.heap

   LAMBDA{
     THREAD-HEAP @ >R
     this.heap THREAD-HEAP ! 
     this.str STR+ 
     R> THREAD-HEAP ! } TO USER-TYPE

   \ execute with overloaded TYPE
   xt CATCH 

   \ return
   this.str SWAP ( str ior -- )

   \ restore modified values on exit
   old.type TO USER-TYPE 
   old.heap TO this.heap
   old.str TO this.str ;

\ Сохранить весь консольный вывод
\ Игнорировать исключения - лог будет сохранён в строку (если был)
: TYPE>STR ( xt -- str ) TYPE>STR-CATCH DROP ;

;MODULE

\ -------------------------------------------------

/TEST

:NONAME { x | s }
  ." START" CR
  5 0 DO 
   x LAMBDA{ ."   thread " LAMBDA{ . ." hello" } TYPE>STR STYPE CR } TYPE>STR STYPE 
   100 PAUSE 
  LOOP
  ." END" CR
  ; TASK: q

: main
  3 0 DO I q START DROP LOOP
  10 0 DO " MAIN THREAD{CRLF}" STYPE 50 PAUSE LOOP ;

main   

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

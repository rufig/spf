\ Структурная обработка исключительных ситуаций как в delphi
\ на основе лямбда-конструкции by ruvim
\ v0.4 [19.08.2000] - Небольшие исправления
\ v0.3 [02.06.2000] - Синтаксис всё более похож на делфи, см. try-example.f
\ v0.2 [30.05.2000] - Теперь обработчик искл. ОС восстанавливается нормально
\ v0.1 [14.05.2000] 
\ Sergey Shishmintzev <sergey.shishmintzev/at/gmail.com> 
\
\ ПРИМЕЧАНИЯ:
\ 1. перед выполнением блока try-except в стек возратов добавляется tryDEPTH
\ байтов, количество которых зависит от реаизации слова CATCH
\ 2. после выполнения блока try-except состояние стека данных и стека возратов
\ сохраняется таким каким оно было до выполненения слова try (но его содержимое
\ может изменится, зависит от операций со стеком в даном блоке) плюс код 
\ исключения в стеке данных


BASE @ DECIMAL
44 CONSTANT tryDEPTH
-44 CONSTANT -tryDEPTH

-1 CONSTANT EAbort
-2 CONSTANT EAbort"

' DROP VALUE <os-exc-handler>
\ ' EXC-DUMP1  VALUE <os-exc-handler>

: try-prolog ( -- )
  \ Убрать вывод дампа для исключений ОС
  \ (точнее заменить его своим обработчиком)
  ['] <EXC-DUMP> >BODY @ R@ 5 + !
  <os-exc-handler> TO <EXC-DUMP> 
;
: try-epilog ( e ^xt -- e )
  \ Восстановить старый обработчик исключений ОС
  @ TO <EXC-DUMP>
; 


: try  ( -- )
\ время компиляции  ( -- orig1 xt t-addr t-s )
   ?COMP
   POSTPONE try-prolog
   HERE BRANCH, HERE >MARK
   CELL ALLOT \ t-addr = HERE 
   14444444 
; IMMEDIATE
          
: except  ( -- n_exception )
\ время компиляции ( orig1 xt t-addr t-s -- e-s )
\ t-s     метка: сначала был try?
\ t-addr  адрес ячейки для хранения кода ошибки
\ xt      исполнимый токен
\ orig1 
\ e-s     метка: тут был except
   ?COMP 14444444 <> IF -2007 THROW THEN
   RET,
   >RESOLVE1 >R R@ CELL+ LIT, POSTPONE CATCH
   R@ LIT, POSTPONE try-epilog
   POSTPONE ?DUP POSTPONE IF 
   POSTPONE DUP R@ LIT, POSTPONE !
   R>
   14444440
; IMMEDIATE

: finally
\ время компиляции (  orig1 xt t-addr t-s -- t-addr f-s )
   ?COMP 14444444 <> IF -2007 THROW THEN
   RET,
   >RESOLVE1 DUP CELL+ LIT, POSTPONE CATCH
   DUP LIT, POSTPONE try-epilog
   DUP LIT, POSTPONE !
   14444441
; IMMEDIATE

: raise  ( -- )
  DUP 14444440 = IF
    12 SP@ + @ LIT, POSTPONE @ POSTPONE THROW 
  ELSE
    ABORT" raise: In except/end-try block only"
  THEN
; IMMEDIATE

: end-try ( t-addr e-s|f-s -- )
  ?COMP
  DUP 14444441 = IF DROP LIT, POSTPONE @ POSTPONE THROW EXIT THEN
  14444440 = IF  DROP POSTPONE THEN EXIT THEN
  -2007 THROW
; IMMEDIATE                               		

\ отменить какую-либо обработку исключений и продолжить выполнение
: stop-except ( t-s -- ) POSTPONE finally DROP  DROP ; IMMEDIATE


BASE !
\ : tt try except end-try ;

\ S" tt.exe" SAVE BYE
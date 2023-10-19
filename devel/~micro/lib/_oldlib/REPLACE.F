\ Создание нового определения для уже скомпилированных слов с возможностью
\ вызова старого определения. Только для слов, у которых первая команда CALL.
\ Принцип действия: Первая команда CALL <слово1> заменяется на
\ JMP <новое_определение>. При вызове старого определения производится
\ восстановление первой команды.

0 VALUE INHERITED-1STCALL
\ Адрес первого CALL-а. Смещение, а не адрес, т. е. в том виде, в каком он есть.
0 VALUE INHERITED-XT
\ xt заменяемого слова
0 VALUE NEW-XT
\ xt нового определения

: (INHERITED) ( inh_xt inh_1stcall -- )
\ Вызов старого определения
\ inh-xt - его xt
\ inh-1stcall - его первый CALL
  OVER 1+ @ >R
\ Сохранили адрес первого слова в старом определении
  OVER 0xE8 SWAP C!
\ Восстановили CALL
  OVER 1+ !
\ Восстановили адрес
  DUP >R CATCH
\ Сохранили xt слова и выполняем
  0xE9 R@ C!
\ JMP ...
  R> R> SWAP 1+ !
\ Снова на новое определение
  THROW
\ Может, ошибка была? Тогда вываливаемся.
;

: INHERITED
\ Компилирует вызов старого определения
  INHERITED-XT POSTPONE LITERAL
  INHERITED-1STCALL POSTPONE LITERAL
  POSTPONE (INHERITED)
; IMMEDIATE

: _; POSTPONE ; ; IMMEDIATE
VECT ; IMMEDIATE
' _; TO ;

: REPLACE;
\ Завершить перекрывающее определение.
  ['] _; TO ;
  POSTPONE ;
\ Тут, наверное, всё понятно.
  INHERITED-XT
  LATEST-NAME-XT \ old new
  OVER - 5 - SWAP 1+ !
\ Замена адреса на новый. Если возникла ошибка во время компиляции, или
\ старое переопределяемое слово будет вызвано во время компиляции нового
\ определения, ничего страшного не произойдёт. Для этого замена адреса здесь,
\ а не в начале компиляции.
  0xE9 INHERITED-XT C!
\ Поставили JMP вместо CALL
; IMMEDIATE

: REPLACE:
\ Создание нового определения
\ REPLACE: Name [<words>] [INHERITED] [<words>] ;
  >IN @ >R
  NextWord SFIND IF
    DUP C@ 0xE8 <>
    ABORT" Bad word to REPLACE:"
    DUP TO INHERITED-XT
    1+ @ TO INHERITED-1STCALL
\ Сохраняем это на время компиляции - может пригодиться для INHERITED или
\ для чего-нибудь ещё.
    R> >IN !
    :
    HERE TO NEW-XT
    ['] REPLACE; TO ;
  ELSE
    RDROP
    1 ABORT" No word to REPLACE:"
  THEN
;

\ Пример:
\ > REPLACE: . DUP INHERITED INHERITED ;
\ > 1 .
\   1 1  Ok

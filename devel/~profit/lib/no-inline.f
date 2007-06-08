\ Подавление (до некоторой степени) оптимизатора для более предсказуемой
\ и контролируемой компиляции в кодофайл (используется в ~profit/lib/compile2heap.f
\ для динамической компиляции кода).

\ Использование:
\ NO-INLINE{ ... }NO-INLINE
\ , где вместо ... -- компилирующий код.

\ НЕ ПЫТАЙТЕСЬ вкладывать эти "скобки". Рекомендуется использовать их только в 
\ режиме интерпретации для обозначения слов, при определении которых требуется 
\ запретить инлайн:
\ NO-INLINE{ 
\ : blabla 10 0 DO I . LOOP ;
\ }NO-INLINE

\ Если нужно будет более сложное поведение, то рекомендуется использовать
\ бэкфортовый вариант NO-INLINE=> который можно вкладывать и использовать
\ в run-time для изменения поведения компиляции на этом этапе.

\ Скомпилировать ' DROP , без инлайна. При этом значение MM_SIZE восстанавливается.
\ : DROP, NO-INLINE=> POSTPONE DROP ;

REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: no-inline

VARIABLE SAVE-MM_SIZE
SAVE-MM_SIZE 0!

\ Подключаем внутрь модуля нормальный (не машкодовый) DO-LOOP
S" ~profit\lib\~moleg\doloop.f" INCLUDED

EXPORT

: NO-INLINE{ \ Убираем все попытки оптимизатора на инлайн (чтобы последнюю вещь убить -- компиляцию литералов)
MM_SIZE SAVE-MM_SIZE !
0 TO MM_SIZE
ALSO no-inline ;

: }NO-INLINE
\ Возвращаем работоспособность INLINE,
SAVE-MM_SIZE @ TO MM_SIZE
PREVIOUS ;

: NO-INLINE=> PRO
SAVE-MM_SIZE KEEP
NO-INLINE{ CONT }NO-INLINE ;

;MODULE

/TEST
lib/ext/disasm.f

NO-INLINE{
CR CR .( NO-INLINE:)
:NONAME 10 0 ." [" ?DO I . LOOP ." ]" ; DUP REST EXECUTE
}NO-INLINE

CR CR .( USUAL:)
:NONAME 10 0 ." [" ?DO I . LOOP ." ]" ; DUP REST EXECUTE


: DROP, NO-INLINE=> POSTPONE DROP ;

: r [ DROP, ] DROP ;
SEE r
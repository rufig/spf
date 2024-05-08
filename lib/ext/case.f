\ Конструкция выбора CASE ENDCASE

\ Данная реализация полагает, что "orig" располагается на стеке данных.
\ Из-за глобального определения стека "S-CSP" эта реализация
\ не является потокобезопасной во время компиляции.

\ Эта реализация используется в "./spf-asm.f" и "../lib/asm/486asm.f"
\ И там используются слова из семейства CSP, определенные здесь.

\ Более простая, портабельная и потокобезопасная реализация: "lib/include/control-case.f"


REQUIRE [IF] lib/include/tools.f


VARIABLE   CSP    \ Указатель стека контроля
6 CONSTANT L-CAS# \ Допустимый уровень вложенности
CREATE     S-CSP   L-CAS# CELLS ALLOT \ Стек контроля
S-CSP CSP !

: +CSP ( -> P)    \ Добавить уровень
  CSP @ DUP CELL+ CSP !
;
: -CSP ( -> )     \ Убрать уровень
  CSP @ 1 CELLS - CSP !
;
: !CSP ( -> )     \ Инициализировать уровень
  SP@ +CSP !
;
: CSP@ ( -> A)
  CSP @ 1 CELLS - @
;
: ?CSP ( -> )     \ Проверить выдержанность стека
  SP@ CSP@ <> 37 ?ERROR ( ABORT" Сбой стека по CSP !")
  -CSP
;


S" ENDCASE" GET-CURRENT SEARCH-WORDLIST 0= ?DUP NIP [IF]
\ avoid redefinition if these words are already defined in the compilation word list

: CASE ( -> )
  !CSP
; IMMEDIATE
: OF
  POSTPONE OVER POSTPONE =
  [COMPILE] IF POSTPONE DROP
; IMMEDIATE
: ENDOF
  [COMPILE] ELSE
; IMMEDIATE
: ENDCASE
  POSTPONE DROP BEGIN SP@ CSP@ =
  0=  WHILE  [COMPILE] THEN  REPEAT -CSP
; IMMEDIATE

[THEN]

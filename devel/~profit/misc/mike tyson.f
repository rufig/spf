REQUIRE NOT ~profit/lib/logic.f

MODULE: tyson

\ тут должны быть мозги
\ память и прочие анализы
\ но их нет.. (пока?)

VARIABLE r

r 0!

EXPORT

: move ( -- flag ) r @ NOT DUP r ! ;
: board ( state -- ) DROP ;

;MODULE

\ Тайсон работает: "качелями", правой-левой, правой-левой.
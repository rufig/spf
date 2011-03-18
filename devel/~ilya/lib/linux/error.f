\

REQUIRE NSYM: lib/include/facil.f
1 NSYM: strerror

\ Преобразуем номер ошибки в строку
: ERRSTR ( n -- adr n )
strerror ASCIIZ>
;

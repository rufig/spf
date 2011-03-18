\ Получаем имя компьютера
WINAPI: GetComputerNameA        KERNEL32.DLL
VARIABLE _maxsize
1024 _maxsize !
: GETCOMPUTERNAME ( -- adr n )
PAD _maxsize OVER GetComputerNameA DROP ASCIIZ>
;

\EOF
GETCOMPUTERNAME . CR ASCIIZ> TYPE
HEX
\ Заполним адреса процедур
AOLL  @ @ @ IMAGE-BASE 1034 + !
AOGPA @ @ @ IMAGE-BASE 1038 + !

\ Установим адреса для данного модуля
IMAGE-BASE 1034 + AOLL @ !
IMAGE-BASE 1038 + AOGPA @ !
DECIMAL

S" spf4.exe" S" src\spf.fres" tsave.f
.( The system has been saved)

BYE

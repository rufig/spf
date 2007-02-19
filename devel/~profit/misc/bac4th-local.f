\ Локальные переменные vs bac4th
~profit\lib\bac4th.f
lib\ext\locals.f

: a PRO { n -- } 10 0 DO I n + CONT DROP n CONT DROP LOOP ;
: r 10 a DUP CR . ; r
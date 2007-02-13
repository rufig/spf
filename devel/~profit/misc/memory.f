\ http://fforum.winglion.ru//viewtopic.php?p=4724#4724
\ Спор о заборе памяти
\ mOleg был прав, я -- нет.

:NONAME
1024 DUP * ( Mb ) 100 * DUP >R ALLOCATE THROW DUP
CR ." allocated, now dump"
KEY DROP
DUP 1024 CELLS DUMP
CR ." dumped, erase"
KEY DROP
R> ERASE
KEY DROP
CR ." erased, now free"
FREE THROW ;
EXECUTE
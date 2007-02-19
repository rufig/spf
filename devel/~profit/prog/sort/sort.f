\ Примерная программа (кошка для тренировок)
\ Программа читает из in.txt в текущей директории слова,
\ и сортирует их в алфавитном порядке пирамидальной сортировкой
\ Можно было бы и быстрой: ~pinka/samples/2003/common/qsort.f

\ Испытуемые: hsort.f , binary-search.f , arr{ , STRcompiledCode

\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE 2VARIABLE lib/include/double.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f
REQUIRE split-patch ~profit/lib/bac4th-str.f
REQUIRE iterateBy ~profit/lib/bac4th-iterators.f
REQUIRE HeapSort ~mlg/SrcLib/hsort.f
REQUIRE binary-search.f ~profit/lib/binary-search.f

: TAKE-TWO PRO *> <*> BSWAP <* CONT ;
: TAKE-THREE PRO *> <*> BSWAP <*> ROT BACK -ROT TRACKING <* CONT ;

: TAKE-FOUR PRO                      *>
                                    <*>
BSWAP                               <*>
ROT BACK -ROT TRACKING              <*>
2SWAP SWAP BACK SWAP 2SWAP TRACKING <*  CONT ;

2VARIABLE tmp

:NONAME
['] ANSI>OEM TO ANSI><OEM \ кодировку ставим в консоли

LOCAL arrLen LOCAL arrBeg

S" in.txt" load-file ( addr u ) 2DUP \ заметьте: взятие текста файла сделано *снаружи* arr{
\ если бы было сделано внутри, то текст был бы освобождён по выходу из arr{ ... }arr
\ , что нам не надо, так как у нас в массиве *отрывки* из этого текста

arr{
BL byChar split-patch 2DUP \ эффективнее сначала делить текст на пробелы, а потом -- на строки,
byRows split-patch         \ так как BL byChar при вызове каждый раз генерирует функцию
DUP ONTRUE \ пустые строки фильтруем
TAKE-TWO \ посылаем оба значения
}arr
arrLen !
arrBeg !

arrLen @ CELL / 2/ TO PyrN
arrBeg @ \ подставляемое в частично определённую функцию значение
" 2DUP SWAP
    CELLS 2* [ DUP ] LITERAL + 2@
ROT CELLS 2*         LITERAL + 2@
COMPARE 0< "
STRcompiledCode TO []<[]

arrBeg @
" 2DUP
CELLS 2* [ DUP ] LITERAL  + 2@                                       tmp 2!
CELLS 2* [ DUP ] LITERAL  + 2@  2OVER SWAP >R CELLS 2* [ DUP ] LITERAL + 2!
tmp 2@                                     R> CELLS 2*         LITERAL + 2! "
STRcompiledCode TO []exch[]


HeapSort

0 PyrN 1-
S" этой" \ искомое слово
arrBeg @
" CELLS 2* LITERAL + 2@ ( 2DUP CR TYPE )
2LITERAL COMPARE NEGATE " STRcompiledCode
binary-search . . KEY DROP

START{ arrBeg @ arrLen @ 2 CELLS iterateBy DUP 2@ CR TYPE }EMERGE
; EXECUTE
\ MemReport
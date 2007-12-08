\ Задача по перебору комбинаций которые составляются из 
\ шести случайных цифр и некоторых стековых операций 
\ Нужно находить те комбинации которые при выполнении 
\ оставляют на стеке 100 
\ http://fforum.winglion.ru/viewtopic.php?t=1054 


REQUIRE /STRING lib/include/string.f 
REQUIRE [UNDEFINED] lib/include/tools.f 

REQUIRE *> ~profit/lib/bac4th.f 
[UNDEFINED] KEEP [IF] 
: KEEP   ( addr --> / <-- )    R> SWAP DUP @  2>R EXECUTE 2R> SWAP ! ; 
[THEN] 

REQUIRE FREEB ~profit/lib/bac4th-mem.f 

REQUIRE chartable ~profit/lib/chartable.f 
[UNDEFINED] state-table [IF] 
: state-table таблица ; 
[THEN] 

REQUIRE ENUM ~nn/lib/enum.f 

REQUIRE CLASS ~day/hype3/hype3.f 
REQUIRE CStack ~day/hype3/lib/stack.f 

REQUIRE GENRANDMAX ~ygrek/lib/neilbawd/mersenne.f \ Mersenne twister - high-speed and quality RNG 
: GENRANDMINMAX ( min max -- r ) TUCK - GENRANDMAX + ; 

WINAPI: GetTickCount KERNEL32.DLL 

CStack SUBCLASS CStackI 
   CELL PROPERTY runner \ бегунок стека 

   \ из-того что я завязался на реализацию (использовал count@) 
   \ мне приходится дополнительно определять каким образом ведёт 
   \ себя свойство count при записи числа в стек 
   CStack NEW s 
   s count@  1 s push  s count@ - ABS 
   CONSTANT countStep \ шаг увеличения свойства count 
   s dispose 

   : depth ( -- n ) SUPER count@ countStep / 1- ; 

   \ адрес вершины стека 
   : tos' ( -- addr ) SUPER data@ depth CELLS + ; 

   \ подготовить к проходу стека, начиная от его дна 
   : prepare-fetch ( -- )   SUPER data@ runner! ; 
   \ достигли ли мы вершины? 
   : eof ( -- f )    runner@ tos' > ; 
   \ брать пошагово значения идя от дна: 
   : fetch ( -- n )    runner@ @  CELL runner +! ; 
;CLASS 

( 
CStackI NEW s 
1 s push 
2 s push 
3 s push 
\ 1 s count! 
\ s prepare-fetch 
\ s fetch . 
\ s fetch . 
\ s fetch . \EOF \ ) 

CStackI NEW ops \ стек операций 
CStackI NEW nums \ стек чисел 


VARIABLE depth \ актуальная глубина стека 

0 
ENUM lit \ взятие числа, аналог LITERAL 
ENUM plus 
ENUM minus 
ENUM mult 
ENUM divi 
ENUM neg 
ENUM fact 
( ops-num ) 

DUP state-table op-execute 
lit   asc: nums fetch ; 
plus  asc: + ; 
minus asc: - ; 
mult  asc: * ; 
divi  asc: / ; 
neg   asc: NEGATE ; 
fact  asc: DUP 2 < IF DROP 1 EXIT THEN 1 SWAP 1+ 1 DO I * LOOP ; \ факториал 

DUP state-table op-print 
lit   asc: nums fetch . ; 
plus  asc: ." + " ; 
minus asc: ." - " ; 
mult  asc: ." * " ; 
divi  asc: ." / " ; 
neg   asc: ." ~ " ; 
fact  asc: ." fact " ; 

DROP 

\ итератор по текущей последовательности операторов 
: ops=> ( --> op \ <-- ) PRO 
nums prepare-fetch  ops prepare-fetch 
BEGIN ops eof 0= WHILE 
ops fetch CONT REPEAT ; 


\ распечатать текущую последовательность операторов 
: ops. ops=> op-print ; 

\ исполнить текущую последовательность операторов 
: ops-execute ops=> op-execute ; 

\ дать верхние два числа остающиеся на стеке после выполнения 
\ текущей последовательности операторов (которая хранится в ops) 
\ слово полагается на правильно выставленную переменную depth которая 
\ хранит итоговую глубину стека после исполнения последовательности 
: get-two ( -- n1 n2 ) 
ops-execute 2DUP 2>R \ выполнить и взять два верхних числа 
depth @ 0 DO DROP LOOP \ стереть все следы работы ops-execute 
2R> ; 

\ дать вершину стека остающуюся на стеке после выполнения 
\ текущей последовательности операторов 
: get-one ( -- n ) 
ops top lit = IF nums top ELSE get-two NIP THEN ; 



\ можно ли применить операцию деления к верхним элементам стека остающегося 
\ после выполнения текущей последовательности? 
: is-dividable ( -- f ) get-two DUP 0<> IF MOD 0= ELSE 2DROP FALSE THEN ; 

\ выходное число, которое должны иметь на стеке искомые последовательности 
100 VALUE terminal 

\ записать новую операцию (с откатным действием) 
: op-bpush ( op -- ) PRO ops count KEEP ops push CONT ; 

\ откатное увеличение значения VARIABLE-переменной 
: B+! ( n addr -- ) PRO DUP KEEP +! CONT ; 

\ итератор, перебирающий все комбинации цифр указанных в строке 
\ addr u и операций 
\ результате находится в объектах ops и nums 
: comb ( addr u --> \ <-- ) PRO 
BACK 2DROP TRACKING 
depth 0! 
BEGIN 

*> \ альтернатива 1: взятие цифры из строки addr u 

   DUP 0<> ONTRUE \ строка должна быть непустой 
    *> \ под-альтернатива 1.1 -- взятая цифра отделяется как отдельная 
      OVER C@ [CHAR] 0 - \ берём цифру 
      nums count KEEP nums push \ записываем её в стек чисел (с откатным действием) 
      lit op-bpush \ записываем операцию lit 
      1 depth B+! \ новая цифра увеличивает глубину стека 
   <*> \ под-альтернатива 1.2 -- взятая цифра "прицепляется" к уже существующей 
      ops count@ 0<> ONTRUE ops top lit = ONTRUE \ является ли последняя операция -- lit 
      OVER C@ [CHAR] 0 - \ берём цифру 
      nums tos' KEEP \ сохраняем старое значение вершины стека чисел 
      nums pop 10 * + nums push \ добавляем на вершину стека чисел новый разряд -- взятую цифру 
   <* 

   1 /STRING \ сдвинуть строку на один символ 
   BACK -1 /STRING TRACKING \ откатное действие -- сдвиг в обратную сторону 

<*> \ альтернатива 2: функции с одним операндом 
   depth @ 0 > ONTRUE  \ необходимое условие применимости функции с одним операндом -- непустой стек 
    *> 
      EXIT \ <-- заблокировано по-умолчанию -- варианты растут экспоненциально... 
      ops top neg <> ONTRUE \ предыдущая операция не должна быть neg 
      neg op-bpush 
   <*> 
      EXIT \ <-- заблокировано по-умолчанию -- слишком тяжёлые вычисления... 
      ops top fact <> ONTRUE \ чтобы убрать комбинации из fact'ов 
      get-one 0 14 WITHIN ONTRUE \ область определения факториала на 2^32 -- [0;13]
      fact op-bpush 
   <* 

<*> \ альтернатива 3: функции с двумя операндами 
   depth @ 1 > ONTRUE \ необходимое условие применимости функции с двумя операндами -- достаточная глубина стека 
    *> 
      plus op-bpush 
   <*> 
      minus op-bpush 
   <*> 
      mult op-bpush 
   <*> 
      \ проверка применимости операции деления: делитель и остаток от деления должны быть ненулевыми 
      is-dividable ONTRUE 
      divi op-bpush 
   <* 

   -1 depth B+! \ уменьшение глубины стека (с откатным действием) 
<* 
DUP 0= \ когда строка addr u подошла к концу 
depth @ 1 = AND \ и на стеке только одно значение... 
IF 
ops-execute \ выполнить последовательность 
terminal = \ и проверить её на равенство 100 
NEGATE ( 0|1 ) 0 ?DO CONT LOOP \ если правда, то делать "успех" 
\ ^-- некрасивый обход глюка SPF 4.18, но зато теперь работает 
THEN 

\ ops depth 15 > ONFALSE \ ограничить глубину перебора 20-ью шагами 
AGAIN \ повторять пока не будут исчерпаны все альтернативы и их комбинации 
; 

\ Распечатать все варианты стековых операций с цифрам из числа n приводящие в результате к 100 
: print-combs ( n -- ) 
S>D <# #S #> ( addr u )
TUCK HEAP-COPY FREEB SWAP
CR CR ." -----" 2DUP TYPE ." -----" 
START{ 
comb CR ops. }EMERGE 
CR ." ----------------" ; 

: stack-ops-galore ( n -- ) 
GetTickCount SGENRAND 
0 DO 
999999 100000 GENRANDMINMAX print-combs 
LOOP ; 

10 stack-ops-galore 
\ 200100 print-combs
\ 123456 print-combs
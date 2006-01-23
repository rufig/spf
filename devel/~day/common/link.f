\ Dmitry Yakimov 13.03.2000
\ ftech@tula.net

\ Идея взята из Win32Forth
\ Формат записи списка:
\ 4 - указатель на предыдущий узел
\ n - данные узла
\ Список представляет просто переменную, хранящую адрес
\ последнего узла


\ После применения этого слова обязательно нужно скомпилировать данные
\ Например, 
\ LINK,
\ 123 ,

: LINK,     ( list -- )    \ скомпилировать связь с предыдущим узлом
         HERE  OVER @ ,  SWAP !  ;


\ На случай если данные узлов - указатели на исполняемые слова                
: DO-LIST ( list -- )
                BEGIN   @ ?DUP
                WHILE   DUP CELL+ @ EXECUTE
                REPEAT  ;

\ Исполняет xt с параметром `указатель на данные узлов`
\ Если xt возващает -1 то заканчиваем итерации, если 0 - продолжаем
: ITERATE-LIST ( list xt -- )
    >R
    BEGIN @ ?DUP
    WHILE DUP CELL+ R@ EXECUTE IF R> 2DROP EXIT THEN
    REPEAT RDROP
;

VARIABLE CHAINS

\ Первоначальная компиляция CHAINS и 4 + в DOES> для того, чтобы
\ для CHAINS были такие же правила обработки, что и для других
\ списков

: CHAIN ( "name" -- )
   CREATE
       CHAINS LINK,    
       0 ,
   DOES> CELL+
;

\ Создает новый список, но наследует предыдущий
: INHERITH-CHAIN ( list "name" -- )
   CREATE
       CHAINS LINK,    
       , ['] NOOP ,
   DOES> CELL+
;

\ sas

: ADD-LINK ( list "name" -- )
    LINK,
    ' ,
;

(
CHAIN test

: t1 2 . ;
: t2 3 . ;


test ADD-LINK t1
test ADD-LINK t2
test DO-LIST )
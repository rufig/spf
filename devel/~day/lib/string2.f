\ Расширения string.f
\ В процессе доработки...

REQUIRE SADD ~day\lib\string.f
REQUIRE {    lib\ext\locals.f

(
Возможные задачи:
- Найти и заменить текст в строке
- Найти позицию данного символа в строке
- Получить подстроку от сих и до сих как новую строку
- Вписать строку 1 с позиции такой-то в строке 2
- Преобразовать строку в UNICODE
- Преобразовать строку из UNICODE
)

: StrLChar ( c addr -- addr1 f )
\ Найти символ c в строке на вершине стека строк, искать начиная с u,
\ возвратить позицию u1 символа начиная с 0 и TRUE,
\ иначе u1 неопределено, f=FALSE
;

: StrRChar ( c addr -- addr1 f )
;

: StrSub ( u1 u2 S: s -- S: s s1 )
;

: StrPutDown ( addr u u1 S: s1 -- S: s2 )
;

: StrLReplace ( addr1 u1 addr2 u2 u3 -- u4 f )
;

: StrRReplace ( addr1 u1 addr2 u2 u3 S: s -- u4 f S: s1 )
;

: Str2Unicode
;

: Str2Plain
;

: StrCmp ( addr u addr1 -- f )
\ Сравнивать с адреса addr1
;

: StrSearch ( addr u addr1 -- c-addr3 u3 flag )
\ Искать с адреса addr1
;

: StrCopy ( addr u )
\ Копировать строку addr u в строку на вершине стека строк
\ Если длина новой больше чем длина исходной, увеличить длину строки
;

: StrUpper ( S: s -- S: s1 )
;

: StrLower ( S: s -- S: s1 )
;
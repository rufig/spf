( ~ac 23.08.2005
  $Id$

  Подключение внешних SQLite3 баз данных [по имени файла] в
  качестве контекстного форт-словаря. В результате базовые
  действия над таблицами производится самим интерпретатором 
  Форта, без необходимости использования языка SQL и специфичных API.

  Использование:
  ALSO SQLITE3_DB NEW: world.db3
  - создает словарь, привязанный к указанному файлу БД, имеющий
  то же имя, и добавляет этот словарь в контекст поиска.
  Когда транслятор форта будет осуществлять следующий поиск -
  эта БД автоматически загрузится и поиск его таблиц и VIEWS будет
  производиться так, как если бы это был "встроенный" форт-словарь.
  Выполнение найденной таблицы заменяет текущую вершину контекста
  поиска на найденный словарь найденной таблицы [или VIEW],
  как если бы она сама была определена через VOCABULARY, и дальнейший 
  поиск будет вестись, начиная с него. Поиск в текущей таблице
  приводит к замене текущей вершины контекста на ROW-словарь -
  искомое слово при этом считается именем ключевого поля таблицы,
  по которому будет теперь производиться дальнейший поиск.
  Поиск в текущем ROW-словаре будет инициировать, соответственно 
  неявное выполнение SELECT-запросов.
  todo: Которое в свою очередь вернет словарь с результатами.

  Таким образом возможна запись:
  world.db3 Country CODE RU
  которая в процессе исполнения даст тот же результат, что и
  SQL-запрос "SELECT * FROM Country WHERE CODE='RU'"

  Слова "@" и "." в этих контекстах переопределены для извлечения
  и печати текстовых значений "контекстных узлов" соответственно.

  Библиотека еще в доработке, поэтому примеры в конце не отключены.
)

REQUIRE db3_open     ~ac/lib/lin/sql/sqlite3.f 
REQUIRE ForEachDirWR ~ac/lib/ns/iterators.f

ALSO sqlite3.dll

: DB_RESET ( stmt -- )
\ db3_fin вызывается из db3_cdr, поэтому явно вызывать нужно
\ только в случае, если результат не обрабатывается
  db3_fin
;
: DB_CAR ( addr u sqh -- ppStmt )
  db3_car
;
: DB_CDR ( ppStmt -- ppStmt | 0 )
  db3_cdr
;
: DB_SELECT { addr u sqh wid -- ppStmt }
  addr u wid OBJ-NAME@  wid PAR@ OBJ-NAME@ 
  " SELECT * FROM {s} WHERE {s} LIKE '{s}'"
  STR@ 2DUP TYPE SPACE sqh DB_CAR
;
PREVIOUS

<<: FORTH SQLITE3_FIELD

: CAR DROP 0 ;

>> CONSTANT SQLITE3_FIELD-WL

: TABLE>FIELD ( addr u -- )
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  SQLITE3_FIELD-WL R@ CLASS!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;

<<: FORTH SQLITE3_ROW

: ?VOC DROP FALSE ;

: CAR { oid \ ppStmt -- item }
." SQLITE3_ROW CAR;"
  oid PAR@ PAR@ OBJ-DATA@ DUP \ sqh
  IF S" %" ROT oid DB_SELECT DUP 
     IF oid OBJ-DATA! oid
        ." OK!"
     THEN
  THEN
;
: NAME ( item -- addr u )
  ." SQLITE3_ROW NAME;"
  1 SWAP OBJ-DATA@ db3_col
;
: CDR ( item -- item )
  ." SQLITE3_ROW CDR;"
  DUP >R OBJ-DATA@ db3_cdr DUP R@ OBJ-DATA!
  IF R> ELSE RDROP 0 THEN
;
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти записи с oid='c-addr u' в таблице oid_par

\ сначала ищем в методах класса, чтобы не менять контекст поиска в БД...
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN
  
  oid PAR@ PAR@ OBJ-DATA@ DUP \ sqh
  IF c-addr u ROT oid DB_SELECT DUP 
     IF \ найден узел с заданным именем
        ( менять в oid или в CONTEXT ?! - разные полезные свойства ...)
        \ oid
        CONTEXT @
        OBJ-DATA! ['] NOOP 1
     THEN
  THEN
;
: . ( -- )
  0 CONTEXT @ ?DUP
  IF OBJ-DATA@ ?DUP 
     IF db3_dump
\       CONTEXT @ OBJ-DATA@ DB_RESET ( db3_fin вызывается из db3_cdr )
       0 CONTEXT @ OBJ-DATA!
     THEN
  ELSE DROP THEN
;
: PREVIOUS PREVIOUS ;
: \ POSTPONE \ ;
: .. .. ;
>> CONSTANT SQLITE3_ROW-WL

: TABLE>ROW ( addr u -- )
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  SQLITE3_ROW-WL R@ CLASS!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;

<<: FORTH SQLITE3_TABLE

: ?VOC DROP FALSE ;

: SHEADER ( addr u -- )
  TYPE ." to implement - INSERT :)"
;
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти в текущей таблице поле с именем c-addr u в БД oid и сделать его 
\ текущим (считать ключевым в дальнейшем поиске).

\ сначала ищем в методах класса
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN

  oid OBJ-NAME@ NIP DUP
  IF \ нужно заменить контекст таблицы на контекст записи
     \ т.к. сейчас известно имя ключевого поля
     DROP c-addr u TABLE>ROW ['] NOOP 1
  THEN
;
: PREVIOUS PREVIOUS ;
: \ POSTPONE \ ;
: .. .. ;

>> CONSTANT SQLITE3_TABLE-WL

: DB>TABLE ( addr u -- )
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  SQLITE3_TABLE-WL R@ CLASS!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;

<<: FORTH SQLITE3_DB

: ?VOC DROP TRUE ;

: CAR  { oid \ ppStmt -- item }
." SQLITE3_DB CAR;"
  oid OBJ-DATA@ \ sqh; если не подключена - подключим
  0= IF oid OBJ-NAME@ " {s}" STR@ db3_open oid OBJ-DATA! THEN

." open OK;"
  oid OBJ-DATA@ DUP
  IF \ удалось открыть, теперь нужно заменить контекст на словарь-таблицу
     \ т.к. только сейчас известно её имя
     S" select name from SQLite_Master where type LIKE '%'"
     ROT DB_CAR ( ppstmt )
\     DROP
\     ALSO oid CONTEXT ! S" SQLite_Master" DB>TABLE
\     S" type" TABLE>ROW CONTEXT @ PREVIOUS SQLITE3_ROW::CAR

  THEN
;
: NAME ( item -- addr u )
  0 SWAP db3_col
;
: CDR ( item -- item )
  db3_cdr
;
: >WID ( item -- wid )
  ALSO S" name" TABLE>FIELD CONTEXT @ OBJ-DATA!
  CONTEXT @ PREVIOUS
;

: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти таблицу с именем c-addr u в БД oid и сделать эту таблицу текущей.

\ сначала ищем в методах класса
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN

  oid OBJ-DATA@ \ sqh; если не подключена - подключим
  0= IF oid OBJ-NAME@ " {s}" STR@ db3_open oid OBJ-DATA! THEN

  oid OBJ-DATA@ DUP
  IF \ удалось открыть, теперь нужно заменить контекст на словарь-таблицу
     \ т.к. только сейчас известно её имя
     DROP c-addr u DB>TABLE ['] NOOP 1
  THEN
;
: PREVIOUS PREVIOUS ;
: \ POSTPONE \ ;
: .. .. ;
: WORDS ['] wid. CONTEXT @ ForEachDirWR ;
: \EOF \EOF ;

:>>

\EOF

ALSO SQLITE3_DB NEW: world.db3
WORDS
Country CODE RUS .
UKR .
BLR .
USA .
.. .. 
\ Country CODE ROS \ даст -2003
CountryLanguage CountryCode RUS .
PREVIOUS ORDER

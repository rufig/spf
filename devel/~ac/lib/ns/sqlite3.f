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
  поиск будет вестись, начиная с него. Поиск в текущем словаре-таблице
  будет инициировать, соответственно неявное выполнение SELECT-запросов.
  Которое в свою очередь вернет словарь с результатами.

  Таким образом возможна запись:
  world.db3 Country RU
  которая в процессе исполнения даст тот же результат, что и
  SQL-запрос "SELECT * FROM Country WHERE ID='RU'"

  Слова "@" и "." в этих контекстах переопределены для извлечения
  и печати текстовых значений "контекстных узлов" соответственно.

  Библиотека еще в доработке, поэтому примеры в конце не отключены.
)

REQUIRE db3_open ~ac/lib/lin/sql/sqlite3.f 

ALSO sqlite3.dll

: DB_SELECT { addr u sqh \ pzTail ppStmt -- ppStmt }
  addr u CONTEXT @ OBJ-NAME@ " SELECT * FROM {s} WHERE CODE='{s}'"
  STR@ 2DUP TYPE CR sqh db3_prepare -> ppStmt -> pzTail
  ppStmt db3_bind

  BEGIN \ ждем освобождения доступа к БД
    ppStmt 1 sqlite3_step DUP SQLITE_BUSY =
  WHILE
    DROP 1000 PAUSE
  REPEAT

  DUP 1 SQLITE_ROW WITHIN IF S" DB3_STEP" sqh db3_error? THEN

  SQLITE_ROW = IF ppStmt DUP . ELSE 0 THEN
;
: DB_RESET ( stmt -- )
  DUP 1 sqlite3_reset THROW  1 sqlite3_finalize THROW
;
PREVIOUS

<<: FORTH SQLITE3_TABLE

: SHEADER ( addr u -- )
  TYPE ." to implement - INSERT :)"
;
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти записи с ID='c-addr u' в таблице oid

\ сначала ищем в методах класса, чтобы не менять контекст поиска в БД...
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN
  
  oid PAR@ OBJ-DATA@ DUP \ sqh
  IF c-addr u ROT DB_SELECT DUP 
     IF \ найден узел с заданным именем
        ( менять в oid или в CONTEXT ?! - разные полезные свойства ...)
        \ oid
        CONTEXT @
        OBJ-DATA! ['] NOOP 1
     THEN
  THEN
;
: . ( -- )
  1 0 CONTEXT @ ?DUP
  IF OBJ-DATA@ db3_dump DROP
     CONTEXT @ OBJ-DATA@ DB_RESET
     0 CONTEXT @ OBJ-DATA!
  ELSE 2DROP THEN
;
>> CONSTANT SQLITE3_TABLE-WL

: DB>TABLE ( addr u -- )
2DUP TYPE ." : "
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  SQLITE3_TABLE-WL R@ CLASS!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;

<<: FORTH SQLITE3_DB

: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти таблицу с именем c-addr u в БД oid и сделать эту таблицу текущей.

  oid OBJ-DATA@ \ sqh; если не подключена - подключим
  0= IF oid OBJ-NAME@ " {s}" STR@ db3_open oid OBJ-DATA! THEN

  oid OBJ-DATA@ DUP
  IF \ удалось открыть, теперь нужно заменить контекст на словарь-таблицу
     \ т.к. только сейчас известно её имя
     DROP c-addr u DB>TABLE ['] NOOP 1
  THEN
;
:>>

ALSO SQLITE3_DB NEW: world.db3
Country RUS .
USA .
\ world.db3 Country ROS \ даст -2003
ORDER
PREVIOUS

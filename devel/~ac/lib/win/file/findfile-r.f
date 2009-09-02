( 26.01.03 А.Ч. )
( 08.07.09 ~pig )

\ Рекурсивный обход каталогов и выполнение 
\ групповых действий над файлами и каталогами.
\ Каталоги ".." и "." в xt не передаются.
\ Каталоги "." можно обрабатывать, если указать TRUE FIND-FILES.. !
\ Можно выполнить xt только для одного файла, если вместо имени
\ каталога подать на вход "имя_файла*".

\ xt ( addr u data flag -- ) - процедура вызываемая для каждого файла
\ addr u - путь и имя файла или каталога (готово для open-file, etc)
\ flag=true, если каталог, false если файл
\ data - адрес структуры с данными о файле или каталоге
\ поля структуры см. в findile.f
\ После вызова xt строка addr и структура data освобождаются,
\ поэтому, если xt требуется сохранять эти данные, надо копировать.

REQUIRE FIND-FILES       ~ac/lib/win/file/FINDFILE.F
REQUIRE {                ~ac/lib/locals.f
REQUIRE STR@             ~ac/lib/str5.f
REQUIRE WildCMP-U        ~pinka/lib/mask.f

USER FIND-FILES-RL    \ уровень вложенности 0-...
USER FIND-FILES-DEPTH \ ограничение вложенности, 0 - без ограничения,
                      \ 1 - только в указанном каталоге, ...
USER FIND-FILES..
USER FIND-FILES-U

USER FIND-FILES-USE-RET \ true, если надо вызывать xt также при выходе
                        \ из каталога (c data=0)

: IsNot..
  2DUP S" .." COMPARE 0<> ROT ROT S" ." COMPARE 0<> AND
;
: FIND-FILES-R ( addr u xt -- )
\ addr u - имя каталога для обхода
\ xt ( addr u data flag -- ) - процедура вызываемая для каждого файла

  { addr u xt \ addr2 data id f dir }

  FIND-FILES-RL @ 0= IF u FIND-FILES-U ! THEN
  addr u S" *" SEARCH NIP NIP
  addr u ROT IF " {s}" ELSE " {s}/*.*" THEN -> addr2
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr2 STR@ DROP FindFirstFileA -> id
  id -1 = IF data FREE DROP addr2 STRFREE EXIT THEN
  BEGIN
    data cFileName ASCIIZ> 2DUP IsNot.. FIND-FILES.. @ OR
    IF
      data dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0<> -> dir
      addr u 2DUP + 1- C@ [CHAR] * =
      IF 1-
         BEGIN 2DUP + 1- C@ DUP [CHAR] \ <> SWAP [CHAR] / <> AND WHILE 1- REPEAT 1-
      THEN
      " {s}/{s}" DUP -> f STR@ data dir xt EXECUTE
      dir
      IF FIND-FILES-RL 1+!
         FIND-FILES-RL @ FIND-FILES-DEPTH @ < FIND-FILES-DEPTH @ 0= OR
         data cFileName ASCIIZ> IsNot.. AND
         IF f STR@ xt RECURSE THEN
         FIND-FILES-RL @ 1- FIND-FILES-RL !
         FIND-FILES-USE-RET @
         IF f STR@ 0 dir xt EXECUTE THEN
      THEN
      f STRFREE
    ELSE 2DROP THEN
    data id FindNextFileA 0=
  UNTIL
  addr2 STRFREE
  id FindClose DROP
  data FREE DROP
;
: FIND-FILES-RP ( addr u xt -- )
\ addr u - имя каталога для обхода
\ xt ( addr u data flag -- ) - процедура вызываемая для каждого файла

  { addr u xt \ addr2 up tmpla tmplu data id f dir }

  u				\ пустой путь обработать особым образом
  IF
    addr u 1- + C@ is_path_delimiter	\ если на конце слэш - запрошен путь к каталогу
    IF
      u 1- S" *.*"		\ слэш для корректности отрезать
    ELSE
      addr GetFileAttributesA DUP FILE_ATTRIBUTE_DIRECTORY AND
      0<> SWAP -1 <> AND	\ IsDirectory - если это каталог, то задан путь без шаблона
      IF
        u S" *.*"
      ELSE
        addr u 2DUP CUT-PATH NIP DUP 1- 0 MAX SWAP
        2SWAP -ROT OVER + -ROT - 0 MAX
      THEN
    THEN
  ELSE
    0 S" *.*"			\ обойти весь текущий диск (как в FIND-DIRS-R)
  THEN
  -> tmplu -> tmpla -> up
  FIND-FILES-RL @ 0= IF up FIND-FILES-U ! THEN	\ фиксируется длина базового пути без шаблона
  addr up " {s}/*.*" -> addr2	\ поиск всегда по всем файлам
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr2 STR@ DROP FindFirstFileA -> id
  id -1 = IF data FREE DROP addr2 STRFREE EXIT THEN
  BEGIN
    data cFileName ASCIIZ> 2DUP IsNot.. FIND-FILES.. @ OR
    IF
      data dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0<> DUP -> dir	\ либо каталог
      ?DUP 0=
      IF
        tmpla tmplu S" *.*" COMPARE	\ *.* - особый шаблон, с ним сравнивается всё
        IF 2DUP tmpla tmplu WildCMP-U 0= ELSE TRUE THEN	\ либо файл проходит сравнение с шаблоном
      THEN
      IF
        addr up " {s}/{s}" DUP -> f STR@ data dir xt EXECUTE
        dir
        IF FIND-FILES-RL 1+!
           FIND-FILES-RL @ FIND-FILES-DEPTH @ < FIND-FILES-DEPTH @ 0= OR
           data cFileName ASCIIZ> IsNot.. AND
           IF
             tmpla tmplu f STR@ " {s}/{s}" DUP >R
             STR@ xt RECURSE
             R> STRFREE
           THEN
           FIND-FILES-RL @ 1- FIND-FILES-RL !
           FIND-FILES-USE-RET @
           IF f STR@ 0 dir xt EXECUTE THEN
        THEN
        f STRFREE
      ELSE 2DROP THEN
    ELSE 2DROP THEN
    data id FindNextFileA 0=
  UNTIL
  addr2 STRFREE
  id FindClose DROP
  data FREE DROP
;
: FIND-DIRS-R ( addr u xt -- )
\ addr u - имя каталога для обхода
\ xt ( addr u data -- ) - процедура вызываемая для каждого каталога

  { addr u xt \ addr2 data id f }

  addr u " {s}/*.*" -> addr2
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr2 STR@ DROP FindFirstFileA -> id
  id -1 = IF data FREE DROP addr2 STRFREE EXIT THEN
  BEGIN
    data cFileName ASCIIZ>
    2DUP 2DUP S" .." COMPARE 0<> ROT ROT S" ." COMPARE 0<> AND
    IF
      data dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0<>
      IF 
         addr u " {s}/{s}" DUP -> f STR@ data xt EXECUTE
         FIND-FILES-RL 1+!
         FIND-FILES-RL @ FIND-FILES-DEPTH @ < FIND-FILES-DEPTH @ 0= OR
         IF f STR@ xt RECURSE THEN
         FIND-FILES-RL @ 1- FIND-FILES-RL !
         f STRFREE
      ELSE 2DROP THEN
    ELSE 2DROP THEN
    data id FindNextFileA 0=
  UNTIL
  addr2 STRFREE
  id FindClose DROP
  data FREE DROP
;

\ печать полных имен каталогов
\ : TT NIP IF TYPE CR ELSE 2DROP THEN ;
\ печать имен каталогов со сдвигом на глубину
\ : TT IF FIND-FILES-RL @ CELLS SPACES cFileName ASCIIZ> TYPE CR
\      ELSE DROP THEN 2DROP ;
\ 2 FIND-FILES-DEPTH !
\ : T S" c:\temp" ['] TT FIND-FILES-R ; T

\ печать полных имен каталогов
\ : TT DROP TYPE CR ;
\ : T S" c:" ['] TT FIND-DIRS-R ; T


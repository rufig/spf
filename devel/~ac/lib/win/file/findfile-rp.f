( основано на FIND-FILES-R - ~ac/lib/win/file/findfile-r.f, 26.01.03 А.Ч. )
( 20.09.09 ~pig )

\ Рекурсивный обход каталогов и выполнение 
\ групповых действий над файлами и каталогами.
\ Каталоги ".." и "." можно обрабатывать, если указать TRUE FIND-FILES.. !

\ Каталоги всегда обрабатываются все
\ Файлы - только соответствующие переданному шаблону

\ xt ( addr u data flag -- ) - процедура вызываемая для каждого файла
\ addr u - путь и имя файла или каталога (готово для open-file, etc)
\ flag=true, если каталог, false если файл
\ data - адрес структуры с данными о файле или каталоге
\ поля структуры см. в findile.f
\ После вызова xt строка addr и структура data освобождаются,
\ поэтому, если xt требуется сохранять эти данные, надо копировать.

REQUIRE FIND-FILES       ~ac/lib/win/file/FINDFILE.F
REQUIRE FIND-FILES-R     ~ac/lib/win/file/findfile-r.f
REQUIRE {                ~ac/lib/locals.f
REQUIRE STR@             ~ac/lib/str5.f
REQUIRE WildCMP-U        ~pinka/lib/mask.f

[UNDEFINED] Match-U [IF] VECT Match-U ' WildCMP-U TO Match-U [THEN]

: FIND-FILES-RP ( S" path" S" template" xt -- )
\ path - имя базового каталога для обхода
\ template - шаблон имени файла
\ xt ( addr u data flag -- ) - процедура вызываемая для каждого файла

  { addr u tmpla tmplu xt \ addr2 data id f dir }

  u				\ пустой путь обработать особым образом
  IF
    addr u 1- + C@ is_path_delimiter	\ если на конце слэш, то это лишнее
    IF u 1- -> u THEN		\ слэш для корректности отрезать
  THEN
  tmplu 0=			\ если шаблон пустой
  IF S" *.*" -> tmplu -> tmpla THEN	\ будет перебор всех файлов

  FIND-FILES-RL @ 0= IF u FIND-FILES-U ! THEN	\ фиксируется длина базового пути без финального слэша
  addr u " {s}/*.*" -> addr2	\ поиск всегда по всем файлам
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
        IF 2DUP tmpla tmplu Match-U 0= ELSE TRUE THEN	\ либо файл проходит сравнение с шаблоном
      THEN
      IF
        addr u " {s}/{s}" DUP -> f STR@ data dir xt EXECUTE
        dir
        IF FIND-FILES-RL 1+!
           FIND-FILES-RL @ FIND-FILES-DEPTH @ < FIND-FILES-DEPTH @ 0= OR
           data cFileName ASCIIZ> IsNot.. AND
           IF
             tmpla tmplu f STR@ " {s}/{s}" DUP >R
             STR@ tmpla tmplu xt RECURSE
             R> STRFREE
           THEN
           -1 FIND-FILES-RL +!
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

\ печать полных имен каталогов
\ : TT NIP IF TYPE CR ELSE 2DROP THEN ;
\ печать имен каталогов со сдвигом на глубину
\ : TT IF FIND-FILES-RL @ CELLS SPACES cFileName ASCIIZ> TYPE CR
\      ELSE DROP THEN 2DROP ;
\ 2 FIND-FILES-DEPTH !
\ : T S" c:\temp" S" *" ['] TT FIND-FILES-RP ; T

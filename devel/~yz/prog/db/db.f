\ Интерпретатор диалоговых форм для баз данных
\ Ю. Жиловец, 5 ноября 2003 г.

REQUIRE "          ~yz/lib/common.f
REQUIRE small-hash ~yz/lib/hash.f
REQUIRE <(         ~yz/lib/format.f
REQUIRE WINDOWS... ~yz/lib/wincc.f
REQUIRE PARSE...   ~yz/lib/parse.f
REQUIRE (:         ~yz/lib/inline.f
REQUIRE StartSQL   ~yz/lib/odbc.f
REQUIRE BIND-HASH  ~yz/lib/odbchash.f
REQUIRE Z>>        ~yz/lib/data.f

\ -------------------------------------
" DB 1.0" ASCIIZ prog-name

0 VALUE database
0 VALUE FORMS
0 VALUE SUBFORMS
0 VALUE DATA

0 VALUE V1
0 VALUE V2
0 VALUE V3
0 VALUE V4
0 VALUE V5

0 VALUE debug  \ TRUE TO debug

\ -------------------------------------
\ Обработка ошибок

: my-error ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP -2 = IF DROP 
                ER-A @ ER-U @ PAD CZMOVE PAD err
           THEN
  >R <( R> DUP " Ошибка #~N (0x~06H)" )> err
;
: error ( z--) err BYE ;
: ?error ( ? z --) SWAP IF error ELSE DROP THEN ;

0 VALUE fatal-a
0 VALUE fatal-n

: !fatal ( a n -- ) TO fatal-n TO fatal-a ;

CREATE last-sql-statement 500 ALLOT
VARIABLE last-form-wid

: fatal-error ( z -- )
  >R <( R> fatal-a fatal-n  
    S" form-name" last-form-wid @ SEARCH-WORDLIST IF EXECUTE ELSE S" ?" THEN
    RP@ 5 CELLS OVER + SWAP DO I @ WordByAddr CELL +LOOP
    " ~Z: ~S~/Последняя вызванная форма: ~S~/Стек возвратов: ~S ~S ~S ~S ~S"
  )> error
;

WINAPI: SQLGetDiagField ODBC32.DLL

: get-sql-error { buf err \ ptr -- }
 ^ ptr 1000 buf err 1 database 2 CELLS@ W: sql_handle_stmt
  SQLGetDiagField DROP
;

: sql-message { message \ [ 500 ] descr [ 6 ] code }
  descr W: sql_diag_message_text get-sql-error
  code  W: sql_diag_sqlstate get-sql-error
  <( message code last-sql-statement descr
     " ~Z: ~Z~/~'~Z~'~/~Z" 
  )> ;

: ?sql-error ( ? -- ) 0xFFFF AND 
  DUP W: SQL_SUCCESS = IF DROP EXIT THEN 
  W: SQL_SUCCESS_WITH_INFO = IF 
    " Предупреждение" sql-message msg 
  ELSE 
    " Ошибка доступа к базе данных" sql-message error 
  THEN ;

: err-dialog ( z -- )
  { \ [ 256 ] buf }
  buf ZMOVE
  <( ERR-FILE ERR-LINE# ERR-IN# buf ERR-LINE
  " ~S: ~N, ~N~/~Z~/~S" 
  )> err
  CURFILE @ ?DUP IF FREE DROP CURFILE 0! THEN
  BYE ;

\ ------------------------------
\ Запросы
: query ( z -- ) DUP last-sql-statement ZMOVE 
  database ExecuteSQL ?sql-error ;

: FirstRow ( -- ) database NextRowWithInfo 
  DUP W: sql_no_data_found = IF 
    DROP " Запрос не вернул данных" sql-message error 
  ELSE
    ?sql-error 
  THEN ;

: ask-number ( z -- ) query
  BIND
    SQL_INTEGER res
    last-sql-statement ASCIIZ> !fatal
    FirstRow
    res
  BIND;
;

: ask-string ( query buf -- ) SWAP query
  BIND
    SQL_CHAR str
    last-sql-statement ASCIIZ> !fatal
    FirstRow
    str SWAP ZMOVE
  BIND;
;

: insert-from-hash ( table hash -- ) 
  OVER last-sql-statement ZMOVE
  database insert-hash ?sql-error ;

: read-to-hash ( query hash -- )
  SWAP query BIND-HASH FirstRow UNBIND-HASH ;

: fill-ctl ( query ctl -- ) 
  >R query
  BIND
    SQL_CHAR str
    last-sql-statement ASCIIZ> !fatal
    FirstRow
    str R> -text!
  BIND;
;

\ : row-empty? ( -- ?) database ColCount 0= ;

: fill-combo ( query combo -- )
  >R query
  BIND
    SQL_CHAR str
    BEGIN
      database NextRow WHILE
      str R@ addstring
    REPEAT
  BIND; RDROP ;

MODULE: ODBC EXPORT

: fill-table { q table \ ulim counter -- }
  table clear-listview
  q query 
  last-odbc @ ColCount args# MIN 1+ TO ulim
  ulim 1 ?DO
    I last-odbc @ ColType CASE
\    W: sql_bit  OF ENDOF
\    W: sql_date OF ENDOF
     DROP I W: sql_char bind-column-len
  LOOP
\  1 TO counter
  BEGIN
    last-odbc @ NextRow
  WHILE
    "" 0 0 table add-item
    ulim 1 ?DO
      I field 0 I 1- table -isubitem!
    LOOP
\    counter 1+ TO counter
  REPEAT
  unbind-all ;

;MODULE

\ ------------------------------
\ Система

WINAPI: LoadImageA USER32.DLL

: load-icon ( z -- hicon)
  >R W: lr_loadfromfile 0 0 W: image_icon R> IMAGE-BASE LoadImageA ;

\ ------------------------------
\ Формы

0
CELL -- :ctl
CELL -- :name
CELL -- :elink    
CELL -- :create
CELL -- :load
CELL -- :unload
CELL -- :clear
CELL -- :invalid
\ добавляя новые поля, не забудьте изменить ELEMENT:
== elem-len

: || ( elem -- ) :ctl @ | ;

USER-VALUE last-element

: me ( -- ) last-element :ctl [COMPILE] LITERAL POSTPONE @ ; IMMEDIATE
: me! ( ctl -- ) last-element :ctl [COMPILE] LITERAL POSTPONE ! ; IMMEDIATE
: myname ( -- ) 
  last-element :name @ [COMPILE] LITERAL POSTPONE COUNT 
; IMMEDIATE

: ELEMENT: ( ->bl; -- )
  HERE
  CREATE HERE >R
  0 , 5 + ,
  last-element ,  R> TO last-element
  ['] NOOP ,	\ :create
  ['] NOOP ,    \ :load
  ['] NOOP ,    \ :unload
  ['] NOOP ,	\ :clear
  ['] FALSE ,   \ :invalid
;

: ?INTERP STATE @ IF " Только для режима интерпретации" error THEN ;

: ELEMENT; ( -- ) ?INTERP ; IMMEDIATE

: create: ( -- ) ?INTERP
  :NONAME last-element :create ! ; IMMEDIATE
: load: ( -- ) ?INTERP
  :NONAME last-element :load ! ; IMMEDIATE
: unload: ( -- ) ?INTERP
  :NONAME last-element :unload ! 
  debug IF
    last-element :name @ [COMPILE] LITERAL 
    POSTPONE COUNT POSTPONE TYPE POSTPONE CR
  THEN ; IMMEDIATE
: clear: ( ->bl; -- ) ?INTERP
  :NONAME last-element :clear ! ; IMMEDIATE
: invalid: ( ->bl; -- ) ?INTERP
  :NONAME last-element :invalid ! ; IMMEDIATE

: FORM: ( ->bl; -- old-curr-wid )
  GET-CURRENT
  TEMP-WORDLIST ALSO CONTEXT ! DEFINITIONS
  S" form-elements" CREATED 0 ,
  S" form-name" CREATED
  BL PARSE S",
  0 TO last-element
  DOES> COUNT
;

: FORM; ( old-curr-wid -- wid ) 
  last-element S" form-elements" SFIND 
  0= IF " В форме отсутствует переменная form-elements" fatal-error THEN
  >BODY !
  GET-CURRENT SWAP SET-CURRENT
  PREVIOUS
;

: all-elements ( xt list -- )
\ передается ( elem -- )
  SWAP >R
  BEGIN
    ?DUP 
  WHILE
    DUP R@ EXECUTE
    :elink @
  REPEAT RDROP
;

: create-all ( list -- )
  (: :create @ EXECUTE ;) SWAP all-elements ;  
: clear-all ( list -- )
  (: :clear @ EXECUTE ;) SWAP all-elements ;  
: load-all ( list -- )
  (: :load @ EXECUTE ;) SWAP all-elements ;  
: unload-all ( list -- )
  (: :unload @ EXECUTE ;) SWAP all-elements ;  

: some-elements ( xt list -- ?)
\ передается ( elem -- ?)
  SWAP >R
  BEGIN
    ?DUP 
  WHILE
    DUP R@ EXECUTE
    IF RDROP DROP TRUE EXIT THEN
    :elink @
  REPEAT RDROP FALSE
;

: are-invalid ( list -- ?)
  (: :invalid @ EXECUTE ;) SWAP some-elements
;

\ -------------------------------------------------

: ?FORMEXEC ( ... a # wid -- F / ... T ) DUP last-form-wid !
  SEARCH-WORDLIST IF EXECUTE TRUE ELSE FALSE THEN ;

: FORMEXEC ( ... a # wid -- ... )
  >R 2DUP !fatal R>
  ?FORMEXEC 0= IF " FORMEXEC: Слово не найдено" fatal-error THEN ;

\ -------------------------------------------------
\ Регистрация форм и подформ

0
CELL -- :formwid
CELL -- :formwin
CELL -- :formgrid
== #form-rec

0 
CELL -- :subformgrid
== #subform-rec

: register-form { name-a name-n wid win grid -- }
  #form-rec name-a name-n FORMS HASH!R >R
  wid  R@ :formwid  !
  win  R@ :formwin  !
  grid R> :formgrid ! ;

: register-subform { wid grid -- }
  #form-rec ^ wid 4 SUBFORMS HASH!R >R
  grid R> :subformgrid ! ;

: unregister-form ( a n -- ) FORMS -HASH ;
: unregister-subform ( a n -- ) SUBFORMS -HASH ;

: ?formrec ( a n -- rec)
  2DUP !fatal
  FORMS HASH@R ?DUP 0= IF " Форма не зарегистрирована" fatal-error THEN ;

: ?subformrec { wid -- rec }
  S" form-name" wid FORMEXEC !fatal
  ^ wid 4 SUBFORMS HASH@R ?DUP 0= IF " Подформа не зарегистрирована" fatal-error THEN ;

: get-form ( a n -- wid)
  ?formrec :formwid @ ;

: get-form-win ( a n -- win)
  ?formrec :formwin @ ;

: get-form-grid ( a n -- grid)
  ?formrec :formgrid @ ;

: get-subform-grid ( wid -- grid)
  ?subformrec :subformgrid @ ;

: WCALL ( wid proc -- ) ASCIIZ> ROT FORMEXEC ;
: FCALL ( form-z proc -- ) ASCIIZ> ROT ASCIIZ> get-form FORMEXEC ;
: SCALL ( form-z var proc -- ) -ROT FCALL SWAP WCALL ;

\ -------------------------------------------------

: LOAD-FORM { file-a file-u \ depth -- wid }
  DEPTH TO depth
  file-a file-u ['] INCLUDED CATCH
  ?DUP IF
    CASE
      2 3 <OF< <( file-a file-u " Файл ~'~S~' не найден" )> error EXIT ENDOF
      -2003 OF " Неизвестное ключевое слово"  ENDOF
      0xC0000005 OF " Нарушение общей защиты" ENDOF
    >R <( R> " Ошибка ~N" )>
    END-CASE
    err-dialog EXIT
  THEN
  DEPTH 1- depth <> IF " Сбой стека при загрузке формы" err EXIT THEN
;

MESSAGES: form-pre
M: wm_close
  thiswin winminimize
  TRUE
M;
MESSAGES;

: NEW-FORM ( fmname-a fmname-u -- )
  { \ form }
  LOAD-FORM TO form
  0 dialog-window 
  TRUE OVER -dialog!
  S" form-noclose" form ?FORMEXEC IF
    form-pre OVER -pre!
  THEN
  S" form-icon" form ?FORMEXEC IF
    load-icon OVER -icon!
  THEN
  S" form-smicon" form ?FORMEXEC IF
    load-icon OVER -smicon!
  THEN
  ( win ) >R
  S" form-title" form FORMEXEC R@ -text!
  S" form-grid"  form FORMEXEC R@ -grid!
  \ зарегистрируем форму
  S" form-name" form FORMEXEC form R@ DUP -grid@ register-form
  R@ S" form-window-init" form ?FORMEXEC 0= IF DROP THEN
  R> winshow
;

: SUB-FORM ( data formfile-a formfile-u -- wid )
  LOAD-FORM >R
  S" form-data" R@ FORMEXEC !
  R@ S" form-grid" R@ FORMEXEC 
  register-subform R> ;

: UNLOAD-SUBFORM ( wid -- ) S" form-destroy" ROT ?FORMEXEC DROP ;

: UNLOAD-FORM ( name name# -- )  get-form UNLOAD-SUBFORM ;

: MODAL-FORM ( data form-a form-n -- ?)
  { \ form }
  LOAD-FORM TO form
  S" form-title" form FORMEXEC MODAL...
  S" form-data"  form FORMEXEC !
  S" form-grid"  form FORMEXEC SHOW
  dialog-termination W: idok =
  ...MODAL 
  form FREE-WORDLIST ;

\ -------------------------------
\ Мелочи

: skip  filler 1 10 this ctlresize | ;
: space ( n -- ) filler SWAP 1 this ctlresize ;
: gap  20 space ;

: format-money ( n -- z)  S>D <# 0 HOLD # # c: . HOLD #S #> DROP ;
: unformat-money ( z -- n)
  0 SWAP BEGIN
    DUP C@ ?DUP 
  WHILE
    DUP c: . = IF DROP ELSE c: 0 - ROT 10 * + SWAP THEN
    1+
  REPEAT DROP
;
USER ((-stack-begin

: (( ( -- ) SP@ ((-stack-begin ! ;
: )) ( ... -- end begin ) SP@ ((-stack-begin @ CELL- ;

: striped-table ( -- ctl)
  W: lvs_report listview
  (* lvs_ex_gridlines lvs_ex_subitemimages lvs_ex_fullrowselect *) 
  this -exstyle! ;

: table-columns ( end beg tbl -- )
  { tbl \ cnt }
  0 TO cnt
  DO 
    I @ cnt DUP tbl add-column
    I CELL- @ cnt tbl -cwidth!
    cnt 1+ TO cnt
  2 CELLS NEGATE +LOOP
  ((-stack-begin @ SP! ;

: column-right ( col table -- ) W: lvcfmt_right -ROT -cflags! ;

: calendar1 ( -- ctl) W: mcs_notodaycircle calendar ;

WINAPI: GetLocalTime KERNEL32.DLL

: today-datetime ( dt -- ) GetLocalTime DROP ;

: format-date ( dt -- z ) >R
  <( R@ 6 + W@ R@ 2+ W@ R> W@ " ~02N.~02N.~4N" )> ;

: today-str { \ [ 16 ] dt -- z } 
  dt today-datetime  dt format-date ;

: format-sqldate ( dt -- z ) >R
  <( R@ W@ R@ 2+ W@ R> 6 + W@ " ~4N-~02N-~02N" )> ;

: >sqldate ( zdate -- z)
  >R
  <( R@ 6 + 4 R@ 3 + 2 R> 2
     " ~S-~S-~S" )> ;

: sqldate> ( z1 -- z2)
  >R
  <( R@ 2 R@ 3 + 2 R> 6 + 4
     " ~S.~S.~S" )> ;

: selected-date { ctl \ [ 16 ] d -- z }
  d ctl -selected@ d format-date ;

: day-of-week ( dt -- n)
\ 1 - ПН 2 - ВТ ... 7 - ВС
  4 + W@ ?DUP 0= IF 7 THEN ;

: >flag ( ? -- ) IF 1 ELSE 0 THEN ;

: edit-resize { n ctl -- }
\ размер поля ввода по максимальному числу символов
  n ctl limit-edit
  " ш" ctl text-size SWAP n * SWAP 6 + ctl resize ;

: edit-readonly ( flag ctl -- ) W: em_setreadonly wsend DROP ;
: edit-only-numbers ( ctl -- ) W: es_number SWAP +style ;

\ ---------------------------------
\ Форматирование запросов

USER-CREATE <<<buf 2048 USER-ALLOT
\ >>>
: compile-zstr ( a n -- ) 
\ ." comp: " 2DUP 34 EMIT TYPE 34 EMIT CR
  POSTPONE ALITERAL
  HERE DUP >R ESC-CZMOVE R> ZLEN 1+ ALLOT 
  POSTPONE z>> ;

: expand-{} ( -- )
  BEGIN
    c: { PARSE compile-zstr
    c: } PARSE DUP 0= IF 2DROP EXIT THEN
    EVALUATE
  AGAIN
;

: (<<<) ( -- )  <<<buf init->> ;

: (>>>) 0>> <<<buf ;

: <<< ( -- z ; -> >>> ) 
  ?COMP 
  POSTPONE (<<<)
  BEGIN
    REFILL DROP BL SKIP
    CharAddr 3 S" >>>" COMPARE
  WHILE
    expand-{}
  REPEAT
  \ пропускаем все до пробела
  SkipWord
  POSTPONE (>>>)
; IMMEDIATE

: :Z ( z -- ) z>> ;
: :N ( n -- ) >R <( R> " ~N" )> z>> ;
: :F ( n -- 0/1) >flag :N ;

\ -------------------------------
: z>n ( z -- n)
  DUP C@ c: - = IF 1+ -1 ELSE 1 THEN >R
  0 SWAP BEGIN
    DUP C@ ?DUP 
  WHILE
    DUP c: . = IF DROP ELSE c: 0 - ROT 10 * + SWAP THEN
    1+
  REPEAT DROP R> *
;

: ctl>n { ctl \ [ 20 ] buf -- n }
  buf ctl -text@  buf z>n ;
: :E ( ctl -- ) { \ [ 100 ] buf -- } buf SWAP -text@ buf :Z ;
: :EN ( ctl -- ) ctl>n :N ;

: tablecol>n { x y ctl \ [ 20 ] buf -- }
  buf x y ctl -isubitem@ buf z>n ;
: :T { x y ctl \ [ 100 ] buf -- }
  buf x y ctl -isubitem@ buf :Z ; 
: :TN ( x y table -- ) tablecol>n :N ;

: ctl!n ( n ctl -- ) SWAP >R <( R> " ~N" )> SWAP -text! ;
: ctl!$ ( n ctl -- ) SWAP format-money SWAP -text! ;

: ?invalid ( ? z -- ?)  >R DUP IF R@ msg THEN RDROP ;

\ -------------------------------
\ Данные

: ?DATA ( a # data -- a # data ) 
  >R 2DUP !fatal R>
  ?DUP 0= IF " Область данных = 0" fatal-error THEN ;
: data@  ( a n data -- n ) 
  >R 2DUP !fatal R> ?DATA HASH@N 
  0= IF " data@: Нет такого ключа" fatal-error THEN ;
: data@z ( a n data -- z/0) ?DATA HASH@Z ;
: :H ( a n data -- ) data@z :Z ;

: data@zn ( a n data -- n) ?DATA HASH@Z z>n ;
: :HN ( a n data -- ) data@zn :N ;

: data! ( n a u data -- ) >R ROT R> ?DATA HASH!N ;
: data!z ( z a u data -- ) ?DATA HASH!Z ;

: data!text { ctl a u data -- }
  ctl -text# 1+ a u data ?DATA HASH!R
  ctl -text@ ;
: data!table { x y ctl a u data \ [ 256 ] buf -- }
  buf x y ctl -isubitem@ 
  buf a u data ?DATA HASH!Z ;
: data!combo { ctl a u data \ [ 100 ] buf -- }
  buf ctl -selected@ ctl fromcombo
  buf a u data data!z ;

: data@text ( a u data ctl -- )
  >R data@z R> -text! ;
: data@ntext ( a u data ctl -- )
  >R data@ >R <( R> " ~N" )> R> -text! ;

\ -------------------------------
\ Запуск

: ?next ( "name" или name<BL> -- a # / 0)
  PeekChar c: " = IF c: " ELSE BL THEN WORD
  DUP C@ 0= IF DROP 0 EXIT THEN
  COUNT OVER C@ c: " = IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть) ;

: ?comstr ( -- a n)
  -1 TO SOURCE-ID 
  GetCommandLineA ASCIIZ> SOURCE!
  ?next 2DROP  \ убрали имя файла
  ?next ?DUP 0= IF 
    " Интерпретатор диалоговых форм\nЗапуск: DB <первая-форма>\nЮ. Жиловец, 2003"
    msg BYE
  THEN
;

: DB
  ['] my-error TO ERROR
  prog-name TO mbox-title
  ?comstr
  StartSQL 0= IF " Не могу подсоединиться к ODBC" error BYE THEN TO database
  small-hash TO FORMS
  small-hash TO SUBFORMS
  WINDOWS...
  NEW-FORM 
  S" main-form" get-form-win TO winmain
  ...WINDOWS
  (:
    DROP UNLOAD-FORM
  ;) FORMS all-hash
  FORMS del-hash
  BYE
;

0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
 TRUE TO ?GUI
' DB MAINX !
\ 12345678
 S" db.exe" SAVE  
\ DB
\ . 
BYE

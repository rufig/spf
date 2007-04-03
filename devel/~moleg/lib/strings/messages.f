\ 25-08-2006 сообщения (см описание в конце) --------------------------------

        VOCABULARY msg
                        ALSO msg DEFINITIONS

        0 VALUE handle

\ все настройки в этой секции -----------------------------------------------

\ по умолчанию все сообщения на экран
:NONAME TYPE CR ;  ->VECT ~msg
\ по умолчанию ожидание реакции на предупреждение
:NONAME ."  press a key" KEY DROP ; ->VECT mwait
\ имя текущего рабочего файла
:NONAME S" .\message." ; ->VECT file

\ ---------------------------------------------------------------------------

\ временно можно использовать буфер PAD
: temp PAD 0x200 ;

\ переместить указатель доступа к файлу
: goto   ( d --> ) handle REPOSITION-FILE THROW ;
: go-up  ( --> ) 0 0 goto ;
: go-end ( --> ) handle FILE-SIZE THROW goto ;

\ работа с записями
: write ( asc # --> ) handle WRITE-LINE THROW ;
: read  ( --> asc # flag ) temp OVER SWAP handle READ-LINE THROW ;

\ всего строк в file
: count ( --> n ) go-up 0 BEGIN read WHILE 2DROP 1+ REPEAT 2DROP ;

\ вернуть сообщение из файла с номером n
\ если сообщения с таким номером нет, вернуть строку с номером ошибки
: nfind ( n --> asc # )
        go-up
        BEGIN DUP WHILE
              read WHILE
              2DROP
           1-
         REPEAT <# #S S" message = " HOLDS #> EXIT
        THEN DROP read DROP ;

\ добавить новое сообщение в конец списка,
\ вернуть порядковый номер сообщения
: new ( asc # --> n ) count -ROT write ;

\ инициализация начала работы
: init  ( --> )
        file FILE-EXIST
        IF file R/W OPEN-FILE
         ELSE file R/W CREATE-FILE
        THEN THROW TO handle ;

\ найти аналогичную запись в файле
: search ( asc # --> n true | asc # false )
         handle IF ELSE init THEN

         go-up 0 >R
         BEGIN read WHILE
               2OVER COMPARE WHILE
               R> 1+ >R
          REPEAT 2DROP R> TRUE EXIT
         THEN RDROP 2DROP FALSE ;

\ вернуть номер сообщения
: add ( asc # --> n | false ) search IF EXIT ELSE new THEN ;

\ передать сообщение об ошибке обработчику ошибок
: emsg   ER-U ! ER-A ! -2 THROW ;

\ ---------------------------------------------------------------------------

PREVIOUS DEFINITIONS

ALSO msg

: Error" [CHAR] " PARSE add
         POSTPONE LITERAL  POSTPONE nfind POSTPONE emsg
       ; IMMEDIATE

: ?Error"
         [COMPILE] IF
         [CHAR] " PARSE add
         POSTPONE LITERAL  POSTPONE nfind POSTPONE emsg
         [COMPILE] THEN
       ; IMMEDIATE


\ просто вывести сообщение
: Message" [CHAR] " PARSE add
           POSTPONE LITERAL POSTPONE nfind
           POSTPONE ~msg
           ; IMMEDIATE

\ вывести сообщение и подождать нажатия
: Warning" [CHAR] " PARSE add
           POSTPONE LITERAL  POSTPONE nfind
           POSTPONE ~msg POSTPONE mwait
           ; IMMEDIATE

PREVIOUS

\ ---------------------------------------------------------------------------

\EOF тестовая секция --------------------------------------------------------

: mes ONLY FORTH ALSO msg DEFINITIONS ;

: tst0 Message" message number one" ;
: tst1 Warning" warning number two" ;
: tst2 Error" error number three" ;
: tst3 Error" message number one"

\EOF ------------------------------------------------------------------------

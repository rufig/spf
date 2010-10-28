\ MySQL wrapper
\ (c) Dmitry Yakimov  2001; ftech@tula.net
\ This wrapper does not contain all of possible
\ functions of the dll, but it is quite enough for me.
\ I know many ways of improvement of speed and comfort of the lib,
\ but it's still quite enough for me :)
\ Enjoy!

REQUIRE {  lib\ext\locals.f

WINAPI: mysql_init          LIBMYSQL \ included in mySQL package
WINAPI: mysql_real_connect  LIBMYSQL
WINAPI: mysql_close         LIBMYSQL
WINAPI: mysql_errno         LIBMYSQL
WINAPI: mysql_error         LIBMYSQL
WINAPI: mysql_real_query    LIBMYSQL
WINAPI: mysql_select_db     LIBMYSQL
WINAPI: mysql_store_result  LIBMYSQL
WINAPI: mysql_free_result   LIBMYSQL
WINAPI: mysql_num_rows      LIBMYSQL
WINAPI: mysql_num_fields    LIBMYSQL
WINAPI: mysql_fetch_row     LIBMYSQL
WINAPI: mysql_fetch_lengths LIBMYSQL
WINAPI: mysql_stat          LIBMYSQL           

WINAPI: mysql_fetch_field_direct  LIBMYSQL    

496 CONSTANT /MYSQL
3306 VALUE MYSQL_PORT


: MyErrStr (  -- addr u )
    mysql_error ASCIIZ>
;

\ fixed by ~ygrek and ~kamikadze

: MyConnect { host hu user uu passw pu -- h ior }
\ h - connection handle
\ ior - error code
    0 mysql_init DUP 0= IF 8 ( ERROR_NOT_ENOUGH_MEMORY) EXIT THEN
    >R
    0 0
    MYSQL_PORT
    0
    passw
    user
    host
    R@
    mysql_real_connect
    DUP 0= IF R@ mysql_errno
              R> mysql_close DROP EXIT
           THEN
    RDROP 0
;

: MyClose ( h -- )
   mysql_close DROP
;

: MyStat ( h -- addr u )
    mysql_stat ASCIIZ>
;

: MySelectDB ( addr u h -- f )
   NIP mysql_select_db 0=
;

: MyQuery ( addr u h -- f )
   >R SWAP R>
   mysql_real_query 0=
;

: MyStoreRes ( h -- res )
   mysql_store_result
;

: MyFreeRes ( res -- )
   mysql_free_result DROP
;

: MyNumRows ( res -- u )
   mysql_num_rows
;

: MyNumFields ( res -- u )
   mysql_num_fields
;

: MyFetchField ( u res -- field )
   mysql_fetch_field_direct
;

: MyFetchRow ( res -- row )
   mysql_fetch_row
;

: FieldName ( field -- addr u )
   @ ASCIIZ>
;

: FieldSize ( field -- u )
   4 CELLS + @ 
;

: ColData ( u row res -- addr u )
\ get data from column of field 'u' in row 'row'
    >R OVER CELLS + @
    R> mysql_fetch_lengths
    ROT CELLS + @
;

\EOF
: test { \ myH myRes }
   S" localhost"
   S" root"
   S" go2Chopae"
   MyConnect 0=
   IF
     TO myH
     S" mysql" myH MySelectDB 0= ABORT" can't select db"
     S" SELECT * FROM user" myH MyQuery 0=  ABORT" Can't make query"
     myH MyStoreRes TO myRes
     \ print all of the fields
     ." Fields: " CR
     ." ------" CR
     myRes MyNumFields 0
     DO
        I myRes MyFetchField DUP FieldName TYPE
        SPACE FieldSize . CR
     LOOP
     CR ." Data: " CR
     ." ----- " CR

     BEGIN
       myRes MyFetchRow ?DUP
     WHILE
       myRes MyNumFields 0
       DO
          I OVER myRes ColData TYPE SPACE
       LOOP DROP CR CR
     REPEAT
     myH MyStat TYPE
     \ free handles and close DB
     myRes MyFreeRes
     myH MyClose
   ELSE
   THEN
;

STARTLOG
test
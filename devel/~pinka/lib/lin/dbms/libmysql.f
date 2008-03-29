\ Mar.2008
\ надо будет уйти от "WINAPI:"

\ something from ~day/lib/mysql.f

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
WINAPI: mysql_next_result         LIBMYSQL
WINAPI: mysql_more_results        LIBMYSQL
WINAPI: mysql_set_server_option   LIBMYSQL
WINAPI: mysql_options             LIBMYSQL

\ http://www.google.com/codesearch?hl=en&q=+MYSQL_SET_CHARSET_NAME+MYSQL_OPT_CONNECT_TIMEOUT+show:LXdgaP_KS48:OAUvlXKKbcI:NGWZpAIjpNM&sa=N&cd=1&ct=rc&cs_p=http://fjf.gnu.de/crystal/crystal.tar.bz2&cs_f=crystal-0.999/mysql.pas#l260

7 CONSTANT MYSQL_SET_CHARSET_NAME
0 CONSTANT MYSQL_OPTION_MULTI_STATEMENTS_ON
1 CONSTANT MYSQL_OPTION_MULTI_STATEMENTS_OFF

65536  CONSTANT CLIENT_MULTI_STATEMENTS \ Enable/disable multi-stmt support
131072 CONSTANT CLIENT_MULTI_RESULTS    \ Enable/disable multi-results
                                         \ This is automatically set if CLIENT_MULTI_STATEMENTS is set.

: mysql_new_conn ( -- h )
  0 mysql_init DUP IF EXIT THEN 
  8 THROW 
;

: mysql_free_res ( res -- )
  DUP 0= IF DROP EXIT THEN
  mysql_free_result 1 = IF EXIT THEN
  `#error(mysql_free_result) STHROW
;

: mysql_get_value ( u-column row res -- addr u )
  >R OVER CELLS + @
  R> mysql_fetch_lengths
  ROT CELLS + @
;

: mysql_field_name ( u-column res -- addr u )
  mysql_fetch_field_direct @ ASCIIZ>
;

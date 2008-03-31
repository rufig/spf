\ Mar.2008
\ надо будет уйти от "WINAPI:"

\ something from ~day/lib/mysql.f

WINAPI: mysql_init                libmySQL
WINAPI: mysql_real_connect        libmySQL
WINAPI: mysql_close               libmySQL
WINAPI: mysql_errno               libmySQL
WINAPI: mysql_error               libmySQL
WINAPI: mysql_real_query          libmySQL
WINAPI: mysql_select_db           libmySQL
WINAPI: mysql_store_result        libmySQL
WINAPI: mysql_free_result         libmySQL
WINAPI: mysql_num_rows            libmySQL
WINAPI: mysql_num_fields          libmySQL
WINAPI: mysql_fetch_row           libmySQL
WINAPI: mysql_fetch_lengths       libmySQL
WINAPI: mysql_stat                libmySQL           

WINAPI: mysql_fetch_field_direct  libmySQL
WINAPI: mysql_next_result         libmySQL \ 0 -- Successful and there are more results
WINAPI: mysql_more_results        libmySQL
WINAPI: mysql_set_server_option   libmySQL
WINAPI: mysql_options             libmySQL
WINAPI: mysql_real_escape_string  libmySQL
WINAPI: mysql_thread_safe         libmySQL \  1 if the client library is thread-safe,
                                            \ 0 otherwise.
WINAPI: mysql_thread_end          libmySQL \ -- void
\ -- is not invoked automatically by the client library.
\ It must be called explicitly to avoid a memory leak. 

WINAPI: mysql_thread_init         libmySQL \ Zero if successful.
\ This function must be called early within each created thread 
\ to initialize thread-specific variables.


7 CONSTANT MYSQL_SET_CHARSET_NAME
0 CONSTANT MYSQL_OPTION_MULTI_STATEMENTS_ON
1 CONSTANT MYSQL_OPTION_MULTI_STATEMENTS_OFF

20    CONSTANT MYSQL_OPT_RECONNECT \ include/mysql_h.ic
\ Note: mysql_real_connect()  incorrectly reset the MYSQL_OPT_RECONNECT option
\ to its default value before MySQL 5.1.6. 

65536  CONSTANT CLIENT_MULTI_STATEMENTS \ Enable/disable multi-stmt support
131072 CONSTANT CLIENT_MULTI_RESULTS    \ Enable/disable multi-results
                                         \ This is automatically set if CLIENT_MULTI_STATEMENTS is set.



: mysql_new_conn ( -- h )
  0 mysql_init DUP IF EXIT THEN
  \ it calls mysql_library_init() wich is not thread-safe and must be synchronized.
  \ Also mysql_thread_init() is automatically called by my_init(), 
  \ which itself is automatically called by mysql_init()

  8 THROW
;

: mysql_free_res ( res -- )
  DUP 0= IF DROP EXIT THEN
  mysql_free_result 1 = IF EXIT THEN
  ABORT" #error(mysql_free_result)"
;

: mysql_get_value ( u-column row res -- addr u )
  >R OVER CELLS + @
  R> mysql_fetch_lengths
  ROT CELLS + @
;

: mysql_field_name ( u-column res -- addr u )
  mysql_fetch_field_direct @ ASCIIZ>
;

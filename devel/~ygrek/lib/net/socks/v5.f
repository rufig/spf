\ $Id$
\
\ SOCKS5
\ Ограничения: только TCP, только CONNECT, без аутентификации
\
\ target: RFC-1928

REQUIRE ConnectHost ~ac/lib/win/winsock/psocket.f
REQUIRE { lib/ext/locals.f
REQUIRE CASE lib/ext/case.f

MODULE: SOCKS5

\ Пакет для "знакомства" с прокси сервером
CREATE step1 3 C, ( count) 5 C, ( version) 1 C, ( methods) 0 C, ( noauth)

\ второй байт
: 2nd-byte ( u -- c ) 8 RSHIFT 0xFF AND ;

\ Собрать пакет для CONNECT в буфере addr
: step2 ( a u port addr -- ) 
    HERE >R
    DP !
    OVER 7 + C, \ COUNT - not proto
     5 C, \ version
     1 C, \ CONNECT
     0 C, \ reserved
     3 C, \ domain
     >R S", \ FQDN
     R> DUP 2nd-byte C, C, \ port (reversed bytes)
    R> DP ! \ restore HERE
    ;

\ Выкинуть ior если условие f истинно
: err ( f ior -- )
   SWAP IF 
   THROW ELSE 
   \ CR ." Passed err " DUP . \ debug
   DROP THEN ;

: ProxyStep1 ( a u port -- sock )
   ConnectHost -1 err
   { sock | [ 2 ] reply }
   step1 COUNT sock WriteSocket -2 err
   reply 2 sock ReadSocket -3 err
   2 <> -4 err
   reply C@ 5 <> -5 err
   reply 1+ C@ 0 <> -6 err
   sock ;

: ProxyStep2 ( a u port sock -- )
  500 ALLOCATE THROW { sock buf } \ хватит т.к. в пакете меньше 10 ячеек + FQDN который меньше 256
  buf step2 
  buf COUNT \ 2DUP DUMP
  sock WriteSocket -7 err
  buf 4 sock ReadSocket THROW 4 <> -4 err
  buf C@ 5 <> -8 err
  buf 1 + C@ 0 <> -9 err
  buf 2 + C@ 0 <> IF CR ." Warning: rsrv used" THEN
  buf 3 + C@ 3 = IF 
  buf 1 sock ReadSocket -3 err 1 <> -4 err
  buf 1+ buf C@ 2+ sock ReadSocket -3 err buf C@ <> -4 err
  ELSE
   buf 3 + C@ 1 = IF buf 4 2 + sock ReadSocket -3 err 6 <> -4 err
  ELSE 
   buf 3 + C@ 4 = IF buf 16 2 + sock ReadSocket -3 err 18 <> -4 err
  ELSE
   -10 THROW
  THEN
  THEN
  THEN
  buf FREE THROW ;

\ Обьяснить ior возврщаемый этим модулем
: explain ( ior -- a u )
   CASE
      0 OF 0 0 ENDOF
     -1 OF S" Connection to proxy server failed." ENDOF
     -2 OF S" Step1: send hello failed" ENDOF
     -3 OF S" Didn't get reply" ENDOF
     -4 OF S" Bad reply (incorrect length)" ENDOF
     -5 OF S" Step1: bad proto version in reply" ENDOF
     -6 OF S" Step1: bad auth" ENDOF
     -7 OF S" Step2: send CONNECT failed" ENDOF
     -8 OF S" Step2: bad proto version in reply" ENDOF
     -9 OF S" Step2: CONNECT failed" ENDOF
    -10 OF S" Step2: Domain format unsupported" ENDOF
   ENDCASE ;

: ETHROW DUP IF explain CR TYPE CR -1 THROW ELSE DROP THEN ;

\ Установить TCP соединение с указанным хостом (FQDN, не IP!)
\ Если proxy-port = 0, то соединение идёт напрямую
\ Если ior = 0 то соединение установлено - сокет sock
\
: ConnectHostViaProxy ( host-au port proxy-au proxy-port -- sock ior ) 
   DUP 0= IF DROP 2DROP ConnectHost EXIT THEN
   ['] ProxyStep1 CATCH DUP IF 0 SWAP EXIT ELSE DROP THEN
   >R
   R@
   ['] ProxyStep2 CATCH DUP IF R> SWAP EXIT ELSE DROP THEN
   R>
   ( sock) 0 ;

;MODULE

\EOF

\ Попробуем добыть страничку через Tor
: test { | s }
  SocketsStartup THROW
  S" forth.org.ru" 80 S" localhost" 9050 SOCKS5::ConnectHostViaProxy SOCKS5::ETHROW SocketLine TO s
" GET / HTTP/1.0
Host: www.forth.org.ru
Connection: close

" DUP s fputs STRFREE
  10 0 DO \ первых 10 строк
  s fgets DUP STR@ CR TYPE STRFREE
  LOOP
  s fclose ;

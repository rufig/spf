\ $Id$
\
\ SOCKS5
\ Ограничения: только TCP, только CONNECT, без аутентификации
\
\ target: RFC-1928

REQUIRE ConnectHost ~ygrek/lib/net/sockets.f
REQUIRE { lib/ext/locals.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE EXCEPTION ~ygrek/lib/exception.f
REQUIRE STHROW ~pinka/spf/sthrow.f

MODULE: SOCKS5

: EXN EXCEPTION CONSTANT ;

S" Connection to proxy server failed." EXN #connect
S" Step1: send hello failed" EXN #hello
S" Didn't get reply" EXN #noreply
S" Bad reply (incorrect length)" EXN #badreply
S" Step1: bad proto version in reply" EXN #badproto
S" Step1: bad auth" EXN #badauth
S" Step2: send CONNECT failed" EXN #send
S" Step2: bad proto version in reply" EXN #badproto2
S" Step2: CONNECT failed" EXN #connect2
S" Step2: Domain format unsupported" EXN #domain
S" Step2: No response" EXN #noresponse

\ Выкинуть ior если условие f ложно
: MUST ( ? ior -- ) SWAP IF DROP ELSE THROW THEN ;

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
     ( a u port)
     >R
     255 MIN \ prevent buffer overflow
     S", \ FQDN
     R> ( port) DUP 2nd-byte C, C, \ port (reversed bytes)
    R> DP ! \ restore HERE
    ;

: ProxyStep1 ( a u port -- sock )
   ConnectHost 0= #connect MUST
   { sock | [ 2 ] reply }
   step1 COUNT sock WriteSocket 0= #hello MUST
   reply 2 sock ReadSocket 0= #noreply MUST
   2 = #badreply MUST
   reply C@ 5 = #badproto MUST
   reply 1+ C@ 0 = #badauth MUST
   sock ;

: ProxyStep2 ( a u port sock -- )
  500 ALLOCATE THROW { sock buf } \ хватит т.к. в пакете меньше 10 ячеек + FQDN который меньше 256
  buf step2
  buf COUNT \ 2DUP DUMP
  sock WriteSocket 0= #send MUST
  buf 4 sock ReadSocket 0= #noresponse MUST 4 = #badreply MUST
  buf C@ 5 = #badproto2 MUST
  buf 1 + C@ 0 = #connect2 MUST
  buf 2 + C@ 0 <> IF CR ." Warning: rsrv used" THEN
  buf 3 + C@ 3 = IF
  buf 1 sock ReadSocket 0= #noreply MUST 1 = #badreply MUST
  buf 1+ buf C@ 2+ sock ReadSocket 0= #noreply MUST buf C@ = #badreply MUST
  ELSE
   buf 3 + C@ 1 = IF buf 4 2 + sock ReadSocket 0= #noreply MUST 6 = #badreply MUST
  ELSE
   buf 3 + C@ 4 = IF buf 16 2 + sock ReadSocket 0= #noreply MUST 18 = #badreply MUST
  ELSE
   #domain THROW
  THEN
  THEN
  THEN
  buf FREE THROW ;

EXPORT

\ Установить TCP соединение с указанным хостом (FQDN, не IP!)
\ через SOCKS5 прокси "proxy-au:proxy-port"
\ Если proxy-port = 0, то соединение идёт напрямую, минуя прокси
\ Если соединение установлено - ior = 0
: ConnectHostViaSocks5 ( host-a u port proxy-a u proxy-port -- sock ior )
   DUP 0= IF DROP 2DROP ConnectHost EXIT THEN
   ['] ProxyStep1 CATCH DUP IF >R 2DROP 2DROP 2DROP 0 R> EXIT ELSE DROP THEN
   >R
   R@
   ['] ProxyStep2 CATCH DUP IF NIP NIP NIP NIP R> FastCloseSocket DROP 0 SWAP EXIT ELSE DROP THEN
   R>
   ( sock) 0 ;

;MODULE

: ETHROW ( exn -- ) ?DUP IF EXCEPTION>TEXT STHROW THEN ;

/TEST

REQUIRE fgets ~ac/lib/win/winsock/PSOCKET.F

\ Попробуем добыть страничку через Tor
: test { | s }
  SocketsStartup THROW
  S" forth.org.ru" 80 S" localhost" 9050 ConnectHostViaSocks5 ETHROW SocketLine TO s
" GET / HTTP/1.0
Host: www.forth.org.ru
Connection: close

" DUP s fputs STRFREE
  10 0 DO \ первых 10 строк
  s fgets DUP STR@ CR TYPE STRFREE
  LOOP
  s fclose ;

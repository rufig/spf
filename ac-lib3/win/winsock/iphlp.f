REQUIRE {            ~ac/lib/locals.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f

WINAPI: GetTcpTable iphlpapi.dll
WINAPI: SetTcpEntry iphlpapi.dll

 1 CONSTANT MIB_TCP_STATE_CLOSED
 2 CONSTANT MIB_TCP_STATE_LISTEN
 3 CONSTANT MIB_TCP_STATE_SYN_SENT
 4 CONSTANT MIB_TCP_STATE_SYN_RCVD
 5 CONSTANT MIB_TCP_STATE_ESTAB
 6 CONSTANT MIB_TCP_STATE_FIN_WAIT1
 7 CONSTANT MIB_TCP_STATE_FIN_WAIT2
 8 CONSTANT MIB_TCP_STATE_CLOSE_WAIT
 9 CONSTANT MIB_TCP_STATE_CLOSING
10 CONSTANT MIB_TCP_STATE_LAST_ACK
11 CONSTANT MIB_TCP_STATE_TIME_WAIT
12 CONSTANT MIB_TCP_STATE_DELETE_TCB

0 \ Iprtrmib.h
CELL -- MTCP.State
CELL -- MTCP.LocalAddr
CELL -- MTCP.LocalPort
CELL -- MTCP.RemoteAddr
CELL -- MTCP.RemotePort
CONSTANT /MIB_TCPROW

: TcpConnection. { tr }
    tr MTCP.State @ .
    tr MTCP.LocalAddr @ NtoA TYPE ." :"
    tr MTCP.LocalPort @ 256 /MOD SWAP 256 * + .
    tr MTCP.RemoteAddr @ NtoA TYPE ." :"
    tr MTCP.RemotePort @ 256 /MOD SWAP 256 * + . CR
;
: ForEachTcpConnection { xt filter \ mem size tr -- } \ throwable
  0 ^ size PAD GetTcpTable DROP
  size ALLOCATE THROW -> mem
  0 ^ size mem GetTcpTable THROW
  mem CELL+ -> tr
  mem @ 0 ?DO
    tr MTCP.State @ filter =
    filter 0= OR
    IF tr xt EXECUTE THEN
    tr /MIB_TCPROW + -> tr
  LOOP
;

: CloseWaitingConnection
  DUP MTCP.State MIB_TCP_STATE_DELETE_TCB SWAP !
  SetTcpEntry DROP
;
: CloseWaitingConnections
  ['] CloseWaitingConnection MIB_TCP_STATE_CLOSE_WAIT ForEachTcpConnection
;

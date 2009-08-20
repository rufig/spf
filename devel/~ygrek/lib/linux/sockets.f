\ $Id$
\ see ~ac/lib/win/winsock/SOCKETS.F

REQUIRE LINUX-CONSTANTS lib/posix/const.f
REQUIRE /TEST ~profit/lib/testing.f

USER-CREATE sock_addr SIZEOF_SOCKADDR_IN USER-ALLOT

: sin_port OFFSETOF_SIN_PORT + ;
: sin_addr OFFSETOF_SIN_ADDR + ;
: sin_family OFFSETOF_SIN_FAMILY + ;

USER TIMEOUT

: ConnectSocket ( IP port socket -- ior )
\  CONNECT-INTERFACE @ ?DUP 
\  IF OVER 0 ROT ROT BindSocketInterface ?DUP IF NIP NIP NIP EXIT THEN THEN
  >R
  256 /MOD SWAP 256 * + \ reverse port number byte order
  sock_addr sin_port W!
  sock_addr sin_addr !
  AF_INET sock_addr sin_family W!
  (( R> sock_addr SIZEOF_SOCKADDR_IN )) connect ?ERR NIP ;

: CreateSocket ( -- socket ior )
  (( PF_INET SOCK_STREAM IPPROTO_TCP )) socket ?ERR ;

: CloseSocket ( sock -- ior ) 1 <( )) close ?ERR NIP ;

: GetHostIP ( addr u -- IP ior )
  DUP 0= IF NIP 11004 EXIT THEN \ иначе пустой хост S" " дает 0 0
  (( OVER )) inet_addr DUP -1 <> IF NIP NIP 0 EXIT ELSE DROP THEN
  DROP 1 <( )) gethostbyname DUP IF 4 CELLS + @ @ @ 0
                         ELSE -1 THEN
;

: ConnectHost ( a u port -- sock ior )
  CreateSocket ?DUP IF NIP NIP NIP -1 SWAP EXIT THEN
  >R
    >R GetHostIP ?DUP IF NIP RDROP RDROP -2 SWAP EXIT THEN
    R> ( ip port )
  R@ ConnectSocket ?DUP IF R> CloseSocket DROP -3 SWAP EXIT THEN
  R> 0 ;

: ReadSocket ( addr u s -- rlen ior )
  -ROT 0 4 <( )) recv ?ERR
  OVER 0= IF DROP -1002 THEN
  ( если принято 0, то обрыв соединения )
;

: WriteSocket ( addr u s -- ior ) -ROT 0 4 <( )) send ?ERR NIP ;

: WriteSocketLine ( addr u s -- ior )
  DUP >R WriteSocket ?DUP IF R> DROP EXIT THEN
  EOLN R> WriteSocket ;

: BindSocket TRUE ABORT" BindSocket not implemented" ;
: ListenSocket TRUE ABORT" ListenSocket not implemented" ;
: SetSocketTimeout TRUE ABORT" SetSocketTimeout not implemented" ;
: FastCloseSocket CloseSocket ; \ FIXME

/TEST

S" forth.org.ru" 21 ConnectHost THROW VALUE s
PAD 200 s ReadSocket THROW PAD SWAP TYPE
S" QUIT" s WriteSocketLine THROW
PAD 200 s ReadSocket THROW PAD SWAP TYPE
s CloseSocket THROW


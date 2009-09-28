\ $Id$
\ FastCGI

REQUIRE fgets      ~ac/lib/win/winsock/psocket.f
REQUIRE small-hash ~pinka/lib/hash-table.f 

0
1 -- fh.version
1 -- fh.type
1 -- fh.requestIdB1
1 -- fh.requestIdB0
1 -- fh.contentLengthB1
1 -- fh.contentLengthB0
1 -- fh.paddingLength
1 -- fh.reserved
CONSTANT /FCGI_Header

0
1 -- fr.roleB1
1 -- fr.roleB0
1 -- fr.flags
5 -- fr.reserved
CONSTANT /FCGI_BeginRequestBody

0
1 -- fe.appStatusB3
1 -- fe.appStatusB2
1 -- fe.appStatusB1
1 -- fe.appStatusB0
1 -- fe.protocolStatus
3 -- fe.reserved
CONSTANT /FCGI_EndRequestBody


 1 CONSTANT FCGI_BEGIN_REQUEST      
 2 CONSTANT FCGI_ABORT_REQUEST      
 3 CONSTANT FCGI_END_REQUEST        
 4 CONSTANT FCGI_PARAMS             
 5 CONSTANT FCGI_STDIN              
 6 CONSTANT FCGI_STDOUT             
 7 CONSTANT FCGI_STDERR             
 8 CONSTANT FCGI_DATA               
 9 CONSTANT FCGI_GET_VALUES         
10 CONSTANT FCGI_GET_VALUES_RESULT  
11 CONSTANT FCGI_UNKNOWN_TYPE       

 1 CONSTANT FCGI_KEEP_CONN

USER-CREATE FCGI_Header /FCGI_Header USER-ALLOT
USER-CREATE FCGI_EndRequestBody /FCGI_EndRequestBody USER-ALLOT
USER-VALUE FCGI_ServerSocket
USER-VALUE FCGI_Socket
USER-VALUE FCGI_Body
USER-VALUE FCGI_BodyLen
USER-VALUE FCGI_Flags
USER-VALUE FCGI_Params

: FcgiReadHeader ( -- type )
  FCGI_Header /FCGI_Header
  FCGI_Socket ReadSocketExact THROW
  FCGI_Header fh.version C@ 1 <> ABORT" FCGI: version mismatch."
  FCGI_Header fh.type C@ \ DUP ." type=" .
  FCGI_Header fh.contentLengthB1 C@ 8 LSHIFT
  FCGI_Header fh.contentLengthB0 C@ OR TO FCGI_BodyLen
;
: FcgiReadBody ( -- )
  FCGI_Body ?DUP IF FREE THROW THEN
  FCGI_BodyLen DUP ALLOCATE THROW DUP TO FCGI_Body
  SWAP FCGI_Socket ReadSocketExact THROW
  PAD FCGI_Header fh.paddingLength C@ FCGI_Socket ReadSocketExact THROW
\  FCGI_Body FCGI_BodyLen DUMP CR CR
;
: FcgiWrite1 { addr u type -- } \ u < 0xFFFF
  type FCGI_Header fh.type C!
  u 8 RSHIFT FCGI_Header fh.contentLengthB1 C!
  u 0xFF AND FCGI_Header fh.contentLengthB0 C!
  0 FCGI_Header fh.paddingLength C!
  FCGI_Header /FCGI_Header
  FCGI_Socket WriteSocket THROW
  addr u
  FCGI_Socket WriteSocket THROW
;
: FcgiWrite { addr u type \ l -- }
  BEGIN
    u 0 >
  WHILE
    addr u 0xFFFF MIN DUP -> l type FcgiWrite1
    addr l + -> addr
    u l - -> u
  REPEAT
;
: FcgiEndRequest
  FCGI_EndRequestBody /FCGI_EndRequestBody FCGI_END_REQUEST FcgiWrite
  FCGI_Flags FCGI_KEEP_CONN AND 0= IF FCGI_Socket CloseSocket THROW 0 TO FCGI_Socket THEN
;
: FcgiNameValue { addr \ nu vu -- na nu va vu addr }
  addr C@ 7 RSHIFT
  IF addr C@ 7 AND 8 LSHIFT addr 1+ -> addr
     addr C@ OR 8 LSHIFT addr 1+ -> addr
     addr C@ OR 8 LSHIFT addr 1+ -> addr
     addr C@ OR addr 1+ -> addr
  ELSE addr C@ addr 1+ -> addr THEN -> nu
  addr C@ 7 RSHIFT
  IF addr C@ 7 AND 8 LSHIFT addr 1+ -> addr
     addr C@ OR 8 LSHIFT addr 1+ -> addr
     addr C@ OR 8 LSHIFT addr 1+ -> addr
     addr C@ OR addr 1+ -> addr
  ELSE addr C@ addr 1+ -> addr THEN -> vu
  addr nu
  2DUP + vu
  2DUP +
;
: FcgiType_4 { \ addr -- } \ FCGI_PARAMS
  FCGI_Body -> addr
  BEGIN
    addr FCGI_Body FCGI_BodyLen + <
  WHILE
    addr FcgiNameValue -> addr
    2OVER TYPE ." =" 2DUP TYPE CR
    2SWAP FCGI_Params HASH!
  REPEAT
;
: FcgiType_5 \ FCGI_STDIN
  " Content-Type: text/html

<b>TEST</b> SCRIPT_NAME=
" STR@ FCGI_STDOUT FcgiWrite
  S" SCRIPT_NAME" FCGI_Params HASH@ 2DUP TYPE CR FCGI_STDOUT FcgiWrite
  S" " FCGI_STDOUT FcgiWrite
\  S" " FCGI_STDERR FcgiWrite
  FcgiEndRequest
;
: FcgiServer { port -- }
  SocketsStartup THROW
  FCGI_ServerSocket 0=
  IF
    CreateSocket THROW TO FCGI_ServerSocket
  THEN
  port FCGI_ServerSocket ReusedBindSocket THROW
  FCGI_ServerSocket ListenSocket THROW
  BEGIN
  FCGI_ServerSocket AcceptSocket THROW TO FCGI_Socket

  FcgiReadHeader FCGI_BEGIN_REQUEST <> ABORT" FCGI: begin_request expected."
  FcgiReadBody
  FCGI_Body fr.roleB0 C@ 1 <> ABORT" FCGI: only responder role supported."
  FCGI_Body fr.flags C@ TO FCGI_Flags
  small-hash TO FCGI_Params

  BEGIN
    FCGI_Socket 0<>
    IF FcgiReadHeader DUP FCGI_END_REQUEST <> OVER FCGI_UNKNOWN_TYPE < AND
    ELSE 0 FALSE THEN
  WHILE
    FcgiReadBody
    S>D <# #S S" FcgiType_" HOLDS #>
    SFIND IF EXECUTE ELSE TYPE ." not implemented" THEN
  REPEAT DROP
  AGAIN
;

\ 9000 FcgiServer

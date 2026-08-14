\ ~ac/lib/net/tuya.f -- DESKTOP Tuya local-protocol client (v3.3 / v3.4 / v3.5) for spf64.
\ Same protocol as the ESP32-C3 (src/runtime/tuya.f); the shared logic lives in tuya-core.f.  Here we
\ supply the two platform layers the core needs: 64-bit portable STATE (VARIABLE/CREATE/CELLS) and a
\ TCP SOCKET adapter over the spf winsock / POSIX socket library, plus crypto via ~ac/lib/net/crypto.f
\ (OpenSSL).  Usage:  192 168 7 84 IP#  <key-addr>  TUYA34-STATUS   ( key-addr -> the 16-byte local key ).
\ KEYS ARE SECRETS -- pass by address from a gitignored config; never hardcode one here.  CRLF.
REQUIRE (CRYPTO) ~ac/lib/net/crypto.f
DECIMAL

\ ---- TCP sockets: the classic spf CreateSocket/ConnectSocket/Read/Write/CloseSocket surface -----------
[DEFINED] WINAPI64: [IF]
   [UNDEFINED] socket [IF]                 \ Win64 arg-count prototypes so the count-less WINAPI: in sockets.f binds
      3 WINAPI64: socket          WSOCK32.DLL      2 WINAPI64: listen          WSOCK32.DLL
      3 WINAPI64: accept          WSOCK32.DLL      3 WINAPI64: connect         WSOCK32.DLL
      4 WINAPI64: send            WSOCK32.DLL      4 WINAPI64: recv            WSOCK32.DLL
      1 WINAPI64: closesocket     WSOCK32.DLL      3 WINAPI64: bind            WSOCK32.DLL
      3 WINAPI64: ioctlsocket     WSOCK32.DLL      0 WINAPI64: WSAGetLastError WSOCK32.DLL
      3 WINAPI64: gethostbyaddr   WSOCK32.DLL      1 WINAPI64: gethostbyname   WSOCK32.DLL
      3 WINAPI64: getpeername     WSOCK32.DLL      2 WINAPI64: WSAStartup      WSOCK32.DLL
      0 WINAPI64: WSACleanup      WSOCK32.DLL      1 WINAPI64: inet_addr       WSOCK32.DLL
      1 WINAPI64: inet_ntoa       WSOCK32.DLL      5 WINAPI64: setsockopt      WSOCK32.DLL
      2 WINAPI64: shutdown        WSOCK32.DLL      2 WINAPI64: gethostname     WSOCK32.DLL
      5 WINAPI64: select          WSOCK32.DLL
   [THEN]
   REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f
   SocketsStartup DROP                     \ WSAStartup (idempotent, refcounted per process)
[ELSE]
   REQUIRE ReadSocket ~ac/lib/lin/net/sockets.f
[THEN]

\ ---- portable state (64-bit-safe: buffers by byte size, request block by CELLS) ------------------------
CREATE TXB 1024 ALLOT   CREATE RXB 1024 ALLOT   CREATE PTB 1024 ALLOT   CREATE JBUF 256 ALLOT
CREATE HMB 32 ALLOT     CREATE RNONCE 16 ALLOT   CREATE SKEY 16 ALLOT    CREATE XORB 16 ALLOT
CREATE CRQ 9 CELLS ALLOT
VARIABLE TSEQ   VARIABLE TSOCK   VARIABLE DKEY   VARIABLE DIP   VARIABLE CRCV   VARIABLE PADN   VARIABLE JP
VARIABLE P-PL   VARIABLE P-PLEN   VARIABLE P-CMD   VARIABLE P-KEY
VARIABLE U-FR   VARIABLE U-KEY    VARIABLE U-LEN
VARIABLE IDA    VARIABLE IDU      VARIABLE TSA     VARIABLE TSU

\ ---- dotted quad -> host-order IPv4 (same as the C3 seed's IP#) ----
: IP# ( a b c d -- ip )  >R >R >R  256 * R> + 256 * R> + 256 * R> + ;

\ ---- socket adapter the core calls: TUYA-OPEN / TSEND / TRECV / TCLOSE ----
\ ConnectSocket stores the IP int straight into sin_addr (network order), so swap host-order -> network.
: BSWAP32 ( x -- x' )  DUP 24 RSHIFT  OVER 16 RSHIFT 255 AND 8 LSHIFT OR
                       OVER 8 RSHIFT 255 AND 16 LSHIFT OR  SWAP 255 AND 24 LSHIFT OR ;
: TUYA-OPEN ( -- ok )
   CreateSocket IF DROP 0 EXIT THEN  TSOCK !
   4000 TSOCK @ SetSocketTimeout DROP                  \ 4 s recv/send timeout: a stalled device can't block us
   DIP @ BSWAP32  6668  TSOCK @  ConnectSocket
   IF TSOCK @ FastCloseSocket DROP 0 EXIT THEN  -1 ;
: TSEND ( a u -- )   TSOCK @ WriteSocket DROP ;
: TRECV ( -- rlen )  RXB 1024 TSOCK @ ReadSocket DROP ;
: TCLOSE ( -- )      TSOCK @ FastCloseSocket DROP ;

REQUIRE TUYA34-STATUS ~ac/lib/net/tuya-core.f

\EOF
\ ---- offline self-test: PACK/UNPACK round-trips + CRC, a dummy NON-secret key, no device.  Past \EOF (not run
\ on a normal load); to run it:  : \EOF ;  then INCLUDE this file (it also runs crypto.f's KAT via the REQUIRE).
DECIMAL
CREATE K16 16 ALLOT
: MK-KEY  16 0 DO I 37 * 17 + 255 AND K16 I + C! LOOP ;   \ arbitrary non-secret test key
: TCRC  ." CRC32(123456789)= " S" 123456789" CRC32  BASE @ >R HEX U. R> BASE !  ."  (want CBF43926)" CR ;
: T66 { pa pu \ pt ptlen ok -- }
   pa pu 10 K16 PACK66 DROP  K16 UNPACK66 -> ok -> ptlen -> pt
   ." v3.5 66-frame: "  ok 0= IF ." UNPACK FAIL" CR EXIT THEN
   pt ptlen pa pu COMPARE 0= IF ." round-trip OK (plen=" pu . ." )" ELSE ." MISMATCH" THEN CR ;
: T34 { pa pu \ padded rl -- }   \ request path: decrypt PACK34's own ciphertext + recompute the HMAC trailer
   pa pu 10 K16 PACK34 DROP  TXB f55.len BE@ 36 - -> padded
   K16 TXB f55.pl padded PTB ECB-DEC DROP
   padded PTB padded + 1- C@ - -> rl
   ." v3.4 55-frame ECB: "  PTB rl pa pu COMPARE 0= IF ." OK (padded=" padded . ." )" ELSE ." MISMATCH" THEN
   K16 16 TXB padded /F55HDR + HMB HMAC256 DROP
   ."   HMAC trailer: " HMB 32 TXB f55.pl padded + 32 COMPARE 0= IF ." OK" ELSE ." BAD" THEN CR ;
: T33 { \ ja pu2 -- }
   S" testdevid00000001" S" 1700000000" JSON-DPQ  PKCS7  -> pu2 -> ja
   K16 ja pu2 TXB f55.pl ECB-ENC DROP  K16 TXB f55.pl pu2 PTB ECB-DEC DROP
   ." v3.3 ECB payload: "  PTB pu2 ja pu2 COMPARE 0= IF ." round-trip OK (padded=" pu2 . ." )" ELSE ." MISMATCH" THEN CR ;
MK-KEY  CR ." === tuya.f offline round-trips (dummy key) ===" CR
TCRC  S" hello, tuya v3.x payload!" T66  S" hello, tuya v3.x payload!" T34  T33  CR

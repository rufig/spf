\ IPv4 directed-broadcast targets. One network owner, no new sockets or binds.
\ Include after LAN-PRIVATE?; IPs/masks use the UDP backend's network-byte layout.
0 CELL -- li.next CELL -- li.ip CONSTANT /lan-target
VARIABLE LAN-TARGETS VARIABLE LAN-TARGET-COUNT
: LAN-TARGETS-FREE { \ p next -- }
  LAN-TARGETS @ -> p 0 LAN-TARGETS ! 0 LAN-TARGET-COUNT !
  BEGIN p WHILE p li.next @ -> next p FREE DROP next -> p REPEAT
;
: LAN-SWAP32 { n -- n' }
  n 255 AND 24 LSHIFT n 8 RSHIFT 255 AND 16 LSHIFT OR
  n 16 RSHIFT 255 AND 8 LSHIFT OR n 24 RSHIFT 255 AND OR
;
: LAN-SUBNET-ADD { ip mask \ host target p -- }
  ip LAN-PRIVATE? 0= IF EXIT THEN
  mask LAN-SWAP32 4294967295 XOR -> host
  \ Reject noncontiguous masks, default routes, and /31-/32 (no broadcast).
  host 1 U> host 4294967295 <> AND host host 1+ AND 0= AND 0= IF EXIT THEN
  ip mask 4294967295 XOR OR -> target
  target LAN-PRIVATE? 0= IF EXIT THEN
  LAN-TARGETS @ -> p
  BEGIN p WHILE p li.ip @ target = IF EXIT THEN p li.next @ -> p REPEAT
  /lan-target ALLOCATE THROW -> p
  target p li.ip ! LAN-TARGETS @ p li.next ! p LAN-TARGETS !
  1 LAN-TARGET-COUNT +!
;
[DEFINED] WINAPI: [IF]
  [DEFINED] WINAPI64: [IF] 9 WINAPI64: WSAIoctl WS2_32.DLL
  [ELSE] WINAPI: WSAIoctl WS2_32.DLL [THEN]
  \ INTERFACE_INFO uses 24-byte sockaddr_gen even on Win64.
  0 4 -- lif.flags 24 -- lif.addr 24 -- lif.broadcast 24 -- lif.mask CONSTANT /lan-interface
  : LAN-WIN-ENTRY { p -- }
    p lif.flags L@ 15 AND 3 <> IF EXIT THEN \ UP+BROADCAST, no LOOPBACK/POINTTOPOINT
    p lif.addr W@ 2 <> IF EXIT THEN
    p lif.addr 4 + L@ p lif.mask 4 + L@ LAN-SUBNET-ADD
  ;
  : (LAN-ENUMERATE) { buf bytes -- }
    bytes /lan-interface / 0 ?DO buf I /lan-interface * + LAN-WIN-ENTRY LOOP
  ;
  : LAN-ENUMERATE { \ buf size used result err -- }
    1216 -> size
    BEGIN
      size ALLOCATE THROW -> buf 0 -> used
      0 0 ^ used size buf 0 0 1074033791 DHT-SOCK @ WSAIoctl -> result
      result 0= IF
        buf used ['] (LAN-ENUMERATE) CATCH -> err
        err IF 2DROP THEN buf FREE DROP err THROW EXIT
      THEN
      WSAGetLastError -> err buf FREE DROP
      err 10014 <> size 1048576 >= OR IF err THROW THEN
      size 2* -> size
    AGAIN
  ;
[ELSE]
  [DEFINED] DLFN: [IF] ALSO SO NEW: libSystem.B.dylib [ELSE] ALSO SO NEW: libc.so.6 [THEN]
  : (lan-getifaddrs) ( list-address -- result ) 1 getifaddrs ;
  : (lan-freeifaddrs) ( list -- ) 1 freeifaddrs DROP ;
  PREVIOUS
  \ ifa_flags is uint32 + pointer-alignment padding on 64-bit platforms.
  0 CELL -- lif.next CELL -- lif.name CELL -- lif.flags
    CELL -- lif.addr CELL -- lif.mask CONSTANT /lan-interface-prefix
  : LAN-POSIX-ENTRY { p \ a mask -- }
    p lif.flags L@ 27 AND 3 <> IF EXIT THEN \ UP+BROADCAST, no LOOPBACK/POINTOPOINT
    p lif.addr @ -> a p lif.mask @ -> mask
    a 0= mask 0= OR IF EXIT THEN
    [DEFINED] DLFN: [IF] a 1+ C@ [ELSE] a W@ [THEN] 2 <> IF EXIT THEN
    a 4 + L@ mask 4 + L@ LAN-SUBNET-ADD
  ;
  : (LAN-ENUMERATE) ( p -- )
    BEGIN DUP WHILE DUP LAN-POSIX-ENTRY lif.next @ REPEAT DROP
  ;
  : LAN-ENUMERATE { \ head err -- }
    0 -> head ^ head (lan-getifaddrs) IF (errno) THROW THEN
    head ['] (LAN-ENUMERATE) CATCH -> err
    err IF DROP THEN head (lan-freeifaddrs) err THROW
  ;
[THEN]
: LAN-REFRESH ( -- ) LAN-TARGETS-FREE LAN-ENUMERATE ;

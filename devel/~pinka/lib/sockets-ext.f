REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE ReadSocket ~ac/lib/win/winsock/SOCKETS.F
REQUIRE OPEN-FILE-SHARED-DELETE ~ac/lib/win/file/share-delete.f

: READOUT-SOCK ( a u1 h -- a u2 ior ) \ on likeness READOUT-FILE
  >R OVER SWAP R>   ( a a h1 h )
  ReadSocket        ( a u2 ior )
  DUP -1002 = IF 2DROP 0. THEN
;
: ReadoutSocket ( a u1 h -- a u2 ior ) \ on likeness ReadSocket
  READOUT-SOCK
;

\ READ-SOCK-EXACT ( a u socket -- ior )
\ ReadSocketExact ( a u socket -- ior )
\ -- в базовом ~ac/lib/win/winsock/SOCKETS.F


[UNDEFINED] TransmitFile [IF]
  WINAPI: TransmitFile mswsock.dll
[THEN]
\ see also: ~ac/lib/win/winsock/transmit.f

: WRITE-SOCKET-FILE ( h sock -- ior )         \ m.b. WRITE-SOCKET-FILE-ENTIRELY
  2>R 0 0 0 0 0 2R> TransmitFile
  IF 0 EXIT THEN WSAGetLastError
;
: WRITE-SOCKET-FILE-PART ( u h sock -- ior )  \ m.b. WRITE-SOCKET-FILE-PARTIALLY
  2>R >R 0 0 0 0 R> 2R> TransmitFile
  IF 0 EXIT THEN WSAGetLastError
  \ the file position is changed only in case it was not repositioned yet after open
;

: WRITE-SOCK-FILE ( h sock -- ior ) WRITE-SOCKET-FILE ;
\   file (data to send) should not be larger than 2,147,483,646 bytes
\ TODO:
\   Workstation and client versions of Windows [...] limiting the number of concurrent TransmitFile operations 
\   allowed on the system to a maximum of two. 

: WRITE-SOCK-FILENAME ( d-filename sock -- ior )
  >R
  R/O OPEN-FILE-SHARED-DELETE DUP IF NIP RDROP EXIT THEN ( 0 ) DROP
  R> OVER >R
  WRITE-SOCK-FILE
  R> CLOSE-FILE OVER IF DROP EXIT THEN NIP
  ( Файл, который находится в процессе отправки, лучше не менять. Если его размер уменьшиться,
    то TransmitFile так и повиснет [в ожидании данных для отправки?].
    Вариант предупреждения ситуации: открывать здесь файл в эксклюзивном режиме, вместо shared.
  )
;

\ just aliases:
: WRITE-SOCKET-FILENAME ( d-filename sock -- ior ) WRITE-SOCK-FILENAME ;

( -- discussion

  Может быть, в именах вместо '-SOCK' использовать '-SOCKET'?
  см. ~pinka/model/protocol/http/write-basic.f.xml
)

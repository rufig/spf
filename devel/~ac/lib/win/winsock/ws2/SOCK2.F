: read ( addr len socket -- )
  \ прочесть ровно len байт из сокета socket и записать в addr
  { _addr _len _sock \ _p }
  0 -> _p
  BEGIN
    _len 0 >
  WHILE
    0 _len _addr _p +  _sock
    recv DUP SOCKET_ERROR =
    IF WSAGetLastError ELSE 0 THEN THROW
    DUP 0= IF DROP -1002 THROW THEN ( если принято 0, то обрыв соединения )
    DUP _p + -> _p
    _len SWAP - -> _len
  REPEAT
\  ( ***) _addr _p dump1
;
: upTo0 ( -- )
  >IN 0!
  BEGIN
    TIB >IN @ + DUP 1 SOURCE-ID read
    >IN 1+!
    C@ 0=
  UNTIL
;
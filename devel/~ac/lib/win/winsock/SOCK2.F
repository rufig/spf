REQUIRE {            ~ac/lib/locals.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f

: read ( addr len socket -- )
  \ прочесть ровно len байт из сокета socket и записать в addr
  { _addr _len _sock \ _p }
  0 -> _p
  BEGIN
    _len 0 >
  WHILE
    _addr _p +  _len _sock
    ReadSocket THROW
    DUP 0= IF DROP -1002 THROW THEN ( если принято 0, то обрыв соединения )
    DUP _p + -> _p
    _len SWAP - -> _len
  REPEAT
;
: upTo0 ( -- )
  >IN 0!
  BEGIN
    TIB >IN @ + DUP 1 SOURCE-ID read
    >IN 1+!
    C@ 0=
  UNTIL
;
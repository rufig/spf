( 25.04.2001 [C] Andrey Cherezov mailto:spf@users.sourceforge.net )
( ForEachIP - выполнение заданного действия для каждого IP хоста,
              на котором это запускается. Компьютер, выполняющий
              роль прокси, обычно имеет минимум 3 IP:
              127.0.0.1     [всегда] - localhost
              10.1.1.1      [пример] - адрес LAN-интерфейса
              194.186.20.62 [пример] - адрес WAN-интерфейса
)

REQUIRE {            ~ac/lib/locals.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f

: ForEachIP { xt \ addr -- ior }
\ xt - процедура ( IP -- ), запускаемая для каждого IP
  255 PAD gethostname 0=
  IF \ PAD ASCIIZ> TYPE ."  - localhost name" CR
     PAD gethostbyname
     DUP IF -> addr
            \ addr @ ASCIIZ> TYPE ."  - domain name" CR
            0
            addr @
            addr CELL+ CELL+ CELL+ @ @
            DO I @ 4 +LOOP
            0x0100007F xt EXECUTE \ localhost
            BEGIN
              DUP
            WHILE
              \ HostName. CR
              xt EXECUTE
            REPEAT
         ELSE DROP WSAGetLastError THEN
  ELSE WSAGetLastError THEN
;
: IsMyIP { ip \ addr sp -- flag }
  ip 0x0100007F = IF TRUE EXIT THEN
  255 PAD gethostname 0=
  IF 
     PAD gethostbyname
     DUP IF -> addr
            SP@ -> sp
            0
            addr @
            addr CELL+ CELL+ CELL+ @ @
            DO I @ 4 +LOOP
            BEGIN
              DUP
            WHILE
              ip = IF sp SP! TRUE EXIT THEN
            REPEAT
         ELSE DROP FALSE THEN
  ELSE FALSE THEN
;
: IsMyHostname ( addr u -- flag )
  GetHostIP IF DROP FALSE EXIT THEN
  IsMyIP
;
(
SocketsStartup . CR : TEST NtoA TYPE SPACE ; ' TEST ForEachIP CR . CR
1 IsMyIP . CR
S" 127.0.0.1" GetHostIP THROW IsMyIP . CR
S" 10.1.1.1" GetHostIP THROW IsMyIP . CR
S" ac" IsMyHostname . CR
S" localhost" IsMyHostname . CR
S" somehost.com" IsMyHostname . CR
)

REQUIRE {            ~ac/lib/locals.f
REQUIRE STR@         ~ac/lib/str2.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f

: IsRblBlocked { ip hosta hostu -- flag }
  ^ ip 3 + C@ ^ ip C@ ^ ip 3 + C! ^ ip C!
  ^ ip 1+ C@ ^ ip 2+ C@ ^ ip 1+ C! ^ ip 2+ C! \ reverse
  hosta hostu ip NtoA " {s}.{s}" STR@ \ 2DUP TYPE
  GetHostIP IF DROP FALSE
            ELSE S" 127.0.0.2" GetHostIP THROW = THEN
;

: IsMapsBlockedRelay ( ip -- flag )
  S" blackholes.mail-abuse.org" IsRblBlocked
\  ^ ip 3 + C@ ^ ip C@ ^ ip 3 + C! ^ ip C!
\  ^ ip 1+ C@ ^ ip 2+ C@ ^ ip 1+ C! ^ ip 2+ C! \ reverse
\  ip NtoA " {s}.blackholes.mail-abuse.org" STR@ \ 2DUP TYPE
\  GetHostIP IF DROP FALSE
\            ELSE S" 127.0.0.2" GetHostIP THROW = THEN
;
\ relays.ordb.org
: IsOrdbBlockedRelay ( ip -- flag )
  S" relays.ordb.org" IsRblBlocked
\  ^ ip 3 + C@ ^ ip C@ ^ ip 3 + C! ^ ip C!
\  ^ ip 1+ C@ ^ ip 2+ C@ ^ ip 1+ C! ^ ip 2+ C! \ reverse
\  ip NtoA " {s}.relays.ordb.org" STR@ \ 2DUP TYPE
\  GetHostIP IF DROP FALSE
\            ELSE S" 127.0.0.2" GetHostIP THROW = THEN
;
(
: TEST
  SocketsStartup . S" 192.203.178.39" GetHostIP THROW
  IsMapsBlockedRelay .
  CR CR
  S" 80.254.168.54" GetHostIP THROW IsOrdbBlockedRelay . CR
  S" 127.0.0.2" GetHostIP THROW S" proxies.relays.monkeys.com" IsRblBlocked . CR
  S" 127.0.0.2" GetHostIP THROW S" list.dsbl.org" IsRblBlocked . CR
  S" 127.0.0.2" GetHostIP THROW S" dnsbl.njabl.org" IsRblBlocked . CR
  S" 127.0.0.2" GetHostIP THROW S" proxies.blackholes.easynet.nl" IsRblBlocked . CR
  S" 127.0.0.2" GetHostIP THROW S" sbl.spamhaus.org" IsRblBlocked . CR
  
;
TEST
)
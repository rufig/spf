REQUIRE fsockopen ~ac\lib\win\winsock\psocket.f 

\ WINAPI: PfCreateInterface Iphlpapi.dll \ вот ведь хитрецы... :)
WINAPI: _PfCreateInterface@24            Iphlpapi.dll
WINAPI: _PfAddFiltersToInterface@24      Iphlpapi.dll
WINAPI: _PfBindInterfaceToIPAddress@12   Iphlpapi.dll
WINAPI: _PfRemoveFiltersFromInterface@20 Iphlpapi.dll

0 CONSTANT PF_ACTION_FORWARD
1 CONSTANT PF_ACTION_DROP

1 CONSTANT FD_FLAGS_NOSYN

0 CONSTANT PF_IPV4
\ 1 CONSTANT PF_IPV6

   0 CONSTANT FILTER_PROTO_ANY
   1 CONSTANT FILTER_PROTO_ICMP
   6 CONSTANT FILTER_PROTO_TCP
0x11 CONSTANT FILTER_PROTO_UDP



0
CELL -- dwFilterFlags
CELL -- dwRule \ copied into the log when appropriate
CELL -- pfatType
CELL -- SrcAddr
CELL -- SrcMask
CELL -- DstAddr
CELL -- DstMask
CELL -- dwProtocol
CELL -- fLateBound
   2 -- wSrcPort
   2 -- wDstPort
   2 -- wSrcPortHighRange
   2 -- wDstPortHighRange
CONSTANT /PF_FILTER_DESCRIPTOR

: FilterCreateInterface { \ ih -- ih }
  ^ ih 0 0 PF_ACTION_FORWARD PF_ACTION_FORWARD 0 _PfCreateInterface@24 0 <> THROW
  ih
;
: FilterAllocAddr { str \ addr -- addr }
  CELL ALLOCATE THROW -> addr
  str STR@ GetHostIP THROW addr !
  addr 
;
: FilterAllocIp { ip \ addr -- addr }
  CELL ALLOCATE THROW -> addr
  ip addr !
  addr 
;
: FilterAddRule { srchost srcmask srcport targethost targetmask targetport ih \ rule -- ior }
  /PF_FILTER_DESCRIPTOR ALLOCATE THROW -> rule
  FD_FLAGS_NOSYN rule dwFilterFlags !
  PF_IPV4 rule pfatType !
  FILTER_PROTO_TCP rule dwProtocol !
  srchost FilterAllocAddr rule SrcAddr !
  srcmask FilterAllocAddr rule SrcMask !
  targethost FilterAllocAddr rule DstAddr !
  targetmask FilterAllocAddr rule DstMask !
  srcport 256 /MOD SWAP 256 * + rule wSrcPort W!
  targetport 256 /MOD SWAP 256 * + rule wDstPort W!
  0 rule 1 rule 1 ih _PfAddFiltersToInterface@24
;
: FilterAddIpRule { srcip targetip ih \ rule -- ior }
  /PF_FILTER_DESCRIPTOR ALLOCATE THROW -> rule
  FD_FLAGS_NOSYN rule dwFilterFlags !
  PF_IPV4 rule pfatType !
  FILTER_PROTO_ANY rule dwProtocol !
     srcip FilterAllocIp rule SrcAddr !
        -1 FilterAllocIp rule SrcMask !
  targetip FilterAllocIp rule DstAddr !
        -1 FilterAllocIp rule DstMask !
  0 rule wSrcPort W!
  0 rule wDstPort W!
  0 rule 1 rule 1 ih _PfAddFiltersToInterface@24
;
: FilterDelIpRule { srcip targetip ih \ rule -- ior }
  /PF_FILTER_DESCRIPTOR ALLOCATE THROW -> rule
  FD_FLAGS_NOSYN rule dwFilterFlags !
  PF_IPV4 rule pfatType !
  FILTER_PROTO_ANY rule dwProtocol !
     srcip FilterAllocIp rule SrcAddr !
        -1 FilterAllocIp rule SrcMask !
  targetip FilterAllocIp rule DstAddr !
        -1 FilterAllocIp rule DstMask !
  0 rule wSrcPort W!
  0 rule wDstPort W!
  rule 1 rule 1 ih _PfRemoveFiltersFromInterface@20
;  

VARIABLE FILTER-IH
VARIABLE FILTER-IP

: FilterCreate { str_ip -- }
  FilterCreateInterface FILTER-IH !
  str_ip FilterAllocAddr DUP @ FILTER-IP !
  PF_IPV4 FILTER-IH @ _PfBindInterfaceToIPAddress@12 0 <> THROW
;
: FilterAddInterface { str_ip -- }
  str_ip FilterAllocAddr
  PF_IPV4 FILTER-IH @ _PfBindInterfaceToIPAddress@12 0 <> THROW
;
: FilterAdd ( srchost srcmask srcport targethost targetmask targetport -- )
\ запретить пакеты с srchost srcmask srcport на targethost targetmask targetport
  FILTER-IH @ FilterAddRule 0 <> THROW
;
: FilterAddIp ( srcip targetip -- )
\ запретить пакеты с srcip на targetip
  FILTER-IH @ FilterAddIpRule 0 <> THROW
;
: FilterDelIp ( srcip targetip -- )
\ отключить ранее введенный запрет
  FILTER-IH @ FilterDelIpRule 0 <> THROW
;

: FilterDenyPacketsTo { host port -- }
\ запретить исходящие соединения к хосту:порту
  " 0.0.0.0" " 0.0.0.0" 0
  host " 255.255.255.255" port
  FilterAdd
;
: FilterDenyPacketsFrom { host port -- }
\ запретить любые соединения с указанного хоста
  host " 255.255.255.255" port
  " 0.0.0.0" " 0.0.0.0" 0
  FilterAdd
;
: FilterDenyPacketsFromIp ( ip if_ip -- )
\ запретить любые соединения с указанного ip к if_ip
  FilterAddIp
;
: FilterAllowPacketsFromIp ( ip if_ip -- )
\ разрешить соединения с указанного ip к if_ip
  FilterDelIp
;

(
: TEST2
  SocketsStartup THROW
  " ac.eserv.ru" FilterCreate
  " www.eserv.ru" " 255.255.255.255" 0
  " cherezov.ol.enet.ru" " 255.255.255.255" 25
  FilterAdd
\  " www.eserv.ru" 25 FilterDenyPacketsTo
\  " www.eserv.ru" 0 FilterDenyPacketsFrom
;
TEST2
)
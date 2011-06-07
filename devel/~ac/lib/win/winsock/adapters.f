\ ¬ XP не работает нормально (по MSDN-документации) функци€ getaddrinfo
\ (при подаче "пустого" хоста возвращает не все локальные адреса, а только IPv4)
\ поэтому приходитс€ использовать более сложный способ дл€ получени€ полного
\ списка локальных адресов, включа€ IPv6.

\ ѕример см. в foreach_ip6.f 

WINAPI: GetAdaptersAddresses iphlpapi.dll

0
4 ( ULONG) -- ua.Length
4 ( DWORD) -- ua.Flags
4 ( struct _IP_ADAPTER_UNICAST_ADDRESS *) -- ua.Next
8 ( SOCKET_ADDRESS) -- ua.Address
(
  IP_PREFIX_ORIGIN                   PrefixOrigin;
  IP_SUFFIX_ORIGIN                   SuffixOrigin;
  IP_DAD_STATE                       DadState;
  ULONG                              ValidLifetime;
  ULONG                              PreferredLifetime;
  ULONG                              LeaseLifetime;
  UINT8                              OnLinkPrefixLength;
)
CONSTANT /IP_ADAPTER_UNICAST_ADDRESS

0
0 ( ULONGLONG)                      -- aa.Alignment
4 ( ULONG)                          -- aa.Length
4 ( DWORD)                          -- aa.IfIndex
4 ( struct _IP_ADAPTER_ADDRESSES)   -- aa.Next
4 ( PCHAR)                          -- aa.AdapterName
4 ( PIP_ADAPTER_UNICAST_ADDRESS)    -- aa.FirstUnicastAddress
4 ( PIP_ADAPTER_ANYCAST_ADDRESS)    -- aa.FirstAnycastAddress
4 ( PIP_ADAPTER_MULTICAST_ADDRESS)  -- aa.FirstMulticastAddress
4 ( PIP_ADAPTER_DNS_SERVER_ADDRESS) -- aa.FirstDnsServerAddress
4 ( PWCHAR)                         -- aa.DnsSuffix
4 ( PWCHAR)                         -- aa.Description
4 ( PWCHAR)                         -- aa.FriendlyName
8 ( BYTE)                           -- aa.PhysicalAddress \ [MAX_ADAPTER_ADDRESS_LENGTH]
4 ( DWORD)                          -- aa.PhysicalAddressLength
4 ( DWORD)                          -- aa.Flags
4 ( DWORD)                          -- aa.Mtu
4 ( DWORD)                          -- aa.IfType
4 ( IF_OPER_STATUS)                 -- aa.OperStatus
4 ( DWORD)                          -- aa.Ipv6IfIndex
64 ( DWORD[16])                         -- aa.ZoneIndices \ [16]
4 ( PIP_ADAPTER_PREFIX)             -- aa.FirstPrefix
8 ( ULONG64)                        -- aa.TransmitLinkSpeed
8 ( ULONG64)                        -- aa.ReceiveLinkSpeed
4 ( PIP_ADAPTER_WINS_SERVER_ADDRESS_LH) -- aa.FirstWinsServerAddress
4 ( PIP_ADAPTER_GATEWAY_ADDRESS_LH) -- aa.FirstGatewayAddress
4 ( ULONG)                          -- aa.Ipv4Metric
4 ( ULONG)                          -- aa.Ipv6Metric
8 ( IF_LUID)                        -- aa.Luid
8 ( SOCKET_ADDRESS)                 -- aa.Dhcpv4Server
4 ( NET_IF_COMPARTMENT_ID)          -- aa.CompartmentId
16 ( NET_IF_NETWORK_GUID)           -- aa.NetworkGuid
4 ( NET_IF_CONNECTION_TYPE)         -- aa.ConnectionType
4 ( TUNNEL_TYPE)                    -- aa.TunnelType
8 ( SOCKET_ADDRESS)                 -- aa.Dhcpv6Server
130 ( BYTE)                         -- aa.Dhcpv6ClientDuid \ [MAX_DHCPV6_DUID_LENGTH]
4 ( ULONG)                          -- aa.Dhcpv6ClientDuidLength
4 ( ULONG)                          -- aa.Dhcpv6Iaid
4 ( PIP_ADAPTER_DNS_SUFFIX)         -- aa.FirstDnsSuffix
CONSTANT /IP_ADAPTER_ADDRESSES

\EOF

VARIABLE gaa_len

: TEST1
  ." st," SocketsStartup6 . CR
  15000 gaa_len !
  BEGIN
    gaa_len @ ALLOCATE THROW >R
    gaa_len R@ 0 ( 0x0010) 0 0 GetAdaptersAddresses
    IF R> FREE THROW FALSE ELSE TRUE THEN
  UNTIL
  R@
  BEGIN
    DUP
  WHILE
    DUP aa.OperStatus C@ 1 =
    IF
      DUP aa.Length @ 144 >
      IF
        DUP aa.TransmitLinkSpeed 2@ SWAP D.
        DUP aa.Dhcpv4Server @ ?DUP IF OVER aa.Dhcpv4Server CELL+ @ IPtoStr TYPE SPACE THEN
        DUP aa.ConnectionType @ .
        DUP aa.TunnelType @ .
      THEN
\      DUP aa.NetworkGuid 16 DUMP
      DUP aa.IfIndex @ >R
\      DUP aa.AdapterName @ ASCIIZ> TYPE CR
      DUP aa.FirstUnicastAddress @
        BEGIN
          DUP
        WHILE
          DUP ua.Address DUP @ SWAP CELL+ @ IPtoStr ." [ " R@ . ." ] " TYPE CR
          ua.Next @
        REPEAT DROP
      RDROP
    THEN
    aa.Next @
  REPEAT DROP
  R> FREE THROW
;


\ 09.Aug.2004 ruv  (based on test.f by ac)
\ $Id$

( Модуль обертки wpcap.dll,
  для работы требуется драйвер WinPcap [http://winpcap.polito.it/]

  Значения имен слов следует понимать в контексте WinPcap.
  Предполагается, что модуль будет подключаться
  в отдельный словарь при возможности разночтений.
)

REQUIRE {            lib\ext\locals.f

WINAPI: pcap_findalldevs_ex wpcap.dll
WINAPI: pcap_open wpcap.dll
WINAPI: pcap_next_ex wpcap.dll
WINAPI: pcap_freealldevs wpcap.dll

WINAPI: pcap_setmode wpcap.dll
WINAPI: pcap_setfilter wpcap.dll
WINAPI: pcap_compile wpcap.dll


0 CONSTANT MODE_CAPT
1 CONSTANT MODE_STAT
2 CONSTANT MODE_MON


256 CONSTANT PCAP_ERRBUF_SIZE
1   CONSTANT PCAP_OPENFLAG_PROMISCUOUS

: PCAP_SRC_IF_STRING S" rpcap://" DROP ;

\ pcap_if 
0 
CELL -- pcap_if.next \ *    next, if not NULL, a pointer to the next element in the list; NULL for the last element of the list
CELL -- pcap_if.name \ char *   name, a pointer to a string giving a name for the device to pass to pcap_open_live()
CELL -- pcap_if.description \ char *    if not NULL, a pointer to a string giving a human-readable description of the device
CELL -- pcap_if.pcap_addr \ *   addresses,  a pointer to the first element of a list of addresses for the interface
CELL -- pcap_if.flags \ u_int   PCAP_IF_ interface flags. Currently the only possible flag is PCAP_IF_LOOPBACK, that is set if the interface is a loopback interface.
CONSTANT /pcap_if

0 \ pcap_addr
CELL -- pcap_addr.next \  if not NULL, a pointer to the next element in the list; NULL for the last element of the list 
CELL -- pcap_addr.addr \  a pointer to a struct sockaddr containing an address 
CELL -- pcap_addr.netmask \  if not NULL, a pointer to a struct sockaddr that contains the netmask corresponding to the address pointed to by addr. 
CELL -- pcap_addr.broadaddr \  if not NULL, a pointer to a struct sockaddr that contains the broadcast address corre- sponding to the address pointed to by addr; may be null if the interface doesn't support broadcasts 
CELL -- pcap_addr.dstaddr \  if not NULL, a pointer to a struct sockaddr that contains the destination address corre- sponding to the address pointed to by addr; may be null if the interface isn't a point- to-point interface 
CONSTANT /pcap_addr


\ pcap_pkthdr
0
   8 -- pcap_pkthdr.timestamp \ ts
CELL -- pcap_pkthdr.caplen
CELL -- pcap_pkthdr.len
CONSTANT /pcap_pkthdr

\ timeval ts
\ 0
\ CELL -- ts.tv_sec
\ CELL -- ts.tv_usec
\ CONSTANT /timestamp

\ pcap_stat
0 
2 CELLS -- pcap_stat.2pkt \ Accepted Packets, 64-bit counter
2 CELLS -- pcap_stat.2oct \ Accepted Bytes, 64-bit counter
CONSTANT /pcap_stat

\ ---

: ENUM-IF ( xt -- ) \ xt ( if -- )
  { xt \ alldevs dev }
  PAD  ^ alldevs 0  PCAP_SRC_IF_STRING pcap_findalldevs_ex 
  >R 2DROP 2DROP R>
  -1 = IF PAD ASCIIZ> TYPE CR  14001 THROW THEN
  alldevs TO dev
  BEGIN
    dev xt EXECUTE
    dev pcap_if.next @ DUP TO dev  0=
  UNTIL
  alldevs pcap_freealldevs 2DROP
;
: (ENUM-IFN) ( xt dev -- xt )
    SWAP >R
    pcap_if.name @ ASCIIZ>
    R@ EXECUTE R>
;
: (ENUM-IFDN) ( xt dev -- xt ) \ xt ( a-desc u-desc a-n u-n )
    2>R
    R@ pcap_if.description @ ?DUP IF ASCIIZ> ELSE 0. THEN
    R> pcap_if.name @ ASCIIZ>
    R@ EXECUTE R>
;
: ENUM-IFN ( xt -- ) \ xt ( a-n u-n ) \ enum names
  ['] (ENUM-IFN) ENUM-IF   DROP
;
: ENUM-IFDN ( xt -- ) \ xt ( a-desc u-desc a-n u-n ) \ enum  descs and names
  ['] (ENUM-IFDN) ENUM-IF  DROP
;

: (ALLDEVS.) ( a-desc u-desc a-n u-n )
  TYPE ."  -- " TYPE CR
;
: ALLDEVS. ( -- )
  ['] (ALLDEVS.) ENUM-IFDN
;

VARIABLE ADHANDLE \ last capture instance

 10000 VALUE read-timeout \ ms
   128 VALUE snap-len     \ bytes

: OPEN-IF ( addr u -- h ) \ to Open InterFace  by name addr u
  0= IF 14002 THROW THEN
  >R
  PAD 0 read-timeout 0 snap-len R>
  pcap_open >R 2DROP 2DROP 2DROP R> DUP ADHANDLE !
  DUP 0= IF PAD ASCIIZ> TYPE CR 14002 THROW THEN
;
: LAST-INSTANCE ( -- h )
  ADHANDLE @
;
: (OPEN-ALL) ( n a u -- h n+1 )
  OPEN-IF SWAP 1+
;
: OPEN-ALL ( -- i*h i )
  0 ['] (OPEN-ALL) ENUM-IFN
;
: NEXT-PKT ( h -- data header true | false )
  { h \ header data }
  ^ data ^ header h  pcap_next_ex  >R DROP 2DROP R>
  \ -1 - ошибка, -2 - EOF
  DUP 0< IF -2 = IF -1002 ELSE 14003 THEN THROW THEN 
  \ 0 - таймаут, 1 - пакет принят
  1 = IF data header TRUE ELSE FALSE THEN
;
: (LOOKUP-DESC) ( a1 u1 a-d u-d a u -- a2 u2 )
  2SWAP 2>R 2OVER COMPARE IF
  RDROP RDROP             ELSE
  2DROP
  <# 2R> HOLDS 0. #>      THEN
;
: LOOKUP-DESC ( a u -- a-desc u-desc )
\ Return description in the PAD.
\ But, same as (a u), if adapter (a u) not found
  ['] (LOOKUP-DESC) ENUM-IFDN
;
: MODE-STAT ( h -- )
  MODE_STAT SWAP pcap_setmode DROP 2DROP
;
: MODE-CAPT ( h -- )
  MODE_CAPT SWAP pcap_setmode DROP 2DROP
;
: SET-FILTER ( a u h -- )
    NIP { a h \ fcode }
    \ compile the filter
    \ if (pcap_compile(fp, &fcode, "tcp", 1, netmask) <0 )
    0xFFFFFF ( mask) 1 a  ^ fcode  h
    pcap_compile 0< IF 14004 THROW THEN

    \ set the filter
    \ if (pcap_setfilter(fp, &fcode)<0)
    pcap_setfilter 0< IF 14005 THROW THEN
    DROP 2DROP 2DROP
;

: (LOOKUP-NNAME) ( n i f a u  --  n i+1 0 | a u -1 )
  ROT IF 2DROP TRUE EXIT THEN
  2>R 2DUP = IF <# 2R> HOLDS #> TRUE ELSE RDROP RDROP 1+ FALSE THEN
;
: LOOKUP-NNAME ( n -- a u ) \ ret name for adapter number n
  0 0 ['] (LOOKUP-NNAME) ENUM-IFN 0= IF 2DROP 0. THEN
;
: OPEN-NIF ( n -- h|0 ) \ open N'InterFace 
\ open by ordinal number n, as from zero
  LOOKUP-NNAME OPEN-IF
;

\ 14001 Error in pcap_findalldevs.
\ 14002 Unable to open the adapter.
\ 14003 Error reading the packets.
\ 14004 Unable to compile the packet filter. Check the syntax.
\ 14005 Error setting the filter.

REQUIRE ForEachTcpConnection ~ac/lib/win/winsock/iphlp.f

WINAPI: AllocateAndGetUdpExTableFromStack IPHLPAPI.DLL ( PMIB_UDPTABLE_EX*,BOOL,HANDLE,DWORD,DWORD);
WINAPI: AllocateAndGetTcpExTableFromStack IPHLPAPI.DLL ( PMIB_TCPTABLE_EX*,BOOL,HANDLE,DWORD,DWORD);

\ 2 0 GetProcessHeap ... по версии Kumar Gaurav Khanna 
\ 2 2 GetProcessHeap ... по версии Russinovich

(
typedef struct _MIB_TCPTABLE_EX
{
DWORD dwNumEntries;
MIB_TCPROW_EX table[ANY_SIZE];
} MIB_TCPTABLE_EX, *PMIB_TCPTABLE_EX;
typedef struct _MIB_UDPTABLE_EX
{
DWORD dwNumEntries;
MIB_UDPROW_EX table[ANY_SIZE];
} MIB_UDPTABLE_EX, *PMIB_UDPTABLE_EX;
)

0
CELL -- MTCP_EX.State
CELL -- MTCP_EX.LocalAddr
CELL -- MTCP_EX.LocalPort
CELL -- MTCP_EX.RemoteAddr
CELL -- MTCP_EX.RemotePort
CELL -- MTCP_EX.ProcessId
CONSTANT /MIB_TCPROW_EX

0
CELL -- MUDP_EX.LocalAddr
CELL -- MUDP_EX.LocalPort
CELL -- MUDP_EX.ProcessId
CONSTANT /MIB_UDPROW_EX

: TcpConnectionEx. { tr }
  tr MTCP_EX.State @ .
  tr MTCP_EX.LocalAddr @ NtoA TYPE ." :"
  tr MTCP_EX.LocalPort @ 256 /MOD SWAP 256 * + .
  tr MTCP_EX.RemoteAddr @ NtoA TYPE ." :"
  tr MTCP_EX.RemotePort @ 256 /MOD SWAP 256 * + .
  tr MTCP_EX.ProcessId @ .
  CR
;

: ForEachTcpConnectionXp { xt filter \ mem tr -- } \ throwable
  2 0 GetProcessHeap 1 ^ mem
  AllocateAndGetTcpExTableFromStack THROW
  mem CELL+ -> tr
  mem @ 0 ?DO
    tr MTCP_EX.State @ filter =
    filter 0= OR
    IF tr xt EXECUTE THEN
    tr /MIB_TCPROW_EX + -> tr
  LOOP
  0 mem GetProcessHeap HeapFree ERR THROW
;
: netstat
  ['] TcpConnectionEx. 0 ForEachTcpConnectionXp
;

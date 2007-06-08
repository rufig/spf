WINAPI: GetSystemInfo KERNEL32

MODULE: get-system-info

0
2 -- wProcessorArchitecture
2 -- wReserved
CELL -- dwPageSize
CELL -- lpMinimumApplicationAddress
CELL -- lpMaximumApplicationAddress
CELL -- dwActiveProcessorMask
CELL -- dwNumberOfProcessors
CELL -- dwProcessorType
CELL -- dwAllocationGranularity
CELL -- wProcessorLevel
CELL -- wProcessorRevision
CONSTANT /SYSTEM_INFO

CREATE SYSTEM_INFO
/SYSTEM_INFO ALLOT

EXPORT

: ProcessorArchitecture ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO wProcessorArchitecture W@ ;

: PageSize ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO dwPageSize @ ;

: ActiveProcessorMask ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO dwActiveProcessorMask @ ;

: NumberOfProcessors ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO dwNumberOfProcessors @ ;

: ProcessorType ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO dwNumberOfProcessors @ ;

: AllocationGranularity ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO dwAllocationGranularity @ ;

: ProcessorLevel ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO wProcessorLevel W@ ;

: ProcessorRevision ( -- n )
SYSTEM_INFO GetSystemInfo DROP
SYSTEM_INFO wProcessorRevision W@ ;


;MODULE
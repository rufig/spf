WINAPI:  GetModuleHandleA KERNEL32

REQUIRE { lib/ext/locals.f
 
WINAPI: GetDiskFreeSpaceA   KERNEL32.DLL
WINAPI: GetDiskFreeSpaceExA KERNEL32.DLL

\ BOOL GetDiskFreeSpace(
\  LPCTSTR lpRootPathName,    // pointer to root path
\  LPDWORD lpSectorsPerCluster,  // pointer to sectors per cluster
\  LPDWORD lpBytesPerSector,  // pointer to bytes per sector
\  LPDWORD lpNumberOfFreeClusters,
\                             // pointer to number of free clusters
\  LPDWORD lpTotalNumberOfClusters 
\                             // pointer to total number of clusters

\ BOOL GetDiskFreeSpaceEx(
\   LPCTSTR lpDirectoryName,                 // directory name
\   PULARGE_INTEGER lpFreeBytesAvailable,    // bytes available to caller
\   PULARGE_INTEGER lpTotalNumberOfBytes,    // bytes on disk
\   PULARGE_INTEGER lpTotalNumberOfFreeBytes // free bytes on disk


: FreeSpace { a u \ spc bps nfc tnc tnfb1 tnfb0 tnb1 tnb0 fba1 fba0  -- kb }
    S" GetDiskFreeSpaceExA" DROP  S" kernel32.dll" DROP GetModuleHandleA
    GetProcAddress
    IF
        AT tnfb0 AT tnb0 AT fba0
        a GetDiskFreeSpaceExA ERR THROW
        fba0 fba1
    ELSE
        AT tnc AT nfc AT bps AT spc a    
        GetDiskFreeSpaceA ERR THROW
        bps spc * nfc UM* 
    THEN
    1024 UM/MOD NIP
;

\ CREATE FRSP 0 C, CHAR : C, CHAR \ C, 0 C, 
: FREE-SPACE { c \ a -- kb }
    c 0xFF AND 0x005C3A00 OR TO a
    AT a 3 FreeSpace
;

(  
CHAR c FREE-SPACE . CR
CHAR d FREE-SPACE . CR
CHAR e FREE-SPACE . CR
)
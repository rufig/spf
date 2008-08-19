\ Find Files
REQUIRE { lib/ext/locals.f
REQUIRE ZPLACE ~nn/lib/az.f
REQUIRE ALLOCATE9x ~nn/lib/alloc95.f

0                             \ typedef struct _WIN32_FIND_DATA { // wfd
1 CELLS -- dwFileAttributes   \    DWORD    dwFileAttributes;
2 CELLS -- ftCreationTime     \    FILETIME ftCreationTime;
2 CELLS -- ftLastAccessTime   \    FILETIME ftLastAccessTime;
2 CELLS -- ftLastWriteTime    \    FILETIME ftLastWriteTime;
1 CELLS -- nFileSizeHigh      \    DWORD    nFileSizeHigh;
1 CELLS -- nFileSizeLow       \    DWORD    nFileSizeLow;
1 CELLS -- dwReserved0        \    DWORD    dwReserved0;
1 CELLS -- dwReserved1        \    DWORD    dwReserved1;
260     -- cFileName          \    TCHAR    cFileName[ MAX_PATH ];
14      -- cAlternateFileName \    TCHAR    cAlternateFileName[ 14 ];
CONSTANT /WIN32_FIND_DATA     \ } WIN32_FIND_DATA;

\ 18 CONSTANT ERROR_NO_MORE_FILES

WINAPI: FindFirstFileA   kernel32.dll
\ HANDLE FindFirstFile(LPCTSTR lpFileName, LPWIN32_FIND_DATA lpFindFileData)
\ If the function succeeds, the return value is a search handle used in
\ a subsequent call to FindNextFile or FindClose.
\ If the function fails, the return value is INVALID_HANDLE_VALUE(-1).
\ To get extended error information, call GetLastError.

WINAPI: FindNextFileA    kernel32.dll
\ BOOL FindNextFile( HANDLE hFindFile, LPWIN32_FIND_DATA lpFindFileData)
\ If the function succeeds, the return value is nonzero.
\ If the function fails, the return value is zero.
\ To get extended error information, call GetLastError.
\ If no matching files can be found, the GetLastError function returns
\ ERROR_NO_MORE_FILES.

WINAPI: FindClose       kernel32.dll
\ BOOL FindClose(HANDLE hFindFile)    // file search handle

WINAPI: GetFullPathNameA KERNEL32.DLL
\ DWORD GetFullPathName(
\  LPCTSTR lpFileName,  // pointer to name of file to find path for
\  DWORD nBufferLength, // size, in characters, of path buffer
\  LPTSTR lpBuffer,     // pointer to path buffer
\  LPTSTR *lpFilePart);   // pointer to filename in path


\ CREATE __FFB /WIN32_FIND_DATA ALLOT
USER-VALUE __FFB
USER-VALUE __FFH
: FIND-RESULT ( ~? -- Path TRUE / FALSE)
    IF
        GetLastError
        DUP ERROR_NO_MORE_FILES <> OVER ERROR_FILE_NOT_FOUND <> AND
        OVER ERROR_PATH_NOT_FOUND <> AND
        IF THROW ELSE DROP THEN
        FALSE
    ELSE __FFB cFileName TRUE THEN ;

: FIND-FIRST-FILE ( Mask -- Path TRUE / FALSE)
    /WIN32_FIND_DATA ALLOCATE9x THROW TO __FFB
    __FFB SWAP FindFirstFileA
    DUP TO __FFH INVALID_HANDLE_VALUE = FIND-RESULT
    ;

: FIND-NEXT-FILE ( -- Path TRUE / FALSE)
    __FFB __FFH  FindNextFileA
    DUP ERROR_NO_MORE_FILES = SWAP 0= OR
    FIND-RESULT ;

: FIND-CLOSE ( --)
    __FFH FindClose DROP
    __FFB FREE9x DROP
;

: GET-FULL-PATH ( where addr u -- where u1)
    DROP >R DUP >R
    0 SP@ R> 255 R> GetFullPathNameA NIP
    DUP 255 > IF DROP 0 THEN
;

FILE_ATTRIBUTE_DIRECTORY CONSTANT FILE_ATTRIBUTE_DIRECTORY
\ FILE_ATTRIBUTE_ARCHIVE   CONSTANT FILE_ATTRIBUTE_ARCHIVE
FILE_ATTRIBUTE_HIDDEN    CONSTANT FILE_ATTRIBUTE_HIDDEN
FILE_ATTRIBUTE_READONLY  CONSTANT FILE_ATTRIBUTE_READONLY
FILE_ATTRIBUTE_SYSTEM    CONSTANT FILE_ATTRIBUTE_SYSTEM

: FF-SIZE __FFB nFileSizeHigh 2@ ;
: FF-ATTRIB  __FFB dwFileAttributes @ ;
: FF-ATTRIB? FF-ATTRIB AND 0<> ;
: IS-DIR?       FILE_ATTRIBUTE_DIRECTORY    FF-ATTRIB? ;
: IS-ARCHIVE?   FILE_ATTRIBUTE_ARCHIVE      FF-ATTRIB? ;
: IS-HIDDEN?    FILE_ATTRIBUTE_HIDDEN       FF-ATTRIB? ;
: IS-READONLY?  FILE_ATTRIBUTE_READONLY     FF-ATTRIB? ;
: IS-SYSTEM?    FILE_ATTRIBUTE_SYSTEM       FF-ATTRIB? ;

: FF-CREATION-TIME  __FFB ftCreationTime 2@ SWAP ;
: FF-ACCESS-TIME    __FFB ftLastAccessTime 2@ SWAP ;
: FF-WRITE-TIME     __FFB ftLastWriteTime 2@ SWAP ;


REQUIRE FILE-ATTRIBUTES ~nn/lib/fileattr.f

: FILE-EXIST { a u \ sp res -- ? ior }
    a u S" *" SEARCH NIP NIP 0= a u S" ?" SEARCH NIP NIP 0= AND
    IF a GetFileAttributesA -1 <> DUP ERR  EXIT THEN
    SP@ TO sp
    SP@ /WIN32_FIND_DATA - SP!
    SP@ a u FILE-ATTRIBUTES TO res
    sp SP! res DUP ERR
;

: EXIST? FILE-EXIST DROP ;

0 [IF]
: EXIST? { a u \ sp res -- ? }
    a u S" *" SEARCH NIP NIP 0= a u S" ?" SEARCH NIP NIP 0= AND
    IF a GetFileAttributesA -1 <> EXIT THEN
\    __FFB TO b  __FFH TO h
    SP@ TO sp
    SP@ /WIN32_FIND_DATA - SP!
    SP@ a u FILE-ATTRIBUTES TO res
    sp SP! res
\    SP@ a FIND-FIRST-FILE FIND-CLOSE
\    DUP IF NIP THEN
\    h TO __FFH  b TO __FFB
;
[THEN]
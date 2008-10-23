REQUIRE { lib/ext/locals.f
REQUIRE WC-COMPARE ~nn/lib/wcmatch.f
REQUIRE ONLYNAME ~nn/lib/filename.f
REQUIRE WC|RE-COMPARE ~nn/lib/wcre.f
REQUIRE Win9x? ~nn/lib/winver.f
REQUIRE ON ~nn/lib/onoff.f

USER PROC-FULLPATH?
USER <ProcID>
: PROC-FULLPATH PROC-FULLPATH? ON ;

: KERN: ( .. a u -- ior)
    >IN @
    CREATE 0 ,
    >IN ! BL WORD ", 0 C,   \ "
    DOES>
      DUP @ ?DUP 0=
      IF DUP CELL+ 1+
         S" KERNEL32.DLL" DROP GetModuleHandleA
         GetProcAddress DUP ROT !
      ELSE NIP THEN
      ?DUP IF API-CALL ELSE 0 THEN
;


KERN: CreateToolhelp32Snapshot
\ HANDLE WINAPI CreateToolhelp32Snapshot(DWORD dwFlags, DWORD th32ProcessID);

2 CONSTANT TH32CS_SNAPPROCESS
8 CONSTANT TH32CS_SNAPMODULE

KERN: Process32First
\ BOOL WINAPI Process32First(HANDLE hSnapshot, LPPROCESSENTRY32 lppe);

KERN: Process32Next
\ BOOL WINAPI Process32Next(HANDLE hSnapshot, LPPROCESSENTRY32 lppe);

KERN: Module32First
KERN: Module32Next

0
1 CELLS -- pe.th32dwSize
1 CELLS -- pe.cntUsage
1 CELLS -- pe.th32ProcessID
1 CELLS -- pe.th32DefaultHeapID
1 CELLS -- pe.th32ModuleID
1 CELLS -- pe.cntThreads
1 CELLS -- pe.th32ParentProcessID
1 CELLS -- pe.pcPriClassBase
1 CELLS -- pe.th32dwFlags
MAX_PATH -- pe.szExeFile
CONSTANT /PROCESSENTRY32

255 CONSTANT MAX_MODULE_NAME32

0
1 CELLS -- me.dwSize
1 CELLS -- me.th32ModuleID
1 CELLS -- me.th32ProcessID
1 CELLS -- me.GlblcntUsage
1 CELLS -- me.ProccntUsage
1 CELLS -- me.modBaseAddr
1 CELLS -- me.modBaseSize
1 CELLS -- me.hModule
MAX_MODULE_NAME32 1+ -- me.szModule
MAX_PATH  -- me.szExePath
CONSTANT /MODULEENTRY32

: thGetProcessModule { pid me \ hSnap res -- ? }
    pid TH32CS_SNAPMODULE CreateToolhelp32Snapshot  TO hSnap
        hSnap -1 = IF FALSE EXIT THEN
    /MODULEENTRY32 me me.dwSize !

    me hSnap Module32First
    hSnap CloseHandle DROP
;


: WalkProc95 { xt \ hSnap pe me -- }
    0 TH32CS_SNAPPROCESS CreateToolhelp32Snapshot TO hSnap
        hSnap -1 = IF EXIT THEN
    /PROCESSENTRY32 ALLOCATE THROW TO pe
    /PROCESSENTRY32 pe pe.th32dwSize !
    /MODULEENTRY32 ALLOCATE THROW TO me
    /MODULEENTRY32 me me.dwSize !
    pe hSnap Process32First
    IF
        BEGIN
            Win9x?
            IF pe pe.szExeFile ASCIIZ>
               PROC-FULLPATH? @ 0= IF ONLYNAME THEN
               TRUE
            ELSE
                pe pe.th32ProcessID @ me thGetProcessModule
                IF
\                  ." -- " me me.szExePath ASCIIZ> TYPE CR
\                  ." ---- " me me.szModule ASCIIZ> TYPE CR
                   PROC-FULLPATH? @
                   IF me me.szExePath  ELSE me me.szModule THEN ASCIIZ>
                   TRUE
                ELSE
                    FALSE
                THEN
            THEN

            IF
              pe pe.th32ProcessID @
              xt EXECUTE 0=
            ELSE FALSE THEN

            pe hSnap Process32Next 0= OR
        UNTIL
    THEN
    me FREE DROP
    pe FREE DROP
    hSnap CloseHandle DROP
;

USER-CREATE ProcPattern 2 CELLS USER-ALLOT
USER ProcFound

: FindProc { a u id \ continue -- ? } \ false - terminate loop
     id 0= IF GetCurrentProcessId TO id THEN
     TRUE TO continue
     a u ProcPattern 2@ WC|RE-COMPARE
     IF id ProcFound ! FALSE TO continue
     ELSE
       <ProcID> @ ?DUP
       IF id = IF id ProcFound ! FALSE TO continue THEN THEN
     THEN
     continue

\    TRUE TO continue
\    a u ProcPattern 2@ WC|RE-COMPARE
\    IF id ProcFound ! FALSE TO continue
\    ELSE
\      <ProcID> @ ?DUP
\      IF id = IF id ProcFound ! FALSE TO continue THEN THEN
\    THEN
\    continue
;

: (PROC-EXIST?) ( a u xt -- ProcId/0)
    >R
    ProcPattern 2!
    ProcFound 0!
    ['] FindProc R> EXECUTE
    ProcFound @
;

\ : PROC-EXIST95? ( a u --  ProcId/0) ['] WalkProc95 (PROC-EXIST?) ;
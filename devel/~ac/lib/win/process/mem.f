\ Working Set - набор страниц виртуального адресного пространства процесса,
\ находящихся в физической памяти.

REQUIRE GetCurrentProcess ~ac/lib/win/process/pipes.f
WINAPI: GetProcessMemoryInfo PSAPI.DLL
\ WINAPI: QueryWorkingSet      PSAPI.DLL
WINAPI: EmptyWorkingSet      PSAPI.DLL

0                                      \ названия в Task Manager:
CELL -- pmc.cb
CELL -- pmc.PageFaultCount             \ ошибки страниц
CELL -- pmc.PeakWorkingSetSize
CELL -- pmc.WorkingSetSize             \ память
CELL -- pmc.QuotaPeakPagedPoolUsage
CELL -- pmc.QuotaPagedPoolUsage        \ выгружаемый пул ( 18Кб при старте)
CELL -- pmc.QuotaPeakNonPagedPoolUsage
CELL -- pmc.QuotaNonPagedPoolUsage     \ невыгружаемый пул (обычно меньше 1Кб)
CELL -- pmc.PagefileUsage              \ выделенная память (максимальное число в таблице)
CELL -- pmc.PeakPagefileUsage
CONSTANT /PROCESS_MEMORY_COUNTERS

/PROCESS_MEMORY_COUNTERS
CELL -- pmce.PrivateUsage
CONSTANT /PROCESS_MEMORY_COUNTERS_EX

: WorkingSetSize ( -- u )
  /PROCESS_MEMORY_COUNTERS_EX ALLOCATE THROW >R
  /PROCESS_MEMORY_COUNTERS R@ GetCurrentProcess GetProcessMemoryInfo ERR THROW
  R@ pmc.WorkingSetSize @
  R> FREE THROW
;
: PagefileUsage ( -- u )
  /PROCESS_MEMORY_COUNTERS_EX ALLOCATE THROW >R
  /PROCESS_MEMORY_COUNTERS R@ GetCurrentProcess GetProcessMemoryInfo ERR THROW
  R@ pmc.PagefileUsage @
  R> FREE THROW
;
\EOF

: MTEST
  WorkingSetSize . PagefileUsage . CR
  /PROCESS_MEMORY_COUNTERS_EX PAD GetCurrentProcess GetProcessMemoryInfo ERR THROW
\  PAD /PROCESS_MEMORY_COUNTERS_EX DUMP CR
  GetCurrentProcess EmptyWorkingSet DROP WorkingSetSize . PagefileUsage . CR CR
; MTEST

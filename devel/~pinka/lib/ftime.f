\ diffsec ( thi1 tlo1 thi2 tlo2 -- sec )
\ дает разность между моментами времени: t2-t1  в секундах.
( Если разность более ~136 лет, возможно переполнение,
  т.к. в 32 бита вмещается только число секунд в 136 годах.
  NowFTime [и FILETIME] отсчитывает интервал от 1601 года.
)

\ 15.Apr.2001  ruv
\ 16. поменял порядок значений на стеке... 
\       чтобы 2! ( thi tlo ) записывало в формате FILETIME 
\ 25.Jul.2001 Wed 12:37 
\ * diffsec берет разность по модулю.
\ + SecondsToDateTime ( sec -- sec min hr day mt year )
\ + DateTimeToSeconds ( sec min hr day mt year -- sec )

\ 20.Oct.2001 Sat 21:40
\ однако, опять поменял порядок ;)
\ + !FTime @FTime  ( tlo thi )

\ 13.Nov.2001 Tue 21:07
\ * NowFTime дает UTC (как и нативная  дата файлов )
\ + >UTC  UTC> ( tlo thi -- tlo1 thi1 )
\ + DateTimeToFTime ( sec min hr day mt year -- tlo thi )
\ + FTimeToDateTime ( tlo thi -- sec min hr day mt year )

\ 12.Mar.2002 Tue 02:50
\ * NowFTime \ использовал GetSystemTimeAsFileTime,
\              вместо GetSystemTime и SystemTimeToFileTime
\              слово стало работать в 10 раз быстрей.

REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] >CELLS   [IF]
: >CELLS ( n1 -- n2 ) \ "to-cells" \ see: http://forth.sourceforge.net/word/to-cells/
  2 RSHIFT
;                    [THEN]
[UNDEFINED] ?WINAPI: [IF]
: ?WINAPI: ( -- ) \
  >IN @
  POSTPONE [UNDEFINED]
  IF   >IN ! WINAPI: 
  ELSE DROP NextWord 2DROP 
  THEN
;                    [THEN]

\ reference:
( typedef struct _FILETIME { // ft 
    DWORD dwLowDateTime; 
    DWORD dwHighDateTime; 
} FILETIME; )
\ 64-bit value representing the number of 100-nanosecond intervals 
\ since January 1, 1601. 

( typedef struct _SYSTEMTIME {  // st 
    WORD wYear; 
    WORD wMonth; 
    WORD wDayOfWeek; 
    WORD wDay; 
    WORD wHour; 
    WORD wMinute; 
    WORD wSecond; 
    WORD wMilliseconds; 
} SYSTEMTIME;  )


?WINAPI: GetSystemTimeAsFileTime KERNEL32.DLL
( LPFILETIME:lpSystemTimeAsFileTime \ pointer to a file time structure  
   -- VOID )    \ возвращает ячейку какой-то фигни.

?WINAPI: SystemTimeToFileTime KERNEL32.DLL
(   lpFileTime   \ LPFILETIME   \ address of buffer for converted file time 
    lpSystemTime \ LPSYSTEMTIME \ address of system time to convert 
  -- BOOL )

?WINAPI: FileTimeToSystemTime  KERNEL32.DLL
(   lpSystemTime  \ pointer to structure to receive system time  
    lpFileTime    \ pointer to file time to convert 
  -- BOOL )

?WINAPI: FileTimeToLocalFileTime KERNEL32.DLL
(   LPFILETIME lpLocalFileTime  // pointer to converted file time 
    CONST FILETIME *lpFileTime, // pointer to UTC file time to convert  
  -- BOOL )   

?WINAPI: LocalFileTimeToFileTime KERNEL32.DLL
(   LPFILETIME lpFileTime   // address of converted file time
    CONST FILETIME *lpLocalFileTime,    // address of local file time to convert
  -- BOOL )

\ (
[UNDEFINED] /SYSTEMTIME [IF]
0 \ _SYSTEMTIME
2 -- wYear
2 -- wMonth
2 -- wDayOfWeek
2 -- wDay
2 -- wHour
2 -- wMinute
2 -- wSecond
2 -- wMilliseconds
CONSTANT /SYSTEMTIME     [THEN]
\ CREATE SYSTEMTIME /SYSTEMTIME ALLOT
\ )

: !FTime ( tlo thi a -- )
  SWAP 2!
;
: @FTime ( a -- tlo thi )
  2@ SWAP
;

: diffsec ( tlo1 thi1 tlo2 thi2 -- sec )
\ дает разность по модулю между моментами времени: t1-t2  в секундах.
  ( D- ) DNEGATE D+ DABS
  10000000 UM/MOD NIP  \ из десятых долей микросекунд в секунды
; \ 10 000 000

[DEFINED] ?C-JMP [IF]  \ for macroopt.f
?C-JMP
FALSE TO ?C-JMP  [THEN]

: FTimeToDateTime ( tlo thi -- sec min hr day mt year )
  SWAP SP@  ( filetime )
  /SYSTEMTIME >CELLS RALLOT DUP /SYSTEMTIME ERASE DUP >R
  SWAP
  FileTimeToSystemTime DROP
  2DROP
     R@ wSecond W@
     R@ wMinute W@
     R@ wHour   W@
     R@ wDay    W@
     R@ wMonth  W@
     R@ wYear   W@
  RDROP /SYSTEMTIME >CELLS RFREE
;
: DateTimeToFTime ( sec min hr day mt year -- tlo thi )
  /SYSTEMTIME >CELLS RALLOT DUP /SYSTEMTIME ERASE >R
     R@ wYear   W!
     R@ wMonth  W!
     R@ wDay    W!
     R@ wHour   W!
     R@ wMinute W!
     R@ wSecond W!
  0. SP@ R@ SystemTimeToFileTime DROP SWAP
  RDROP /SYSTEMTIME >CELLS RFREE
;

[DEFINED] ?C-JMP [IF]
TO ?C-JMP        [THEN]


: NowFTime ( -- tlo thi ) \ expressed in Coordinated Universal Time (UTC). 
\ дает текущий момент времени ( ~ в формате FILETIME)
  0. SP@ ( filet )
  GetSystemTimeAsFileTime DROP SWAP
;

\ UTC is Coordinated Universal Time
: >UTC ( tlo thi -- tlo1 thi1 )
  SWAP
  SP@ DUP LocalFileTimeToFileTime DROP
  SWAP
;
: UTC> ( tlo thi -- tlo1 thi1 )
  SWAP
  SP@ DUP FileTimeToLocalFileTime DROP
  SWAP
;

( может лучше было бы не привязываться к thi tlo на стеке ?
  Т.е. работа только с адресами значений типа FILETIME.
)

\ =======================================================
\ Слова для перевода интервалов времени, выраженных в секундах.

: SecondsToDateTime ( sec -- sec min hr day mt year )
  60  /MOD
  60  /MOD
  24  /MOD
  30  /MOD
  12  /MOD
;
: DateTimeToSeconds ( sec min hr day mt year -- sec )
  31104000 *    SWAP
  2592000  * +  SWAP
  86400    * +  SWAP
  3600     * +  SWAP
  60       * +  SWAP
             +
;


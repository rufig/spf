REQUIRE .R lib/include/core-ext.f

WINAPI: GetDateFormatA kernel32.dll
WINAPI: GetSystemTime kernel32.dll
WINAPI: SystemTimeToFileTime kernel32.dll
WINAPI: FileTimeToSystemTime kernel32.dll
WINAPI: lstrlenA kernel32.dll

MODULE: SYSTEMTIME
  0
  2 -- wYear
  2 -- wMonth
  2 -- wDayOfWeek
  2 -- wDay
  2 -- wHour
  2 -- wMinute
  2 -- wSecond
  2 -- wMilliseconds
  CONSTANT structsize
;MODULE

: DMY>ftime ( day month year -- ftime )
  {{ SYSTEMTIME
    structsize ALLOCATE THROW >R
    R@ wYear W!
    R@ wMonth W!
    R@ wDay W!
  }}
  0 0 SP@ R@ SystemTimeToFileTime 0= THROW SWAP
  R> FREE THROW
;

: SundayIs7
  ?DUP 0= IF
    7
  THEN
;

: ftime>DMYW ( ftime -- day month year day_of_week )
  SWAP SP@
  {{ SYSTEMTIME
    structsize ALLOCATE THROW >R
    R@ SWAP FileTimeToSystemTime 0= THROW
    2DROP
    R@ wDay       W@
    R@ wMonth     W@
    R@ wYear      W@
    R@ wDayOfWeek W@
    R> FREE THROW
  }}
  SundayIs7
;

: ftime>W ( ftime -- day_of_week )
  ftime>DMYW NIP NIP NIP
;

: DMY>W
  DMY>ftime
  ftime>W
;

CREATE MonthNameBuffer 20 ALLOT

: MonthName ( month -- addr u )
  {{ SYSTEMTIME
    structsize ALLOCATE THROW >R
    R@ wMonth W!
    2000 R@ wYear W!
    1 R@ wDay W!
  }}
  20 MonthNameBuffer S" MMMM" DROP R@ 0 0 GetDateFormatA 0= THROW
  MonthNameBuffer DUP lstrlenA
  R> FREE THROW
;

HERE
2 1 2000 DMY>ftime
1 1 2000 DMY>ftime
DNEGATE D+ , ,
: ftimeInDay LITERAL 2@ ;

CREATE Days 31 , 28 , 31 , 30 , 31 , 30 , 31 ,
            31 , 30 , 31 , 30 , 31 , 30 , 31 ,

: DaysInMonth ( month year -- n )
  OVER 2 = IF
    NIP
    29 SWAP 2 SWAP ['] DMY>ftime CATCH IF
      DROP 2DROP 28
    ELSE
      2DROP 29
    THEN
  ELSE
    DROP
    1- CELLS Days + @
  THEN
;

2001 VALUE Year

MODULE: MonthTable
  0
  CELL -- month
  CELL -- nameA
  CELL -- nameU
  CELL -- arr
  CELL -- dow1
  CONSTANT structsize

  : create ( month -- mt )
    structsize ALLOCATE THROW >R
    DUP R@ month !
    6 7 * ALLOCATE THROW R@ arr !
    DUP
        MonthName
        DUP R@ nameU !
        DUP ALLOCATE THROW DUP R@ nameA !
            SWAP MOVE
    1 SWAP Year DMY>W R@ dow1 !
    R>
  ;

  : destroy ( mt -- )
    DUP arr @ FREE THROW
    DUP nameA @ FREE THROW
        FREE THROW
  ;

  : arr[] ( n w mt -- addr )
    arr @ >R
    1- 6 * +
    R> +
  ;

  : fill ( mt -- )
    0 SWAP
    DUP dow1 @ SWAP
    DUP month @ Year DaysInMonth 1+ 1 DO
      >R 2DUP R@
      arr[] R> SWAP I SWAP C! >R
      1+
      DUP 8 = IF
        DROP
        1+
        1
      THEN
      R>
    LOOP
    DROP 2DROP
  ;

  : show ( mt -- )
    8 1 DO
      I SWAP
      6 0 DO
        2DUP
        I ROT ROT arr[] C@ 3 .R
      LOOP
      SWAP DROP
      CR
    LOOP
    DROP
  ;
;MODULE

\EOF
2002 TO Year
{{ MonthTable
2 create
DUP fill
DUP show
destroy
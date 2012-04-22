\ Перевод дат из различных форматов (примеры ниже) в unixtime.
\ Пока без учета зон.

\ %Y-%m-%d %H:%M:%S
\ %d.%m.%Y %H:%M
\ %a, %d %b %Y %H:%M:%S GMT
\ %d-%b-%Y %H:%M:%S TZ
\ и др.

\ FIXME: S" 19.01.2038" >UnixTime -> 2147461200
\        S" 20.01.2038" >UnixTime -> -1 (см. mktime)
\ http://ru.wikipedia.org/wiki/Проблема_2038_года
\ Если пенсионный возраст к тому времени сделают больше 67 лет, 
\ то я не буду исправлять :-)

: _IsDigit ( char -- flag )
  DUP [CHAR] 9 > IF DROP FALSE EXIT THEN
  [CHAR] 0 < 0=
;
: DateS>M ( addr u -- m )
  \ возвращает номер месяца (1-12) по имени
  \ или 0, если формат неправильный
  1 ROT ROT
  S" Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
  OVER + SWAP DO
    2DUP I 3 COMPARE 0= IF 2DROP UNLOOP EXIT THEN
    ROT 1+ ROT ROT
  4 +LOOP 2DROP DROP 0
;
: _>NUM 0 0 2SWAP >NUMBER 2DROP D>S ;

0
CELL -- tm_sec     \ * seconds after the minute - [0,59] */
CELL -- tm_min     \ * minutes after the hour - [0,59] */
CELL -- tm_hour    \ * hours since midnight - [0,23] */
CELL -- tm_mday    \ * day of the month - [1,31] */
CELL -- tm_mon     \ * months since January - [0,11] */
CELL -- tm_year    \ * years since 1900 */
CELL -- tm_wday    \ * days since Sunday - [0,6] */
CELL -- tm_yday    \ * days since January 1 - [0,365] */
CELL -- tm_isdst   \ * daylight savings time flag */
CONSTANT /tm

WINAPI: mktime    MSVCRT.DLL

: >tm_year ( n1 -- n2 )
  DUP 100 < IF EXIT THEN
  1900 -
;
: (Rus>UnixTime) ( -- n )
  \ %d.%m.%Y %H:%M
  /tm ALLOCATE THROW >R
  [CHAR] . PARSE _>NUM R@ tm_mday !
  [CHAR] . PARSE _>NUM 1- R@ tm_mon !
  BL PARSE _>NUM >tm_year R@ tm_year !
  [CHAR] : PARSE _>NUM R@ tm_hour !
  [CHAR] : PARSE _>NUM R@ tm_min !
  BL PARSE _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;
: (Sql>UnixTime) ( -- n )
  \ %Y-%m-%d %H:%M:%S
  /tm ALLOCATE THROW >R
  [CHAR] - PARSE _>NUM >tm_year R@ tm_year !
  [CHAR] - PARSE _>NUM 1- R@ tm_mon !
  BL PARSE _>NUM R@ tm_mday !
  [CHAR] : PARSE _>NUM R@ tm_hour !
  [CHAR] : PARSE _>NUM R@ tm_min !
  BL PARSE _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;

: (Date>UnixTime) ( -- n )
  \ Wed, 18 Aug 2010 03:15:25 +0400
  /tm ALLOCATE THROW >R
  BL PARSE 2DROP
  BL PARSE _>NUM R@ tm_mday !
  BL PARSE DateS>M 1- R@ tm_mon !
  BL PARSE _>NUM >tm_year R@ tm_year !
  [CHAR] : PARSE _>NUM R@ tm_hour !
  [CHAR] : PARSE _>NUM R@ tm_min !
  BL PARSE _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;
: (InternalDate>UnixTime) ( -- n )
  \ 16-Jun-2011 01:44:54 +0400 \ IMAP
  /tm ALLOCATE THROW >R
  [CHAR] - PARSE _>NUM R@ tm_mday !
  [CHAR] - PARSE DateS>M 1- R@ tm_mon !
  BL PARSE _>NUM >tm_year R@ tm_year !
  [CHAR] : PARSE _>NUM R@ tm_hour !
  [CHAR] : PARSE _>NUM R@ tm_min !
  BL PARSE _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;
: (VcalTime) ( -- n )
  \ 2012-04-20T06:00:00.000Z
  /tm ALLOCATE THROW >R
  [CHAR] - PARSE _>NUM >tm_year R@ tm_year !
  [CHAR] - PARSE _>NUM 1- R@ tm_mon !
  [CHAR] T PARSE _>NUM R@ tm_mday !
  [CHAR] : PARSE _>NUM R@ tm_hour !
  [CHAR] : PARSE _>NUM R@ tm_min !
  [CHAR] . PARSE _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;
: (EvtTime) ( -- n )
  \ 20120419T221123Z
  /tm ALLOCATE THROW >R
  CharAddr 4 _>NUM >tm_year R@ tm_year !
  CharAddr 4 + 2 _>NUM 1- R@ tm_mon !
  CharAddr 6 + 2 _>NUM R@ tm_mday !
  [CHAR] T PARSE 2DROP
  CharAddr 2 _>NUM R@ tm_hour !
  CharAddr 2+ 2 _>NUM R@ tm_min !
  CharAddr 4 + 2 _>NUM R@ tm_sec !
  -1 R@ tm_isdst !
  R@ mktime NIP R> FREE THROW
;
: >UnixTime ( a u -- n )
  DUP 0= IF 2DROP 0 EXIT THEN
  OVER 2+ C@ [CHAR] - = IF ['] (InternalDate>UnixTime) EVALUATE-WITH EXIT THEN
  OVER DUP 8 + C@ [CHAR] T = SWAP 15 + C@ [CHAR] Z = AND IF ['] (EvtTime) EVALUATE-WITH EXIT THEN
  OVER DUP 10 + C@ [CHAR] T = SWAP 23 + C@ [CHAR] Z = AND IF ['] (VcalTime) EVALUATE-WITH EXIT THEN
  OVER C@ _IsDigit
  IF 2DUP S" ." SEARCH NIP NIP
     IF ['] (Rus>UnixTime) ELSE ['] (Sql>UnixTime) THEN
  ELSE ['] (Date>UnixTime) THEN
  EVALUATE-WITH
;

\EOF

REQUIRE UnixTimeSql ~ac/lib/win/date/unixtime.f 
S" Wed, 18 Aug 2010 03:15:25 +0400" >UnixTime UnixTimeSql TYPE CR
S" 23.06.71 02:03" >UnixTime UnixTimeSql TYPE CR
S" 1988-06-01 12:01:02" >UnixTime UnixTimeSql TYPE CR
S" 16-Jun-2011 01:44:54 +0400" >UnixTime UnixTimeSql TYPE CR

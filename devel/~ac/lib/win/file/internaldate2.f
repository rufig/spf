\ То же, но без открытия файла, т.е. подходит и для каталогов
\ и прочих неоткрываемых объектов.

REQUIRE FILE-INTERNALDATE    ~ac/lib/win/file/internaldate.f 
REQUIRE GET-FILETIME-WRITE-S ~ac/lib/win/file/fileprop.f 
REQUIRE FILETIME>UNIXTIME    ~ac/lib/win/date/unixtime.f

: FILETIME-INTERNALDATE ( filetime -- addr u ) \ filetime в utc
  2>R <<# Zone# BL HOLD
  2R> UTC>LOCAL FILETIME>TIME&DATE >R 2>R
  SWAP ROT Time# BL HOLD
  2R> R> #N [CHAR] - HOLD
  DateM>S HOLDS [CHAR] - HOLD #N## #>
;
: FILENAME-INTERNALDATE2 ( filea fileu -- addr u )
\ месяц букв.сокр, локальное время с указанием зоны
\ 09-Oct-2008 04:37:21 +0300
\ используется в частности в IMAP
  GET-FILETIME-WRITE-S FILETIME-INTERNALDATE
;
: FILETIME-UDATE ( filetime -- addr u ) \ filetime в utc
  2>R <<# \ Zone# BL HOLD
  2R> FILETIME>TIME&DATE >R 2>R
  SWAP ROT Time# BL HOLD
  2R> R> ROT #N## [CHAR] - HOLD
  SWAP #N## [CHAR] - HOLD #N #>
;
: FILENAME-UDATE2 ( filea fileu -- addr u )
\ числовой формат в UTC/GMT-зоне (без указания)
\ 2008-10-09 01:37:21
\ используется в частности в SQL
  GET-FILETIME-WRITE-S FILETIME-UDATE
;
: FILENAME-UNIXTIME ( filea fileu -- unixtime )
  GET-FILETIME-WRITE-S FILETIME>UNIXTIME
;

\EOF

S" internaldate2.f" FILENAME-INTERNALDATE2 TYPE CR
S" internaldate2.f" FILENAME-UDATE2 TYPE CR

REQUIRE DAYS-OLD                ~ac/lib/win/file/filetime.f

6 6 * CONSTANT NS-IN-HOUR

: HOURS-OLD ( h -- days )
  >R NOW-FILETIME R> GET-FILETIME DNEGATE D+
  DUP 0< IF 2DROP 0 0 THEN
  4000000000 UM/MOD NIP
  4 NS-IN-HOUR */
;

(
REQUIRE FIND-FILES-R              ~ac/lib/win/file/findfile-r.f

\ печать "возраста" файлов в часах
: TT IF FIND-FILES-RL @ CELLS SPACES cFileName ASCIIZ> TYPE CR 2DROP
     ELSE DROP
          2DUP TYPE SPACE
          R/O OPEN-FILE-SHARED
          IF DROP 
          ELSE DUP HOURS-OLD . CLOSE-FILE THROW THEN CR
     THEN
;
: T S" ." ['] TT FIND-FILES-R ; T
)

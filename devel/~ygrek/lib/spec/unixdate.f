\ unix timestamp в дату
\ и наоборот
\
\ требуется FSL (ибо нефиг плодить дубликаты - реализовано корректно в FSL - вот и отлично)
\ используйте ~ygrek/spf/included.f чтобы подключить FSL через spf4.ini

\ URL в тему - http://vsg.cape.com/~pbaum/date/date0.htm

REQUIRE fsl-util ~diver/fsl-util.f
UNIX-LINES
REQUIRE JDAY dates.seq
DOS-LINES
REQUIRE /TEST ~profit/lib/testing.f

: unix_epoch_j ( -- j_double ) 1 1 1970 JDAY ;

: Num>Date ( n -- s m h d m1 y )
   60 /MOD \ секунды
   60 /MOD \ минуты
   24 /MOD \ часы
   S>D unix_epoch_j D+ JDATE ;

: Date>Num ( s m h d m1 y -- n )
  JDAY unix_epoch_j D- D>S 60 60 * 24 * * SWAP
  3600 * + SWAP
  60 * + + ;

/TEST

REQUIRE TESCASES ~ygrek/lib/testcase.f

TESTCASES timestamp-datetime conversions

(( unix_epoch_j -> 2440588 0 )) \ на самом деле 2440587.5
(( 1000000 Num>Date Date>Num -> 1000000 ))
(( 795792721 Num>Date -> 1 32 13 21 3 1995 ))
(( 1 32 13 21 3 1995 Date>Num -> 795792721 ))

END-TESTCASES
\ unix timestamp в дату
\ и наоборот
\
\ требуется FSL (ибо нефиг плодить дубликаты - реализовано корректно в FSL - вот и отлично)
\ используйте ~ygrek/spf/included.f чтобы подключить FSL через spf4.ini
\ http://www.taygeta.com/fsl/sciforth.html

\ URL в тему - http://vsg.cape.com/~pbaum/date/date0.htm

MODULE: FSL
 REQUIRE fsl-util ~diver/fsl-util.f
 UNIX-LINES
  REQUIRE JDAY dates.seq
 DOS-LINES
 CR
;MODULE

REQUIRE DateTime#GMT ~ac/lib/win/date/date-int.f
REQUIRE /TEST ~profit/lib/testing.f

\ Julian day начала эпохи unix 
: unix_epoch_j ( -- j_double ) 1 1 1970 FSL::JDAY ;

\ преобразовать timestamp в дату
: Num>DateTime ( n -- s m h d m1 y )
   60 /MOD \ секунды
   60 /MOD \ минуты
   24 /MOD \ часы
   S>D unix_epoch_j D+ FSL::JDATE ;

\ преобразовать дату в timestamp
: DateTime>Num ( s m h d m1 y -- n )
  FSL::JDAY unix_epoch_j D- D>S 60 60 * 24 * * SWAP
  3600 * + SWAP
  60 * + + ;

\ извлечь только время из timestamp
: Num>Time ( n -- s m h ) 60 /MOD 60 /MOD 24 /MOD DROP ;

\ дату в число дней
: DateTime>Days ( s m h d m1 y -- days ) FSL::JDAY D>S NIP NIP NIP ;

\ Представить дату как строку в буфере PAD
: DateTime>PAD ( s m h d m1 y -- a u ) <# DateTime#GMT 0 0 #> ;

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES timestamp-datetime conversions

(( unix_epoch_j -> 2440588 0 )) \ на самом деле 2440587.5
(( 1000000 Num>DateTime DateTime>Num -> 1000000 ))
(( 795792721 Num>DateTime -> 1 32 13 21 3 1995 ))
(( 1 32 13 21 3 1995 DateTime>Num -> 795792721 ))

END-TESTCASES
REQUIRE >Дата         ~ac/lib/win/date/date.f
REQUIRE #N            ~ac/lib/win/date/date-int.f

1 1 1970 >Дата CONSTANT d01011970

86400 CONSTANT SecsPerDay

: SecsSince1970 ( -- n )
  ТекущаяДата d01011970 - SecsPerDay *
;
: UnixDate ( -- n )
  TIME&DATE 2DROP DROP
  3600 * SWAP 60 * + +
  SecsSince1970 +
  TZ @ 0 = IF GET-TIME-ZONE THEN
  TZ @ 60 * +
;
: UnixDate#
  UnixDate #N
;
: UnixDate.#
  S" .000" HOLDS UnixDate#
;
: UNIXDATE
  0 0 <# UnixDate.# #>
;


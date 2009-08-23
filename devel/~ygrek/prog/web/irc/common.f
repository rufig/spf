
REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE #N## ~ac/lib/win/date/date-int.f
REQUIRE AsQChar ~pinka/spf/quoted-word.f
REQUIRE NOT ~profit/lib/logic.f

: RAW-LOG-FILE { d m y -- }
  <# S" .log" HOLDS d #N## m #N## y S>D #S 2DROP `logs/raw/ HOLDS 0 0 #> ;

: HTML-LOG-FILE { d m y -- }
  <# S" .html" HOLDS d #N## '/' HOLD m #N## '/' HOLD y S>D #S 2DROP `logs/html/ HOLDS 0 0 #> ;

: Num>Date ( num -- d m y ) Num>DateTime 2>R NIP NIP NIP 2R> ;


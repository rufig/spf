REQUIRE DateM>S ~ac/lib/win/date/date-int.f

: MyDate# { d m y -- } y #N DROP [CHAR] . HOLD m DateM>S HOLDS DROP [CHAR] . HOLD d #N## DROP ;
: DateRaw# { d m y -- } d #N## DROP m #N## DROP y #N DROP ;
: MY_DATE ( -- a u ) <# TIME&DATE MyDate# 0 0 #> ;
: DATE_RAW ( -- a u ) <# TIME&DATE DateRaw# 0 0 #> ;
: NUM_RAW ( n -- ) S>D (D.) ;


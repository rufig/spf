
\ ├хэхЁрЄюЁ RSS яю tab delimited юЄў╕Єє ё trac
\ ╤юЁЄшЁєхЄ чряшёш яю єс√трэш■ changetime
\
\ ╥ЁхсєхЄ libcurl.dll - http://curl.haxx.se/latest.cgi?curl=win32-ssl

REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE tag ~ygrek/prog/web/trac/xml.f
REQUIRE Num>Date ~ygrek/lib/spec/unixdate.f
REQUIRE STR{ ~ygrek/lib/strtype.f
REQUIRE UTF8>UNICODE ~ac/lib/win/com/com.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
REQUIRE New-Queue ~pinka/lib/queue_pr.f

: report-url S" http://www.activekitten.com/trac/spf/report/1" ;
: tab-param S" ?format=tab&USER=anonymous" ;

:NONAME 0 VALUE ; ENUM values:

0 VALUE queue

REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f

: chars=> ( a u -- )
   PRO
   BOUNDS ?DO I C@ CONT LOOP ;

: htmlchar-emit
    DUP [CHAR] < = IF DROP S" &lt;" TYPE EXIT THEN 
    DUP [CHAR] > = IF DROP S" &gt;" TYPE EXIT THEN
    DUP [CHAR] & = IF DROP S" &amp;" TYPE EXIT THEN
    DUP [CHAR] " = IF DROP S" &quot;" TYPE EXIT THEN
    EMIT ;

: TYPEHTML
   chars=> htmlchar-emit ;

: STYPEHTML STR@ TYPEHTML ;

values: 
color
ticket 
summary 
component 
version 
milestone
type
owner
created
changetime
description
reporter
;

: ParseTab  9 PARSE UTF8>UNICODE UNICODE> ;

: ParseLine
   ParseTab " {s}" TO color
   ParseTab " {s}" TO ticket
   ParseTab " {s}" TO summary
   ParseTab " {s}" TO component
   ParseTab " {s}" TO version
   ParseTab " {s}" TO milestone
   ParseTab " {s}" TO type
   ParseTab " {s}" TO owner
   ParseTab " {s}" TO created
   ParseTab " {s}" TO changetime
   ParseTab " {s}" TO description
   ParseTab " {s}" TO reporter
;

: au->n ( a u -- n )
     0 0 2SWAP >NUMBER  
     0= IF DROP D>S ELSE 2DROP DROP ABORT" Not a number" THEN ;

: sdate >R <# 0 0 R> STR@ au->n Num>Date DateTime#GMT #> ;

: BuildItem
  S" item" tag 
   *> 
    S" title" tag " #{ticket STR@} {summary STR@}" STYPEHTML 
   <*>
    S" pubDate" tag  changetime sdate TYPE 
   <*>
    S" description" tag 
    " <b>Created:</b> {created sdate}"
    " <br><b>Changed:</b> {changetime sdate}" OVER S+
    " <br><br>{description STR@}" OVER S+
    STYPEHTML
   <*>
    S" dc:creator" tag reporter STYPEHTML
   <*>
    S" link" tag ticket STR@ au->n " http://www.activekitten.com/trac/spf/ticket/{n}" STYPE
   <* ;

: EachLine
   ParseLine BuildItem ;

\ STARTLOG

CREATE buf 1026 ALLOT

: MY-READ-LINE ( c-addr u1 fileid -- u2 f2 flag ior ) \ 94 FILE
  DUP >R
  FILE-POSITION IF 2DROP 0 0 THEN _fp1 ! _fp2 !
  LTL @ +
  OVER _addr !

  R@ READ-FILE ?DUP IF NIP RDROP >R 0 0 0 R> EXIT THEN

  DUP >R 0= IF RDROP RDROP 0 0 0 0 EXIT THEN \ были в конце файла

  _addr @ R@ LT LTL @ SEARCH
  IF   \ найден разделитель строк
     DROP _addr @ -
     DUP
     LTL @ + S>D _fp2 @ _fp1 @ D+ RDROP R> REPOSITION-FILE DROP
     TRUE
  ELSE \ не найден разделитель строк
     2DROP
     R> RDROP  \ если строка прочитана не полностью - будет разрезана
     FALSE
  THEN
  TRUE 0
;

0 VALUE str
: get-line { h | -- s | 0 }
   "" TO str
   BEGIN
    buf 1024 h MY-READ-LINE THROW 0= IF 2DROP str STRFREE 0 EXIT THEN
    IF buf SWAP str STR+ str EXIT
    ELSE buf SWAP str STR+ THEN
   AGAIN
;

: FileLines=> ( a u -- )
  R/O OPEN-FILE THROW
  PRO
  START{
  BEGIN
   DUP get-line DUP
  WHILE
   CONT
   STRFREE
  REPEAT
  DROP
  }EMERGE
  CLOSE-FILE THROW ;

: string-parts ( a u a1 u1 -- a u-u1 a1 u1 ) 2>R R@ - 2R> ; 

: TextLines=> ( a u -- )
   PRO
    BEGIN
     DUP 0= IF 2DROP EXIT THEN
     2DUP 
     LT LTL @ SEARCH 
     IF string-parts 2 /STRING 2SWAP CONT 2DROP ELSE 2DROP CONT 2DROP EXIT THEN
    AGAIN
;               

TRUE VALUE ?first
0 VALUE u 
0 VALUE a

: //notfirst PRO ?first IF FALSE TO ?first ELSE CONT THEN ;

\ : 10- PRO 10 0 DO I CONT DROP LOOP ;
\ : a 10- //notfirst DUP . ;
\ EOF

: BuildBody
   BEGIN
    queue LeaveLow
   WHILE
    STR@ ['] EachLine EVALUATE-WITH 
   REPEAT
;

: rss-body ( a u -- )
  S" channel" tag
  *>
  S" title" tag S" SP-FORTH: {1} Active Tickets" TYPE
  <*>
  S" link" tag report-url TYPE
  <*>
  S" description" tag S" Trac Report - {1} Active Tickets" TYPE
  <*>
  S" language" tag S" ru" TYPE
  <*>
  S" generator" tag S" Trac v0.9.4 via SPF ~ygrek/prog/web/trac/rss.f" TYPE
  <*>
  S" pubDate" tag <# 0 0 TIME&DATE DateTime# #> TYPE
  <*>
  BuildBody
  <* 
;

: (RSS)
  " <?xml version={''}1.0{''} encoding={''}windows-1251{''}?>" STYPE 
  CR
  " <rss version={''}2.0{''} xmlns:dc={''}http://purl.org/dc/elements/1.1/{''}>" STYPE
  rss-body
  S" </rss>" TYPE ;


: Prepare 
    TRUE TO ?first
    New-Queue TO queue
    a u TextLines=> //notfirst 2DUP 2DUP ['] ParseLine EVALUATE-WITH " {s}" changetime STR@ au->n NEGATE queue Enterly ;

: RSS
   TO u TO a
   Prepare
   "" STR{ 
   ['] (RSS) CATCH DROP 
   }STR 
   ;

: to-file ( a u outfile u2 -- )
   R/W CREATE-FILE THROW >R
   R@ WRITE-FILE THROW
   R> CLOSE-FILE THROW ;

\ ╤Є эєЄ№ Їрщы ё ёхЄш
: get-www ( -- a u )
 " {report-url}{tab-param}" STR@ GET-FILE
 STR@ 2DUP S" 1.dat" to-file ;

\ ╚ыш шёяюы№чютрЄ№ ыюъры№э√щ Їрщы
: get-loc ( -- a u ) S" 1.dat" FILE ;

: do get-www RSS STR@ S" 1.xml" to-file ." Done" ;

do BYE



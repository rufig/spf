
\ Генератор RSS по tab delimited отчёту с trac
\ Сортирует записи по убыванию changetime
\
\ Требует libcurl.dll - http://curl.haxx.se/latest.cgi?curl=win32-ssl

REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE Num>DateTime ~ygrek/lib/spec/unixdate.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
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

: sdate STR@ au->n Num>DateTime DateTime>PAD ;

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
    " <guid isPermaLink={''}false{''}>{ticket STR@}-{changetime STR@}</guid>" CR STYPE
   <*>
    S" link" tag ticket STR@ au->n " http://www.activekitten.com/trac/spf/ticket/{n}" STYPE
   <* ;

: EachLine
   ParseLine BuildItem ;

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
   ['] (RSS) TYPE>STR ;

: to-file ( a u outfile u2 -- )
   R/W CREATE-FILE THROW >R
   R@ WRITE-FILE THROW
   R> CLOSE-FILE THROW ;

\ Стянуть файл с сети
: get-www ( -- a u )
 " {report-url}{tab-param}" STR@ GET-FILE
 STR@ 2DUP S" 1.dat" to-file ;

\ Или использовать локальный файл
: get-loc ( -- a u ) S" 1.dat" FILE ;

: do get-www RSS STR@ S" 1.xml" to-file ." Done" ;

do BYE

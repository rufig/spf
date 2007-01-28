REQUIRE rss.items-new=> ~ygrek/prog/web/irc/rss.f

REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f

\ remove double-slashes - bug in fforum
: normalize-link ( s -- s )
   DUP " //" " /" replace-str-
   DUP " http:/" " http://" replace-str- ;

\ for manual debugging
\ : S-SAY CR TYPE ; : ECHO S-SAY ; : ON-CONNECT ... ;

\ sorry fr ugly code
: my-date ( stamp -- a u )
    DUP Num>DateTime DateTime>Days TIME&DATE DateTime>Days -
    DUP 
    0 = 
    IF 
     DROP
     Num>Time ROT DROP SWAP ( hh mm)
     <# S"  GMT" HOLDS S>D # # 2DROP [CHAR] : HOLD S>D # # 2DROP S" Сегодня " HOLDS 0 0 #>
     EXIT
    THEN

    -1 = 
    IF 
    Num>Time ROT DROP SWAP ( hh mm)
     <# S"  GMT" HOLDS S>D # # 2DROP [CHAR] : HOLD S>D # # 2DROP S" Вчера " HOLDS 0 0 #>
    ELSE
     timestamp>pad
    THEN ;

: reply-got-item ( node -- )
   >R
   S" title" R@ nodeText
   S" creator" R@ nodeText
   R@ rss.item-timestamp@ my-date
   " [{s}] {s} -- {s}" DUP STR@ S-SAY STRFREE
   S" link" R> nodeText " {s}" DUP STR@ S-SAY STRFREE ;

0 VALUE ?forum-reloaded

: timestamp-file S" .timestamp" ;

: check-forum
    S" Checking forum..." ECHO
    S" fforum.xml" 
    timestamp-file read-number 
    START{
      rss.items-new=> DUP reply-got-item
    }EMERGE
    S" fforum.xml" rss.items-newest timestamp-file write-number
    S" Forum checked" ECHO ;

: seconds 1000 * ;
: minutes 60 * seconds ;

:NONAME
 DROP
 BEGIN
   S" rss get" ECHO
   rss-gets 
   DUP STR@ S" fforum.xml" ['] TO-FILE CATCH DROP
        STRFREE
   TRUE TO ?forum-reloaded
   S" rss-getter done" ECHO
   5 minutes PAUSE
 AGAIN
 ; TASK: rss-getter

:NONAME
  DROP
  BEGIN
   100 PAUSE
   ?forum-reloaded IF
    FALSE TO ?forum-reloaded
    ['] check-forum CATCH ?DUP IF . S" forum check error" ECHO THEN
   THEN
  AGAIN
; TASK: rss-checker

..: ON-CONNECT 
 0 rss-getter START DROP 
 0 rss-checker START DROP ;..

S" -- RSS plugin loaded." ECHO

REQUIRE XML_DOC_ROOT ~ac/lib/lin/xml/xml.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE NUMBER ~ygrek/lib/parse.f
REQUIRE parse-date ~ygrek/lib/spec/sdate.f
REQUIRE STATIC ~profit/lib/static.f
REQUIRE load-file ~profit/lib/bac4th-str.f

' ANSI>OEM TO ANSI><OEM

: TO-FILE ( data-au file-au -- )
     R/W CREATE-FILE THROW >R
     R@ WRITE-FILE THROW
     R> CLOSE-FILE THROW ;

: children=> ( node -- node )
   PRO
    x.children @
    BEGIN
     DUP
    WHILE
     DUP x.type @ XML_ELEMENT_NODE = IF CONT THEN
     x.next @
    REPEAT DROP ;

: //S= ( a u a1 u1 -- )
   PRO COMPARE 0= IF CONT THEN ;

: name@ x.name @ ASCIIZ> ;

: //name= ( node a u -- node )
    PRO
     2>R DUP name@ 2R>
     //S= CONT ;

ALSO libxml2.dll

: XML_FREE_DOC 1 xmlFreeDoc DROP ;

PREVIOUS

: rss.items=> ( a u -- )
   PRO 
   load-file 2DUP XML_READ_DOC_MEM 
   DUP XML_DOC_ROOT 
   S" channel" ROT node@ 
   START{ children=> S" item" //name= CONT }EMERGE
   XML_FREE_DOC ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: read-number ( a u -- stamp )
   R/O OPEN-FILE IF DROP 0 EXIT THEN
   >R
   PAD 100 R@ READ-FILE DROP
   PAD SWAP NUMBER 0= IF 0 THEN 
   R> CLOSE-FILE DROP ;

: timestamp>pad Num>DateTime DateTime>PAD ;

: write-number ( stamp a u -- )
    2>R S>D <# #S #> 2R> TO-FILE ;

: rss.item-timestamp@ ( node -- timestamp )
   S" pubDate" ROT node@ ?DUP 0= IF 0 EXIT THEN
   text@ parse-unixdate ;

: //more ( u1 u2 -- ) PRO > IF CONT THEN ;
: //less ( u1 u2 -- ) PRO < IF CONT THEN ;

: rss.items-new=> ( a u stamp -- )
    STATIC stamp
    stamp !
    PRO
    START{
    rss.items=> 
     DUP rss.item-timestamp@ stamp @ //more CONT 
   }EMERGE ;

: rss.items-newest ( a u -- max )
    STATIC newest
    0 newest !
    START{
    rss.items=>
     DUP rss.item-timestamp@ DUP newest @ > IF newest ! ELSE DROP THEN 
    }EMERGE
    newest @ ;

: rss-gets ( -- s )
 S" http://fforum.winglion.ru/rss.php?c=10" GET-FILE ;

/TEST

: test
    0 0 20 26 1 2007 DateTime>Num
    rss.items-new=>
     >R
      \ R@ rss.item-timestamp@ CR DUP . CR timestamp>pad TYPE
      S" pubDate" R@ nodeText CR TYPE
      S" link" R@ nodeText CR TYPE
      S" title" R@ nodeText CR TYPE
     R> ;

S" rss.xml" test
CR 
CR S" Newest : " TYPE
S" rss.xml" rss.items-newest timestamp>pad TYPE

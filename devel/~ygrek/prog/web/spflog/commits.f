\ $Id$
\ Коммиты в SPF CVS по авторам
\ Файлы Spf*ChangeLog.xml тянутся из сети и кэшируются на диск, чтобы обновить результаты - удалите их

REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
REQUIRE xml.children=> ~ygrek/lib/spec/rss.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE list-all ~ygrek/lib/list/all.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

: cl-path S" http://www.forth.org.ru/log/" ;

0 VALUE stamp

: cl-items=> ( a u --> node \ node <-- )
   PRO
   XML_READ_DOC_ROOT ?DUP ONTRUE \ root
   ( node )
   START{
     xml.children=>
     S" entry" //name=
     DUP rss.item.timestamp stamp > ONTRUE
     CONT
   }EMERGE ;

: maybe-load { a u -- }
   a u FILE-EXIST IF EXIT THEN
   a u " {EOLN}Downloading {s} ..." STYPE
   a u " {cl-path}{s}" STR@ GET-FILE STR@ a u OCCUPY ;

: find-author ( a u list -- node ? )
  LAMBDA{ >R 2DUP R> list::car STR@ COMPARE 0= } list::find 2SWAP 2DROP ;

{{ list
: inc-author ( node -- ) cdr DUP car 1+ SWAP setcar ;
}}

: add-author { a u l -- l }
   a u l find-author
   IF list::car inc-author l
   ELSE DROP %[ a u >STR % 1 % ]% l list::cons
   THEN ;

: author-sum ( node -- n ) 0 SWAP LAMBDA{ list::cdar + } list::iter ;

: BKSP 0x08 EMIT ;

{{ list
: print-authors ( node -- )
   LAMBDA{ DUP cdar SWAP car STR@ " {s} : {n}, " STYPE } iter 
   BKSP BKSP SPACE ; \ hack - erase last comma :)

: sort-by-num ( node -- ) LAMBDA{ cdar SWAP cdar U< } sort ;
}}

: go STATIC rl
  list::nil rl !
  2DUP maybe-load
  START{ cl-items=> DUP rss.item.author 2DUP rl @ add-author rl ! 2DROP }EMERGE
  rl @
;

lst(
 lst( " SpfDevChangeLog.xml" % " devel" % )lst %
 lst( " SpfLibChangeLog.xml" % " lib" % )lst %
 lst( " SpfSrcChangeLog.xml" % " src" % )lst %
 lst( " SpfDocsChangeLog.xml" % " docs" % )lst %
)lst VALUE l

: commits. ( num -- )
   TO stamp
   stamp Num>DateTime DateTime>PAD CR CR ." --------- Data since " TYPE
   l
   LAMBDA{
    DUP list::cdar STR@ " {EOLN}{EOLN}::: New commits in {s}" STYPE
        list::car STR@ go
          DUP author-sum DUP "  = {n}" STYPE
          ( n ) 0 = IF DROP EXIT THEN
          DUP sort-by-num
          CR print-authors
   } list::iter ;

: days 24 * 60 * 60 * ;

0 0 0 17 9 2007 DateTime>Num commits. \ Since spf-devel-20070917 snapshot
0 0 0 17 1 2008 DateTime>Num commits. \ Since SPF 4.19 snapshot
TIME&DATE DateTime>Num 365 days - commits. \ Last year
BYE

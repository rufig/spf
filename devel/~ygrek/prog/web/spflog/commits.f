\ $Id$
\ Коммиты в SPF CVS по авторам
\ Файлы Spf*ChangeLog.xml тянутся из сети и кэшируются на диск, чтобы обновить результаты - удалите их

REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
REQUIRE xml.children=> ~ygrek/lib/spec/rss.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE mapcar ~ygrek/lib/list/all.f
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
   a u " {CRLF}Downloading {s} ..." STYPE
   a u " {cl-path}{s}" STR@ GET-FILE STR@ a u OCCUPY ;

: find-author ( a u list -- node ? )
  LAMBDA{ car >R 2DUP R> car STR@ COMPARE 0= } SWAP scan-list 2SWAP 2DROP ;

: inc-author ( node -- ) cdr DUP car 1+ SWAP setcar ;

: add-author { a u list -- }
   a u list find-author
   IF car inc-author
   ELSE DROP lst( a u " {s}" %s 1 % )lst vnode as-list list insert-after
   THEN ;

: author-sum ( node -- n ) >R 0 LAMBDA{ cdar + } R> mapcar ;

: BKSP 0x08 EMIT ;

: print-authors ( node -- )
   LAMBDA{ DUP cdar SWAP car STR@ " {s} : {n}, " STYPE } SWAP mapcar 
   BKSP BKSP SPACE ; \ hack - erase last comma :)

: sort-by-num ( node -- ) LAMBDA{ cdar SWAP cdar U< } list-sort- ;

: go STATIC rl
  lst( lst( "" %s 0 % )lst %l )lst rl ! \ "пустое" значение чтобы можно было делать insert
  2DUP maybe-load
  START{ cl-items=> DUP rss.item.author 2DUP rl @ add-author 2DROP }EMERGE
  rl @
;

lst(
 lst( " SpfDevChangeLog.xml" % " devel" % )lst %l
 lst( " SpfLibChangeLog.xml" % " lib" % )lst %l
 lst( " SpfSrcChangeLog.xml" % " src" % )lst %l
 lst( " SpfDocsChangeLog.xml" % " docs" % )lst %l
)lst VALUE l

: commits. ( num -- )
   TO stamp
   stamp Num>DateTime DateTime>PAD CR CR ." --------- Data since " TYPE
   LAMBDA{
    DUP cdar STR@ " {CRLF}{CRLF}::: New commits in {s}" STYPE
        car STR@ go cdr \ забываем "пустое" значение
          DUP author-sum DUP "  = {n}" STYPE
          ( n ) 0 = IF DROP EXIT THEN
          DUP sort-by-num
          CR print-authors
   } l mapcar ;

0 0 0 1 6 2007 DateTime>Num commits. \ Since spf-devel-20070601 snapshot
0 0 0 17 9 2007 DateTime>Num commits. \ Since spf-devel-20070917 snapshot
BYE

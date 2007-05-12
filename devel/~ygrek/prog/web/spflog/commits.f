\ $Id$
\ Коммиты в SPF CVS по авторам
\ Файлы Spf*ChangeLog.xml тянутся из сети и кэшируются на диск, чтобы обновить результаты - удалите их

\ ~ygrek/lib/script.f
REQUIRE EXC-DUMP2 ~pinka/spf/exc-dump.f
REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
REQUIRE xml.children=> ~ygrek/lib/spec/rss.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE lst( ~ygrek/lib/list/all.f
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

: find-author ( a u list -- node -1 | 0 )
  LAMBDA{ >R 2DUP R> car STR@ COMPARE 0= } SWAP list-scan 2SWAP 2DROP ;

: inc-author ( node -- ) cdr DUP car 1+ SWAP setcar ;

: add-author { a u list -- }
   a u list find-author 
   IF car inc-author
   ELSE lst( a u " {s}" %s 1 % )lst vnode as-list list insert-after
   THEN ;

: author-sum ( node -- n ) >R 0 LAMBDA{ cdar + } R> mapcar ;

: print-authors ( node -- )
   LAMBDA{ DUP car STR@ CR TYPE ."  = " cdar . } SWAP mapcar ;

: sort-by-num ( node -- )
   LAMBDA{ cdar SWAP cdar U< } SWAP list-qsort ;

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
)lst VALUE l

: commits. ( num -- )
   TO stamp
   stamp Num>DateTime DateTime>PAD CR CR ." --------- Data since " TYPE
   LAMBDA{
    DUP cdar STR@ CR CR ." ::: New commits in " TYPE
        car STR@ go cdr \ забываем "пустое" значение
          DUP author-sum ."  = " . 
          DUP sort-by-num 
          print-authors
   } l mapcar ;

0 0 0 1 4 2007 DateTime>Num commits. \ Since spf-devel-20070401 snapshot
0 0 0 1 12 2006 DateTime>Num commits. \ Since SPF 4.18

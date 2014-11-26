\ 2013 ruv -- "command line" options to set current directory and stdout files
\ $Id$

REQUIRE OPEN-FILE-SHARED-DELETE     devel/~ac/lib/win/file/share-delete.f
REQUIRE OPEN-LOG                    devel/~pinka/samples/2005/lib/append-file.f
REQUIRE FORCE-PATH                  devel/~pinka/samples/2005/lib/lay-path.f
REQUIRE WORDLIST-NAMED              devel/~pinka/spf/compiler/native-wordlist.f
REQUIRE PUSH-DEVELOP                devel/~pinka/spf/compiler/native-context.f
REQUIRE SET-STDOUT                  devel/~pinka/spf/stdio.f
REQUIRE PARSE-STRING                devel/~pinka/lib/parse-string.f
REQUIRE SetCurrentDir               devel/~pinka/lib/win/directory.f
REQUIRE AsQName                     devel/~pinka/samples/2006/syntax/qname.f

: OPEN-LOG-SURE ( d-txt-filename -- ) FORCE-PATH OPEN-LOG ;

`SUPPORT-OPTIONS-STDIO WORDLIST-NAMED PUSH-DEVELOP

: ParseFileName ( -- a u ) PARSE-STRING 2DUP + 0 SWAP C! ;

CREATE stdpath 0. , ,
  ..: AT-PROCESS-STARTING 0. stdpath 2! ;..

: fullname ( d-txt-name -- d-txt-fullname )
  stdpath 2@ DUP 0= IF 2DROP EXIT THEN
  SYSTEM-PAD DUP >R /SYSTEM-PAD CELL- CROP CROP ( a2-rest u2-rest )
  DROP 0 OVER C! R> TUCK -
;
: open-log ( d-txt-name -- h )
  fullname OPEN-LOG-SURE
;
: parse-namelog ( -- h )
  ParseFileName open-log
;

BEGIN-EXPORT

\ command-line options

: --workdir ParseFileName SetCurrentDir ;
: --stdpath ParseFileName stdpath 2! ;
: --stdout  parse-namelog SET-STDOUT ;
: --stderr  parse-namelog SET-STDERR ;

: --chdir   --workdir ; \ alias

END-EXPORT

DROP-DEVELOP

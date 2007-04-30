\ $Id$
\
\ CVS keywords parsed as Forth strings
\ Just put $Revision$ somewhere in your source and it will transform to S" 1.1"
\ After each CVS commit revision will be automatically increased by CVS itself 
\ NB Keyword substitution is performed only if -kkv is specifed (it is the default for text files)

: kkv-extract [CHAR] $ PARSE -TRAILING ;
\ : COMPILE-STRING ( a u -- ) HERE -ROT S", COUNT ;

: $Date: kkv-extract ;
: $Revision: kkv-extract ;
: $Id: kkv-extract ;

\EOF


$Revision$ TYPE
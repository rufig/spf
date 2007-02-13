\ $Id$
\
\ CVS keywords parsed as Forth strings
\ Just put $Revision$ somewhere in your source and it will transform to S" 1.1"
\ After each CVS commit revision will be automatically increased by CVS itself 
\ NB Keyword substitution is performed only if -kkv is specifed (it is the default for text files)

: kkv-save [CHAR] $ PARSE -TRAILING S", ;
: kkv-extract HERE kkv-save COUNT ;

: $Date: kkv-extract ;
: $Revision: kkv-extract ;

\EOF


$Revision$ TYPE
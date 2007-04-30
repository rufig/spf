\ $Id$
\
\ CVS keywords parsed as Forth strings
\ Just put $Revision$ somewhere in your source and it will transform to S" 1.1"
\ After each CVS commit revision will be automatically increased by CVS itself 
\ NB Keyword substitution is performed only if -kkv is specifed (it is the default for text files)

: kkv-extract [CHAR] $ PARSE -TRAILING ;

\ вкомпильнуть строку a u в кодофайл и вернуть адрес и длину вкомпилированного образа
: -STRING- ( a u -- a1 u ) HERE -ROT S", COUNT ;

: $Date: kkv-extract ; IMMEDIATE
: $Revision: kkv-extract ; IMMEDIATE
: $Id: kkv-extract ; IMMEDIATE

\EOF

$Revision$ TYPE
: a $Date$ SLITERAL TYPE ;
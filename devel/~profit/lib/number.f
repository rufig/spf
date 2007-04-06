S" lastChar" S" ~profit\lib\strings.f" REQUIRED

: sign ( addr len --> addr len +|- ) firstChar DUP 
[CHAR] + = IF DROP restOfString FALSE EXIT THEN
[CHAR] - = IF restOfString TRUE EXIT THEN 
FALSE ;

: number ( addr len --> 0 | n -1 ) sign >R
0 0 2SWAP >NUMBER 
NIP IF RDROP 2DROP -309 THROW THEN 
D>S R> IF NEGATE THEN ;


: ParseFileName ( -- a u )
\ разобрать имя файла  из входного потока. 
\ имя может быть в кавычках ( "filename").

    BL SKIP
    SOURCE DROP >IN @ + C@   [CHAR] " = IF [CHAR] " DUP SKIP ELSE BL THEN
    PARSE  2DUP + 0 SWAP C!
;

REQUIRE BLANK         lib/include/string.f 
REQUIRE STR@          ~ac/lib/str5.f

: DelXmlDecl { a u \ len -- a u }
  a u
  BEGIN
    S" <?xml version='1.0' encoding='windows-1251'?>" DUP -> len
    SEARCH
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
  BEGIN
    S" <?xml version='1.0' encoding='windows-1251' ?>" DUP -> len
    SEARCH
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
  BEGIN
    S' <META http-equiv="Content-Type" content="text/html; charset=UTF-16">' DUP -> len
    SEARCH 
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
  BEGIN
    S' <?xml version="1.0" encoding="UTF-16"?>' DUP -> len
    SEARCH 
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
  BEGIN
    S' <?xml version="1.0" encoding="UTF-8"?>' DUP -> len
    SEARCH 
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
;
: DelXhtmlNs { a u \ len -- a u }
  a u
  BEGIN
    S' xmlns="http://www.w3.org/1999/xhtml"' DUP -> len
    SEARCH
  WHILE
    OVER len BLANK
    len - 0 MAX SWAP len + SWAP
  REPEAT
  2DROP
  a u
;
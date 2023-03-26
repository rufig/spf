: USE ( "name" -- )
  PARSE-NAME ( 2DUP dlopen2) TRUE name-lookup DROP
;

\ Dec.2004
\ $Id$

REQUIRE STR@ ~ac/lib/str2.f

REQUIRE SPLIT- ~pinka\samples\2005\lib\split.f

: replace-str ( s-what s-to s -- )
  \ заменить  s-what на s-to в s
  \ s1 и s2 освобождаются
  "" { s1 s2 so s }
  so STR@
  BEGIN DUP WHILE
    s1 STR@ SPLIT   IF
    s STR+
    s2 STR@ s STR+  ELSE
    s STR+   0.     THEN
  REPEAT 2DROP
  s STR@  so STR!
  s STRFREE
  s1 STRFREE
  s2 STRFREE
;

\EOF
: replace-str- ( s s-what s-to -- )
  ROT replace-str
;

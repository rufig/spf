\ 21-02-2007  слово, которого мне не хватает в —ѕ‘е

\ делает то же, что и ['] name COMPILE,
\ но гораздо более однозначное, чем POSTPONE
: COMPILE ( --> ) ?COMP ' LIT, ['] COMPILE, COMPILE, ; IMMEDIATE

\EOF

: sample ." sample " ;

: tst ['] sample COMPILE, ; IMMEDIATE
: ts1 COMPILE sample ; IMMEDIATE

: test tst CR ts1 ;

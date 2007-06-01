\ 21-02-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ слово, которого мне не хватает в —ѕ‘е

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

\ делает то же, что и ['] name COMPILE,
\ но гораздо более однозначное, чем POSTPONE
: COMPILE ( --> ) ?COMP ' LIT, ['] COMPILE, COMPILE, ; IMMEDIATE

?DEFINED test{ \EOF -- тестова€ секци€ ---------------------------------------

test{
      : sample 1234 ;
      : tst ['] sample COMPILE, ; IMMEDIATE
      : ts1 COMPILE sample ; IMMEDIATE
      : testing tst ts1 <> THROW ; testing
    S" passed" TYPE
}test

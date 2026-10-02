REQUIRE STR@ ~ac/lib/str5.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
VARIABLE mh-allocations VARIABLE mh-attempt VARIABLE mh-fail
: ALLOCATE ( u -- a ior )
  1 mh-attempt +! mh-fail @ DUP IF mh-attempt @ = ELSE DROP FALSE THEN
  IF DROP 0 -59 EXIT THEN
  ALLOCATE DUP 0= IF 1 mh-allocations +! THEN
;
: FREE ( a -- ior ) FREE DUP 0= IF -1 mh-allocations +! THEN ;
REQUIRE ParseMessageHeaders ~ac/lib/lin/mime/mime.f
DEPTH CONSTANT mh-test-depth
: MH-ASSERT 0= IF -9989 THROW THEN ;
\ Fixture notation: ~ = CR, | = LF, ^ = HTAB; no dependency on acTCP's literals.
: MH-EXPAND { a u \ s p -- s }
  a u >STR -> s s STR@ DROP -> p
  u 0 ?DO p I + C@ CASE
    126 OF 13 p I + C! ENDOF 124 OF 10 p I + C! ENDOF 94 OF 9 p I + C! ENDOF
  ENDCASE LOOP s
;
: MH-CRLF ( -- a u ) S" Message-ID: <x@test>~|Subject: folded~|^value~|Content-Type: multipart/mixed; boundary=x~|~|body" ;
: MH-LF ( -- a u ) S" Message-ID: <x@test>|Subject: folded|^value||body" ;
: MH-CHECK { a u expected eu \ mp input wanted -- }
  a u MH-EXPAND -> input expected eu MH-EXPAND -> wanted
  input STR@ ParseMessageHeaders -> mp
  S" Message-ID" mp FindMimeHeader S" <x@test>" COMPARE 0= MH-ASSERT
  S" subject" mp FindMimeHeader wanted STR@ COMPARE 0= MH-ASSERT
  mp mpBodyAddr @ mp mpBodyLen @ S" body" COMPARE 0= MH-ASSERT
  mp mpParts @ 0= MH-ASSERT mp FreeMimeHeaders input STRFREE wanted STRFREE
;
: MH-BAD { a u code \ input -- }
  a u MH-EXPAND -> input
  input STR@ ['] ParseMessageHeaders CATCH code = MH-ASSERT 2DROP input STRFREE
  MimePart @ 123 = MH-ASSERT CurrentHeader @ 456 = MH-ASSERT
  mh-allocations @ 0= MH-ASSERT
;
CREATE mh-long 1100 ALLOT
: MH-LEGACY { \ input mp -- }
  S" From: a@test~|Content-Type: text/plain; Charset=utf-8~|Subject: folded~|^value~|~|body" MH-EXPAND -> input
  input STR@ ParseMessageText -> mp
  mp mpParts @ 0= MH-ASSERT
  mp mpCharsetAddr @ mp mpCharsetLen @ S" utf-8" COMPARE 0= MH-ASSERT
  S" Subject" mp FindMimeHeader S" folded~|^value" MH-EXPAND >R R@ STR@ COMPARE 0= MH-ASSERT R> STRFREE
  mp FreeMimeHeaders input STRFREE
;
: MH-TEST { \ saved-mp saved-header saved-ltl -- }
  MimePart @ -> saved-mp CurrentHeader @ -> saved-header LTL @ -> saved-ltl
  123 MimePart ! 456 CurrentHeader !
  1000 0 DO
    1 LTL ! MH-CRLF S" folded~|^value" MH-CHECK
    2 LTL ! MH-LF S" folded|^value" MH-CHECK
    mh-allocations @ 0= MH-ASSERT
  LOOP
  MimePart @ 123 = MH-ASSERT CurrentHeader @ 456 = MH-ASSERT
  S" " MIME-INVALID-HEADERS MH-BAD
  S" orphan~|~|" MIME-INVALID-HEADERS MH-BAD
  S"  orphan~|~|" MIME-INVALID-HEADERS MH-BAD
  S" Subject: unterminated" MIME-INVALID-HEADERS MH-BAD
  S" Bad Name: value||" MIME-INVALID-HEADERS MH-BAD
  mh-long 1100 65 FILL mh-long 1100 MIME-HEADERS-LIMIT MH-BAD
  5 1 DO 0 mh-attempt ! I mh-fail ! MH-CRLF -59 MH-BAD LOOP 0 mh-fail !
  MH-LEGACY
  mh-allocations @ 0= MH-ASSERT
  saved-ltl LTL ! saved-mp MimePart ! saved-header CurrentHeader !
;
MH-TEST DEPTH mh-test-depth = MH-ASSERT .( MIME header tests passed) CR BYE

\ $Id$

: MemReport ;
: ClearMemInfo ;
\ ~day/lib/memreport.f
\ ~ygrek/work/memreport/memreport1.f

REQUIRE RE" ~ygrek/lib/re/re.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f

\ -----------------------------------------------------------------------

TESTCASES regex parsing

(( S" 1+"               dotto: 01.dot -> TRUE ))
(( S" (1+234*5?)"       dotto: 02.dot -> TRUE ))
(( S" (1)"              dotto: 03.dot -> TRUE ))
(( S" (1(23)?(4)+)"     dotto: 04.dot -> TRUE ))
(( S" 1"                dotto: 05.dot -> TRUE ))
(( S" th(is|at)\?"      dotto: 06.dot -> TRUE ))
(( S" th((is)|(at))\?"  dotto: 07.dot -> TRUE ))
(( S" ((ya)|(no)+)+!"   dotto: 08.dot -> TRUE ))
(( S" (1|2|3)+"         dotto: 09.dot -> TRUE ))
(( S" .*abc.*"          dotto: 10.dot -> TRUE ))
(( S" \.\*ab\\c\.\*"    dotto: 11.dot -> TRUE ))
(( S" for(th(er)?|um|)" dotto: 12.dot -> TRUE ))

CR .( NB: 'REGEX SYNTAX ERROR' messages are expected in this test!)

(( S" (1"     dotto: error.dot -> FALSE ))
(( S" (1++)"  dotto: error.dot -> FALSE ))
(( S" ()"     dotto: error.dot -> FALSE ))
(( S" +"      dotto: error.dot -> FALSE ))
\ (( S" (3))"   dotto: error.dot -> FALSE )) \ это пока не ловится...
(( S" 123(*)" dotto: error.dot -> FALSE ))
(( S" a\bc"   dotto: error.dot -> FALSE ))

ClearMemInfo

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES stre_fast_match?

(( S" 12+1?3" S" 12222213" 2SWAP stre_fast_match? -> TRUE ))
(( S" 12+1?3" S" 1223" 2SWAP stre_fast_match? -> TRUE ))
(( S" 12+1?3" S" 1213" 2SWAP stre_fast_match? -> TRUE ))
(( S" 12+1?3" S" 123" 2SWAP stre_fast_match? -> TRUE ))

(( S" 12+1?3" S" 113" 2SWAP stre_fast_match? -> FALSE ))
(( S" 12+1?3" S" 1222221" 2SWAP stre_fast_match? -> FALSE ))
(( S" 12+1?3" S" 2222213" 2SWAP stre_fast_match? -> FALSE ))

(( S" 1((ab)|(cd))+" S" 1ababcdab" 2SWAP stre_fast_match? -> TRUE ))
(( S" 1((ab)|(cd))+" S" 1ababab" 2SWAP stre_fast_match? -> TRUE ))
(( S" 1((ab)|(cd))+" S" 1cdcdcd" 2SWAP stre_fast_match? -> TRUE ))
(( S" 1((ab)|(cd))+" S" 1cdabcdab" 2SWAP stre_fast_match? -> TRUE ))
(( S" 1((ab)|(cd))+" S" 1ab" 2SWAP stre_fast_match? -> TRUE ))
(( S" 1((ab)|(cd))+" S" 1cd" 2SWAP stre_fast_match? -> TRUE ))

(( S" 1((ab)|(cd))+" S" 1" 2SWAP stre_fast_match? -> FALSE ))
(( S" 1((ab)|(cd))+" S" 1abc" 2SWAP stre_fast_match? -> FALSE ))

(( S" (ab|cd)+" S" abdacd" 2SWAP stre_fast_match? -> FALSE ))
(( S" (ab|cd)+" S" abdabdacdabd" 2SWAP stre_fast_match? -> FALSE ))
(( S" (ab|cd)+" S" acd" 2SWAP stre_fast_match? -> FALSE ))
(( S" (ab|cd)+" S" abd" 2SWAP stre_fast_match? -> FALSE ))
(( S" (ab|cd)+" S" acdacd" 2SWAP stre_fast_match? -> FALSE ))
(( S" (ab|cd)+" S" " 2SWAP stre_fast_match? -> FALSE ))

(( S" (ab|cd)+" S" abcd" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" abab" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" ababcd" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" abcdab" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" cdcdab" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" cd" 2SWAP stre_fast_match? -> TRUE ))
(( S" (ab|cd)+" S" ab" 2SWAP stre_fast_match? -> TRUE ))

(( S" a(1|2|3)b(1|2|3)c" S" a1b1c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a1b2c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a1b3c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a2b1c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a2b2c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a2b3c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a3b1c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a3b2c" 2SWAP stre_fast_match? -> TRUE ))
(( S" a(1|2|3)b(1|2|3)c" S" a3b3c" 2SWAP stre_fast_match? -> TRUE ))

(( S" a(1|2|3)b(1|2|3)c" S" a4b1c" 2SWAP stre_fast_match? -> FALSE ))
(( S" a(1|2|3)b(1|2|3)c" S" a22c" 2SWAP stre_fast_match? -> FALSE ))
(( S" a(1|2|3)b(1|2|3)c" S" a2b3" 2SWAP stre_fast_match? -> FALSE ))

(( S" forther" S" for(th(er)?|um|)" stre_fast_match? -> TRUE ))
(( S" forth"   S" for(th(er)?|um|)" stre_fast_match? -> TRUE ))
(( S" forum"   S" for(th(er)?|um|)" stre_fast_match? -> TRUE ))
(( S" for"     S" for(th(er)?|um|)" stre_fast_match? -> TRUE ))

(( S" fort"     S" for(th(er)?|um|)" stre_fast_match? -> FALSE ))
(( S" forther1" S" for(th(er)?|um|)" stre_fast_match? -> FALSE ))
(( S" forthum"  S" for(th(er)?|um|)" stre_fast_match? -> FALSE ))

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES regex matching character classes

(( S" abc def" S" abc\sdef" stre_match? -> TRUE ))
(( S" abc def" S" \w+\s\w+" stre_match? -> TRUE ))
(( S" abc def" S" \w+ \w+" stre_match? -> TRUE ))
(( S" abc def" S" \w+" stre_match? -> FALSE ))
(( S" abc def" S" \w\w\w\s\w\w\w" stre_match? -> TRUE ))
(( S" abc def" S" \w\w\w\W\w\w\w" stre_match? -> TRUE ))
(( S" abc def" S" \S\S\S\s\S\S\S" stre_match? -> TRUE ))
(( S" abc def" S" \S\S\S\W\S\S\S" stre_match? -> TRUE ))
" {0x11 PAD C! PAD 1}abc{9 PAD C! PAD 1}def{CRLF}xyz" VALUE s
(( s STR@ S" \x11abc\tdef\r\nxyz" stre_match? -> TRUE ))
s STRFREE

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES misc

: qqq RE" 123\"qwerty\"" re_fast_match? ;
: email? RE" \w+@\w+(\.\w+)+" re_fast_match? ;

(( " 123{''}qwerty{''}" DUP STR@ qqq SWAP STRFREE -> TRUE ))
(( " 123{''}qwerty"     DUP STR@ qqq SWAP STRFREE -> FALSE ))

(( S" hello1@example.com" email? -> TRUE ))
(( S" hello_world@example.com" email? -> TRUE ))
(( S" a@a.com" email? -> TRUE ))
(( S" a@a.b.com" email? -> TRUE ))

(( S" he!!o@example.com" email? -> FALSE ))
(( S" a[at]a.com" email? -> FALSE ))
(( S" a@acom" email? -> FALSE ))

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES re_match?

: str S" hello hallo world..." ;

(( str S" (((h(e|a)llo|farewell)\s)+)(cruel\s)?(world|planet)(!?)..." stre_match? -> TRUE ))
(( 0 get-group -> str ))
(( 1 get-group S" hello hallo " TEST-ARRAY -> ))
(( 2 get-group S" hello " TEST-ARRAY -> ))
(( 3 get-group S" hello" TEST-ARRAY -> ))
(( 4 get-group S" e" TEST-ARRAY -> ))
(( 5 get-group -> 0 0 ))
(( 6 get-group S" world" TEST-ARRAY -> ))
(( 7 get-group -> str DROP 17 + 0 ))
(( 8 ' get-group CATCH NIP 0 <> -> TRUE )) \ ловим ожидаемое исключение

\ теперь то же самое для статических регекспов

: re RE" (((h(e|a)llo|farewell)\s)+)(cruel\s)?(world|planet)(!?)..." ;

(( 0 get-group -> str ))
(( 1 get-group S" hello hallo " TEST-ARRAY -> ))
(( 2 get-group S" hello " TEST-ARRAY -> ))
(( 3 get-group S" hello" TEST-ARRAY -> ))
(( 4 get-group S" e" TEST-ARRAY -> ))
(( 5 get-group -> 0 0 ))
(( 6 get-group S" world" TEST-ARRAY -> ))
(( 7 get-group -> str DROP 17 + 0 ))
(( 8 ' get-group CATCH NIP 0 <> -> TRUE )) \ ловим ожидаемое исключение

0 regexp::set-default-groups \ чтобы утихомирить MemReport, удаляем результаты последнего сопоставления

END-TESTCASES

\ -----------------------------------------------------------------------

MemReport
\ countMem NIP 1 = [IF] CR .( NB: It is not a leak but a dynamic buffer for ANSI-FILE) [THEN]

\EOF

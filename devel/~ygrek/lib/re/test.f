\ $Id$

S" ~ygrek/~day/lib/memreport.f" INCLUDED

REQUIRE TESTCASES ~ygrek/lib/testcase.f

REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE dottify ~ygrek/lib/re/dot.f
REQUIRE re_search ~ygrek/lib/re/ext.f

\ -----------------------------------------------------------------------

TESTCASES parsing (bad)

CR .( NB: 'REGEX SYNTAX ERROR' messages are expected in this test!)

NewMemoryMark SetReportMark

(( S" (1"     dotto: error.dot -> FALSE ))
(( S" (1++)"  dotto: error.dot -> FALSE ))
(( S" ()"     dotto: error.dot -> FALSE ))
(( S" +"      dotto: error.dot -> FALSE ))
\ (( S" (3))"   dotto: error.dot -> FALSE )) \ это пока не ловится...
(( S" 123(*)" dotto: error.dot -> FALSE ))
(( S" a\bc"   dotto: error.dot -> FALSE ))

countMem . .
NewMemoryMark SetReportMark

\ ClearMemInfo \ тут утечки памяти за счёт некорректных регекспов - игнорируем

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES parsing

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
" {0x11 PAD C! PAD 1}abc{9 PAD C! PAD 1}def{0x0D PAD C! 0x0A PAD 1+ C! PAD 2}xyz" VALUE s
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

(( str RE" (((h(e|a)llo|farewell)\s)+)(cruel\s)?(world|planet)(!?)..." re_match? -> TRUE ))
(( 0 get-group -> str ))
(( 1 get-group S" hello hallo " TEST-ARRAY -> ))
(( 2 get-group S" hello " TEST-ARRAY -> ))
(( 3 get-group S" hello" TEST-ARRAY -> ))
(( 4 get-group S" e" TEST-ARRAY -> ))
(( 5 get-group -> 0 0 ))
(( 6 get-group S" world" TEST-ARRAY -> ))
(( 7 get-group -> str DROP 17 + 0 ))
(( 8 ' get-group CATCH NIP 0 <> -> TRUE )) \ ловим ожидаемое исключение

(( str RE" ((?:(?:h(e|a)llo|farewell)\s)+)(?:cruel\s)?(world|planet)(!?)..." re_match? -> TRUE ))
(( 0 get-group -> str ))
(( 1 get-group S" hello hallo " TEST-ARRAY -> ))
(( 2 get-group S" e" TEST-ARRAY -> ))
(( 3 get-group S" world" TEST-ARRAY -> ))
(( 4 get-group -> str DROP 17 + 0 ))
(( 5 ' get-group CATCH NIP 0 <> -> TRUE )) \ ловим ожидаемое исключение

\ regexp::re_def_groups regexp::print-array

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES re_sub

: re1 RE" foo(bar)?(s|p)uper" ;
(( S" foosuperpuperquaqua" re1 re_sub -> 8 ))
(( S" foosuper" re1 re_sub -> 8 ))
(( S" foobarpupermatch" re1 re_sub -> 11 ))

: re2 RE" (c\+\+|forth|php|ocaml) rule" ;
(( S" ocaml rulez :-)" re1 re_sub -> 0 ))
(( S" forth rulez :-)" re2 re_sub -> 10 ))
(( S" php rulez (just kidding)" re2 re_sub -> 8 ))
(( S" c++ rules me crazy!" re2 re_sub -> 8 ))

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES re_search

: str S" some absolutely raaaandom text for testing bu bu bu la la la" ;

(( str S" utely\sra+nd?" stre_search -> str DROP 10 + 13 ))
(( str S" (bu\s)+" stre_search S" bu bu bu " TEST-ARRAY -> ))
(( str S" la\sla\sla\s?" stre_search S" la la la" TEST-ARRAY -> ))
(( str S" l[^l]*l" stre_search 2DUP TYPE S" lutel" TEST-ARRAY -> ))
(( str S" m[^t]*t[^l]*l" stre_search S" me absolutel" TEST-ARRAY -> ))
(( str S" m[^t]*t" stre_search S" me absolut" TEST-ARRAY -> ))
(( str S" m[^t]*t" stre_search S" me absolut" TEST-ARRAY -> ))
(( str S" m" stre_search S" m" TEST-ARRAY -> ))
(( str S" (z?)" stre_search S" " TEST-ARRAY -> ))

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES extra

: str S" ab" ;
: >pos { a u a1 u1 } a a1 - DUP u + ;
: np ROT get-group 2SWAP >pos ;
0 [IF] \ не проходится! FIX!!
(( str S" ((a?)((ab)?))(b?)" stre_match? -> TRUE ))
(( 0 str np -> 0 2 ))
(( 1 str np -> 0 2 ))
(( 2 str np -> 0 0 ))
(( 3 str np -> 0 2 ))
(( 4 str np -> 0 2 ))
(( 5 get-group -> 0 0 ))
[THEN]
: str2 S" aaaa" ;
(( str2 RE" (a*)(a*)" re_match? -> TRUE ))
(( 0 str2 np -> 0 4 ))
(( 1 str2 np -> 0 4 ))
(( 2 get-group -> 0 0 ))

END-TESTCASES

\ -----------------------------------------------------------------------

TESTCASES matching brackets

(( S" abracadabra" S" [abcdr]+" stre_match? -> TRUE ))
(( S" abracadabra" S" [ra-d]+" stre_match? -> TRUE ))
(( S" d--d-" S" [-d]+" stre_match? -> TRUE ))
(( S" d--d-" S" [a-d]+" stre_match? -> FALSE ))
(( S" abrakadabra" S" [a-dr]+" stre_match? -> FALSE ))
(( S" abracadabra" S" abr([^r]+)ra" stre_match? -> TRUE 1 get-group S" acadab" TEST-ARRAY ))
(( S" []][" RE" [][]+" re_match? -> TRUE ))
(( S" []][" RE" [^][]+" re_match? -> FALSE ))
(( S" []][" RE" [^]]+" re_match? -> FALSE ))
(( S" []][" RE" [^[]+" re_match? -> FALSE ))
(( S" []][" RE" [^afhow*ru.+weo2423\ds]+" re_match? -> TRUE ))

END-TESTCASES

\ -----------------------------------------------------------------------

0 regexp::set-default-groups \ чтобы утихомирить MemReport, удаляем результаты последнего сопоставления

MemReport
countMem NIP 1 = [IF] CR .( NB: It is not a leak but a dynamic buffer for ANSI-FILE) [THEN]

\EOF

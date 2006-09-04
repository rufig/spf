REQUIRE { lib/ext/locals.f
REQUIRE /STRING lib/include/string.f
REQUIRE :M ~ygrek/~yz/lib/wincore.f
REQUIRE OnText ~ygrek/prog/fhlp/parser.f 
REQUIRE DateTime#GMT ~ac/lib/win/date/date-int.f
REQUIRE LAY-PATH ~pinka/samples/2005/lib/lay-path.f

' OEM>ANSI TO ANSI><OEM

VARIABLE section

WARNING OFF
: M: BL PARSE DROP C@ :M ;
WARNING ON

MESSAGES: html
M: < ." &lt;" TRUE M;
M: > ." &gt;" TRUE M;
M: & ." &amp;" TRUE M;
M: " ." &quot;" TRUE M;
MESSAGES;

: TYPEHTML ( a u -- )
   BOUNDS ?DO
    I C@ html ?find-in-xtable 0= IF I C@ EMIT THEN
   LOOP
;

: NTYPE S>D <# #S #> TYPE ;

:NONAME 2DROP ." <hr>" CR ; TO OnSectionEnd
:NONAME
 ." <a id='section-" section @ NTYPE ." '></a>"
 ." <span class=word>"
 ." <a href='#section-" section @ NTYPE ." ' class=link>"
 TYPEHTML 
 ." </a>"
 ." </span>" 
 section 1+!
 CR ; TO OnSectionStart

:NONAME ( ." <b> Группа : </b>" TYPEHTML ." </b>" CR) 2DROP ; TO OnGroup

:NONAME TYPEHTML CR ; TO OnText
:NONAME 2DROP ." <div class=code>" ; TO OnCodeStart
:NONAME 2DROP ." </div>" ; TO OnCodeEnd
:NONAME 2DROP ( <div class=text>) ; TO OnTextStart
:NONAME 2DROP ( </div>) ; TO OnTextEnd
:NONAME 2DROP ." <div class=pre>" ; TO OnPreStart
:NONAME 2DROP ." </div>" ; TO OnPreEnd

:NONAME ." <b> See also: </b><i>" TYPEHTML ." </i>" CR ; TO OnSee
:NONAME ." <tt>" TYPEHTML ." </tt>" CR ; TO OnIndex
:NONAME ." Interpretation: <span class=int>" TYPEHTML ." </span>" CR ; TO OnInt
:NONAME ." <span class=run>" TYPEHTML ." </span>" CR ; TO OnRun
:NONAME ." Compilation: <span class=comp>" TYPEHTML ." </span>" CR ; TO OnComp

: file-content ( addr max name #name -- n )
  R/O OPEN-FILE IF DROP 2DROP 0 EXIT THEN >R
  R@ FILE-SIZE THROW D>S
  \ TUCK .S CR < IF 2DROP 0 R> CLOSE-FILE THROW EXIT THEN
  MIN
  R@ READ-FILE THROW
  R> CLOSE-FILE THROW ;

CREATE MY-PAD 1024 ALLOT

: HTML-header ( cssa cssu a u -- )
 ." <HTML><HEAD><TITLE>" DUP 0= IF 2DROP S"  Unnamed" THEN TYPEHTML ." </TITLE>" CR
 ." <META HTTP-EQUIV='Content-Type' CONTENT='text/html; charset=windows-1251'>" CR
 ." <STYLE type='text/css'>" CR
 MY-PAD 1024 2SWAP file-content MY-PAD SWAP TYPE
\ ." <LINK rel='stylesheet' href='" TYPE ." ' type='text/css'>" CR
 ." </STYLE>" CR
 ." </HEAD>" CR
 ." <BODY bgcolor='white'><div align='center'><table width='800'><tr><td><pre>" CR
;

: HTML-footer
 ." </pre></td></tr></table></div></BODY></HTML>" CR
;

: convert { ina inu outa outu cssa cssu \ -- }
 ina inu ['] FIND-FULLNAME CATCH IF TYPE ."  not found! Skipping..." CR EXIT THEN 2DROP
 cssa cssu FILE-EXIST 0= IF cssa cssu TYPE ."  not found! Skipping..." CR EXIT THEN

 outa outu LAY-PATH

 section 0!
 H-STDOUT
 outa outu R/W CREATE-FILE THROW TO H-STDOUT

 cssa cssu outa outu HTML-header
 ." <div class=date>Generated from <b>" ina inu TYPEHTML 
 ." </b> on " <# 0 0 TIME&DATE DateTime# #> TYPEHTML ." </div>" CR
 ['] Run &INTERPRET !
  ina inu ['] INCLUDED CATCH 
 ['] INTERPRET_ &INTERPRET !
 IF ROT TO H-STDOUT TYPE ."  Error!" CR EXIT THEN
 HTML-footer

 TO H-STDOUT
;

\EOF

S" docs/help/ANSFth94.fhlp" S" ans94.html" S" fhlp.css" convert
S" docs/help/ANS94ru.fhlp" S" ans94ru.html" S" fhlp.css" convert
S" docs/help/SPForth.fhlp" S" spforth.html" S" fhlp.css" convert
S" docs/help/opt.fhlp" S" opt.html" S" fhlp.css" convert
S" winctl.fhlp" S" winctl.html" S" fhlp.css" convert
.( Done)
BYE

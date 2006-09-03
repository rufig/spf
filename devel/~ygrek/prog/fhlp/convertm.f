REQUIRE { lib/ext/locals.f
REQUIRE /STRING lib/include/string.f
REQUIRE :M ~ygrek/~yz/lib/wincore.f
REQUIRE OnText ~ygrek/prog/fhlp/parser.f 
REQUIRE DateTime#GMT ~ac/lib/win/date/date-int.f
REQUIRE LAY-PATH ~pinka/samples/2005/lib/lay-path.f
\ REQUIRE " ~ac/lib/str5.f

' OEM>ANSI TO ANSI><OEM

REQUIRE ENUM ~ygrek/lib/enum.f
:NONAME 0 VALUE ; ENUM VALUE:

VALUE: gCSSa gCSSu prevH ?WasText gINa gINu gPATHa gPATHu H-INDEX PREV-OUT-H H-PROJECT H-TOC ;

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

:NONAME ( ." <b> Ãðóïïà : </b>" TYPEHTML ." </b>" CR) 2DROP ; TO OnGroup

:NONAME TYPEHTML CR ; TO OnText
:NONAME 2DROP ." <div class=code>" ; TO OnCodeStart
:NONAME 2DROP ." </div>" ; TO OnCodeEnd
:NONAME 2DROP ( <div class=text>) TRUE TO ?WasText ; TO OnTextStart
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
 ." <BODY bgcolor='white'><div align='left'><pre>" CR
;

: HTML-footer
 CR ." </pre></div></BODY></HTML>" CR
;

REQUIRE STR-APPEND ~ygrek/lib/string.f

: #0S ( ud n -- )
   HLD @ 2>R
   #S
   2R> HLD @ - ?DO [CHAR] 0 HOLD LOOP
;

: OUT{ ( h -- )
   H-STDOUT TO PREV-OUT-H
   TO H-STDOUT ;

: }OUT 
   PREV-OUT-H TO H-STDOUT ;

: .'  \ 94
  ?COMP
  ['] _CLITERAL-CODE COMPILE,
  [CHAR] ' PARSE DUP C,
  HERE SWAP DUP ALLOT MOVE 0 C,
  ['] (.") COMPILE,
; IMMEDIATE

: Index-Header 
  .' <HTML><HEAD>' CR
  .'  <META name="GENERATOR" content="~ygrek\prog\fhlp\convertm.f">' CR
  .'  <!-- Sitemap 1.0 -->' CR
  .' </HEAD>' CR
  .' <BODY>' CR
  .' <OBJECT type="text/site properties">' CR
  .' </OBJECT>' CR
  .' <UL>' CR ;

: TOC-Header 
  .' <HTML><HEAD>' CR
  .'  <META name="GENERATOR" content="~ygrek\prog\fhlp\convertm.f">' CR
  .'  <!-- Sitemap 1.0 -->' CR
  .' </HEAD>' CR
  .' <BODY>' CR
  .' <OBJECT type="text/site properties">' CR
  .' <PARAM name="Window Styles" value="0x800027">' CR
  .' <PARAM name="ImageType" value="Folder">' CR
  .' </OBJECT>' CR
  .' <UL>' CR ;

: Index-Object ( addr-a addr-u name-a name-u -- )
  .' <LI><OBJECT type="text/sitemap">' CR
  .' <PARAM name="Name" value="' TYPEHTML .' ">' CR
  .' <PARAM name="Local" value="' TYPEHTML .' ">' CR
  .' </OBJECT>' CR ;

: TOC-Dir ( a u -- )
  .' <LI><OBJECT type="text/sitemap">' CR
  .' <PARAM name="Name" value="' TYPEHTML .' ">' CR
  .' </OBJECT>' CR 
  .' <UL>' CR ;

: Index-Footer
  .' </UL></BODY></HTML>' CR ;

: section-file-name
 <#
  S" .htm" HOLDS
  section @ S>D 4 #0S
  S" section" HOLDS
  gPATHa gPATHu HOLDS
 #> ;

: start-section ( a u -- )
 section 1+!
 2>R
 section-file-name R/W CREATE-FILE THROW TO H-STDOUT

 gCSSa gCSSu 2R> HTML-header ;

: end-section
   ?WasText 
   IF
   HTML-footer
   prevH TO H-STDOUT 
   THEN
;

:NONAME 2DROP 
  CR ." <hr>" 
  ." <b>From </b><i>" gINa gINu TYPEHTML ." </i>"
  CR ." <b>Date </b><i>" <# 0 0 TIME&DATE DateTime#GMT #> TYPEHTML ." </i>"
  end-section ; TO OnSectionEnd

: start-index ( a u -- )
   R/W CREATE-FILE THROW TO H-INDEX
   H-INDEX OUT{ Index-Header }OUT ;

: end-index
  H-INDEX OUT{ Index-Footer }OUT
  H-INDEX CLOSE-FILE THROW ;

: start-toc ( a u -- )
   R/W CREATE-FILE THROW TO H-TOC
   H-TOC OUT{ TOC-Header }OUT ;

: end-toc
  H-TOC OUT{ Index-Footer }OUT
  H-TOC CLOSE-FILE THROW ;

: start-project ( a u -- )
   R/W CREATE-FILE THROW TO H-PROJECT
   H-PROJECT 
   OUT{
    ." [OPTIONS]" CR
    ." Compatibility=1.1 or later" CR
    ." Full-text search=Yes" CR
    ." Compiled file=spf_help_ru.chm" CR
    ." Index file=spf_help_ru.hhk" CR
    ." Contents file=spf_help_ru.hhc" CR 
    ." Default topic=index.ru.htm" CR
    ." Display compile progress=No" CR
    ." Language=0x419 Russian" CR 
    ." Title=SPF help" CR 
    CR
    ." [FILES]" CR
   }OUT ;

: add-file ( a u a1 u1 )
   2OVER 2OVER H-INDEX OUT{ Index-Object }OUT
   2OVER 2OVER H-TOC OUT{ Index-Object }OUT
   2DROP H-PROJECT OUT{ TYPEHTML CR }OUT ;

: end-project
  H-PROJECT CLOSE-FILE THROW ;

: CUT-FIRST ( a u -- )
   BEGIN
    DUP
   WHILE
    OVER C@ is_path_delimiter 0= 
   WHILE
    1 /STRING
   REPEAT
    1 /STRING
   THEN  ;

:NONAME
 ?WasText IF 2DUP start-section THEN
 FALSE TO ?WasText
 section-file-name 2OVER add-file
 \ ." <a id='section-" section @ NTYPE ." '></a>"
 ." <span class=word>"
 \ ." <a href='#section-" section @ NTYPE ." ' class=link>"
 TYPEHTML 
 \ ." </a>"
 ." </span>" 
 CR ; TO OnSectionStart

: convertm { ina inu ptha pthu nptha npthu cssa cssu \ -- }
 ina inu ['] FIND-FULLNAME CATCH IF TYPE ."  not found! Skipping..." CR EXIT THEN 2DROP
 cssa cssu FILE-EXIST 0= IF cssa cssu TYPE ."  not found! Skipping..." CR EXIT THEN

 ptha pthu LAY-PATH-CATCH IF ." Error with path " TYPE CR EXIT THEN 

 0 section !
 TRUE TO ?WasText

 cssa TO gCSSa
 cssu TO gCSSu

 ina TO gINa
 inu TO gINu

 ptha TO gPATHa
 pthu TO gPATHu

 H-TOC OUT{ nptha npthu TOC-Dir }OUT

 H-STDOUT TO prevH

 ['] Run &INTERPRET !
  ina inu ['] INCLUDED CATCH 
  S" " OnSectionEnd
 ['] INTERPRET_ &INTERPRET !
 IF TYPE ."  Error!" CR EXIT THEN 
 prevH TO H-STDOUT

 H-TOC OUT{ .' </UL>' }OUT
 ;

\EOF

S" Index.hhk" start-index
S" project.hhp" start-project
S" toc.hhc" start-toc

S" docs/help/SPForth.fhlp" S" qwe\" S" Some name" S" fhlp.css" convertm

end-toc
end-index
end-project

.( Done)
BYE

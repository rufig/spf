S" ~ygrek/prog/fhlp/convert.f" INCLUDED

REQUIRE ENUM ~ygrek/lib/enum.f
:NONAME 0 VALUE ; ENUM VALUE:

VALUE: gCSSa gCSSu prevH ?WasText gINa gINu gPATHa gPATHu H-INDEX PREV-OUT-H H-PROJECT H-TOC 
 ?first-file ;

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
  CR ." <b>Date </b><i>" <# 0 0 TIME&DATE DateTime# #> TYPEHTML ." </i>"
  end-section ; TO OnSectionEnd

:NONAME 2DROP TRUE TO ?WasText ; TO OnTextStart

: start-index ( a u -- )
   H-PROJECT OUT{ ." Index file=" 2DUP TYPEHTML CR }OUT
   R/W CREATE-FILE THROW TO H-INDEX
   H-INDEX OUT{ Index-Header }OUT ;

: end-index
  H-INDEX OUT{ Index-Footer }OUT
  H-INDEX CLOSE-FILE THROW ;

: start-toc ( a u -- )
   H-PROJECT OUT{ ." Contents file=" 2DUP TYPEHTML CR }OUT
   R/W CREATE-FILE THROW TO H-TOC
   H-TOC OUT{ TOC-Header }OUT ;

: end-toc
  H-TOC OUT{ Index-Footer }OUT
  H-TOC CLOSE-FILE THROW ;

: start-project ( a u -- )
   R/W CREATE-FILE THROW TO H-PROJECT
   TRUE TO ?first-file
   H-PROJECT 
   OUT{
    ." [OPTIONS]" CR
    ." Compatibility=1.1 or later" CR
    \ ." Display compile progress=Yes" CR
    ." Language=0x419 Russian" CR 
   }OUT ;

: project-start-file ( a u -- )
   H-PROJECT OUT{ ." Default topic=" TYPEHTML CR }OUT ;

: project-out-file ( a u -- )
  H-PROJECT OUT{ ." Compiled file=" TYPEHTML CR }OUT ;

: project-title ( a u -- )
  H-PROJECT OUT{ ." Title=" TYPEHTML CR }OUT ;

: project-full-search ( -- )
  H-PROJECT OUT{ ." Full-text search=Yes" CR }OUT ;


: add-file ( a u a1 u1 )
   ?first-file IF 
    H-PROJECT OUT{
      CR
      ." [FILES]" CR
    }OUT
    FALSE TO ?first-file 
   THEN
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

S" project.hhp" start-project \ должна быть первой строчкой
S" Index.hhk" start-index \ если нужен индекс
S" toc.hhc" start-toc \ если нужна таблица содержания

S" index.ru.htm" project-start-file \ указать начальный файл
S" SPF help" project-title \ указать заголовок (почему-то не работает..)
project-full-search \ полнотекстовый поиск
S" spf_help_ru.chm" project-out-file \ выходной файл

 S" index.ru.htm" S" Home" add-file \ добавить файл вручную


S" docs/help/SPForth.fhlp" S" qwe\" S" Some name" S" fhlp.css" convertm \ добавить все секции из fhlp

end-toc
end-index
end-project \ не забыть закрыть!

.( Done)
BYE

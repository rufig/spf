\ $Id$
\
\ Front page of http://spf.sf.net

REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f
REQUIRE XHTML ~ygrek/lib/xhtml/core.f
REQUIRE env ~ygrek/lib/env.f

ALSO XMLSAFE
ALSO XHTML

: .block PRO `block :div CONT ;

\ link to download
: link-dl ( `name -- ) 2DUP " http://downloads.sourceforge.net/spf/{s}" DUP STR@ link-tag STRFREE TYPE ;

: notes-4.20 `https://sourceforge.net/project/shownotes.php?group_id=17919&release_id=655371 ;

: bytes ( n -- s ) 
  DUP 1024 < IF " {n} bytes" EXIT THEN
  1024 /MOD DUP 1024 < IF NIP " {n} KB" EXIT THEN
  NIP
  1024 /MOD DUP 1024 < IF SWAP 100 / SWAP " {n}.{n} MB" EXIT THEN
  NIP
  1024 / " {n} GB" ;

: release ( `dl size `notes `date `comment )
  [env]
  `comment env! `date env! `notes env! `size env HASH!N `dl env! 
  
  << tr
   << td `dl env@ link-dl >>
   << td `size env HASH@N IF bytes STYPE THEN >>
\   << td `notes env@ TYPE >>
   << td `date env@ `notes env@ link-text >>
   << td `comment env@ TYPE >>
  >> ;


: releases
 .block

 %[ `0 `cellpadding $$ `0 `cellspacing $$ ]% `table atag
 << tr *> `File th <*> `Size th <*> ( `Notes th <*>) `Date th <*> `Comment th <* >>

 `spf4-20-setup.exe 
 2257644
 notes-4.20
 S" 21 Jan 2009"
 S" Win32 full installer"
 release

 `spf4-20.rar
 2336781
 notes-4.20
 S" 21 Jan 2009"
 S" Win32 full archive"
 release

 `spf-4.20.tar.gz
 761984
 notes-4.20
 S" 21 Jan 2009"
 S" Linux sources+binary tarball, without devel"
 release

 `spf-devel-4.20.tar.gz
 2345649
 notes-4.20
 S" 21 Jan 2009"
 S" Linux devel tarball"
 release
 
 `spforth4_4.20-1_i386.deb
 545120
 notes-4.20
 S" 21 Jan 2009"
 S" Debian GNU/Linux binary package, without devel"
 release 
 
 ;

: intro
   .block
   << `caps :span
 << `http://sourceforge.net/projects/spf link-tag 
    %[ `spf.png `src $$ `32px `height $$ `32px `width $$ S" SP-Forth" `alt $$ ]% `img /atag >> SPACE
   ." SP-Forth" >> "  is an ANS forth system for Windows and Linux.
It features optimized native code generation, high speed execution, full ANS'94 support, small yet highly-extensible kernel,
big number of additional libraries for developing sophisticated windows applications, active and helpful community." STYPE ;

: download
\  .block
  `span tag
   `Download `http://sourceforge.net/project/showfiles.php?group_id=17919 link-text ;

: project-page
\  .block
  `span tag
  S" Project page" `http://sourceforge.net/projects/spf link-text ;

: cvs
\ .block
  `span tag
  `CVS `http://sourceforge.net/cvs/?group_id=17919 link-text ( mdash ." get the latest sources.") ;

: first
   S" line block" :div
   project-page
   download
   cvs ;

: roadmap
  .block
   ." Roadmap:" `br /tag
   ." 4.21 &mdash; wide characters" ;

: link-tracker ( `name `extra -- )
   " http://sourceforge.net/tracker/?group_id=17919{s}" { s }
   s STR@ link-text 
   s STRFREE ;

: tracker
 .block
  `Bugtracker S" " link-tracker 
  mdash
  ." feel free to leave tickets concerning "
  `bugs `&atid=117919&func=browse link-tracker
  ." , documentation omissions, "
  S" feature requests" `&atid=367919&func=browse link-tracker 
  ." , etc." ;

: link-list
  2DUP " https://lists.sourceforge.net/lists/listinfo/{s}" { s }
  s STR@ link-text s STRFREE ;

: lst ( `name `desc -- ) 2SWAP link-list mdash TYPE ;

: lists
  .block
  ." Mailing lists :"
  ul
   << li `spf-dev S" the first place to contact developers." lst >>
   << li `spf-tickets S" bugtracker changes." lst >>
   << li `spf-commits S" CVS commits." lst >> ;

: docs
 .block
 ." Docs available online:"
 ul plaintags
  << li 
    `SPF_README `docs/readme.en.html link-text
    ."  (" `ru `docs/readme.ru.html link-text ." )." >>
  << li `SPF_INTRO `docs/intro.en.html link-text
    ."  (" `ru `docs/intro.ru.html link-text ." )"
    mdash ." a short introduction, for those already familiar with some Forth-system and ANS'94 standard." >>
  << li `SPF_DEVEL `docs/devel.en.html link-text
    ."  (" `ru `docs/devel.ru.html link-text ." )" 
    mdash ." description and links to most used/useful libraries for SPF." >>
  << li ." SPF_SRC (" `ru `docs/src.ru.html link-text ." )" 
    mdash ." quick overview of SPF kernel." >>
  << li `SPF_ANS `docs/ans.en.html link-text 
    mdash ." documentation as required by ANS." >> ;

: rufig
 .block
  `RuFIG `http://forth.org.ru link-text mdash ." Russian Forth Interest Group" ;

: footer
   .block
\  `div tag
  << `http://sourceforge.net/projects/spf link-tag
   %[ `http://sflogo.sourceforge.net/sflogo.php?group_id=17919&type=12 `src $$
      `120 `width $$
      `30 `height $$
      S" Get SP-Forth - ANS Forth compiler at SourceForge.net. Fast, secure and Free Open Source software downloads" `alt $$ ]% 
      `img /atag >>

  icon-valid

  << `http://forth.org.ru/~ygrek/prog/web/spf.sf.net/index.f link-tag
  %[ `http://www.forth.org.ru/img/powered-by-spf-mono-2-ani.gif `src $$
     S" View source" `alt $$ ]% `img /atag >>

\  `small tag
\   S" $Id$" TYPE 
;

: index
   xml-declaration
   doctype-strict
   xhtml
   << `head tag
     << `title tag S" SP-Forth" TYPE >>
     << `index.css link-stylesheet >>
\     << S" application/xhtml+xml; encoding=utf-8" S" Content-Type" http-equiv >>
   >>

`body tag

<< `content :div 
intro
first
\ download
releases
\ project-page
\ roadmap
tracker
lists
docs
\ cvs
rufig
footer
>>
;

index BYE

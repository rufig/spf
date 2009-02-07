\ $Id$
\
\ Front page of http://spf.sf.net

REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f
REQUIRE XHTML ~ygrek/lib/xhtml/core.f
REQUIRE new-hash ~pinka/lib/hash-table.f
REQUIRE KEEP! ~profit/lib/bac4th.f

: css ( a u s -- ) -ROT TYPE ."  { " STYPE ." }" CR ;

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

USER _h
: h _h @ ;

: h! h HASH! ;
: h@ h HASH@ ;

: [hash]
  PRO
  10 new-hash _h KEEP!
  CONT
  h del-hash ;

( : inner
  [hash]
  `key `value h HASH!
  `key2 `value2 h HASH!
  h hash-count . ;

: outer
  [hash]
  `q `v h HASH!
  inner
  h hash-count . ;

outer h .)

: release ( `dl size `notes `date `comment )
  [hash]
  `comment h! `date h! `notes h! `size h HASH!N `dl h! 
  
  << tr
   << td `dl h@ link-dl >>
   << td `size h HASH@N IF bytes STYPE THEN >>
\   << td `notes h@ TYPE >>
   << td `date h@ `notes h@ link-text >>
   << td `comment h@ TYPE >>
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

( 
<br/>
<a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.7z">7z</a>, 1.7 MB
</td>
<td><a href="http://sourceforge.net/project/shownotes.php?release_id=608161&group_id=17919">spf-devel-20080619</a></td>
<td>19 June 2008</td>
<td>for SPF/Windows</td>
</tr>

<tr>
<td>
<a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.tar.gz">gz</a>, 2.2 MB
<br/>
<a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.tar.bz2">bz2</a>, 2.0 MB
</td>
<td><a href="http://sourceforge.net/project/shownotes.php?release_id=608161&group_id=17919">spf-devel-20080619</a></td>
<td>19 June 2008</td>
<td>for SPF/Linux</td>
</tr>
)

0 [IF] 
<!--ul>
  <li>
  <a href="http://sourceforge.net/project/shownotes.php?release_id=569286&group_id=17919">SPF 4.19 Win32</a>
  full installer (17 Jan 2008) 
  <ul><li><a href="http://downloads.sourceforge.net/spf/spf4-19-setup.exe">exe</a>, 2 MB</li></ul>
  </li>
  <li>
  <a href="http://sourceforge.net/project/shownotes.php?release_id=597863&group_id=17919">SPF 4.19 Linux beta1</a>
  (sources+binary, no devel, no docs) (7 May 2008) 
  <ul><li><a href="http://downloads.sourceforge.net/spf/spf4-19-linux-beta1.tar.gz">tar.gz</a>, 355 KB</li></ul>
  </li>
  <li>
  <a href="http://sourceforge.net/project/shownotes.php?release_id=608161&group_id=17919">spf-devel-20080619</a>  
  &mdash; latest update of the contributed code
  <ul>
  <li><a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.rar">rar</a></li>
  <li><a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.7z">7z</a></li>
  <li><a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.tar.gz">tar.gz</a></li>
  <li><a href="http://downloads.sourceforge.net/spf/spf-devel-20080619.tar.bz2">tar.bz2</a></li>
  </ul>
  </li>
</ul-->
<!--h3--></td></tr>

<tr><td><hr/></td></tr>
[THEN]

: intro
   .block
   << `caps :span
 << `http://sourceforge.net/projects/spf/ link-tag 
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
  S" Project page" `http://sourceforge.net/projects/spf/ link-text ;

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
 ul 
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
  
  << `http://sourceforge.net link-tag
   %[ `http://sourceforge.net/sflogo.php?group_id=17919 `src $$
      S" SourceForge Logo" `alt $$ ]% `img /atag >>

  icon-valid

  << `http://forth.org.ru link-tag
  %[ `http://www.forth.org.ru/img/powered-by-spf-mono-2-ani.gif `src $$
     S" Powered by SP-Forth" `alt $$ ]% `img /atag >>

\  `small tag
\   S" $Id$" TYPE 
;

: index
   xml-declaration
   doctype-strict
   xhtml
   << `head tag
     << `title tag S" SP-Forth" TYPE >>
     `index.css link-stylesheet
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

\ $Id$
\
\ Front page of http://spf.sf.net

REQUIRE tag ~ygrek/lib/xmltag.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f
REQUIRE XHTML ~ygrek/lib/xhtml/core.f

: css ( a u s -- ) -ROT TYPE ."  { " STYPE ." }" CR ;

ALSO XMLSAFE
ALSO XHTML

: .block PRO `block :div CONT ;

\ link to download
: link-dl ( `name -- ) 2DUP " http://downloads.sourceforge.net/spf/{s}" DUP STR@ link-tag STRFREE TYPE ;

: notes-4.20
   PRO `https://sourceforge.net/project/shownotes.php?group_id=17919&release_id=655371 link-tag CONT ;

: releases
 .block

 %[ `0 `cellpadding $$ `0 `cellspacing $$ ]% `table atag
 << tr *> `File th <*> `Size th <*> `Notes th <*> `Date th <*> `Comment th <* >>

( << tr
  %[ `5 `colspan $$ ]% `td atag `h3 tag S" SP-Forth 4.19" TYPE 
 >>)

 << tr
  << td `spf4-20-setup.exe link-dl >>
  << td ." 2.1 MB" >>
  << td notes-4.20 ." Win32" >>
  << td ." 21 Jan 2009" >>
  << td ." full installer" >>
 >>
 
 << tr
  << td `spf4-20.rar link-dl >>
  << td ." 2.2 MB" >>
  << td notes-4.20 ." Win32" >>
  << td ." 21 Jan 2009" >>
  << td ." full" >>
 >>

<< tr
  << td `spf-4.20.tar.gz link-dl >>
  << td ." 744 KB" >>
  << td notes-4.20 ." Linux sources" >>
  << td ." 21 Jan 2009" >>
  << td ." sources+binary, no devel" >> 
 >>

 << tr
  << td `spf-devel-4.20.tar.gz link-dl >>
  << td ." 2.2 MB" >>
  << td notes-4.20 ." Linux sources" >>
  << td ." 21 Jan 2009" >>
  << td ." devel" >> 
 >>
 
 << tr
  << td `spforth4_4.20-1_i386.deb link-dl >>
  << td ." 532 KB" >>
  << td notes-4.20 ." Debian" >>
  << td ." 21 Jan 2009" >>
  << td ." binary package, no devel" >> 
 >>

( 
<tr>
<td colspan="4"><h3>devel snapshot</h3></td>
</tr>


 << tr
  << td `spf-devel-20080619.rar link-dl >>
  << td ." 1.8 MB" >>
  << td

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
;

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
    %[ `icon `class $$ `spf.png `src $$ `32px `height $$ `32px `width $$ ]% `img /atag >>
   ." SP-Forth" >> "  is an ANS forth system for Windows 9x/NT/Vista (and Linux). 
Features optimized native code generation, high speed execution, full ANS'94 support, small yet highly-extensible kernel, 
big number of additional libraries for developing sophisticated windows applications, active and helpful community." STYPE ;

: download
  .block
   `Download `http://sourceforge.net/project/showfiles.php?group_id=17919 link-text ;

: project-page
  .block
  S" Project page" `http://sourceforge.net/projects/spf/ link-text ;

: roadmap
  .block
   ." Roadmap:" `br /tag
   ." 4.21 &mdash; wide characters" ;

: link-tracker ( `name `extra -- )
   " http://sourceforge.net/tracker/?group_id=17919{s}" { s }
   s STR@ link-text 
   s STRFREE ;

: mdash ."  &mdash; " ;

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

: li `li PRO tag CONT ;
: ul `ul PRO tag CONT ;
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
    `SPF_README `docs/readme.en.html" link-text
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

: cvs
 .block
  `CVS `http://sourceforge.net/cvs/?group_id=17919 link-text mdash ." get the latest sources." ;

: rufig
 .block
  `RuFIG `http://forth.org.ru link-text mdash ." Russian Forth Interest Group" ;

: footer
  `div tag
  
  << `http://sourceforge.net link-tag
   %[ `0 `border $$
      `http://sourceforge.net/sflogo.php?group_id=17919 `src $$
      S" SourceForge Logo" `alt $$ ]% `img /atag >>
  `small tag
\   S" $Id$" TYPE 
;

: index
 `html tag
 <<
  `head tag
   << `title tag S" SP-Forth" TYPE >>
   << %[ `text/css `type $$ ]% `style atag
`body " background-color: #FFFFFF; font-family: arial,helvetica,sans-serif;" css
`a " text-decoration: none; color #3333FF; " css
`a:visited " text-decoration: none; color: #6666AA; "  css
`a:link " text-decoration: none; color: #3333AA; " css
`a:active " text-decoration: none; color: #3333AA; " css
`a:hover " text-decoration: none; color: #FF3333; " css
\ `div " outline: 1px solid red; " css
\ `table " cellpadding: 0; cellspacing: 0;" css
S" td,th" " padding: 5 20 5 10; border: 1px solid black; " css
`th " background-color: gold; " css
`.block " padding: 10px; border-bottom: 1px dashed black;" css
`img.icon " padding-right: 4px; /*outline: 1px solid green;*/ " css
`.content " width: 70%; " css
`.caps " font-size: 3em; line-height: 0.85; font-family: sans-serif; /* outline: 1px solid red;*/ " css
   >>
 >>


\ <body bgcolor=#FFFFFF topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0">
`body tag
( 
<!-- top title table -->
<table width="100%" border=0 cellspacing=0 cellpadding=0 bgcolor="" valign="center">
  <tr valign="top" bgcolor="#eeeef8">
    <td valign=center align=left>
     <a href="http://sourceforge.net">
      <img src="http://sourceforge.net/sflogo.php?group_id=17919" border="0" alt="SourceForge Logo">
     </a>
    </td>
  </tr>
  <tr>
   <td bgcolor="#543a48" colspan=2>
    <img src="http://sourceforge.net/images/blank.gif" height=2 vspace=0>
   </td>
  </tr>
</table>
<!-- end top title table -->)

<< `content :div 
intro
download
releases
project-page
\ roadmap
tracker
lists
docs
cvs
rufig
footer
>>
;

index BYE

\ http://fforum.winglion.ru//viewtopic.php?p=4398#4398
\ Усложнённый на ровном месте вариант tools/nsis/spf_cvs.f

REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE split ~profit/lib/bac4th-str.f
\ REQUIRE DBG{ ~profit/lib/debug.f

: SPF-PATH S" c:\lang\spf" ;

: DOUBLE-SLASHES  ( addr u -- addr u ) concat{ [CHAR] \
byChar split DUP STR@ [CHAR] / byChar split DUP STR@ *> <*> S" \\" <* }concat DUP STR@ ;

: r SPF-PATH DOUBLE-SLASHES TYPE ;

: EXCEPTIONS  ( --> addr u ) PRO *>
" {SPF-PATH}/spf4.exe"          <*>
" {SPF-PATH}/jpf375c.exe"       <*>
" {SPF-PATH}/spf4.ini"          <*>
" {SPF-PATH}/help.fhlp"         <*>
" {SPF-PATH}/uninstall.exe"     <* STR@ CONT ;

: DIRS ( --> addr u ) PRO *>
" {SPF-PATH}/devel/*"    <*>
" {SPF-PATH}/docs/*"     <*>
" {SPF-PATH}/lib/*"      <*>
" {SPF-PATH}/samples/*"  <*>
" {SPF-PATH}/src/*"      <* STR@ CONT ;

: EXCLUDE ( --> addr u ) PRO *>
" *.log"                    <*>
" */CVS/*"                  <*>
" *.old"                    <*>
" *.rar"                    <*>
" *.bak"                    <*>
" *.svn"                    <*>
" *.7z"                     <*>
" *.zip"                    <*>
" *.RAR"                    <*>
" *Entries.Log"             <*>
" *.pid"                    <*>
" *-setup.exe"              <*>
" *spf_cvs.f"               <*>
" *make_spf_distr.bat"      <*>
" *co.bat"                  <*>
" *.md"                     <*>
" *Makefile"                <*>
" {SPF-PATH}/docs/*.md.css" <* STR@ CONT ;

: FILTER ( addr u <--> addr u ) PRO \ на входе: строка-имя файла, в зависимости от условий делает или не делает успех
CUT:
 *> EXCEPTIONS 2OVER 2SWAP COMPARE-U 0= ONTRUE
<*> DIRS 2OVER 2SWAP COMPARE-U 0= ONTRUE  NOT: EXCLUDE 2OVER 2OVER COMPARE-U 0= ONTRUE -NOT <* -CUT CONT ;
: FILTER ( addr u <--> addr u ) PRO \ на входе: строка-имя файла, в зависимости от условий делает или не делает успех
CR 2DUP TYPE
CUT: EXCEPTIONS 2OVER 2SWAP COMPARE-U 0= ONTRUE -CUT DEPTH ." =" . ." ="  CONT ." !" ;



: DISTR ( addr u --> filea fileu ) PRO 1 ITERATE-FILES ( filea fileu data flag ) 2DROP FILTER CONT 2DROP ;

: r START{ S" c:\lang\spf" DISTR CR 2DUP TYPE }EMERGE CR ." ------------" ;
r
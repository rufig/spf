WARNING 0!

REQUIRE FIND-FILES-R       ~ac/lib/win/file/findfile-r.f
REQUIRE ONFALSE ~profit/lib/bac4th.f
REQUIRE LIKE ~pinka/lib/like.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f

\ : SPF-PATH S" spf" ;
: SPF-PATH-LEN SPF-PATH NIP 1+ ;

: double-slashed  ( a u -- s )  " {s}" DUP " \" " \\" replace-str- ;

SPF-PATH double-slashed VALUE path\\

: SPF-PATH-\\ path\\ STR@ ;

REQUIRE DateM>S ~ac/lib/win/date/date-int.f

: MyDate# { d m y } y #N [CHAR] . HOLD m DateM>S HOLDS [CHAR] . HOLD d #N## ;
: MY_DATE 0 0 <# TIME&DATE MyDate# DROP DROP DROP #> ;

: PROD_NAME    S" {PROD_NAME}" ;
: PROD_FILE    S" {PROD_FILE}" ;
: PROD_VENDOR  S" {PROD_VENDOR}" ;
: PROD_ICON    S" {PROD_ICON}" ;
: VER_MAJOR    S" {VER_MAJOR}" ;
: VER_MINOR    S" {VER_MINOR}" ;

: VER_DATE     S" {VER_DATE}" ;
: MUI_ICON     S" {MUI_ICON}" ;
: INSTDIR      S" {INSTDIR}" ;
: LANG_ENGLISH S" {LANG_ENGLISH}" ;
: LANG_RUSSIAN S" {LANG_RUSSIAN}" ;

: Switch       S" {Switch}" ;
: Case         S" {Case}" ;
: Break        S" {Break}" ;
: EndSwitch    S" {EndSwitch}" ;
: WM_SETTEXT   S" {WM_SETTEXT}" ;
: stSTAT       S" {stSTAT}" ;

: SecSPF       S" {SecSPF}" ;
: SecUnRegVal  S" {SecUnRegVal}" ;
: SecStartMenu S" {SecStartMenu}" ;
: SecDesktop   S" {SecDesktop}" ;
: SecAssociate S" {SecAssociate}" ;

\ подготовить данные для NSIS
: />\ ( addr u -- )
  0 ?DO DUP I + C@ [CHAR] / = IF [CHAR] \ OVER I + C! THEN LOOP DROP
;


: FILTER
  PREDICATE
  2DUP S" *.log" ULIKE ONFALSE
  2DUP S" *\\CVS\\*" ULIKE ONFALSE
  2DUP S" *.old" ULIKE ONFALSE
  2DUP S" *.rar" ULIKE ONFALSE
  2DUP S" *.bak" ULIKE ONFALSE
  2DUP S" *.svn" ULIKE ONFALSE
  2DUP S" *.7z" ULIKE ONFALSE
  2DUP S" *.zip" ULIKE ONFALSE
  2DUP S" *.RAR" ULIKE ONFALSE
  2DUP S" *Entries.Log" ULIKE ONFALSE
  2DUP S" *.pid" ULIKE ONFALSE
  2DUP S" *-setup.exe" ULIKE ONFALSE
  2DUP S" *spf_cvs.f" ULIKE ONFALSE
  2DUP S" *make_spf_distr.bat" ULIKE ONFALSE
  2DUP S" *co.bat" ULIKE ONFALSE
  2DUP S" *.md" ULIKE ONFALSE
  2DUP S" *Makefile" ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\ac-lib3\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\spf3-src\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\linux\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\CVSROOT\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\spf4root\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\tools\\*" STR@ ULIKE ONFALSE
  2DUP " {SPF-PATH-\\}\\docs\\*.md.css" STR@ ULIKE ONFALSE
  SUCCEEDS
;

: TT
  NIP
  IF 2DROP EXIT THEN

  2DUP />\
  FILTER 0= IF 2DROP EXIT THEN

  2DUP " {s}" STR@
  OVER >R +
  BEGIN
    1- DUP C@ [CHAR] \ = OVER R@ = OR
    IF 0 SWAP 1+ C! TRUE ELSE FALSE THEN
  UNTIL 
  R> ASCIIZ>
  SPF-PATH-LEN - SWAP SPF-PATH-LEN + SWAP
  1- 0 MAX
  ?DUP
  IF
    "  SetOutPath $INSTDIR\{s}" STYPE CR
  ELSE
    DROP "  SetOutPath $INSTDIR" STYPE CR
  THEN
  "  File {''}{s}{''}" STYPE CR
;

: INI S" {INI}" ;

: T SPF-PATH ['] TT FIND-FILES-R ;

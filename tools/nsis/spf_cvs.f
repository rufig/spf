REQUIRE FIND-FILES-R       ~ac/lib/win/file/findfile-r.f

: SPF-PATH S" spf" ;
: SPF-PATH-LEN SPF-PATH NIP 1+ ;

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

\ подготовить данные для NSIS
: />\ ( addr u -- )
  0 ?DO DUP I + C@ [CHAR] / = IF [CHAR] \ OVER I + C! THEN LOOP DROP
;
: TT
  NIP
  IF 2DROP EXIT THEN

  TRUE >R
  2DUP S" .log" SEARCH NIP NIP 0= R> AND >R
  2DUP S" /CVS/" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .old" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .rar" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .bak" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .svn" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .7z" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .zip" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .RAR" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .ZIP" SEARCH NIP NIP 0= R> AND >R
  2DUP S" Entries.Log" SEARCH NIP NIP 0= R> AND >R
  2DUP S" .pid" SEARCH NIP NIP 0= R> AND >R
  2DUP S" -setup.exe" SEARCH NIP NIP 0= R> AND >R
  2DUP S" spf_cvs.f" SEARCH NIP NIP 0= R> AND >R
  2DUP S" make_spf_distr.bat" SEARCH NIP NIP 0= R> AND >R
  2DUP S" co.bat" SEARCH NIP NIP 0= R> AND >R

  R>
  0= IF 2DROP EXIT THEN

  2DUP />\
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

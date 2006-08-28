REQUIRE WildCMP-U ~pinka/lib/mask.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE FIND-FILES-R ~ac/lib/win/file/findfile-r.f

0 VALUE aPath

MODULE: filelist

0 [IF]

S" ~ac/lib/ns/files.f" INCLUDED

: ForEachWRstr { str xt wid \ s -- }
\ xt: ( str item wid -- )
\ перебрать рекурсивно все словари, передавая в xt полный путь к словарю (str)
\ xt вызывается только для конечных листьев(файлов), а не узлов(каталогов)
  wid CAR
  BEGIN
    DUP
  WHILE
    DUP wid W?VOC
    IF 
       DUP wid WNAME str STR@ ?DUP IF " {s}/{s}" ELSE DROP " {s}" THEN -> s
       DUP s xt ROT wid ITEM>WID RECURSE
    ELSE
       DUP wid WNAME str STR@ ?DUP IF " {s}/{s}" ELSE DROP " {s}" THEN -> s
       DUP s SWAP wid xt EXECUTE s STRFREE
    THEN
    wid WCDR
  REPEAT DROP ;
[THEN]

REQUIRE AddNode ~ac/lib/list/STR_LIST.f
REQUIRE SGENRAND ~ygrek/lib/neilbawd/mersenne.f

VARIABLE ListSize
VARIABLE List
0 List !

VARIABLE temp
: ForEachWildMatch ( a u -- ) "" DUP >R STR+ R> List AddNode ;
: (ForEachStr)  NIP IF 2DROP EXIT THEN \ directory
    2DUP S" *.f" WildCMP-U 0= IF ForEachWildMatch ELSE 2DROP THEN ;

: getFileNames
    aPath ASCIIZ> ['] (ForEachStr) FIND-FILES-R ;

: incer CREATE , DOES> @ 1+! ;
ListSize incer ListIncer

: ListTyper NodeValue STR@ TYPE CR ;

0 VALUE N2go
0 VALUE str
: ListSelect
  str IF DROP EXIT THEN
  N2go 0= IF NodeValue TO str EXIT THEN
  DROP
  N2go 1- TO N2go ;

: ListGet ( n list -- str )
    SWAP
    TO N2go
    0 TO str
    ['] ListSelect SWAP DoList 
    str ;

WINAPI: GetTickCount kernel32.dll

EXPORT

: randomName
   ListSize @ GENRANDMAX List ListGet STR@ ; 

: names-init
   GetTickCount SGENRAND
   getFileNames
   LAMBDA{ DROP ListIncer } List DoList 
   ListSize @ 0= IF 
     aPath ASCIIZ> 
     " Bad path (no *.f files or doesnt exist..):{CRLF}{s}{CRLF}Tweak settings." 
     STR@ ShowMessage BYE 
   THEN ;

;MODULE


REQUIRE HYPE ~day\hype3\hype3.f

WINAPI: GetOpenFileNameA COMDLG32.DLL
WINAPI: GetSaveFileNameA COMDLG32.DLL

260 CONSTANT MAX_PATH

CLASS COpenFileDialog

OBJ-SIZE
          0 DEFS addr
          VAR lStructSize
          VAR hwndOwner  
          VAR hInstance
          VAR lpstrFilter
          VAR lpstrCustomFilter
          VAR nMaxCustFilter
          VAR nFilterIndex
          VAR lpstrFile
          VAR nMaxFile
          VAR lpstrFileTitle
          VAR nMaxFileTitle
          VAR lpstrInitialDir
          VAR lpstrTitle
          VAR Flags
          2 DEFS nFileOffset
          2 DEFS nFileExtension
          VAR lpstrDefExt
          VAR lCustData
          VAR lpfnHook
          VAR lpTemplateName

OBJ-SIZE SWAP - CONSTANT /OFStruct

init:
    MAX_PATH 1+ ALLOCATE THROW lpstrFile !
    MAX_PATH nMaxFile !
    /OFStruct lStructSize !
;

dispose:
    lpstrFile @ FREE THROW
;

: showModal ( parent-obj -- f )
    ?DUP IF ^ checkWindow hwndOwner ! THEN
    addr GetOpenFileNameA
;

0 VALUE FMarker

: EXT" ( "name" -- )
   [CHAR] " PARSE
   HERE OVER ALLOT
   SWAP CMOVE 0 C,
;

: NAME" ( -- )
   FMarker @ 0= IF HERE FMarker ! THEN
   EXT"
;

: setFilter ( filter -- )
   lpstrFilter !
;

: fileName ( -- addr u -1 | 0 )
   lpstrFile @ DUP
   IF
     ASCIIZ> -1
   THEN
;

: setTitle ( addr u )
   DROP lpstrTitle !
;

;CLASS

COpenFileDialog SUBCLASS CSaveFileDialog

: showModal ( parent-obj -- f )
    ?DUP IF ^ checkWindow SUPER hwndOwner ! THEN
    SUPER addr GetSaveFileNameA
;


;CLASS

COpenFileDialog ^ also

: FILTER:
    CREATE 
       HERE TO FMarker 0 ,
       COpenFileDialog ^ also
    DOES> @
;

: ;FILTER
   PREVIOUS
   0 C,
;

PREVIOUS

\EOF

FILTER: fTest

  NAME" all files" EXT" *.*"
  NAME" exe files" EXT" *.exe"

;FILTER


COpenFileDialog NEW of 
fTest of setFilter
of showModal DROP 
of fileName DROP TYPE
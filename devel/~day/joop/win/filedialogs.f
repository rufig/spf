REQUIRE Object ~day\joop\oop.f

260 CONSTANT max-path
2   CONSTANT short

WINAPI: GetOpenFileNameA COMDLG32.DLL
WINAPI: GetSaveFileNameA COMDLG32.DLL

<< :execute
<< :setFilter
<< :fileName
<< :setTitle

CLASS: OpenDialog <SUPER Object

      RECORD:  OFStruct
          CELL VAR   lStructSize
          CELL VAR   hwndOwner  
          CELL VAR   hInstance
          CELL VAR   lpstrFilter
          CELL VAR   lpstrCustomFilter
          CELL VAR   nMaxCustFilter
          CELL VAR   nFilterIndex
      max-path ARR   lpstrFile   \ указатель на динамический массив!
          CELL VAR   nMaxFile
          CELL VAR   lpstrFileTitle
          CELL VAR   nMaxFileTitle
          CELL VAR   lpstrInitialDir
          CELL VAR   lpstrTitle
          CELL VAR   Flags
         short VAR   nFileOffset
         short VAR   nFileExtension
          CELL VAR   lpstrDefExt
          CELL VAR   lCustData
          CELL VAR   lpfnHook
          CELL VAR   lpTemplateName
        /REC

: :new
    own :new 
    max-path nMaxFile !
    size: OFStruct lStructSize !
;
          
: :execute ( -- bool )
    OFStruct GetOpenFileNameA
;    

: :setFilter ( addr -- )
    lpstrFilter !
;

: :fileName ( -- addr u )
    lpstrFile ASCIIZ>
;

: :setTitle ( addr u -- )
   DROP lpstrTitle !
;

;CLASS  


CLASS: SaveDialog <SUPER OpenDialog

: :execute
   OFStruct GetSaveFileNameA 
;

;CLASS


0 VALUE FMarker
VOCABULARY VOC-FILTER

: FILTER:
    CREATE 
       ALSO VOC-FILTER
       HERE TO FMarker 0 ,
    DOES> @
;

GET-CURRENT
ALSO VOC-FILTER DEFINITIONS

: EXT" ( "name" -- )
   [CHAR] " PARSE
   HERE OVER ALLOT
   SWAP CMOVE 0 C,
;

: NAME" ( -- )
   FMarker @ 0= IF HERE FMarker ! THEN
   EXT"
;

: ;FILTER
   0 C,
   PREVIOUS
;

SET-CURRENT PREVIOUS

REQUIRE CLASS: ~day\mc\microclass.f

260 CONSTANT MAX_PATH
2 CONSTANT WIDE

CLASS: OpenDialog
        0
          CELL FIELD lStructSize
          CELL FIELD hwndOwner  
          CELL FIELD hInstance
          CELL FIELD lpstrFilter
          CELL FIELD lpstrCustomFilter
          CELL FIELD nMaxCustFilter
          CELL FIELD nFilterIndex
          CELL FIELD lpstrFile
          CELL FIELD nMaxFile
          CELL FIELD lpstrFileTitle
          CELL FIELD nMaxFileTitle
          CELL FIELD lpstrInitialDir
          CELL FIELD lpstrTitle
          CELL FIELD Flags
          WIDE FIELD nFileOffset
          WIDE FIELD nFileExtension
          CELL FIELD lpstrDefExt
          CELL FIELD lCustData
          CELL FIELD lpfnHook
          CELL FIELD lpTemplateName

          DUP CONSTANT /OFStruct
        
          260 FIELD lpstrFile2 \ Выделим автоматически вместе со структурой
       CONSTANT /OpenDialog

WINAPI: GetOpenFileNameA COMDLG32.DLL
WINAPI: GetSaveFileNameA COMDLG32.DLL
 
M: INIT ( -- self )
     lpstrFile2
     lpstrFile !
     MAX_PATH nMaxFile !
     /OFStruct lStructSize !
     self
;

M: Execute ( -- bool )
     self GetOpenFileNameA
;    

M: SetFilter ( addr -- )
    lpstrFilter !
;

M: FileName ( -- addr u -1 | 0 )
    lpstrFile @ DUP
    IF
       ASCIIZ> -1
    THEN
;

M: SetTitle ( addr u self -- )
    DROP lpstrTitle !
;

0 VALUE FMarker

: FILTER:
    CREATE 
       HERE TO FMarker 0 ,
    DOES> @
;


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
;

;CLASS  


WITH OpenDialog CHILD:  SaveDialog

   /OpenDialog CONSTANT /SaveDialog
        
: Execute
    GetSaveFileNameA 
;


;CLASS


 \ Sample

WITH SaveDialog /SaveDialog OBJECT VALUE tt

FILTER: fTest

  NAME" all files" EXT" *.*"
  NAME" exe files" EXT" *.exe"

;FILTER

fTest tt SetFilter
tt Execute DROP
tt FileName  DROP TYPE

ENDWITH
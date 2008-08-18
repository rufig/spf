REQUIRE CLASS: ~nn/class/class.f
REQUIRE Control ~nn/lib/win/control.f
REQUIRE ?FREE ~nn/lib/free.f
WINAPI: SHBrowseForFolder SHELL32.DLL
WINAPI: SHGetPathFromIDList SHELL32.DLL
\ WINSHELLAPI LPITEMIDLIST WINAPI SHBrowseForFolder(
\     LPBROWSEINFO lpbi
\ ); 

CLASS: ChooseDirDialog
    RECORD:  BROWSEINFO
        var hwndOwner       \ HWND hwndOwner; 
        var pidlRoot        \ LPCITEMIDLIST pidlRoot; 
        var pszDisplayName  \ LPSTR pszDisplayName; 
        var lpszTitle       \ LPCSTR lpszTitle; 
        var ulFlags         \ UINT ulFlags; 
        var lpfn            \ BFFCALLBACK lpfn; 
        var lParam          \ LPARAM lParam; 
        var iImage          \ int iImage; 
    ;RECORD /BROWSEINFO
    var _path \ Добавил Абдрахимов И.А.
    var vPIDL
CONSTR: init
    MAX_PATH ALLOCATE THROW pszDisplayName !
    BIF_RETURNONLYFSDIRS ulFlags !
    MAX_PATH ALLOCATE THROW _path !
;
DESTR: free pszDisplayName @ ?FREE lpszTitle @ ?FREE _path @ ?FREE ;
M: SetTitle ( a u -- ) S>ZALLOC lpszTitle ! ;
M: Execute ( -- ?)
    WITH Control InitCommonControls ENDWITH
    BROWSEINFO SHBrowseForFolder DUP vPIDL ! 0<>
    
;
M: GetPath  _path @ vPIDL @ ( DUP W@ SWAP 2+ SWAP) SHGetPathFromIDList DROP _path @ ASCIIZ> ;

;CLASS

\EOF
ChooseDirDialog POINTER cdd
: test
    ChooseDirDialog NEW TO cdd
    S" test" cdd SetTitle
    cdd Execute .
    cdd vPIDL @ 100 DUMP
    cdd GetPath CR TYPE
;
test

( Спасибо 1001bytes за обращение моего внимания на этот пример в w32f

  Пример из справки из раздела ООП к Win32Forth 4.1.
)
REQUIRE { lib\ext\locals.f
REQUIRE CLASS: ~day\mc\microclass.f


260 CONSTANT MAX_PATH
8 CONSTANT QWORD

  CLASS: DirObject
         0
            CELL FIELD dwFileAttributes
           QWORD FIELD ftCreationTime
           QWORD FIELD ftLastAccessTime
           QWORD FIELD ftLastWriteTime
            CELL FIELD nFileSizeHigh
            CELL FIELD nFileSizeLow
            CELL FIELD dwReserved0
            CELL FIELD dwReserved1
        MAX_PATH FIELD cFileName
              14 FIELD cAlternateFileName
              
            DUP CONSTANT /FIND_DATA    
            
            CELL FIELD vFindHandle
        CONSTANT /DirObject

WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL
            
  M: INIT ( -- self )                  \ init the structure
                -1 vFindHandle !
                self
  ;

  M: FindFirst { addr len -- f }    \ f1=TRUE if found file
                self addr FindFirstFileA DUP
                vFindHandle !
                ;

  M: FindNext  ( - f)
                self vFindHandle @
                FindNextFileA
                ;


  M: CloseFind ( - f)        \ завершить поиски
                vFindHandle @
                FindClose 0=
                -1 vFindHandle !
                ;

  M: ShowFile  ( -- )          \ показать последний найденный
                cFileName ASCIIZ> TYPE
                ;

  M: FileName cFileName ASCIIZ> ;

  M: DISPOSE
     CloseFind DROP
  ;
                          
  ;CLASS


  WITH DirObject  /DirObject OBJECT VALUE aFile
      \ делать объект класса DirObject

  : SIMPLEDIR ( FIELD )
        S" c:\*" aFile FindFirst
        IF      BEGIN   CR  aFile ShowFile 
                        aFile  FindNext 0=
                UNTIL   CR 
                aFile CloseFind DROP
        THEN
  ;
  
  ENDWITH




SIMPLEDIR


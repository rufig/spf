( Спасибо 1001bytes за обращение моего внимания на этот пример в w32f

  Пример из справки из раздела ООП к Win32Forth 4.1.
  + Позволяет искать по аттрибутам
)


REQUIRE Object ~day\joop\oop.f

260 CONSTANT max-path

WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL

<< :fileName
<< :showFile
<< :findClose
<< :findNext
<< :findFirst
<< :getAttr

  CLASS: DirObject <SUPER Object

        RECORD: FIND_DATA       \ returns the address of the structure

            CELL VAR dwFileAttributes
               8 VAR ftCreationTime
               8 VAR ftLastAccessTime
               8 VAR ftLastWriteTime
            CELL VAR nFileSizeHigh
            CELL VAR nFileSizeLow
            CELL VAR dwReserved0
            CELL VAR dwReserved1
        max-path VAR cFileName
              14 VAR cAlternateFileName

        /REC

            CELL VAR vFindHandle
            CELL VAR vAttr

  : :new
     own :new
     -1 vFindHandle !
  ;

  : :getAttr ( -- u)
      dwFileAttributes @
  ;
              
  : :findFirst ( addr len -- f )    \ f1=TRUE if found file
                DROP
                FIND_DATA SWAP
                FindFirstFileA DUP
                vFindHandle !
                ;

  : :fileName cFileName ASCIIZ> ;                
  
  : :findNext  ( -- f )
                FIND_DATA
                vFindHandle @
                FindNextFileA
                ;


  : :findClose ( -- f )        \ завершить поиски
                vFindHandle @
                FindClose 0=
                -1 vFindHandle !
                ;

  : :showFile  ( -- )          \ показать последний найденный
                cFileName ASCIIZ> TYPE
                ;

  : :free
      own :findClose DROP
      own :free
  ;

  ;CLASS

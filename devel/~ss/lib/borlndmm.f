\ Подключение менеджера памяти borlndmm.dll из поставки Borland Delphi 
\ Пример подключения:
\ MODULE: MM
\ S" ~ss/lib/borlndmm.f" INCLUDED
\ ;MODULE
\

:NONAME ." borlndmm.dll not found" ; ->VECT MM_NOTFOUND
0 VALUE borlndmm.dll
VECT SysGetMem ( u -- addr )
VECT SysFreeMem ( addr -- * )
VECT SysReallocMem ( addr1 -- addr2 ) \ edx:=u
VECT GetAllocMemSize ( * -- u )
VECT GetAllocMemCount ( * -- n )  

: LoadDelphiMM
  S" borlndmm.dll" DROP LoadLibraryA TO borlndmm.dll
  borlndmm.dll 0= IF MM_NOTFOUND BYE THEN
  S" @Borlndmm@SysGetMem$qqri" DROP borlndmm.dll GetProcAddress TO SysGetMem
  S" @Borlndmm@SysFreeMem$qqrpv" DROP borlndmm.dll GetProcAddress TO SysFreeMem
  S" @Borlndmm@SysReallocMem$qqrpvi" DROP borlndmm.dll GetProcAddress TO SysReallocMem
  S" GetAllocMemSize" DROP borlndmm.dll GetProcAddress TO GetAllocMemSize
  S" GetAllocMemCount" DROP borlndmm.dll GetProcAddress TO GetAllocMemCount
;

LoadDelphiMM
..: AT-PROCESS-STARTING LoadDelphiMM ;..
: ALLOCATE  
  DUP
  \ push ...                      pop ...
  [ 0x53 C, 0x57 C, ] SysGetMem [ 0x5F C, 0x5B C, ] 
  DUP IF DUP ROT ERASE 0 ELSE -300 THEN 
;
: FREE [ 0x53 C, 0x57 C, ]  SysFreeMem [ 0x5F C, 0x5B C, ] DROP 0  ;
: RESIZE  [ 0x8B C, 0xD0 C,  ( MOV EDX,EAX) ] DROP  [ 0x53 C, 0x57 C, ] SysReallocMem [ 0x5F C, 0x5B C, ] 0 ;

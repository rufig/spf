\ На заре SPF3 (95-96гг) шаблон PE-заголовка spf брал не из себя самого,
\ а из отдельного файла spf-stub.exe.
\ Здесь программа генерации этого spf-stub по состоянию на апрель 1996г.
\ Только закомментирована запись "SP-Forth 3.0" в конце RVA/Sizes заголовка,
\ чтобы работало и в текущих версиях Windows.
\ Структура заголовка пригодилась в связи с добавлением секции экспорта
\ в SPF4, поэтому и этот файл решил положить в lib в качестве справки.

S" LIB\EXT\SPF-ASM.F" INCLUDED
HEX

\ структура PE-HEADER
 0
 4 -- Signature \ PE/0/0
 2 -- CPUtype   \ 14Ch - 386
 2 -- #Objects
 4 -- TimeDateStamp
 4 -- Res1
 4 -- Res2
 2 -- NTHDRsize
 2 -- Flags
 2 -- Magic
 1 -- LMAJOR
 1 -- LMINOR
 4 -- SizeOfCode
 4 -- SizeOfInitializedData
 4 -- SizeOfUninitializedData
 4 -- EntryPointRVA
 4 -- BaseOfCode
 4 -- BaseOfData
 4 -- ImageBase
 4 -- ObjectAlign
 4 -- FileAlign
 2 -- OSMajor
 2 -- OSMinor
 2 -- UserMajor
 2 -- UserMinor
 2 -- SubsysMajor
 2 -- SubsysMinor
 4 -- Res9
 4 -- ImageSize
 4 -- HeaderSize
 4 -- FileChecksum
 2 -- Subsystem
 2 -- DLLFlags
 4 -- StackReserve
 4 -- StackCommitSize
 4 -- HeapReserveSize
 4 -- HeapCommitSize
 4 -- Res10
 4 -- #InterestingRVA/Sizes
 4 -- ExportTableRVA
 4 -- TotalExportDataSize
 4 -- ImportTableRVA
 4 -- TotalImportDataSize
 4 -- ResourceTableRVA
 4 -- TotalResourceDataSize
 4 -- ExceptionTableRVA
 4 -- TotalExceptionDataSize
 4 -- SecurityTableRVA
 4 -- TotalSecurityDataSize
 4 -- FixupTableRVA
 4 -- TotalFixupDataSize
 4 -- DebugTableRVA
 4 -- TotalDebugDataSize
 4 -- ImageDescriptionRVA
 4 -- TotalDescriptionSize
 4 -- MachineSpecificRVA
 4 -- MachineSpecificSize
 4 -- ThreadLocalStorageRVA
 4 -- TotalTLSSize
CONSTANT /PE-HEADER

\ структура - таблица объектов (идёт вслед за PE-header)
 0
 8 -- OT.ObjectName        \ CODE\0\0\0\0
 4 -- OT.VirtualSize       \ сколько памяти отводится объекту при загруке
 4 -- OT.RVA               \ относительный виртуальный адрес
 4 -- OT.PhisicalSize      \ физический размер объекта в файле
 4 -- OT.PhisicalOffset    \ смещение в exe-файле
 4 -- OT.Res1              \ pointer to relocations
 4 -- OT.Res2              \ pointer to line numbers
 2 -- OT.Res3              \ number of relocations
 2 -- OT.Res4              \ number of line numbers
 4 -- OT.ObjectFlags       \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
CONSTANT /ObjectTable


\ Структура записей в каталоге импорта .idata (опытным путем)
0
4 -- ID.ImportLookupTableRVA  \ указатель на таблицу адресов имён имп.процедур
4 -- ID.TimeDateStamp
2 -- ID.MajorVersion
2 -- ID.MinorVersion
4 -- ID.NameRVA               \ указатель на имя DLL
4 -- ID.ImportAddressTableRVA \ указатель на таблицу адресов процедур
CONSTANT /ImportDirectory

\ -------------------------- пример ---------------------------------

CREATE ImportDirectory
       HERE /ImportDirectory 2 * DUP ALLOT ERASE

       HERE ImportDirectory - 1000 + ImportDirectory ID.ImportLookupTableRVA !
       0 , \ addr of "LoadLibrary" (OFFSET = 34H)
       0 , \ addr of "GetProcAddress" (OFFSET = 38H)
       0 ,

       HERE ImportDirectory - 1000 + ImportDirectory ID.ImportAddressTableRVA !
       0 , 0 , 0 ,

       HERE 101 W, S" GetProcAddress" HERE SWAP DUP ALLOT MOVE 0 C, 0 C,
       ImportDirectory - 1000 + DUP ImportDirectory /ImportDirectory DUP + + CELL+ !
       ImportDirectory /ImportDirectory DUP + + CELL+ 3 CELLS + !

       HERE 16D W, S" LoadLibraryA" HERE SWAP DUP ALLOT MOVE 0 C, 0 C,
       ImportDirectory - 1000 + DUP ImportDirectory /ImportDirectory DUP + + !
       ImportDirectory /ImportDirectory DUP + + 3 CELLS + !

       HERE S" KERNEL32.dll" HERE SWAP DUP ALLOT MOVE 0 C, 0 C,
       ImportDirectory - 1000 + ImportDirectory ID.NameRVA !

HERE ImportDirectory - CONSTANT /ID-SIZE


0 VALUE PE-HEADER
CREATE EXE-HEADER

\ DOS-HEADER

       CHAR M C, CHAR Z C, 30090 , 40000 , FFFF0000 , B80000 , 0 , 400000 ,
       HERE 22 DUP ALLOT ERASE
       80 , 0EBA1F0E , CD09B400 , 4C01B821 , 0CD C, 21 C,
       S" This program cannot be run in DOS mode" HERE SWAP DUP ALLOT MOVE
       0A0D0D2E , 24 , 0 ,

\ --------------------------------------------------------
HERE TO PE-HEADER
HERE /PE-HEADER DUP ALLOT ERASE

    S" PE" PE-HEADER Signature SWAP MOVE
      014C PE-HEADER CPUtype       W!
         2 PE-HEADER #Objects      W!
  311CBDC5 PE-HEADER TimeDateStamp !
       10E PE-HEADER Flags         W!
       10B PE-HEADER Magic         W!
        02 PE-HEADER LMAJOR        C!
        37 PE-HEADER LMINOR        C!
      \ SIZEOFCODE
      \ SIZEOFDATA
      \ SIZEOFINITDATA
  2000 PE-HEADER EntryPointRVA !
      \ BASEOFCODE
      \ BASEOFDATA
400000 PE-HEADER ImageBase     !
      1000 PE-HEADER ObjectAlign   !
       200 PE-HEADER FileAlign     !
         1 PE-HEADER OSMajor       W!
      \ IMAGEVERSION
         4 PE-HEADER SubsysMajor   W!
      3000 PE-HEADER ImageSize     !
       200 PE-HEADER HeaderSize    !
         2 PE-HEADER Subsystem     W!            \ 2-GUI, 3-Character
    100000 PE-HEADER StackReserve  !
      8000 PE-HEADER StackCommitSize !
    100000 PE-HEADER HeapReserveSize !
      1000 PE-HEADER HeapCommitSize !
        10 PE-HEADER #InterestingRVA/Sizes !
      1000 PE-HEADER ImportTableRVA !
  /ID-SIZE PE-HEADER TotalImportDataSize !

HERE /ObjectTable 8 + DUP ALLOT ERASE  \ без этого не работает

\ S" SP-Forth 3.0 (C) Cherezov A." HERE OVER - SWAP MOVE
\ начиная с Win2000 эти адреса использутся :)

HERE PE-HEADER -  18 -  PE-HEADER NTHDRsize W!
\ 18 =  0 Magic, т.е. смещение начала опционального заголовка

\ --------------------------------------------------------

HERE DUP /ObjectTable DUP ALLOT ERASE DUP S" .idata" ROT OT.ObjectName SWAP MOVE       \ CODE\0\0\0\0
/ID-SIZE OVER OT.VirtualSize !      \ сколько памяти отводится объекту при загруке
 1000 OVER OT.RVA !              \ относительный виртуальный адрес
  200 OVER OT.PhisicalSize !     \
  200 OVER OT.PhisicalOffset !   \ смещение в exe-файле
 C0000040 OVER OT.ObjectFlags !  \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
DROP

HERE DUP /ObjectTable DUP ALLOT ERASE DUP S" .text" ROT OT.ObjectName SWAP MOVE       \ CODE\0\0\0\0
 1000 OVER OT.VirtualSize !      \ сколько памяти отводится объекту при загруке
 2000 OVER OT.RVA !              \ относительный виртуальный адрес
  200 OVER OT.PhisicalSize !     \
  400 OVER OT.PhisicalOffset !   \ смещение в exe-файле
 E0000060 OVER OT.ObjectFlags !  \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
OT.VirtualSize

HERE EXE-HEADER - CONSTANT /EXE-HEADER
\ -----------------
VARIABLE ADDROFUSER32       \ временные переменные (нужны для ручной сборки модуля)
VARIABLE ADDROFMESSAGEBOX
VARIABLE ADDROFOK
VARIABLE ADDROFALL

HERE

ALSO ASSEMBLER
INIT-ASM
    MOV  EAX , 401034        \ addr of LoadLibrary

    PUSH # 100000       \ Z" USER32.DLL"
     A; HERE 4 - ADDROFUSER32 !
 
    CALL EAX                  \ HINST of USER32
 
    PUSH # 200000       \ Z" MessageBoxA"
     A; HERE 4 - ADDROFMESSAGEBOX !
 
    PUSH EAX                  \ HINST of USER32
    MOV  EAX , 401038             \ addr of GetProcAddress
    CALL EAX 

    PUSH # 0
    PUSH # 300000       \ Z" OK"
     A; HERE 4 - ADDROFOK !
    PUSH # 400000       \ Z" Всё работает!"
     A; HERE 4 - ADDROFALL !
    PUSH # 0

    CALL EAX                  \ CALL MessageBoxA
    RET
END-ASM PREVIOUS

HEX
HERE OVER - 402000 +  ADDROFUSER32 @ !     S" USER32.DLL"    HERE SWAP DUP ALLOT MOVE 0 C,
HERE OVER - 402000 +  ADDROFMESSAGEBOX @ ! S" MessageBoxA"   HERE SWAP DUP ALLOT MOVE 0 C,
HERE OVER - 402000 +  ADDROFOK @ !         S" SPF-STUB"       HERE SWAP DUP ALLOT MOVE 0 C,
HERE OVER - 402000 +  ADDROFALL @ !        S" Это шаблон EXE-файла формата PE," HERE SWAP DUP ALLOT MOVE 0D C,
                                           S" используемый СП-Фортом 3.07 для"   HERE SWAP DUP ALLOT MOVE 0D C,
                                           S" формирования выполнимых файлов."  HERE SWAP DUP ALLOT MOVE 0D C, 0D C,
                                           S" Copyright (C) 1995-96 Черезов А.Ю." HERE SWAP DUP ALLOT MOVE 0 C,

HERE CONSTANT TEST-MSG-END
     CONSTANT TEST-MSG-BEGIN
TEST-MSG-END TEST-MSG-BEGIN - SWAP !
\ ---------------------------------------------------------------------------------

HEX
: WRITE-EXE-HEADER
  >R
  EXE-HEADER /EXE-HEADER R@ WRITE-FILE THROW
  200 /EXE-HEADER - HERE OVER ERASE
  HERE SWAP R> WRITE-FILE THROW
;
: WRITE-ID
  >R
  ImportDirectory /ID-SIZE R@ WRITE-FILE THROW
  200 /ID-SIZE - HERE OVER ERASE
  HERE SWAP R> WRITE-FILE THROW
;
: WRITE-PROGRAM
  >R
  TEST-MSG-BEGIN TEST-MSG-END OVER -
  R@ WRITE-FILE THROW
  200 TEST-MSG-END TEST-MSG-BEGIN - -  HERE OVER ERASE
  HERE SWAP R> WRITE-FILE THROW
;
DECIMAL

: SAVE-PE ( addr u -- )
  R/W CREATE-FILE THROW >R
  R@ WRITE-EXE-HEADER
  R@ WRITE-ID
  R@ WRITE-PROGRAM
  R> CLOSE-FILE THROW
;
S" Spf-stub.exe" SAVE-PE

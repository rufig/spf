\ в exe файле:
\ 512 - заголовок
\ по 512 на каждую из секций
\ код

\ В памяти начиная с IMAGE-BASE
\ 4096  - ???
\ 4096 (1000h) - .idata \ импортируемые процедуры
\  N           - .text  \ собственно код

S" lib\EXT\SPF-ASM.F" INCLUDED
S" lib\win\const.f" INCLUDED

HEX


\ структура PE-HEADER
 0
 4 -- Signature \ PE/0/0
 2 -- CPUtype   \ 14Ch - 386
 2 -- NumberOfSections
 4 -- TimeDateStamp
 4 -- PointerToSymbolTable
 4 -- NumberOfSymbols
 2 -- NTHDRsize
 2 -- Flags
 
 \ Standart fields
 
 2 -- Magic
 1 -- MajorLinkedVersion
 1 -- MinorLinkedVersion
 4 -- SizeOfCode
 4 -- SizeOfInitializedData
 4 -- SizeOfUninitializedData
 4 -- AddresOfEntryPoint
 4 -- BaseOfCode
 4 -- BaseOfData
 
 \ NT Additional fields
 
 4 -- ImageBase
 4 -- SectionAlignment
 4 -- FileAlignment
 2 -- OSMajor
 2 -- OSMinor
 2 -- UserMajor
 2 -- UserMinor
 2 -- SubsysMajor
 2 -- SubsysMinor
 4 -- Reserved1
 4 -- ImageSize
 4 -- HeaderSize
 4 -- FileChecksum
 2 -- Subsystem
 2 -- DLLFlags
 4 -- StackReserve
 4 -- StackCommitSize
 4 -- HeapReserveSize
 4 -- HeapCommitSize
 4 -- LoaderFlags
 4 -- NumberOfRvaAndSizes
 
 \ IMAGE_DATA_DIRECTORY - всего 16 entries
 
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
 4 -- RelocationTableRVA
 4 -- TotalRelocationDataSize
 4 -- DebugTableRVA
 4 -- TotalDebugDataSize
 4 -- MachineValueTableRVA
 4 -- TotalMachineValueDataSize
 4 -- GlobalPtrTableRVA
 4 -- TotalGlobalPtrDataSize
 4 -- TLSTableRVA
 4 -- TotalTLSDataSize
 4 -- LoadConfigurationTableRVA
 4 -- TotalLoadConfigurationDataSize
 4 -- BoundImportTableRVA
 4 -- TotalBoundImportDataSize
 4 -- IATTableRVA
 4 -- TotalIATDataSize
 4 -- DelayImportTableRVA
 4 -- TotalDelayImportDataSize
  
 \ 14 описали, дальше просто ALLOT
 2 8 * -- ReservedSections
 
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

 0
 4 -- ED.ExportFlags       \ 0
 4 -- ED.TimeDateStamp     \ 0
 2 -- ED.MajorVersion      \ 0
 2 -- ED.MinorVersion      \ 0
 4 -- ED.NameRVA           \ 50032h DLL asciiz name
 4 -- ED.OrdinalBase       \ 1
 4 -- ED.NumberOfFunctions
 4 -- ED.NumberOfNames
 4 -- ED.AddressTableRVA   \ 50028h там 1006Eh = entry point of "__Get..."
 4 -- ED.NamePtrTableRVA   \ 5002Ch там 5003D, а в 5003D "__GetExceptDLLInfo"
 4 -- ED.OrdinalTableRVA   \ 50030h там 0000 = ordinal of "__Get..."
CONSTANT /ExportDirectory

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
         2 PE-HEADER NumberOfSections      W!
  311CBDC5 PE-HEADER TimeDateStamp !

IMAGE_FILE_32BIT_MACHINE  
IMAGE_FILE_DEBUG_STRIPPED      OR
IMAGE_FILE_EXECUTABLE_IMAGE    OR
IMAGE_FILE_LINE_NUMS_STRIPPED  OR
IMAGE_FILE_LOCAL_SYMS_STRIPPED OR
IMAGE_FILE_MACHINE_I386        OR
IMAGE_FILE_RELOCS_STRIPPED     OR  
           PE-HEADER Flags         W!
       10B PE-HEADER Magic         W!
        02 PE-HEADER MajorLinkedVersion        C!
        37 PE-HEADER MinorLinkedVersion        C!
      \ SIZEOFCODE
      \ SIZEOFDATA
      \ SIZEOFINITDATA
  2000 PE-HEADER AddresOfEntryPoint !
  2000 PE-HEADER BaseOfCode ! \ 2000 - RVA of directory .text
      \ BASEOFDATA
400000 PE-HEADER ImageBase     !
      1000 PE-HEADER SectionAlignment   !
       200 PE-HEADER FileAlignment     !
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
        10 PE-HEADER NumberOfRvaAndSizes !
      1000 PE-HEADER ImportTableRVA !
  /ID-SIZE PE-HEADER TotalImportDataSize !


HERE PE-HEADER -  18 -  PE-HEADER NTHDRsize W!

\ --------------------------------------------------------

HERE DUP /ObjectTable DUP ALLOT ERASE DUP S" .idata" ROT OT.ObjectName SWAP MOVE       \ CODE\0\0\0\0
 /ID-SIZE OVER OT.VirtualSize !      \ сколько памяти отводится объекту при загруке
 1000 OVER OT.RVA !              \ относительный виртуальный адрес
  200 OVER OT.PhisicalSize !     \
  200 OVER OT.PhisicalOffset !   \ смещение в exe-файле
\  IMAGE_SCN_CNT_INITIALIZED_DATA
  IMAGE_SCN_CNT_CODE
  IMAGE_SCN_MEM_READ     OR
  IMAGE_SCN_MEM_WRITE    OR
  IMAGE_SCN_MEM_EXECUTE  OR
  OVER OT.ObjectFlags !  \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
DROP

HERE DUP /ObjectTable DUP ALLOT ERASE DUP S" .text" ROT OT.ObjectName SWAP MOVE       \ CODE\0\0\0\0
 1000 OVER OT.VirtualSize !      \ сколько памяти отводится объекту при загруке
 2000 OVER OT.RVA !              \ относительный виртуальный адрес
  200 OVER OT.PhisicalSize !     \
  400 OVER OT.PhisicalOffset !   \ смещение в exe-файле
  IMAGE_SCN_CNT_CODE  
  IMAGE_SCN_MEM_READ     OR
  IMAGE_SCN_MEM_WRITE    OR
  OVER OT.ObjectFlags !  \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
OT.VirtualSize

 0 , 0 ,
 S" SP-FORTH 4.0 (c) RUFIG http://www.forth.org.ru" HERE SWAP DUP ALLOT MOVE

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
                                           S" используемый JP-Фортом 1.0 для"   HERE SWAP DUP ALLOT MOVE 0D C,
                                           S" формирования выполнимых файлов."  HERE SWAP DUP ALLOT MOVE 0D C, 0D C,
                                           S" Copyright (C) 1995-96 Черезов А.Ю." HERE SWAP DUP ALLOT MOVE 0D C,
                                           S" Модификация 19.06.2000 Якимов Д.А." HERE SWAP DUP ALLOT MOVE 0 C,                                           

HERE CONSTANT TEST-MSG-END
     CONSTANT TEST-MSG-BEGIN
TEST-MSG-END TEST-MSG-BEGIN - DUP ROT !
PE-HEADER SizeOfCode !
\ ---------------------------------------------------------------------------------

HEX
: WRITE-EXE-HEADER
  >R
  EXE-HEADER /EXE-HEADER R@ WRITE-FILE THROW
  200 /EXE-HEADER - HERE OVER ERASE \ доводим до 512, затем пойдут секции
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

BYE
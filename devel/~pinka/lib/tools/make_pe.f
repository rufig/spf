\ 09.Sep.2001 Sun 03:13   Ruv

\ 09.Aug.2003   Ruv
\  * comment ERASED-CNT  as obsolete  in new versions of spf4

\ S" lib\EXT\SPF-ASM.F" INCLUDED

(  
   ----- IMAGE-BASE
   0x1000 .reserved \ uninitialized data
   0x1000 .idata \ - импортируемые функции
   ----- IMAGE-BEGIN  \ ORG-ADDR
   .text \ основное хранилище форт-системы
     первая команда: CALL INIT 
   ----- IMAGE-END    \ HERE
)

HERE 
                    TEMP-WORDLIST  DUP SET-CURRENT ALSO CONTEXT !
 CONSTANT IMAGE-END

: >RVA ( a1 -- a2 )
  IMAGE-BASE -
;
REQUIRE U.R lib\include\core-ext.f
0 VALUE _EXE-HEADER
\ : pre  HERE _EXE-HEADER - 4 U.R ."  | " SOURCE TYPE CR ; ' pre TO <PRE>


CREATE EXE-HEADER \ ========================================================
EXE-HEADER TO _EXE-HEADER
HEX

\ == DOS-HEADER
\ IMAGE_DOS_HEADER
       CHAR M C, CHAR Z C, 30090 , 40000 , FFFF0000 , B80000 , 0 , 400000 ,
       HERE 22 DUP ALLOT ERASE
       80 , 0EBA1F0E , CD09B400 , 4C01B821 , 0CD C, 21 C,
       S" This program cannot be run in DOS mode" HERE SWAP DUP ALLOT MOVE
       0A0D0D2E , 24 , 0 ,
\ /IMAGE_DOS_HEADER
\ == PE-HEADER

\ IMAGE_FILE_HEADER
 CHAR P C, CHAR E C, 0 W,   \ 4 -- Signature \ PE/0/0
 014C W,                    \ 2 -- CPUtype   \ 14Ch - IMAGE_FILE_MACHINE_I386
 0002 W,                    \ 2 -- NumberOfSections  ( offs 86 \hex everywhere)
 311CBDC5 ,                 \ 4 -- TimeDateStamp
 0 ,                        \ 4 -- PointerToSymbolTable
 0 ,                        \ 4 -- NumberOfSymbols
 00E0 W,                    \ 2 -- NTHDRsize \ SizeOfOptionalHeader

 \ 0
 \ IMAGE_FILE_RELOCS_STRIPPED     OR  \ bit 0
 \ IMAGE_FILE_EXECUTABLE_IMAGE    OR  \ bit 1
 \ IMAGE_FILE_LINE_NUMS_STRIPPED  OR  \ bit 2
 \ IMAGE_FILE_LOCAL_SYMS_STRIPPED OR  \ bit 3
 \ IMAGE_FILE_AGGRESIVE_WS_TRIM   OR  \ bit 4
 \ IMAGE_FILE_32BIT_MACHINE       OR  \ bit 8
 \ IMAGE_FILE_DEBUG_STRIPPED      OR  \ bit 9
 \ IMAGE_FILE_SYSTEM              OR  \ bit 12  \ for drv
 \ IMAGE_FILE_DLL                 OR  \ bit 13
BASE @ 2 BASE !
 \ 5432109876543210
   0000001100011111 W,      \ 2 -- Flags  \ Characteristics  ( offs 96 )
 \       0100001110 \ SPF316, SPF3.754
 \       1100011111 \ JPF, SPF4

BASE !

\ /IMAGE_FILE_HEADER

\ IMAGE_OPTIONAL_HEADER

 \ Standart fields
 010B W,                    \ 2 -- Magic
 02 C,                      \ 1 -- MajorLinkedVersion \ what if you have got no idea *which* linker was used?
 37 C,                      \ 1 -- MinorLinkedVersion
\ IMAGE-END IMAGE-BEGIN - ,  \ 4 -- SizeOfCode ( offs 9C) \ but unreliable, as and two following.
 F3 , \ ***
 0 ,                        \ 4 -- SizeOfInitializedData    \ so-called "data segment"
 0 ,                        \ 4 -- SizeOfUninitializedData  \ so-called "bss segment"
 IMAGE-BEGIN >RVA ,         \ 4 -- AddresOfEntryPoint ( offs 0A8)  \ RVA of  CALL INIT
 IMAGE-BEGIN >RVA ,         \ 4 -- BaseOfCode
 IMAGE-BASE  >RVA ,         \ 4 -- BaseOfData \ is 0
    \ The data section (IMAGE_SCN_CNT_INITIALIZED_DATA), or sections, will be 
    \   in the range 'BaseOfData' up to 'BaseOfData'+'SizeOfInitializedData'.

 \ NT Additional fields
 IMAGE-BASE ,               \ 4 -- ImageBase
 1000 ,                     \ 4 -- SectionAlignment
  200 ,                     \ 4 -- FileAlignment
 01 W,                      \ 2 -- OSMajor   \ MajorOperatingSystemVersion \ The loader doesn't use it, apparently.
 00 W,                      \ 2 -- OSMinor   \ MinorOperatingSystemVersion \
 00 W,                      \ 2 -- UserMajor \ MajorImageVersion
 00 W,                      \ 2 -- UserMinor \ MinorImageVersion
 04 W,                      \ 2 -- SubsysMajor
 00 W,                      \ 2 -- SubsysMinor
 0 ,                        \ 4 -- Reserved1 \ Win32VersionValue
 IMAGE-BEGIN IMAGE-BASE - 
 IMAGE-SIZE + ,             \ 4 -- ImageSize  ( offs D0) \ SizeOfImage - sum of all headers' and sections' lengths if aligned to 'SectionAlignment'.
 0200 ,                     \ 4 -- HeaderSize ( offs D4) \ SizeOfHeaders - the offset from the beginning of the file to the first section's raw data.
 0 ,                        \ 4 -- FileChecksum ( offs D8)
 03 W,                      \ 2 -- Subsystem  ( offs DC) \ 2-GUI, 3-Character
 00 W,                      \ 2 -- DLLFlags   ( offs DE)
 100000 ,                   \ 4 -- StackReserve
   8000 ,                   \ 4 -- StackCommitSize
 100000 ,                   \ 4 -- HeapReserveSize
   1000 ,                   \ 4 -- HeapCommitSize
 0 ,                        \ 4 -- LoaderFlags
 10 ,                       \ 4 -- NumberOfRvaAndSizes \ = IMAGE_NUMBEROF_DIRECTORY_ENTRIES

 \ IMAGE_DATA_DIRECTORY - всего 16 entries ( IMAGE_NUMBEROF_DIRECTORY_ENTRIES )
 0 ,                        \ ( 00) 4 -- ExportTableRVA       ( offs 0F8)
 0 ,                        \       4 -- TotalExportDataSize
 IMAGE-BEGIN 1000 - >RVA ,  \ ( 01) 4 -- ImportTableRVA       ( offs 100)
 70 ,                       \       4 -- TotalImportDataSize
 0 ,                        \ ( 02) 4 -- ResourceTableRVA     ( offs 108)
 0 ,                        \       4 -- TotalResourceDataSize
 0 ,                        \ ( 03) 4 -- ExceptionTableRVA
 0 ,                        \       4 -- TotalExceptionDataSize
 0 ,                        \ ( 04) 4 -- SecurityTableRVA
 0 ,                        \       4 -- TotalSecurityDataSize
 0 ,                        \ ( 05) 4 -- RelocationTableRVA   ( offs 120) \ base relocation table
 0 ,                        \       4 -- TotalRelocationDataSize
 0 ,                        \ ( 06) 4 -- DebugTableRVA
 0 ,                        \       4 -- TotalDebugDataSize
 0 ,                        \ ( 07) 4 -- GlobalPtrTableRVA \ Description String
 0 ,                        \       4 -- TotalGlobalPtrDataSize \ (some arbitrary copyright note or the like)
 0 ,                        \ ( 08) 4 -- MachineValueTableRVA
 0 ,                        \       4 -- TotalMachineValueDataSize
 0 ,                        \ ( 09) 4 -- TLSTableRVA         \ Thread local storage directory
 0 ,                        \       4 -- TotalTLSDataSize
 0 ,                        \ ( 10) 4 -- LoadConfigurationTableRVA
 0 ,                        \       4 -- TotalLoadConfigurationDataSize
 0 ,                        \ ( 11) 4 -- BoundImportTableRVA  \ Bound Import Directory in headers
 0 ,                        \       4 -- TotalBoundImportDataSize
 0 ,                        \ ( 12) 4 -- IATTableRVA          \ Import Address Table
 0 ,                        \       4 -- TotalIATDataSize
 0 ,                        \ ( 13) 4 -- DelayImportTableRVA
 0 ,                        \       4 -- TotalDelayImportDataSize
 \ 14 описали, дальше просто ALLOT
 0 , 0 , 0 , 0 ,            \ 2 8 * -- ReservedSections
 
\ /IMAGE_OPTIONAL_HEADER
\ /PE-HEADER
\ /EXE-HEADER

\ Section directories
  \ Section headers
  \ Sections raw data

\ IMAGE_SECTION_HEADER  
  \ Characteristics
    \ If bit 05 (IMAGE_SCN_CNT_CODE) is set, the section contains executable code.
    \ If bit 06 (IMAGE_SCN_CNT_INITIALIZED_DATA)
    \ If bit 07 (IMAGE_SCN_CNT_UNINITIALIZED_DATA) \ This is normally the BSS.
    \ If bit 09 (IMAGE_SCN_LNK_INFO) is set, the section doesn't contain image data but comments, description or other documentation.
    \ If bit 11 (IMAGE_SCN_LNK_REMOVE) is set, the data is part of an object file's section
    \ If bit 12 (IMAGE_SCN_LNK_COMDAT) is set, the section contains "common block data", which are packaged functions of some sort.
    \ If bit 15 (IMAGE_SCN_MEM_FARDATA) is set, we have far data - whatever that means. This bit's meaning is unsure.
    \ If bit 17 (IMAGE_SCN_MEM_PURGEABLE) is set, the section's data is purgeable... This bit's meaning is unsure.
    \ If bit 18 (IMAGE_SCN_MEM_LOCKED) is set, the section should not be moved in memory? Perhaps it indicates there is no relocation information? This bit's meaning is unsure.
    \ If bit 19 (IMAGE_SCN_MEM_PRELOAD) is set, the section should be paged in before execution starts? This bit's meaning is unsure.
    \ If bit 24 (IMAGE_SCN_LNK_NRELOC_OVFL) is set, the section contains some extended relocations that I don't know about.
    \ If bit 25 (IMAGE_SCN_MEM_DISCARDABLE) is set, the section's data is not needed after the process has started. (relocation information, import directories)
    \ If bit 26 (IMAGE_SCN_MEM_NOT_CACHED) is set, the section's data should not be cached. Does this mean to switch off the 2nd-level-cache?
    \ If bit 27 (IMAGE_SCN_MEM_NOT_PAGED) is set, the section's data should not be paged out. This is interesting for drivers.
    \ If bit 28 (IMAGE_SCN_MEM_SHARED) is set, the section's data is shared among all running instances of the image.
    \ If bit 29 (IMAGE_SCN_MEM_EXECUTE) is set, the process gets 'execute'-access to the section's memory.
    \ If bit 30 (IMAGE_SCN_MEM_READ) is set, the process gets 'read'-access to the section's memory.
    \ If bit 31 (IMAGE_SCN_MEM_WRITE) is set, the process gets 'write'-access to the section's memory.
  \ /Characteristics

\ .idata header \ IMAGE_SECTION_HEADER
 S" .idata" HERE SWAP DUP ALLOT MOVE   0 C, 0 C,  \ 8 -- Name
\ 70 ,                        \ 4 -- Misc \ PhysicalAddress:DWORD or VirtualSize:DWORD
 0 , \ ***
 IMAGE-BEGIN 1000 - >RVA ,  \ 4 -- VirtualAddress
 200 ,                      \ 4 -- SizeOfRawData
 200 ,                      \ 4 -- PointerToRawData  \ offset at exe file
 0 ,                        \ 4 -- PointerToRelocations
 0 ,                        \ 4 -- PointerToLinenumbers
 0 W,                       \ 2 -- NumberOfRelocations
 0 W,                       \ 2 -- NumberOfLinenumbers
BASE @ 2 BASE !
 \ 10987654321098765432109876543210
\   11000000000000000000000001000000 ( 0xC0000040 )
0xE0000020 \ ***
 \ 11100000000000000000000000100000 ( 0xE0000020 ) - spf4
 \ spf3:                            ( 0xC0000040 )
 ,                          \ 4 -- Characteristics   \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
BASE !

\ .text header
 S" .text" HERE SWAP DUP ALLOT MOVE  0 C, 0 C, 0 C,
\ IMAGE-END IMAGE-BEGIN - ,  \ Misc
\ 0x080000 , \ ***
\ 0 ,
 IMAGE-SIZE ,
\ IMAGE-END IMAGE-BASE - 1FF + 200 / 200 * , 

 IMAGE-BEGIN >RVA ,         \ VirtualAddress
 IMAGE-END IMAGE-BEGIN - 
 1FF + 200 / 200 * ,        \ SiziOfRawData  \ align by FileAlignment
 400 ,                      \ PointerToRawData
 0 ,                        \ PointerToRelocations
 0 ,                        \ PointerToLinenumbers
 0 W,                       \ NumberOfRelocations 
 0 W,                       \ NumberOfLinenumbers 
BASE @ 2 BASE !
 \ 10987654321098765432109876543210
   11100000000000000000000001100000 ( 0xE0000060 )
 \ 11000000000000000000000000100000 ( 0xC0000020 )  - spf4. как оно работает?
 \ spf3:                            ( 0xE0000060 )
 ,                          \ 4 -- Characteristics   \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
BASE !

 HERE
 200 HERE EXE-HEADER - - DUP . CR ALLOT
 HERE OVER - ERASE

HERE EXE-HEADER -   CONSTANT /EXE-HEADER
\ /EXE-HEADER  EXE-HEADER D4 + !  \ SizeOfHeaders \ смещение данных первой секции.

/EXE-HEADER . CR

: save ( a u -- )
  W/O CREATE-FILE THROW >R
\  ERASED-CNT 0!
  EXE-HEADER /EXE-HEADER  R@ WRITE-FILE THROW  \ заголовок
  \ IMAGE-BEGIN 1000 - 200  R@ WRITE-FILE THROW  \ первая секция - таблица импорта

  ModuleName R/O OPEN-FILE-SHARED THROW >R
  HERE 400 R@ READ-FILE THROW 400 < THROW
  R> CLOSE-FILE THROW

  HERE 200 +           200  R@ WRITE-FILE THROW  \ первая секция - таблица импорта

  IMAGE-BEGIN IMAGE-END OVER - 
  1FF + 200 / 200 *       R@ WRITE-FILE THROW  \ вторая секция - код.
  R> CLOSE-FILE THROW
\  ERASED-CNT 1+!
;
\ S" test.exe" save BYE

( нельзя писать инициализированную загрузчиком таблицу импорта )



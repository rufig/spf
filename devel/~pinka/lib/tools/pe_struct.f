
REQUIRE STRUCT:  lib\ext\struct.f

\ структура PE-HEADER

STRUCT: PEHeader
 \ IMAGE_FILE_HEADER
 4 -- Signature \ PE/0/0
 2 -- Machine              \ 14Ch - 386
 2 -- NumberOfSections     
 4 -- TimeDateStamp        
 4 -- PointerToSymbolTable 
 4 -- NumberOfSymbols      
 2 -- SizeOfOptionalHeader 
 2 -- Characteristics      
 \ /IMAGE_FILE_HEADER
 \ IMAGE_OPTIONAL_HEADER
      ( Standard fields. )
 2 -- Magic                  
 1 -- MajorLinkerVersion     
 1 -- MinorLinkerVersion     
 4 -- SizeOfCode             
 4 -- SizeOfInitializedData  
 4 -- SizeOfUninitializedData
 4 -- AddressOfEntryPoint    
 4 -- BaseOfCode             
 4 -- BaseOfData             
      ( NT additional fields. )
 4 -- ImageBase                  
 4 -- SectionAlignment           
 4 -- FileAlignment              
 2 -- MajorOperatingSystemVersion
 2 -- MinorOperatingSystemVersion
 2 -- MajorImageVersion          
 2 -- MinorImageVersion          
 2 -- MajorSubsystemVersion      
 2 -- MinorSubsystemVersion      
 4 -- Win32VersionValue          
 4 -- SizeOfImage                
 4 -- SizeOfHeaders              
 4 -- CheckSum                   
 2 -- Subsystem                  
 2 -- DllCharacteristics         
 4 -- SizeOfStackReserve         
 4 -- SizeOfStackCommit          
 4 -- SizeOfHeapReserve          
 4 -- SizeOfHeapCommit           
 4 -- LoaderFlags                
 4 -- NumberOfRvaAndSizes        
 ( Data Directory - 16 entrys )
 ( 00) 4 -- ExportTableRVA       
       4 -- TotalExportDataSize
 ( 01) 4 -- ImportTableRVA
       4 -- TotalImportDataSize
 ( 02) 4 -- ResourceTableRVA
       4 -- TotalResourceDataSize
 ( 03) 4 -- ExceptionTableRVA
       4 -- TotalExceptionDataSize
 ( 04) 4 -- SecurityTableRVA
       4 -- TotalSecurityDataSize
 ( 05) 4 -- RelocationTableRVA
       4 -- TotalRelocationDataSize
 ( 06) 4 -- DebugTableRVA
       4 -- TotalDebugDataSize
 ( 07) 4 -- CopyrightTableRVA
       4 -- TotalCopyrightDataSize
 ( 08) 4 -- MachineValueTableRVA
       4 -- TotalMachineValueDataSize
 ( 09) 4 -- TLSTableRVA
       4 -- TotalTLSDataSize
 ( 10) 4 -- LoadConfigurationTableRVA
       4 -- TotalLoadConfigurationDataSize
 ( 11) 4 -- BoundImportTableRVA
       4 -- TotalBoundImportDataSize
 ( 12) 4 -- IATTableRVA
       4 -- TotalIATDataSize
 ( 13) 4 -- DelayImportTableRVA
       4 -- TotalDelayImportDataSize
   8 2 * -- Reserved
 \ /IMAGE_OPTIONAL_HEADER
;STRUCT

STRUCT: ImageSectionHeader \ aka элемент таблицы объектов (идет вслед за PE-header)
 8 -- Name                  \ CODE\0\0\0\0
 4 -- Misc                  \ PhysicalAddress or VirtualSize - сколько памяти отводится объекту при загруке
 4 -- VirtualAddress        \ относительный виртуальный адрес
 4 -- SizeOfRawData         \ физический размер объекта в файле
 4 -- PointerToRawData      \ смещение в exe-файле
 4 -- PointerToRelocations  \ pointer to relocations
 4 -- PointerToLinenumbers  \ pointer to line numbers
 2 -- NumberOfRelocations   \ number of relocations
 2 -- NumberOfLinenumbers   \ number of line numbers
 4 -- Characteristics       \ 60000020h=readable excutable code (E0000060h=-"-+writeable data)
;STRUCT

STRUCT: ImageImportDescriptor \ Структура записей в каталоге импорта
 4 -- OriginalFirstThunk    \ RVA
 4 -- TimeDateStamp         \  0
 4 -- ForwarderChain        \ -1
 4 -- Name                  \ RVA of dll name
 4 -- FirstThunk            \ RVA
;STRUCT

STRUCT: ImageExportDirectory
 4 -- Characteristics       \ 0
 4 -- TimeDateStamp         \ 0
 2 -- MajorVersion          \ 0
 2 -- MinorVersion          \ 0
 4 -- Name                  \ RVA DLL asciiz name
 4 -- Base                  \
 4 -- NumberOfFunctions    
 4 -- NumberOfNames        
 4 -- AddressOfFunctions    
 4 -- AddressOfNames        
 4 -- AddressOfNameOrdinals 
;STRUCT
                                                    HEX
CREATE DOS-HEADER
       CHAR M C, CHAR Z C, 30090 , 40000 , FFFF0000 , B80000 , 0 , 400000 ,
       HERE 22 DUP ALLOT ERASE
       80 , 0EBA1F0E , CD09B400 , 4C01B821 , 0CD C, 21 C,
       S" This program cannot be run in DOS mode" HERE SWAP DUP ALLOT MOVE
       0A0D0D2E , 24 , 0 ,
HERE DOS-HEADER - CONSTANT /DOS-HEADER              DECIMAL


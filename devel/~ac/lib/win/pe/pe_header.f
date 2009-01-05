\ структура PE-HEADER (из spf-stub.f 96го года с изменениями из pecoff_v8.docx)
 0
 4 -- Signature \ PE/0/0
 2 -- CPUtype   \ 14Ch - 386
 2 -- #Objects
 4 -- TimeDateStamp
 4 -- PointerToSymbolTable \ Res1
 4 -- NumberOfSymbols \ Res2
 2 -- NTHDRsize \ размер опционального заголовка, который начинается ниже с Magic
 2 -- Flags

 2 -- Magic \ 0x10b	PE32	0x20b	PE32+

 1 -- LMAJOR \ linker
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
 2 -- UserMajor \ image version
 2 -- UserMinor
 2 -- SubsysMajor
 2 -- SubsysMinor
 4 -- Win32VersionValue \ Res9
 4 -- ImageSize \ The size (in bytes) of the image, including all headers, as the image is loaded in memory. It must be a multiple of SectionAlignment.
 4 -- HeaderSize \ The combined size of an MS DOS stub, PE header, and section headers rounded up to a multiple of FileAlignment.
 4 -- FileChecksum \ The image file checksum. The algorithm for computing the checksum is incorporated into IMAGHELP.DLL. The following are checked for validation at load time: all drivers, any DLL loaded at boot time, and any DLL that is loaded into a critical Windows process.
 2 -- Subsystem
 2 -- DLLFlags
 4 -- StackReserve
 4 -- StackCommitSize
 4 -- HeapReserveSize
 4 -- HeapCommitSize
 4 -- LoaderFlags \ Res10
 4 -- #InterestingRVA/Sizes \ = NumberOfRvaAndSizes The number of data-directory entries in the remainder of the optional header. Each describes a location and size.

\ Optional Header Data Directories:
 4 -- ExportTableRVA
 4 -- TotalExportDataSize

 4 -- ImportTableRVA
 4 -- TotalImportDataSize

 4 -- ResourceTableRVA
 4 -- TotalResourceDataSize

 4 -- ExceptionTableRVA
 4 -- TotalExceptionDataSize

 4 -- SecurityTableRVA \ (file pointer!) The attribute certificate table
 4 -- TotalSecurityDataSize

 4 -- FixupTableRVA \ The .reloc Section
 4 -- TotalFixupDataSize

 4 -- DebugTableRVA
 4 -- TotalDebugDataSize

 4 -- ImageDescriptionRVA  \ Architecture	Reserved, must be 0
 4 -- TotalDescriptionSize

 4 -- MachineSpecificRVA \ Global Ptr	The RVA of the value to be stored in the global pointer register. The size member of this structure must be set to zero. 
 4 -- MachineSpecificSize

 4 -- ThreadLocalStorageRVA
 4 -- TotalTLSSize

\ SPF знает только 10 указанных выше RvaAndSizes

 8 -- LoadConfigTable
 8 -- BoundImport
 8 -- IAT
 8 -- DelayImportDescriptor
 8 -- CLRRuntimeHeader
 8 -- Res11 \ Reserved, must be zero
CONSTANT /PE-HEADER

\ структура - таблица объектов (идёт вслед за PE-header) -- из spf_stub.f 96го года,
 0
 8 -- OT.ObjectName        \ CODE\0\0\0\0 An 8-byte, null-padded UTF-8 encoded string. If the string is exactly 8 characters long, there is no terminating null. For longer names, this field contains a slash (/) that is followed by an ASCII representation of a decimal number that is an offset into the string table. Executable images do not use a string table and do not support section names longer than 8 characters. Long names in object files are truncated if they are emitted to an executable file.
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

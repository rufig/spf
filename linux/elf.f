\ UNIX ELF utilites 
\ Dmitry Yakimov (c) 2004 ftech@tula.net
\ GNU public license

\ FORTH constants

100000 CONSTANT ForthSize
0x08048000 CONSTANT IMAGE-BASE

\ types of file

0 CONSTANT ET_NONE
1 CONSTANT ET_REL
2 CONSTANT ET_EXEX
3 CONSTANT ET_CORE
0xFF00 CONSTANT ET_LOPROC
0xFFFF CONSTANT ET_HIPROC

\ types of machine

3 CONSTANT EM_386

16 CONSTANT EI_NIDENT

\ versions
0 CONSTANT EV_NONE
1 CONSTANT EV_CURRENT

\ ELF header

0
EI_NIDENT -- e_ident  \ initialisation bytes
2  -- e_type          \ type of file
2  -- e_machine       \ type of machine ( EM_386 )
4  -- e_version       \ EV_NONE | EV_CURRENT
4  -- e_entry         \ entry point
4  -- e_phoff         \ offset of program header tables
4  -- e_shoff         \ offset of section header tables
4  -- e_flags         \ processor specific flag ( 0 for Intel )
2  -- e_ehsize        \ ELF's header size, in bytes
2  -- e_phentsize     \ size of one entry in the program header table
2  -- e_phnum         \ num of entries in the program header table
2  -- e_shentsize     \ size of one entry in the section header table
2  -- e_shnum         \ num of entries in the section header table
2  -- e_shstrndx      \ section table header index of the entry
                       \ associated with section name string table
VALUE /Elf32_Ehdr


\ Section header

0
4 -- sh_name     \ index in section header string table
4 -- sh_type     \ section content
4 -- sh_flags    \ 1 bit flags
4 -- sh_addr     \ address of section in the memory of process
4 -- sh_offset   \ offset from the beginning of the file
2 -- sh_size     \ sas
2 -- sh_link     \ section header table index link
2 -- sh_info     \ extra information
2 -- sh_addralign \ 0 2 4 ...
2 -- sh_entsize   \ size of entry of optional section table (symbol table)
VALUE /Elf32_Shdr

\ Section types

0 CONSTANT SHT_NULL
1 CONSTANT SHT_PROGBITS
2 CONSTANT SHT_SYMTAB
3 CONSTANT SHT_STRTAB
4 CONSTANT SHT_RELA
5 CONSTANT SHT_HASH
6 CONSTANT SHT_DYNAMIC
7 CONSTANT SHT_NOTE
8 CONSTANT SHT_NOBITS
9 CONSTANT SHT_REL
10 CONSTANT SHT_SHLIB
11 CONSTANT SHT_DYNSYM
0x70000000 CONSTANT SHT_LOPROC
0x7FFFFFFF CONSTANT SHT_HIPROC
0x80000000 CONSTANT SHT_LOUSER
0xFFFFFFFF CONSTANT SHT_HIUSER


\ Section flags
0x1 CONSTANT SHF_WRITE
0x2 CONSTANT SHF_ALLOC
0x4 CONSTANT SHF_EXECINSTR
0xF0000000 CONSTANT SHF_MASKPROC

0 CONSTANT SHN_UNDEF


\ Program header

1 CONSTANT PT_LOAD

0
4 -- p_type   \ 1 ( PT_LOAD )
4 -- p_offset \ from the beginning of file ( 0x100 for example )
4 -- p_vaddr  \ where we want to load the first byte of section data ( base addess )
4 -- p_paddr  \ unspecified for exec ( 0 )
4 -- p_filesz 
4 -- p_memsz
4 -- p_flags
4 -- p_align  \ 0x1000
VALUE /Elf32_Phdr

/Elf32_Phdr /Elf32_Ehdr + CONSTANT CodeOffset

\ segment permission
1 CONSTANT PF_X
2 CONSTANT PF_W
4 CONSTANT PF_R

\ lets do it!

CREATE Ident
0x7F C,
CHAR E C, 
CHAR L C,
CHAR F C,
1 C, \ ELFCLASS32
1 C, \ ELFDATA2LSB
EV_CURRENT C,
0 C, \ EI_PAD
0 C,
0 C,
0 C,
0 C,
0 C,
0 C,
0 C,
0 C,

\ fullfil header

CREATE ElfHeader /Elf32_Ehdr ALLOT
ElfHeader /Elf32_Ehdr 0 FILL

Ident ElfHeader EI_NIDENT MOVE
ET_EXEX     ElfHeader e_type W!
EM_386      ElfHeader e_machine W!
EV_CURRENT  ElfHeader e_version !
/Elf32_Ehdr ElfHeader e_ehsize W!
/Elf32_Phdr ElfHeader e_phentsize W!
1           ElfHeader e_phnum W!
IMAGE-BASE CodeOffset + ElfHeader e_entry !
/Elf32_Ehdr ElfHeader e_phoff !

CREATE ProgramHeader /Elf32_Phdr ALLOT
ProgramHeader /Elf32_Phdr 0 FILL

PT_LOAD ProgramHeader p_type !
0x1000 ProgramHeader p_align !
IMAGE-BASE DUP ProgramHeader p_vaddr !
               ProgramHeader p_paddr !
ForthSize ProgramHeader p_memsz !

PF_R PF_X OR PF_W OR ProgramHeader p_flags !

  
0 VALUE SysExitAddr
0 VALUE SysExitSize

HEX
HERE TO SysExitAddr
33 C, DB C, \ xor ebx, ebx
B3 C, 2A C, \ mov bl, 42
31 C, C0 C, \ xor eax, eax
40 C,       \ inc eax
CD C, 80 C, \ int 80
HERE SysExitAddr - TO SysExitSize
DECIMAL

: SaveElf
     CodeOffset SysExitSize +
     ProgramHeader p_filesz ! \ file size
     
     S" spf4.elf" W/O CREATE-FILE THROW >R
     
     ElfHeader /Elf32_Ehdr R@ WRITE-FILE THROW
     ProgramHeader /Elf32_Phdr R@ WRITE-FILE THROW
     
     \ write exit call
     SysExitAddr SysExitSize R@ WRITE-FILE THROW
     R> CLOSE-FILE THROW
;

SaveElf

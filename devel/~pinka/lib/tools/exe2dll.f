\ 12.Sep.2001 Wed 21:17   Ruv

\ 09.Aug.2003   Ruv
\  * comment ERASED-CNT  as obsolete  in new versions of spf4

\ S" exe2.exe" S" %2" SAVE-DLL

(  
   ----- IMAGE-BASE
   0x1000 .reserved \ uninitialized data
   0x1000 .idata \ - импортируемые функции
   ----- IMAGE-BEGIN  \ ORG-ADDR
     .text \ основное хранилище форт-системы
     первая команда: CALL INIT
     словарь FORTH
   ----- IMAGE-END    \ HERE
     reserved for main store
   ----- IMAGE-BEGIN + IMAGE-SIZE
     .reloc
   -----
     .edata
   -----
)



GET-ORDER  GET-CURRENT OVER 2 +  (  x1 x2 ... xk k )
HERE

TEMP-WORDLIST DUP SET-CURRENT  DUP ALSO CONTEXT !   CONSTANT exe2dll-wid
\ IMAGE-BEGIN - CONSTANT ImageSize  \ not align
IMAGE-BEGIN - VALUE ImageSize  \ not align


: StoreAs ( x1 x2 ... xk k -- ) \ name
  CREATE DUP , 0 ?DO  , LOOP
  DOES>  \ name ( -- x1 x2 ... xk k )
  ( a )  DUP @ DUP >R
         CELLS + 
         R@ 0 ?DO DUP @ SWAP 1 CELLS - LOOP
         DROP R>
;

StoreAs OrigContext&Current
                               \  00 00 55 00
0x10000 CONSTANT difference    \  00 00 54 00
     -2 CONSTANT OffsToCell    \  ^     ^
                               \     2 bytes

: alignes ( a|u align-bytes -- a2|u2 )
  DUP >R + 1- DUP R> MOD -
;
: >RVA ( a -- RV_a )
  IMAGE-BASE -
;

                                        VOC-LIST @
: | 0= IF POSTPONE \ THEN ; IMMEDIATE
  ' ' CATCH {  | 0 .( locals.f must be included at the base exe !!! ) CR CR
  DROP
REQUIRE {       ~ac\lib\locals.f
                                        VOC-LIST !  

( надо фиксить VOC-LIST на старое значение.
  Потому как. даже если словарь создается во временном хранилище /во временном словаре/
  он добавляется в VOC-LIST
  =-> VOC-LIST должно быть локальным для хранилища!
)

VARIABLE dllname-a
VARIABLE dllname-u 

0 VALUE EDataSize     \ 0x200 alignes
0 VALUE EDataA
0 VALUE ExportDirectorySize
0 VALUE ExportDirectory

0 VALUE RelocationDataSize
0 VALUE RelocSize     \ 0x200 alignes  \ aligned
0 VALUE vReloc
VARIABLE reloc-offs

0 VALUE vImage1
0 VALUE vImage2
VARIABLE image-offs

: [r]here ( -- a )
  vReloc reloc-offs @ +
;
: [r],  ( x -- )
  [r]here !
  4 reloc-offs +!
;
: [r]W,  ( x -- )
  [r]here W!
  2 reloc-offs +!
;

: Image1A ( -- a )
  vImage1 image-offs @ +
;
: Image2A ( -- a )
  vImage2 image-offs @ +
;
: [Image1]C@ ( -- b )
  vImage1 image-offs @ + C@
;
: [Image2]C@ ( -- b )
  vImage2 image-offs @ + C@
;


: report1 ( -- )
  BASE @ HEX
  ." Unknown difference at " Image1A .  
  ."  Exe offset: " image-offs @ 0x400 + .
  ."  Word: " Image1A  WordByAddr  TYPE CR
  BASE !
;

: checkly-diff ( -- flag ) \ true if difference known 
  OffsToCell image-offs +!
  Image2A @
  Image1A @
  - difference = IF TRUE EXIT THEN
  OffsToCell NEGATE image-offs +!
  report1  \ ABORT" found unknown difference"
  FALSE
;

: find-diff ( -- f ) \ true if found
  4 image-offs +!           BEGIN 
  image-offs @ ImageSize < 0=  IF FALSE EXIT THEN \ ABORT" end of image"
  [Image1]C@  [Image2]C@ <>    IF checkly-diff IF TRUE EXIT THEN THEN
  1 image-offs +!           AGAIN
;

: Make-RelocBlock ( -- f ) \ true if end
  Image1A  { base \ h1 h2 }
  [r]here -> h1    base >RVA  [r],   \ RVA
  [r]here -> h2            0  [r],   \ size

                                BEGIN
  Image1A base - 
  DUP 0x1000 ( 4Kb) <           WHILE ( a)
  0x3000 OR [r]W,
  find-diff  0=                 UNTIL -1 ELSE DROP 0 THEN
  [r]here h1 - h2 !  \ fix the size
;

: Make-RelocTable ( -- a u )
  vReloc IF vReloc FREE THROW THEN
  ImageSize ALLOCATE THROW TO vReloc
  reloc-offs 0!
  find-diff IF BEGIN Make-RelocBlock UNTIL THEN
  reloc-offs @  TO RelocationDataSize
  0 [r], 0 [r],
  vReloc reloc-offs @
;
( значения самой перовой проверяемой ячейки должно быть одинаково
в обоих образах)

0 VALUE hdll

: ReadedExe2 ( name-a name-u -- block-a block-u )
  R/O OPEN-FILE THROW { hexe \ a u }
  hexe FILE-SIZE THROW D>S -> u
  u ALLOCATE THROW -> a
  a u hexe READ-FILE THROW u < THROW
  hexe CLOSE-FILE THROW
  a u
;


: get-reloc ( name2-a  name2-u  namedll-a  namedll-u -- a u )
  W/O CREATE-FILE   THROW TO hdll
  ReadedExe2 ( block-addr block-u )
  ImageSize  < ABORT" unexpected size of exe2" \ ***
  0x400 + TO vImage2  IMAGE-BEGIN TO vImage1  image-offs 0!

  Make-RelocTable  0x200 alignes DUP TO RelocSize
;

: SectionsH ( -- a u )
  HERE 0x400 { a o }
  S" .idata" HERE SWAP DUP ALLOT MOVE  0 C, 0 C,
  0x70 ,   \ VirtSize
  0x1000 , \ RVA
  o 0x200 DUP o + -> o ,  \ size
  ,  \ offset at file
  0 , 0 , 0 ,
  0xC0000040 , \ Characteristics

  S" .text" HERE SWAP DUP ALLOT MOVE  0 C, 0 C, 0 C,
  IMAGE-SIZE , \ VS
  0x2000 , \ RVA
  o ImageSize 0x200 alignes DUP o + -> o ,  \ size
  ,  \ offset at file
  0 , 0 , 0 ,
  0xE0000060 , \ Characteristics

  S" .reloc" HERE SWAP DUP ALLOT MOVE  0 C, 0 C, 
  RelocSize 0x1000 alignes , \ VS 
  0x2000 IMAGE-SIZE 0x1000 alignes + , \ RVA
  o RelocSize  DUP o + -> o ,  \ size
  ,  \ offset at file
  0 , 0 , 0 ,
  0xC0000040 , \ Characteristics

  S" .edata" HERE SWAP DUP ALLOT MOVE  0 C, 0 C, 
  EDataSize , \ VS
  0x2000  IMAGE-SIZE 0x1000 alignes +  RelocSize 0x1000 alignes + , \ RVA
  o EDataSize  DUP o + -> o ,  \ size
  ,  \ offset at file
  0 , 0 , 0 ,
  0xC0000040 , \ Characteristics


  HERE a -    \ DUP NEGATE ALLOT
  a SWAP  \ 0x200 alignes
;

: PEHeader ( -- a u )
  ModuleName R/O OPEN-FILE-SHARED THROW >R
  HERE 0x400 R@ READ-FILE THROW 0x400 < THROW
  R> CLOSE-FILE THROW

  HERE 0x086 + W@  2 <> ABORT" unknown sections."
    4
  HERE 0x086 + ! \ 4 секции
    1 13 LSHIFT >R \ IMAGE_FILE_DLL
  HERE 0x096 + DUP W@ R> OR SWAP W!  \ dll flag
    ['] DllMain >RVA
  HERE 0x0A8 + !  \ AddresOfEntryPoint 
    \ 0x2000 IMAGE-SIZE + RelocSize + EDataSize +
    0x2000  IMAGE-SIZE 0x1000 alignes +  RelocSize 0x1000 alignes +  EDataSize +
  HERE 0x0D0 + !  \ SizeOfImage
    0x400
  HERE 0x0D4 + !  \ HeaderSize
    0xF
  HERE 0x0DE + W!  \ DLLFlags \ but not used
  \ надо фиксить размеры стеков в dll до 0  ?
    \ 0x2000 IMAGE-SIZE 0x1000 alignes + RelocSize 0x1000 alignes +
    \ EDataA >RVA
    ExportDirectory
  HERE 0x0F8 + !   \ ExportDirectory
    \ EDataSize
    ExportDirectorySize
  HERE 0x0FC + !   \ ExportDirectory Size
    0x2000 IMAGE-SIZE 0x1000 alignes + 
  HERE 0x120 + !   \ RelocationTableRVA
    \ RelocSize
    RelocationDataSize
  HERE 0x124 + !   \ TotalRelocationDataSize

  HERE 0x178
;


0 VALUE vBase2

: >rva ( a1 -- a2 )
  vBase2 + >RVA
;

: Make-Export ( -- )
  IMAGE-BASE 0x2000 +  IMAGE-SIZE 0x1000 alignes +  RelocSize 0x1000 alignes +
  HERE -  TO vBase2

  HERE >R 

  HERE >rva 0 ,                 \ NameOrdinals
  HERE 1+ >rva  S" sfind" S", 0 C, \ names itself
  HERE >rva     SWAP ,          \ array of rva names
  HERE >rva     ['] sfind >RVA ,  \ array of rva functions
  HERE 1+ >rva  dllname-a @ dllname-u @ S", 0 C, \ dll name

  HERE >rva TO ExportDirectory
  HERE >R

  0 ,  \ Characteristics. are unused.
  0 ,  \ TimeDateStamp
  0 ,  \ Major&Minor version
   ,  \ name
  1 , \ Base
  1 , \ NumberOfFunctions
  1 , \ NumberOfNames
   ,  \ Addr of functions
   ,  \ Addr of names
   ,  \ addr of name ordinals
  \ HERE ExportDirectory -  TO ExportDirectorySize
  HERE R> - TO ExportDirectorySize
  R> HERE OVER -  0x200 alignes  TO  EDataSize  TO EDataA
;


: SAVE-DLL  ( name2-a  name2-u  namedll-a  namedll-u -- )

  \ ERASED-CNT 0!
  OrigContext&Current DROP SET-CURRENT SET-ORDER

  2DUP dllname-u ! dllname-a !
  get-reloc ( a u )
  HERE >R
  Make-Export
  SectionsH ( -> a2 u2 )
  PEHeader  ( -> a3 u3 )
  R> HERE  - ALLOT \ откат.
  OVER >R \ начало прочитанного заголовка файла
  DUP >R
  hdll WRITE-FILE THROW  \ PE header 
  DUP >R
  hdll WRITE-FILE THROW  \ section's headers
  HERE   0x400 2R> + - DUP 0< ABORT" unexpected EXE-header size"
  \ 2DUP 0xFF FILL
  hdll WRITE-FILE THROW \ выравнивание
  R> 0x200 + 0x200 
  hdll WRITE-FILE THROW \ section_01 таблица импорта  .idata 

  IMAGE-BEGIN ImageSize 0x200 alignes hdll WRITE-FILE THROW \ section_02 .text
  hdll WRITE-FILE THROW  \ section_03 relocations  .reloc
  EDataA EDataSize  \ 2DUP DUMP
  hdll WRITE-FILE THROW \ section_04 .edata

  hdll CLOSE-FILE THROW

  \ ERASED-CNT 1+!

  vReloc FREE THROW
  \ BYE
;

\EOF
: exe2 S" exe2.exe" ;
: dll  S" my1.dll" ;
dll dllname-u ! dllname-a !

exe2 dll  
W/O CREATE-FILE   THROW TO hdll

ReadedExe2 DROP 0x400 + TO vImage2  IMAGE-BEGIN TO vImage1  image-offs 0!

  ImageSize ALLOCATE THROW TO vReloc
  reloc-offs 0!

\  ERASED-CNT 0!
\  OrigContext&Current DROP SET-CURRENT SET-ORDER


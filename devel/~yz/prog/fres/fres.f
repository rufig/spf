\ FRES 1.02 09.03.2007
\ преобразует стандартый файл .RES в удобный для загрузки формат,
\ который представляет собой ничто иное, как соответствующий кусок
\ сегмента ресурсов: три уровня дерева плюс сами ресурсы.
\ единственная разница: ссылки на ресурсы отмеряются от начала файла.
\ Ю. Жиловец, http://www.forth.org.ru/~yz
\ ------------------------------------------
\ Недоделки.
\ Поскольку функции работы с атомами (в W95/98) не понимают юникодовских строк,
\ пришлось преобразовывать таковые в обычные строки, а потом назад.
\ Соответственно, имена ресурсов и их типов должны ограничиваться символама ASCII.
\ ------------------------------------------
\ Версии
\ 1.01 (15.12.2001) Исправлена ошибка: ресурсы с именами компилировались под NT неправильно
\ 1.02 (09.03.2007) WINAPI: вместо ~yz/lib/api.f
\ ------------------------------------------
REQUIRE "       ~yz/lib/common.f
REQUIRE (|      ~yz/lib/printf.f
REQUIRE {       lib/ext/locals.f
\ ------------------------------------------
CREATE input-file  256 ALLOT
CREATE output-file 256 ALLOT
\ ------------------------------------------

: err  ." FRES: " .ASCIIZ CR BYE ;
: ?err ( ? z --) SWAP IF err ELSE DROP THEN ;

: my-error ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP -2 = IF DROP 
                ER-A @ ER-U @ PAD CZMOVE PAD err
           THEN
  DUP 2 <| " Ошибка #%d (0x%06X)" |) err
;
\ ------------------------------------------
0xF0000000 == numflag
: name? ( n -- ?) numflag AND 0= ;
: setnumflag ( n -- n1) numflag OR ;
: clnumflag ( n -- n1) numflag INVERT AND ;
\ ------------------------------------------
WINAPI: CreateFileMappingA KERNEL32.DLL
WINAPI: MapViewOfFile KERNEL32.DLL
WINAPI: UnmapViewOfFile KERNEL32.DLL

0 VALUE fh
0 VALUE maph
0 VALUE file
0 VALUE input-file-size

0 VALUE ofh
0 VALUE omaph
0 VALUE ofile

VARIABLE file-ptr

: map-input-file
  input-file DUP ZLEN R/O OPEN-FILE " Входной файл не найден" ?err TO fh
  0 0 0 2 ( page_readonly) 0 fh CreateFileMappingA ?DUP 0= 
    " Не могу отобразить файл в памяти" ?err TO maph
  0 0 0 4 ( file_map_read) maph MapViewOfFile ?DUP 0= 
    " Не могу отобразить файл в памяти" ?err TO file ;

: unmap-input-file
  file UnmapViewOfFile DROP
  maph CloseHandle DROP
  fh CLOSE-FILE DROP ;

: map-output-file
  output-file DUP ZLEN R/W CREATE-FILE " Не могу создать выходной файл" ?err TO ofh
  0 input-file-size 2* 0 4 ( page_readwrite) 0 ofh CreateFileMappingA ?DUP 0= 
    " Не могу отобразить выходной файл в памяти" ?err TO omaph
  0 0 0 2 ( file_map_write) omaph MapViewOfFile ?DUP 0= 
    " Не могу отобразить выходной файл в памяти" ?err TO ofile 
  ofile file-ptr ! ;

: unmap-output-file
  ofile UnmapViewOfFile DROP
  omaph CloseHandle DROP
  file-ptr @ ofile - S>D ofh RESIZE-FILE DROP
  ofh CLOSE-FILE DROP ;
\ ------------------------------------------
WINAPI: GetAtomNameA KERNEL32.DLL

: >> ( n -- ) file-ptr @ !  CELL file-ptr +! ;
: W>> ( w -- ) file-ptr @ W! 2 file-ptr +! ;
: block>> ( a n -- ) >R file-ptr @ R@ CMOVE  R> file-ptr +! ;
: atom>> ( atom -- ) >R 300 HERE R> GetAtomNameA >R
  600 file-ptr @ 2+ R> HERE 0 0 MultiByteToWideChar DUP file-ptr @ W!
  2* 2+ file-ptr +! ;
: ?align-file ( -- )
  \ пользуемся тем, что все, записываемое в файл, уже выравнено на границу слова
  file-ptr @ ofile - CELL MOD IF 0 W>> THEN ;
\ ------------------------------------------
\ Корень дерева
0
CELL -- :begin    \ должно быть = :next = 0
CELL -- :treeref
CELL -- :names
CELL -- :ords
== root#
\ узел дерева
0 
CELL -- :next
CELL -- :strref
CELL -- :nextname
CELL -- :id
CELL -- :son
== node#
\ лист дерева
0
CELL -- :adr
CELL -- :leafref \ должно быть = :treeref
CELL -- :dataref
CELL -- :nextleaf
CELL -- :size
== leaf#

0 VALUE type-tree

: new ( size -- a)
  DUP >R GETMEM DUP R> ERASE ;
: new-tree ( -- a) root# new ;
: new-node ( -- a) node# new ;
: new-leaf ( -- a) leaf# new ;

WINAPI: AddAtomA KERNEL32.DLL

: get-son { tree id newproc \ -- son }
  tree :begin @ ?DUP IF
    BEGIN
      DUP :id @ id = IF ( нашли) :son @ EXIT THEN
      :next DUP @ ?DUP IF PRESS 0 ELSE -1 THEN
    UNTIL \ не нашли: создаем новый узел и новое дерево к нему
  ELSE
    tree :begin
  THEN
  new-node >R
  tree id name? IF :names ELSE :ords THEN 1+!
  R@ SWAP :next !
  id R@ :id !
  newproc EXECUTE DUP R> :son !
;

: get-tree ( tree id -- tree1 )
  ['] new-tree get-son ;

: get-leaf ( tree id -- leaf )
  ['] new-leaf get-son
;

: >id ( adr -- id)
  DUP W@ 0xFFFF = IF 
    2+ W@ setnumflag \ чтобы можно было отличить от строк
  ELSE
    unicode>buf DUP AddAtomA SWAP FREEMEM
  THEN ;

: add-to-tree
  { type name langid dataadr datasize \ -- }
  type-tree type >id get-tree
  name >id get-tree langid setnumflag get-leaf >R
  dataadr  R@ :adr  !
  datasize R> :size !
;  
\ ------------------------------------------
\ простая обменная сортировка. Списки короткие, хватит и такой
: sort { tree lt \ start min minnode -- }
  tree :begin @ TO start
  BEGIN start :next @ WHILE
    start TO minnode
    start :id @ TO min
    start
    BEGIN
      ( node)
      DUP :id @ min lt EXECUTE IF
        DUP TO minnode
        DUP :id @ TO min
      THEN
      :next @
    ?DUP 0= UNTIL
    start minnode <> IF \ меняем местами данные
      \ это безопасно, поскольку относительных ссылок там нет
      start CELL+ HERE node# CELL - DUP >R CMOVE
      minnode CELL+ start CELL+ R@ CMOVE
      HERE minnode CELL+ R> CMOVE
    THEN
    start :next @ TO start
  REPEAT
;
\ обойти дерево, выполнив в каждом узле операцию xt
\ xt ( node -- )
: traverse-tree ( tree xt --)
  >R
  :begin @ ?DUP IF \ дерево непустое?
    BEGIN
      DUP R@ EXECUTE
      :next @ ?DUP
    0= UNTIL
  THEN
  RDROP
;
\ выполнить для дерева операцию xt1, а потом обойти дерево с операцией xt
\ xt ( node -- )
\ xt1 ( tree -- )
: do-it-and-traverse-tree ( tree xt xt1 --)
  >R OVER R> EXECUTE traverse-tree ;

\ обойти дерево с операцией xt, потом выполнить над ним операцию xt1
\ xt ( node -- )
\ xt1 ( tree -- )
\ : traverse-tree-and-do-it ( tree xt xt1 --)
\  >R >R DUP R> traverse-tree R> EXECUTE ;  

WINAPI: lstrcmp KERNEL32.DLL

: atom>str ( atom adr -- )
  SWAP 300 ROT ROT GetAtomNameA DROP ;

: ord/uni< ( o/u1 o/u2 -- ?)
  2DUP OR name? IF
    \ это два атома, изображающие строки
    HERE atom>str HERE 300 + atom>str
    HERE HERE 300 + lstrcmp 0<
  ELSE
    \ хватит и простого сравнения. Если это два числа, то U< их упорядочивает.
    \ а если число и атом, то атомы гарантированно меньше чисел с установленным
    \ старшим битом, что и требуется
    U<
  THEN ;

: (.tree2) ( tree -- )
  ." Tree " DUP .H ." names=" DUP :names @ . ." ords=" :ords @ . CR ;
: (.tree1) ( node -- )
  ." node: id=" DUP :id @ .H ." son=" :son @ .H CR ;
: .tree ( tree -- )
  ['] (.tree1) ['] (.tree2) do-it-and-traverse-tree ;

: ord/uni-sort ( tree -- ) ['] ord/uni< sort ;

: sort-lang-tree ( node -- )
  :son @ ['] < sort ;
: sort-name-tree ( node -- )
  :son @ ['] sort-lang-tree ['] ord/uni-sort do-it-and-traverse-tree ;
: sort-all-trees
  type-tree ['] sort-name-tree ['] ord/uni-sort do-it-and-traverse-tree 
;
\ ------------------------------------------
\ обойти дерево, выполнить в каждом узле xt ( node -- ) и уничтожить этот узел
\ потом уничтожить дерево
: last-traverse-tree ( tree xt -- )
  OVER >R
  >R
  :begin @ ?DUP IF \ дерево непустое?
    BEGIN
      DUP R@ EXECUTE
      DUP >R
      :next @ ?DUP 0=
      R> FREEMEM 
    UNTIL
  THEN
  RDROP  R> FREEMEM ;

: chop-lang-son ( node -- )
  :son @ FREEMEM ;
: chop-name-son ( node -- )
  :son @ ['] chop-lang-son last-traverse-tree ;
: chop-type-son ( node -- )
  :son @ ['] chop-name-son last-traverse-tree ;
: chop-tree 
  type-tree ['] chop-type-son last-traverse-tree ;
\ ------------------------------------------
: ?offset>> ( to -- ) \ записать текущее смещение в файле по адресу to<>0
  ?DUP IF file-ptr @ ofile - 0x80000000 OR SWAP ! THEN ;

: ?offset0>> ( to -- ) \ записать текущее смещение в файле по адресу to<>0
  ?DUP IF file-ptr @ ofile - SWAP ! THEN ;

VARIABLE name-begin
VARIABLE last-name

VARIABLE leaf-begin
VARIABLE last-leaf

\ struct _IMAGE_RESOURCE_DIRECTORY_ENTRY {
\   ULONG   Name;
\   ULONG   OffsetToData; }
: write-entries ( node -- )
  >R
  R@ :id @ name? IF
    \ это строка. запишем ее позже
    file-ptr @ R@ :strref !
    R@ last-name @ !
    R@ :nextname last-name !
    CELL" NAME" >>
  ELSE
   \ это число
    R@ :id @ clnumflag >>
  THEN
  \ ссылку на поддерево запишем позже
  file-ptr @ R> :son @ :treeref !
  CELL" DOWN" >>
;  

\ struct _IMAGE_RESOURCE_DIRECTORY {
\    ULONG   Characteristics;
\    ULONG   TimeDateStamp;
\    USHORT  MajorVersion;
\    USHORT  MinorVersion;
\    USHORT  NumberOfNamedEntries;
\    USHORT  NumberOfIdEntries; }
: write-dir ( tree -- )
  DUP :treeref @ ?offset>>
  0 >> 0 >> 0 >>
  DUP :names @ W>>
  DUP :ords  @ W>>
  ['] write-entries traverse-tree ;

: write-lang-nodes ( lang-nodes -- ) 
  :son @ 
  DUP last-leaf @ !
  :nextleaf last-leaf !
;

: write-name-nodes ( name-node -- )
  :son @ ['] write-lang-nodes ['] write-dir do-it-and-traverse-tree ;

: .restype ( restype --)
  DUP name? IF
    HERE atom>str
    HERE
  ELSE
    clnumflag
  CASE
  1 OF " Cursor      " ENDOF
  2 OF " Bitmap      " ENDOF
  3 OF " Icon        " ENDOF
  4 OF " Menu        " ENDOF
  5 OF " Dialog      " ENDOF
  6 OF " String      " ENDOF
  7 OF " FontDir     " ENDOF
  8 OF " Font        " ENDOF
  9 OF " Accelerator " ENDOF
 10 OF " RCdata      " ENDOF
 12 OF " GroupCursor " ENDOF 
 14 OF " GroupIcon   " ENDOF 
 16 OF " Version     " ENDOF 
 17 OF " DlgInclude  " ENDOF 
 19 OF " PlugPlay    " ENDOF 
 20 OF " Vxd         " ENDOF 
 21 OF " AniCursor   " ENDOF 
 22 OF " AniIcon     " ENDOF 
   1 <| " Type%-8d" |)
 END-CASE
 THEN
 .ASCIIZ SPACE ;
 
: write-type-nodes ( type-node -- )
  DUP :id @ .restype  DUP :son @ DUP :names @ SWAP :ords @ + . CR
  :son @ ['] write-name-nodes ['] write-dir do-it-and-traverse-tree ;

: write-names ( -- )
  name-begin @ ?DUP 0= IF EXIT THEN 
  BEGIN
    DUP :strref @ ?offset>>
    DUP :id @ atom>>
    :nextname @ 
  ?DUP 0= UNTIL 
  ?align-file ;

\ struct _IMAGE_RESOURCE_DATA_ENTRY {
\   ULONG   OffsetToData;
\   ULONG   Size;
\   ULONG   CodePage;
\   ULONG   Reserved; }
: write-leafs ( -- )
  leaf-begin @ ?DUP 0= IF EXIT THEN 
  BEGIN
    >R 
    R@ :leafref @ ?offset0>>
    file-ptr @ R@ :dataref !
    CELL" RSRC" >>
    R@ :size @ >>
    0 >> 0 >>
    R> :nextleaf @ 
  ?DUP 0= UNTIL ;

: write-data ( -- )
  leaf-begin @ ?DUP 0= IF EXIT THEN 
  BEGIN
    DUP :dataref @ ?offset0>> 
    DUP :adr @ OVER :size @ block>>
    ?align-file
    :nextleaf @ 
  ?DUP 0= UNTIL ;

: write-to-file
  map-output-file
  name-begin last-name !
  leaf-begin last-leaf !
  name-begin 0!
  leaf-begin 0!
  type-tree ['] write-type-nodes ['] write-dir do-it-and-traverse-tree
  write-names
  write-leafs
  write-data
  unmap-output-file
;
\ ------------------------------------------
: align-dword ( a -- a') DUP CELL MOD IF 2+ THEN ;
: ord/uni-beyond ( a -- a')
  DUP W@ 0xFFFF = IF
    CELL+
  ELSE
    BEGIN DUP W@ 0 <> WHILE
      2+
    REPEAT
    2+
  THEN ;

\ struct RESOURCEHEADER {  
\    DWORD DataSize; 
\    DWORD HeaderSize; 
\    [Ordinal or name TYPE]; 
\    [Ordinal or name NAME];
\    ? word для выравнивания
\    DWORD DataVersion; 
\    WORD MemoryFlags; 
\    WORD LanguageId; 
\    DWORD Version; 
\    DWORD Characteristics; }; 

: enumerate-resources 
  { \ file-end ptr -- }
  fh FILE-SIZE 2DROP DUP TO input-file-size file + TO file-end
  file TO ptr
  BEGIN ptr file-end < WHILE
  \ пропускаем сомнительную запись с DataSize=0, которую компилятор ставит первой
    ptr @ IF 
      ptr 2 CELLS+ ( type) DUP ord/uni-beyond ( name)
      DUP ord/uni-beyond align-dword CELL+ 2+ DUP W@ ( lang id)
      SWAP 2+ 2 CELLS+ ( dataadr) ptr @ ( datasize) add-to-tree
    THEN
    ptr @ ptr CELL+ @ + align-dword ^ ptr +!
  REPEAT ;
\ ------------------------------------------
: ?next ( "name" или name<BL> -- a # / 0)
  PeekChar c: " = IF c: " ELSE BL THEN WORD
  DUP C@ 0= IF DROP 0 EXIT THEN
  COUNT OVER C@ c: " = IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть)
;

: -ext { a n -- a #1 }
  a n + 1-
  BEGIN DUP a < NOT WHILE
    DUP C@ c: . = IF a - a SWAP EXIT THEN
    1-
  REPEAT DROP a n ;

: +ext ( a # -- a1 #1)
  -ext
  DUP >R PAD SWAP CMOVE R> PAD + 
  S" .FRES" ROT 2DUP + 1+ >R CZMOVE
  PAD R> OVER -
;

: RUN
  ['] my-error TO ERROR
  -1 TO SOURCE-ID 
  GetCommandLineA ASCIIZ> SOURCE!
  ?next 2DROP  \ убрали имя файла
  ?next 
  ?DUP 0= IF
    ." FRES 1.01  Преобразует стандартный файл ресурсов .RES в формат .FRES" CR
    ." Вызов: FRES вхфайл [выхфайл]" CR
    BYE
  THEN
  ( a #) input-file CZMOVE
  ?next ?DUP 0= IF input-file DUP ZLEN +ext THEN output-file CZMOVE
  new-tree TO type-tree
  map-input-file
  enumerate-resources
  sort-all-trees
  write-to-file
  chop-tree
  unmap-input-file
  BYE ;

0 TO SPF-INIT?
' RUN MAINX !
S" fres.exe" SAVE  
BYE

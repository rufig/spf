( addr_exe u_exe addr_fres u_fres -- )
\ Сохраняет текущюю форт систему в exe с ресурсами из fres файла;
\ если ресурсы не нужны, то u_fres = 0.
\ Особенность pesave - работает во временном словаре и не
\ остается в готовом исполняемом файле.
\ Должна грузиться последней, поскольку портит некоторые структуры,
\ используемые словом USE для импорта
\ А. Филаткин, http://www.forth.org.ru/~af (библиотека)
\ Ю. Жиловец,  http://www.forth.org.ru/~yz (ресурсы, импорт)

DECIMAL

GET-CURRENT
TEMP-WORDLIST DUP ALSO CONTEXT ! DEFINITIONS

0x080 CONSTANT START-PE-HEADER
0x400 CONSTANT SIZE-HEADER
0x2000 CONSTANT BASEOFCODE
0 VALUE END-CODE-SEG
0 VALUE END-RES-SEG
0 VALUE END-IMP-SEG
TRUE VALUE ?Res
0 VALUE START-SECTHEADER
0 VALUE RES-RELOCATION

: relocate ( adr xt -- ) 
\ применить ко всем элементам каталога adr слово xt
  >R
  DUP 12 + W@ ( именованные записи) OVER 14 + W@ ( неименованные записи) +
  SWAP 16 + SWAP
  BEGIN ( adr #) DUP WHILE
    OVER CELL+ @ 0x7FFFFFFF AND END-IMP-SEG + R@ EXECUTE
  SWAP 2 CELLS + ( длина записи) SWAP 1-
  REPEAT 2DROP
  RDROP
;

: relocate3 ( leaf --) RES-RELOCATION SWAP +! ;
: relocate2 ( dir -- ) ['] relocate3 relocate ;
: relocate1 ( dir -- ) ['] relocate2 relocate ;

: ADD-RES ( addr u -- )
  DUP IF
    R/O OPEN-FILE THROW >R
    END-IMP-SEG R@ FILE-SIZE 2DROP R@ READ-FILE THROW ALLOT
    \ добавить ко всем адресам ресурсов поправку на начало сегмента ресурсов
    IMAGE-SIZE BASEOFCODE + END-IMP-SEG - END-CODE-SEG + TO RES-RELOCATION
    END-IMP-SEG ['] relocate1 relocate 
    R> CLOSE-FILE DROP
  ELSE
    2DROP
  THEN ;

: align-here ( n -- ) ALIGN-BYTES @ SWAP ALIGN-BYTES ! ALIGN ALIGN-BYTES ! ;
: SEG-ALIGN ( -- ) 512 align-here ;
: align2  2 align-here ;
: align4  4 align-here ;

: RVA, ( n -- ) IMAGE-SIZE + BASEOFCODE + END-CODE-SEG - , ;

: Z, ( z -- ) DUP HERE ZMOVE ZLEN 1+ ALLOT ;

: ADD-IMPORT
  \ берем готовую таблицу импорта и скидываем ее данные
  HERE ( адрес начала каталогов)
  \ резервируем место под n+1 каталогов
  IMPORT-DIR DYNSIZE /importdir + ALLOT
  \ скидываем имена библиотек и списки
  \ сохраняем в каталоге их адреса для последующей вставки в файл
  IMPORT-DIR DUP DYNSIZE OVER + SWAP DO
    \ запишем имя библиотеки
    I :idlibname @ DUP CELL+ @ + CELL+ 
    HERE I :idlibname !
    Z, align4
    \ сохраним список имен, попутно записывая его адреса в память вместо старых
    I :idlist1 @ DUP I :idfwdchain ! \ адрес списка имен временно припрячем здесь
    I :iddatetime @ CELLS OVER + SWAP DO
      \ ставим вместо хинта 0 - все равно они меняются от версии к версии Windows
      I @ HERE I ! 0 W, Z, align2
    CELL +LOOP
    align4
    \ запишем первый список
    HERE I :idlist1 !
    I :idfwdchain @  I :iddatetime @ CELLS OVER + SWAP DO
      I @ RVA,
    CELL +LOOP
    0 ,
    \ запишем второй список
    HERE I :idlist2 !
      I :idfwdchain @  I :iddatetime @ CELLS OVER + SWAP DO
      I @ RVA,
    CELL +LOOP
    0 ,
  /importdir +LOOP
  \ заполним каталоги, подменив DP
  HERE SWAP DP !
  IMPORT-DIR DUP DYNSIZE OVER + SWAP DO
    I :idlist1 @ RVA,   \ первый список
    0 ,                 \ дата и время
    -1 ,                \ переадресация импорта
    I :idlibname @ RVA, \ имя библиотеки
    I :idlist2 @ RVA,   \ второй список
  /importdir +LOOP
  \ пустой каталог импорта завершает таблицу
  0 , 0 , 0 , 0 , 0 ,
  DP ! ;

: SAVE ( offset c-addr u -- )
  ( сохранение наработанной форт-системы в EXE-файле формата PE - Win32 )
  R/W CREATE-FILE THROW >R
  ModuleName R/O OPEN-FILE-SHARED THROW >R
  HERE SIZE-HEADER R@ READ-FILE THROW SIZE-HEADER < THROW
  R> CLOSE-FILE THROW

  \ если ресурсов нет (u_coff = 0), то END-IMP-SEG = END-RES-SEG
  END-IMP-SEG END-RES-SEG = 0= TO ?Res

  ?Res IF 3 ELSE 2 THEN HERE START-PE-HEADER 0x06  + + W! ( Num of Objects )
  ?GUI IF 2 ELSE 3 THEN HERE START-PE-HEADER 0x5C  + + W! ( Subsystem )
  BASEOFCODE            HERE START-PE-HEADER 0x28  + +  ! ( EntryPointRVA )
  IMAGE-BASE            HERE START-PE-HEADER 0x34  + +  ! ( ImageBase )
  IMAGE-SIZE BASEOFCODE + END-RES-SEG END-IMP-SEG - 0xFFF + 0x1000 / 0x1000 * +
                        HERE START-PE-HEADER 0x50  + +  ! ( ImageSize )
  IMAGE-SIZE BASEOFCODE + 
                        HERE START-PE-HEADER 0x80  + + !  ( ImportRVA )
  END-IMP-SEG END-CODE-SEG -
                        HERE START-PE-HEADER 0x84  + + !  ( ImportSize )
  ?Res IF IMAGE-SIZE BASEOFCODE + END-IMP-SEG END-CODE-SEG - + ELSE 0 THEN
                        HERE START-PE-HEADER 0x88  + + !  ( ResourcesRVA )
  ?Res IF END-RES-SEG END-IMP-SEG - ELSE 0 THEN
                        HERE START-PE-HEADER 0x8C  + + !  ( ResourcesSize )
  IMAGE-SIZE            HERE START-PE-HEADER 0x128 + + !  ( VirtualSize code)
  END-IMP-SEG IMAGE-BEGIN -
                        HERE START-PE-HEADER 0x130 + + !  ( PhysicalSize code)
  \ Копирайт вписываем в бывшую секцию импорта - она теперь все равно свободна
  S" SP-FORTH 4.0 (c) RUFIG http://www.forth.org.ru"
                      HERE START-PE-HEADER 0x180 + + SWAP CMOVE
  HERE START-PE-HEADER 0x180 + + 12 CELLS + 16 CELLS ERASE

  \ Секция импорта
  HERE 0x178 + TO START-SECTHEADER
  START-SECTHEADER 0x28 ERASE
  ?Res IF
    S" .idata"             START-SECTHEADER SWAP CMOVE     \ section name
    END-IMP-SEG END-CODE-SEG - 0xFFF + 0x1000 / 0x1000 *
                          START-SECTHEADER 0x08 + !       \ sect virtual size
    IMAGE-SIZE BASEOFCODE +
                          START-SECTHEADER 0x0C + !       \ sect RVA
    END-IMP-SEG END-CODE-SEG -
                          START-SECTHEADER 0x10 + !       \ sect physical size
    END-CODE-SEG IMAGE-BEGIN - SIZE-HEADER +
                              START-SECTHEADER 0x14 + !       \ sect file offset
                          START-SECTHEADER 0x18 + 0xC ERASE
    0xE0000020            START-SECTHEADER 0x24 + !       \ sect flags: code, read, write, exec
  THEN

  \ Секция ресурсов
  HERE 0x1C8 + TO START-SECTHEADER
  START-SECTHEADER 0x38 ERASE
  ?Res IF
    S" .rsrc"             START-SECTHEADER SWAP CMOVE     \ section name
    END-RES-SEG END-IMP-SEG - 0xFFF + 0x1000 / 0x1000 *
                          START-SECTHEADER 0x08 + !       \ sect virtual size
    IMAGE-SIZE BASEOFCODE + END-IMP-SEG END-CODE-SEG - +
                          START-SECTHEADER 0x0C + !       \ sect RVA
    END-RES-SEG END-IMP-SEG -
                          START-SECTHEADER 0x10 + !       \ sect physical size
    END-IMP-SEG IMAGE-BEGIN - SIZE-HEADER +
                          START-SECTHEADER 0x14 + !       \ sect file offset
                          START-SECTHEADER 0x18 + 0xC ERASE
    0x40000040            START-SECTHEADER 0x24 + !       \ sect flags: read, ini
  THEN

  \ занесем новое значение таблицы импорта
  IMAGE-SIZE BASEOFCODE + IMAGE-BASE + TO IMPORT-DIR
  \ поправка для RVA, хранящихся в таблице импорта
  IMAGE-BASE TO IMPORT-RELOC

  HERE SIZE-HEADER R@ WRITE-FILE THROW ( заголовок и таблица импорта )
  IMAGE-BEGIN HERE OVER -
  ROT ALLOT
  R@ WRITE-FILE THROW

  \ а теперь хак по-живому: прямо в файле меняем в процедуре _WINAPI-CODE
  \ ссылки на процедуры LoadLibraryA и GetProcAddress
  \ Работать это будет до ближайшего релиза СП-Форта
  \ По-хорошему, надо править сам WINAPI-CODE
  0x1F5F 0 R@ REPOSITION-FILE THROW
  HERE 4 R@ READ-FILE THROW DROP
  HERE @ 0x541034 <> ABORT" Не та версия Форта!"
  IMPORT-DIR 0x8C + HERE !
  0x1F5F 0 R@ REPOSITION-FILE THROW
  HERE 4 R@ WRITE-FILE THROW

  0x1F74 0 R@ REPOSITION-FILE THROW
  HERE 4 R@ READ-FILE THROW DROP
  HERE @ 0x541038 <> ABORT" Не та версия Форта!"
  0x1F74 0 R@ REPOSITION-FILE THROW
  IMPORT-DIR 0x90 + HERE !
  HERE 4 R@ WRITE-FILE THROW

  R> CLOSE-FILE THROW
;


SWAP SET-CURRENT

HERE
SEG-ALIGN
HERE TO END-CODE-SEG

ADD-IMPORT
SEG-ALIGN
HERE TO END-IMP-SEG

2SWAP ADD-RES

SEG-ALIGN
HERE TO END-RES-SEG

HERE -

2SWAP SAVE
PREVIOUS
FREE-WORDLIST

\ 30-11-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ задачка с конкурса на форуме http://fforum.winglion.ru/viewtopic.php?t=1048

 REQUIRE >CIPHER   devel\~moleg\lib\parsing\number.f
 REQUIRE cmdline>  devel\~mOleg\lib\util\parser.f
 REQUIRE SPELLS    devel\~moleg\lib\util\spells.f
 REQUIRE s"        devel\~moleg\lib\strings\string.f
 REQUIRE onward    devel\~moleg\lib\strings\subst.f
 REQUIRE xWord     devel\~moleg\lib\parsing\xWordn.f

      0 VALUE sourceid   \ id файла исходника
      0 VALUE 'source
      0 VALUE #source
      0 VALUE collector  \ id файла приемника
      0 VALUE colbuf
      0 VALUE ^collector

\ помощь по использованию
SPELL: /? ( --> )
          s" \tusage: transttf.exe test.ttf [test2.bin]\n\r" TYPE
          BYE ;S

\ разбор ком. строки, открытие файлов
SECRET: NOTFOUND ( asc # --> )
                 <back ParseFileName 2DUP FILE-EXIST
                 IFNOT ." \tInvalid source file: " TYPE CR BYE THEN
                 2DUP R/O OPEN-FILE IF ." \tCan't open source file: " TYPE CR EXIT THEN
                 TO sourceid
                 SeeForw NIP IF 2DROP ParseFileName
                              ELSE S" *.bin" onward
                             THEN 2DUP
                 W/O CREATE-FILE IF ." \tCan't create result file: " TYPE CR EXIT THEN
                 TO collector 2DROP
                 [COMPILE] \ ;S

\ читаем весь исходник в память.
: ReadSource ( --> )
             sourceid FILE-SIZE 2DROP \ считаем, что размер файла меньше 4 G
             DUP TO #source
             ALLOCATE THROW TO 'source \ считаем что получилось
             'source #source sourceid READ-FILE THROW
             #source <> THROW ;

\ выделить место под результирующий массив
: InitReceiver ( --> )
               #source 2/ ALLOCATE THROW DUP TO colbuf TO ^collector
               ;

\ сохранить результат
: SaveBuf ( --> ) colbuf ^collector OVER - collector WRITE-FILE THROW ;


 s" \000\t\n\r, " Delimiter: delimiters

\ преобразование исходного текста
: Transform ( --> )
            'source #source SOURCE!
            BEGIN EndOfChunk WHILENOT

               BEGIN delimiters xWord DUP WHILENOT
                     2DROP EndOfChunk WHILENOT
                     >IN 1+!
                 REPEAT EXIT
               THEN

               0 0 2SWAP >NUMBER IF -1 THROW ELSE 2DROP THEN
               ^collector TUCK B! 1 + TO ^collector

            REPEAT ;

\ главное слово программы
: transttf ( --> )
           options
           sourceid IFNOT [ ALSO SPELLS ] /? [ PREVIOUS ] BYE THEN
           ReadSource  InitReceiver  Transform  SaveBuf
           sourceid CLOSE-FILE DROP collector CLOSE-FILE DROP
           BYE ;

\ сохранение результата в отдельный файл:

' transttf MAINX !

S" transttf.exe" SAVE




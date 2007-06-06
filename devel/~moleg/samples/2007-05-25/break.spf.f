\ 25-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ решение задачи с конкурса открытого на форуме
\ программа разбивающая большой текстовый файл на маленькие
\ вариант для СПФ4.18

  REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
  REQUIRE s"       devel\~moleg\lib\strings\string.f
  REQUIRE onward   devel\~moleg\lib\strings\subst.f
  REQUIRE RECENT   devel\~moleg\lib\util\useful.f

\ установить SOURCE на строку параметров »
: cmdline> ( --> )
           -1 TO SOURCE-ID
           GetCommandLineA ASCIIZ> SOURCE!
           ParseFileName 2DROP ;

\ компилировать двойное число на вершину кодофайла
: D, ( d --> ) HERE 2 CELLS ALLOT 2! ;

\ создать именованую переменную для хранения двойного числа
: dVar ( / name --> ) CREATE 0 0 D, DOES> ;

        VARIABLE ResultFile# \ размер результирующего файла в байтах
        VARIABLE parts       \ количество частей, на которые надо разбить файл

\ преобразовать указанное число килобайт в кол-во байт
: kBytes ( u --> d ) 1024 * ;

\ преобразовать указанное число мегабайт в кол-во байт
: mBytes ( n --> d ) kBytes kBytes ;

 64 kBytes ResultFile# !  \ предустановленный размер 64 кб

        VECT ?waiting
: BYE ?waiting BYE ;

\ максимальный размер результирующего файла не может превышать 4G

        VARIABLE b|n

\ уже введена подобная опция?
: ?alone ( --> )
         b|n @ IF ." Must be only one spell: -n or -b\n\r" BYE
                ELSE TRUE b|n !
               THEN ;

\ преобразовать число
: ?numb ( / numb --> d )
        0 0 NextWord >NUMBER IF ." \n\r Invaid number." BYE THEN DROP D>S ;

      0 VALUE SourceFile \ имя исходного файла
      0 VALUE FileMask   \ маска
      0 VALUE Prototype \ результат преобразования имени файла с помощью маски

\ сохранить строку в хипе, вернуть адрес начала
: SaveString  ( asc # --> addr )
              DUP CELL + char + ALLOCATE THROW
              2DUP ! DUP >R CELL + SWAP 2DUP
              2>R CMOVE 2R> + 0 SWAP C! R> ;

\ по адресу строки получить ее начало и размер
: string> ( addr --> asc # ) DUP CELL + SWAP @ ;

\ откатить >IN назад, на начало непонятого слова
: <back ( ASC # --> ) DROP TIB - >IN ! ;

   TRUE VALUE part-name-add  \ добавлять ли имя части в начало файла

\ типа прогресс индикатор 8)
\ вобщем-то не обязательная вещь.
CREATE s-progress S"  І№ЅoO0OoЅ№" S",   VARIABLE iter
: ~progress ( --> )
            s-progress COUNT iter @ SWAP MOD + C@ EMIT 0x08 EMIT
            1 iter +! ;

\ -- ключи командной строки --------------------------------------------------

\ это на случай, если имя файла не предварено ключем -s
VOCABULARY expand
           ALSO expand DEFINITIONS

\ пробуем строку распознать, как имя файла.
: NOTFOUND ( asc # --> )
           OVER C@ [CHAR] " =
           IF <back ParseFileName THEN

           SeeForw NIP IF ." \n\rInvalid option: " TYPE BYE THEN
           SourceFile IF ." \n\rSuperfluous parameter: " TYPE BYE THEN
           SaveString TO SourceFile ;

RECENT

VOCABULARY COMMANDS
           ALSO COMMANDS DEFINITIONS

  \ подсказка - если встречается в командной строке - выполнение программы
  \ прерывается, выводится помощь
  : -h ( --> )
       ." \r command line options are:"
       ." \n\t -h & /h  this help"
       ." \n\t /? & -?  spell list"
       ." \n\t -b num   result file size specificator"
       ." \n\t -f mask  result files naming rules"
       ." \n\t -s file  source file name"
       ." \n\t -n num   result file count rules"
       ." \n\t -p       don't write part name at start of file"
       ." \n\nSample: break.exe -n 10 -f *##.* [-s] FileName"
       ;
  : /h ( --> ) -h ;

  \ подсказка по ключам
  : /? ( --> )
       ." \r spells are: "
       GET-ORDER SWAP NLIST BYE ;
  : -? /? ;

  \ указывает размер файлов, на который надо разбивать исходный
  : -b  ( / numb --> ) ?alone ?numb ResultFile# ! ;
  : -kb ( / numb --> ) ?alone ?numb kBytes ResultFile# ! ;
  : -mb ( / numb --> ) ?alone ?numb mBytes ResultFile# ! ;

  \ на какое кол-во частей надо разбить исходный файл
  : -n ( / numb --> ) ?alone ?numb parts ! ;

  \ правило именования результирующих файлов
  : -f ( / mask --> )
       FileMask IF FileMask FREE DROP THEN \ повторение -f не запрещается
       ParseFileName SaveString TO FileMask ;

  \ имя исходного файла.
  : -s ( / filename --> )
       SourceFile IF SourceFile FREE DROP THEN \ повторение -s не запрещается
       ParseFileName SaveString TO SourceFile ;

  \ опция для отключения сохранения имен в начале каждой части
  : -p ( --> ) FALSE TO part-name-add ;

RECENT

\ ----------------------------------------------------------------------------

\ проверить наличие исходного файла
: ?source ( --> flag )
          SourceFile DUP IFNOT ." \n\r source file missing." BYE THEN
          string> FILE-EXIST ;

      0 VALUE sourceId     \ рукоядка исходного файла
        dVar  SourceFile#  \ размер исходного файла

\ открыть исходный файл на чтение
: open-source ( --> )
              ?source IFNOT ." \n\rInvalid source file name: "
                            SourceFile string> ANSI>OEM TYPE BYE
                      THEN
              SourceFile string> R/O OPEN-FILE
              IF ." \n\r Can't open file." BYE THEN DUP TO sourceId
              FILE-SIZE THROW SourceFile# 2! ;

\ сформировать имя результирующего файла
: outname ( --> )
          SourceFile string> FileMask string>
          onward SaveString TO Prototype ;

        VARIABLE volume \ номер текущего тома
      0 VALUE part#     \ размер текущего сохраненного файла

\ создать новый том
: new-file ( --> handle )
           volume DUP @ SWAP 1+!
           Prototype string> ROT partnum
           2DUP 2>R W/O CREATE-FILE THROW
           part-name-add IF 2R@ DUP 2 CHARS + TO part#
                            ROT DUP >R WRITE-LINE THROW R>
                          ELSE 0 TO part#
                         THEN
           2R> ." \r In progress: " ANSI>OEM TYPE ;

\ посчитать размер получаемого файла исходя из количества частей.
: measure ( --> )
          SourceFile# 2@ parts @ UM/MOD + DUP 100 / +
          ResultFile# ! ;

\ символ перевода строки ?
: ?eol ( addr --> flag ) C@ 0x0A = ;

\ найти последний перевод строки в буфере
: ScanBack ( start end --> addr TRUE|FALSE )
           OVER UMAX
           BEGIN 2DUP <> WHILE
                 DUP ?eol WHILENOT
                 char -
              REPEAT NIP char + TRUE EXIT
           THEN 2DROP FALSE ;

      0 VALUE buffer   \ адрес начала временного буфера
      0 VALUE ^start   \ адрес начала
      0 VALUE ^end     \ указатель на конец буфера

\ вернуть адрес и длину остатка содержимого входного буфера
: _rest> ( --> asc # ) ^start ^end OVER - ;

\ сбросить остаток содержимого буфера на диск
: save-rest ( dest-id --> )
            >R _rest> TUCK
            IF OVER R> WRITE-FILE THROW
             ELSE R> 2DROP
            THEN part# + TO part# ;

\ предельный размер буфера выше которого ему не стоит расти
\ в принципе можно выделять большой буфер, но ведь 3G буфер
\ всеравно не получится выделить...
100 kBytes CONSTANT buff-limit

\ заполнить входной буфер
: revive ( --> flag )
         ~progress
         buffer DUP TO ^start ResultFile# @ buff-limit UMIN
         sourceId READ-FILE THROW
         DUP buffer + TO ^end ;

\ сохранить блок, ограниченный сверху символом перевода строки.
: save-block ( file-id --> )
             >R ^start DUP ResultFile# @ part# - + char -
            2DUP ScanBack IF NIP THEN TO ^start
             ^start OVER - R> WRITE-FILE THROW ;

\ сохранить данные в файл
: save-data ( dest-id --> flag )
            ResultFile# @ _rest> NIP - 100 <
            IF save-block TRUE EXIT THEN

            BEGIN DUP save-rest revive WHILE
                  _rest> NIP part# + ResultFile# @ < WHILE
              REPEAT save-block TRUE EXIT
            THEN save-rest FALSE ;

\ создать буффер для промежуточного хранения данных файла
: arise ( # --> addr )
        ResultFile# @ buff-limit UMIN
        ALLOCATE THROW ;

\ основной цикл программы
: PROCESS-FILES ( --> )
                open-source
                 parts @ IF measure THEN
                 outname 1 volume !
                 arise TO buffer
                  BEGIN new-file DUP >R save-data WHILE
                        R> CLOSE-FILE DROP
                  REPEAT R> CLOSE-FILE
                 buffer FREE DROP
                sourceId CLOSE-FILE DROP ;

\ инициализация опций командной строки
: init ( --> )
       cmdline> COMMANDS SEAL ALSO expand UNDER
       S" name.####.*" SaveString TO FileMask
       SOURCE DROP C@ [CHAR] " = IF ['] KEY TO ?waiting THEN
       ;

\ главное слово
: break ( --> )
        init SeeForw NIP
        IFNOT [ ALSO COMMANDS ] -h [ PREVIOUS ]
         ELSE ['] INTERPRET CATCH
              IF ."  .\n\rInternal error."
               ELSE ['] PROCESS-FILES CATCH DROP
              THEN
        THEN BYE ;

\ -- сохранение в файл -------------------------------------------------------

' break MAINX !

S" break.exe" SAVE


( Файловый ввод-вывод.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

: CLOSE-FILE ( fileid -- ior ) \ 94 FILE
\ Закрыть файл, заданный fileid.
\ ior - определенный реализацией код результата ввода/вывода.
  CloseHandle ERR
;

: CREATE-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Создать файл с именем, заданным c-addr u, и открыть его в соответствии
\ с методом доступа fam. Смысл значения fam определен реализацией.
\ Если файл с таким именем уже существует, создать его заново как
\ пустой файл.
\ Если файл был успешно создан и открыт, ior нуль, fileid его идентификатор,
\ и указатель чтения/записи установлен на начало файла.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  0 ( secur )
  0 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

CREATE SA 12 , 0 , 1 ,

: CREATE-FILE-SHARED ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  SA ( secur )
  3 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: OPEN-FILE-SHARED ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  3 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

: DELETE-FILE ( c-addr u -- ior ) \ 94 FILE
\ Удалить файл с именем, заданным строкой c-addr u.
\ ior - определенный реализацией код результата ввода/вывода.
  DROP DeleteFileA ERR
;

USER lpDistanceToMoveHigh

: FILE-POSITION ( fileid -- ud ior ) \ 94 FILE
\ ud - текущая позиция в файле, идентифицируемом fileid.
\ ior - определенный реализацией код результата ввода/вывода.
\ ud неопределен, если ior не ноль.
  >R FILE_CURRENT lpDistanceToMoveHigh DUP 0! 0 R>
  SetFilePointer
  DUP -1 = IF GetLastError ELSE 0 THEN
  lpDistanceToMoveHigh @ SWAP
;

: FILE-SIZE ( fileid -- ud ior ) \ 94 FILE
\ ud - размер в символах файла, идентифицируемом fileid.
\ ior - определенный реализацией код результата ввода/вывода.
\ Эта операция не влияет на значение, возвращаемое FILE-POSITION.
\ ud неопределен, если ior не ноль.
  lpDistanceToMoveHigh SWAP
  GetFileSize
  DUP -1 = IF GetLastError ELSE 0 THEN
  lpDistanceToMoveHigh @ SWAP
;

: OPEN-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Открыть файл с именем, заданным строкой c-addr u, с методом доступа fam.
\ Смысл значения fam определен реализацией.
\ Если файл успешно открыт, ior ноль, fileid его идентификатор, и файл
\ позиционирован на начало.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  0 ( secur )
  0 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

USER lpNumberOfBytesRead

: READ-FILE ( c-addr u1 fileid -- u2 ior ) \ 94 FILE
\ Прочесть u1 символов в c-addr из текущей позиции файла,
\ идентифицируемого fileid.
\ Если u1 символов прочитано без исключений, ior ноль и u2 равен u1.
\ Если конец файла достигнут до прочтения u1 символов, ior ноль
\ и u2 - количество реально прочитанных символов.
\ Если операция производится когда значение, возвращаемое
\ FILE-POSITION равно значению, возвращаемому FILE-SIZE для файла
\ идентифицируемого fileid, ior и u2 нули.
\ Если возникла исключительная ситуация, то ior - определенный реализацией
\ код результата ввода/вывода, и u2 - количество нормально переданных в
\ c-addr символов.
\ Неопределенная ситуация возникает, если операция выполняется, когда
\ значение, возвращаемое FILE-POSITION больше чем значение, возвращаемое
\ FILE-SIZE для файла, идентифицируемого fileid, или требуемая операция
\ пытается прочесть незаписанную часть файла.
\ После завершения операции FILE-POSITION возвратит следующую позицию
\ в файле после последнего прочитанного символа.
  >R >R >R
  0 lpNumberOfBytesRead R> R> SWAP R>
  ReadFile ERR
  lpNumberOfBytesRead @ SWAP
;

: REPOSITION-FILE ( ud fileid -- ior ) \ 94 FILE
\ Перепозиционировать файл, идентифицируемый fileid, на ud.
\ ior - определенный реализацией код результата ввода-вывода.
\ Неопределенная ситуация возникает, если позиционируется вне
\ его границ.
\ После завершения операции FILE-POSITION возвращает значение ud.
  >R lpDistanceToMoveHigh ! FILE_BEGIN lpDistanceToMoveHigh ROT R>
  SetFilePointer
  -1 = IF GetLastError ELSE 0 THEN
;

HEX

CREATE LT 0A0D , \ line terminator
CREATE LTL 2 ,   \ line terminator length

: DOS-LINES ( -- )
  0A0D LT ! 2 LTL !
;
: UNIX-LINES ( -- )
  0A0A LT ! 1 LTL !
;

DECIMAL

USER Buf
USER Hdl

: READ-LINE ( c-addr u1 fileid -- u2 flag ior ) \ 94 FILE
\ Прочесть следующую строку из файла, заданного fileid, в память
\ по адресу c-addr. Читается не больше u1 символов. До двух
\ определенных реализацией символов "конец строки" могут быть
\ прочитаны в память за концом строки, но не включены в счетчик u2.
\ Буфер строки c-addr должен иметь размер как минимум u1+2 символа.
\ Если операция успешна, flag "истина" и ior ноль. Если конец строки
\ получен до того как прочитаны u1 символов, то u2 - число реально
\ прочитанных символов (0<=u2<=u1), не считая символов "конец строки".
\ Когда u1=u2 конец строки уже получен.
\ Если операция производится, когда значение, возвращаемое
\ FILE-POSITION равно значению, возвращаемому FILE-SIZE для файла,
\ идентифицируемого fileid, flag "ложь", ior ноль, и u2 ноль.
\ Если ior не ноль, то произошла исключительная ситуация и ior -
\ определенный реализацией код результата ввода-вывода.
\ Неопределенная ситуация возникает, если операция выполняется, когда
\ значение, возвращаемое FILE-POSITION больше чем значение, возвращаемое
\ FILE-SIZE для файла, идентифицируемого fileid, или требуемая операция
\ пытается прочесть незаписанную часть файла.
\ После завершения операции FILE-POSITION возвратит следующую позицию
\ в файле после последнего прочитанного символа.
  SWAP LTL @ + SWAP
  >R >R DUP Buf ! R> R>
  DUP Hdl !
  READ-FILE ?DUP IF ( ошибка чтения ) 0 SWAP EXIT THEN
  DUP IF ( что-то прочли ) ( прочитано_байт )
         DUP
         Buf @ SWAP LT 1 SEARCH ( прочитано_байт адрес_конца_строки осталось_байт флаг )
         0= IF ( конец строки не найден - будем рвать в текущем месте)
               2DROP -1 0 EXIT
            THEN
         ( конец строки найден )
         ROT DROP ( убрал прочитано_байт )
         ( адрес_конца_строки  осталось )
         LTL @ - ( не возвращать CRLF )
         ?DUP IF
         0 DNEGATE
         Hdl @ FILE-POSITION ?DUP
         IF >R 2DROP 2DROP Buf @ - -1 R> EXIT THEN
         D+
         Hdl @ REPOSITION-FILE ?DUP IF 0 SWAP EXIT THEN
         THEN
         ( адрес_конца_строки )
         Buf @ - -1 0
      ELSE ( были в конце файла ) 0 0 THEN
;

USER lpNumberOfBytesWritten

: WRITE-FILE ( c-addr u fileid -- ior ) \ 94 FILE
\ Записать u символов из c-addr в файл, идентифицируемый fileid,
\ в текущую позицию.
\ ior - определенный реализацией код результата ввода-вывода.
\ После завершения операции FILE-POSITION возвращает следующую
\ позицию в файле за последним записанным в файл символом, и
\ FILE-SIZE возвращает значение большее или равное значению,
\ возвращаемому FILE-POSITION.
  OVER >R
  >R >R >R
  0 lpNumberOfBytesWritten R> R> SWAP R>
  WriteFile ERR ( ior )
  ?DUP IF RDROP EXIT THEN
  lpNumberOfBytesWritten @ R> <>
  ( если записалось не столько, сколько требовалось, то тоже ошибка )
;

: RESIZE-FILE ( ud fileid -- ior ) \ 94 FILE
\ Установить размер файла, идентифицируемого fileid, равным ud.
\ ior - определенный реализацией код результата ввода-вывода.
\ Если результирующий файл становится больше, чем до операции,
\ часть файла, добавляемая в результате операции, может быть
\ не записана.
\ После завершения операции FILE-SIZE возвращает значение ud
\ и FILE-POSITION возвращает неопределенное значение.
  DUP >R REPOSITION-FILE  ?DUP IF R> DROP EXIT THEN
  R> SetEndOfFile ERR
;

: WRITE-LINE ( c-addr u fileid -- ior ) \ 94 FILE
\ Записать u символов от c-addr с последующим зависящим от реализации концом 
\ строки в файл, идентифицируемый fileid, начиная с текущей позиции.
\ ior - определенный реализацией код результата ввода-вывода.
\ После завершения операции FILE-POSITION возвращает следующую
\ позицию в файле за последним записанным в файл символом, и
\ FILE-SIZE возвращает значение большее или равное значению,
\ возвращаемому FILE-POSITION.
  DUP >R WRITE-FILE ?DUP IF R> DROP EXIT THEN
  LT LTL @ R> WRITE-FILE
;

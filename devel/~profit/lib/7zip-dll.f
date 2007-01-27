\ Соединитель с библиотекой архиватора 7-zip
\ Упаковывает и распаковывает ZIP и 7z


\ 7-zip32.dll можно взять по адресу:
\ http://www.csdinc.co.jp/archiver/lib/7-zip32.html#download
\ Там на японском, но думаю разберётесь...


REQUIRE ZPLACE ~nn/lib/az.f

WINAPI: SevenZip 7-zip32.dll

MODULE: 7zip

100 CONSTANT maxOutputLen

CREATE input 200 ALLOT \ буфер для задания команд архиватору
CREATE output maxOutputLen ALLOT \ выходной буфер


CREATE quote CHAR " C, 0 C, \ Двойная кавычка

\ закавыченный текст положить во входной буфер:
: quotedInput ( addr u -- ) quote 1 input +ZPLACE  input +ZPLACE  quote 1 input +ZPLACE ;


EXPORT

\ Выполнить команду указанную в input, о результатах доложить в output
\ Команды при этом такие же как и при вызове 7z.exe с комадной строки,
\ то есть x a e и прочие (см. справку по 7-zip)
: 7zcommand maxOutputLen output input 0 SevenZip  input ASCIIZ> CR TYPE 
;

\ Что (what) за архив распаковать куда (where), в какую папку
\ f -- флаг успеха, =0 если всё хорошо
: zip-extract ( where what -- f ) \ распаковка без перезаписи
S" x " input ZPLACE
quotedInput
S"  -hide -aoa -o" input +ZPLACE \ hide здесь для того чтобы спрятать окошко с полоской
quotedInput
7zcommand ;

\ Что (what) за файлы упаковывать куда (toWhere), в какой zip-архив
\ f -- флаг успеха, =0 если всё хорошо
: zip-pack ( what toWhere arc -- f )
S" a " input ZPLACE
quotedInput
S"  -hide -tzip -r " input +ZPLACE
quotedInput
7zcommand ;

\ Что (what) за файлы (да, можно указывать маски) упаковывать куда (toWhere), в какой 7z-архив
\ f -- флаг успеха, =0 если всё хорошо
: 7zip-pack ( what toWhere arc -- f )
S" a " input ZPLACE
quotedInput
S"  -hide -t7z -r " input +ZPLACE
quotedInput
7zcommand ;

;MODULE

\EOF

S" 7zip-dll.f" S" r.zip" zip-pack CR .
S" 7zip-dll.f" S" r.7z" 7zip-pack CR .

S" r" S" r.zip" zip-extract CR .
S" r" S" r.7z" zip-extract CR .
\ Библиотеки openssl для выполнения файлового i/o используют не crt,
\ не вызовы ОС, а таблицу функций, предоставляемых самим приложением
\ (кстати, так же работает и drweb32.dll, но таблица функций
\ передается в dll иначе).
\ Openssl требует, чтобы использующий его exe-модуль экспортировал
\ функцию OPENSSL_Applink, как будто dll, и эта функция должна
\ возвращать адрес таблицы функций для использования в openssl.
\ Если такой нет, то получим ошибку "no OPENSSL_Applink".

\ Нам пока нужна только функция fwrite, т.к. её использует openssl
\ для записи x509-сертификатов и запросов сертификатов.
\ Все остальные представлены заглушками.
\ fwrite мы реализуем так, чтобы вывод шел в str5-строку, а не файл.

\ Включение aplink.f в приложение приведет к тому, что по будущему SAVE
\ будет записан exe, экспортирующий OPENSSL_Applink.
\ Relocations нас здесь не волнуют, т.к. openssl не загружает
\ приложение еще раз по LoadLibrary, а получает хэндл текущего
\ приложения по GetModuleHandle(NULL), и потом 
\ ищет наш applink по GetProcAddress(h,"OPENSSL_Applink").

: Linux? PLATFORM S" Linux" COMPARE 0= ;
: SkipOnLinux Linux? IF \EOF THEN ;
: OnLinux: Linux? 0= IF POSTPONE \ THEN ; IMMEDIATE
: OnWindows: Linux?  IF POSTPONE \ THEN ; IMMEDIATE

USER ap_str \ вместо stdout-файла используем строку

SkipOnLinux

REQUIRE STR@                  ~ac/lib/str5.f
REQUIRE /ExportDirectoryTable ~ac/lib/win/pe/pe_export.f 
 
:NONAME ." app_stdin," 0 ; 0 CELLS CALLBACK: al_app_stdin
:NONAME ." app_stdout," 0 ; 0 CELLS CALLBACK: al_app_stdout
:NONAME ." app_stderr," 0 ; 0 CELLS CALLBACK: al_app_stderr
:NONAME ." fprintf," 0 ; 0 CELLS CALLBACK: al_fprintf
:NONAME ." fgets," 0 ; 0 CELLS CALLBACK: al_fgets
:NONAME ." fread," 0 ; 0 CELLS CALLBACK: al_fread

:NONAME { stream count size buffer \ tls -- count }
  TlsIndex@ -> tls stream TlsIndex!
  buffer size ap_str @ STR+
  stream count size  buffer
  count
  tls TlsIndex!
; 4 CELLS CALLBACK: al_fwrite

:NONAME ." app_fsetmod," 0 ; 0 CELLS CALLBACK: al_app_fsetmod
:NONAME ." app_feof," 0 ; 0 CELLS CALLBACK: al_app_feof
:NONAME ." fclose," 0 ; 0 CELLS CALLBACK: al_fclose

:NONAME ." fopen," 0 ; 0 CELLS CALLBACK: al_fopen
:NONAME ." fseek," 0 ; 0 CELLS CALLBACK: al_fseek
:NONAME ." ftell," 0 ; 0 CELLS CALLBACK: al_ftell
:NONAME ." fflush," 0 ; 0 CELLS CALLBACK: al_fflush
:NONAME ." app_ferror," 0 ; 0 CELLS CALLBACK: al_app_ferror
:NONAME ." app_clearerr," 0 ; 0 CELLS CALLBACK: al_app_clearerr
:NONAME ." app_fileno," 0 ; 0 CELLS CALLBACK: al_app_fileno

:NONAME ." open," 0 ; 0 CELLS CALLBACK: al_open
:NONAME ." read," 0 ; 0 CELLS CALLBACK: al_read
:NONAME ." write," 0 ; 0 CELLS CALLBACK: al_write
:NONAME ." lseek," 0 ; 0 CELLS CALLBACK: al_lseek
:NONAME ." close," 0 ; 0 CELLS CALLBACK: al_close

CREATE AlTable
' al_app_stdin ,
' al_app_stdin ,
' al_app_stdout ,
' al_app_stderr ,
' al_fprintf ,
' al_fgets ,
' al_fread ,
' al_fwrite ,
' al_app_fsetmod ,
' al_app_feof ,
' al_fclose ,

' al_fopen ,
' al_fseek ,
' al_ftell ,
' al_fflush ,
' al_app_ferror ,
' al_app_clearerr ,
' al_app_fileno ,

' al_open ,
' al_read ,
' al_write ,
' al_lseek ,
' al_close ,

:NONAME ( -- addr )
\ ." APP-LINK!"
  AlTable
; 0 CELLS CALLBACK: OPENSSL_Applink

CREATE ExpDir \ выравнивание не обязательно (?)

  HERE IMAGE-BASE - EXPORTS-RVA !
  HERE /ExportDirectoryTable DUP ALLOT ERASE

  HERE IMAGE-BASE - S" spf4.exe" S, 0 C, ExpDir ED.NameRVA ! \ ALIGN
  1 ExpDir ED.OrdinalBase !
  1 ExpDir ED.AddressTableEntries !  1 ExpDir ED.NumberOfNamePointers !

  HERE IMAGE-BASE - ExpDir ED.NamePointerRVA !
  HERE CELL+ IMAGE-BASE - ,
  S" OPENSSL_Applink" S, 0 C, \ ALIGN

  HERE IMAGE-BASE - ExpDir ED.OrdinalTableRVA ! 0 W, \ ALIGN \ нумерация там с нуля

  HERE IMAGE-BASE - ExpDir ED.ExportAddressTableRVA ! 
  ' OPENSSL_Applink IMAGE-BASE - ,

  HERE ExpDir - EXPORTS-SIZE ! 

\ S" spf4e.exe" SAVE

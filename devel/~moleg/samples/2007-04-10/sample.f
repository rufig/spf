\ 10-04-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ пример очень простой обработки файла.

VOCABULARY process
           ALSO process DEFINITIONS

      \ я не люблю NOTFOUND, но в данном примере он кстати.
      : NOTFOUND ( asc # --> ) 2DROP
                 0 >IN !
                 0x0D PARSE
                 TYPE CR ;

PREVIOUS DEFINITIONS

\ по-умолчанию сохраняем в STDLOG
: sample ( srcZ # --> )
         ONLY process
         GetCommandLineA ASCIIZ> SOURCE! NextWord 2DROP
         NextWord INCLUDED
         KEY DROP BYE ;

' sample MAINX !

S" sample.exe" SAVE CR S" passed " CR BYE

\ пример использования:
\ sample file.name >result.file

\ заменяем завершающую последовательность строки 0x0D 0x0D 0x0A
\ на принятую в данной ОС ( для win платформы 0x0D 0x0A для linux - 0x0A )
\ пустые строки удаляются.

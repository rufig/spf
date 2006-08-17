S" ~micro\deleter\core.f" INCLUDED
\ Ядро

: del
\ del <каталог>
\ компиляция программы удаленя файлов из каталога
  NextWord
  POSTPONE SLITERAL
  POSTPONE DeleteFromDir
; IMMEDIATE

: arch
\ arch <каталог> <файл>
\ компиляция программы сброса файлов из каталога в файл
  NextWord POSTPONE SLITERAL 
  NextWord POSTPONE SLITERAL
  POSTPONE Arch
; IMMEDIATE


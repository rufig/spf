\ Загрузка произвольных файлов с данными
\ Ю. Жиловец, 2001

: BINDATA ( a # "name" -- )
  CREATE
  R/O OPEN-FILE ABORT" ” ©« ­Ґ ­ ©¤Ґ­" >R
  HERE 100000 R@ READ-FILE THROW ALLOT
  R> CLOSE-FILE THROW
;
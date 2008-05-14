\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ Работа с ini-файлами

REQUIRE [DEFINED]  lib/include/tools.f

WINAPI: GetPrivateProfileStringA    kernel32.dll
WINAPI: WritePrivateProfileStringA  kernel32.dll

USER-CREATE BufIni 4096 USER-ALLOT
: N>S ( u -- addr0)
  S>D DUP >R DABS <#
  [ VERSION 400000 < [IF] ] 0 HOLD  [ [THEN] ] \ чтобы была 0-строка
  #S R> SIGN #> DROP
;

\ Получить строковое значение ключа
: GetIniString ( addr0_ini addr0_sec addr0_key addr0_def -- addr0)
\ где addr0_ini - нуль-терминированная строка - имя ini файла
\ addr0_sec - имя секции
\ addr0_key - имя ключа
\ addr0_def - значение по умолчанию
\ addr0 - требуемая строка
  ASCIIZ> 1+ PAD SWAP MOVE
  >R >R
  4096 BufIni PAD
  2R>
  GetPrivateProfileStringA DROP
  BufIni
;

\ Записать строковое значение ключа
: SetIniString ( addr0_ini addr0_sec addr0_key addr0 -- )
\ гиде - addr0 - записываемая строка
  SWAP ROT
  WritePrivateProfileStringA DROP
;

\ Получить числовое значение ключа
: GetIniInt ( addr0_ini addr0_sec addr0_key u1 -- u2)
\ u1 - дефолтное число
  DUP >R
  N>S GetIniString
  ASCIIZ> ['] ?SLITERAL1 CATCH 0= IF
    RDROP
  ELSE
    2DROP R>
  THEN
;

\ Записать числовое значение ключа
: SetIniInt ( addr0_ini addr0_sec addr0_key u1 -- )
  N>S SetIniString
;

\ Получить список ключей в секции
: EnumSectionKeys ( addr0_ini addr0_sec addr u -- flag)
\ где addr0_ini - нуль-терминированная строка - имя ini файла
\ addr0_sec - имя секции
\ addr - буфер для списка
\ u - его размер
\ Формат списка ключей:
\ каждый ключ - 0-строка, в конце списка два нуля
  ROT >R
  SWAP
  0 PAD C!  PAD
  0 R>
  GetPrivateProfileStringA 0<>
;

\ Удалить ключ
: DeleteIniKey ( addr0_ini addr0_sec addr0_key -- )
  0 SetIniString
;

\ Удалить секцию
: DeleteIniSection ( addr0_ini addr0_sec -- )
  0 0 SetIniString
;

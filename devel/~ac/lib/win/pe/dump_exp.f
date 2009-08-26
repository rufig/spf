\ Дампер секции экспорта (см. делософтовый PE-дампер и MIPS-дизасм MIPSDIS 98г) для проверки
\ самодельных списков экспортируемых процедур форта. 
\ Раньше проводник Windows сам показывал списки экспорта dll, но в этом веке уже нет :)

REQUIRE /PE-HEADER            ~ac/lib/win/pe/pe_header.f 
REQUIRE /ExportDirectoryTable ~ac/lib/win/pe/pe_export.f 
REQUIRE {                     lib/ext/locals.f

: DUMP-EXP { addr u \ h pe_offs rvas sects exp exp_size o erva esize ef_offs ef_size f bas -- }

  addr u R/O OPEN-FILE-SHARED THROW -> h
  PAD 0x40 h READ-FILE THROW DROP
  BASE @ -> bas HEX
  PAD 0x3C + @  \ смещение до PE
  DUP -> pe_offs
  S>D h REPOSITION-FILE THROW

  PAD /PE-HEADER h READ-FILE THROW DROP
  PAD ExportTableRVA @ -> exp
  PAD TotalExportDataSize @ -> exp_size
  PAD #InterestingRVA/Sizes @ -> rvas
  PAD #Objects W@ -> sects
  pe_offs Magic \ смещение до опционального заголовка
  PAD NTHDRsize W@ \ размер опционального заголовка
  + S>D h REPOSITION-FILE THROW

  PAD sects /ObjectTable *  h READ-FILE THROW DROP
  sects 0 DO
    I /ObjectTable * PAD + -> o
    o ASCIIZ> TYPE SPACE
    o OT.RVA @ . o OT.VirtualSize @ .
    exp o OT.RVA @ DUP o OT.VirtualSize @ + WITHIN DUP .
    IF o OT.RVA @ -> erva  o OT.VirtualSize @ -> esize \ параметры секции, в которой export table (exp), не обязательно с начала
       o OT.PhisicalOffset @ -> ef_offs  o OT.PhisicalSize @ -> ef_size
    THEN
    CR
  LOOP

  exp erva - ( смещение в секции) ef_offs + S>D h REPOSITION-FILE THROW
  HERE exp_size h READ-FILE THROW DROP
\  S" exp.bin" R/W CREATE-FILE THROW -> f
\  HERE exp_size f WRITE-FILE THROW
\  f CLOSE-FILE THROW
  HERE ED.NameRVA @ exp - HERE + ASCIIZ> TYPE CR \ убедились, что правильно нашли таблицу

  HERE ED.AddressTableEntries @ . HERE ED.NumberOfNamePointers @ . CR
  HERE ED.OrdinalBase @ . CR
  HERE ED.NumberOfNamePointers @ 0 ?DO
    HERE ED.NamePointerRVA @ exp - HERE +
    I CELLS + @ ( rva) exp - HERE + ASCIIZ> TYPE SPACE
    HERE ED.OrdinalTableRVA @ exp - HERE +
    I 2* + W@ 1+ ( номер) DUP ." #" . HERE ED.OrdinalBase @ - CELLS \ смещение
    HERE ED.ExportAddressTableRVA @ exp - HERE + + @ \ rva - либо экспортируемый символ, либо указатель на форвардер
    DUP exp DUP exp_size + WITHIN IF exp - HERE + ASCIIZ> ." ->" TYPE SPACE ELSE . THEN
CR
  LOOP
  h CLOSE-FILE THROW
  bas BASE !
;
\ S" c:\windows\system32\kernel32.dll" DUMP-EXP
\ S" F:\openssl\openssl.exe" DUMP-EXP
\ S" test.exe" DUMP-EXP
\ S" F:\PRO\e4-installer\Eserv400a4-setup.exe" DUMP-EXP
\ S" F:\spf4\devel\~ac\lib\lin\openssl\libeay32.dll" DUMP-EXP

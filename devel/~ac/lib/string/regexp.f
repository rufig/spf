( Библиотека работы с Perl-образными регулярными выражениями
  для обработки строк.

     Regular expression support is provided by the PCRE library package,
     which is open source software, written by Philip Hazel, and copyright
     by the University of Cambridge, England.
     ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/

     PCRE wrapped for SP-Forth 17.09.2002 by Andrey Cherezov
     v1.0

  Основная функция:

  PcreGetMatch [ addr1 u1 add2 u2 -- an un an-1 un-1 ... a1 u1 n ]
  Сравнить строку addr1 u1 с шаблоном addr2 u2
  Если шаблон не подошел - результат 0.
  Если подошел - в результате n>0, а под ним на стеке n строк
  в формате addr u. Это строки, которые подошли под ловушки-скобки
  в заданном шаблоне. Строки на стеке в таком порядке, что
  сниматься будут в порядке попадания в ловушки.
  Причем верхняя строка - подстрока исходной строки, попавшая
  под шаблон вцелом.

  Например, запуск предложения:
)
\  S" one two three" S" (\S+)\s+(\S+)\s+(\S+)" PcreGetMatch
\  . CR TYPE CR TYPE CR TYPE CR TYPE CR 
(
  даст результат:

  4
  one two three
  one
  two
  three

  Если результаты не нужны, то можно использовать более простое слово

  PcreMatch [ addr1 u1 add2 u2 -- matched ]
  Возвращает 0, если шаблон addr2 u2 не найден в строке addr1 u1.
  Если найден, то результат - больше нуля.

  Библиотека не требует инициализации. Но по окончании работы
  требуется вызов PcreEnd - освобождае память _pcre_vector.

  Библиотека не зависит от других библиотек SPF, но требует pcre.dll,
  где собственно функциональность regexp и реализована, а здесь
  всего лишь wrapper для Форта.
)

  
WINAPI: FreeLibrary  KERNEL32.DLL
WINAPI: pcre_compile pcre.dll
WINAPI: pcre_exec    pcre.dll
WINAPI: pcre_free_substring_list pcre.dll \ (pcre_free)((void *)pointer);

VARIABLE PcreFreeAddr

: PcreFree ( re -- ior )

  DROP 0 EXIT \ что-то эта функция портит в памяти (в многопоточном режиме)

  pcre_free_substring_list 2DROP 0 EXIT

\ Выше используется особенность реализации функции pcre_free_substring_list,
\ которая есть просто вызов (pcre_free), и даже рекомендуется в комментариях
\ к использованию вместо pcre_free. Соответственно код ниже уже не нужен.

\ GetProcAddress здесь возвращает не адрес функции, а адрес переменной,
\ содержащей адрес функции
  PcreFreeAddr @ ?DUP IF API-CALL NIP 1 = IF 0 ELSE -3012 THEN EXIT THEN
  S" pcre_free" DROP S" pcre.dll" DROP LoadLibraryA DUP >R GetProcAddress @
  DUP PcreFreeAddr !
  API-CALL NIP 1 = IF 0 ELSE -3012 THEN
  R> FreeLibrary DROP
;
USER _pcre_erroffset 
USER _pcre_error
USER _pcre_vector
60 VALUE _pcre_vector_len

2 CONSTANT PCRE_MULTILINE \ чтобы работали ^ и $ в шаблоне

\ -3010 - incorrect pattern
\ -3011 - vector too small
\ -3012 - wrong memory pointer for pcre_free()

: PcreEnd ( -- )
  _pcre_vector @ ?DUP IF FREE DROP _pcre_vector 0! THEN
;
: PcreCompile ( addr u -- re ior )
  DROP >R
  0 _pcre_erroffset _pcre_error PCRE_MULTILINE R>
  pcre_compile >R 2DROP 2DROP DROP R>
  DUP 0= IF -3010 ELSE 0 THEN
;
: PcreExec ( addr u re -- matched ior )
  >R 2>R
  _pcre_vector_len _pcre_vector @ 
  DUP 0= IF DROP _pcre_vector_len ALLOCATE THROW DUP _pcre_vector ! THEN
  0 0 2R> SWAP 0 R> 
  pcre_exec >R 2DROP 2DROP 2DROP 2DROP R>
  DUP   0= IF -3011 EXIT THEN
  DUP -1 = IF DROP 0 0 EXIT THEN \ не подходит в шаблон
  DUP   0< IF 0 SWAP EXIT THEN   \ коды ошибок pcre
  0 \ положительное число означает, что шаблон подошел
    \ 1 = "просто подошел", возвращена совпавшая подстрока
    \ 1> = возвращены подстроки для (...)
;
\ S" ^P(.+)Z" PcreCompile THROW S" PcReIsRULEZZ:)" ROT PcreExec THROW .

: PcreMatch ( addr1 u1 add2 u2 -- matched )
\   PcreCompile THROW PcreExec THROW
  PcreCompile THROW
    DUP >R
  PcreExec 
    R> PcreFree DROP
  THROW
;
\ S" PcReIsRULEZZ:)" S" ^P(.+)Z"  PcreMatch .
\ S" один два три" S" (\S+)" PcreMatch . _pcre_vector @ 20 DUMP

: PcreExpandResult ( addr1 n -- an un an-1 un-1 ... a1 u1 n )
\ один из параметров передается неявно в переменной-результате _pcre_vector
  DUP 2* CELLS _pcre_vector @ + \ addr1 n addr+n*2(pos)
  SWAP DUP >R
  0 DO                   \ ... addr1 pos
      CELL- DUP @        \ ... addr1 pos- offse
      SWAP CELL- DUP @   \ ... addr1 offse pos-- offsn
      SWAP >R            \ ... addr1 offse offsn
      DUP >R - R>        \ ... addr1 un offsn
      SWAP >R OVER +     \ ... addr1 an
      R> ROT             \ ... an un addr1
      R>                 \ ... an un addr1 pos--
  LOOP                   \ ... addr1 pos
  2DROP R>
;
: PcreGetMatch ( addr1 u1 add2 u2 -- an un an-1 un-1 ... a1 u1 n )
  2OVER DROP >R
  PcreCompile THROW
    DUP >R
  PcreExec ?DUP IF R> PcreFree DROP THROW THEN
  DUP 0= IF R> PcreFree DROP RDROP EXIT THEN
  2R> >R
  SWAP PcreExpandResult
  R> PcreFree THROW
;
\ S" PcReIsRULEZZ:)" S" ^P(.+)ZZ:"  PcreGetMatch . CR TYPE CR TYPE CR
\ результат: 2 "PcReIsRULEZZ:" "cReIsRULE"
\ S" one two three" S" (\S+)\s+(\S+)\s+(\S+)" PcreGetMatch . CR TYPE CR TYPE CR TYPE CR TYPE CR 
\ результат: 4 "one two three" "one" "two" "three"

\ : TEST
\   S" (\S+)\s+(\S+)\s+(\S+)" PcreCompile THROW >R
\   S" one two three" R@ PcreExec . .
\   S" 7 8 9" R@ PcreExec . .
\   S" ab cd ef" R@ PcreExec . .
\   S" раз два три" R@ PcreExec . .
\   S" something" R@ PcreExec . .
\   RDROP
\ ; TEST

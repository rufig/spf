WINAPI: BRegexpVersion BRegexp.dll
\ BRegexpVersion ASCIIZ> TYPE
WINAPI: BMatch         BRegexp.dll
\ BMatch("m/abc/",szTarget,
\ 		szTarget+strlen(szTarget),&rxp,msg);
WINAPI: BSubst         BRegexp.dll


USER rxp 
0
CELL -- rxp.outp      \ BSubst: Pointer to Replace data
CELL -- rxp.outendp   \ BSubst: Pointer to last of replace data + 1
CELL -- rxp.splitctr  \ BSplit: Number of array items.
CELL -- rxp.splitp    \ BSplit: Pointer to the data
CELL -- rxp.rsv1      \ Reserved (free to use)
CELL -- rxp.parap     \ Pointer to pattern data
CELL -- rxp.paraendp  \ Pointer to pattern data + 1
CELL -- rxp.transtblp \ BTrans: Pointer to Translation table 
CELL -- rxp.startp    \ Pointer to first of matched data.
CELL -- rxp.endp      \ Pointer to last of matched data.
CELL -- rxp.nparens   \ Number of ()s in pattern. It is useful to examine $1, $2 and $n.
CONSTANT /BREGEXP


: bresult ( i -- addr u )
  CELLS >R
  rxp @ rxp.startp @ R@ + @
  rxp @ rxp.endp @ R> + @ OVER -
;
: BregexpMatch ( S" string" S" pattern" -- n )
\ n - к-во попаданий в ()
  2>R 2>R PAD rxp 2R> OVER + SWAP 2R> DROP BMatch >R 2DROP 2DROP DROP R>
  DUP -1 = IF PAD ASCIIZ> TYPE CR ABORT THEN
  1 = IF rxp @ rxp.nparens @ 1+ ELSE 0 THEN
;
: BregexpReplace ( S" string" S" pattern" -- S" result" n )
\ n - к-во замен
  2>R 2>R PAD rxp 2R> OVER + SWAP 2R> DROP BSubst >R 2DROP 2DROP DROP R>
  DUP -1 = IF PAD ASCIIZ> TYPE CR ABORT THEN
  >R
  rxp @ rxp.outp @ 
  rxp @ rxp.outendp @ OVER -
  R>
;
: BregexpGetMatch ( S" string" S" pattern" -- ... n )
  BregexpMatch
  DUP >R
  0 ?DO
    rxp @ rxp.nparens @ I - bresult
  LOOP
  R>
;
(
: TEST
  S" one two three" S" /(\S+)\s+(\S+)\s+(\S+)/" BregexpGetMatch
  . CR TYPE CR TYPE CR TYPE CR TYPE CR 
  S" Yokohama 045-222-1111  Osaka 06-5555-6666  Tokyo 03-1111-9999 "
  S" /(03|045)-(\d{3,4})-(\d{4})/" BregexpGetMatch
  DUP . 0 ?DO TYPE CR LOOP \ находит только первое совпадение
  S" Yokohama 045-222-1111  Osaka 06-5555-6666  Tokyo 03-1111-9999 "
  S" s/(\d\d)-\d{4}-\d{4}/$1-xxxx-xxxx/g" BregexpReplace
  . TYPE
  S" test&lt;test" S" s/(&lt;)/</g" BregexpReplace
  . TYPE
; TEST
)
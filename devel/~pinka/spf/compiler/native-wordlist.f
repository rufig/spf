\ Oct.2006, Feb.2007, 
\ Jan.2008 something extracted from xt.immutable.f
\ Нативные списки форт-слов

: RESOLVE-NAME ( c-addr u wid -- xt true | c-addr u false )
  @ CDR-BY-NAME DUP IF NIP NIP NAME> TRUE THEN
;

: RELATE-NAME ( xt  c-addr u  wid -- )
\ поставить имя (заданное c-addr u) в отношение к xt в списке wid
  >R
  HERE LAST-CFA ! ROT , \ ссылка на xt
  0 C,                  \ flags
  \ +SWORD was here
  HERE LAST ! S",       \ само имя
  \ (формат SPF4)
  LAST @  R> DUP @ , !  \ связали в список wid
;


[DEFINED] QuickSWL-Support  [IF] WARNING @  WARNING 0!

: RELATE-NAME DUP >R RELATE-NAME LAST @ R> QuickSWL-Support::update1-wlhash ;

WARNING !                   [THEN]



: NAMING- ( xt c-addr u -- )
\ Добавить слово, заданное семантикой xt, 
\ под именем, заданным строкой c-addr u, в текущий список.
  GET-CURRENT RELATE-NAME
;
: NAMING ( c-addr u xt -- ) \ NAMED or GIVE-NAME or ?
\ дает слову имя и зачисляет его в текущую книгу имен :)
\ сразу после этого слово находимо по данному имени.
  -ROT NAMING-
;

( Дополнительные атрибуты могут привязываться к xt. Например,
если надо быстро, то через ссылку ячейкой выше от адреса xt,
если надо много, то через дополнительные списки /см. inlines.f/.
В последнем случае возможные сигнатуры слов
для получения текстового и числового значения соответственно:
 attrib-a attib-u xt -- text-a text-u
 attrib-a attib-u xt -- value
)


: WORDLIST-NAMED ( addr u -- wid )
\ И в текущий словарь добавляет слово с заданным именем,
\ возвращающее wid
  WORDLIST DUP >R CODEGEN-WL::MAKE-CONST NAMING R> ( wid )
  LAST @ OVER CELL+ ! ( ссылка на имя словаря, SPF4 )
;

: &  ( c-addr u -- xt )  \ see also ' (tick)
  SFIND IF EXIT THEN -321 THROW
;



\EOF
\ old ideas:

: ALIAS ( xt c-addr u -- ) NAMING- ;
: DEFER-NAMING ( c-addr u -- entry ) 0 , 0 C, HERE -ROT S", 0 , ;
: ~~~BIND-NAME ( xt entry -- ) TUCK 5 - ! .....  ;

: &EX, ( c-addr u -- )
  & EXEC,
;
: &LT, ( c-addr u -- )
  I-LIT IF LIT, EXIT THEN -321 THROW
;

\ 23.Dec.2006 Sat 16:08
( ѕоддержка экстра-€чейки дл€ списков слов
  с целью их расширени€.  од вынесен из quick-swl3.f

  —лово WID-EXTRA [ wid -- addr ] дает свободую €чейку дл€ использовани€.
  ћодуль расширени€, использующий эту €чейку дл€ своих нужд,
  должен переопределить слово WID-EXTRA
  с тем, чтобы оно продолжало давать свободную €чейку.

  ћодуль предоставл€ет цепочку AT-WORDLIST-CREATING [ wid -- wid ]
  вызываемую при создании нового списка слов.
)

REQUIRE [UNDEFINED] lib\include\tools.f
REQUIRE Included ~pinka\lib\ext\requ.f
REQUIRE REPLACE-WORD lib\ext\patch.f

WARNING @  WARNING 0!

MODULE: WidExtraSupport

Require ENUM-VOCS enum-vocs.f

2 CELLS CONSTANT /THIS-EXTR   \ [ free cell | voc class ]

: MAKE-EXTR ( wid -- )
  HERE DUP /THIS-EXTR DUP ALLOT ERASE
  ( wid here )
  OVER CLASS@ OVER CELL+ !
  SWAP CLASS!
;
: MAKE-EXTR2 ( wid -- ) \ не используетс€; на случай словарей, созданных мину€ слово WORDLIST
  GET-CURRENT >R  DUP SET-CURRENT
  MAKE-EXTR
  R> SET-CURRENT
;

EXPORT

: WID-EXTRA ( wid -- a )  \ будет свободна€ дл€ других расширений €чейка
  [ 3 CELLS ] LITERAL + \ an old "class of vocabulary" cell
  @
;

DEFINITIONS

: WID-CLASSA ( wid -- a )
  WID-EXTRA CELL+
;

EXPORT

WARNING @ WARNING 0!
: CLASS! ( cls wid -- ) WID-CLASSA ! ;
: CLASS@ ( wid -- cls ) WID-CLASSA @ ;
WARNING !

: AT-WORDLIST-CREATING ( wid -- wid ) ... ;

\ : WORDLIST ( -- wid )
\   WORDLIST DUP MAKE-EXTR AT-WORDLIST-CREATING ( wid )
\ ;

\ Ќиже закладка дл€ storage.f, чтобы подцепить новый VOC-LIST

( WORDLIST надо переопределить,
  т.к. благодар€ оптимизатору оно ссылаетс€ на старый VOC-LIST
  несмотр€ на подмену последнего.
)
' WORDLIST  \ see compiler\spf_wordlist.f
: WORDLIST ( -- wid ) \ 94 SEARCH
  HERE VOC-LIST @ , VOC-LIST !
  HERE 0 , \ здесь будет указатель на им€ последнего слова списка
       0 , \ здесь будет указатель на им€ списка дл€ именованых
       0 , \ wid словар€-предка
       0 , \ класс словар€ = wid словар€, определ€ющего свойства данного

  DUP MAKE-EXTR AT-WORDLIST-CREATING ( wid )
;

' WORDLIST SWAP REPLACE-WORD

\ : VOCABULARY
\   VOCABULARY  VOC-LIST @ CELL+
\   DUP MAKE-EXTR AT-WORDLIST-CREATING DROP
\ ;

' VOCABULARY
: VOCABULARY  \ see  compiler/spf_defwords.f
  CREATE
  HERE 0 , \ cell for wid
  WORDLIST ( addr wid )
  LATEST OVER CELL+ !   \ ссылка на им€ словар€
  GET-CURRENT OVER PAR! \ словарь-предок
  \ FORTH-WORDLIST SWAP CLASS! ( класс )
  SWAP ! \ сам wid
  VOC    \ признак "словарь"
  DOES> @ CONTEXT !
;
' VOCABULARY SWAP REPLACE-WORD  \ чтобы повли€ло и на 'MODULE:', и было совместимо со storage.f


' MAKE-EXTR ENUM-VOCS \ фикс существующих словарей (!!!)

;MODULE

WARNING !
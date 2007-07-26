\ 26.Jul.2007
\ Поддержка экстра-ячеек hash-table и storage-id
\ (Вариант, использующий WID-EXTRA из ядра)

MODULE: WidExtraSupport

3 CELLS CONSTANT /THIS-EXTR   \ [ hash-table | storage-id | free cell ]

: MAKE-EXTR ( wid -- )
  HERE DUP /THIS-EXTR DUP ALLOT ERASE
  ( wid here )
  SWAP WID-EXTRA !
;

: WID-CACHEA ( wid -- a )
  WID-EXTRA @ 
;
: WID-STORAGEA ( wid -- a )
  WID-EXTRA @ CELL+
;

EXPORT

WARNING @  WARNING 0!

: WID-EXTRA ( wid -- a )  \ будет свободная для других расширений ячейка
  WID-EXTRA @ 2 CELLS +  \ оптимизатор тут все правильно сделает :)
;

..: AT-WORDLIST-CREATING DUP MAKE-EXTR ;..

\ TEMP-WORDLIST не использует WORDLIST (нет события AT-WORDLIST-CREATING)
\ и само не используется в ядре. Поэтому, необходимо и достаточно переопределить:
: TEMP-WORDLIST ( -- wid )
  TEMP-WORDLIST GET-CURRENT >R  DUP SET-CURRENT DUP MAKE-EXTR R> SET-CURRENT
  \ расширение заголовка этого словря должно идти в его же временное хранилище
;

' MAKE-EXTR ENUM-VOCS-FORTH \ фикс существующих словарей (!!!)

WARNING !

;MODULE

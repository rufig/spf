\ 26.Jul.2007
\ ѕоддержка экстра-€чеек hash-table и storage-id
\ (¬ариант, использующий WID-EXTRA из €дра)

MODULE: WidExtraSupport

4 CELLS CONSTANT /THIS-EXTR   \ DataTypeLayout( cache-for-wid = x.cache-id x.storage-id x.obj-data x.reserved )

: MAKE-EXTR ( wid -- )
  ALIGN
  HERE DUP /THIS-EXTR DUP ALLOT ERASE
  ( wid a-addr[+ cache-for-wid ] )
  SWAP WID-EXTRA !
;

: WID-CACHEA ( wid -- a-addr[+ x.cache-id] )
  WID-EXTRA @
;
: WID-STORAGEA ( wid -- a-addr[+ x.storage-id] )
  WID-EXTRA @ CELL+
;
: WID-OBJA ( wid -- a-addr[+ x.obj-data ] )
  \ a slot for `OBJ-DATA` in "devel/~ac/lib/ns/ns.f"
  WID-EXTRA @ 2 CELLS +
;

EXPORT

WARNING @  WARNING 0!

: WID-EXTRA ( wid -- a-addr[+ x.reserved] )  \ будет свободна€ дл€ других расширений €чейка
  WID-EXTRA @ 3 CELLS +  \ оптимизатор тут все правильно сделает :)
;

..: AT-WORDLIST-CREATING DUP MAKE-EXTR ;..


' MAKE-EXTR ENUM-VOCS-FORTH \ фикс существующих словарей (!!!)

WARNING !

;MODULE

\ Работа с буфером последних введенных строк

  8 CONSTANT LruNum           \ число запоминаемых сообщений lru
255 CONSTANT LruLen           \ размер одной строки буфера lru
  0 VALUE CurrFromLru
  0 VALUE LruBuf \ буфер history (last recently used)

: LruAddr ( n -- addr )
  LruLen * LruBuf +
;

: NextLru
  CurrFromLru
  LruNum 1- = IF 0 TO CurrFromLru
           ELSE CurrFromLru 1+ TO CurrFromLru
           THEN
;
: PrevLru
  CurrFromLru
  0  =     IF LruNum 1- TO CurrFromLru
           ELSE CurrFromLru 1- TO CurrFromLru
           THEN
;

: AddToLru ( addr u )
  DUP 0= IF 2DROP EXIT THEN
  CurrFromLru
  LruAddr 2DUP C!
  1+ 2DUP 2>R
  SWAP CMOVE
  2R> + 0 SWAP C!
  NextLru
;

: UpLru ( -- addr u )
   PrevLru
   CurrFromLru
   LruAddr COUNT
;

: DownLru ( -- addr u )
   NextLru
   CurrFromLru
   LruAddr COUNT
;

: LruList
  LruNum 0
  DO
    I LruAddr ?DUP IF COUNT TYPE CR THEN
  LOOP
;

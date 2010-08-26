\ SHT = Sorted Hash Table

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE MD5  ~clf/md5-ts.f

0
CELL -- sht.key
CELL -- sht.value
  32 -- sht.keyhash
  32 -- sht.valhash
CELL -- sht.keyL
CELL -- sht.keyR
CELL -- sht.khL
CELL -- sht.khR
CELL -- sht.vhL
CELL -- sht.vhR
CELL -- sht.prev  \ для расплющивания дерева от узла, а не корня
CELL -- sht.vprev \ указатель на ячейку vh предка по хэшу значения
CELL -- sht.par   \ для отражения других иерархий
CELL -- sht.oval  \ для списка предыдущих значений
CELL -- sht.class \ опционально класс для [де]сериализации и пр.
CELL -- sht.mux   \ для mutex'а блокировки поддерева
CONSTANT /sht

\ Команда создания sht не нужна, это обычный указатель, т.е. переменная.

: (ST!) { vala valu node -- } \ fixme: можно хранить список пред.значений
  vala valu node sht.value S!
  vala valu MD5 node sht.valhash SWAP MOVE
;
: (ST!name) { keya keyu node -- }
  keya keyu node sht.key S!
  keya keyu MD5 node sht.keyhash SWAP MOVE
;
: (ST@K) { keya keyu sht \ pnode flag -- addr flag }
  \ flag здесь имеет смысл подобный COMPARE (а не SEARCH):
  \ если flag=0, то в дереве найдено точное совпадение ключа
  \ и addr=node - указатель на этот узел
  \ если flag не 0, то он 1 или -1 в зависимости от результата
  \ сравнения с последним (ближайшим по алфавиту) ключем,
  \ и addr - пустая переменная (keyL или leyR), куда надо 
  \ записать указатель на новый узел, если добавляется

\ fixme: эта и две последующие функции отличаются только используемым полем

  sht
  BEGIN \ параметром цикла является адрес указателя на узел sht
    DUP @
  WHILE
    -> pnode
    pnode @ sht.key @ STR@ keya keyu COMPARE
    ?DUP IF DUP -> flag
            0 < IF pnode @ sht.keyR ELSE pnode @ sht.keyL THEN
         ELSE pnode @ 0 EXIT THEN
  REPEAT
  ( pnode) flag
  DUP 0= IF DROP -1 THEN \ если sht вообще был пуст
;
: (ST@KH) { ha hu sht \ pnode flag -- addr flag }
  \ поиск по хэшу ключа
  \ обычно быстрее, чем по алфавиту, если входное множество не было
  \ предварительно осортировано по хэшам ключей...
  \ но для небольших множеств из-за вычисления MD5 может быть дороже
  sht
  BEGIN \ параметром цикла является адрес указателя на узел sht
    DUP @
  WHILE
    -> pnode
    pnode @ sht.keyhash 32 ha hu COMPARE
    ?DUP IF DUP -> flag
            0 < IF pnode @ sht.khR ELSE pnode @ sht.khL THEN
         ELSE pnode @ 0 EXIT THEN
  REPEAT
  ( pnode) flag
  DUP 0= IF DROP -1 THEN \ если sht вообще был пуст
;
: (ST@VH) { ha hu sht \ pnode flag -- addr flag }
  \ поиск по хэшу значения; неполный, если значения ключей менялись!
  sht
  BEGIN \ параметром цикла является адрес указателя на узел sht
    DUP @
  WHILE
    -> pnode
    pnode @ sht.valhash 32 ha hu COMPARE
    ?DUP IF DUP -> flag
            0 < IF pnode @ sht.vhR ELSE pnode @ sht.vhL THEN
         ELSE pnode @ 0 EXIT THEN
  REPEAT
  ( pnode) flag
  DUP 0= IF DROP -1 THEN \ если sht вообще был пуст
;
VECT dST-VALDUP ' DROP TO dST-VALDUP

: ST! { vala valu keya keyu sht \ pnode node -- }
  keya keyu sht (ST@K) 0=
  \ можно было бы искать по "keya keyu MD5 sht (ST@KH) 0=",
  \ но тогда для подключения новых значений надо будет еще искать pnode
  IF \ найден, заменим значение
     -> node
     vala valu node (ST!)
     node sht.vprev @ ?DUP IF 0! THEN \ отключение поддерева хэшей значений,
                          \ т.к. без полной перестройки нарушается весь их порядок
     EXIT
  THEN
  -> pnode

  \ не найден, создадим
  /sht ALLOCATE THROW -> node
  vala valu node (ST!)
  keya keyu node (ST!name)
  pnode node sht.prev !
  node sht.keyhash 32 sht (ST@KH)
  IF node SWAP !
  ELSE ." (hash dup!)" DROP THEN \ большая удача или баг! :)
  node sht.valhash 32 sht (ST@VH)
  IF node OVER !
     node sht.vprev ! \ для будущей отвязки при смене значения
  ELSE dST-VALDUP THEN \ то же значение у другого ключа, это нормально
  node pnode !
;
: ST@ { keya keyu sht \ pnode -- vala valu }
  keya keyu sht (ST@K)
  IF DROP S" "
  ELSE sht.value @ STR@ THEN
;
: ST? { keya keyu sht \ pnode -- vala valu flag }
  keya keyu sht (ST@K)
  IF DROP S" " FALSE
  ELSE sht.value @ STR@ TRUE THEN
;
: ST@H { keya keyu sht \ pnode -- vala valu }
  keya keyu MD5 sht (ST@KH)
  IF DROP S" "
  ELSE sht.value @ STR@ THEN
;
: ST?H { keya keyu sht \ pnode -- vala valu flag }
  keya keyu MD5 sht (ST@KH)
  IF DROP S" " FALSE
  ELSE sht.value @ STR@ TRUE THEN
;
USER uST-RECLEVEL
USER uST-MAXRECLEVEL

: ST-FOREACH-SORTED { xt sht \ pnode -- }
\ xt: ( ... vala valu keya keyu node -- ... )
\ в порядке алфавитного возрастания ключа
\ дерево не балансируется при вставках, поэтому уровень рекурсии
\ может быть велик, не используйте на уже сортированных ключах ;)
  uST-RECLEVEL 1+! uST-RECLEVEL @ uST-MAXRECLEVEL @ MAX uST-MAXRECLEVEL !
  sht @ 0= IF EXIT THEN
  sht @ sht.keyL DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  sht @ sht.value @ STR@ sht @ sht.key @ STR@ sht @ xt EXECUTE
  sht @ sht.keyR DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  uST-RECLEVEL @ 1- uST-RECLEVEL !
;

: ST-FOREACH-HASHED { xt sht \ pnode -- }
\ xt: ( ... vala valu keya keyu node -- ... )
\ ключи выдаются в случайном порядке (хэши по алфавиту),
\ и уровень рекурсии не видел глубже 32
  uST-RECLEVEL 1+! uST-RECLEVEL @ uST-MAXRECLEVEL @ MAX uST-MAXRECLEVEL !
  sht @ 0= IF EXIT THEN
  sht @ sht.khL DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  sht @ sht.value @ STR@ sht @ sht.key @ STR@ sht @ xt EXECUTE
  sht @ sht.khR DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  uST-RECLEVEL @ 1- uST-RECLEVEL !
;

: ST-FOREACH-VHASHED { xt sht \ pnode -- }
\ xt: ( ... vala valu keya keyu node -- ... )
\ цикл по уникальным значениям (не ключам) из дерева,
\ т.е. в общем случае не по всем ключам
\ и даже не по всем значениям, если они менялись у ключей
  uST-RECLEVEL 1+! uST-RECLEVEL @ uST-MAXRECLEVEL @ MAX uST-MAXRECLEVEL !
  sht @ 0= IF EXIT THEN
  sht @ sht.vhL DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  sht @ sht.value @ STR@ sht @ sht.key @ STR@ sht @ xt EXECUTE
  sht @ sht.vhR DUP @ IF xt SWAP RECURSE ELSE DROP THEN
  uST-RECLEVEL @ 1- uST-RECLEVEL !
;

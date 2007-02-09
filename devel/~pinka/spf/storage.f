\ 23.Dec.2006 Sat 16:08, ruvim@forth.org.ru
\ $Id$
( Поддержка полноценных хранилищ для SPF4.
  Определяемое ниже хранилище основанно на простейшем [storage-core.f]
  и имеет следующие дополнения:
    - текущий список слов для добавления,
    - список слов по умолчанию, для вновь созданных хранилищ,
    - список словарей [списков слов, VOC-LIST], он тоже привязан к хранилищу.

  Словари расширены знанием свого хранилища, чтобы
  SET-CURRENT устанавливало текущим и хранилище,
  в котором располагается словарь.

  В дочерних потоках текущее хранилище и текущий словарь не установлены!
  Перед тем, как что-то откладывать, программа в своем потоке
  должна установить текущее [то бишь, целевое] хранилище или словарь.
  Устанавливаемое хранилище должно быть 'свободно' от других потоков,
  то есть, оно не должно быть текущим в каком-либо другом потоке.

  Модуль предоставляет новые варианты слов
  TEMP-WORDLIST - создает временное хранилище и в нем словарь,
  и FREE-WORDLIST - освобождающее хранилище, в котором расположен словарь.
  ORDER выдает вершину контекста справа!

  Модуль определяет слово UNUSED, учитывающее текущее хранилище, поэтому 
  при использовании lib/include/core-ext.f оно должно быть подключено раньше,
  т.к. в нем UNUSED тоже определяется.


  Cовместимо с quick-swl3.f, который следует подгружать после данного модуля.
)

REQUIRE Included ~pinka\lib\ext\requ.f
REQUIRE REPLACE-WORD lib\ext\patch.f
REQUIRE NDROP    ~pinka\lib\ext\common.f

WARNING @  WARNING 0!

: AT-SAVING-BEFORE ... ;
: AT-SAVING-AFTER ... ;

: SAVE ( addr u -- )
  AT-SAVING-BEFORE
  SAVE
  AT-SAVING-AFTER
;
\ Т.к. надо сбросить базовое хранилище перед сохранением.


' DP
USER DP ( -- addr ) \ переменная, содержащая HERE сегмента данных

DUP EXECUTE @ DP !  ' DP SWAP REPLACE-WORD
\ заменили старое DP, чтобы не переопределять все откладывающие слова

USER STORAGE \ текущее хранилище. 
              \ Для вновь созданного потока будет неопределеным.

S" storage-core.f" Included

\ расширение простейшего хранилища:

..: AT-FORMATING ( -- )
  ( ALIGN) HERE STORAGE-EXTRA !
  0 ,       \ 0, current wid
  0 ,       \ 1, extra
  HERE 0 ,  \ 2, default wid
  0 ,       \ 3, voc-list
  WORDLIST
  DUP STORAGE-EXTRA @ ! \ to current
  SWAP !                \ to default
;..

..: AT-DISMOUNTING ( -- )
  CURRENT @  STORAGE-EXTRA @  !  CURRENT 0!
;..

..: AT-MOUNTING ( -- )
  STORAGE-EXTRA @  @ CURRENT !
;..

: DEFAULT-WORDLIST ( -- wid )
  STORAGE-EXTRA @  CELL+ CELL+ @
;

VOC-LIST @ ' VOC-LIST 
( old-voc-list@  'voc-list )

CREATE _VOC-LIST-EMPTY 0 , 
\ если кто-то захочет перебирать словари без подключения хранилища.

: VOC-LIST ( -- addr )
  STORAGE-ID IF STORAGE-EXTRA @ 3 CELLS + EXIT THEN _VOC-LIST-EMPTY
;
' VOC-LIST SWAP REPLACE-WORD

: STORAGE-EXTRA ( -- a ) \ свободная ячейка
  STORAGE-EXTRA @ CELL+
;

( old-voc-list@ )
ALIGN HERE IMAGE-SIZE HERE IMAGE-BASE - - ( addr u ) \ see  lib/include/core-ext.f
FORMAT
  DUP MOUNT \ (!!!)
  FORTH-WORDLIST SET-CURRENT
CONSTANT FORTH-STORAGE  \ базовое хранилище форт-системы

( old-voc-list@ ) VOC-LIST !  \ список словарей базового хранилища

..: AT-PROCESS-STARTING  FORTH-STORAGE MOUNT ;..

..: AT-SAVING-BEFORE FLUSH-STORAGE ;..


\ ==================================================

Include enum-vocs.f  \ чтобы использовали новый VOC-LIST

\ ========
\ Чтобы при SET-CURRENT текущим становилось и хранилище, в котором расположен словарь,
\ необходимо чтобы словарь знал свое хранилище.

Require WidExtraSupport  wid-extra.f
\ там определяется и WORDLIST с учетом нового VOC-LIST
\ и ячейка WID-STORAGEA

MODULE: WidExtraSupport

: MAKE-EXTR ( wid -- )
  STORAGE-ID SWAP WID-STORAGEA !
;

..: AT-WORDLIST-CREATING DUP MAKE-EXTR ;..

EXPORT

: WL-STORAGE ( wid -- h-storage )
  WID-STORAGEA @
;

' MAKE-EXTR ENUM-VOCS  \ прописываю STORAGE-ID для существующих словарей

;MODULE

\ переопределяем все слова, завязанные на SET-CURRENT
\ (т.к. оптимизатор делал подстановку, и перехвата только причинного слова недостаточно)

' SET-CURRENT
: SET-CURRENT ( wid -- )
  DUP IF DUP WL-STORAGE MOUNT  CURRENT ! EXIT THEN
  CURRENT ! DISMOUNT DROP
;
' SET-CURRENT SWAP REPLACE-WORD

\ ..: AT-THREAD-STARTING CURRENT 0! ;.. 
\ из дочернего потока нельзя писать в занятое основным потоком базовое хранилище

' DEFINITIONS
: DEFINITIONS ( -- ) \ 94 SEARCH
  CONTEXT @ SET-CURRENT
;
' DEFINITIONS  SWAP REPLACE-WORD

' MODULE:
: MODULE: ( "name" -- old-current )
  >IN @ 
  ['] ' CATCH
  IF >IN ! VOCABULARY LATEST NAME> ELSE NIP THEN
  GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS
;
' MODULE: SWAP REPLACE-WORD


: ORDER ( -- ) \ 94 SEARCH EXT
  GET-ORDER ." Context>: "
  DUP >R BEGIN DUP WHILE DUP PICK VOC-NAME. SPACE 1- REPEAT DROP R> NDROP CR
  ." Current: " GET-CURRENT DUP IF VOC-NAME. ELSE DROP ." <not mounted>" THEN CR
;

\ =====
\ Временные хранилища и словари

: AT-STORAGE-DELETING ( -- ) ... ;

: NEW-STORAGE ( size -- h )
  DUP ALLOCATE THROW SWAP 
  2DUP ERASE FORMAT
;
: DEL-STORAGE ( h -- )
  PUSH-MOUNT AT-STORAGE-DELETING POP-MOUNT FREE THROW
;

: TEMP-WORDLIST ( -- wid )
\ создаст временное хранилище в текущей куче (хипе)
\ и в нем словарь
  WL_SIZE NEW-STORAGE PUSH-MOUNT
  DEFAULT-WORDLIST  POP-MOUNT DROP
;
: FREE-WORDLIST ( wid -- )
  WL-STORAGE DEL-STORAGE
;

WARNING !
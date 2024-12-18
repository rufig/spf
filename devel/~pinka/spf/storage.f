\ 23.Dec.2006 Sat 16:08, ruvim@forth.org.ru
\ $Id$
( Поддержка полноценных хранилищ для SPF4.
    
    Штатные временные словари, которые создаются через TEMP-WORDLIST,
    имеют следующий недостаток: в них нельзя создавать вложенные обычные 
    словари через WORDLIST или производные от него слова. Если во
    временном словаре будет создан обычный словарь, то возникнут 
    следующие проблемы:
      - содержимое этого словаря пойдет в общее базовое хранилище;
        - при параллельной компиляции получится мусор;
        - при освобождение временного словаря возникает утечка
          в базовом хранилище;
      - после освобождения временного словаря список словарей VOC-LIST
        будет некорректен.
    Поддержка полноценных хранилищ, независимых от списков слов, 
    снимает эти проблемы.

  Определяемое ниже хранилище основанно на простейшем [storage-core.f]
  и имеет следующие дополнения:
    - текущий список слов для добавления,
    - список слов по умолчанию, для вновь созданных хранилищ,
    - список словарей [списков слов, VOC-LIST], он тоже привязан к хранилищу.

  Словари расширены знанием своего хранилища, чтобы
  SET-CURRENT устанавливало текущим и хранилище,
  в котором располагается словарь.

  В дочерних потоках текущее хранилище и текущий словарь не установлены!
  Перед тем, как что-то откладывать, программа в своем потоке
  должна установить текущее [то бишь, целевое] хранилище или словарь.
  Устанавливаемое хранилище должно быть 'свободно' от других потоков,
  то есть, оно не должно быть текущим в каком-либо другом потоке.

  Модуль предоставляет новые варианты слов:
    TEMP-WORDLIST -- создает временное хранилище и в нем словарь,
    FREE-WORDLIST -- освобождающее хранилище, в котором расположен словарь.
    ORDER выдает вершину контекста справа!
    SAVE -- вызывает AT-SAVING-BEFORE и AT-SAVING-AFTER
    SET-CURRENT и DEFINITIONS -- учитывают новый локальный для потока DP.

    Важно: нельзя освобождать словарь, если он используется; т.е. 
    делать FREE-WORDLIST, когда этот словарь в CURRENT или CONTEXT,
    тоже самое и для хранилищ.

  Модуль определяет слово UNUSED, учитывающее текущее хранилище, поэтому 
  при использовании lib/include/core-ext.f оно должно быть до storage.f,
  т.к. в нем UNUSED тоже определяется.
  В остальном же, storage.f должен быть подключен на самой ранней стадии.

  Дискуссия:
    оправдано ли значению CURRENT быть локальным для хранилища, как сейчас.


  Cовместимо с quick-swl3.f, который следует подгружать после данного модуля.
)

REQUIRE Included ~pinka/lib/ext/requ.f
REQUIRE REPLACE-WORD lib/ext/patch.f
REQUIRE NDROP    ~pinka/lib/ext/common.f

WARNING @  WARNING 0!

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
  HERE 0 ,  \ 0, current wid
  0 ,       \ 1, extra
  HERE 0 ,  \ 2, default wid
  0 ,       \ 3, voc-list
  0 ,       \ 4, isBusy -- for debug
  WORDLIST DUP ROT ! \ to default
  SWAP !             \ to current
;..

..: AT-DISMOUNTING ( -- )
  STORAGE-EXTRA @  CURRENT @ OVER !  4 CELLS + 0!  CURRENT 0!
;..

..: AT-MOUNTING ( -- )
  STORAGE-EXTRA @  DUP
  4 CELLS +  DUP  @ IF -2012 THROW THEN -1 SWAP !
  @ CURRENT !
;..

: DEFAULT-WORDLIST ( -- wid )
  STORAGE-EXTRA @  CELL+ CELL+ @
;

VOC-LIST @
( old-voc-list@ )

CREATE _VOC-LIST-EMPTY 0 ,
\ если кто-то захочет перебирать словари без подключения хранилища.

: VOC-LIST2 ( -- addr )
  STORAGE-ID IF STORAGE-EXTRA @ 3 CELLS + EXIT THEN _VOC-LIST-EMPTY
;
' VOC-LIST2 TO VOC-LIST

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

: AT-SAVING-BEFORE ... ; 
: AT-SAVING-AFTER ... ;

: CODESPACE-CONTENT ( -- addr u )
  STORAGE-ID FORTH-STORAGE <> IF CODESPACE-CONTENT EXIT THEN
  IMAGE-BASE DP @ OVER -
;
: FLUSH-STORAGE ( -- )
  STORAGE-ID FORTH-STORAGE = IF IMAGE-BASE IMAGE-SIZE +  STORAGE-ID 3 CELLS + ! THEN
  FLUSH-STORAGE
;
: SAVE ( addr u -- )
  STORAGE-ID FORTH-STORAGE <> ABORT" Current storage is not FORTH-STORAGE"
  AT-SAVING-BEFORE
  FLUSH-STORAGE STORAGE-EXTRA 3 CELLS + DUP >R 0! \ сохранить надо с флагом "незанято"
  SAVE
  -1 R> !
  AT-SAVING-AFTER
;
\ Т.к. надо сбросить базовое хранилище перед сохранением; оно должно быть текущим.


\ ==================================================
\ Чтобы при SET-CURRENT текущим становилось и хранилище, в котором расположен словарь,
\ необходимо чтобы словарь знал свое хранилище.

Require WidExtraSupport  wid-extra.f  \ ячейка WID-STORAGEA

MODULE: WidExtraSupport

: MAKE-EXTR-STORAGE ( wid -- )
  STORAGE-ID SWAP WID-STORAGEA !
;
..: AT-WORDLIST-CREATING  DUP MAKE-EXTR-STORAGE ;..

EXPORT

: WL-STORAGE ( wid -- h-storage )
  WID-STORAGEA @
;

' MAKE-EXTR-STORAGE ENUM-VOCS-FORTH  \ прописываю STORAGE-ID для существующих словарей

;MODULE


\ Переопределяем все слова, завязанные на SET-CURRENT
\ (т.к. оптимизатор делал подстановку, и перехвата только причинного слова недостаточно)

: SET-CURRENT ( wid -- )
  DUP IF DUP WL-STORAGE MOUNT  CURRENT ! EXIT THEN
  CURRENT ! DISMOUNT DROP
;

..: AT-THREAD-STARTING STORAGE-ID 0= IF CURRENT 0! THEN ;..
\ из дочернего потока нельзя писать в занятое основным потоком базовое хранилище

: DEFINITIONS ( -- ) \ 94 SEARCH
  CONTEXT @ SET-CURRENT
;

: MODULE: ( "name" -- old-current )
  >IN @ 
  ['] ' CATCH
  IF >IN ! VOCABULARY LATEST-NAME-XT ELSE NIP THEN
  GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS
;
: ;MODULE ( old-current -- )
  SET-CURRENT PREVIOUS
;


: ORDER ( -- ) \ 94 SEARCH EXT
  GET-ORDER ." Context>: "
  DUP >R BEGIN DUP WHILE DUP PICK VOC-NAME. SPACE 1- REPEAT DROP R> NDROP CR
  ." Current: " GET-CURRENT DUP IF VOC-NAME. ELSE DROP ." <not mounted>" THEN CR
;

\ =====
\ Временные хранилища и словари

: AT-STORAGE-DELETING ( -- ) ... ;

: NEW-STORAGE ( size -- h )
  DUP ALLOCATE-RWX THROW (FIX-MEMTAG) SWAP
  2DUP ERASE FORMAT
;
: DEL-STORAGE ( h -- )
  PUSH-MOUNT AT-STORAGE-DELETING POP-MOUNT FREE-RWX THROW
;

: TEMP-WORDLIST ( -- wid )
\ создаст временное хранилище в текущей куче (хипе)
\ и в нем словарь
  WL_SIZE NEW-STORAGE (FIX-MEMTAG) PUSH-MOUNT
  DEFAULT-WORDLIST  POP-MOUNT DROP
;
: FREE-WORDLIST ( wid -- )
  WL-STORAGE DEL-STORAGE
;
: IS-TEMP-WORDLIST ( wid -- flag )
  WL-STORAGE FORTH-STORAGE <>
;
: IS-TEMP-WL ( -- flag )
  GET-CURRENT IS-TEMP-WORDLIST
;

WARNING !

Include storage-enum.f

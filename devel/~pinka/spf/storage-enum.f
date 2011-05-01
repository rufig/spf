\ 26.Jul.2007 наследован от exc-dump.f
\ $Id$
( ћодуль предоставл€ет ENUM-STORAGES и поддержку WordByAddr дл€ множества хранилищ.
)

REQUIRE NEW-STORAGE  ~pinka/spf/storage.f
REQUIRE [UNDEFINED] lib/include/tools.f

MODULE: storage-support

REQUIRE BIND-NODE ~pinka/samples/2006/lib/plain-list.f

USER STORAGE-LIST \ список хранилищ, созданных потоком

: excide-this ( -- ) \ выкинуть
  STORAGE-ID STORAGE-LIST FIND-LIST IF UNBIND-NODE DROP THEN
;
: enroll-this ( -- ) \ вписать
  excide-this
  0 , HERE STORAGE-ID , STORAGE-LIST BIND-NODE
;

..: AT-FORMATING         enroll-this  ;..
..: AT-STORAGE-DELETING  excide-this  ;..

: (WITHIN-STORAGE) ( xt h -- xt ) \ for inner purpose only
  \ OVER DISMOUNT 2>R MOUNT EXECUTE 2R> MOUNT
  OVER STORAGE @ 2>R STORAGE ! CATCH R> STORAGE ! THROW R>
;

EXPORT

: ENUM-STORAGES ( xt -- ) \ xt ( h -- )
  >R FORTH-STORAGE R@ EXECUTE
  R> STORAGE-LIST FOREACH-LIST-VALUE
;

DEFINITIONS

: ENUM-STORAGES-WITHIN ( xt -- ) \ xt ( -- ) \ for inner purpose only
  ['] (WITHIN-STORAGE) ENUM-STORAGES DROP
;

\ EXPORT

: (NEAREST4) ( addr nfa1 -- addr nfa2 )
  OVER CODESPACE-CONTENT OVER + WITHIN IF 
    \ [ ' (NEAREST-NFA) BEHAVIOR EXEC, ]
    (NEAREST3)
  THEN
;
: (NEAREST_STOR) ( addr nfa1|0 -- addr nfa2|0 )
  ['] (NEAREST4)  ENUM-STORAGES-WITHIN
;

' (NEAREST_STOR) TO (NEAREST-NFA)

;MODULE

Require VOCS vocs.f

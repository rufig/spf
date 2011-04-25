REQUIRE PUSH-DEVELOP   ~pinka/spf/compiler/native-context.f
REQUIRE ENUM-USERAREAS ~pinka/spf/enum-userareas2.f

REQUIRE storage-support   ~pinka/spf/storage.f

\ для USER-переменной BEHAVIOR дает смещение в USER-области

[UNDEFINED] storage-support-wl [IF]
  ALSO storage-support CONTEXT @ CONSTANT storage-support-wl PREVIOUS
[THEN]

storage-support-wl PUSH-DEVELOP

: (ENUM-STORAGELISTS) ( xt userarea -- xt ) \ xt ( list -- )
  ['] STORAGE-LIST BEHAVIOR +
  SWAP DUP >R EXECUTE R>
;
: ENUM-STORAGELISTS ( xt -- )
  ['] (ENUM-STORAGELISTS) ENUM-USERAREAS
  DROP
;
: (ENUM-STORAGES-ALL) ( xt list -- xt ) \ xt ( h -- )
  OVER >R FOREACH-LIST-VALUE R>
;

BEGIN-EXPORT

: ENUM-STORAGES-ALL ( xt -- ) \ xt ( h -- )
\ except basic FORTH-STORAGE
  ['] (ENUM-STORAGES-ALL) ENUM-STORAGELISTS DROP
;

END-EXPORT

: ENUM-STORAGES-ALL-WITHIN ( xt -- ) \ xt ( -- )
  ['] (WITHIN-STORAGE) ENUM-STORAGES-ALL DROP
;
: (ENUM-STORAGELISTS-WITHIN) ( xt list -- xt ) \ xt ( -- )
  @ STORAGE-LIST !
  DUP >R EXECUTE R>
;
: ENUM-STORAGELISTS-WITHIN ( xt -- )
  STORAGE-LIST @ >R
     ['] (ENUM-STORAGELISTS-WITHIN) ['] ENUM-STORAGELISTS   CATCH
  R> STORAGE-LIST !                                         THROW
  DROP
;

BEGIN-EXPORT

: (NEAREST_STOR_ALL) ( addr nfa1|0 -- addr nfa2|0 )
  [ ' (NEAREST3) LIT, ]  ENUM-STORAGES-ALL-WITHIN
  [ ' (NEAREST3) LIT, ]  FORTH-STORAGE (WITHIN-STORAGE) DROP
;

' (NEAREST_STOR_ALL) TO (NEAREST-NFA)

END-EXPORT

DROP-DEVELOP


\EOF

: (NEAREST_STOR_ALL) ( addr nfa1|0 -- addr nfa2|0 )
  [ ' (NEAREST-NFA) BEHAVIOR EXEC, ] ENUM-STORAGELISTS-WITHIN
;

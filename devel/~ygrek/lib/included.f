( Расширение поиска для INCLUDED
  Если файл не найден оригинальным FIND-FULLNAME'ом, перебираются 
  слова из included_path и трактуются как пути /относительно ModuleDir
  или абсолютные/ для поиска. 
  Использовать в spf4.ini в виде:

  ~ygrek/lib/included.f
  MODULE: included_path
   CREATE my_path/
   S" My path with spaces/" CREATED
  ;MODULE

  Слеш в конце обязателен

  28.Jun.2006 )

REQUIRE ForEach ~ac/lib/ns/iterators.f

MODULE: included_path
\ CREATE D:/WORK/FORTH/spf4/devel2/
\ CREATE devel2/
;MODULE

MODULE: EXTRA-INCLUDED

0 VALUE a
0 VALUE u

1024 CONSTANT buf-size
CREATE buf buf-size ALLOT

: ?full-path ( a u -- ? )
  DUP 0= IF 2DROP FALSE EXIT THEN
  OVER C@ is_path_delimiter IF 2DROP TRUE EXIT THEN
  DUP 3 < IF 2DROP FALSE EXIT THEN
  DROP
  1+ DUP C@ [CHAR] : <> IF DROP FALSE EXIT THEN
  1+ DUP C@ is_path_delimiter 0= IF DROP FALSE EXIT THEN
  DROP TRUE
 ;

(
: MUST 0= ABORT" Test failed" ;
: yes ?full-path MUST ;
: no ?full-path 0= MUST ;
: test
 S" D:\a" yes
 S" d" no
 S" \" yes
 S" \dsds" yes
 S" dsds" no
 S" root\dsd\dasd\sd/" no
 S" /" yes
 S" /e" yes
 S" /re/r.at" yes
 S" re/r.at" no
 S" A:/a.txt" yes
 S" A:dsd" no
 S" C:/" yes
 S" C:" no
 ." Test passed" ;
 test BYE
)

: +auName ( a u -- a u2 )
  2DUP + a u DUP >R ROT SWAP 1+ MOVE R> + ;

: buf-copy ( a u -- a2 u2 )
  >R 
  R@ buf-size > IF ABORT" buf-copy fails" THEN
  buf R@ CMOVE
  buf R>
;

: +DirName ( daddr du -- addr2 u2 )
  buf-copy
  2DUP ?full-path 0= IF +ModuleDirName buf-copy THEN
  +auName ;

0 VALUE ?found

: CHECK
   ?found IF DROP EXIT THEN
   NAME +DirName 
   2DUP FILE-EXIST IF 
    TO u TO a
    TRUE TO ?found
   ELSE
    2DROP THEN ;

: FIND-FULLNAME2 ( a1 u1 -- a u )
  ['] FIND-FULLNAME1 CATCH 0= IF EXIT THEN
\  ." Find: " 2DUP TYPE CR
  ALSO included_path CONTEXT @ PREVIOUS >R
   TO u
   TO a
   0 TO ?found
   ['] CHECK R> ForEach
   ?found 0= IF 2 THROW THEN
\   ." Found: " a u TYPE CR
   a u
;

' FIND-FULLNAME2 TO FIND-FULLNAME

;MODULE

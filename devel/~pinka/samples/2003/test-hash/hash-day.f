\ 01.Nov.2003 Sat 18:15

S" ~day\common\hash.f" INCLUDED
\ старый by ~day, новая функция реализована Дмитрием в сорцах spf4.

: HASH ( a u u1 -- u2 )
  >R HASH R> ?DUP IF UMOD THEN
;

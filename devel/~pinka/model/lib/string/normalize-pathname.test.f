REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`match.f.xml EMBODY

`normalize-pathname.f.xml EMBODY

ALSO SO NEW: libxml2.dll

: normalizeURI ( addr-z u1 -- addr u2 )
  OVER >R `: SEARCH NIP IF CHAR+ THEN \ cut out a scheme
  1 xmlNormalizeURIPath THROW \ work for pathnames only 
  R> ASCIIZ>
;
: normalizeURI ( addr-z u1 -- addr u2 )
  OVER
  1 xmlNormalizeURIPath THROW \ work for pathnames only 
  DROP ASCIIZ>
;

PREVIOUS

: _NORMALIZE-PATHNAME-INPLACE  \ for test
  `/../asdf SPLIT DROP
\  2DUP OVER SWAP CMOVE
\  2DUP OVER SWAP MOVE
   2DUP OVER SWAP CMOVE-CERTAIN
;

  S" aaa/bbb/ccc/../../../ddd/eee/fff/../../ooo" normalizeURI TYPE CR
  S" aaa/bbb/ccc/../../../ddd/eee/fff/../../ooo" NORMALIZE-PATHNAME-INPLACE TYPE CR

~pinka\lib\Tools\profiler.f

: t-(libxml2)
  100000 0 DO
  S" aaa/bbb/ccc/../../../ddd/eee/fff/../../ooo" PAD OVER SEATED
  normalizeURI 2DROP
  LOOP
;
: t-(native)
  100000 0 DO
  S" aaa/bbb/ccc/../../../ddd/eee/fff/../../ooo" PAD OVER SEATED
  NORMALIZE-PATHNAME-INPLACE 2DROP
  LOOP
;
profile off

: test
  300 PAUSE
  t-(native)
  300 PAUSE
  t-(libxml2)
  .AllStatistic
;

\EOF

\ Делать копию через >STR ... STRFREE  -- в два раза дольше тест работает
\ (~450 вместо ~200)

Разница во времени работы слов t-(libxml2) и t-(native) зависит от процессора.
Например, на AMD Turion 64 X2 время соотносится как ~ 150/220 (=0.68) соответственно,
а на Interl Pentium 4 -- как ~ 230/560 (=0.41) (в тиках процессора).

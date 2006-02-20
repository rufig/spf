\ 20.Feb.2006 ruv

( prime is get_url_params.f by ~ac
  storeParamsFromString -- store params to hash-table. Max value length is 256 octets.
  New syntax:
    param.name [ -- addr u ]
    wasParam.name [ -- flag ]
  Also allowed:
    S" name" param [ -- addr u ]
    S" name" wasParam [ -- flag ]
)

REQUIRE ""                ~ac\lib\str5.f
REQUIRE PARSE-URN-PARAMS  ~pinka\samples\2006\lib\parse-urn.f
REQUIRE AsLaterSintax     ~pinka\samples\2006\syntax\later.f 

USER uPARAMS-TBL

: param ( a u -- a1 u1 )
  uPARAMS-TBL @ ?DUP IF HASH@ EXIT THEN
  2DROP 0.
;
: isParam ( a u -- a1 u1 true | false )
  param DUP IF TRUE EXIT THEN
  2DROP FALSE
;
: wasParam ( a u -- flag )
  uPARAMS-TBL @ ?DUP IF HASH? EXIT THEN
  2DROP FALSE
;
: setParam ( a-val u-val a u -- )
  uPARAMS-TBL @ DUP 0= IF DROP small-hash DUP uPARAMS-TBL ! THEN
  HASH!
;

: storeParamsFromString ( a u -- )
  uPARAMS-TBL @ ?DUP IF del-hash uPARAMS-TBL 0! THEN
  PARSE-URN-PARAMS uPARAMS-TBL !
;

: DumpParam ( name-a name-u addr -- )
  COUNT 2SWAP
  " <tr><td>{s}</td><td>{s}</td></tr>" EVALUATE.str @ S+
;
: DumpParams ( -- a u )
  uPARAMS-TBL @ 0= IF 0. EXIT THEN
  TEMP-WORDLIST DUP >R ALSO CONTEXT !
  GET-CURRENT >R DEFINITIONS
   S" str" CREATED " <table>" DUP , ( s )
    ['] DumpParam uPARAMS-TBL @ all-hash
   DUP S" </table>" ROT STR+
  R> SET-CURRENT
  PREVIOUS R> FREE-WORDLIST
  STR@
;

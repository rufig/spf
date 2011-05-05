\ микроутилитки для парсера строк по строковым ограничителям 
\ без EVALUATE-WITH
\ см. примеры

REQUIRE {             lib/ext/locals.f

: StringBefore { a u sa su -- fa fu flag }
  a u sa su SEARCH
  IF NIP u SWAP - a SWAP TRUE
  ELSE FALSE THEN
;
: StringAfter { a u sa su -- fa fu flag }
  a u sa su SEARCH
  IF su - SWAP su + SWAP TRUE
  ELSE FALSE THEN
;
: StringBetween { a u aa au ba bu -- fa fu flag }
  a u aa au StringAfter
  IF ba bu StringBefore
  ELSE FALSE THEN
;
: SBetween { a u aa au ba bu -- fa fu }
  a u aa au StringAfter DROP ba bu StringBefore DROP
;

\EOF

S" OpenSSL 0.9.8g 19 Oct 2007" S" SSL " StringAfter DROP S"  " StringBefore DROP TYPE CR
S" libcurl/7.18.0 OpenSSL/0.9.8g zlib/1.2.3 libssh2/0.17" S" libcurl/" StringAfter DROP S"  " StringBefore DROP TYPE CR

S" OpenSSL 0.9.8g 19 Oct 2007" S" SSL " S"  " StringBetween . TYPE CR
S" libcurl/7.18.0 OpenSSL/0.9.8g zlib/1.2.3 libssh2/0.17" S" libcurl/" S"  " SBetween TYPE CR

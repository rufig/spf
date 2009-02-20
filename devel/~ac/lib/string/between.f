\ микроутилитки для парсера строк по строковым ограничителям 
\ без EVALUATE-WITH
\ см. примеры

REQUIRE {             ~ac/lib/locals.f

: StrBefore { a u sa su -- fa fu flag }
  a u sa su SEARCH
  IF NIP u SWAP - a SWAP TRUE
  ELSE FALSE THEN
;
: StrAfter { a u sa su -- fa fu flag }
  a u sa su SEARCH
  IF su - SWAP su + SWAP TRUE
  ELSE FALSE THEN
;
: StrBetween { a u aa au ba bu -- fa fu }
  a u aa au StrAfter DROP ba bu StrBefore DROP
;

\EOF

S" OpenSSL 0.9.8g 19 Oct 2007" S" SSL " StrAfter DROP S"  " StrBefore DROP TYPE CR
S" libcurl/7.18.0 OpenSSL/0.9.8g zlib/1.2.3 libssh2/0.17" S" libcurl/" StrAfter DROP S"  " StrBefore DROP TYPE CR

S" OpenSSL 0.9.8g 19 Oct 2007" S" SSL " S"  " StrBetween TYPE CR
S" libcurl/7.18.0 OpenSSL/0.9.8g zlib/1.2.3 libssh2/0.17" S" libcurl/" S"  " StrBetween TYPE CR

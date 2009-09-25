\ Еще один вариант реализации тех же хэш-функций, что и в gcrypt.f,
\ и тех же crc, что в zlib.f. Экономия порядка 200кб (лишних dll),
\ если требуются только эти функции.

\ http://mhash.sourceforge.net/mhash.3.html

\ Под Linux не тестировалось.

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE {             lib/ext/locals.f

 0 CONSTANT MHASH_CRC32
 1 CONSTANT MHASH_MD5
 2 CONSTANT MHASH_SHA1
 9 CONSTANT MHASH_CRC32B
16 CONSTANT MHASH_MD4
17 CONSTANT MHASH_SHA256
18 CONSTANT MHASH_ADLER32

ALSO SO NEW: libmhash.dll

: MHASH { addr u algo \ td hu -- ha hu }
  algo 1 mhash_init -> td
  u addr td 3 mhash DROP
  td 1 mhash_end ( ha)
  algo 1 mhash_get_block_size DUP -> hu
  HEAP-COPY hu
  0 td 2 mhash_deinit DROP
;
: HMAC { addr u keya keyu algo \ td hu -- ha hu }
  algo 1 mhash_get_hash_pblock keyu keya algo 4 mhash_hmac_init -> td
  u addr td 3 mhash DROP
  td 1 mhash_hmac_end ( ha)
  algo 1 mhash_get_block_size DUP -> hu
  HEAP-COPY hu
\  0 td 2 mhash_hmac_deinit DROP \ какая-то там ошибка...
;
PREVIOUS

: MD5B ( a u -- ha hu ) \ см. gcrypt.f
  MHASH_MD5 MHASH
;
: SHA1B ( a u -- ha hu ) \ см. gcrypt.f
  MHASH_SHA1 MHASH
;
: CRC32 ( a u -- x ) \ см. zlib.f
  MHASH_CRC32B MHASH DROP @
;
: ADLER32 ( a u -- x ) \ см. zlib.f
  MHASH_ADLER32 MHASH DROP @
;
: HMAC-MD5 ( addr u keya keyu  -- ha hu )
  MHASH_MD5 HMAC
;
: HMAC-SHA1 ( addr u keya keyu  -- ha hu )
  MHASH_SHA1 HMAC
;
: HMAC-SHA256 ( addr u keya keyu  -- ha hu )
  MHASH_SHA256 HMAC
;

\EOF
S" test" MD5B DUMP CR
S" test" SHA1B DUMP CR
S" test" CRC32 . CR
S" test" ADLER32 . CR

\ тесты из RFC2202:
S" what do ya want for nothing?" S" Jefe" HMAC-MD5 DUMP CR \ 0x750c783e6ab0b503eaa86e310a5db738
S" what do ya want for nothing?" S" Jefe" HMAC-SHA1 DUMP CR \ 0xeffcdf6ae5eb2fa2d27416d5f184df9c259a7c79

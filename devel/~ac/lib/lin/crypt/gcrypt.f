( Обертки для бинарных вариантов функций MD5B и SHA1B, а также HMAC.
  Традиционные строчные MD5 см. в ~clf/md5-ts.f
  $Id$
)
\ Кроме libgcrypt.dll требуется libintl-2.dll
\ Испытано с 1.2.1 под Windows (http://www.forth.org.ru/ext/libgcrypt121.rar)
\ и 1.2.4 под Linux.

\ Многопоточность см. http://www.gnupg.org/documentation/manuals/gcrypt/Multi_002dThreading.html

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE {             lib/ext/locals.f

37 CONSTANT GCRYCTL_DISABLE_SECMEM
38 CONSTANT GCRYCTL_INITIALIZATION_FINISHED
39 CONSTANT GCRYCTL_INITIALIZATION_FINISHED_P

1 CONSTANT GCRY_MD_MD5
2 CONSTANT GCRY_MD_SHA1
8 CONSTANT GCRY_MD_SHA256

2 CONSTANT GCRY_MD_FLAG_HMAC

ALSO SO NEW: libgcrypt.dll
ALSO SO NEW: libgcrypt.so.11

: HMAC { addr u keya keyu algo \ hd mdlen p -- ha hu }
  GCRY_MD_FLAG_HMAC algo ^ hd 3 gcry_md_open THROW
  algo 1 gcry_md_get_algo_dlen -> mdlen
  keyu keya hd 3 gcry_md_setkey THROW
  u addr hd 3 gcry_md_write DROP
  0 hd 2 gcry_md_read -> p
  p mdlen HEAP-COPY mdlen
  hd 1 gcry_md_close DROP
;
: HMAC-MD5 ( addr u keya keyu  -- ha hu )
  GCRY_MD_MD5 HMAC
;
: HMAC-SHA1 ( addr u keya keyu  -- ha hu )
  GCRY_MD_SHA1 HMAC
;
: HMAC-SHA256 ( addr u keya keyu  -- ha hu )
  GCRY_MD_SHA256 HMAC
;
: MD5B ( addr u -- ha hu )
  16 ALLOCATE THROW >R
  SWAP R@ GCRY_MD_MD5 4 gcry_md_hash_buffer DROP
  R> 16
;
: SHA1B ( addr u -- ha hu )
  20 ALLOCATE THROW >R
  SWAP R@ GCRY_MD_SHA1 4 gcry_md_hash_buffer DROP
  R> 20
;
: GCryptInit ( -- flag )
  S" 1.2.1" DROP 1 gcry_check_version ?DUP
  IF ( ASCIIZ> TYPE) DROP ELSE ( ." unknown libgcrypt version") FALSE EXIT THEN
  0 GCRYCTL_DISABLE_SECMEM 2 gcry_control THROW
  0 GCRYCTL_INITIALIZATION_FINISHED 2 gcry_control THROW
  0 GCRYCTL_INITIALIZATION_FINISHED_P 2 gcry_control
;
: #_ ( ud1 -- ud2 ) \ то же, что и "#", но lowercase
  0 BASE @ UM/MOD >R BASE @ UM/MOD R>
  ROT DUP 10 < 0= IF 39 + THEN 48 + 
  HOLD
;
: B>S ( a u -- a2 u2 )
  \ Преобразовать двоичный буфер в текстовый путем простой замены
  \ каждого байта двумя hex-цифрами (так принято представлять хэши).
  \ Работает только с короткими строками (для MD5/SHA-1 достаточно),
  \ портит PAD.
  BASE @ >R HEX
  2>R 0 0 <# 2R>
  SWAP OVER + SWAP
  0 ?DO
    DUP I - 1- C@ S>D #_ #_ 2DROP
  LOOP DROP #>
  R> BASE !
;
PREVIOUS
PREVIOUS

\EOF

REQUIRE base64 ~ac/lib/string/conv.f

: TEST
  GCryptInit
  IF
    S" test" MD5B DUMP \ возвращает 16 байт 09 8F 6B CD  46 21 D3 73  CA DE 4E 83  26 27 B4 F6
                       \ в отличие от 32-байтной строки 098f6bcd4621d373cade4e832627b4f6, которую дает md5.f:MD5
                       \ т.е. строка кодируется аналогично blob'ам в sql (см. xmldb2.f:DeBlob)
    CR
    S" test" SHA1B DUMP \ аналогично
    CR
    \ тесты из RFC2202:
    S" what do ya want for nothing?" S" Jefe" HMAC-MD5 B>S TYPE CR \ 0x750c783e6ab0b503eaa86e310a5db738
    S" what do ya want for nothing?" S" Jefe" HMAC-SHA1 B>S TYPE CR \ 0xeffcdf6ae5eb2fa2d27416d5f184df9c259a7c79
    \ пример из OAuth (http://www.hueniverse.com/hueniverse/2008/10/beginners-guide.html):
    S" Type someting here to see how the hash value changes..." S" Shhhh!" HMAC-SHA1 base64 TYPE
  THEN
;
TEST

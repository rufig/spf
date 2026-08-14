\ ~ac/lib/net/crypto.f -- (CRYPTO) for the Tuya local protocol via OpenSSL libcrypto, matching the ESP32-C3
\ shim's op/cell contract (esp32c3-shim/src/main.c crypto_op) EXACTLY, so tuya.f's GCM-ENC / HMAC256 / ECB-*
\ wrappers run UNCHANGED on desktop spf64.  Bound through the SO/dlsym FFI, same pattern as dtls.f (args pushed
\ reversed + arg-count last; the SO wordlist stays in scope while these words compile, PREVIOUS at the end).  CRLF.
\ Request block CR* (9 cells), the shared (CRYPTO) contract -- fields defined with -- like ~ac/lib/net/dtls-net.f:
\   cr.key cr.keylen cr.iv cr.in cr.inlen cr.aad cr.aadlen cr.out cr.tag  ( aad 0 = none ; iv 12 B ; tag 16 B )
\ (CRYPTO) ( p op -- r ) : op 0=GCM-enc 1=GCM-dec(+verify) 2=HMAC-SHA256 3=RNG 4=ECB-enc 5=ECB-dec ; 0 ok, <0 fail.
REQUIRE { ~ac/lib/locals.f
DECIMAL

[DEFINED] WINAPI64: [IF]
   ALSO SO NEW: ext/libcrypto-3-x64.dll
[ELSE]
   ALSO SO NEW: libcrypto.so.3
[THEN]

 9 CONSTANT GCM-SET-IVLEN        \ EVP_CTRL_AEAD_SET_IVLEN
16 CONSTANT GCM-GET-TAG          \ EVP_CTRL_AEAD_GET_TAG
17 CONSTANT GCM-SET-TAG          \ EVP_CTRL_AEAD_SET_TAG
HEX FFFFFFFF CONSTANT MASK32 DECIMAL
: I32 ( n -- n )  MASK32 AND ;   \ a C int return may carry junk in the high 32 bits (as in dtls.f)
VARIABLE OL                      \ scratch int* for EVP_*Update / EVP_*Final output lengths

\ ---- request block layout: named fields instead of `n CELLS +` (Forth builds it + Forth/C read it) ----
0
CELL -- cr.key                   \ p0  key
CELL -- cr.keylen                \ p1  key length
CELL -- cr.iv                    \ p2  iv (12 B for GCM)
CELL -- cr.in                    \ p3  input
CELL -- cr.inlen                 \ p4  input length
CELL -- cr.aad                   \ p5  aad (0 = none)
CELL -- cr.aadlen                \ p6  aad length
CELL -- cr.out                   \ p7  output
CELL -- cr.tag                   \ p8  tag (16 B, GCM)
CONSTANT /CRQ

: (ECB) { p enc? \ ctx cy -- r }                        \ AES-128-ECB, no padding, block-aligned (Tuya v3.3)
   0 EVP_aes_128_ecb -> cy
   0 EVP_CIPHER_CTX_new -> ctx   ctx 0= IF -1 EXIT THEN
   enc? IF  0 p cr.key @  0 cy ctx 5 EVP_EncryptInit_ex
        ELSE 0 p cr.key @  0 cy ctx 5 EVP_DecryptInit_ex  THEN  DROP
   0 ctx 2 EVP_CIPHER_CTX_set_padding DROP
   enc? IF  p cr.inlen @  p cr.in @  OL  p cr.out @  ctx 5 EVP_EncryptUpdate
        ELSE p cr.inlen @  p cr.in @  OL  p cr.out @  ctx 5 EVP_DecryptUpdate  THEN  DROP
   ctx 1 EVP_CIPHER_CTX_free DROP  0 ;

: (GCM) { p enc? \ ctx cy -- r }                        \ AES-128-GCM, 12-byte IV, 16-byte tag (Tuya v3.4/3.5)
   0 EVP_aes_128_gcm -> cy
   0 EVP_CIPHER_CTX_new -> ctx   ctx 0= IF -1 EXIT THEN
   enc? IF  0 0  0 cy ctx 5 EVP_EncryptInit_ex  ELSE 0 0  0 cy ctx 5 EVP_DecryptInit_ex  THEN  DROP
   0 12 GCM-SET-IVLEN ctx 4 EVP_CIPHER_CTX_ctrl DROP
   enc? IF  p cr.iv @  p cr.key @  0 0 ctx 5 EVP_EncryptInit_ex  ELSE p cr.iv @  p cr.key @  0 0 ctx 5 EVP_DecryptInit_ex  THEN  DROP
   p cr.aadlen @ IF                                     \ AAD (authenticated but not encrypted)
      enc? IF  p cr.aadlen @  p cr.aad @  OL  0 ctx 5 EVP_EncryptUpdate
           ELSE p cr.aadlen @  p cr.aad @  OL  0 ctx 5 EVP_DecryptUpdate  THEN  DROP
   THEN
   enc? IF
      p cr.inlen @  p cr.in @  OL  p cr.out @  ctx 5 EVP_EncryptUpdate DROP
      OL  p cr.out @  ctx 3 EVP_EncryptFinal_ex DROP
      p cr.tag @  16 GCM-GET-TAG ctx 4 EVP_CIPHER_CTX_ctrl DROP
      ctx 1 EVP_CIPHER_CTX_free DROP  0
   ELSE
      p cr.tag @  16 GCM-SET-TAG ctx 4 EVP_CIPHER_CTX_ctrl DROP
      p cr.inlen @  p cr.in @  OL  p cr.out @  ctx 5 EVP_DecryptUpdate DROP
      OL  p cr.out @  ctx 3 EVP_DecryptFinal_ex I32       \ >0 = tag verified
      ctx 1 EVP_CIPHER_CTX_free
      0> IF 0 ELSE -1 THEN
   THEN ;

: (HMAC) { p -- r }                                     \ HMAC(EVP_sha256, key, keylen, d, n, md)
   0  p cr.out @  p cr.inlen @  p cr.in @  p cr.keylen @  p cr.key @  0 EVP_sha256  7 HMAC  DROP  0 ;
: (RNG)  { p -- r }   p cr.inlen @  p cr.out @  2 RAND_bytes  I32 1 = IF 0 ELSE -1 THEN ;

: (CRYPTO) ( p op -- r )
   DUP 2 = IF DROP (HMAC)       EXIT THEN
   DUP 3 = IF DROP (RNG)        EXIT THEN
   DUP 4 = IF DROP TRUE  (ECB)  EXIT THEN
   DUP 5 = IF DROP FALSE (ECB)  EXIT THEN
   DUP 0 = IF DROP TRUE  (GCM)  EXIT THEN
   DROP FALSE (GCM) ;                                   \ op 1 = GCM decrypt + verify

PREVIOUS                                                \ drop the SO (libcrypto) wordlist from the search order

\EOF
\ ---- (CRYPTO) known-answer self-test.  Past \EOF (not run on a normal load); to run it:  : \EOF ;  then
\ INCLUDE this file.  Vectors: FIPS-197 C.1 (ECB), NIST GCM TC2 (GCM enc/dec), RFC 4231 TC2 (HMAC-SHA256).
DECIMAL
CREATE KATQ /CRQ ALLOT   CREATE KOUT 64 ALLOT   CREATE KTAG 16 ALLOT
CREATE KKEY 16 ALLOT   CREATE KPT 16 ALLOT   CREATE KZ 16 ALLOT   CREATE KIV 12 ALLOT
: KCLR   KATQ /CRQ 0 FILL ;
: KHX. ( a u -- )  BASE @ >R HEX 0 ?DO DUP I + C@ 0 <# # # #> TYPE LOOP DROP R> BASE ! ;
: KVEC  16 0 DO I KKEY I + C! LOOP  16 0 DO I 17 * KPT I + C! LOOP  KZ 16 0 FILL  KIV 12 0 FILL ;
: T-ECB  KCLR  KKEY KATQ cr.key !  KPT KATQ cr.in !  16 KATQ cr.inlen !  KOUT KATQ cr.out !  KATQ 4 (CRYPTO) DROP
   ." ECB    " KOUT 16 KHX. ."    want 69C4E0D86A7B0430D8CDB78070B4C55A" CR ;
: T-GCM  KCLR  KZ KATQ cr.key !  16 KATQ cr.keylen !  KIV KATQ cr.iv !  KZ KATQ cr.in !  16 KATQ cr.inlen !
   0 KATQ cr.aad !  0 KATQ cr.aadlen !  KOUT KATQ cr.out !  KTAG KATQ cr.tag !  KATQ 0 (CRYPTO) DROP
   ." GCM ct " KOUT 16 KHX. ."    want 0388DACE60B6A392F328C2B971B2FE78" CR
   ." GCM tag" KTAG 16 KHX. ."    want AB6E47D42CEC13BDF53A67B21257BDDF" CR ;
: T-DEC  KCLR  KZ KATQ cr.key !  16 KATQ cr.keylen !  KIV KATQ cr.iv !  KOUT KATQ cr.in !  16 KATQ cr.inlen !
   0 KATQ cr.aad !  0 KATQ cr.aadlen !  KPT KATQ cr.out !  KTAG KATQ cr.tag !  KATQ 1 (CRYPTO)
   ." GCM dec r=" DUP .  ."  (0 ok)  pt=" KPT 16 KHX. ."  (want 16x 00)" CR  DROP ;
: T-HMAC  KCLR  S" Jefe" KATQ cr.keylen ! KATQ cr.key !
   S" what do ya want for nothing?" KATQ cr.inlen ! KATQ cr.in !  KOUT KATQ cr.out !  KATQ 2 (CRYPTO) DROP
   ." HMAC   " KOUT 32 KHX. CR
   ." want   5BDCC146BF60754E6A042426089575C75A003F089D2739839DEC58B964EC3843" CR ;
KVEC  CR ." === crypto.f (CRYPTO) known-answer test ===" CR  T-ECB  T-GCM  T-DEC  T-HMAC  CR

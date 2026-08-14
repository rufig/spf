\ ~ac/lib/net/tuya-core.f -- PORTABLE core of the Tuya local protocol (v3.3 / v3.4 / v3.5), a faithful
\ port of tinytuya.  Identical protocol logic on the ESP32-C3 (32-bit, mbedtls, lwIP) and on desktop
\ spf64 (64-bit, OpenSSL, winsock/POSIX) -- the two differ ONLY in the state layer and the socket layer,
\ which the PLATFORM file defines before INCLUDEing this one.  KEYS ARE SECRETS -- kept in a gitignored
\ config, never here (this file is generic: keys are passed by ADDRESS).
\
\ The platform file MUST have already defined, before INCLUDE:
\   state buffers  : TXB RXB PTB JBUF HMB RNONCE SKEY XORB   ( each -> byte region )
\                    CRQ ( -> /CRQ request block for the (CRYPTO) call )
\   state cells    : TSEQ TSOCK DKEY DIP CRCV PADN JP  P-PL P-PLEN P-CMD P-KEY  U-FR U-KEY U-LEN
\                    IDA IDU TSA TSU   ( each -> one-cell variable )
\   crypto         : (CRYPTO) ( p op -- r ) + the request-block fields cr.key cr.keylen cr.iv cr.in
\                    cr.inlen cr.aad cr.aadlen cr.out cr.tag   (defined by crypto.f on desktop)
\   sockets        : TUYA-OPEN ( -- ok )  TSEND ( a u -- )  TRECV ( -- rlen )  TCLOSE ( -- )
\ CRLF.
DECIMAL
HEX CREATE LNONCE 30 C, 31 C, 32 C, 33 C, 34 C, 35 C, 36 C, 37 C, 38 C, 39 C, 61 C, 62 C, 63 C, 64 C, 65 C, 66 C, DECIMAL
HEX 6699 CONSTANT PFX66   9966 CONSTANT SFX66   DECIMAL   \ 0x00006699 / 0x00009966

\ ---- wire-frame field offsets (named with --, like ~ac/lib/net/dtls-net.f, instead of numeric literals) ----
0                          \ 6699 frame (v3.5): prefix, 0000, seq, cmd, len, iv(12), ciphertext, tag(16), suffix
4  -- f66.prefix
2  -- f66.unk              \ 0000 ; the GCM AAD is the header from f66.unk up to f66.iv (F66-AAD bytes)
4  -- f66.seq
4  -- f66.cmd
4  -- f66.len              \ = plen + iv(12) + tag(16)
12 -- f66.iv
0  -- f66.ct               \ ciphertext (plen) ; tag(16) and suffix(4) follow
CONSTANT /F66HDR
14 CONSTANT F66-AAD
0                          \ 55AA frame (v3.1-3.4): prefix, seq, cmd, len, body
4 -- f55.prefix
4 -- f55.seq
4 -- f55.cmd
4 -- f55.len
0 -- f55.pl                \ body @ +16 : request = ECB payload ; response = retcode(/RETCODE) then ciphertext
CONSTANT /F55HDR
4 CONSTANT /RETCODE

\ ---- big-endian 32-bit ----
: BE! ( x a -- ) >R  DUP 24 RSHIFT R@ C!  DUP 16 RSHIFT R@ 1+ C!  DUP 8 RSHIFT R@ 2 + C!  R> 3 + C! ;
: BE@ ( a -- x ) DUP C@ 24 LSHIFT  OVER 1+ C@ 16 LSHIFT OR  OVER 2 + C@ 8 LSHIFT OR  SWAP 3 + C@ OR ;

\ ---- (CRYPTO) convenience over the request block (fields cr.* from crypto.f) ----
: GCM-ENC ( key iv in inlen aad aadlen out tag -- r )
   CRQ cr.tag !  CRQ cr.out !  CRQ cr.aadlen !  CRQ cr.aad !  CRQ cr.inlen !
   CRQ cr.in !  CRQ cr.iv !  16 CRQ cr.keylen !  CRQ cr.key !  CRQ 0 (CRYPTO) ;
: GCM-DEC ( key iv in inlen aad aadlen out tag -- r )
   CRQ cr.tag !  CRQ cr.out !  CRQ cr.aadlen !  CRQ cr.aad !  CRQ cr.inlen !
   CRQ cr.in !  CRQ cr.iv !  16 CRQ cr.keylen !  CRQ cr.key !  CRQ 1 (CRYPTO) ;
: HMAC256 ( key keylen in inlen out -- r )
   0 CRQ cr.tag !  CRQ cr.out !  0 CRQ cr.aadlen !  0 CRQ cr.aad !  CRQ cr.inlen !
   CRQ cr.in !  0 CRQ cr.iv !  CRQ cr.keylen !  CRQ cr.key !  CRQ 2 (CRYPTO) ;
: RAND-BYTES ( out n -- r ) CRQ cr.inlen !  CRQ cr.out !  CRQ 3 (CRYPTO) ;

\ ---- 6699 frame pack ( payload plen cmd key -- frame flen ) ----
: PACK66 ( payload plen cmd key -- frame flen )
   P-KEY ! P-CMD ! P-PLEN ! P-PL !
   PFX66 TXB f66.prefix BE!                              \ prefix 00006699
   0 TXB f66.unk C!  0 TXB f66.unk 1+ C!                  \ unknown 0000
   TSEQ @ TXB f66.seq BE!  P-CMD @ TXB f66.cmd BE!        \ seqno, cmd
   P-PLEN @ 28 + TXB f66.len BE!                          \ length = plen + iv(12) + tag(16)
   TXB f66.iv 12 RAND-BYTES DROP                          \ random 12-byte GCM iv
   P-KEY @  TXB f66.iv  P-PL @  P-PLEN @  TXB f66.unk  F66-AAD  TXB f66.ct  TXB f66.ct P-PLEN @ +  GCM-ENC DROP
   SFX66  TXB f66.ct P-PLEN @ + 16 +  BE!                 \ suffix 00009966 after ct+tag(16)
   TXB  P-PLEN @ 50 +  1 TSEQ +! ;                        \ flen = hdr30 + plen + tag16 + suffix4

\ ---- 6699 frame unpack ( frame key -- pt ptlen ok ) ; pt = PTB ----
: UNPACK66 ( frame key -- pt ptlen ok )
   U-KEY ! U-FR !
   U-FR @ f66.prefix BE@ PFX66 = 0= IF 0 0 0 EXIT THEN
   U-FR @ f66.len BE@ U-LEN !
   U-KEY @  U-FR @ f66.iv  U-FR @ f66.ct  U-LEN @ 28 -  U-FR @ f66.unk  F66-AAD  PTB  U-FR @ f66.iv U-LEN @ + 16 -  GCM-DEC
   0= IF PTB  U-LEN @ 28 -  -1  ELSE 0 0 0 THEN ;

\ ---- session-key negotiation (v3.4/3.5) ----
: NEG ( -- ok )
   1 TSEQ !
   LNONCE 16 3 DKEY @ PACK66 TSEND  TRECV DROP           \ NEG_START -> NEG_RESP
   RXB DKEY @ UNPACK66 0= IF 2DROP 0 EXIT THEN  ( pt ptlen )
   DROP 4 +                                              ( base=pt+4 -- rnonce16 then hmac32 )
   DUP RNONCE 16 CMOVE                                   \ RNONCE = device nonce
   DKEY @ 16 LNONCE 16 HMB HMAC256 DROP                  \ expected = HMAC(key, local_nonce)
   HMB 32  ROT 16 +  32  COMPARE  IF 0 EXIT THEN         \ verify device proof (base[16:48]); !=0 -> fail
   DKEY @ 16 RNONCE 16 HMB HMAC256 DROP                  \ FINISH payload = HMAC(key, remote_nonce)
   2 TSEQ !  HMB 32 5 DKEY @ PACK66 TSEND                \ NEG_FINISH (no reply awaited)
   16 0 DO LNONCE I + C@  RNONCE I + C@  XOR  XORB I + C! LOOP   \ local xor remote
   DKEY @  LNONCE  XORB 16  0 0  SKEY  HMB  GCM-ENC DROP \ session key = GCM_ct(key, local_nonce[:12], XOR)
   -1 ;

\ ---- DP_QUERY + status ----
: FIND{ ( a u -- a2 u2 )  BEGIN DUP WHILE OVER C@ [CHAR] { = IF EXIT THEN 1 /STRING REPEAT ;
: DPQ ( -- pt ptlen ok )  3 TSEQ !  S" {}" 16 SKEY PACK66 TSEND  TRECV DROP  RXB SKEY UNPACK66 ;
: TUYA-STATUS ( ip key-addr -- )    \ poll one v3.5 device; prints its {"dps":...}
   DKEY !  DIP !
   TUYA-OPEN 0= IF ." tuya: connect fail" CR EXIT THEN
   NEG 0= IF ." tuya: negotiate fail" CR TCLOSE EXIT THEN
   DPQ 0= IF ." tuya: query fail" CR 2DROP TCLOSE EXIT THEN
   FIND{ TYPE CR  TCLOSE ;

\ ---- v3.3 (55AA framing, AES-128-ECB, no session negotiation).  TUYA33-STATUS ( ip id-a id-u key-a -- ) ----
HEX 55AA CONSTANT PFX55   AA55 CONSTANT SFX55   EDB88320 CONSTANT CRCPOLY   DECIMAL
[UNDEFINED] MASK32 [IF] HEX FFFFFFFF CONSTANT MASK32 DECIMAL [THEN]   \ CRC is a 32-bit register (on the C3 -1 already is)
: CRC-BYTE ( b -- )  CRCV @ XOR  8 0 DO  DUP 1 AND IF 1 RSHIFT CRCPOLY XOR ELSE 1 RSHIFT THEN LOOP  CRCV ! ;
: CRC32 ( a u -- crc )  MASK32 CRCV !  0 ?DO DUP I + C@ CRC-BYTE LOOP DROP  CRCV @ MASK32 XOR ;
: ECB-ENC ( key in inlen out -- r )  CRQ cr.out !  CRQ cr.inlen !  CRQ cr.in !  CRQ cr.key !  CRQ 4 (CRYPTO) ;
: ECB-DEC ( key in inlen out -- r )  CRQ cr.out !  CRQ cr.inlen !  CRQ cr.in !  CRQ cr.key !  CRQ 5 (CRYPTO) ;
: PKCS7 ( a u -- a u2 )  16 OVER 16 MOD -  PADN !  2DUP +  PADN @ 0 ?DO PADN @ OVER I + C! LOOP DROP  PADN @ + ;
34 CONSTANT Q
: J+ ( a u -- )  JP @ SWAP DUP >R CMOVE  R> JP +! ;
: JQ ( -- )  Q JP @ C!  1 JP +! ;
: JSON-DPQ ( id-a id-u ts-a ts-u -- ja ju )    \ {"gwId":"<id>","devId":"<id>","uid":"<id>","t":"<ts>"}
   TSU ! TSA ! IDU ! IDA !  JBUF JP !
   S" {" J+  JQ S" gwId" J+ JQ  S" :" J+  JQ IDA @ IDU @ J+ JQ  S" ," J+
   JQ S" devId" J+ JQ  S" :" J+  JQ IDA @ IDU @ J+ JQ  S" ," J+
   JQ S" uid" J+ JQ  S" :" J+  JQ IDA @ IDU @ J+ JQ  S" ," J+
   JQ S" t" J+ JQ  S" :" J+  JQ TSA @ TSU @ J+ JQ
   S" }" J+  JBUF  JP @ JBUF - ;
: PACK55 ( plen cmd -- frame flen )            \ ECB payload already at TXB f55.pl (plen bytes)
   PFX55 TXB f55.prefix BE!  TSEQ @ TXB f55.seq BE!  TXB f55.cmd BE!
   DUP 8 + TXB f55.len BE!  /F55HDR +           \ length = plen+8 ; hp = 16+plen
   DUP TXB SWAP CRC32  OVER TXB + BE!  SFX55 OVER TXB + 4 + BE!
   TXB SWAP 8 +  1 TSEQ +! ;
: TUYA33-STATUS ( ip id-a id-u key-a -- )
   DKEY !  ROT DIP !                            ( id-a id-u )
   S" 1700000000" JSON-DPQ  PKCS7               ( pa pu )
   DUP >R  DKEY @ -ROT  TXB f55.pl  ECB-ENC DROP  R>  ( plen )
   10 PACK55                                    ( frame flen : cmd 0x0a = DP_QUERY )
   TUYA-OPEN 0= IF 2DROP ." tuya33: connect fail" CR EXIT THEN
   TSEND  TRECV 28 < IF ." tuya33: short reply" CR TCLOSE EXIT THEN
   RXB f55.pl BE@ ?DUP IF ." tuya33: device error " . CR TCLOSE EXIT THEN   \ retcode != 0 -> wrong key
   RXB f55.len BE@  12 -                         ( ctlen = length minus retcode4 crc4 suffix4 )
   DUP 0 > OVER 353 < AND 0= IF ." tuya33: bad length" CR DROP TCLOSE EXIT THEN   \ bound ctlen to PTB
   DKEY @  RXB f55.pl /RETCODE +  2 PICK  PTB  ECB-DEC DROP  ( ctlen )
   DUP PTB + 1- C@  OVER MIN  -                 ( reallen : strip PKCS7 ; pad clamped <= ctlen )
   PTB SWAP  FIND{  TYPE CR  TCLOSE ;

\ ---- v3.4 (55AA framing + HMAC-SHA256 trailer + ECB session negotiation).  TUYA34-STATUS ( ip key-addr -- ) ----
\ Session key = ECB(device_key, local_nonce XOR remote_nonce) (the ECB analogue of the v3.5 GCM NEG/DPQ above);
\ DP_QUERY (cmd 0x0a) then rides that session key (no protocol header -- tinytuya NO_PROTOCOL_HEADER_CMDS).
: PACK34 ( pa plen cmd key -- frame flen )   \ 55AA + ECB(key,PKCS7(pl)) + HMAC(key,hdr+enc) + suffix ; PTB scratch
   P-KEY ! P-CMD ! P-PLEN ! P-PL !
   P-PL @  PTB  P-PLEN @  CMOVE
   PTB  P-PLEN @  PKCS7  NIP  P-PLEN !
   P-KEY @  PTB  P-PLEN @  TXB f55.pl  ECB-ENC DROP
   PFX55 TXB f55.prefix BE!  TSEQ @ TXB f55.seq BE!  P-CMD @ TXB f55.cmd BE!
   P-PLEN @ 36 + TXB f55.len BE!
   P-KEY @  16  TXB  P-PLEN @ /F55HDR +  TXB f55.pl P-PLEN @ +  HMAC256 DROP
   TXB f55.pl P-PLEN @ + 32 +  SFX55 SWAP  BE!
   TXB  P-PLEN @ 52 +  1 TSEQ +! ;
: UNPACK34 ( frame key -- pt ctlen ok )
   U-KEY ! U-FR !
   U-FR @ f55.prefix BE@ PFX55 = 0= IF 0 0 0 EXIT THEN
   U-FR @ f55.len BE@  40 -
   DUP 0 > OVER 353 < AND 0= IF DROP 0 0 0 EXIT THEN
   U-KEY @  U-FR @ f55.pl /RETCODE +  2 PICK  PTB  ECB-DEC DROP
   PTB SWAP -1 ;
: NEG34 ( -- ok )   \ negotiate a v3.4 session ; derive SKEY from DKEY
   1 TSEQ !
   LNONCE 16 3 DKEY @ PACK34 TSEND  TRECV DROP
   RXB DKEY @ UNPACK34 0= IF 2DROP 0 EXIT THEN  2DROP    \ NEG_RESP decrypted into PTB
   PTB RNONCE 16 CMOVE                                   \ RNONCE = PTB[0:16]
   DKEY @ 16 LNONCE 16 HMB HMAC256 DROP                  \ expected = HMAC(key, local_nonce)
   HMB 32  PTB 16 +  32  COMPARE IF 0 EXIT THEN          \ verify PTB[16:48]
   DKEY @ 16 RNONCE 16 HMB HMAC256 DROP                  \ FINISH payload = HMAC(key, remote_nonce)
   2 TSEQ !  HMB 32 5 DKEY @ PACK34 TSEND                \ NEG_FINISH (cmd 5)
   16 0 DO LNONCE I + C@  RNONCE I + C@  XOR  XORB I + C! LOOP
   DKEY @  XORB 16  SKEY  ECB-ENC DROP                   \ SKEY = ECB(key, local_nonce XOR remote_nonce)
   -1 ;
: DPQ34 ( cmd -- pt ctlen ok )  3 TSEQ !  S" {}" ROT SKEY PACK34 TSEND  TRECV DROP  RXB SKEY UNPACK34 ;
: TUYA34-STATUS ( ip key-addr -- )
   DKEY !  DIP !
   TUYA-OPEN 0= IF ." tuya34: connect fail" CR EXIT THEN
   NEG34 0= IF ." tuya34: negotiate fail" CR TCLOSE EXIT THEN
   10 DPQ34 0= IF ." tuya34: query fail" CR 2DROP TCLOSE EXIT THEN
   DUP PTB + 1- C@  OVER MIN  -  FIND{  TYPE CR  TCLOSE ;

\ Поддержка OpenID 1.1

REQUIRE X509Pk2PEM ~ac/lib/lin/openssl/x509req.f
REQUIRE base64     ~ac/lib/string/conv.f
REQUIRE POST-FILE  ~ac/lib/lin/curl/curlpost.f 

ALSO libeay32.dll
ALSO libssl.so.0.9.8

: default_p S" defp" FILE ;
: default_g S" 2" ;

0
4 -- DH.pad
4 -- DH.version
4 -- DH.p
4 -- DH.g
4 -- DH.length \ optional
4 -- DH.pub_key \ g^x
4 -- DH.priv_key \ x
DROP

USER assoc_handle
USER assoc_type
USER dh_server_public
USER enc_mac_key
USER expires_in
USER session_type

: (assoc_reply)
  [CHAR] : PARSE SFIND IF EXECUTE ELSE TYPE ." unknown reply" EXIT THEN
  10 PARSE ROT S!
;
: assoc_reply
  BEGIN
    10 PARSE 2DUP ." [" TYPE ." ]" CR
    DUP
  WHILE
    ['] (assoc_reply) EVALUATE-WITH
  REPEAT 2DROP
;
: OpenIdGetSharedKey { urla urlu \ p g dh pk pklen spub ck cklen key_sha1 mac_key -- ka ku }
  0 DH_new -> dh
  enc_mac_key 0!
\  dh DH.pub_key @ .
  default_p DROP ^ p 2 BN_dec2bn DROP
  default_g DROP ^ g 2 BN_dec2bn DROP

  p dh DH.p !
  g dh DH.g !
  dh 1 DH_generate_key 1 <> THROW
\  dh DH.pub_key @ @ 10 DUMP CR
\  dh DH.priv_key @ @ 10 DUMP CR
  dh DH.pub_key @ 1 BN_num_bits 7 + 8 / ALLOCATE THROW -> pk
  pk dh DH.pub_key @ 2 BN_bn2bin -> pklen
  pk pklen base64 \ 2DUP TYPE CR
  " openid.mode=associate&openid.assoc_type=HMAC-SHA1&openid.session_type=DH-SHA1&openid.dh_consumer_public={s}" STR@
  S" " urla urlu POST-FILE STR@ \ 2DUP TYPE ." <==" CR
  ['] assoc_reply EVALUATE-WITH
  enc_mac_key @
  IF \ enc_mac_key @ STR@
     dh_server_public @ STR@ debase64 SWAP
     0 ROT ROT 3 BN_bin2bn -> spub
     dh 1 DH_size ALLOCATE THROW -> ck
     dh spub ck 3 DH_compute_key -> cklen  cklen 1 < THROW
     20 ALLOCATE THROW -> key_sha1
     key_sha1 cklen ck 3 SHA1 DROP \ тот же key_sha1
     enc_mac_key @ STR@ debase64 20 <> THROW -> mac_key
\     mac_key 20 DUMP CR
     20 0 DO mac_key I + C@ key_sha1 I + C@ XOR mac_key I + C! LOOP
     mac_key 20 \ DUMP CR
  ELSE S" " THEN
;
PREVIOUS
PREVIOUS

\ S" http://www.livejournal.com/openid/server.bml" OpenIdGetSharedKey DUMP CR
\ S" http://authn.freexri.com/authentication/" OpenIdGetSharedKey DUMP CR
\ S" http://www.blogger.com/openid-server.g" OpenIdGetSharedKey DUMP CR
\ S" https://open.login.yahooapis.com/openid/op/1.1/auth" OpenIdGetSharedKey DUMP CR
\ S" http://api.screenname.aol.com/auth/openidServer" OpenIdGetSharedKey DUMP CR

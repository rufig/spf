\ ~ac/lib/net/dtls.f -- DTLS (TLS over UDP) via OpenSSL, for authenticated swarm connections.
\ Discovery (DHT) yields UNTRUSTED ip:port; this layer does the actual trust: a DTLS handshake with
\ MUTUAL certificate verification against the swarm CA.  For IH-GROUP the peer's cert must chain to the
\ CA; for IH-SELF it must additionally hash (SHA1(SPKI)) to the expected value from the registry.
\ Binds OpenSSL 3.x through the SO/dlsym FFI, same pattern as acWEB64 src/acTCP/tls.f (args pushed in
\ reverse, arg-count last).  This file: OpenSSL init; DTLS context construction (cert/key/CA + a verify
\ hook); the memory-BIO handshake pump; and network-facing wrappers (incl. the verify-callback helpers)
\ so the multiplex layer (dtls-net.f) never has to touch the SO namespace itself.  CRLF.
REQUIRE { ~ac/lib/locals.f
DECIMAL

1 CONSTANT SSL_FILETYPE_PEM
1 CONSTANT SSL_VERIFY_PEER
2 CONSTANT SSL_VERIFY_FAIL_IF_NO_PEER_CERT
3 CONSTANT VERIFY_MUTUAL                     \ PEER | FAIL_IF_NO_PEER_CERT

\ ---- load OpenSSL (libcrypto must load before libssl; OpenSSL_version forces it) ----
NS-ON
[DEFINED] WINAPI64: [IF]
   ALSO SO NEW: ext/libcrypto-3-x64.dll
   : CRYPTO-PRELOAD ( -- )  0 1 OpenSSL_version DROP ;
   ALSO SO NEW: ext/libssl-3-x64.dll
[ELSE]
   ALSO SO NEW: libcrypto.so.3
   : CRYPTO-PRELOAD ( -- )  0 1 OpenSSL_version DROP ;
   ALSO SO NEW: libssl.so.3
[THEN]
\ NB: SO stays in the search order (as in tls.f) so the OpenSSL symbols below resolve as lib exports.

VARIABLE DTLS-INITED
: DTLS-INIT ( -- )
   DTLS-INITED @ IF EXIT THEN
   CRYPTO-PRELOAD  0 0 2 OPENSSL_init_ssl 1 <> IF -3200 THROW THEN
   TRUE DTLS-INITED ! ;

\ Verify-callback trampoline (0 = none).  Set to SWARM-VERIFY-CB below, once it (and the SO wrappers
\ it needs) are defined -- DTLS-CTX reads this VALUE, so no forward reference.
0 VALUE DTLS-VERIFY-CB
0 VALUE DTLS-COOKIE-GEN     \ filled in below, once SSL>BASE exists (same late-binding as the verify cb)
0 VALUE DTLS-COOKIE-VER

\ ---- context construction: load our identity cert+key, trust the CA, require peer certs ----
\ cert-c / key-c / ca-c are NUL-terminated C strings (spf4 S" ... DROP gives one).
\ Calls follow the tls.f style: reversed args + arg-count, e.g. `TYPE file ctx 3 SSL_CTX_use_...`.
\ ---- explicit DTLS policy, modelled on what browsers negotiate for WebRTC (RFC 8827) ----
\ Without this we inherit whatever the local OpenSSL defaults to, and the fleet spans 3.0.13 to 3.6.3 --
\ i.e. the policy would differ per node and drift silently on the next distribution upgrade.
\ RFC 8827: DTLS 1.2 is the floor, ECDHE only (forward secrecy -- no static RSA/DH), and
\ TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 must be supported.  Everything here is AEAD; the CBC suites
\ browsers still carry for legacy peers are left out, since every peer that matters is our own fleet.
\ AES-GCM first (hardware AES), ChaCha20 after it for machines without AES-NI -- the browser ordering.
123 CONSTANT SSL_CTRL_SET_MIN_PROTO_VERSION
 92 CONSTANT SSL_CTRL_SET_GROUPS_LIST
HEX FEFD CONSTANT DTLS1_2_VERSION DECIMAL
: DTLS-POLICY { ctx -- }
   0 DTLS1_2_VERSION SSL_CTRL_SET_MIN_PROTO_VERSION ctx 4 SSL_CTX_ctrl  1 <> IF -3215 THROW THEN
   S" ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305" DROP
   ctx 2 SSL_CTX_set_cipher_list                                        1 <> IF -3216 THROW THEN
   S" X25519:P-256:P-384" DROP  0 SSL_CTRL_SET_GROUPS_LIST ctx 4 SSL_CTX_ctrl  1 <> IF -3217 THROW THEN ;

: DTLS-CTX { srv? cert-c key-c ca-c \ ctx -- ctx }
   DTLS-INIT
   srv? IF 0 DTLS_server_method ELSE 0 DTLS_client_method THEN
   1 SSL_CTX_new  DUP 0= IF -3210 THROW THEN  -> ctx
   ctx DTLS-POLICY
   \ chain_file, not certificate_file: identical for our single self-signed-CA-issued leaf, but if the
   \ fleet ever moves to an offline root + intermediate, dropping the intermediate into the same .crt
   \ just works.  With the plain loader it would silently not be sent, and peers would fail with
   \ "unable to get local issuer certificate" while the files all look present and correct.
   cert-c ctx 2 SSL_CTX_use_certificate_chain_file             1 <> IF -3211 THROW THEN
   SSL_FILETYPE_PEM key-c  ctx 3 SSL_CTX_use_PrivateKey_file   1 <> IF -3212 THROW THEN
   ctx 1 SSL_CTX_check_private_key                             1 <> IF -3213 THROW THEN
   0 ca-c ctx 3 SSL_CTX_load_verify_locations                 1 <> IF -3214 THROW THEN
   DTLS-VERIFY-CB VERIFY_MUTUAL ctx 3 SSL_CTX_set_verify DROP  \ verdict unchanged; cb only logs
   srv? DTLS-COOKIE-GEN 0<> AND IF                             \ P0.5: cookie exchange, server side only
      DTLS-COOKIE-GEN ctx 2 SSL_CTX_set_cookie_generate_cb DROP
      DTLS-COOKIE-VER ctx 2 SSL_CTX_set_cookie_verify_cb   DROP
   THEN
   ctx ;
: DTLS-SERVER-CTX ( cert-c key-c ca-c -- ctx )  >R >R >R TRUE  R> R> R> DTLS-CTX ;
: DTLS-CLIENT-CTX ( cert-c key-c ca-c -- ctx )  >R >R >R FALSE R> R> R> DTLS-CTX ;

\ ===== handshake over memory BIOs (single socket / loopback) ================================
2 CONSTANT SSL_ERROR_WANT_READ    3 CONSTANT SSL_ERROR_WANT_WRITE
1 CONSTANT SSL_ERROR_SSL          5 CONSTANT SSL_ERROR_SYSCALL
0 CONSTANT X509_V_OK
130 CONSTANT BIO_C_SET_BUF_MEM_EOF_RETURN     \ BIO_set_mem_eof_return
120 CONSTANT DTLS_CTRL_SET_LINK_MTU
HEX 1000 CONSTANT SSL_OP_NO_QUERY_MTU   FFFFFFFF CONSTANT MASK32  DECIMAL
1400 VALUE DTLS-MTU
2048 CONSTANT /DTLS-BUF   CREATE DTLS-BUF /DTLS-BUF ALLOT
4096 CONSTANT /PEER-DER   CREATE PEER-DER /PEER-DER ALLOT   VARIABLE PEER-DER-PTR

: I32 ( n -- n )  MASK32 AND ;

\ ===== why a STREAM memory BIO and not a datagram one (P1.10) ================================
\ DTLS wants datagram semantics, and OpenSSL grew BIOs that provide them -- BIO_s_dgram_mem and
\ BIO_s_dgram_pair.  We deliberately do NOT use them: both appeared in OpenSSL 3.2, and the fleet's
\ Linux nodes run 3.0.13 (checked with nm on their libcrypto.so.3 -- the symbols are absent; Windows
\ has 3.6.3).  Calling them would make the node fail to load on exactly the machines that run
\ unattended.  Selecting the BIO per platform is worse than either choice: it splits the code that
\ frames the handshake into two paths, each exercised on only half the fleet.
\ So datagram semantics are supplied by hand, and the three pieces that matter are all here:
\   * record framing on the way out -- PR-PUMP-OUT in dtls-net.f sends each DTLS record as its own
\     datagram and carries an unfinished record across reads (P1.9);
\   * the MTU is set explicitly instead of being queried from a BIO that has none (SSL_OP_NO_QUERY_MTU
\     + DTLS_CTRL_SET_LINK_MTU below), so OpenSSL fragments handshake messages itself;
\   * an empty read returns "retry" rather than EOF (BIO_C_SET_BUF_MEM_EOF_RETURN -1), without which
\     an idle association would look like a closed one.
\ REVISIT when the minimum supported OpenSSL across all five targets reaches 3.2: switching to
\ BIO_s_dgram_mem then lets PR-PUMP-OUT lose its framing loop entirely.
: DTLS-WRAP { ctx server? \ ssl rbio wbio -- ssl rbio wbio }   \ SSL + a mem-BIO pair for pumping
   ctx 1 SSL_new DUP 0= IF -3220 THROW THEN -> ssl
   TlsIndex@ 0 ssl 3 SSL_set_ex_data DROP     \ stash our USER base so the verify-cb can restore it
   0 BIO_s_mem 1 BIO_new DUP 0= IF -3221 THROW THEN -> rbio
   0 BIO_s_mem 1 BIO_new DUP 0= IF -3221 THROW THEN -> wbio
   0 -1 BIO_C_SET_BUF_MEM_EOF_RETURN rbio 4 BIO_ctrl DROP    \ empty read -> retry, not EOF
   0 -1 BIO_C_SET_BUF_MEM_EOF_RETURN wbio 4 BIO_ctrl DROP
   wbio rbio ssl 3 SSL_set_bio                               \ SSL owns both BIOs now
   SSL_OP_NO_QUERY_MTU ssl 2 SSL_set_options DROP            \ don't query the mem BIO for MTU
   0 DTLS-MTU DTLS_CTRL_SET_LINK_MTU ssl 4 SSL_ctrl DROP
   server? IF ssl 1 SSL_set_accept_state ELSE ssl 1 SSL_set_connect_state THEN
   ssl rbio wbio ;

: DRAIN { from to \ n -- }                                  \ move all pending bytes from `from` to `to`
   BEGIN from 1 BIO_ctrl_pending 0> WHILE
      /DTLS-BUF DTLS-BUF from 3 BIO_read I32 -> n
      n 0> 0= IF EXIT THEN
      n DTLS-BUF to 3 BIO_write DROP
   REPEAT ;

: DTLS-HANDSHAKE { c-ssl c-w s-r  s-ssl s-w c-r \ cnt -- ok? }  \ pump client<->server to completion
   0 -> cnt
   BEGIN cnt 60 < WHILE
      c-ssl 1 SSL_do_handshake I32
      c-w s-r DRAIN
      s-ssl 1 SSL_do_handshake I32
      s-w c-r DRAIN
      1 =  SWAP 1 = AND IF TRUE EXIT THEN                    \ both handshakes returned 1
      cnt 1+ -> cnt
   REPEAT FALSE ;

: DTLS-VERIFIED? ( ssl -- f )  1 SSL_get_verify_result  X509_V_OK = ;   \ chain-to-CA ok?
: DTLS-SUITE { ssl \ c -- va vu ca cu }    \ what was actually negotiated -- so the policy above can be
   ssl 1 SSL_get_version ASCIIZ>           \ checked against reality instead of assumed to have applied
   ssl 1 SSL_get_current_cipher -> c
   c 0= IF S" (none)" ELSE c 1 SSL_CIPHER_get_name ASCIIZ> THEN ;

: DTLS-PEER-DER { ssl \ x509 len -- a u }                   \ peer cert as DER (into PEER-DER); 0 0 if none
   ssl 1 SSL_get1_peer_certificate DUP 0= IF DROP 0 0 EXIT THEN -> x509
   0 x509 2 i2d_X509 I32 -> len
   len /PEER-DER > IF x509 1 X509_free 0 0 EXIT THEN
   PEER-DER PEER-DER-PTR !
   PEER-DER-PTR x509 2 i2d_X509 DROP
   x509 1 X509_free
   PEER-DER len ;

\ ---- network-oriented wrappers (so the multiplex layer never touches the SO namespace itself) ----
: DTLS-WRAP1 ( ctx server? -- ssl rbio wbio )  DTLS-WRAP ;   \ re-export under a stable name
: DTLS-HS1     ( ssl -- ret )        1 SSL_do_handshake I32 ;      \ one handshake step
: DTLS-READ    { ssl a u -- n }      u a ssl 3 SSL_read  I32 ;     \ app data in
: DTLS-WRITE   { ssl a u -- n }      u a ssl 3 SSL_write I32 ;     \ app data out
74 CONSTANT DTLS_CTRL_HANDLE_TIMEOUT             \ DTLSv1_handle_timeout is a macro -> SSL_ctrl
: DTLS-TIMEOUT { ssl -- r }  0 0 DTLS_CTRL_HANDLE_TIMEOUT ssl 4 SSL_ctrl I32 ;  \ retransmit if due (no-op if none)
: DTLS-ERR     ( ssl ret -- err )    SWAP 2 SSL_get_error I32 ;
: BIO-PENDING  ( bio -- n )          1 BIO_ctrl_pending ;
: WBIO-READ    { bio a u -- n }      u a bio 3 BIO_read  I32 ;     \ pull ready output bytes to send
: RBIO-WRITE   { bio a u -- n }      u a bio 3 BIO_write I32 ;     \ push a received datagram in
: SSL-FREE     ( ssl -- )            ?DUP IF 1 SSL_free DROP THEN ;
: CTX-FREE     ( ctx -- )            ?DUP IF 1 SSL_CTX_free DROP THEN ;

\ ===== helpers for the verify-callback (the callback itself is in dtls-net.f) ===================
\ These wrappers keep the SO namespace INSIDE dtls.f.  The callback body cannot live here: it needs
\ CERT-SPKI/SHA1/.HASH (swarm.f Forth words), but here SHA1 still resolves to the libcrypto EXPORT
\ (SO is in scope until PREVIOUS PREVIOUS below) -- calling that C SHA1 as a bare word == 0xC0000005.
\ So dtls-net.f defines SWARM-VERIFY-CB (SO-free) and does `' SWARM-VERIFY-CB TO DTLS-VERIFY-CB`.
4096 CONSTANT /CB-DER   CREATE CB-DER /CB-DER ALLOT   VARIABLE CB-DER-PTR
512  CONSTANT /CB-SUB   CREATE CB-SUB /CB-SUB ALLOT

: SCTX-CERT   ( sctx -- x509 )  1 X509_STORE_CTX_get_current_cert ;
: SCTX-ERR    ( sctx -- n )     1 X509_STORE_CTX_get_error I32 ;
: SCTX-DEPTH  ( sctx -- n )     1 X509_STORE_CTX_get_error_depth I32 ;
: SCTX>SSL    { sctx \ idx -- ssl }                       \ the SSL* this store-ctx belongs to
   0 SSL_get_ex_data_X509_STORE_CTX_idx I32 -> idx
   idx sctx 2 X509_STORE_CTX_get_ex_data ;
: SSL>BASE    ( ssl -- base )   0 SWAP 2 SSL_get_ex_data ;         \ our USER base (stashed in DTLS-WRAP)
: VERR-STR    ( code -- a u )   1 X509_verify_cert_error_string ASCIIZ> ;
: X509-SUBJECT { x509 -- a u }                            \ subject DN as text, into CB-SUB
   /CB-SUB CB-SUB  x509 1 X509_get_subject_name  3 X509_NAME_oneline DROP
   CB-SUB ASCIIZ> ;
\ ===== P0.5: stateless cookie / HelloVerifyRequest ==========================================
\ Before this, ANY datagram whose first byte looked like a DTLS record could make us allocate an SSL and
\ a peer slot.  A flood from forged source addresses would then hold every slot until CONNECT-TIMEOUT,
\ and we would answer a certificate flight to an address that never asked -- an amplifier.
\ The cure is RFC 6347's cookie round: answer a first ClientHello with a HelloVerifyRequest carrying a
\ cookie derived from the sender's own endpoint, and allocate NOTHING.  Only a client that can receive
\ at that address can echo the cookie back, so a forged source never gets past this point.  The reply is
\ SMALLER than the ClientHello that triggered it, so there is nothing to amplify either.
\ We drive it with DTLSv1_listen rather than emitting the HelloVerifyRequest ourselves: after a cookie
\ round the client's second ClientHello carries message_seq=1, and a server that never saw the exchange
\ would still be waiting for seq 0.  OpenSSL keeps that bookkeeping inside the listener SSL.
\ The cookie binds to (secret, ip, port); the secret is per-run, like the DHT token secret.
16 CONSTANT /COOKIE
CREATE COOKIE-SECRET 16 ALLOT
CREATE COOKIE-MAT    22 ALLOT                             \ secret(16) + ip(4) + port(2)
CREATE COOKIE-MD     20 ALLOT
VARIABLE CK-IP   VARIABLE CK-PORT                         \ endpoint to bind to; set before DTLSv1_listen
: COOKIE-INIT ( -- )   16 COOKIE-SECRET 2 RAND_bytes DROP ;
: (COOKIE-CALC) ( -- )                                    \ COOKIE-MD = SHA1(secret || ip || port)
   COOKIE-SECRET COOKIE-MAT 16 CMOVE
   CK-IP @         255 AND COOKIE-MAT 16 + C!   CK-IP @  8 RSHIFT 255 AND COOKIE-MAT 17 + C!
   CK-IP @ 16 RSHIFT 255 AND COOKIE-MAT 18 + C!  CK-IP @ 24 RSHIFT 255 AND COOKIE-MAT 19 + C!
   CK-PORT @ 8 RSHIFT 255 AND COOKIE-MAT 20 + C!  CK-PORT @ 255 AND COOKIE-MAT 21 + C!
   COOKIE-MD 22 COOKIE-MAT 3 SHA1 DROP ;                  \ the libcrypto SHA1, SO is in scope here
: U32! { x a -- }                                         \ store exactly 4 bytes (an unsigned int*)
   x 255 AND a C!  x 8 RSHIFT 255 AND a 1+ C!
   x 16 RSHIFT 255 AND a 2 + C!  x 24 RSHIFT 255 AND a 3 + C! ;

:NONAME { lenp ck ssl \ tls base -- ret }                 \ cookie_generate_cb(SSL*, uchar*, uint*)
   \ locals are the C arguments REVERSED, exactly like the verify cb above ({ sctx preverify } for
   \ verify_callback(preverify, ctx)).  Getting this backwards made ssl hold the length pointer and
   \ SSL>BASE dereference garbage -- a segfault the moment a real ClientHello arrived.
   TlsIndex@ -> tls
   ssl IF ssl SSL>BASE -> base  base IF base TlsIndex! THEN THEN
   ['] (COOKIE-CALC) CATCH DROP
   COOKIE-MD ck /COOKIE CMOVE   /COOKIE lenp U32!
   tls TlsIndex!   1 ;
3 CELLS CALLBACK: SWARM-COOKIE-GEN
:NONAME { len ck ssl \ tls base ok -- ret }               \ cookie_verify_cb(SSL*, const uchar*, uint) -- reversed
   TlsIndex@ -> tls
   ssl IF ssl SSL>BASE -> base  base IF base TlsIndex! THEN THEN
   FALSE -> ok
   len /COOKIE = IF ['] (COOKIE-CALC) CATCH DROP  ck COOKIE-MD /COOKIE MEM= -> ok THEN
   tls TlsIndex!   ok IF 1 ELSE 0 THEN ;
3 CELLS CALLBACK: SWARM-COOKIE-VER
' SWARM-COOKIE-GEN TO DTLS-COOKIE-GEN
' SWARM-COOKIE-VER TO DTLS-COOKIE-VER

VARIABLE CK-ADDR                                          \ one BIO_ADDR, reused (we know the peer already)
VARIABLE COOKIE-SEEDED                                    \ DTLS-INIT is declared above this block, so the
: DTLS-LISTEN { ssl ip port -- r }                        \ secret is seeded on first use instead
   COOKIE-SEEDED @ 0= IF COOKIE-INIT TRUE COOKIE-SEEDED ! THEN
   ip CK-IP !  port CK-PORT !                             \ 1 = cookie ok (adopt ssl), 0 = HVR queued, <0
   CK-ADDR @ 0= IF 0 BIO_ADDR_new CK-ADDR ! THEN
   CK-ADDR @ ssl 2 DTLSv1_listen I32 ;

: X509>DER { x509 \ len -- a u }                          \ DER of a BORROWED cert (no free); 0 0 on error
   0 x509 2 i2d_X509 I32 -> len
   len 1 < len /CB-DER > OR IF 0 0 EXIT THEN
   CB-DER CB-DER-PTR !
   CB-DER-PTR x509 2 i2d_X509 DROP
   CB-DER len ;

4096 CONSTANT /CB-SPKI
CREATE CB-SPKI /CB-SPKI ALLOT   VARIABLE CB-SPKI-PTR   VARIABLE D2I-PTR
: (DER>SPKI) { a u \ x pk len -- spki-a spki-u true | false }
   \ Let OpenSSL do the parsing: it decodes the whole certificate, so a malformed one fails HERE
   \ rather than inside a hand-rolled walk.  This is what CERT-SPKI uses unless SPKI-VIA-OPENSSL?
   \ is turned off.  d2i_X509 gives us a cert we own; the pubkey inside it is borrowed.
   a D2I-PTR !                                            \ d2i advances the pointer it is given
   u D2I-PTR 0  3 d2i_X509 -> x
   x 0= IF FALSE EXIT THEN
   x 1 X509_get_X509_PUBKEY -> pk
   pk 0= IF x 1 X509_free DROP FALSE EXIT THEN
   0 pk 2 i2d_X509_PUBKEY I32 -> len
   len 1 < len /CB-SPKI > OR IF x 1 X509_free DROP FALSE EXIT THEN
   CB-SPKI CB-SPKI-PTR !
   CB-SPKI-PTR pk 2 i2d_X509_PUBKEY DROP
   x 1 X509_free DROP
   CB-SPKI len TRUE ;

\ Restore the search order: remove the two SO (libcrypto/libssl) wordlists so that names like SHA1
\ (a libcrypto export!) resolve to the normal Forth words in code loaded/compiled after this file.
PREVIOUS PREVIOUS

' (DER>SPKI) TO SPKI-OPENSSL-XT                    \ CERT-SPKI now prefers OpenSSL (see swarm.f)

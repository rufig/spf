\ ~ac/lib/asn1/der.f -- bounded DER (ASN.1 Distinguished Encoding Rules) reader.
\ Every read is confined to the buffer the caller supplies: a truncated, malformed or hostile encoding
\ makes the walk FAIL, it never reads outside the buffer.  Each word returns an explicit ok flag, so a
\ caller cannot accidentally use a value the parser never produced (the classic way a hand-rolled DER
\ walker turns a bad certificate into an out-of-bounds read).
\ Portable: core + locals only -- no OS, no sockets, no crypto -- so it unit-tests on every target.
\ Unit tests (bounds + hostile encodings) live in der-test.f next to this file.  CRLF.
REQUIRE { ~ac/lib/locals.f
DECIMAL

8 CONSTANT DER-MAXLEN-OCTETS       \ a long-form length needing more octets than this cannot fit a cell

\ DER-TLV ( a end -- tag val-a val-u next-a true | false )   parse ONE TLV at a, bounded by end.
\ Rejects: missing tag/length byte, indefinite length (0x80 -- forbidden in DER), a long form with more
\ length octets than a cell holds, a length with the sign bit set, and any content running past `end`.
: DER-TLV { a end \ p b n len -- tag val-a val-u next-a true | false }
   a end U< 0= IF FALSE EXIT THEN                  \ no tag byte
   a 1+ -> p
   p end U< 0= IF FALSE EXIT THEN                  \ no length byte
   p C@ -> b   p 1+ -> p
   b 128 < IF b -> len                             \ short form: length is the byte itself
   ELSE
      b 127 AND -> n
      n 0= IF FALSE EXIT THEN                      \ 0x80 = indefinite length: not valid DER
      n DER-MAXLEN-OCTETS > IF FALSE EXIT THEN     \ would not fit a cell -> reject, never wrap silently
      0 -> len
      n 0 DO
         p end U< 0= IF FALSE UNLOOP EXIT THEN     \ length octets themselves must be inside the buffer
         len 8 LSHIFT  p C@ +  -> len   p 1+ -> p
      LOOP
   THEN
   len 0< IF FALSE EXIT THEN                       \ absurd (sign bit) length -> reject
   end p -  len U< IF FALSE EXIT THEN              \ content must fit inside the buffer
   a C@   p   len   p len +   TRUE ;

: DER-TAG@ { a end -- tag true | false }           \ the tag byte of the TLV at a
   a end DER-TLV 0= IF FALSE EXIT THEN  DROP 2DROP TRUE ;
: DER-VALUE { a end -- val-a val-u true | false }  \ the CONTENT span of the TLV at a
   a end DER-TLV 0= IF FALSE EXIT THEN  DROP ROT DROP TRUE ;
: DER-NEXT { a end -- next-a true | false }        \ skip one whole TLV
   a end DER-TLV 0= IF FALSE EXIT THEN  >R 2DROP DROP R> TRUE ;
: DER-CHILD { a end -- inner-a inner-end true | false }   \ descend into a constructed TLV
   a end DER-TLV 0= IF FALSE EXIT THEN  DROP OVER + ROT DROP TRUE ;
: DER-SPAN { a end -- tlv-a tlv-u true | false }   \ the WHOLE TLV (tag+length+content) at a
   a end DER-TLV 0= IF FALSE EXIT THEN  >R 2DROP DROP R>  a -  a SWAP TRUE ;

\ ===== X.509 helper: locate the SubjectPublicKeyInfo =========================================
\ Certificate     ::= SEQUENCE { tbsCertificate, signatureAlgorithm, signatureValue }
\ TBSCertificate  ::= SEQUENCE { [0] version OPTIONAL, serialNumber, signature, issuer, validity,
\                                subject, subjectPublicKeyInfo, ... }
\ The identity hash is taken over the WHOLE SubjectPublicKeyInfo TLV, so that is what we return.
48  CONSTANT DER-SEQUENCE           \ 0x30
160 CONSTANT DER-CTX0               \ 0xA0 = [0] EXPLICIT (the optional version)

: DER-SPKI { a u \ ce ta te -- spki-a spki-u true | false }
   u 1 < IF FALSE EXIT THEN
   a u + -> ce
   a ce DER-TAG@ 0= IF FALSE EXIT THEN  DER-SEQUENCE <> IF FALSE EXIT THEN   \ Certificate SEQUENCE
   a ce DER-CHILD 0= IF FALSE EXIT THEN -> te -> ta                          \ -> tbsCertificate TLV
   ta te DER-TAG@ 0= IF FALSE EXIT THEN  DER-SEQUENCE <> IF FALSE EXIT THEN  \ tbsCertificate SEQUENCE
   ta te DER-CHILD 0= IF FALSE EXIT THEN -> te -> ta                         \ -> its first field
   ta te DER-TAG@ 0= IF FALSE EXIT THEN  DER-CTX0 = IF                       \ optional [0] version
      ta te DER-NEXT 0= IF FALSE EXIT THEN -> ta THEN
   5 0 DO                                          \ serial, sigAlg, issuer, validity, subject
      ta te DER-NEXT 0= IF FALSE UNLOOP EXIT THEN -> ta
   LOOP
   ta te DER-TAG@ 0= IF FALSE EXIT THEN  DER-SEQUENCE <> IF FALSE EXIT THEN  \ SubjectPublicKeyInfo
   ta te DER-SPAN ;

\ FCS-16 - контрольная сумма для PPP и HDLC
\ Основано на С-коде из RFC 1662

\ Если PPP-кадры помещаются внутрь L2TP/PPTP-кадров, то контрольные суммы не используются.
\ FCS-16 нужен для PPP over serial (USB/COM-модемы и т.п.)

: fсstab,
  BASE @ >R HEX
  0x20 0 DO 
    REFILL DROP
    0x10 0 DO NextWord EVALUATE C, LOOP
  LOOP R> BASE !
;
CREATE fcstab fсstab,
00 00 89 11 12 23 9B 32  24 46 AD 57 36 65 BF 74
48 8C C1 9D 5A AF D3 BE  6C CA E5 DB 7E E9 F7 F8
81 10 08 01 93 33 1A 22  A5 56 2C 47 B7 75 3E 64
C9 9C 40 8D DB BF 52 AE  ED DA 64 CB FF F9 76 E8
02 21 8B 30 10 02 99 13  26 67 AF 76 34 44 BD 55
4A AD C3 BC 58 8E D1 9F  6E EB E7 FA 7C C8 F5 D9
83 31 0A 20 91 12 18 03  A7 77 2E 66 B5 54 3C 45
CB BD 42 AC D9 9E 50 8F  EF FB 66 EA FD D8 74 C9
04 42 8D 53 16 61 9F 70  20 04 A9 15 32 27 BB 36
4C CE C5 DF 5E ED D7 FC  68 88 E1 99 7A AB F3 BA
85 52 0C 43 97 71 1E 60  A1 14 28 05 B3 37 3A 26
CD DE 44 CF DF FD 56 EC  E9 98 60 89 FB BB 72 AA
06 63 8F 72 14 40 9D 51  22 25 AB 34 30 06 B9 17
4E EF C7 FE 5C CC D5 DD  6A A9 E3 B8 78 8A F1 9B
87 73 0E 62 95 50 1C 41  A3 35 2A 24 B1 16 38 07
CF FF 46 EE DD DC 54 CD  EB B9 62 A8 F9 9A 70 8B
08 84 81 95 1A A7 93 B6  2C C2 A5 D3 3E E1 B7 F0
40 08 C9 19 52 2B DB 3A  64 4E ED 5F 76 6D FF 7C
89 94 00 85 9B B7 12 A6  AD D2 24 C3 BF F1 36 E0
C1 18 48 09 D3 3B 5A 2A  E5 5E 6C 4F F7 7D 7E 6C
0A A5 83 B4 18 86 91 97  2E E3 A7 F2 3C C0 B5 D1
42 29 CB 38 50 0A D9 1B  66 6F EF 7E 74 4C FD 5D
8B B5 02 A4 99 96 10 87  AF F3 26 E2 BD D0 34 C1
C3 39 4A 28 D1 1A 58 0B  E7 7F 6E 6E F5 5C 7C 4D
0C C6 85 D7 1E E5 97 F4  28 80 A1 91 3A A3 B3 B2
44 4A CD 5B 56 69 DF 78  60 0C E9 1D 72 2F FB 3E
8D D6 04 C7 9F F5 16 E4  A9 90 20 81 BB B3 32 A2
C5 5A 4C 4B D7 79 5E 68  E1 1C 68 0D F3 3F 7A 2E
0E E7 87 F6 1C C4 95 D5  2A A1 A3 B0 38 82 B1 93
46 6B CF 7A 54 48 DD 59  62 2D EB 3C 70 0E F9 1F
8F F7 06 E6 9D D4 14 C5  AB B1 22 A0 B9 92 30 83
C7 7B 4E 6A D5 58 5C 49  E3 3D 6A 2C F1 1E 78 0F


\ Calculate a new fcs given the current fcs and the new data.

: pppfcs16 ( fcs cp len -- fsc )
  OVER + SWAP
  DO
\           fcs = (fcs >> 8) ^ fcstab[(fcs ^ *cp++) & 0xff];
    I C@ OVER XOR 0xFF AND 1 LSHIFT fcstab + W@ SWAP 8 RSHIFT XOR
  LOOP
;

0xFFFF CONSTANT PPPINITFCS16 \ Initial FCS value
0xF0B8 CONSTANT PPPGOODFCS16 \ Good final FCS value (для проверки: если считать вместе с 2 байтами fcs, то должно получиться это)

\EOF

0 fcstab 512 pppfcs16 HEX U.

CREATE TEST
0xFF C, \ address
0x03 C, \ control 
 
0xC0 C, 0x21 C, \ lcp
0x01 C, \ lcp-command 1=LcpConfigureRequest
0x00 C, \ lcp-id
0x00 C, \
0x17 C, \ lcp-len, включая 4 байта заголовка

0x02 C,
0x06 C,
0x00 C,
0x00 C,
0x00 C,
0x00 C,
0x05 C,
0x06 C,
0x2E C,
0x69 C,
0x19 C,
0xF3 C,
0x07 C,
0x02 C,
0x08 C,
0x02 C,
0x0D C,
0x03 C,
0x06 C,

HERE TEST - CONSTANT /TEST

0 W,

\ How to use the fcs

: tryfcs16 ( cp len -- fcs )

  2DUP
  \ add on output
  \     trialfcs = pppfcs16( PPPINITFCS16, cp, len );
  PPPINITFCS16 ROT ROT pppfcs16
  0xFFFF XOR \ complement
  DUP HEX .

  TEST /TEST + W! \ least significant byte first

  \ check on input
  \     trialfcs = pppfcs16( PPPINITFCS16, cp, len + 2 );
  PPPINITFCS16 ROT ROT 2+ pppfcs16
  DUP HEX .
  PPPGOODFCS16 =
  IF ." Good FCS" CR THEN

;

TEST /TEST tryfcs16 \ HEX U.

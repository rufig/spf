( компилирует две иконки в ресурсы )

0 VALUE I16 0 VALUE I32

: I1:
  2>R
  BL WORD COUNT 2DUP + 0 SWAP C! R/O OPEN-FILE THROW
  DUP HERE 22 ROT READ-FILE THROW DROP
  DUP 2R> ROT READ-FILE THROW DROP CLOSE-FILE DROP
;
: ICONS:
  I32 744 I1:
  I16 296 I1:
;

512 ALIGN-BYTES ! ALIGN 4 ALIGN-BYTES !
HEX
HERE IMAGE-BASE - RESOURCES-RVA !
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 2 W, ( номеров)
3 , ( ICON) 80000020 , ( offs)
E , ( GROUP_ICON) 80000040 , ( offs )

( 20:)
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 2 W, ( номеров)
1 , ( ICON_number ) 80000058 , ( offs)
2 , ( ICON_number ) 80000070 , ( offs)

( 40:)
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 1 W, ( номеров)
1 , ( GI_number) 80000088 , ( offs)

( 58:)
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 1 W, ( номеров)
419 , ( ICON_lang) 000000A0 , ( offs)

( 70:)
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 1 W, ( номеров)
419 , ( ICON_lang) 000000B0 , ( offs)

( 88:)
0 , ( резерв) 9E4231 , ( дата)  4 , ( версия) 0 W, ( имён) 1 W, ( номеров)
419 , ( GI_lang) 000000C0 , ( offs)

( A0:)
HERE 30 + IMAGE-BASE - , ( data_RVA) 2E8 , ( size) 4E4 , ( codepage) 0 , ( reserved)

( B0:)
HERE 20 + 2E8 + IMAGE-BASE - , ( data_RVA) 128 , ( size) 4E4 , ( codepage) 0 , ( reserved)

( C0:)
HERE 10 + 2E8 + 128 + IMAGE-BASE - , ( data_RVA) 22 , ( size) 4E4 , ( codepage) 0 , ( reserved)

DECIMAL
HERE TO I32
S" src\spf32x32.ico" R/O OPEN-FILE THROW 
DUP HERE 22 ROT READ-FILE THROW DROP
DUP HERE 744 DUP ALLOT ROT READ-FILE THROW DROP CLOSE-FILE DROP

HERE TO I16
S" src\spf16x16.ico" R/O OPEN-FILE THROW 
DUP HERE 22 ROT READ-FILE THROW DROP
DUP HERE 296 DUP ALLOT ROT READ-FILE THROW DROP CLOSE-FILE DROP

HEX

00 C, 00 C, 01 C, 00 C, 02 C, 00 C, 20 C, 20 C, 10 C, 00 C, 01 C, 00 C, 04 C, 00 C, E8 C, 02 C,
00 C, 00 C, 01 C, 00 C, 10 C, 10 C, 10 C, 00 C, 01 C, 00 C, 04 C, 00 C, 28 C, 01 C, 00 C, 00 C,
02 C, 00 C,

DECIMAL

HERE IMAGE-BASE - RESOURCES-RVA @ - RESOURCES-SIZE !

S" spf375.exe" SAVE BYE

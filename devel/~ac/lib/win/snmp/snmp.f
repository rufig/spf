\ SNMP v2 клиент/сервер. (C) 2005 Andrey CHerezov

WINAPI: SnmpStartup       Wsnmp32.DLL
WINAPI: SnmpCreateSession Wsnmp32.DLL
WINAPI: SnmpCreatePdu     Wsnmp32.DLL
WINAPI: SnmpStrToContext  Wsnmp32.DLL
WINAPI: SnmpStrToEntity   Wsnmp32.DLL
WINAPI: SnmpSendMsg       Wsnmp32.DLL
WINAPI: SnmpGetLastError  Wsnmp32.DLL
WINAPI: SnmpCreateVbl     Wsnmp32.DLL
WINAPI: SnmpStrToOid      Wsnmp32.DLL
WINAPI: SnmpRecvMsg       Wsnmp32.DLL
WINAPI: SnmpGetPduData    Wsnmp32.DLL
WINAPI: SnmpCountVbl      Wsnmp32.DLL
WINAPI: SnmpGetVb         Wsnmp32.DLL
WINAPI: SnmpFreeVbl       Wsnmp32.DLL
WINAPI: SnmpFreePdu       Wsnmp32.DLL
WINAPI: SnmpFreeContext   Wsnmp32.DLL
WINAPI: SnmpFreeEntity    Wsnmp32.DLL
WINAPI: SnmpFreeDescriptor Wsnmp32.DLL

WINAPI: SnmpSetPort       Wsnmp32.DLL
WINAPI: SnmpListen        Wsnmp32.DLL
WINAPI: SnmpOidToStr      Wsnmp32.DLL
WINAPI: SnmpEntityToStr   Wsnmp32.DLL
WINAPI: SnmpSetPduData    Wsnmp32.DLL
WINAPI: SnmpSetVb         Wsnmp32.DLL
WINAPI: SnmpDeleteVb      Wsnmp32.DLL

USER SNMPnMajorVersion
USER SNMPnMinorVersion
USER SNMPnLevel
USER SNMPnTranslateMode
USER SNMPnRetransmitMode
USER SNMPsession
USER SNMPpdu
CREATE SNMPcommunity S" public" DUP , HERE CELL+ , HERE SWAP DUP ALLOT MOVE
USER SNMPcontext
USER SNMPentity
CREATE SNMPoid 0 , 0 ,
USER SNMPvbl

USER SNMPoutpdu
USER SNMPoutcontext
USER SNMPdstentity
USER SNMPsrcentity
USER SNMPoutvbl
USER SNMPerror_index
USER SNMPerror_status
USER SNMPrequest_id
USER SNMPpdu_type
CREATE SNMPoutoid 0 , 0 ,

0x80 CONSTANT ASN_CONTEXT
0x20 CONSTANT ASN_CONSTRUCTOR

ASN_CONTEXT ASN_CONSTRUCTOR OR 0x0 OR CONSTANT SNMP_PDU_GET          
ASN_CONTEXT ASN_CONSTRUCTOR OR 0x1 OR CONSTANT SNMP_PDU_GETNEXT
ASN_CONTEXT ASN_CONSTRUCTOR OR 0x2 OR CONSTANT SNMP_PDU_RESPONSE
ASN_CONTEXT ASN_CONSTRUCTOR OR 0x3 OR CONSTANT SNMP_PDU_SET
\ /* SNMP_PDU_V1TRAP is obsolete in SNMPv2 */
\ #define SNMP_PDU_V1TRAP       (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x4)
\ #define SNMP_PDU_GETBULK      (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x5)
\ #define SNMP_PDU_INFORM       (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x6)
\ #define SNMP_PDU_TRAP         (ASN_CONTEXT | ASN_CONSTRUCTOR | 0x7)

0x00 CONSTANT ASN_UNIVERSAL
0x00 CONSTANT ASN_PRIMITIVE
0x40 CONSTANT ASN_APPLICATION

ASN_UNIVERSAL ASN_PRIMITIVE OR 0x04 OR CONSTANT SNMP_SYNTAX_OCTETS
CREATE SNMPvalue SNMP_SYNTAX_OCTETS , 0 , 0 ,
CREATE SNMPoutvalue SNMP_SYNTAX_OCTETS , 0 , 0 ,

ASN_UNIVERSAL ASN_PRIMITIVE OR 0x02 OR CONSTANT SNMP_SYNTAX_INT
ASN_UNIVERSAL ASN_PRIMITIVE OR 0x03 OR CONSTANT SNMP_SYNTAX_BITS
ASN_UNIVERSAL ASN_PRIMITIVE OR 0x05 OR CONSTANT SNMP_SYNTAX_NULL
ASN_UNIVERSAL ASN_PRIMITIVE OR 0x06 OR CONSTANT SNMP_SYNTAX_OID

ASN_APPLICATION ASN_PRIMITIVE OR 0x00 OR CONSTANT SNMP_SYNTAX_IPADDR    
ASN_APPLICATION ASN_PRIMITIVE OR 0x01 OR CONSTANT SNMP_SYNTAX_CNTR32    
ASN_APPLICATION ASN_PRIMITIVE OR 0x02 OR CONSTANT SNMP_SYNTAX_GAUGE32
ASN_APPLICATION ASN_PRIMITIVE OR 0x03 OR CONSTANT SNMP_SYNTAX_TIMETICKS

CREATE SNMPresp SNMP_PDU_RESPONSE ,

VARIABLE SnmpWaitingPdu
:NONAME
(
  ." sessionHandle=" .
  ."  hWnd=" . 
  ."  wMsg=" .
  ."  wParam[0?]=" .
  ."  lParam="  .
  ."  lpClientData=" . CR
) 2DROP 2DROP 2DROP
  SnmpWaitingPdu 1+!
  1
; WNDPROC: SnmpCallback

\ .1.3.6.1.2.1.1.1
\ .iso.org.dod.internet.mgmt.mib-2.system.sysDescr

: SnmpDumpReceivedPdu ( -- )
  SNMPoutvbl SNMPerror_index SNMPerror_status SNMPrequest_id SNMPpdu_type
  SNMPoutpdu @ SnmpGetPduData 0= THROW
  SNMPoutvbl @ SnmpCountVbl 1+ 1 ?DO
    3 CELLS ALLOCATE THROW DUP SNMPoutoid I SNMPoutvbl @ SnmpGetVb 0= THROW
    DUP @ SNMP_SYNTAX_OCTETS =
    IF DUP CELL+ DUP @ SWAP CELL+ @ SWAP TYPE CR
    ELSE DUP 3 CELLS DUMP CR THEN
    FREE THROW
\    SNMPoutoid CELL+ @ SNMPoutoid @ CELLS DUMP CR
    PAD 100 SNMPoutoid SnmpOidToStr PAD SWAP TYPE CR
  LOOP
;
: SnmpExecReceivedPdu ( -- )
  SNMPoutvbl SNMPerror_index SNMPerror_status SNMPrequest_id SNMPpdu_type
  SNMPoutpdu @ SnmpGetPduData 0= THROW
SNMPpdu_type @ ." T=" .
  SNMPoutvbl @ SnmpCountVbl 1+ 1 ?DO
    SNMPoutvalue SNMPoutoid I SNMPoutvbl @ SnmpGetVb 0= THROW
    PAD 100 SNMPoutoid SnmpOidToStr 
    IF PAD ASCIIZ> SFIND IF I SWAP EXECUTE ELSE ." unknown_oid=" TYPE THEN THEN
\    PAD 100 SNMPsrcentity @ DUP ." src=" . SnmpEntityToStr DUP .
\    IF PAD ASCIIZ> TYPE ." ->" THEN
\    PAD 100 SNMPdstentity @ DUP ." dst=" . SnmpEntityToStr DUP .
\    IF PAD ASCIIZ> TYPE CR THEN \ в режиме агента = 0 !
  LOOP
  0 0 0 0 SNMPresp SNMPoutpdu @ SnmpSetPduData 0= THROW
  SNMPoutpdu @ SNMPoutcontext @ SNMPsrcentity @ SNMPentity @ SNMPsession @ SnmpSendMsg 0= THROW
;
: SnmpFreeReceivedPdu
  SNMPoutvbl @ SnmpFreeVbl 0= THROW
  SNMPoutpdu @ SnmpFreePdu 0= THROW
  SNMPoutcontext @ SnmpFreeContext 0= THROW
  SNMPsrcentity @ SnmpFreeEntity 0= THROW
  SNMPdstentity @ SnmpFreeEntity 0= THROW
;
: SnmpGetType ( S"oid" type S"host" -- )
  2>R >R 2>R
  SNMPoid ( S" 1.3.6.1.2.1.1.1.0" DROP) 2R> DROP SnmpStrToOid 0= THROW
  SNMPvalue SNMPoid SNMPsession @ SnmpCreateVbl DUP SNMPvbl ! 0= THROW
  SNMPvbl @ 0 0 0 ( SNMP_PDU_GET) R> SNMPsession @ SnmpCreatePdu DUP SNMPpdu ! 0= THROW
  SNMPcommunity SNMPsession @ SnmpStrToContext DUP SNMPcontext ! 0= THROW
  S" 127.0.0.1" DROP SNMPsession @ SnmpStrToEntity DUP SNMPentity ! 0= THROW
  ( S" 198.63.211.47" DROP) 2R> DROP SNMPsession @ SnmpStrToEntity DUP SNMPdstentity ! 0= THROW
  SNMPpdu @ SNMPcontext @ SNMPdstentity @ SNMPentity @ SNMPsession @ SnmpSendMsg 0= THROW
  BEGIN 100 PAUSE SnmpWaitingPdu @ UNTIL SnmpWaitingPdu @ 1- 0 MAX SnmpWaitingPdu !
  SNMPvbl @ SnmpFreeVbl 0= THROW
  SNMPpdu @ SnmpFreePdu 0= THROW
  SNMPcontext @ SnmpFreeContext 0= THROW
  SNMPentity @ SnmpFreeEntity 0= THROW
  SNMPdstentity @ SnmpFreeEntity 0= THROW
  SNMPoid SNMP_SYNTAX_OID SnmpFreeDescriptor 0= THROW
  SNMPoutpdu SNMPoutcontext SNMPdstentity SNMPsrcentity SNMPsession @ SnmpRecvMsg 0= THROW
;
: SnmpGet  ( S"oid" S"host" -- )
  SNMP_PDU_GET ROT ROT SnmpGetType
;
: SnmpGetNext  ( S"oid" S"host" -- )
  SNMP_PDU_GETNEXT ROT ROT SnmpGetType
;
: SnmpInit
  SNMPnRetransmitMode SNMPnTranslateMode SNMPnLevel
  SNMPnMinorVersion SNMPnMajorVersion SnmpStartup 1 =
  SNMPnLevel @ 2 = AND 0= THROW
  0 ['] SnmpCallback 0 0 SnmpCreateSession DUP SNMPsession ! 0= THROW

(
  S" 1.3.6.1.2.1.1.1.0" S" 198.63.211.47" SnmpGet SnmpDumpReceivedPdu SnmpFreeReceivedPdu
  S" 1.3.6.1.2.1.1.7.0" S" 198.63.211.47" SnmpGet SnmpDumpReceivedPdu SnmpFreeReceivedPdu

  S" 1.3.6.1.2.1.4.3.0" S" 198.63.211.47" SnmpGet SnmpDumpReceivedPdu SnmpFreeReceivedPdu

  S" 1.3.6.1.2.1.6.9.0" S" 198.63.211.47" SnmpGet SnmpDumpReceivedPdu SnmpFreeReceivedPdu
  S" 1.3.6.1.2.1.6.9" S" 198.63.211.47" SnmpGetNext SnmpDumpReceivedPdu SnmpFreeReceivedPdu
." 1:"  S" 1.3.6.1.2.1.6.9.0" S" 198.63.211.47" SnmpGetNext SnmpDumpReceivedPdu SnmpFreeReceivedPdu
." 2:"  S" 1.3.6.1.2.1.6.15.0" S" 198.63.211.47" SnmpGetNext SnmpDumpReceivedPdu SnmpFreeReceivedPdu
." 3:"  S" 1.3.6.1.2.1.6.105" S" 198.63.211.47" SnmpGetNext SnmpDumpReceivedPdu SnmpFreeReceivedPdu

  100 0 DO
    S" 1.3.6.1.2.1.6.9.0" S" 198.63.211.47" SnmpGet SnmpDumpReceivedPdu SnmpFreeReceivedPdu
    1000 PAUSE
  LOOP
)

  S" 127.0.0.2" DROP SNMPsession @ SnmpStrToEntity DUP SNMPentity ! 0= THROW
  170 SNMPentity @ SnmpSetPort 0= THROW
  1 SNMPentity @ SnmpListen 0= THROW
  BEGIN
    BEGIN 100 PAUSE SnmpWaitingPdu @ UNTIL SnmpWaitingPdu @ 1- 0 MAX SnmpWaitingPdu !
    SNMPoutpdu SNMPoutcontext SNMPdstentity SNMPsrcentity SNMPsession @ SnmpRecvMsg 0= THROW
    SnmpExecReceivedPdu ."  D=" DEPTH . CR
  AGAIN

\  SNMPsession @ SnmpGetLastError .
;

: SnmpStrValue ( addr u -- addr2 ) \ addr2 освободить по FREE
  2>R
  3 CELLS ALLOCATE THROW
  SNMP_SYNTAX_OCTETS OVER !
  DUP 2R> ROT CELL+ ! OVER CELL+ CELL+ ! \ value
;
: SnmpGaugeValue ( x -- addr2 ) \ addr2 освободить по FREE
  >R
  3 CELLS ALLOCATE THROW
  SNMP_SYNTAX_GAUGE32 OVER !
  R> OVER CELL+ ! \ value
;
: SnmpIntValue ( n -- addr2 ) \ addr2 освободить по FREE
  >R
  3 CELLS ALLOCATE THROW
  SNMP_SYNTAX_INT OVER !
  R> OVER CELL+ ! \ value
;
: SnmpOidValue ( addr u -- addr2 ) \ addr2 освободить по FREE
  2>R
  3 CELLS ALLOCATE THROW
  SNMP_SYNTAX_OID OVER !
  DUP CELL+ 2R> DROP SnmpStrToOid 0= THROW \ value
;
: SnmpTimeValue ( n -- addr2 ) \ addr2 освободить по FREE
  >R
  3 CELLS ALLOCATE THROW
  SNMP_SYNTAX_TIMETICKS OVER !
  R> OVER CELL+ ! \ value
;
: SnmpOidName ( addr u -- addr2 ) \ addr2 освободить по FREE
  2>R
  3 CELLS ALLOCATE THROW
  DUP 2R> DROP SnmpStrToOid 0= THROW \ value
;

: SnmpSetStrReply ( index S"str" -- )
  SnmpStrValue 0 ( name unchanged ) ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;
: SnmpSetGaugeReply ( index x -- )
  SnmpGaugeValue 0 ( name unchanged ) ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;
: SnmpSetIntReply ( index n -- )
  SnmpIntValue 0 ( name unchanged ) ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;
: SnmpSetOidReply ( index S"o.i.d" -- )
  SnmpOidValue 0 ( name unchanged ) ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;
: SnmpSetTimeReply ( index n -- )
  SnmpTimeValue 0 ( name unchanged ) ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;
: SnmpSetReplyName ( index S"o.i.d" -- )
  0 ( value unchanged) ROT ROT SnmpOidName ROT SNMPoutvbl @ SnmpSetVb ( index) DROP
;


WINAPI: GetTickCount KERNEL32.DLL

: 1.3.6.1.2.1.1.1.0 \ SysDescr
  S" SP-FORTH SNMP agent" SnmpSetStrReply ;
: 1.3.6.1.2.1.1.2.0 \ SysObjectID (oid)
  S" 1.3.6.1.4.1.18474.300" SnmpSetOidReply ;
: 1.3.6.1.2.1.1.3.0 \ SysUpTime (timeticks)
  GetTickCount SnmpSetTimeReply ;
: 1.3.6.1.2.1.1.4.0 \ SysContact
  S" Andrey Cherezov" SnmpSetStrReply ;
: 1.3.6.1.2.1.1.5.0 \ SysName
  S" SP-Forth" SnmpSetStrReply ;
: 1.3.6.1.2.1.1.6.0 \ SysLocation
  S" ac@forth.org.ru" SnmpSetStrReply ;
: 1.3.6.1.2.1.1.7.0 \ SysServices (integer)
  12 SnmpSetIntReply ;
: 1.3.6.1.2.1.2.1.0 \ IfNumber (integer)
  5 SnmpSetIntReply ;

: 1.3.6.1.2.1.6.9.0 \ .iso.org.dod.internet.mgmt.mib-2.tcp.tcpCurrEstab (gauge)
  SNMPpdu_type @ SNMP_PDU_GETNEXT = 
  IF S" 1.3.6.1.2.1.6.10.0" SnmpSetReplyName EXIT THEN
  GetTickCount 0xFFFF AND SnmpSetGaugeReply ;

: 1.3.6.1.2.1.6.9 \ for GET_NEXT
  DUP S" 1.3.6.1.2.1.6.9.0" SnmpSetReplyName
\  1.3.6.1.2.1.6.9.0
  GetTickCount 0xFFFF AND SnmpSetGaugeReply
;

\ .iso.org.dod.internet.private.enterprises.etype
: 1.3.6.1.4.1.18474 S" Etype root OID" SnmpSetStrReply ;
\ 18474.1 = x.509 key usage

SnmpInit

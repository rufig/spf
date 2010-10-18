\ Получение имени контроллера домена AD в формате "\\хост.dc.в.домене".
\ Если компьютер вне домена (вне MS-доменов), то возвращается пустая строка.

 4 CONSTANT /LPTSTR
 4 CONSTANT /ULONG
16 CONSTANT /GUID

0
/LPTSTR -- dci.DomainControllerName
/LPTSTR -- dci.DomainControllerAddress
 /ULONG -- dci.DomainControllerAddressType
 /GUID  -- dci.DomainGuid
/LPTSTR -- dci.DomainName
/LPTSTR -- dci.DnsForestName
 /ULONG -- dci.Flags
/LPTSTR -- dci.DcSiteName
/LPTSTR -- dci.ClientSiteName
CONSTANT /DOMAIN_CONTROLLER_INFO

WINAPI: DsGetDcNameA NETAPI32.DLL

VARIABLE ADDC_DEBUG

: GetDcName ( -- addr u )
  0 >R
  RP@
  0 \ Flags
  0 \ SiteName
  0 \ DomainGuid
  0 \ DomainName
  0 \ ComputerName
  DsGetDcNameA ?DUP
  IF ADDC_DEBUG @ IF ." GetDcName err=" . CR ELSE DROP THEN
     RDROP S" " EXIT
  THEN                  
  R@
  IF ADDC_DEBUG @
     IF
     R@ dci.DomainControllerName @ ASCIIZ> TYPE CR     \ \\host.dom.ain
     R@ dci.DomainControllerAddress @ ASCIIZ> TYPE CR  \ \\169.254.98.49
     R@ dci.DomainControllerAddressType @ .            \ 1
     R@ dci.DomainGuid /GUID DUMP CR                   \ 16 байт GUID
     R@ dci.DomainName @ ASCIIZ> TYPE CR               \ dom.ain
     R@ dci.DnsForestName @ ASCIIZ> TYPE CR            \ dom.ain
     R@ dci.Flags @ . CR                               \ -536870403
     R@ dci.DcSiteName @ ASCIIZ> TYPE CR               \ Default-First-Site-Name
     R@ dci.ClientSiteName @ ASCIIZ> TYPE CR           \ Default-First-Site-Name
     THEN
     R> dci.DomainControllerName @ ASCIIZ> EXIT
  THEN
  RDROP S" "
;

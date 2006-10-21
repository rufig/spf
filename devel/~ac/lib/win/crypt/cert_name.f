\ Получение значений переменных из строки сертификата. Примеры в конце файла.

REQUIRE {             ~ac/lib/locals.f

: GetCertValue1 { vna vnu \ vpa vpu fa fu -- addr u }
  BEGIN
    [CHAR] / SKIP [CHAR] / PARSE DUP
  WHILE
    2DUP -> vpu -> vpa
    S" =" SEARCH
    IF -> fu -> fa
       vpa vpu fu - vna vnu COMPARE 0=
       IF fa 1+ fu 1- EXIT THEN
    ELSE 2DROP THEN
  REPEAT 2DROP
  S" "
;
: GetCertValue ( ca cu vna vnu -- addr u )
  2SWAP ['] GetCertValue1 EVALUATE-WITH
;
: GetCertEmail ( ca cu -- ea eu )
  S" emailAddress" GetCertValue
;

\ S" /C=RU/L=Kaliningrad/O=Etype/OU=IT/CN=Andrey Cherezov/emailAddress=andrey@cherezov.koenig.su" GetCertEmail TYPE CR
\ S" /C=RU/L=Kaliningrad/O=Etype/OU=IT/CN=Andrey Cherezov/emailAddress=andrey@cherezov.koenig.su" S" zz" GetCertValue TYPE


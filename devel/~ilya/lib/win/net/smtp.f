\ smtp.f
\ "Частичная" реализация протокола SMTP с возможностью аттача файлов
\
\ ADD-ATTACH ( adr n -- ) - Добавить путь к файлу в список
\
\ SMTP-SEND&ATTACH ( adr n adr1 n1 adr2 n2 adr3 n3 adr4 n4 adr5 n5 -- ) - собственно сама отправка
\ adr n     - содержимое письма
\ adr1 n1   - тема письма
\ adr2 n2   - от кого
\ adr3 n3   - кому
\ adr4 n4   - пароль
\ adr5 n5   - адрес SMTP сервера
\




REQUIRE POP3 ~nn/lib/net/pop3.f
REQUIRE base64 ~nn/lib/base64.f
REQUIRE ONLYNAME ~nn/lib/filename.f
REQUIRE N>H ~nn/lib/num2s.f
REQUIRE AddNode ~nn/lib/list.f


VARIABLE attList        \ Указатель на список прикрепляемых файлов

\ Добавить путь к файлу в список
: ADD-ATTACH
S>ZALLOC attList AddNode
;

: ?free ?DUP IF FREE THROW THEN ;


CREATE vName 255 ALLOT

CLASS: SMTP <SUPER POP3
    var vFrom
    var vTo
    var vSubj
    var vData
    var vAttach
\    128 chars vName

CONSTR: init init 25 vPort ! ;
DESTR: free
        vFrom @ ?free
        vTo @ ?free
        vSubj @ ?free
        vUser @ ?free
        vPass @ ?free
        \ vData @ ?free
        free
;


M: smtpOK?
read DROP 3 S>NUM DUP
200 399 WITHIN IF DROP TRUE ELSE vErr ! FALSE THEN
;
M: Hello ( -- flag ) S" HELO localhost" write smtpOK? ;
M: Ehlo ( -- flag ) S" EHLO localhost" write HERE 1024 Read DROP  ( smtpOK?) TRUE ;
M: Auth
S" AUTH LOGIN" write
read 2DROP
vFrom @ ASCIIZ>  HERE base64 write
read 2DROP
vPass @ ASCIIZ> HERE base64 write
smtpOK?
;

M: Mail ( a n -- flag ) <# [CHAR] > HOLD vFrom @ ASCIIZ> HOLDS S" MAIL FROM: <" HOLDS 0#> write smtpOK? ;
M: Rcpt ( a n -- flag ) <# [CHAR] > HOLD vTo @ ASCIIZ> HOLDS S" RCPT TO: <" HOLDS 0#> write smtpOK? ;

M: sData ( adr n -- )   \ Начало передачи
S" DATA" write \ read
smtpOK?
IF
 <# vFrom @ ASCIIZ> HOLDS S" From: " HOLDS 0#> write
 <# vTo @ ASCIIZ> HOLDS S" To: " HOLDS 0#> write
 <# vSubj @ ASCIIZ> HOLDS S" Subject: " HOLDS 0#> write
S" MIME-Version: 1.0" write
S" Content-Type: multipart/mixed; boundary=%QUOTE%bounds1%QUOTE%" EVAL-SUBST write
S" --bounds1" write
S" Content-Type: text/plain; charset=windows-1251" write
S" Content-Transfer-Encoding: quoted-printable" write
WriteCRLF
OVER + SWAP
?DO
   S" =" Write
   I C@  N>H Write
LOOP
WriteCRLF
ELSE 2DROP THEN
;

M: eData
S" --bounds1--" write
\ vErr @ IF
WriteCRLF S" ." write WriteCRLF
\ THEN
;

M: Data
sData eData
;

M: Data&Attach
sData
2DUP
ONLYNAME
vName ZPLACE
2DUP FILE-EXIST
IF
FILE

S" --bounds1" write
S" Content-Type: text/plain;" write
S" name=%QUOTE%%vName ASCIIZ>%%QUOTE%" EVAL-SUBST write
S" Content-transfer-encoding: base64" write
S" Content-Disposition: attachment;" write
S"  filename=%QUOTE%%vName ASCIIZ>%%QUOTE%" EVAL-SUBST write
WriteCRLF


      OVER + SWAP
      ?DO
         I 76
         HERE base64 write
         76
      +LOOP
ELSE 2DROP THEN

eData
;

M: _writeOneAttach
2DUP
ONLYNAME
vName ZPLACE
2DUP FILE-EXIST
IF
FILE

S" --bounds1" write
S" Content-Type: plain/text;" write
S"  name=%QUOTE%%vName ASCIIZ>%%QUOTE%" EVAL-SUBST write
S" Content-transfer-encoding: base64" write
S" Content-Disposition: attachment;" write
S"  filename=%QUOTE%%vName ASCIIZ>%%QUOTE%" EVAL-SUBST write
WriteCRLF

DUP ROT ROT
      OVER + SWAP
      ?DO
         DUP 76 > IF I 76 HERE base64 write ELSE I SWAP HERE base64 write LEAVE THEN
         76 -
         76
      +LOOP
ELSE 2DROP THEN
;

M: writeOneAttach NodeValue ASCIIZ> _writeOneAttach ;
M: free-node NodeValue FREE DROP ;

M: writeAttach
sData
   ['] writeOneAttach attList DoList
   ['] free-node attList DoList
   attList FreeList
eData
;

;CLASS


: SMTP-SEND&ATTACH { \ p -- }
SMTP NEW TO p
WITH SMTP
	p => Addr!
	p => Create
   S>ZALLOC p => vPass !
   S>ZALLOC p => vFrom !
        S>ZALLOC p => vTo !
        S>ZALLOC p => vSubj !
        p => Connect
        p => read 2DROP
        p => vPass @ ASCIIZ> NIP
        IF
            p => Ehlo
            p => Auth AND
         ELSE
            p => Hello
         THEN
        IF

        p => Mail
        p => Rcpt
        OR
        IF p =>  writeAttach ELSE 2DROP 2DROP THEN
        ELSE
            2DROP
        THEN
        \ p => vErr @ CR ." Err=" .
        p => Logout
        p => Close
    p => Delete

ENDWITH

;
\EOF
: test
S" c:\setup.log" ADD-ATTACH
S" c:\config.sys" ADD-ATTACH
\ S" c:\mdr.iss" ADD-ATTACH
\ S" c:\tm_otl.exe" ADD-ATTACH
S" Проверка без аутен."
S" Ещё одно письмо"
S" xxxx@nm.ru"
S" xxxx@inbox.ru"
S" xxxx"
S" smtp.inbox.ru"


SMTP-SEND&ATTACH
;
test



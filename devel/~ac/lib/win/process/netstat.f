\ Простой пример перебора списка IP-соединений
\ вместо использования iphlpapi:GetTcpTable (как в Eserv/3)
\ запускается netstat и парсится его вывод.
\ Дополнительный плюс - меньшая зависимость от версии ОС -
\ на Win2000, в котором нет последнего поля (pid), должен
\ выдать "System" вместо реальных процессов.
\ fixme: но наверное там и опции "-o" в netstat нет :)

( примеры использования см. в конце файла )

REQUIRE ChildAppErr ~ac/lib/win/process/child_app.f
REQUIRE PipeLine    ~ac/lib/win/process/pipeline.f
REQUIRE STR@        ~ac/lib/str5.f
REQUIRE GetProcessInfo ~ac/lib/win/process/info.f 
REQUIRE /STRING     lib/include/string.F

USER uNS
USER uNSpid

: TCP
  SkipDelimiters [CHAR] : PARSE 2DUP S" 0.0.0.0" COMPARE 0= IF 2DROP S" " THEN 2>R
                 NextWord 2DUP S" 0" COMPARE 0= IF 2DROP S" " THEN 2>R
  SkipDelimiters [CHAR] : PARSE 2DUP S" 0.0.0.0" COMPARE 0= IF 2DROP S" " THEN 2>R
                 NextWord 2DUP S" 0" COMPARE 0= IF 2DROP S" " THEN
  2R> 2R> 2R> " <td>{s}</td><td>{s}</td><td>{s}</td><td>{s}</td>" STR@
  NextWord NextWord 0 0 2SWAP >NUMBER 2DROP D>S
  DUP uNSpid @ = uNSpid @ TRUE = OR
  IF
    DUP GetProcessInfo 2DROP 2DUP CUT-PATH NIP /STRING DUP 0= IF 2DROP S" System" THEN
    ROT
    " <tr class='sp_data'><td>TCP</td><td>{n}</td><td>{s}</td><td>{s}</td>{s}</tr>{CRLF}"
    uNS @ S+
  ELSE DROP 2DROP 2DROP THEN
;
: UDP
  SkipDelimiters [CHAR] : PARSE 2DUP S" 0.0.0.0" COMPARE 0= IF 2DROP S" " THEN 2>R
                 NextWord 2DUP S" 0" COMPARE 0= IF 2DROP S" " THEN 2>R
                 NextWord 2DROP
  2R> 2R> " <td>{s}</td><td>{s}</td><td></td><td></td>" STR@
  S" " NextWord 0 0 2SWAP >NUMBER 2DROP D>S
  DUP uNSpid @ = uNSpid @ TRUE = OR
  IF
    DUP GetProcessInfo 2DROP 2DUP CUT-PATH NIP /STRING DUP 0= IF 2DROP S" System" THEN
    ROT
    " <tr class='sp_data'><td>UDP</td><td>{n}</td><td>{s}</td><td>{s}</td>{s}</tr>{CRLF}"
    uNS @ S+
  ELSE DROP 2DROP 2DROP THEN
;
: NETSTAT
  S" command line error" uNS @ STR+
;

: GetNetStatResults { ta tu -- }
  SOURCE S" ::" SEARCH NIP NIP IF EXIT THEN
  SOURCE S" NETSTAT" SEARCH NIP NIP IF SOURCE EVALUATE EXIT THEN
  SOURCE ta tu SEARCH NIP NIP 0= IF EXIT THEN

  SOURCE S" TCP" SEARCH NIP NIP
  SOURCE S" UDP" SEARCH NIP NIP OR
  0=
  IF EXIT
  ELSE
     SOURCE EVALUATE
  THEN
;

: ReadNetStatReply { ta tu l -- }
  BEGIN
    l PipeReadLine \ DUP IF ." =>" 2DUP TYPE ." <=" CR ELSE CR THEN
    ta tu 2SWAP ['] GetNetStatResults ['] EVALUATE-WITH CATCH
    ?DUP IF ." ns_err=" . 2DROP 2DROP THEN
  AGAIN
;
: (NetStatHtml) { ta tu \ l -- }
  CreateStdPipes
  S" netstat.exe -ona" ChildAppErr THROW

  \  -1 OVER WaitForSingleObject DROP CLOSE-FILE THROW
  CLOSE-FILE DROP 

  ( здесь запись в stdin потомку)

  StdinWH @ CLOSE-FILE THROW

  StdoutRH @ PipeLine -> l
  ta tu l ['] ReadNetStatReply CATCH IF DROP 2DROP THEN
  l FREE THROW
  StdoutRH @ CLOSE-FILE THROW

\  StderrRH @ PipeLine -> l
\  ta tu l ['] ReadNetStatReply CATCH IF DROP 2DROP THEN
\  l FREE THROW
  StderrRH @ CLOSE-FILE THROW
;
: NetStatHtml<  ( -- )
  " <table class='sortable' id='sp_table' cellpadding='0' cellspacing='0'>
<thead><tr class='sp_head'><th class='proto'>Прот</th><th class='pid'>pid</th><th class='process'>Процесс</th>
<th class='state'>Состояние</th><th class='ip'>IP</th><th class='port'>П</th><th class='rip'>IP</th><th class='rport'>П</th></tr></thead>
<tbody>"
  uNS !
;
: >NetStatHtml  ( -- addr u )
  " </tbody></table>" uNS @ S+
  uNS @ STR@
;
: >NetStatHtml< ( ta tu pid -- )
  uNSpid !
  ['] (NetStatHtml) CATCH ?DUP IF ." ns_err=" . 2DROP THEN
;
: NetStatHtml ( ta tu pid -- addr u ) \ при pid=-1 - все
  NetStatHtml<
  >NetStatHtml<
  >NetStatHtml
;
: NetStatPort ( port -- addr u )
  " :{-} " STR@
;
: NetStatAddProc ( addr u -- )
  S" " 2SWAP " *{s}" STR@ GetProcessInfoByName NIP NIP NIP NIP >NetStatHtml<
;

\EOF

\ фильтр по состоянию соединения
S" " TRUE NetStatHtml TYPE CR
S" ESTABLISHED" TRUE NetStatHtml TYPE CR
S" LISTENING" TRUE NetStatHtml TYPE CR
S" TIME_WAIT" TRUE NetStatHtml TYPE CR
S" CLOSE_WAIT" TRUE NetStatHtml TYPE CR
S" UDP" TRUE NetStatHtml TYPE CR

\ по портам:
NetStatHtml<   S" :25 " TRUE >NetStatHtml<  S" :110 " TRUE >NetStatHtml<  S" :143 " TRUE >NetStatHtml< >NetStatHtml TYPE CR
\ или то же без кавычек:
NetStatHtml<   25 NetStatPort TRUE >NetStatHtml<  110 NetStatPort TRUE >NetStatHtml<  143 NetStatPort TRUE >NetStatHtml< >NetStatHtml TYPE CR

\ для заданного процесса:
S" " S" *Eproxy.exe" GetProcessInfoByName NIP NIP NIP NIP NetStatHtml TYPE CR

\ для набора процессов:
NetStatHtml<
  S" " S" *acSMTP.exe" GetProcessInfoByName NIP NIP NIP NIP >NetStatHtml<
  S" " S" *smtpsend4.exe" GetProcessInfoByName NIP NIP NIP NIP >NetStatHtml<
>NetStatHtml TYPE CR

\ то же, короче:
NetStatHtml< S" acSMTP.exe" NetStatAddProc S" smtpsend4.exe" NetStatAddProc >NetStatHtml TYPE CR

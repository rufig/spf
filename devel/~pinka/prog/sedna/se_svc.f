\ Windows service to wrap sedna gov
\ 14.Mar.2009 ruvim@forth.org.ru
\ $Id$

\ REQUIRE StartService    ~ac/lib/win/service/SERVICE.F
REQUIRE StartAppWaitDir ~ac/lib/win/process/process.f
REQUIRE STR@            ~ac/lib/str5.f
REQUIRE AsQWord         ~pinka/spf/quoted-word.f
REQUIRE LAUNCH          ~pinka/lib/multi/launch.f
REQUIRE CreateMut       ~pinka/lib/multi/Mutex.f
REQUIRE NextSubstring   ~pinka/lib/parse.f
REQUIRE OPEN-LOGFILE    ~pinka/samples/2005/lib/append-file.f
REQUIRE WORD|TAIL       ~pinka/samples/2005/lib/split-white.f
REQUIRE OFF             lib/ext/onoff.f
REQUIRE 2VARIABLE       lib/include/double.f
REQUIRE NOWADAYS        src/spf_date.f

CREATE build-date NOWADAYS S",

2VARIABLE _databases

WARNING OFF
: ModuleName_o ModuleName ;
: ModuleName ( -- a u ) \ redefine to specify command line for service
  _databases 2@ ModuleName " {''}{s}{''} -db '{s}' -svc" STR@
;
WARNING ON
`~ac/lib/win/service/SERVICE.F INCLUDED

\ =====
\ Sedna specifics

: sedna-running? ( -- flag )
  `SEDNA1500.SHMEM_GLOBAL 0 CreateMut ( h ior ) IF \ error, -- object exists
     DROP TRUE EXIT
  THEN DeleteMut THROW FALSE
  \ work properly only for the same user
;

\ =====
\ shortcuts and wrappers

: svc-name ( -- a u ) `sedna ;
: sedna-folder ( -- a u ) ModuleDirName ;
: se_gov  ( -- a u ) sedna-folder " {s}se_gov.exe -background-mode off"   STR@ ;
: se_stop ( -- a u ) sedna-folder " {s}se_stop.exe"                       STR@ ;
: se_sm   ( d-database -- a u ) sedna-folder " {s}se_sm.exe {s}"          STR@ ;

: logfile sedna-folder " {s}se_svc.status"   STR@ ;
: set-output ( -- ) logfile 2DUP EMPTY OPEN-LOGFILE THROW DUP TO H-STDOUT TO H-STDERR ;

: exec-se ( a u -- result )
  2DUP 2>R
  0. -1 StartAppWaitDir ( result-code ior )
  2R> TYPE ."  --- "
  ERROR ." result code: " DUP . CR
;

\ =====
\ "service" logic

: stop-sedna; ( -- )
  se_stop exec-se
  100 PAUSE BYE
;
: start-sedna-wait; ( -- )
  sedna-running? IF se_stop exec-se THEN
  se_gov  TYPE CR
  se_gov  exec-se  \ -background-mode off
  100 PAUSE BYE
;
: start-databases ( -- )
  3000 PAUSE \ wait for gov started
  _databases 2@ BEGIN WORD|TAIL 2SWAP DUP WHILE
    ( d-dbname ) se_sm exec-se 0<> IF stop-sedna; THEN
  REPEAT 2DROP 2DROP
;
: svc; ( -- )
  set-output
  'start-sedna-wait; LAUNCH
  'start-databases   LAUNCH
  svc-name StartService 0<> IF ." error on StartService" CR THEN
  stop-sedna;
;


\ =====
\ command line options

: -svc svc; ;
: -db
  NextSubstring _databases 2!
;
: -install
  svc-name CreateService ERR ERROR OK BYE
;
: -uninstall
  svc-name DeleteService ERR ERROR OK BYE
;
: -version
  build-date COUNT
  " Windows service for Sedna XML DBMS -- se_svc version 1.0 ({s})
(C) 2009 ruvim@forth.org.ru
Sources available at http://spf.cvs.sourceforge.net/spf/devel/~pinka/prog/sedna/
" STYPE ." Based on " (TITLE)  BYE
;
: help
`} `{
" Usage: se_svc {s} -db <list> -install | -uninstall {s}
options:
  -db 'db1 db2 dbN'  - the databases to start with service
  -install           - to install service 'sedna'
  -uninstall         - to remove service 'sedna'
  -version           - display version
" STR@ TYPE
;
: -help help BYE ;
: --help -help ; : /? -help ;



\ =====
\ MAIN bindings

:NONAME ( -- )
  COMMANDLINE-OPTIONS NIP 0= IF help THEN
; MAINX !

'BYE TO <MAIN>

\ OPT?  \ DIS-OPT

FALSE TO OPT?

REQUIRE {       ~ac\lib\locals.f

: (INIT1)  \ part1. -- see /spf/src/spf_init.f#(INIT)
  0 TO H-STDLOG
  0 TO H-STDIN
  CONSOLE-HANDLES
  ['] CGI-OPTIONS ERR-EXIT
  MAINX @ ?DUP IF ERR-EXIT THEN   \ (?)
;

: (INIT2)  \ part2. (not used here)
  SPF-INIT?  IF
    ['] SPF-INI ERR-EXIT
  THEN OPTIONS
  CGI? @ 0= POST? @ OR IF ['] <MAIN> ERR-EXIT THEN
  BYE
;

: (dllinit) ( reserved reason hinstance -- retcode )
  OVER 0 = IF  ." DLL_PROCESS_DETACH "        ELSE
  OVER 1 = IF (INIT1) ." DLL_PROCESS_ATTACH " ELSE
  OVER 2 = IF  ." DLL_THREAD_ATTACH "  ELSE
  OVER 3 = IF  ." DLL_THREAD_DETACH "  ELSE
  OVER .
  THEN THEN THEN THEN CR
  2DROP DROP
  1  \ 0 to fail
;



VARIABLE _CNT 

: PROCESS-INIT-ONCE ( n -- )
  _CNT @ 0= IF PROCESS-INIT ELSE DROP THEN _CNT 1+!
;

ALIGN HERE  \ see spf_win_defwords.f#EXTERN and tc_spf.F#PROCESSPROC:
  3 CELLS LIT,
  ' PROCESS-INIT-ONCE COMPILE,
  ' (dllinit) COMPILE,
  RET,
  ( xt )
HEADER DllMain  ' _WNDPROC-CODE COMPILE, ,  \ see spf_win_defwords.f#CALLBACK:




: _sfind  ( a u -- 0|xt )
  SFIND  0= IF 2DROP 0 THEN
;
\ ' _sfind WNDPROC: sfind
 ' _sfind 2 CELLS CALLBACK: sfind


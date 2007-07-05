\ Адаптация locals к новым словам

: WORDDEPTH 
  >IN @ >R
  NextWord SFIND DUP
  0= IF RDROP -321 THROW THEN
  ALSO vocLocalsSupport
  R> >IN ! HEADER IMMEDIATE
  1 = IF COMPILE,
      ELSE LIT, ['] COMPILE, COMPILE, THEN
  LIT, [ ALSO vocLocalsSupport ] uAddDepth [ PREVIOUS ] LIT, POSTPONE +!
  RET,
  PREVIOUS
;

WARNING @ WARNING 0!
 tryDEPTH WORDDEPTH try
-tryDEPTH WORDDEPTH except
-tryDEPTH WORDDEPTH finally 
-tryDEPTH WORDDEPTH stop-except
WARNING !
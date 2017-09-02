\ LEXTERN и LCALLBACK - "облегченные" версии EXTERN и CALLBACK,
\ пропускающие создание нового форт-окружения при входе в callback.
\ Замена для ~af/lib/QuickWNDPROC.f, не работающего под Linux.
\ Требует изменения ядра branch-linux-port spf_win_api.f 1.9.4.1 !

: LEXTERN ( xt1 n -- xt2 )
  HERE
  SWAP DROP
\  SWAP LIT,
\  ['] FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
\  ['] <FORTH-INSTANCE COMPILE,
  RET,
;

: LCALLBACK: ( xt n "name" -- )
\ Здесь n в байтах!
  LEXTERN
  HEADER
  ['] _WNDPROC-CODE COMPILE,
  ,
;
: QUICK_WNDPROC ( xt "name" -- )
  16 LEXTERN
  CREATE  ( -- enter_point )
  ['] _WNDPROC-CODE COMPILE,
  ,
;
\EOF Слегка усложненный тест из ~af/lib/QuickWNDPROC.f:

: MyCallBackWord \ -- 
  TlsIndex@ .
  BASE @ . ." test passed!" CR
;
' MyCallBackWord QUICK_WNDPROC MyCallBackProc
: test \ --
  TlsIndex@ .
  MyCallBackProc API-CALL
;

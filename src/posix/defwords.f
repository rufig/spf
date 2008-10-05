\ $Id$
\ 
\ Интерфейсы с Linux - определения в словаре экспортируемых функций 
\ [callback, wndproc и т.п.]
(  
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

: EXTERN ( xt1 n -- xt2 )
  HERE
  SWAP LIT,
  ['] FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
  ['] <FORTH-INSTANCE COMPILE,
  RET,
;

: CALLBACK: ( xt n "name" -- )
\ Здесь n в байтах!
  EXTERN
  HEADER
  ['] _WNDPROC-CODE COMPILE,
  ,
;

: TASK ( xt1 -- xt2 )
  CELL EXTERN
  HERE SWAP
  ['] _WNDPROC-CODE COMPILE,
  ,
;
: TASK: ( xt "name" -- )
  TASK CONSTANT
;

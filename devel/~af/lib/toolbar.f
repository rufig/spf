\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Создание массива, описывающего тулбар

0x00 CONSTANT TBSTYLE_BUTTON
0x01 CONSTANT TBSTYLE_SEP
0x02 CONSTANT TBSTYLE_CHECK
0x04 CONSTANT TBSTATE_ENABLED

0
4 -- iBitmap
4 -- idCommand
1 -- fsState
1 -- fsStyle
1 -- bReserved1
1 -- bReserved2
4 -- dwData
4 -- iString
CONSTANT /TBBUTTON

: (TB-BUTTON) ( idCommand iBitmap -- addr)
  HERE DUP /TBBUTTON DUP ALLOT ERASE
  SWAP OVER iBitmap !
  SWAP OVER idCommand !
  TBSTATE_ENABLED OVER fsState C!
;

: TB-BUTTON ( idCommand iBitmap -- )
  (TB-BUTTON)
  TBSTYLE_BUTTON SWAP fsStyle C!
;

: TB-CHECK  ( idCommand iBitmap -- )
  (TB-BUTTON)
  TBSTYLE_CHECK SWAP fsStyle C!
;

: TB-SEP
  0 0 (TB-BUTTON)
  TBSTYLE_SEP SWAP fsStyle C!
;

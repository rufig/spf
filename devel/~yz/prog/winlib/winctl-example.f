DIS-OPT \ для СП-Форта ниже 4.10
REQUIRE button ~yz/lib/winctl.f
SET-OPT

0 VALUE ls
0 VALUE g
0 VALUE c
0 VALUE e

PROC: adds { \ [ 255 ] str }
  str e -text@  str c addstring
PROC;

: newcolor 
  thisctl -pos@ 255 SWAP - DUP 255 rgb thisctl -bgcolor! 
  thisctl -pos@ S>D <# 0 HOLD #S #> DROP ls -text! ;

: newpos ( incr -- )
  thisctl -pos@ + thisctl -min@ MAX thisctl -max@ MIN thisctl -pos!
  newcolor ;

MESSAGES: scroll
M: sb_lineleft  -1  newpos M;
M: sb_lineright  1  newpos M;
M: sb_pageleft  -10 newpos M;
M: sb_pageright  10 newpos M;
M: sb_thumbposition
  wparam HIWORD thisctl -pos! newcolor
M;
MESSAGES;

GROUP mm

PROC: dia
  " Пример диалога" MODAL...
    GRID 
      mm start-group
      1 " Мене" radio | 2 " Текел" radio | 3 " Фарес" radio |
      ===
      multiedit DUP TO e 120 25 this resize -middle | 
      " >>" button adds this -command! | combo DUP TO c 150 300 this resize -middle |
      ===
      " 0" label DUP TO ls 10 -width blue ls -bgcolor!  white ls -color! | 
      hscroll  255 this -max!  scroll this -notify!  white this -bgcolor!  -xspan |
    GRID; TO g
    GRID
      1 IMAGE-BASE LoadIconA icon 10 -width | hline -xspan -middle |
      ===
      listbox  " *.*" 0 this lb-dir  120 150 this resize -yspan | g |
      ===
      hline -xspan |
      ===
      filler 40 -width |
      "    Ok   " ['] dialog-ok ok-button -right | 
      " Отмена" cancel-button |
    GRID; SHOW
    dialog-termination W: idcancel = IF 
      ." Диалог был отменен" CR
    ELSE
      mm @ -1 = IF ." Ничего не выбрано" ELSE ." Выбор: " mm @ . THEN CR
      ." В комбинированном списке " 
      c -selected@ -1 = IF  ." ничего не выбрано"
      ELSE ." выбрано: " HERE c -selected@ c fromcombo HERE .ASCIIZ THEN
      CR
    THEN
  ...MODAL
PROC;

KEYTABLE
  dia ONKEY vk_space
KEYTABLE;

: run
  WINDOWS...
  0 dialog-window TO winmain
  " Элементы управления" winmain -text!
  winmain create-status
  " Нажмите пробел, чтобы увидеть диалоговое окно..." 0 winmain set-status
  winmain winshow
  ...WINDOWS
  BYE
;

\ 0 TO SPF-INIT?
 ' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
\ ' run MAINX !
\ S" winctl-example.exe" SAVE  
run
BYE

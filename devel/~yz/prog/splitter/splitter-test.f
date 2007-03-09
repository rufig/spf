REQUIRE splitter ~yz/lib/splitter.f

: test
  WINDOWS...
  0 dialog-window TO winmain
  GRID
    
    GRID
      " Вертикальный" label |
      ===
      multiedit -xspan -yspan |
    GRID;

    GRID
      GRID
        " Горизонтальный" label |
        ===
        multiedit -xspan -yspan |
      GRID;
      GRID
        multiedit -xspan -yspan |
      GRID;
      hsplitter 0 -xmargin 0 -ymargin -xspan -yspan |
    GRID;

    splitter 0 -xmargin 0 -ymargin -xspan -yspan |
  GRID; winmain -grid!
  " Разделители" winmain -text!
  300 300 winmain winresize
  winmain wincenter
  winmain winshow
  ...WINDOWS
  BYE
;

test


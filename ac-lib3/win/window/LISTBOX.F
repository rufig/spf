REQUIRE Window  ~ac/lib/win/window/window.f

: ListboxAddItem ( addr u listbox -- index )
  || a u lb addr c || (( a u lb ))
  a u + DUP -> addr  C@ -> c  0 addr C!
  a 0 LB_ADDSTRING lb SendMessageA
  c addr C!
;
: ListboxDeleteItem ( index listbox -- ) \ zero based index
  0 ROT ROT LB_DELETESTRING SWAP SendMessageA DROP
;
: ListboxScrollTo ( index listbox -- )
  0 ROT ROT LB_SETTOPINDEX SWAP SendMessageA DROP
;
: ListboxFromVoc ( wnd wid -- w )
  || wnd wid a c w || (( wnd wid ))
  S" LISTBOX" WS_VSCROLL WS_HSCROLL OR wnd Window -> w
  wid @
  BEGIN
    DUP
  WHILE
    DUP COUNT  2DUP +  DUP -> a  C@ -> c  0 a C!
    w ListboxAddItem DROP
    c a C!
    CDR
  REPEAT DROP
  w
;
: ListboxGetSel ( listbox -- index | LB_ERR )
  0 0 ROT LB_GETCURSEL SWAP SendMessageA
;

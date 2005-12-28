ONLY FORTH DEFINITIONS
0 VALUE g1
0 VALUE g2

WINAPI: ImageList_Create        COMCTL32.DLL
WINAPI: ImageList_ReplaceIcon   COMCTL32.DLL
WINAPI: ImageList_GetImageCount COMCTL32.DLL

: create-il ( size -- il )
  >R 5 5 W: ilc_color8 R> DUP ImageList_Create ;
: add-icon ( resno il -- ) 
  >R IMAGE-BASE LoadIconA -1 R> ImageList_ReplaceIcon DROP ;

: make-grids
GRID
    [ ALSO Model1 ]
     " Teta :" label -xfixed | edit DUP TO e_Teta -xspan |
    ===
     "   m0 :" label -xfixed | edit DUP TO e_m -xspan |
    ===
     "   v0 :" label -xfixed | edit DUP TO e_v -xspan |
    ===
     "    S :" label -xfixed | edit DUP TO e_S -xspan |
    ===
     " Time :" label -xfixed | edit DUP TO e_time -xspan |
    ===
     hline 500 1 this ctlresize |
    ===
     " График1" button -right add-1 this -command! | 
     " График2" button -left  add-2 this -command! | 
    [ PREVIOUS ]
GRID; TO g1

GRID
    [ ALSO Model2 ]
     " Teta :" label -xfixed | edit DUP TO e_Teta -xspan |
    ===
     "   m0 :" label -xfixed | edit DUP TO e_m -xspan |
    ===
     "   mF :" label -xfixed | edit DUP TO e_mf -xspan |
    ===
     "   T0 :" label -xfixed | edit DUP TO e_T0 -xspan |
    ===
     "   v0 :" label -xfixed | edit DUP TO e_v -xspan |
    ===
     " Time :" label -xfixed | edit DUP TO e_time -xspan |
    ===
     " TimeF :" label -xfixed | edit DUP TO e_timeF -xspan |
    ===
     hline 500 1 this ctlresize |
    ===
     " График1" button -right add-1 this -command! | 
     " График2" button -left  add-2 this -command! | 
    [ PREVIOUS ]
GRID; TO g2
;

: make-tabs
 0 tabcontrol 
 16 create-il DUP 1 SWAP add-icon 0 this -imagelist!
 g1 " Снаряд" 0 0 this add-item
 g2 " Ракета" 0 1 this add-item
;

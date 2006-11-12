\ REQUIRE LOAD-CONSTANTS     ~yz/lib/wincons.f
\ S" ~yz/cons/commctrl.const" LOAD-CONSTANTS
\ WINAPI: LoadIconA       USER32.DLL

MODULE: def-icon

WINAPI: ImageList_Create      COMCTL32.DLL
WINAPI: ImageList_ReplaceIcon COMCTL32.DLL
WINAPI: ImageList_GetImageCount COMCTL32.DLL

: create-il ( size -- il )
  >R 5 5 W: ilc_color8 R> DUP ImageList_Create ;
: add-icon ( resno il -- ) 
  >R IMAGE-BASE LoadIconA -1 R> ImageList_ReplaceIcon DROP ;

EXPORT

: def-small-icon-il  ( -- il n ) 16 create-il DUP 1 SWAP add-icon W: lvsil_small ; 
: def-normal-icon-il ( -- il n ) 32 create-il DUP 1 SWAP add-icon W: lvsil_normal ; 

\ def-icon-small-il ctl -imagelist!

;MODULE

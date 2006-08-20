MODULE: winlib-icons

WINAPI: ImageList_Create      COMCTL32.DLL
WINAPI: ImageList_ReplaceIcon COMCTL32.DLL
WINAPI: ImageList_GetImageCount COMCTL32.DLL

: create-il ( size -- il )
  >R 5 5 W: ilc_color8 R> DUP ImageList_Create ;
: add-icon ( resno il -- ) 
  >R IMAGE-BASE LoadIconA -1 R> ImageList_ReplaceIcon DROP ;

EXPORT

: add-default-icon ( ctl -- )  >R 16 create-il DUP 1 SWAP add-icon 0 R> -imagelist!  ;

;MODULE

WINAPI: LoadImageA              USER32.DLL
WINAPI: ImageList_Create        COMCTL32.DLL
WINAPI: ImageList_AddIcon       COMCTL32.DLL

HEX
0010 CONSTANT LR_LOADFROMFILE
0020 CONSTANT LR_LOADTRANSPARENT
   1 CONSTANT IMAGE_ICON
   1 CONSTANT ILC_MASK
DECIMAL

\ ------------------ значки ----------------
: LOAD-ICON16 ( c-addr u -- hicon ) \ загрузить маленькую иконку из файла *.ico
  DROP >R
  LR_LOADFROMFILE LR_LOADTRANSPARENT OR 16 16 IMAGE_ICON R> 0 LoadImageA
;
: —оздать—писок«начков ( -- h )
  0 3 ILC_MASK 16 16 ImageList_Create
;
: ƒобавить«начок ( h c-addr u -- index )
  LOAD-ICON16 SWAP ImageList_AddIcon
;
